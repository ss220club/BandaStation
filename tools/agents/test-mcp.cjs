'use strict';
// End-to-end MCP transport/browser smoke, using only Node built-ins and local HTTP.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const readline = require('node:readline');
const { spawn } = require('node:child_process');
const { once } = require('node:events');
const { pathToFileURL } = require('node:url');

async function main() {
  const root = path.resolve(__dirname, '../..');
  const page = '<!doctype html><meta charset="utf-8"><title>BandaStation MCP smoke</title>' +
    '<button id="event" onclick="document.getElementById(\'result\').textContent=\'event received\'">Test event</button>' +
    '<output id="result">ready</output>';
  const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(page);
  });
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  let child;
  let lines;
  let output;
  let stderr = '';
  let sequence = 0;
  const pending = new Map();
  let exited;
  function send(value) { child.stdin.write(JSON.stringify({ jsonrpc: '2.0', ...value })+'\n'); }
  function request(method, params = {}) {
    const id = ++sequence;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => { pending.delete(id); reject(new Error('MCP timeout: '+method)); }, 45000);
      pending.set(id, {
        resolve: value => { clearTimeout(timer); resolve(value); },
        reject: error => { clearTimeout(timer); reject(error); }
      });
      send({ id, method, params });
    });
  }
  async function call(name, args = {}) {
    const result = await request('tools/call', { name, arguments: args });
    assert.ok(!result.isError, name+': '+JSON.stringify(result));
    return result;
  }
  try {
    child = spawn(process.execPath, [path.join(__dirname, 'playwright-mcp.cjs')],
      { cwd: root, stdio: ['pipe', 'pipe', 'pipe'], windowsHide: true });
    exited = once(child, 'exit');
    child.stderr.on('data', chunk => {
      stderr += chunk;
      const match = stderr.match(/Playwright artifacts: ([^\r\n]+)/);
      if (match) output = match[1];
    });
    child.stdin.on('error', () => {});
    lines = readline.createInterface({ input: child.stdout });
    lines.on('line', line => {
      let message;
      try { message = JSON.parse(line); } catch {
        for (const entry of pending.values()) entry.reject(new Error('Non-JSON output on MCP stdout'));
        pending.clear(); return;
      }
      if (message.method === 'roots/list') {
        send({ id: message.id, result: { roots: [{ uri: pathToFileURL(root).href, name: 'BandaStation' }] } });
      } else if (message.method && message.id !== undefined) {
        if (message.method === 'ping') send({ id: message.id, result: {} });
        else send({ id: message.id, error: { code: -32601, message: 'Unsupported client method' } });
      } else if (pending.has(message.id)) {
        const item = pending.get(message.id);
        pending.delete(message.id);
        if (message.error) item.reject(new Error(JSON.stringify(message.error)));
        else item.resolve(message.result);
      }
    });
    child.on('exit', () => {
      for (const item of pending.values()) item.reject(new Error('MCP exited early: '+stderr));
      pending.clear();
    });
    const init = await request('initialize', {
      protocolVersion: '2024-11-05', capabilities: { roots: { listChanged: false } },
      clientInfo: { name: 'bandastation-smoke', version: '1.0.0' }
    });
    assert.ok(init.serverInfo.name);
    send({ method: 'notifications/initialized' });
    const { tools } = await request('tools/list');
    if (process.argv.includes('--describe-tools')) {
      console.log(JSON.stringify(tools.filter(tool => ['browser_click', 'browser_evaluate', 'browser_take_screenshot'].includes(tool.name)), null, 2));
      return;
    }
    // Compare every configured name against the real server, not a copied expected list.
    const config = fs.readFileSync(path.join(root, '.codex/config.toml'), 'utf8');
    const section = config.split('[mcp_servers.bandastation-browser]')[1];
    assert.ok(section, 'Browser MCP section missing');
    const allow = section.match(/enabled_tools\s*=\s*\[([\s\S]*?)\]/);
    assert.ok(allow, 'MCP tool allowlist missing');
    for (const [, name] of allow[1].matchAll(/"([^"]+)"/g))
      assert.ok(tools.some(tool => tool.name === name), 'Configured MCP tool missing: '+name);
    console.log(`PASS: MCP initialize (${init.serverInfo.name} ${init.serverInfo.version}); tools/list; configured allowlist`);
    const navigation = await call('browser_navigate', { url: `http://127.0.0.1:${server.address().port}/` });
    let snapshot = navigation.content.filter(item => item.type === 'text').map(item => item.text).join('\n');
    const savedSnapshot = snapshot.match(/\[Snapshot\]\(([^)]+)\)/);
    if (savedSnapshot) {
      const file = path.resolve(savedSnapshot[1]);
      assert.equal(path.dirname(file), output, 'Snapshot must stay in the allocated MCP temporary directory');
      snapshot = fs.readFileSync(file, 'utf8');
    }
    const button = snapshot.match(/button "Test event" \[ref=([^\]]+)\]/);
    assert.ok(button, 'Button reference missing from live browser snapshot: '+snapshot);
    await call('browser_click', { element: 'Test event button', target: button[1] });
    const action = await call('browser_evaluate', { function: "() => ({ result: document.querySelector('#result').innerText, width: innerWidth, height: innerHeight })" });
    const actionText = JSON.stringify(action);
    assert.ok(actionText.includes('event received') && actionText.includes('1920') && actionText.includes('1080'), actionText);
    await call('browser_take_screenshot', { type: 'png', filename: path.join(output, 'smoke.png'), scale: 'css' });
    const png = fs.readFileSync(path.join(output, 'smoke.png'));
    assert.ok(png.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10])), 'Screenshot was not written');
    assert.deepEqual([png.readUInt32BE(16), png.readUInt32BE(20)], [1920, 1080], 'Unexpected screenshot dimensions');
    await call('browser_close');
    console.log('PASS: isolated Edge; local HTTP; DOM event; 1920x1080; real PNG; browser_close');
  } finally {
    server.closeAllConnections();
    await new Promise(resolve => server.close(resolve));
    if (child) {
      child.stdin.end();
      const timer = setTimeout(() => child.kill(), 8000);
      try {
        const [code] = await exited;
        assert.equal(code, 0, 'MCP shutdown failed: '+stderr);
      } finally { clearTimeout(timer); lines?.close(); }
    }
    if (output) assert.ok(!fs.existsSync(output), 'MCP temporary artifacts remain: '+output);
  }
  console.log('PASS: MCP shutdown; temporary artifacts and local HTTP server cleaned up');
}
main().catch(error => { console.error(error.stack); process.exitCode = 1; });
