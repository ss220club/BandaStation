#!/usr/bin/env bash
set -eu

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <header> <fragments-dir> <output>" >&2
  exit 1
fi

HEADER=$1
FRAGMENTS=$2
OUTPUT=$3
TMP="${OUTPUT}.tmp"

mkdir -p "$(dirname "$OUTPUT")"
{
  cat "$HEADER"
  find "$FRAGMENTS" -name '*.toml' | sort | while read -r f; do
    cat "$f"
    echo
  done
} >"$TMP"
mv "$TMP" "$OUTPUT"
