"""Validate ordinary-server lifecycle markers and real native forge output."""
import argparse
import importlib.util
import json
import re
from pathlib import Path

SOURCE = Path(__file__).resolve().parent / "rustg-shutdown-repro/validate_output.py"
SPEC = importlib.util.spec_from_file_location("native_forge_validation", SOURCE)
FORGE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(FORGE)


def validate(run, scenario):
    errors, epochs = [], []
    report = {"valid": False, "scenario": scenario, "errors": errors, "epochs": epochs}
    try:
        host_pid = int((run / "data/lifecycle-host-pid.txt").read_text(encoding="utf-8"))
        nonce = (run / "data/lifecycle-nonce.txt").read_text(encoding="utf-8").strip()
        expected_map = json.loads((run / "_maps/map_jsons/runtimestation_minimal.json").read_text(encoding="utf-8"))["map_name"]
    except (OSError, ValueError, KeyError) as exc:
        errors.append(f"Missing host identity/map evidence: {exc}")
        return report
    count = 3 if scenario == "warm" else 1
    log_directories = []
    for epoch in range(1, count + 1):
        try:
            record = json.loads((run / f"data/lifecycle-epoch-{epoch}.json").read_text(encoding="utf-8"))
            if (record.get("scenario") != scenario or record.get("epoch") != epoch
                    or record.get("nonce") != nonce or record.get("host_pid") != host_pid or host_pid <= 0):
                errors.append(f"Epoch {epoch} identity/host PID mismatch")
            if (record.get("unit_tests") != 0 or record.get("init_stage_completed") != 4
                    or record.get("uninitialized") != [] or record.get("subsystems_initialized", 0) <= 0):
                errors.append(f"Epoch {epoch} is not a fully initialized ordinary server")
            if not record.get("mc_running"):
                errors.append(f"Epoch {epoch} did not keep the master loop running")
            timer = json.loads((run / f"data/lifecycle-timer-{epoch}.json").read_text(encoding="utf-8"))
            if (timer.get("epoch") != epoch or timer.get("before") != record.get("timer_world_time")
                    or not timer.get("mc_running") or not isinstance(timer.get("after"), (int, float))
                    or not isinstance(timer.get("before"), (int, float)) or timer["after"] - timer["before"] < 10):
                errors.append(f"Epoch {epoch} did not advance through both real timer callbacks")
            if record.get("ban_list_is_list") != 1 or record.get("ban_list_length") != 0:
                errors.append(f"Epoch {epoch} did not validate the genuinely empty fresh-server ban list")
            cyber = record.get("cyber_regression", {})
            if (cyber.get("success") != 1 or cyber.get("abstract_costs_null") != 1
                    or cyber.get("concrete_cost") != cyber.get("expected_cost")
                    or cyber.get("registry_restored") != 1 or cyber.get("trait_restored") != 1):
                errors.append(f"Epoch {epoch} failed the deterministic cyber-trait regression")
            mapping = record.get("mapping_regression", {})
            if (mapping.get("success") != 1 or mapping.get("checks") != 3
                    or any(mapping.get(branch) != 1 for branch in ("cache_restored", "change_turf", "lattice_initialize", "lattice_destroy"))):
                errors.append(f"Epoch {epoch} failed the three deterministic missing-area regressions")
            if record.get("runtime_count") != 0 or record.get("map") != expected_map:
                errors.append(f"Epoch {epoch} has runtimes or loaded a different map")
            if record.get("tgs_available") != 0 or record.get("hard_reboot") != 0:
                errors.append(f"Epoch {epoch} used TGS or allowed a process-level restart")
            if record.get("visibility") != 0 or record.get("hub") or record.get("sql_enabled") != 0:
                errors.append(f"Epoch {epoch} enabled Hub visibility or a database")
            if not isinstance(record.get("port"), int) or not 0 < record["port"] <= 65535:
                errors.append(f"Epoch {epoch} did not report an automatically assigned listening port")
            if not FORGE.valid_version(record.get("native_version")):
                errors.append(f"Epoch {epoch} has an invalid native version result")
            log_directory = record.get("log_directory", "")
            if not log_directory.startswith("data/logs/") or log_directory in log_directories:
                errors.append(f"Epoch {epoch} did not preserve a separate ordinary-server log directory")
            log_directories.append(log_directory)
            if not (run / log_directory / "dd.log").exists() or not (run / log_directory / "runtime.log.json").exists():
                errors.append(f"Epoch {epoch} daemon/runtime logs are missing")
            relative = f"data/lifecycle-health-{epoch}.dmi"
            image = FORGE.check_image(run / relative, record.get("native_result"), expected_path=relative)
            epochs.append({"record": record, "image": image})
            if not image["valid"]:
                errors.append(f"Epoch {epoch} native health pixels/metadata failed")
        except (OSError, ValueError, AttributeError) as exc:
            errors.append(f"Missing/invalid epoch {epoch}: {exc}")
        if epoch < count:
            marker = run / f"data/lifecycle-before-reboot-{epoch}.marker"
            if not marker.exists() or marker.read_text(encoding="utf-8").strip() != "before_reboot":
                errors.append(f"Missing normal Reboot marker after epoch {epoch}")
    expected_markers = {
        "data/lifecycle-epoch.txt": str(count),
        "data/lifecycle-before-shutdown.marker": "before_shutdown",
        "data/lifecycle-subsystems-stopped.marker": "subsystems_stopped",
        "data/lifecycle-logging-closed.marker": "logging_closed",
    }
    for relative, expected in expected_markers.items():
        path = run / relative
        if not path.exists() or path.read_text(encoding="utf-8").strip() != expected:
            errors.append(f"Missing/invalid {relative}")
    try:
        shutdown = json.loads((run / "data/lifecycle-shutdown.json").read_text(encoding="utf-8"))
        if shutdown.get("epoch") != count or shutdown.get("runtime_count") != 0:
            errors.append("Shutdown produced DM runtimes or ended the wrong epoch")
    except (OSError, ValueError, AttributeError) as exc:
        errors.append(f"Missing shutdown result: {exc}")
    if (run / "data/lifecycle-failed.json").exists():
        errors.append("The lifecycle subsystem reported failure")
    if (run / "data/unit_tests.json").exists():
        errors.append("A unit-test result appeared in an ordinary-server run")
    if (run / f"data/lifecycle-before-reboot-{count}.marker").exists():
        errors.append("Unexpected reboot after the final epoch")
    runtime_pattern = re.compile(r"Runtime in\b|runtime error\b|uncaught exception\b|Total runtimes:\s*[1-9]|BYOND out of memory|Maximum recursion level reached|Infinite loop suspected", re.I)
    log_paths = [run / "console.log", *sorted((run / "data/logs").rglob("dd.log")), *sorted((run / "data/logs").rglob("runtime.log.json"))]
    report["runtime_matches"] = []
    for path in log_paths:
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            if runtime_pattern.search(line):
                report["runtime_matches"].append({"file": path.relative_to(run).as_posix(), "line": line})
    if report["runtime_matches"]:
        errors.append("Runtime error found in daemon logs")
    if not list((run / "data/logs").rglob("dd.log")) or not list((run / "data/logs").rglob("runtime.log.json")):
        errors.append("Missing ordinary-server daemon/runtime logs")
    report["valid"] = not errors
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run", type=Path)
    parser.add_argument("scenario", choices=("shutdown", "warm"))
    args = parser.parse_args()
    result = validate(args.run, args.scenario)
    print(json.dumps(result, ensure_ascii=False))
    raise SystemExit(0 if result["valid"] else 1)
