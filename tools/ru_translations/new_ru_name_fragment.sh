#!/usr/bin/env bash
# Writes a ru_names TOML stub under translation_data/ru_names/<stem>.toml.
# Usage: [-o outfile] [-g gender] [phrase ...]   OR phrase on stdin if not a TTY.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="${ROOT}/modular_bandastation/translations/code/translation_data/ru_names"
CASE_KEYS=(nominative genitive dative accusative instrumental prepositional)

normalize() {
  local t
  t=$(printf '%s' "$1" | tr -s '[:space:]' ' ')
  t="${t#"${t%%[![:space:]]*}"}"
  printf '%s' "${t%"${t##*[![:space:]]}"}"
}

phrase_to_stem() {
  local s="${1// /_}"
  s="${s//\\/}"
  s="${s////_}"
  [[ -n "$s" ]] && s=$(printf '%s' "$s" | LC_ALL=C sed 's/[[:cntrl:]<>:"|?*]/_/g; s/[. ]*$//')
  printf '%s' "${s:-_}"
}

toml_double_quoted_string() {
  local s="${1//\\/\\\\}"
  printf '"%s"' "${s//\"/\\\"}"
}

table_header_line() {
  if [[ "$1" =~ ^[A-Za-z0-9_-]+$ ]]; then
    printf '[%s]' "$1"
  else
    printf '[%s]' "$(toml_double_quoted_string "$1")"
  fi
}

OUTPUT=""
GENDER="plural"
while [[ $# -gt 0 ]]; do
  case $1 in
    -o)
      [[ -n "${2:-}" ]] || { echo "$0: -o requires an argument" >&2; exit 1; }
      OUTPUT=$2; shift 2
      ;;
    -g)
      [[ -n "${2:-}" ]] || { echo "$0: -g requires an argument" >&2; exit 1; }
      GENDER=$2; shift 2
      ;;
    -h | --help)
      echo "usage: $0 [-o outfile] [-g gender] [phrase ...]" >&2
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -eq 0 ]] && ! [[ -t 0 ]]; then
  phrase=$(cat)
else
  phrase=$(IFS=' '; printf '%s' "$*")
fi

phrase=$(normalize "$phrase")
phrase=$(LC_ALL=C printf '%s' "$phrase" | tr -d '\000-\037\177')
if [[ -z "$phrase" ]]; then
  echo "$0: empty phrase — select text in the editor or pass a phrase" >&2
  exit 1
fi

GENDER=$(printf '%s' "$GENDER" | tr '[:upper:]' '[:lower:]')
val=$(toml_double_quoted_string "$phrase")
g=$(toml_double_quoted_string "$GENDER")

body=$(table_header_line "$phrase")$'\n'
for fk in "${CASE_KEYS[@]}"; do
  body+="${fk} = ${val}"$'\n'
done
body+="gender = ${g}"$'\n'

if [[ -n "$OUTPUT" ]]; then
  out_path=$OUTPUT
  case "$out_path" in
    /* | [A-Za-z]:*) ;;
    *) out_path="${PWD}/${out_path}" ;;
  esac
else
  mkdir -p "$OUT_DIR"
  out_path="${OUT_DIR}/$(phrase_to_stem "$phrase").toml"
fi

mkdir -p "$(dirname -- "$out_path")"
printf '%s\n' "$body" >"$out_path"

if [[ -t 2 ]]; then
  printf '\n \033[1;32mok\033[0m \033[1mru_names\033[0m — фрагмент записан:\n   \033[36m%s\033[0m\n' "$out_path" >&2
else
  printf '\n [ru_names] fragment saved:\n   %s\n' "$out_path" >&2
fi
printf '%s\n' "$out_path"
