/**
 * Assemble modular_bandastation translation_data/ru_names.toml from per-entry TOML files.
 */

import {
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import { homedir } from 'node:os';
import { dirname, isAbsolute, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse } from '@iarna/toml';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = join(__dirname, '../..');

const DEFAULT_FRAGMENTS = join(
  REPO_ROOT,
  'modular_bandastation/translations/code/translation_data/ru_names',
);
const DEFAULT_OUTPUT = join(
  REPO_ROOT,
  'modular_bandastation/translations/code/translation_data/ru_names.toml',
);

const KNOWN_GENDER_VALUES = new Set(['male', 'female', 'neuter', 'plural']);
const VALID_ASSIGNMENT_KEY = /^[A-Za-z_][A-Za-z0-9_]*$/;

interface FragmentRecord {
  relativePath: string;
  englishKey: string;
  fields: Record<string, string>;
}

function discoverFragments(root: string): string[] {
  const paths: string[] = [];
  function walk(dir: string) {
    let ents;
    try {
      ents = readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const ent of ents) {
      const p = join(dir, ent.name);
      if (ent.isDirectory()) walk(p);
      else if (ent.isFile() && ent.name.endsWith('.toml')) paths.push(p);
    }
  }
  walk(root);
  return paths.sort();
}

function loadFragmentDoc(path: string): unknown {
  const raw = readFileSync(path, 'utf-8');
  return parse(raw);
}

function englishKeyMustBeNamedTable(
  top: Record<string, unknown>,
): [string | null, string | null] {
  const keys = Object.keys(top);
  if (keys.length === 0) return [null, 'empty document'];
  if (keys.length !== 1) {
    return [
      null,
      `expected one root table, found ${keys.length} keys: ${JSON.stringify([...keys].sort())}`,
    ];
  }
  const englishKey = keys[0]!;
  if (typeof englishKey !== 'string' || !englishKey.trim()) {
    return [null, 'root table key must be non-empty string'];
  }
  const body = top[englishKey];
  if (body === null || typeof body !== 'object' || Array.isArray(body)) {
    return [null, 'root table value must be a map of key/value pairs'];
  }
  return [englishKey.trim(), null];
}

function mapFieldsStrict(
  body: Record<string, unknown>,
): [Record<string, string> | null, string | null] {
  const flat: Record<string, string> = {};
  for (const k of Object.keys(body)) {
    if (!VALID_ASSIGNMENT_KEY.test(k)) {
      return [
        null,
        `illegal assignment key \`${k}\` (must be bare TOML identifier)`,
      ];
    }
    const v = body[k];
    if (typeof v !== 'string') {
      return [null, `\`${k}\` must be double-quoted string, got ${typeof v}`];
    }
    flat[k] = v;
  }
  return [flat, null];
}

function validateSemantics(fields: Record<string, string>): [boolean, string] {
  const nominative = (fields.nominative ?? '').trim();
  if (!nominative) return [false, 'missing or empty nominative'];
  const rawGender = fields.gender;
  if (rawGender === undefined) return [true, ''];
  const gv = rawGender.trim().toLowerCase();
  if (!KNOWN_GENDER_VALUES.has(gv)) {
    return [
      false,
      `unsupported gender \`${rawGender}\` (allowed: ${[...KNOWN_GENDER_VALUES].sort().join(', ')})`,
    ];
  }
  return [true, ''];
}

function tryParseRecord(
  path: string,
  fragmentsRoot: string,
): [FragmentRecord | null, string[]] {
  let rel: string;
  try {
    rel = relative(fragmentsRoot, path);
    if (rel.startsWith('..') || rel === '') throw new Error();
  } catch {
    return [null, [`${path}: skip (not under ${fragmentsRoot})`]];
  }

  let parsed: unknown;
  try {
    parsed = loadFragmentDoc(path);
  } catch (exc) {
    return [null, [`${path}: corrupt TOML (${exc})`]];
  }

  if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) {
    return [null, [`${path}: corrupt TOML (expected table)`]];
  }

  const doc = parsed as Record<string, unknown>;
  const [keyRaw, structuralErr] = englishKeyMustBeNamedTable(doc);
  if (structuralErr || keyRaw === null) {
    return [null, [`${path}: ${structuralErr}`]];
  }

  const body = doc[keyRaw];
  const [fields, ferr] = mapFieldsStrict(body as Record<string, unknown>);
  if (ferr || !fields) return [null, [`${path}: ${ferr}`]];

  const [ok, semErr] = validateSemantics(fields);
  if (!ok) return [null, [`${path}: ${semErr}`]];

  return [
    {
      relativePath: rel.split(/[/\\]/).join('/'),
      englishKey: keyRaw,
      fields,
    },
    [],
  ];
}

function englishKeyRequiresQuotes(key: string): boolean {
  if (!key) return true;
  return !/^[A-Za-z0-9_-]+$/.test(key);
}

function formatTableHeaderLine(englishKey: string): string {
  if (englishKeyRequiresQuotes(englishKey)) {
    const escaped = englishKey.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
    return `["${escaped}"]`;
  }
  return `[${englishKey}]`;
}

function tomlDoubleQuotedString(value: string): string {
  let out = '"';
  for (const ch of value) {
    const o = ch.codePointAt(0)!;
    if (ch === '\\') out += '\\\\';
    else if (ch === '"') out += '\\"';
    else if (ch === '\n') out += '\\n';
    else if (ch === '\r') out += '\\r';
    else if (ch === '\t') out += '\\t';
    else if (o < 0x20) out += `\\u${o.toString(16).padStart(4, '0')}`;
    else out += ch;
  }
  return `${out}"`;
}

function formatAssignmentLines(assignments: Record<string, string>): string[] {
  const preferred = [
    'nominative',
    'genitive',
    'dative',
    'accusative',
    'instrumental',
    'prepositional',
    'gender',
  ];
  const lines: string[] = [];
  const seen = new Set<string>();
  for (const name of preferred) {
    if (Object.hasOwn(assignments, name)) {
      lines.push(`${name} = ${tomlDoubleQuotedString(assignments[name]!)}`);
      seen.add(name);
    }
  }
  for (const name of Object.keys(assignments).sort()) {
    if (!seen.has(name)) {
      lines.push(`${name} = ${tomlDoubleQuotedString(assignments[name]!)}`);
    }
  }
  return lines;
}

function buildFragmentBody(
  englishKey: string,
  assignments: Record<string, string>,
): string {
  return [
    formatTableHeaderLine(englishKey),
    ...formatAssignmentLines(assignments),
    '',
  ].join('\n');
}

function sortRecords(records: FragmentRecord[]): FragmentRecord[] {
  return [...records].sort((a, b) => {
    const k1 = a.englishKey.toLowerCase();
    const k2 = b.englishKey.toLowerCase();
    if (k1 !== k2) return k1 < k2 ? -1 : 1;
    const p1 = a.relativePath.toLowerCase();
    const p2 = b.relativePath.toLowerCase();
    if (p1 < p2) return -1;
    if (p1 > p2) return 1;
    return 0;
  });
}

function composeMergedToml(records: FragmentRecord[]): string {
  const lines: string[] = [
    '# ru_names.toml generated by tools/build/merge_ru_names.ts',
    '# Edit fragments under translation_data/ru_names/, then rebuild the game.',
    '',
  ];
  for (const rec of sortRecords(records)) {
    const body = buildFragmentBody(rec.englishKey, rec.fields);
    lines.push(body.replace(/\n+$/, ''));
    lines.push('');
  }
  return `${lines.join('\n').trimEnd()}\n`;
}

function runMerge(
  fragmentsRoot: string,
  outputPath: string,
  strict: boolean,
): number {
  if (!existsSync(fragmentsRoot) || !statSync(fragmentsRoot).isDirectory()) {
    console.log(
      `No fragments directory at ${fragmentsRoot}; skipping merge (existing ${outputPath} unchanged).`,
    );
    return 0;
  }

  const discovered = discoverFragments(fragmentsRoot);
  if (discovered.length === 0) {
    console.log(
      `No *.toml under ${fragmentsRoot}; skipping merge (existing ${outputPath} unchanged).`,
    );
    return 0;
  }

  const good: FragmentRecord[] = [];
  const warns: string[] = [];

  for (const p of discovered) {
    const [rec, errs] = tryParseRecord(p, fragmentsRoot);
    if (rec) good.push(rec);
    else warns.push(...errs);
  }

  let duplicates = 0;
  const seenKeys = new Set<string>();
  const unique: FragmentRecord[] = [];
  for (const entry of sortRecords(good)) {
    if (seenKeys.has(entry.englishKey)) {
      warns.push(
        `${join(fragmentsRoot, ...entry.relativePath.split(/[/\\]/))}: duplicate  english key \`${entry.englishKey}\` (skipped)`,
      );
      duplicates++;
      continue;
    }
    seenKeys.add(entry.englishKey);
    unique.push(entry);
  }

  for (const w of warns) console.error(w);

  if (unique.length === 0) {
    console.error(
      'ERROR: zero valid entries after validation; not writing output.',
    );
    if (strict && warns.length > 0) return 1;
    return 2;
  }

  const mergedText = composeMergedToml(unique);

  mkdirSync(dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, mergedText, { encoding: 'utf-8' });

  console.log(
    `Wrote ${outputPath} with ${unique.length} entries (${discovered.length} files scanned; ${warns.length} issues reported; ${duplicates} duplicates skipped).`,
  );

  if (strict && warns.length > 0) return 1;
  return 0;
}

function resolveCliPath(raw: string | undefined, fallback: string): string {
  if (!raw) return fallback;
  const expanded = raw.replace(/^~(?=$|[/\\])/, homedir());
  if (isAbsolute(expanded)) return resolve(expanded);
  return resolve(REPO_ROOT, expanded);
}

function parseArgs(argv: string[]): {
  fragments: string;
  output: string;
  strict: boolean;
} {
  let fragmentsDir: string | undefined;
  let output: string | undefined;
  let strict = false;
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i]!;
    if (a === '--strict') {
      strict = true;
    } else if (a === '--fragments-dir' && argv[i + 1]) {
      fragmentsDir = argv[++i]!;
    } else if (a === '--output' && argv[i + 1]) {
      output = argv[++i]!;
    } else {
      console.error(`Unknown argument: ${a}`);
      process.exit(2);
    }
  }
  return {
    fragments: resolveCliPath(fragmentsDir, DEFAULT_FRAGMENTS),
    output: resolveCliPath(output, DEFAULT_OUTPUT),
    strict,
  };
}

function main(): number {
  const { fragments, output, strict } = parseArgs(process.argv.slice(2));
  return runMerge(fragments, output, strict);
}

process.exit(main());
