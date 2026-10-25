"""Check Paradise provenance, lossless DMI round trips and rejected bad inputs.

Usage: python tools/vox/check_paradise_assets.py --source tmp/vox-paradise-audit
"""

import argparse
import copy
import json
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools.dmi import Dmi
from tools.vox.adapt_paradise_assets import MODES, OUTPUT, TOOLS, build


def check_output_files(directory, outputs):
    expected = {name + ".dmi" for name in outputs}
    actual = {path.name for path in directory.glob("*.dmi")}
    assert actual == expected, f"Wrong generated file set: missing={sorted(expected - actual)}, obsolete={sorted(actual - expected)}"


def check(source):
    mapping = json.loads((TOOLS / "paradise-clothing-map.json").read_text(encoding="utf-8"))
    manifest = json.loads((TOOLS / "paradise-source-assets.json").read_text(encoding="utf-8"))
    outputs = build(source, mapping, manifest)
    check_output_files(ROOT / OUTPUT, outputs)
    rebuilt = {}
    with tempfile.TemporaryDirectory(prefix="vox-paradise-check-") as scratch:
        for name, icon in outputs.items():
            path = Path(scratch) / f"{name}.dmi"
            icon.to_file(path)
            assert path.read_bytes() == (ROOT / OUTPUT / path.name).read_bytes(), f"Stale output: {name}"
            rebuilt[name] = Dmi.from_file(path)

    checked = covered = 0
    donors = {}
    hood_destinations = [
        {(x, 0) for x in range(12, 19)} | {(12, 1), (13, 1), (17, 1), (18, 1), (10, 2), (20, 2)},
        {(x, 0) for x in range(12, 19)} | {(12, 1), (13, 1), (17, 1), (18, 1), (10, 2), (20, 2)},
        {(13, 1), (14, 1), (15, 1), (16, 1), (13, 2), (14, 2), (12, 3), (13, 3)},
        {(18, 1), (17, 1), (16, 1), (15, 1), (18, 2), (17, 2), (19, 3), (18, 3)},
    ]
    head = Dmi.from_file(ROOT / "icons/bandastation/mob/species/vox/bodyparts.dmi").get_state("vox_head")
    for entry in mapping["entries"]:
        relative = entry["source_file"]
        if relative not in donors:
            donors[relative] = Dmi.from_file(source / relative)
        output = rebuilt[entry["category"] + MODES[entry["mode"]]]
        for donor in (state for state in donors[relative].states if state.name == entry["source_state"]):
            actual = next(state for state in output.states if state.name == entry["target_state"] and state.movement == donor.movement)
            for field in ("dirs", "framecount", "movement", "loop", "rewind", "delays", "hotspots"):
                assert getattr(actual, field) == getattr(donor, field), f"Changed {field}: {entry}"
            if entry.get("transform") == "winterhood_head_coverage":
                copies = mapping["transforms"]["winterhood_head_coverage"]["pixel_copies"]
                for index, (frame, original) in enumerate(zip(actual.frames, donor.frames)):
                    direction = index % 4
                    borrowed = {tuple(dst): tuple(src) for dst, src in copies[direction]}
                    assert set(borrowed) == hood_destinations[direction], "Unreviewed hood coverage coordinates"
                    for x in range(32):
                        for y in range(32):
                            coordinate = (x, y)
                            assert frame.getpixel(coordinate) == original.getpixel(borrowed.get(coordinate, coordinate)), f"Changed hood core/copy: {entry}"
                            if y < 5 and head.frames[direction].getpixel(coordinate)[3]:
                                assert frame.getpixel(coordinate)[3], f"Exposed head above hood: {entry}"
                covered += 1
            else:
                assert all(a.tobytes() == b.tobytes() for a, b in zip(actual.frames, donor.frames)), f"Changed pixels: {entry}"
            checked += 1
    assert covered == 14, "All fourteen reviewed winter hoods must cover the current head"

    auxiliary = mapping.get("auxiliary_states", [])
    for recipe in auxiliary:
        if recipe["recipe"] == "native_mask_clipped":
            counts = {"hood_engineer-emissive": [0, 18, 2, 2], "hood_atmos-emissive": [0, 18, 2, 2], "secjacket-emissive": [30, 34, 18, 18], "cone-emissive": [3, 10, 5, 5]}
            name = recipe["target_state"]
            assert name in counts, "Add a focused check for each new native mask"
            native = Dmi.from_file(ROOT / recipe["native_file"]).get_state(name)
            fitted = rebuilt[recipe["category"]].get_state(recipe["fitted_state"])
            mask = rebuilt[recipe["category"]].get_state(name)
            for field in ("dirs", "framecount", "movement", "loop", "rewind", "delays", "hotspots"):
                assert getattr(mask, field) == getattr(native, field), f"Changed native mask {field}: {name}"
            assert mask.dirs == 4 and mask.framecount == 1
            for direction, (actual, original, garment) in enumerate(zip(mask.frames, native.frames, fitted.frames)):
                assert sum(bool(pixel[3]) for pixel in actual.getdata()) == counts[name][direction], f"Missing reflective stripe: {name}/{direction}"
                for pixel, source_pixel, garment_pixel in zip(actual.getdata(), original.getdata(), garment.getdata()):
                    assert pixel == (*source_pixel[:3], source_pixel[3] * garment_pixel[3] // 255), f"Changed native RGBA/alpha clip: {name}/{direction}"
            continue
        assert recipe["target_state"] == "carved_pumpkin-emissive", "Add a focused check for each new auxiliary recipe"
        mask = rebuilt[recipe["category"]].get_state(recipe["target_state"])
        assert mask.dirs == 4 and mask.framecount == 1, "The blumpkin mask must retain four directions"
        lit = donors[recipe["source_file"]].get_state(recipe["on_state"])
        expected = ({(12, 7), (13, 7), (17, 7), (18, 7)}, set(), {(20, 7), (21, 7)}, {(10, 7), (11, 7)})
        for direction, coordinates in enumerate(expected):
            for x in range(32):
                for y in range(32):
                    pixel = mask.frames[direction].getpixel((x, y))
                    reference = lit.frames[direction].getpixel((x, y)) if (x, y) in coordinates else (0, 0, 0, 0)
                    assert pixel == reference, f"Wrong auxiliary RGBA/anchor: {direction}, {x}, {y}"

    scenarios = ["duplicate", "unpinned", "transform", "schema", "mode", "wrong_pin", "wrong_blob", "missing_state"]
    if auxiliary:
        scenarios += ["aux_recipe", "aux_missing", "aux_empty"]
    scenarios += ["hood_recipe", "hood_coordinate", "hood_source", "native_unpinned", "native_wrong_blob", "native_missing_fitted"]
    for scenario in scenarios:
        broken, pins = copy.deepcopy(mapping), copy.deepcopy(manifest)
        first = broken["entries"][0]
        if scenario == "duplicate":
            broken["entries"].append(first)
        elif scenario == "unpinned":
            first["source_file"] = "unexpected.dmi"
        elif scenario == "transform":
            first["transform"] = "unreviewed"
        elif scenario == "schema":
            broken["schema_version"] = 0
        elif scenario == "mode":
            first["mode"] = "unreviewed"
        elif scenario == "wrong_pin":
            broken["source_revision"] = "wrong"
        elif scenario == "wrong_blob":
            pins["assets"][first["source_file"]] = "0" * 40
        elif scenario == "missing_state":
            first["source_state"] = "deliberately_missing_state"
        elif scenario == "aux_recipe":
            broken["auxiliary_states"][0]["recipe"] = "unreviewed"
        elif scenario == "aux_missing":
            broken["auxiliary_states"][0]["on_state"] = "deliberately_missing_state"
        elif scenario == "aux_empty":
            recipe = broken["auxiliary_states"][0]
            recipe["off_state"] = recipe["on_state"]
        elif scenario == "hood_recipe":
            broken["transforms"] = {}
        elif scenario == "hood_coordinate":
            broken["transforms"]["winterhood_head_coverage"]["pixel_copies"][0][0][0] = [32, 0]
        elif scenario.startswith("native_"):
            recipe = next(entry for entry in broken["auxiliary_states"] if entry["recipe"] == "native_mask_clipped")
            if scenario == "native_unpinned":
                pins["native_assets"].pop(recipe["native_file"])
            elif scenario == "native_wrong_blob":
                pins["native_assets"][recipe["native_file"]] = "0" * 40
            else:
                recipe["fitted_state"] = "deliberately_missing_state"
        else:
            broken["transforms"]["winterhood_head_coverage"]["pixel_copies"][0][0][1] = [0, 0]
        try:
            build(source, broken, pins)
        except ValueError:
            continue
        raise AssertionError(f"Malformed input was accepted: {scenario}")
    with tempfile.TemporaryDirectory(prefix="vox-paradise-file-set-") as scratch:
        directory = Path(scratch)
        for name in outputs:
            (directory / (name + ".dmi")).touch()
        check_output_files(directory, outputs)
        obsolete = directory / "obsolete.dmi"
        obsolete.touch()
        try:
            check_output_files(directory, outputs)
        except AssertionError:
            pass
        else:
            raise AssertionError("Obsolete generated DMI was accepted")
    return {
        "wearable_states": checked,
        "identity_states": checked - covered,
        "hood_coverage_states": covered,
        "derived_auxiliary_states": len(auxiliary),
        "reproducible_files": len(outputs),
        "rejected_bad_inputs": len(scenarios) + 1,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    print(json.dumps(check(parser.parse_args().source)))
