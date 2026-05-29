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
import * as TOML from 'toml';
import { z } from 'zod';
import { discoverFragments, resolveCliPath } from './lib/ru_names';

const VALID_GENDER_VALUES = ['male', 'female', 'neuter', 'plural'] as const;

const FieldsSchema = z
  .object({
    nominative: z.string().min(1),
    genitive: z.string().min(1).optional(),
    dative: z.string().min(1).optional(),
    accusative: z.string().min(1).optional(),
    instrumental: z.string().min(1).optional(),
    prepositional: z.string().min(1).optional(),
    gender: z.enum(VALID_GENDER_VALUES).optional(),
  })
  .strict();

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

  let parsed: Record<string, unknown>;
  try {
    parsed = TOML.parse(readFileSync(fragmentPath, 'utf-8')) as Record<
      string,
      unknown
    >;
  } catch (err) {
    return {
      relativePath,
      englishKey: null,
      errors: [`parse error: ${err}`],
    };
  }

  const keys = Object.keys(parsed);
  if (keys.length !== 1) {
    return {
      relativePath,
      englishKey: keys[0] ?? null,
      errors: [`expected exactly one root table, got ${keys.length}`],
    };
  }

  const englishKey = keys[0]!;
  if (!englishKey.trim()) {
    return { relativePath, englishKey, errors: ['empty root key'] };
  }

  const errors: string[] = [];
  const result = FieldsSchema.safeParse(parsed[englishKey]);
  if (!result.success) {
    for (const issue of result.error.issues) {
      const field =
        issue.path.length > 0 ? `field "${issue.path.join('.')}"` : 'root';
      errors.push(`${field}: ${issue.message}`);
    }
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

  if (!rawFragmentsDir) {
    console.error('Error: --fragments-dir is required');
    process.exit(2);
  }

  return { fragmentsDir: resolveCliPath(rawFragmentsDir) };
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

  const results = discovered.map((p) => validateFragment(p, fragmentsDir));

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

  const filesWithErrors = results.filter((r) => r.errors.length > 0);
  if (filesWithErrors.length === 0) {
    console.log(`Success: All ${discovered.length} fragments are valid.`);
    return 0;
  }

  const totalErrors = filesWithErrors.reduce(
    (sum, r) => sum + r.errors.length,
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
