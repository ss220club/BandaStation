"""Shared helpers for split/merge ru_names fragment TOML files."""

from __future__ import annotations

import re


def english_key_requires_quotes(key: str) -> bool:
    if not key:
        return True
    if re.fullmatch(r"[A-Za-z0-9_-]+", key):
        return False
    return True


def format_table_header_line(english_key: str) -> str:
    """Emit TOML table header (bare key vs double-quoted)."""
    if english_key_requires_quotes(english_key):
        escaped = english_key.replace("\\", "\\\\").replace('"', '\\"')
        return f'["{escaped}"]'
    return f"[{english_key}]"


def parse_toml_basic_string_rhs(token: str) -> str | None:
    """
    Parse a TOML double-quoted string literal (RHS of key = "..."),
    excluding multiline triple strings.
    """
    token = token.strip()
    if len(token) < 2 or not (token.startswith('"') and token.endswith('"')):
        return None
    body = token[1:-1]
    return (
        body.replace("\\\\", "\x00")
        .replace('\\"', '"')
        .replace("\x00", "\\")
    )


def toml_double_quoted_string(value: str) -> str:
    """Serialize a Python string as a TOML double-quoted literal (one line)."""
    parts: list[str] = ['"']
    for ch in value:
        if ch == "\\":
            parts.append("\\\\")
        elif ch == '"':
            parts.append('\\"')
        elif ch == "\n":
            parts.append("\\n")
        elif ch == "\r":
            parts.append("\\r")
        elif ch == "\t":
            parts.append("\\t")
        else:
            o = ord(ch)
            if o < 0x20:
                parts.append(f"\\u{o:04x}")
            else:
                parts.append(ch)
    parts.append('"')
    return "".join(parts)


def format_assignment_lines_python(assignments: dict[str, str]) -> list[str]:
    """
    Stable key order: conventional declension fields, then remaining keys sorted.
    Values are Python strings (escaped for TOML).
    """
    preferred = (
        "nominative",
        "genitive",
        "dative",
        "accusative",
        "instrumental",
        "prepositional",
        "gender",
    )
    lines: list[str] = []
    seen: set[str] = set()
    for name in preferred:
        if name in assignments:
            lines.append(f"{name} = {toml_double_quoted_string(assignments[name])}")
            seen.add(name)
    for name in sorted(assignments.keys()):
        if name not in seen:
            lines.append(f"{name} = {toml_double_quoted_string(assignments[name])}")
    return lines


def build_fragment_body(english_key: str, assignments: dict[str, str]) -> str:
    """Full text of a one-table ru_names fragment file."""
    parts = [
        format_table_header_line(english_key),
        *format_assignment_lines_python(assignments),
        "",
    ]
    return "\n".join(parts)
