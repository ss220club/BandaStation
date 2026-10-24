'use strict';
// Real SDK client/stdio transport plus code-search scenarios and cleanup.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const { randomUUID } = require('node:crypto');
const installed = path.join(process.env.LOCALAPPDATA, 'BandaStation/agent-tools/ripgrep/node_modules/@modelcontextprotocol/sdk/dist/cjs');
const { Client } = require(path.join(installed, 'client/index.js'));
const { StdioClientTransport } = require(path.join(installed, 'client/stdio.js'));
async function main() {
  const root = path.resolve(__dirname, '../..');
  const fixture = path.join(root, 'task_state', 'mcp-smoke-'+randomUUID());
  const childDir = path.join(fixture, "owner's code with spaces");
  fs.mkdirSync(childDir, { recursive: true });
  fs.writeFileSync(path.join(childDir, 'sample.dm'), '/datum/sample\nНайти: literal[1] $()\n--pre=never-run\nneedle\nneedle\nneedle\n');
  const client = new Client({ name: 'bandastation-ripgrep-smoke', version: '1.0.0' });
  const transport = new StdioClientTransport({ command: process.execPath, args: [path.join(__dirname, 'ripgrep-mcp.cjs')], cwd: root, stderr: 'pipe' });
  async function call(name, args) {
    const result = await client.callTool({ name, arguments: args });
    assert.ok(!result.isError, JSON.stringify(result));
    return JSON.parse(result.content.find(item => item.type === 'text').text);
  }
  try {
    await client.connect(transport);
    const { tools } = await client.listTools();
    const config = fs.readFileSync(path.join(root, '.codex/config.toml'), 'utf8');
    const section = config.split('[mcp_servers.bandastation-ripgrep]')[1].split('[mcp_servers.')[0];
    const allowed = section.match(/enabled_tools\s*=\s*\[([\s\S]*?)\]/);
    for (const [, name] of allowed[1].matchAll(/"([^"]+)"/g)) assert.ok(tools.some(tool => tool.name === name), name);
    assert.ok(tools.every(tool => tool.annotations.readOnlyHint && !tool.annotations.destructiveHint));
    const relative = path.relative(root, childDir);
    const literal = await call('search', { path: relative, pattern: 'Найти: literal[1] $()' });
    assert.equal(literal.matches.length, 1);
    assert.ok(literal.matches[0].includes('sample.dm:2:Найти'));
    assert.equal((await call('search', { path: relative, pattern: '--pre=never-run' })).matches.length, 1);
    assert.equal((await call('search', { path: relative, pattern: '^/datum/', regex: true })).matches.length, 1);
    assert.equal((await call('search', { path: relative, pattern: 'absent-token' })).matches.length, 0);
    assert.equal((await call('search', { path: relative, pattern: 'needle', maxResults: 1 })).matches.length, 1);
    assert.equal((await call('list-files', { path: relative, filePattern: '*.dm' })).matches.length, 1);
    assert.ok((await call('count-matches', { path: relative, pattern: 'needle' })).matches[0].endsWith(':3'));
    assert.ok((await call('list-file-types', {})).matches.length);
    for (const args of [{ path: '..', pattern: 'anything' }, { path: '.git/config', pattern: 'anything' }, { path: relative, pattern: 'anything', maxResults: 999 }, { path: relative, pattern: 'anything', command: 'unsafe' }]) {
      assert.ok((await client.callTool({ name: 'search', arguments: args })).isError, 'Invalid search was accepted');
    }
    const junction = path.join(fixture, 'outside-junction');
    fs.symlinkSync(os.tmpdir(), junction, 'junction');
    assert.ok((await client.callTool({ name: 'search', arguments: { path: path.relative(root, junction), pattern: 'anything' } })).isError, 'Junction escaped checkout');
    fs.unlinkSync(junction);
    console.log('PASS: ripgrep MCP initialize/tools/list/allowlist; literal/regex/count/list; Cyrillic, spaces and apostrophes; leading option treated as text; invalid paths/arguments and junction rejected');
  } finally {
    await client.close();
    if (path.dirname(fixture) !== path.join(root, 'task_state') || !path.basename(fixture).startsWith('mcp-smoke-') || fs.lstatSync(fixture).isSymbolicLink()) throw new Error('Unexpected fixture cleanup path');
    fs.rmSync(fixture, { recursive: true, force: true });
  }
  assert.ok(!fs.existsSync(fixture));
  console.log('PASS: ripgrep MCP shutdown and fixture cleanup');
}
main().catch(error => { console.error(error.stack); process.exitCode = 1; });
