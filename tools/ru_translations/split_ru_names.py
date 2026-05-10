#!/usr/bin/env python3
# ru_names.toml splitter
"""
Split ru_names.toml into one TOML file per translated key.

Output layout:
  translation_data/ru_names/<stem>.toml  (single flat folder, no gender subdirectories)

<stem> is words from the English key joined with underscores (casing preserved
per token, e.g. "holographic ID sticker" -> holographic_ID_sticker).
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterator

from ru_names_common import build_fragment_body, parse_toml_basic_string_rhs

TABLE_HEADER_PATTERN = re.compile(r"^[ \t]*\[([^\]]+)\]\s*(?:#.*)?\s*$")

@dataclass
class ParsedTable:
    """One TOML table (one English name entry) parsed from ru_names.toml."""

    table_inner: str
    assignments: dict[str, str] = field(default_factory=dict)


def normalize_table_inner(inner: str) -> str:
    """Return the logical English key inside [...] brackets (TOML bare or quoted)."""
    inner = inner.strip()
    if len(inner) >= 2 and inner[0] == '"' and inner[-1] == '"':
        body = inner[1:-1]
        return (
            body.replace("\\\\", "\x00")
            .replace('\\"', '"')
            .replace("\x00", "\\")
        )
    return inner


def assignment_line_split(line: str) -> tuple[str, str] | None:
    """
    Split 'key = "value"' (with optional whitespace). Values must use TOML double-quoted literals.
    """
    stripped = line.strip()
    if stripped.startswith("#") or "=" not in stripped:
        return None
    front, sep, tail = stripped.partition("=")
    if not sep:
        return None
    key_name = front.strip()
    val = tail.strip()
    decoded = parse_toml_basic_string_rhs(val)
    if decoded is None:
        return None
    return key_name, decoded


def parse_ru_tables(path: Path) -> Iterator[ParsedTable]:
    """
    Streaming parse: each [...] header opens a table.
    """
    current: ParsedTable | None = None
    encoding = "utf-8"

    with path.open(encoding=encoding, newline="") as handle:
        for raw_line in handle:
            line = raw_line.rstrip("\n\r")

            table_match = TABLE_HEADER_PATTERN.match(raw_line)
            if table_match:
                if current:
                    yield current
                inner = normalize_table_inner(table_match.group(1))
                current = ParsedTable(table_inner=inner, assignments={})
                continue

            if current:
                parsed = assignment_line_split(line)
                if parsed:
                    k, v = parsed
                    current.assignments[k] = v

        if current:
            yield current


# Output naming

WINDOWS_RESERVED = frozenset(
    {"CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5",
     "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4",
     "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"}
)


def sanitize_filename_piece(name: str) -> str:
    """Remove characters illegal on Windows filenames; normalize path separators."""
    name = name.replace("\\", "_").replace("/", "_")
    name = re.sub(r'[<>:"|?*\x00-\x1f]', "_", name)
    name = name.rstrip(". ")
    return name or "_"


def key_to_filename_stem(english_key: str) -> str:
    """'holographic ID sticker' -> 'holographic_ID_sticker' (token casing preserved)."""
    parts = english_key.split()
    stem = "_".join(parts) if parts else english_key
    stem = sanitize_filename_piece(stem)
    if stem.upper() in WINDOWS_RESERVED:
        stem = stem + "_entry"
    return stem


@dataclass
class PlannedFile:
    rel_path: Path
    body: str
    english_key: str


def plan_outputs(tables: list[ParsedTable]) -> tuple[list[PlannedFile], dict[str, int]]:
    stem_counts: dict[str, int] = defaultdict(int)
    english_keys_seen: set[str] = set()
    key_dup = 0
    stem_extra = 0
    planned: list[PlannedFile] = []
    skipped = 0

    for tbl in tables:
        key = tbl.table_inner.strip()
        if not key:
            skipped += 1
            continue

        stem_base = key_to_filename_stem(key)
        stem_counts[stem_base] += 1
        occurrence = stem_counts[stem_base]
        stem_final = stem_base
        if occurrence > 1:
            stem_final = f"{stem_base}_{occurrence}"
            stem_extra += 1

        filename = stem_final + ".toml"
        rel = Path(filename)
        if key in english_keys_seen:
            key_dup += 1
            rel = Path(f"{stem_final}_keydup{key_dup}.toml")

        body = build_fragment_body(key, tbl.assignments)
        planned.append(PlannedFile(rel_path=rel, body=body, english_key=key))
        english_keys_seen.add(key)

    counts = {
        "written": len(planned),
        "skipped_empty": skipped,
        "duplicate_english_keys": key_dup,
        "stem_disambiguations": stem_extra,
    }
    return planned, counts


def write_files(output_root: Path, planned: list[PlannedFile], *, clean: bool) -> None:
    if clean and output_root.exists():
        for child in output_root.iterdir():
            if child.is_dir():
                shutil.rmtree(child)
            else:
                child.unlink()

    output_root.mkdir(parents=True, exist_ok=True)

    for item in planned:
        out_file = output_root / item.rel_path
        out_file.write_text(item.body, encoding="utf-8", newline="\n")


def repo_root_from_script(script: Path) -> Path:
    return script.resolve().parent.parent.parent


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        type=Path,
        help="Path to ru_names.toml (default: modular_bandastation/.../ru_names.toml under repo)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Output directory root (default: .../translation_data/ru_names next to source file)",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Delete existing contents under --output before writing (destructive).",
    )
    parser.add_argument("--dry-run", action="store_true", help="Parse and report counts only.")
    ns = parser.parse_args(argv)

    root = repo_root_from_script(Path(__file__))
    default_input = root / Path(
            "modular_bandastation/translations/code/translation_data/ru_names.toml"
        )
    in_path = ns.input.expanduser().resolve() if ns.input else default_input
    out_path = (
        ns.output.expanduser().resolve()
        if ns.output
        else in_path.parent / "ru_names"
    )

    if not in_path.is_file():
        print(f"Input not found: {in_path}", file=sys.stderr)
        return 2

    tables = list(parse_ru_tables(in_path))
    planned, stats = plan_outputs(tables)

    print(f"Parsed {len(tables)} tables from {in_path}")
    print(
        f"Planned files: {stats['written']}, skipped_empty: {stats['skipped_empty']}, "
        f"stem_disambiguations: {stats['stem_disambiguations']}, duplicate_keys: {stats['duplicate_english_keys']}"
    )
    print(f"Output root: {out_path}")

    if ns.dry_run:
        return 0

    write_files(out_path, planned, clean=ns.clean)
    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
