"""Read-only bounded Git, UTF-8 and textual DM include inspection (stdlib only)."""
from __future__ import annotations
import argparse
import collections
import json
import pathlib
import re
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]

def git(*args: str, optional: bool = False) -> str:
    result = subprocess.run(["git", "-C", str(ROOT), *args], capture_output=True, encoding="utf-8", errors="replace", timeout=30)
    if result.returncode and not optional:
        raise ValueError(result.stderr.strip())
    return result.stdout.rstrip("\r\n")

def scoped(value: str) -> pathlib.Path:
    target = (ROOT / value).resolve(strict=True)
    if not target.is_relative_to(ROOT) or ".git" in (p.lower() for p in target.relative_to(ROOT).parts):
        raise ValueError("Path escapes repository code scope")
    return target

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    status = sub.add_parser("status")
    status.add_argument("--limit", type=int, default=20)
    includes = sub.add_parser("includes")
    includes.add_argument("--path", default="tgstation.dme")
    includes.add_argument("--depth", type=int, choices=range(1, 5), default=1)
    includes.add_argument("--limit", type=int, default=60)
    read = sub.add_parser("read")
    read.add_argument("--path", required=True)
    read.add_argument("--start", type=int, default=1)
    read.add_argument("--count", type=int, default=80)
    args = parser.parse_args()
    if hasattr(args, "limit") and not 1 <= args.limit <= 500:
        parser.error("--limit must be 1..500")
    if args.command == "status":
        entries, records = [], iter(git("status", "--porcelain=v1", "-z").split("\0"))
        for record in records:
            if not record:
                continue
            entries.append({"status": record[:2], "path": record[3:]})
            if "R" in record[:2] or "C" in record[:2]:
                entries[-1]["from"] = next(records, "")
        upstream = git("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}", optional=True)
        output = {"root": str(ROOT), "branch": git("branch", "--show-current"), "head": git("rev-parse", "HEAD"),
                  "upstream": upstream or None, "divergence": git("rev-list", "--left-right", "--count", "HEAD...@{upstream}", optional=True) if upstream else None,
                  "mergeHead": git("rev-parse", "-q", "--verify", "MERGE_HEAD", optional=True) or None,
                  "statusCount": len(entries), "counts": dict(collections.Counter(item["status"] for item in entries)), "sample": entries[:args.limit]}
        print(json.dumps(output, ensure_ascii=False, indent=2))
    elif args.command == "read":
        if args.start < 1 or not 1 <= args.count <= 300:
            parser.error("--start >= 1; --count must be 1..300")
        lines = scoped(args.path).read_text(encoding="utf-8-sig", errors="strict").splitlines()
        for index in range(args.start - 1, min(len(lines), args.start - 1 + args.count)):
            print(f"{index+1}: {lines[index]}")
    else:
        results, visited = [], set()
        def visit(source: pathlib.Path, depth: int) -> None:
            if source in visited or len(results) >= args.limit:
                return
            visited.add(source)
            for number, line in enumerate(source.read_text(encoding="utf-8-sig", errors="replace").splitlines(), 1):
                match = re.match(r'\s*#include\s+"([^"]+)"', line)
                if not match:
                    continue
                target = (source.parent / match[1].replace("\\", "/")).resolve()
                inside = target.is_relative_to(ROOT)
                exists = inside and target.is_file()
                results.append({"source": source.relative_to(ROOT).as_posix(), "line": number, "include": match[1],
                                "target": target.relative_to(ROOT).as_posix() if inside else "outside checkout", "exists": exists})
                if depth > 1 and exists and target.suffix.lower() in (".dm", ".dme"):
                    visit(target, depth-1)
                if len(results) >= args.limit:
                    break
        visit(scoped(args.path), args.depth)
        print(json.dumps({"kind": "textual includes; conditional preprocessing not evaluated", "entries": results,
                          "limitReached": len(results) >= args.limit}, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        raise SystemExit(str(error)) from error
