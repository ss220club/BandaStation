import { readdirSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, isAbsolute, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

export const REPO_ROOT = join(__dirname, '../../..');

export const DEFAULT_FRAGMENTS_DIR = join(
  REPO_ROOT,
  'modular_bandastation/translations/code/translation_data/ru_names',
);

export function discoverFragments(root: string): string[] {
  const paths: string[] = [];

  function walk(dir: string) {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      const fullPath = join(dir, entry.name);
      if (entry.isDirectory()) {
        walk(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.toml')) {
        paths.push(fullPath);
      }
    }
  }

  walk(root);
  return paths.sort();
}

export function resolveCliPath(
  raw: string | undefined,
  fallback: string,
): string {
  if (!raw) return fallback;
  const expanded = raw.replace(/^~(?=$|[/\\])/, homedir());
  if (isAbsolute(expanded)) return resolve(expanded);
  return resolve(REPO_ROOT, expanded);
}

export interface ParsedFragment {
  rootKey: string;
  fields: Record<string, string>;
}

export type ParseResult =
  | { ok: true; data: ParsedFragment }
  | { ok: false; error: string };

function unescapeString(s: string): string {
  return s.replace(
    /\\(["\\bfnrt]|u[0-9a-fA-F]{4}|U[0-9a-fA-F]{8})/g,
    (_, e: string) => {
      if (e === '"') return '"';
      if (e === '\\') return '\\';
      if (e === 'b') return '\b';
      if (e === 'f') return '\f';
      if (e === 'n') return '\n';
      if (e === 'r') return '\r';
      if (e === 't') return '\t';
      return String.fromCodePoint(parseInt(e.slice(1), 16));
    },
  );
}

// TOML parser
//   - Table header: [bare_key] | ["quoted key"] | ['quoted key']
//   - field = "value" pairs
//   - Comments and blank lines
export function parseTomlFragment(content: string): ParseResult {
  let rootKey: string | undefined;
  const fields: Record<string, string> = {};

  for (const raw of content.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;

    if (rootKey === undefined) {
      const bare = line.match(/^\[([A-Za-z0-9_\-.]+)\]$/);
      if (bare) { rootKey = bare[1]; continue; }

      const dquoted = line.match(/^\["((?:[^"\\]|\\.)*)"\]$/);
      if (dquoted) { rootKey = unescapeString(dquoted[1]!); continue; }

      const squoted = line.match(/^\['([^']*)'\]$/);
      if (squoted) { rootKey = squoted[1]; continue; }

      return { ok: false, error: `invalid table header: ${JSON.stringify(line)}` };
    }

    const kv = line.match(/^([A-Za-z0-9_]+)\s*=\s*"((?:[^"\\]|\\.)*)"$/);
    if (!kv) return { ok: false, error: `unexpected line: ${JSON.stringify(line)}` };
    fields[kv[1]!] = unescapeString(kv[2]!);
  }

  if (rootKey === undefined) return { ok: false, error: 'no table header found' };
  return { ok: true, data: { rootKey, fields } };
}
