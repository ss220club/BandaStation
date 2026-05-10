#!/usr/bin/env bash
# Writes a ru_names TOML stub under translation_data/ru_names/<stem>.toml.
# Usage: [-o outfile] [-g gender] [phrase ...]   OR phrase on stdin if not a TTY.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="${ROOT}/modular_bandastation/translations/code/translation_data/ru_names"

normalize() {
  local t=$1
  if [[ -z "$t" ]]; then
    printf ''
    return
  fi
  t=$(printf '%s' "$t" | tr -s '[:space:]' ' ')
  t="${t#"${t%%[![:space:]]*}"}"
  t="${t%"${t##*[![:space:]]}"}"
  printf '%s' "$t"
}

phrase_to_stem() {
  local p="$1" s
  s=${p// /_}
  s=${s//\\/}
  s=${s////_}
  if [[ -n "${s}" ]]; then
    s=$(printf '%s' "$s" | LC_ALL=C sed 's/[[:cntrl:]<>:"|?*]/_/g')
    s=$(printf '%s' "$s" | sed 's/[. ]*$//')
  fi
  [[ -z "${s}" ]] && s="_"
  printf '%s' "$s"
}

toml_double_quote() {
  local s="$1" out='"'
  local c i len o
  len=${#s}
  for ((i = 0; i < len; i++)); do
    c=${s:i:1}
    case "$c" in
      \\) out+='\\' ;;
      \") out+='\"' ;;
      $'\n') out+='\n' ;;
      $'\r') out+='\r' ;;
      $'\t') out+='\t' ;;
      *)
        if [[ ${#c} -eq 1 ]]; then
          printf -v o %d "'$c"
          if ((o < 32)); then
            out+=$(printf '\\u%04x' "$o")
          else
            out+="$c"
          fi
        else
          out+="$c"
        fi
        ;;
    esac
  done
  out+='"'
  printf '%s' "$out"
}

table_header_line() {
  local k="$1"
  if [[ -z "$k" ]] || [[ ! "$k" =~ ^[A-Za-z0-9_-]+$ ]]; then
    local e="${k//\\/\\\\}"
    e="${e//\"/\\\"}"
    printf '[\"%s\"]' "$e"
  else
    printf '[%s]' "$k"
  fi
}

OUTPUT=""
GENDER="plural"
while [[ $# -gt 0 ]]; do
  case $1 in
    -o)
      OUTPUT=${2:-}
      shift 2
      ;;
    -g)
      GENDER=${2:-plural}
      shift 2
      ;;
    -h | --help)
      echo "usage: $0 [-o outfile] [-g gender] [phrase ...]" >&2
      exit 1
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
if [[ -z "$phrase" ]]; then
  echo "$0: empty phrase — select text in the editor or pass a phrase" >&2
  exit 1
fi

GENDER=$(printf '%s' "$GENDER" | tr '[:upper:]' '[:lower:]')
key=$phrase
val=$(toml_double_quote "$key")
g=$(toml_double_quote "$GENDER")

body=$(table_header_line "$key")
body+=$'\n'
body+=$'nominative = '"$val"$'\n'
body+=$'genitive = '"$val"$'\n'
body+=$'dative = '"$val"$'\n'
body+=$'accusative = '"$val"$'\n'
body+=$'instrumental = '"$val"$'\n'
body+=$'prepositional = '"$val"$'\n'
body+=$'gender = '"$g"$'\n'
body+=$'\n'

if [[ -n "$OUTPUT" ]]; then
  out_path=$OUTPUT
  case "$out_path" in
    /* | [A-Za-z]:*) ;;
    *) out_path="${PWD}/${out_path}" ;;
  esac
else
  mkdir -p "$OUT_DIR"
  stem="$(phrase_to_stem "$phrase").toml"
  out_path="${OUT_DIR}/${stem}"
fi

parent=$(dirname -- "$out_path")
mkdir -p "$parent"
printf '%s' "$body" >"$out_path"

if [[ -t 2 ]]; then
  printf '\n \033[1;32m\033[0m \033[1mru_names\033[0m - фрагмент записан:\n   \033[36m%s\033[0m\n' "$out_path" >&2
else
  printf '\n [ru_names] fragment saved:\n   %s\n' "$out_path" >&2
fi
printf '%s\n' "$out_path"
