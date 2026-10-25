"""Validate actual headless-forge pixels and metadata, including warm VM epochs."""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[3]))
from tools.dmi import Dmi


def valid_version(value):
    return isinstance(value, str) and bool(re.fullmatch(r"\d+\.\d+\.\d+(?:[-+][\w.-]+)?", value.strip()))


def check_image(path, result, expected_path=None):
    errors = []
    report = {"path": path.name, "errors": errors}
    if (not isinstance(result, dict) or not {"error", "file_path", "width", "height"} <= result.keys()
            or result["error"] is not None or result["file_path"] != (expected_path or path.name)
            or result["width"] != 32 or result["height"] != 32):
        errors.append("Invalid headless-forge JSON metadata")
    try:
        with Image.open(path) as image:
            if image.format != "PNG" or image.size != (32, 32):
                errors.append("Output must be a 32x32 PNG")
            if image.convert("RGBA").tobytes() != bytes((255, 0, 0, 255)) * 1024:
                errors.append("Actual output RGB/alpha differs from the solid red SOUTH fixture")
            report["png_size"] = list(image.size)
        icon = Dmi.from_file(path)
        report["states"] = [{"name": state.name, "dirs": state.dirs, "frames": state.framecount} for state in icon.states]
        if ((icon.width, icon.height) != (32, 32) or len(icon.states) != 1
                or icon.states[0].name != "result" or icon.states[0].dirs != 1
                or icon.states[0].framecount != 1 or icon.states[0].movement):
            errors.append("Invalid DMI state/direction/frame metadata")
        report["output_sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
    except (OSError, ValueError, KeyError, AssertionError, StopIteration, NotImplementedError, ZeroDivisionError, IndexError) as exc:
        errors.append(f"Cannot decode output DMI: {type(exc).__name__}: {exc}")
    report["valid"] = not errors
    return report


def validate(run, mode):
    errors = []
    report = {"valid": False, "mode": mode, "errors": errors, "images": []}
    log_path = run / "console.log"
    log = log_path.read_text(encoding="utf-8", errors="replace") if log_path.exists() else ""
    if "BEFORE_DEL" not in log:
        errors.append("World did not reach BEFORE_DEL")
    if (run / "invalid.marker").exists() or "INVALID_RESULT" in log:
        errors.append("DM reported INVALID_RESULT")
    ready = run / "ready.marker"
    if not ready.exists() or ready.read_text(encoding="utf-8").strip() != "ready":
        errors.append("Missing or invalid ready marker")
    if mode == "warm":
        pid_path = run / "host-pid.txt"
        host_pid = int(pid_path.read_text(encoding="utf-8")) if pid_path.exists() else 0
        for epoch in range(1, 4):
            try:
                record = json.loads((run / f"epoch-{epoch}.json").read_text(encoding="utf-8"))
                if record.get("mode") != "warm" or record.get("epoch") != epoch or not valid_version(record.get("version")):
                    errors.append(f"Invalid warm epoch {epoch} identity/version")
                if host_pid <= 0 or record.get("host_pid") != host_pid:
                    errors.append(f"Warm epoch {epoch} does not match the original host PID")
                image_report = check_image(run / f"output-{epoch}.dmi", record.get("result"))
                report["images"].append(image_report)
                if not image_report["valid"]:
                    errors.append(f"Warm epoch {epoch} has invalid output")
            except (OSError, ValueError, AttributeError) as exc:
                errors.append(f"Missing or invalid warm epoch {epoch}: {exc}")
            if epoch < 3:
                marker = run / f"reboot-{epoch}.marker"
                if not marker.exists() or marker.read_text(encoding="utf-8").strip() != "before_reboot":
                    errors.append(f"Missing BEFORE_REBOOT marker for epoch {epoch}")
        epoch_path = run / "epoch.txt"
        if not epoch_path.exists() or epoch_path.read_text(encoding="utf-8").strip() != "3":
            errors.append("Warm reboot did not finish exactly three epochs")
        if (run / "output.dmi").exists() or (run / "reboot-3.marker").exists():
            errors.append("Unexpected extra output/reboot after the third epoch")
    else:
        versions = re.findall(r"^VERSION=(.+)$", log, re.M)
        if len(versions) != 1 or not valid_version(versions[0]):
            errors.append("Missing or invalid get_version result")
        report["version"] = versions[0].strip() if versions else None
        result_lines = re.findall(r"^RESULT=(.+)$", log, re.M)
        if mode == "control":
            if (run / "output.dmi").exists() or result_lines:
                errors.append("Control unexpectedly generated an output")
        else:
            result = None
            if len(result_lines) != 1:
                errors.append("Expected exactly one headless-forge JSON result")
            else:
                try:
                    result = json.loads(result_lines[0])
                except ValueError:
                    errors.append("Malformed headless-forge JSON")
            report["forge_result"] = result
            image_report = check_image(run / "output.dmi", result)
            report["images"].append(image_report)
            if not image_report["valid"]:
                errors.append("Invalid headless-forge output")
        if mode == "cleanup" and re.findall(r"^CLEANUP=(.+)$", log, re.M) != ["Ok"]:
            errors.append("Missing or unsuccessful iconforge_cleanup result")
    report["valid"] = not errors
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run", type=Path)
    parser.add_argument("mode", choices=("control", "forge", "cleanup", "warm"))
    args = parser.parse_args()
    result = validate(args.run, args.mode)
    print(json.dumps(result, ensure_ascii=False))
    raise SystemExit(0 if result["valid"] else 1)
