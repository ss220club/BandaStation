'use strict';
// Keep stdout exclusively for MCP. No downloads or configuration writes at startup.
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { once } = require('node:events');
const { randomUUID } = require('node:crypto');

async function main() {
  if (Number(process.versions.node.split('.')[0]) < 20) throw new Error('Node.js 20 or newer is required by the pinned Playwright runtime.');
  if (process.platform !== 'win32' || !process.env.LOCALAPPDATA)
    throw new Error('This launcher uses the installed Windows Microsoft Edge.');
  const root = path.resolve(__dirname, '../..');
  const installed = path.join(process.env.LOCALAPPDATA, 'BandaStation/agent-tools/browser');
  const expected = require('./package.json').dependencies['@playwright/mcp'];
  const manifest = path.join(installed, 'node_modules/@playwright/mcp/package.json');
  if (!fs.existsSync(manifest) || JSON.parse(fs.readFileSync(manifest, 'utf8')).version !== expected)
    throw new Error('Run powershell.exe -NoProfile -File tools/agents/setup-tools.ps1 first.');
  if (!fs.readFileSync(path.join(installed, 'package-lock.json')).equals(fs.readFileSync(path.join(__dirname, 'package-lock.json'))))
    throw new Error('Agent dependency lock changed; rerun tools/agents/setup-tools.ps1.');
  const edge = [process.env['ProgramFiles(x86)'], process.env.ProgramFiles, process.env.LOCALAPPDATA]
    .filter(Boolean).map(dir => path.join(dir, 'Microsoft/Edge/Application/msedge.exe')).find(file => fs.existsSync(file));
  if (!edge) throw new Error('Microsoft Edge is not installed; see .AGENTS/TOOLS.md.');
  if (process.argv.includes('--check')) {
    require(path.join(installed, 'node_modules/@playwright/mcp'));
    console.log(`PASS: Node ${process.version}; Playwright MCP ${expected}; installed Microsoft Edge; dependency lock matches.`);
    return;
  }
  const tempParent = fs.realpathSync(os.tmpdir());
  // Playwright creates this unique directory only when a tool writes an artifact.
  // A config-only Codex connection must not leave an empty folder if the host kills it.
  const output = path.join(tempParent, 'bandastation-mcp-'+randomUUID());
  console.error(`Playwright artifacts: ${output}`);
  let child;
  let stopTimer;
  const stop = () => {
    if (!child || stopTimer) return;
    child.stdin.end();
    stopTimer = setTimeout(() => child.kill(), 5000);
    stopTimer.unref();
  };
  try {
    child = spawn(process.execPath, [path.join(installed, 'node_modules/@playwright/mcp/cli.js'),
      '--browser', 'msedge', '--executable-path', edge, '--headless', '--isolated',
      '--viewport-size', '1920x1080', '--output-dir', output],
    { cwd: root, stdio: ['pipe', 'inherit', 'inherit'], windowsHide: true });
    child.stdin.on('error', error => { if (error.code !== 'EPIPE') console.error(error.message); });
    process.stdin.pipe(child.stdin);
    process.once('SIGINT', stop);
    process.once('SIGTERM', stop);
    const [code] = await once(child, 'exit');
    process.exitCode = code === null ? 1 : code;
  } finally {
    clearTimeout(stopTimer);
    process.removeListener('SIGINT', stop);
    process.removeListener('SIGTERM', stop);
    process.stdin.unpipe();
    process.stdin.destroy();
    // Delete only the exact, freshly allocated direct child of system TEMP.
    if (path.dirname(output) !== tempParent || !path.basename(output).startsWith('bandastation-mcp-'))
      throw new Error('Unexpected MCP temporary path; cleanup refused.');
    if (fs.existsSync(output)) {
      if (fs.lstatSync(output).isSymbolicLink()) throw new Error('Redirected MCP temporary directory; cleanup refused.');
      fs.rmSync(output, { recursive: true, force: true, maxRetries: 3, retryDelay: 100 });
    }
  }
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
