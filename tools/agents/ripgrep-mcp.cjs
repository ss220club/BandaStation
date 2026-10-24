'use strict';
// A checkout-local launcher. SDK/dependencies are pinned and stored externally.
const fs = require('node:fs');
const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { spawnSync } = require('node:child_process');
async function main() {
  if (!process.env.LOCALAPPDATA) throw new Error('LOCALAPPDATA is required.');
  const root = path.resolve(__dirname, '../..');
  const installed = path.join(process.env.LOCALAPPDATA, 'BandaStation/agent-tools/ripgrep');
  const sourceLock = fs.readFileSync(path.join(__dirname, 'ripgrep/package-lock.json'));
  if (!fs.existsSync(path.join(installed, 'package-lock.json')) || !fs.readFileSync(path.join(installed, 'package-lock.json')).equals(sourceLock))
    throw new Error('Run tools/agents/setup-tools.ps1 before connecting ripgrep MCP.');
  if (!fs.readFileSync(path.join(installed, 'index.mjs')).equals(fs.readFileSync(path.join(__dirname, 'ripgrep/index.mjs'))))
    throw new Error('Ripgrep MCP source changed; rerun tools/agents/setup-tools.ps1.');
  const check = spawnSync('rg', ['--version'], { encoding: 'utf8', windowsHide: true });
  if (check.error || check.status !== 0) throw new Error('ripgrep executable is missing from PATH.');
  process.env.BANDASTATION_WORKSPACE = root;
  if (process.argv.includes('--check')) {
    const sdk = JSON.parse(fs.readFileSync(path.join(installed, 'node_modules/@modelcontextprotocol/sdk/package.json'), 'utf8'));
    console.log(`PASS: pinned mcp-ripgrep source; SDK ${sdk.version}; ${check.stdout.split(/\r?\n/)[0]}; checkout ${root}`);
    return;
  }
  await import(pathToFileURL(path.join(installed, 'index.mjs')).href);
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
