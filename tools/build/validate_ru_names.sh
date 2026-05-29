#!/usr/bin/env bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/../.."
bun "$SCRIPT_DIR/validate_ru_names.ts" \
  --fragments-dir "$REPO_ROOT/modular_bandastation/translations/code/translation_data/ru_names"
