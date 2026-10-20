"""Offline conversion of player preference job assignments. No DM/runtime imports."""

from __future__ import annotations

import argparse
from copy import deepcopy
import json
import math
import os
from pathlib import Path
import re
import stat
import tempfile
from typing import Any


SAVEFILE_VERSION_MIN = 32
SAVEFILE_VERSION_MAX = 53


def migrate_job_slots(document: dict[str, Any]) -> dict[str, Any]:
    """Merge root assignment maps, preserving explicit current/random selections."""

    def read_map(value: Any, *, minimum: int) -> dict[str, int]:
        # An empty DM list can be written as [] or null.
        if value is None or value == []:
            return {}
        if not isinstance(value, dict):
            raise ValueError("Assignments must be a map")
        result: dict[str, int] = {}
        for job, slot in value.items():
            if not isinstance(job, str) or not job:
                raise ValueError("Invalid assignment job key")
            if isinstance(slot, bool) or not isinstance(slot, (int, float)):
                raise ValueError("Invalid assignment slot")
            if slot < minimum or (
                isinstance(slot, float)
                and (not math.isfinite(slot) or not slot.is_integer())
            ):
                raise ValueError("Invalid assignment slot")
            result[job] = int(slot)
        return result

    if not isinstance(document, dict):
        raise ValueError("Preferences root must be an object")
    result = deepcopy(document)
    previous = read_map(result.get("job_assigned_profiles"), minimum=1)
    current = read_map(result.get("pref_job_slots"), minimum=-1)
    previous.update(current)
    result["pref_job_slots"] = previous
    result.pop("job_assigned_profiles", None)
    return result


def validate_player_preferences(document: Any) -> None:
    """Check the root layout used by preferences_savefile.dm, without editing slots."""
    if not isinstance(document, dict):
        raise ValueError("Preferences root must be an object")
    version = document.get("version")
    if (
        isinstance(version, bool)
        or not isinstance(version, (int, float))
        or not SAVEFILE_VERSION_MIN <= version <= SAVEFILE_VERSION_MAX
        or int(version) != version
    ):
        raise ValueError("Unsupported or missing player preferences version")
    default_slot = document.get("default_slot")
    if (
        isinstance(default_slot, bool)
        or not isinstance(default_slot, (int, float))
        or not math.isfinite(default_slot)
        or default_slot < 1
        or int(default_slot) != default_slot
    ):
        raise ValueError("Invalid or missing player default_slot")
    for key, value in document.items():
        if key.startswith("character"):
            if not re.fullmatch(r"character[1-9][0-9]*", key):
                raise ValueError("Unexpected character section key")
            if value is not None and value != [] and not isinstance(value, dict):
                raise ValueError("Unexpected character section format")


def _unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("Duplicate JSON object key")
        result[key] = value
    return result


def _reject_constant(_value: str) -> None:
    raise ValueError("Non-finite JSON number")


def _relative_player_path(source: Path, root: Path) -> Path:
    relative = source.relative_to(root)
    if (
        len(relative.parts) != 3
        or relative.name != "preferences.json"
        or len(relative.parts[0]) != 1
        or not re.fullmatch(r"[a-z0-9]+", relative.parts[1])
        or relative.parts[1][0] != relative.parts[0]
    ):
        raise ValueError("Not a player_saves/<initial>/<ckey>/preferences.json path")
    if source.is_symlink() or source.parent.is_symlink() or source.parent.parent.is_symlink():
        raise ValueError("Symlinked player save paths are not supported")
    if not source.resolve().is_relative_to(root):
        raise ValueError("Player save path leaves the selected root")
    return relative


def _write_backup(backup: Path, original: bytes) -> None:
    backup.parent.mkdir(parents=True, exist_ok=True)
    # An existing backup is never overwritten, even if it belongs to another run.
    with backup.open("xb") as handle:
        handle.write(original)
        handle.flush()
        os.fsync(handle.fileno())


def _atomic_write(source: Path, original: bytes, converted: bytes) -> None:
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=".preferences.json.", suffix=".tmp", dir=source.parent
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(converted)
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temporary, stat.S_IMODE(source.stat().st_mode))
        if source.read_bytes() != original:
            raise ValueError("Preferences changed during conversion; stop all writers")
        os.replace(temporary, source)
    finally:
        if temporary.exists():
            # Windows cannot unlink a temporary file carrying a read-only source mode.
            temporary.chmod(stat.S_IRUSR | stat.S_IWUSR)
            temporary.unlink()


def migrate_file(source: Path, root: Path, backup_root: Path | None = None) -> bool:
    """Return whether conversion is needed; writing always requires a backup root."""
    relative = _relative_player_path(source, root)
    original = source.read_bytes()
    try:
        document = json.loads(
            original.decode("utf-8-sig"),
            object_pairs_hook=_unique_object,
            parse_constant=_reject_constant,
        )
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ValueError("Invalid UTF-8 JSON preferences") from error
    validate_player_preferences(document)
    result = migrate_job_slots(document)
    if result == document:
        return False
    if backup_root is not None:
        converted = (json.dumps(result, ensure_ascii=False, indent=2, allow_nan=False) + "\n").encode("utf-8")
        if source.read_bytes() != original:
            raise ValueError("Preferences changed during conversion; stop all writers")
        _write_backup(backup_root / relative, original)
        _atomic_write(source, original, converted)
    return True


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("player_saves", type=Path, help="Root containing <initial>/<ckey>/preferences.json")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--apply", action="store_true", help="Write converted preferences (default: dry-run)")
    mode.add_argument("--check-ready", action="store_true", help="Read-only gate: fail if any file still needs conversion")
    parser.add_argument("--backup-dir", type=Path, help="Separate directory for immutable original files")
    parser.add_argument("--server-stopped", action="store_true", help="Confirm the server and other save writers are stopped")
    args = parser.parse_args(argv)
    root = args.player_saves.resolve()
    if not root.is_dir():
        parser.error("player_saves must be an existing directory")
    if args.apply and (not args.backup_dir or not args.server_stopped):
        parser.error("--apply requires --backup-dir and --server-stopped")
    backup_root = args.backup_dir.resolve() if args.apply else None
    if backup_root is not None and backup_root.is_relative_to(root):
        parser.error("The backup directory must be outside player_saves")

    files = sorted(root.glob("*/*/preferences.json"))
    if not files:
        print("ERROR: no player preference files found in the selected root")
        return 2
    changed = unchanged = errors = 0
    for source in files:
        label = source.relative_to(root).as_posix()
        try:
            if migrate_file(source, root, backup_root):
                changed += 1
                print(f"{'APPLIED' if args.apply else 'WOULD_CHANGE'} {label}")
            else:
                unchanged += 1
        except (OSError, ValueError, OverflowError) as error:
            errors += 1
            # Error messages never include saved preferences or malformed JSON contents.
            detail = str(error) if isinstance(error, ValueError) else type(error).__name__
            print(f"ERROR {label}: {detail}")
    mode_name = "APPLY" if args.apply else "READY_CHECK" if args.check_ready else "DRY_RUN"
    print(f"{mode_name} examined={len(files)} changed={changed} unchanged={unchanged} errors={errors}")
    return 1 if errors or (args.check_ready and changed) else 0


if __name__ == "__main__":
    raise SystemExit(main())
