/**
 * Validates TOML files under translation_data/ru_names
 *
 * Rules:
 *   - Valid TOML syntax
 *   - Exactly one root table per file, key must be non empty
 *   - "nominative" field present and non empty
 *   - Other case fields must not be empty if present
 *   - "gender" field must be one of the known values if present
 *   - No unknown fields (catches typos like "nominatve")
 *   - No duplicate keys across files
 */

import { existsSync, readFileSync, statSync } from 'node:fs';
import { relative } from 'node:path';
import {
  DEFAULT_FRAGMENTS_DIR,
  discoverFragments,
  parseTomlFragment,
  resolveCliPath,
} from './lib/ru_names';

const CASE_FIELDS = [
  'nominative',
  'genitive',
  'dative',
  'accusative',
  'instrumental',
  'prepositional',
] as const;

const OPTIONAL_CASE_FIELDS = CASE_FIELDS.slice(1);
const VALID_GENDER_VALUES = new Set(['male', 'female', 'neuter', 'plural']);
const ALL_KNOWN_FIELDS = new Set<string>([...CASE_FIELDS, 'gender']);
const ALLOWED_FIELDS_MSG = [...ALL_KNOWN_FIELDS].sort().join(', ');

interface FragmentResult {
  relativePath: string;
  englishKey: string | null;
  errors: string[];
}

function validateFragment(
  fragmentPath: string,
  fragmentsRoot: string,
): FragmentResult {
  const relativePath = relative(fragmentsRoot, fragmentPath)
    .split(/[/\\]/)
    .join('/');
  const parsed = parseTomlFragment(readFileSync(fragmentPath, 'utf-8'));

  if (!parsed.ok) {
    return {
      relativePath,
      englishKey: null,
      errors: [`parse error: ${parsed.error}`],
    };
  }

  const { rootKey: englishKey, fields } = parsed.data;
  const errors: string[] = [];

  if (!englishKey.trim()) {
    errors.push('empty root key');
    return { relativePath, englishKey, errors };
  }

  if (Object.keys(fields).length === 0) {
    errors.push('empty document - expected exactly one root table with fields');
    return { relativePath, englishKey, errors };
  }

  for (const key of Object.keys(fields)) {
    if (!ALL_KNOWN_FIELDS.has(key)) {
      errors.push(`unknown field "${key}"`);
    }
  }

  const nominative = fields['nominative'];
  if (!nominative?.trim()) {
    errors.push(
      nominative === undefined
        ? 'missing required field "nominative"'
        : 'field "nominative" must not be empty',
    );
  }

  for (const field of OPTIONAL_CASE_FIELDS) {
    if (fields[field]?.trim() === '') {
      errors.push(`field "${field}" must not be empty`);
    }
  }

  const gender = fields['gender'];
  if (gender !== undefined && !VALID_GENDER_VALUES.has(gender)) {
    errors.push(
      `invalid gender "${gender}" - allowed: ${[...VALID_GENDER_VALUES].join(', ')}`,
    );
  }

  return { relativePath, englishKey, errors };
}

function parseArgs(argv: string[]): { fragmentsDir: string } {
  let rawFragmentsDir: string | undefined;

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i]!;
    if (arg === '--fragments-dir') {
      if (!argv[i + 1]) {
        console.error(`Error: Missing value for ${arg}`);
        process.exit(2);
      }
      rawFragmentsDir = argv[++i];
    } else {
      console.error(`Error: Unknown argument: ${arg}`);
      process.exit(2);
    }
  }

  return {
    fragmentsDir: resolveCliPath(rawFragmentsDir, DEFAULT_FRAGMENTS_DIR),
  };
}

function main(): number {
  const { fragmentsDir } = parseArgs(process.argv.slice(2));

  if (!existsSync(fragmentsDir) || !statSync(fragmentsDir).isDirectory()) {
    console.error(`Error: Fragments directory not found: ${fragmentsDir}`);
    return 1;
  }

  const discovered = discoverFragments(fragmentsDir);
  if (discovered.length === 0) {
    console.error(`Error: No *.toml fragments found under ${fragmentsDir}`);
    return 1;
  }

  const results = discovered.map((fragmentPath) =>
    validateFragment(fragmentPath, fragmentsDir),
  );

  const seenKeys = new Map<string, string>();
  for (const result of results) {
    if (result.englishKey === null) continue;
    const firstPath = seenKeys.get(result.englishKey);
    if (firstPath !== undefined) {
      result.errors.push(
        `duplicate key "${result.englishKey}" - first defined in ${firstPath}`,
      );
      continue;
    }
    seenKeys.set(result.englishKey, result.relativePath);
  }

  const filesWithErrors = results.filter((result) => result.errors.length > 0);
  if (filesWithErrors.length === 0) {
    console.log(`Success: All ${discovered.length} fragments are valid.`);
    return 0;
  }

  const totalErrors = filesWithErrors.reduce(
    (sum, result) => sum + result.errors.length,
    0,
  );
  console.error(
    `Validation failed: ${totalErrors} error(s) in ${filesWithErrors.length} of ${discovered.length} file(s)\n`,
  );
  for (const { relativePath, errors } of filesWithErrors) {
    console.error(`${relativePath}:`);
    for (const error of errors) {
      console.error(`  Error: ${error}`);
    }
  }

  return 1;
}

process.exit(main());
