"""Strictly validate the imported vox DMI files, animation and provenance."""

import hashlib
import json
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


def main():
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
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
