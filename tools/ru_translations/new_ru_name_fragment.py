#!/usr/bin/env python3
"""
Interactive stub writer for modular_bandastation ru_names fragments.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

from ru_names_common import build_fragment_body

_REPO_ROOT = Path(__file__).resolve().parents[2]

DEFAULT_SAVE_DIR = (
    _REPO_ROOT
    / "modular_bandastation"
    / "translations"
    / "code"
    / "translation_data"
    / "ru_names"
)


def normalize_phrase(raw: str) -> str:
    text = raw.strip().replace("\r\n", "\n").replace("\r", "\n")
    return " ".join(text.split())


def phrase_to_filename_stem(phrase: str) -> str:
    parts = phrase.split()
    stem = "_".join(parts)
    stem = stem.replace("\\", "_").replace("/", "_")
    stem = re.sub(r'[<>:"|?*\x00-\x1f]', "_", stem)
    stem = stem.rstrip(". ") or "_"
    return stem


def pick_save_path(initial_name: str) -> Path | None:
    try:
        import tkinter as tk
        from tkinter import filedialog
    except ImportError:
        print(
            "tkinter unavailable; pass --output path/to/name.toml explicitly.",
            file=sys.stderr,
        )
        return None

    root = tk.Tk()
    root.withdraw()
    root.attributes("-topmost", True)
    start_dir = DEFAULT_SAVE_DIR if DEFAULT_SAVE_DIR.is_dir() else _REPO_ROOT

    picked = filedialog.asksaveasfilename(
        parent=root,
        title="Save ru_names fragment",
        initialdir=str(start_dir),
        initialfile=initial_name,
        defaultextension=".toml",
        filetypes=(
            ("TOML fragment", "*.toml"),
            ("All files", "*.*"),
        ),
    )
    root.destroy()
    if not picked:
        return None
    return Path(picked)


def build_stub(english_key: str, gender: str) -> str:
    g = normalize_phrase(english_key)
    fields = {
        "nominative": g,
        "genitive": g,
        "dative": g,
        "accusative": g,
        "instrumental": g,
        "prepositional": g,
        "gender": gender.strip().lower(),
    }
    return build_fragment_body(english_key.strip(), fields)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "phrase",
        nargs="?",
        help="English phrase (also read from stdin if omitted and not a TTY)",
    )
    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        help="Write here instead of Save dialog.",
    )
    parser.add_argument(
        "--gender",
        default="plural",
        help='Value for gender = "…" (default: plural)',
    )
    ns = parser.parse_args(argv)

    phrase = ns.phrase
    if not phrase and not sys.stdin.isatty():
        phrase = sys.stdin.read()
    phrase = normalize_phrase(phrase or "")
    if not phrase:
        parser.error("empty phrase — select text in the editor and run the task again")

    body = build_stub(phrase, ns.gender)
    out_path = ns.output.expanduser().resolve() if ns.output else None

    if out_path is None:
        stem = phrase_to_filename_stem(phrase) + ".toml"
        picked = pick_save_path(stem)
        if picked is None:
            return 1
        out_path = picked

    try:
        out_path.write_text(body, encoding="utf-8", newline="\n")
    except OSError as exc:
        print(f"cannot write {out_path}: {exc}", file=sys.stderr)
        return 2

    print(out_path.as_posix())
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
