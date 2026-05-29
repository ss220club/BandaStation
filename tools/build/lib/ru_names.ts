import { readdirSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, isAbsolute, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = join(__dirname, '../../..');

/**
 * Recursively discovers all `.toml` files under `root`, sorted lexicographically.
 *
 * @param root - Absolute path to the directory to search.
 * @returns Sorted list of absolute paths to `.toml` files found under `root`.
 */
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

/**
 * Resolves a CLI-supplied path string to an absolute path.
 *
 * - A leading `~` is expanded to the current user's home directory.
 * - Relative paths are resolved relative to the repository root.
 *
 * @param raw - The raw path string supplied by the caller.
 * @returns An absolute path string.
 */
export function resolveCliPath(raw: string): string {
  const expanded = raw.replace(/^~(?=$|[/\\])/, homedir());
  if (isAbsolute(expanded)) return resolve(expanded);
  return resolve(REPO_ROOT, expanded);
}
