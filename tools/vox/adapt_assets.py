"""Adapt pinned BandaStation PR #2682 DMIs without changing their pixels.

Usage: python tools/vox/adapt_assets.py --source tmp/vox-source/assets
The source directory must contain the PR files at their repository-relative paths.
"""

import argparse
import copy
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools.dmi import Dmi

VOX = Path("icons/bandastation/mob/species/vox")


def add_state(destination, state, name=None):
    state = copy.copy(state)
    state.dmi = destination
    if name is not None:
        state.name = name
    destination.states.append(state)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path)
    args = parser.parse_args()

    provenance = json.loads((Path(__file__).parent / "source-assets.json").read_text(encoding="utf-8"))
    for relative, expected in provenance["assets"].items():
        data = (args.source / relative).read_bytes()
        actual = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        if actual != expected:
            raise ValueError(f"Source asset does not match the pinned PR: {relative}")

    head = Dmi.from_file(args.source / VOX / "clothing/head.dmi")
    helmet = Dmi.from_file(args.source / VOX / "clothing/helmet.dmi")
    keys = {(state.name, state.movement) for state in head.states}
    for state in helmet.states:
        if (state.name, state.movement) not in keys:
            add_state(head, state)
            keys.add((state.name, state.movement))

    # Paradise puts the lamp digit at the end; TG puts it before the colour.
    for colour in ("yellow", "white", "orange", "red", "dblue", "pumpkin"):
        for lamp in (0, 1):
            source_name = f"hardhat_{colour}{lamp}"
            target_name = f"hardhat{lamp}_{colour}"
            if (target_name, False) not in keys:
                add_state(head, head.get_state(source_name), target_name)
                keys.add((target_name, False))

    aliases = {
        "helmet-novisor": "security_helmet_novisor",
        "helmet-flight": "security_helmet-flight",
        "helmet-flight-on": "security_helmet-flight-on",
        "helmet-novisor-flight": "security_helmet_novisor-flight",
        "helmet-novisor-flight-on": "security_helmet_novisor-flight-on",
        "headmirror": "head_mirror",
        "surgicalcap": "surgcap_blue",
        "surgicalcapgreen": "surgcap_green",
        "surgicalcapwine": "surgcap_purple",
        "weldhelmet": "welding",
        "bombsuit_sec": "bombsuitsec",
    }
    for target, source in aliases.items():
        if (target, False) not in keys:
            add_state(head, head.get_state(source), target)

    # Equal state names have different artwork: helmets need the complete
    # helmet sprites, while the modern head file also contains partial overlays.
    helmet_keys = {(state.name, state.movement) for state in helmet.states}
    for state in head.states:
        if (state.name, state.movement) not in helmet_keys:
            add_state(helmet, state)
            helmet_keys.add((state.name, state.movement))

    mask_source = Dmi.from_file(args.source / VOX / "clothing/mask.dmi")
    mask = Dmi(mask_source.width, mask_source.height)
    mask_keys = set()
    for state in mask_source.states:
        key = (state.name, state.movement)
        if key in mask_keys:
            continue
        mask_keys.add(key)
        # The first set fits the beak; the repeated set contains human sprites.
        add_state(mask, state)

    for style in ("cloth", "stripe", "skull"):
        for suffix in ("", "_up"):
            add_state(mask, mask.get_state(f"bandana_{style}_worn{suffix}"), f"bandana_{style}{suffix}")
    add_state(mask, mask.get_state("joker"), "jonkler")

    eyes = Dmi.from_file(args.source / VOX / "clothing/eyes.dmi")
    for target, source in {
        "glasses_regular": "glasses",
        "glasses_hipster": "hipster_glasses",
        "eyepatch_medical": "medpatch",
        "eyepatch_medical_flipped": "medpatch_flipped",
        "securityhudnight": "security_hud_nv",
        "sunhudsec": "sunhud",
        "medsechud": "secmedhud",
        "gar_black": "garb",
        "gar_meson": "garm",
        "gar_sec": "gars",
        "gigagar_black": "supergarb",
        "gigagar_red": "supergar",
        "gigagar_sec": "supergars",
    }.items():
        add_state(eyes, eyes.get_state(source), target)

    body = Dmi.from_file(args.source / VOX / "bodyparts.dmi")
    for side in ("l", "r"):
        add_state(body, body.get_state(f"digitigrade_{side}_leg"), f"vox_{side}_leg")

    changed = {}
    for relative, icon in (
        (VOX / "clothing/head.dmi", head),
        (VOX / "clothing/helmet.dmi", helmet),
        (VOX / "clothing/mask.dmi", mask),
        (VOX / "clothing/eyes.dmi", eyes),
        (VOX / "bodyparts.dmi", body),
    ):
        destination = ROOT / relative
        icon.to_file(destination)
        changed[relative.as_posix()] = {
            "states": len(icon.states),
            "sha256": hashlib.sha256(destination.read_bytes()).hexdigest(),
        }
    print(json.dumps(changed, indent=2))


if __name__ == "__main__":
    main()
