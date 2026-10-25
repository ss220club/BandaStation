"""Extract pinned Paradise states without changing pixels, direction order or timing.

Usage: python tools/shadow_demon/extract_assets.py PATH_TO_DONOR [--check]
The donor directory must retain repository-relative icon and sound paths.
"""

import argparse
import copy
import hashlib
import json
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools.dmi import Dmi

REVISION = "0fffca1f1f29a63aff49d9b56524813eedf82c6d"
MODULE = ROOT / "modular_bandastation/shadow_demon"
RECIPES = {
    "alerts.dmi": {"icons/mob/screen_alert.dmi": ["lightexposure"]},
    "shadow_demon.dmi": {
        "icons/mob/mob.dmi": [
            "shadow_demon", "shadow_demon_eye_glow_overlay",
            "shadowwalk_appear", "shadowwalk_disappear",
        ],
    },
    "actions.dmi": {
        "icons/mob/actions/actions.dmi": [
            "shadow_demon_bg", "shadow_grapple", "shadow_crawl", "shadow_whisper",
        ],
    },
    "effects.dmi": {
        "icons/effects/effects.dmi": ["shadowcocoon"],
        "icons/effects/beam.dmi": ["grabber_beam"],
    },
    "projectiles.dmi": {"icons/obj/projectiles.dmi": ["shadow_hand"]},
    "items.dmi": {"icons/obj/wizard.dmi": ["vialshadows"]},
}


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def build(source, destination):
    manifest = {"repository": "https://github.com/ss220club/Paradise-SS220", "revision": REVISION, "inputs": {}, "outputs": {}}
    for output_name, inputs in RECIPES.items():
        result = None
        for relative, states in inputs.items():
            path = source / relative
            data = path.read_bytes()
            blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
            manifest["inputs"][relative] = {"git_blob": blob, "sha256": sha256(data)}
            original = Dmi.from_file(path)
            if result is None:
                result = Dmi(original.width, original.height)
            if (result.width, result.height) != (original.width, original.height):
                raise ValueError(f"Incompatible DMI cell size: {relative}")
            for name in states:
                state = copy.deepcopy(original.get_state(name))
                state.dmi = result
                result.states.append(state)
        out = destination / "icons" / output_name
        out.parent.mkdir(parents=True, exist_ok=True)
        result.to_file(out)
        reread = Dmi.from_file(out)
        for expected, actual in zip(result.states, reread.states, strict=True):
            if (expected.name, expected.dirs, expected.delays, expected.loop, expected.rewind, expected.movement) != (actual.name, actual.dirs, actual.delays, actual.loop, actual.rewind, actual.movement):
                raise ValueError(f"Changed animation metadata: {expected.name}")
            for frame, restored in zip(expected.frames, actual.frames, strict=True):
                if frame.tobytes() != restored.tobytes():
                    raise ValueError(f"Changed pixels: {expected.name}")
        manifest["outputs"][f"icons/{output_name}"] = {"sha256": sha256(out.read_bytes()), "states": [state.name for state in result.states]}
    sounds = sorted((source / "sound/shadowdemon").glob("*.ogg"))
    if len(sounds) != 10:
        raise ValueError(f"Expected 10 original sounds; found {len(sounds)}")
    for sound in sounds:
        data = sound.read_bytes()
        out = destination / "sound" / sound.name
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_bytes(data)
        manifest["inputs"][sound.relative_to(source).as_posix()] = {"sha256": sha256(data)}
        manifest["outputs"][f"sound/{sound.name}"] = {"sha256": sha256(data)}
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    manifest_path = MODULE / "assets.json"
    with tempfile.TemporaryDirectory() as temporary:
        output = Path(temporary) if args.check else MODULE
        manifest = build(args.source, output)
        if args.check:
            pinned = json.loads(manifest_path.read_text(encoding="utf-8"))
            if manifest != pinned:
                raise ValueError("Asset provenance differs from committed manifest")
            for relative, expected in manifest["outputs"].items():
                if sha256((MODULE / relative).read_bytes()) != expected["sha256"]:
                    raise ValueError(f"Asset differs from pinned output: {relative}")
        else:
            manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Verified {len(manifest['outputs'])} assets with original pixels, animation metadata and sound bytes.")


if __name__ == "__main__":
    main()
