"""Strictly validate the imported vox DMI files, animation and provenance."""

import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools.dmi import Dmi

DERIVED = {
    "icons/bandastation/mob/species/vox/bodyparts.dmi",
    "icons/bandastation/mob/species/vox/clothing/head.dmi",
    "icons/bandastation/mob/species/vox/clothing/helmet.dmi",
    "icons/bandastation/mob/species/vox/clothing/eyes.dmi",
    "icons/bandastation/mob/species/vox/clothing/mask.dmi",
}


def check_pumpkin_mask(dmi):
    mask = dmi.get_state("carved_pumpkin-emissive")
    lit = dmi.get_state("hardhat_pumpkin1")
    unlit = dmi.get_state("hardhat_pumpkin0")
    if mask.dirs != 4 or mask.framecount != 1:
        raise ValueError("The pumpkin emissive mask must have four static directions")
    expected = (
        {(12, 4), (12, 7), (13, 4), (13, 5), (13, 8), (14, 8), (15, 6), (15, 9), (16, 8), (17, 4), (17, 5), (17, 8), (18, 4), (18, 7)},
        set(),
        {(16, 4), (16, 7), (17, 4), (17, 5), (17, 8), (18, 8), (19, 6), (19, 9)},
        {(12, 6), (12, 9), (13, 8), (14, 4), (14, 5), (14, 8), (15, 4), (15, 7)},
    )
    holes = {(43, 22, 3, 255), (65, 31, 4, 255), (79, 32, 12, 255)}
    for direction, coordinates in enumerate(expected):
        for x in range(32):
            for y in range(32):
                coordinate = (x, y)
                pixel = mask.frames[direction].getpixel(coordinate)
                reference = lit.frames[direction].getpixel(coordinate) if coordinate in coordinates else (0, 0, 0, 0)
                if pixel != reference:
                    raise ValueError(f"Incorrect pumpkin mask RGBA/anchor: {direction}/{coordinate}")
                if coordinate in coordinates and unlit.frames[direction].getpixel(coordinate) not in holes:
                    raise ValueError("Pumpkin mask contains shell pixels instead of authored holes")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, help="Also reproduce derived files from the pinned raw PR assets")
    args = parser.parse_args()
    provenance = json.loads((Path(__file__).parent / "source-assets.json").read_text(encoding="utf-8"))
    report = {"files": 0, "states": 0, "frames": 0, "assets": {}}
    for relative, expected_blob in provenance["assets"].items():
        path = ROOT / relative
        data = path.read_bytes()
        blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        if relative not in DERIVED and blob != expected_blob:
            raise ValueError(f"Unmodified asset differs from its pinned source: {relative}")
        with Image.open(path) as png:
            png.load()  # Truncated PNGs must fail; do not enable LOAD_TRUNCATED_IMAGES.
            image_width, image_height = png.size
        dmi = Dmi.from_file(path)
        if relative.endswith(("/clothing/head.dmi", "/clothing/helmet.dmi")):
            check_pumpkin_mask(dmi)
        if image_width % dmi.width or image_height % dmi.height:
            raise ValueError(f"Partial sprite cell in {relative}")
        keys = [(state.name, state.movement) for state in dmi.states]
        if len(keys) != len(set(keys)):
            raise ValueError(f"Ambiguous duplicate state in {relative}")
        frames = 0
        for state in dmi.states:
            if state.dirs not in (1, 4, 8) or not state.frames:
                raise ValueError(f"Invalid direction/frame count in {relative}: {state.name}")
            if len(state.frames) % state.dirs:
                raise ValueError(f"Incomplete directions in {relative}: {state.name}")
            if state.delays and len(state.delays) != state.framecount:
                raise ValueError(f"Animation delay count mismatch in {relative}: {state.name}")
            frames += len(state.frames)
        cells = (image_width // dmi.width) * (image_height // dmi.height)
        if frames > cells:
            raise ValueError(f"DMI metadata points outside the PNG in {relative}")
        report["files"] += 1
        report["states"] += len(dmi.states)
        report["frames"] += frames
        report["assets"][relative] = {"states": len(dmi.states), "frames": frames, "sha256": hashlib.sha256(data).hexdigest()}
    if args.source:
        result = subprocess.run(
            [sys.executable, str(Path(__file__).with_name("adapt_assets.py")), "--source", str(args.source), "--check"],
            check=True, capture_output=True, text=True,
        )
        report["reproduced_derived_files"] = len(json.loads(result.stdout))
        preserved = 0
        for name in ("head", "helmet"):
            relative = Path("icons/bandastation/mob/species/vox/clothing") / f"{name}.dmi"
            original = Dmi.from_file(args.source / relative)
            actual = Dmi.from_file(ROOT / relative)
            for donor in original.states:
                state = next(s for s in actual.states if s.name == donor.name and s.movement == donor.movement)
                fields = ("dirs", "framecount", "movement", "loop", "rewind", "delays", "hotspots")
                if any(getattr(state, field) != getattr(donor, field) for field in fields) or any(a.tobytes() != b.tobytes() for a, b in zip(state.frames, donor.frames)):
                    raise ValueError(f"Original source state was changed: {relative}/{donor.name}")
                preserved += 1
        report["unchanged_original_head_helmet_states"] = preserved
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
