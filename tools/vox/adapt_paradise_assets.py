"""Build the reviewed Paradise clothing overlays for the existing Vox body.

Usage: python tools/vox/adapt_paradise_assets.py --source tmp/vox-paradise-audit
Add --check to compare the committed output without changing it. Source files
must retain their repository-relative paths. Only the explicit clothing map is
copied: matching names in another DMI do not imply equivalent clothing.

Wearable states preserve source pixels, 32x32 anchors, colours, direction order
and animation metadata. Fourteen winter hoods add reviewed copies of their own
border/fabric pixels to cover the current head. The separate auxiliary recipe
retains only lit pixels that change between a pinned on/off pair. Native
reflective masks use separately pinned Banda inputs and are clipped to the
fitted garment alpha. Current Nova
body parts, beaks and quills are never modified.
"""

import argparse
import copy
import hashlib
import json
import sys
import tempfile
from pathlib import Path
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools.dmi import Dmi

TOOLS = Path(__file__).parent
OUTPUT = Path("icons/bandastation/mob/species/vox/paradise")
CATEGORIES = {"head", "helmet", "mask", "under", "shoes", "eyes", "gloves", "suit", "back", "belt", "neck", "ears"}
MODES = {"missing_only": "", "reviewed_replacement": "_replacement"}


def git_blob_hash(data):
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()


def cover_winterhood(state, recipe):
    if not recipe or len(recipe.get("pixel_copies", [])) != 4 or state.dirs != 4:
        raise ValueError("Winterhood coverage requires reviewed copies for four directions")
    frames = []
    for index, original in enumerate(state.frames):
        frame = original.copy()
        copies = recipe["pixel_copies"][index % 4]
        for destination, source in copies:
            if any(len(point) != 2 or any(not isinstance(v, int) or not 0 <= v < 32 for v in point) for point in (destination, source)):
                raise ValueError("Winterhood pixel coordinates must stay in the 32x32 cell")
            destination, source = tuple(destination), tuple(source)
            if original.getpixel(destination)[3] or not original.getpixel(source)[3]:
                raise ValueError("Winterhood copies must extend transparent cells using authored opaque pixels")
            frame.putpixel(destination, original.getpixel(source))
        frames.append(frame)
    return frames


def build(source_root, mapping, provenance):
    if mapping["schema_version"] != 1:
        raise ValueError("Unsupported clothing map schema")
    if mapping["source_revision"] != provenance["revision"]:
        raise ValueError("Clothing map and source manifest have different revisions")
    inputs = {}
    outputs = {}
    targets = set()

    def get_input(relative, native=False):
        pins = provenance.get("native_assets", {}) if native else provenance["assets"]
        root = ROOT if native else source_root
        key = (native, relative)
        if relative not in pins:
            raise ValueError(f"Source is not pinned: {relative}")
        if key not in inputs:
            data = (root / relative).read_bytes()
            if git_blob_hash(data) != pins[relative]:
                raise ValueError(f"Source differs from its pinned file: {relative}")
            icon = Dmi.from_file(root / relative)
            if (icon.width, icon.height) != (32, 32):
                raise ValueError(f"Unexpected source anchor/cell size: {relative}")
            inputs[key] = icon
        return inputs[key]

    for entry in mapping["entries"]:
        category, name, mode = entry["category"], entry["target_state"], entry["mode"]
        if category not in CATEGORIES or mode not in MODES or not name or any(ord(char) < 32 for char in name):
            raise ValueError(f"Invalid target category/state: {category}/{name!r}")
        if (category, name) in targets:
            raise ValueError(f"Ambiguous target: {category}/{name}")
        targets.add((category, name))
        transform = entry.get("transform", "identity")
        if transform not in ("identity", "winterhood_head_coverage"):
            raise ValueError(f"Unreviewed pixel transform: {category}/{name}")
        if transform == "winterhood_head_coverage" and (category != "head" or not name.startswith("hood_")):
            raise ValueError(f"Winterhood coverage used outside its reviewed family: {category}/{name}")
        relative = entry["source_file"]
        states = [state for state in get_input(relative).states if state.name == entry["source_state"]]
        if not states or len({state.movement for state in states}) != len(states):
            raise ValueError(f"Missing or ambiguous source state: {relative}/{entry['source_state']}")
        output = outputs.setdefault(category + MODES[mode], Dmi(32, 32))
        for source_state in states:
            if source_state.dirs != 4 or not any(frame.getbbox() for frame in source_state.frames):
                raise ValueError(f"Not a visible four-direction overlay: {relative}/{source_state.name}")
            state = copy.copy(source_state)
            state.dmi = output
            state.name = name
            if transform == "winterhood_head_coverage":
                recipe = mapping.get("transforms", {}).get(transform)
                state.frames = cover_winterhood(source_state, recipe)
            output.states.append(state)
    for recipe in mapping.get("auxiliary_states", []):
        category, name = recipe["category"], recipe["target_state"]
        if category not in CATEGORIES or not name or any(ord(char) < 32 for char in name):
            raise ValueError(f"Invalid auxiliary target: {category}/{name!r}")
        if (category, name) in targets or recipe["recipe"] not in ("changed_lit_rgba", "native_mask_clipped"):
            raise ValueError(f"Ambiguous or unreviewed auxiliary recipe: {category}/{name}")
        targets.add((category, name))
        if recipe["recipe"] == "native_mask_clipped":
            output = outputs.get(category)
            masks = [state for state in get_input(recipe["native_file"], native=True).states if state.name == name]
            fitted = [] if output is None else [state for state in output.states if state.name == recipe["fitted_state"]]
            if len(masks) != 1 or len(fitted) != 1 or name != recipe["fitted_state"] + "-emissive":
                raise ValueError(f"Missing or ambiguous native/fitted auxiliary input: {category}/{name}")
            native, fitted = masks[0], fitted[0]
            fields = ("dirs", "framecount", "movement", "loop", "rewind", "delays", "hotspots")
            if native.dirs != 4 or any(getattr(native, field) != getattr(fitted, field) for field in fields):
                raise ValueError(f"Native/fitted auxiliary metadata differs: {category}/{name}")
            state = copy.copy(native)
            state.dmi, state.name, state.frames = output, name, []
            for mask, garment in zip(native.frames, fitted.frames):
                frame = mask.copy()
                frame.putalpha(ImageChops.multiply(mask.getchannel("A"), garment.getchannel("A")))
                state.frames.append(frame)
            if not any(frame.getbbox() for frame in state.frames):
                raise ValueError(f"Auxiliary recipe is empty: {category}/{name}")
            output.states.append(state)
            continue
        icon = get_input(recipe["source_file"])
        pair = []
        for key in ("on_state", "off_state"):
            matches = [state for state in icon.states if state.name == recipe[key]]
            if len(matches) != 1:
                raise ValueError(f"Missing or ambiguous auxiliary input: {recipe[key]}")
            pair.append(matches[0])
        on, off = pair
        fields = ("dirs", "framecount", "movement", "loop", "rewind", "delays", "hotspots")
        if on.dirs != 4 or any(getattr(on, field) != getattr(off, field) for field in fields):
            raise ValueError(f"Auxiliary on/off metadata differs: {category}/{name}")
        output = outputs.setdefault(category, Dmi(32, 32))
        state = copy.copy(on)
        state.dmi, state.name, state.frames = output, name, []
        for lit, unlit in zip(on.frames, off.frames):
            frame = Image.new("RGBA", (32, 32))
            for x in range(32):
                for y in range(32):
                    pixel = lit.getpixel((x, y))
                    if pixel[3] and pixel != unlit.getpixel((x, y)):
                        frame.putpixel((x, y), pixel)
            state.frames.append(frame)
        if not any(frame.getbbox() for frame in state.frames):
            raise ValueError(f"Auxiliary recipe is empty: {category}/{name}")
        output.states.append(state)
    if not outputs:
        raise ValueError("The reviewed clothing map is empty")
    return outputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    mapping = json.loads((TOOLS / "paradise-clothing-map.json").read_text(encoding="utf-8"))
    provenance = json.loads((TOOLS / "paradise-source-assets.json").read_text(encoding="utf-8"))
    outputs = build(args.source, mapping, provenance)
    expected = {name + ".dmi" for name in outputs}
    existing = {path.name for path in (ROOT / OUTPUT).glob("*.dmi")}
    if existing - expected:
        raise ValueError(f"Remove obsolete generated files before rebuilding: {sorted(existing - expected)}")
    report = {}
    with tempfile.TemporaryDirectory(prefix="vox-paradise-") as scratch:
        for category, icon in sorted(outputs.items()):
            relative = OUTPUT / f"{category}.dmi"
            destination = Path(scratch) / f"{category}.dmi" if args.check else ROOT / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            icon.to_file(destination)
            data = destination.read_bytes()
            if args.check and (ROOT / relative).read_bytes() != data:
                raise ValueError(f"Committed overlay is not reproducible: {relative}")
            report[relative.as_posix()] = {
                "states": len(icon.states),
                "sha256": hashlib.sha256(data).hexdigest(),
            }
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
