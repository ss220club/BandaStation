// Adapted from mcp-ripgrep 0.4.0 (MIT; see LICENSE).
// Direct argument arrays replace shell-style quoting. Paths stay in this checkout.
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

const root = fs.realpathSync(process.env.BANDASTATION_WORKSPACE || process.cwd());
const server = new Server({ name: 'bandastation-ripgrep', version: '1.0.0' }, { capabilities: { tools: {} } });
const properties = {
  path: { type: 'string', description: 'Explicit narrow repository-relative file/directory, or absolute path inside this checkout.' },
  pattern: { type: 'string', description: 'Literal text by default; set regex=true for a regular expression.' },
  regex: { type: 'boolean', default: false },
  caseSensitive: { type: 'boolean', default: true },
  filePattern: { type: 'string', description: 'Optional ripgrep glob, such as *.dm.' },
  maxResults: { type: 'integer', minimum: 1, maximum: 200, default: 40 }
};
function tool(name, description, fields, required) {
  return { name, description, inputSchema: { type: 'object', properties: Object.fromEntries(fields.map(key => [key, properties[key]])), required, additionalProperties: false },
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false } };
}
const tools = [
  tool('search', 'Bounded read-only code search in an explicit path; uses literal matching by default.', Object.keys(properties), ['path', 'pattern']),
  tool('count-matches', 'Count matching lines per file within one explicit path.', Object.keys(properties), ['path', 'pattern']),
  tool('list-files', 'List files in an explicit directory; respects Git exclusions and never follows symlinks.', ['path', 'filePattern', 'maxResults'], ['path']),
  tool('list-file-types', 'Show the installed ripgrep file-type definitions.', [], [])
];
function searchPath(value) {
  if (typeof value !== 'string' || !value.trim() || value.includes('\0')) throw new Error('An explicit repository path is required.');
  const resolved = fs.realpathSync(path.resolve(root, value));
  const relative = path.relative(root, resolved);
  if (path.isAbsolute(relative) || relative === '..' || relative.startsWith('..'+path.sep)) throw new Error('Search path escapes this checkout.');
  if (relative.split(path.sep).some(part => part.toLowerCase() === '.git')) throw new Error('Git internal files are outside code-search scope.');
  return resolved;
}
function integer(value, fallback) {
  if (value === undefined) return fallback;
  if (!Number.isInteger(value) || value < 1 || value > 200) throw new Error('maxResults must be an integer from 1 to 200.');
  return value;
}
async function execute(args) {
  return new Promise((resolve, reject) => {
    const child = spawn('rg', args, { cwd: root, shell: false, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
    let output = '', errors = '', truncated = false, timedOut = false;
    const timeout = setTimeout(() => { timedOut = true; child.kill(); }, 20000);
    child.stdout.setEncoding('utf8');
    child.stderr.setEncoding('utf8');
    child.stdout.on('data', chunk => {
      output += chunk;
      if (output.length > 256000) { output = output.slice(0, 256000); truncated = true; child.kill(); }
    });
    child.stderr.on('data', chunk => { errors = (errors+chunk).slice(0, 4000); });
    child.on('error', error => { clearTimeout(timeout); reject(error); });
    child.on('close', code => {
      clearTimeout(timeout);
      if (timedOut) reject(new Error('Search timed out; use a narrower path or pattern.'));
      else if (!truncated && code !== 0 && code !== 1) reject(new Error(errors || `ripgrep exited ${code}`));
      else resolve({ output, truncated });
    });
  });
}
server.setRequestHandler(ListToolsRequestSchema, async () => ({ tools }));
server.setRequestHandler(CallToolRequestSchema, async request => {
  try {
    const name = request.params.name;
    const schema = tools.find(entry => entry.name === name);
    if (!schema) throw new Error('Unknown read-only tool: '+name);
    const args = request.params.arguments || {};
    for (const key of Object.keys(args)) if (!(key in schema.inputSchema.properties)) throw new Error('Unsupported argument: '+key);
    const limit = integer(args.maxResults, 40);
    const command = name === 'list-file-types' ? ['--type-list'] : ['--color', 'never'];
    if (name !== 'list-file-types') {
      const target = searchPath(args.path);
      command.push('--glob', '!.git/**', '--glob', '!**/node_modules/**');
      if (args.filePattern !== undefined) {
        if (typeof args.filePattern !== 'string') throw new Error('filePattern must be a string.');
        command.push('--glob', args.filePattern);
      }
      if (name === 'list-files') {
        if (!fs.statSync(target).isDirectory()) throw new Error('list-files expects a directory.');
        command.push('--files', '--', target);
      } else {
        if (typeof args.pattern !== 'string' || !args.pattern || args.pattern.includes('\0')) throw new Error('A non-empty pattern is required.');
        if (args.regex !== undefined && typeof args.regex !== 'boolean') throw new Error('regex must be boolean.');
        if (args.caseSensitive !== undefined && typeof args.caseSensitive !== 'boolean') throw new Error('caseSensitive must be boolean.');
        command.push(name === 'count-matches' ? '--count' : '--line-number');
        if (!args.regex) command.push('--fixed-strings');
        if (args.caseSensitive === false) command.push('--ignore-case');
        command.push('--max-count', String(limit), '--', args.pattern, target);
      }
    }
    const result = await execute(command);
    let lines = result.output.trimEnd().split(/\r?\n/).filter(Boolean);
    const truncated = result.truncated || lines.length > limit;
    lines = lines.slice(0, limit).map(line => line.replaceAll(root+path.sep, '').replaceAll(root+'/', ''));
    return { content: [{ type: 'text', text: JSON.stringify({ workspace: root, matches: lines, truncated }) }] };
  } catch (error) { return { isError: true, content: [{ type: 'text', text: error.message }] }; }
});
await server.connect(new StdioServerTransport());
