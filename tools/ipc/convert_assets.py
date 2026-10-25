"""Convert Paradise-SS220 IPC limb sprites to BandaStation's six-bodypart layout.

Original accessory files are copied byte-for-byte, retaining their animation
timing and directions. See README.md for the required source revision.
"""
from pathlib import Path
import argparse
import math
import re
import shutil
import subprocess
from PIL import Image, PngImagePlugin

TARGET = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--source", type=Path, default=TARGET.parent / "Paradise-SS220",
                    help="Path to the pinned Paradise-SS220 checkout")
SOURCE = parser.parse_args().source.resolve()
REVISION = "0fffca1f1f29a63aff49d9b56524813eedf82c6d"
actual_revision = subprocess.check_output(
    ["git", "-C", str(SOURCE), "rev-parse", "HEAD"], text=True
).strip()
if actual_revision != REVISION:
    parser.error(f"Expected source revision {REVISION}, got {actual_revision}")
source_changes = subprocess.check_output(
    ["git", "-C", str(SOURCE), "status", "--porcelain", "--untracked-files=all"], text=True
).strip()
if source_changes:
    parser.error("The pinned source checkout has local changes; use a clean checkout before converting assets")
DEST = TARGET / "modular_bandastation/species/icons/ipc"
DEST.mkdir(parents=True, exist_ok=True)


def read_dmi(path):
    image = Image.open(path).convert("RGBA")
    description = Image.open(path).info["Description"]
    assert re.search(r"width = 32", description)
    assert re.search(r"height = 32", description)
    states, cursor = {}, 0
    for match in re.finditer(r'^state = "([^"]+)"\n(.*?)(?=^state = |# END DMI)', description, re.M | re.S):
        name, props = match.groups()
        directions = int(re.search(r"dirs = (\d+)", props).group(1))
        frames = int(re.search(r"frames = (\d+)", props).group(1))
        pixels = []
        for index in range(cursor, cursor + directions * frames):
            x = index % (image.width // 32) * 32
            y = index // (image.width // 32) * 32
            pixels.append(image.crop((x, y, x + 32, y + 32)))
        states[name] = (directions, frames, pixels)
        cursor += directions * frames
    return states


def write_dmi(path, states):
    pixels = [frame for frames in states.values() for frame in frames]
    width = 8
    image = Image.new("RGBA", (32 * width, 32 * math.ceil(len(pixels) / width)))
    for index, frame in enumerate(pixels):
        image.paste(frame, ((index % width) * 32, (index // width) * 32))
    description = '# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n'
    for state, frames in states.items():
        assert len(frames) == 4
        description += f'state = "{state}"\n\tdirs = 4\n\tframes = 1\n'
    metadata = PngImagePlugin.PngInfo()
    metadata.add_text("Description", description + "# END DMI\n", zip=True)
    image.save(path, format="PNG", pnginfo=metadata)


def parse_types(paths, base):
    types = {}
    for path in paths:
        source = (SOURCE / path).read_text(encoding="utf-8")
        for match in re.finditer(r"^(/datum/[^\r\n]+)\n((?:\t[^\n]*\n|\n)*)", source, re.M):
            typepath, body = match.groups()
            if not (typepath == base or typepath.startswith(base + "/")):
                continue
            parent = typepath.rsplit("/", 1)[0]
            inherited = types.get(parent, {}).copy()
            for prop, value in re.findall(r'^\t(\w+) = (.+?)(?:\s+//.*)?$', body, re.M):
                inherited[prop] = value.strip()
            types[typepath] = inherited
    return types


limbs = parse_types(
    ["code/modules/surgery/organs/robolimbs.dm", "modular_ss220/robolimbs/code/robolimbs.dm"],
    "/datum/robolimb",
)
default_parts = ['head', 'chest', 'groin', 'l_arm', 'r_arm', 'l_hand', 'r_hand', 'l_leg', 'r_leg', 'l_foot', 'r_foot']
source_paths = set()
catalog = []
for typepath, definition in limbs.items():
    if typepath == "/datum/robolimb":
        continue
    source_path = definition["icon"].strip("'")
    source_paths.add(source_path)
    own_states = read_dmi(SOURCE / source_path)
    base_type = "/".join(typepath.split("/")[:4])
    base_states = read_dmi(SOURCE / limbs[base_type]["icon"].strip("'"))
    parts = re.findall(r'"([^"]+)"', definition.get("parts", "")) or default_parts
    states = {}
    part_map = {"head": ["head"], "chest": ["torso", "groin"], "l_arm": ["l_arm"], "r_arm": ["r_arm"],
                "l_hand": ["l_hand"], "r_hand": ["r_hand"], "l_leg": ["l_leg", "l_foot"], "r_leg": ["r_leg", "r_foot"]}
    for target_part, source_parts in part_map.items():
        frames = [Image.new("RGBA", (32, 32)) for _ in range(4)]
        for part in source_parts:
            state = own_states.get(part) or base_states.get(part)
            assert state, (source_path, part)
            directions, count, pixels = state
            assert directions == 4 and count == 1, (source_path, part, directions, count)
            for direction in range(4):
                frames[direction] = Image.alpha_composite(frames[direction], pixels[direction])
        states["ipc_" + target_part] = frames
    key = typepath.removeprefix("/datum/robolimb/").replace("/", "_")
    output_path = f"modular_bandastation/species/icons/ipc/{key}.dmi"
    write_dmi(TARGET / output_path, states)
    catalog.append((typepath, definition, key, output_path, parts))

copies = {
    "screens.dmi": "icons/mob/sprite_accessories/ipc/ipc_face.dmi",
    "antennae.dmi": "icons/mob/sprite_accessories/ipc/ipc_head_accessories.dmi",
    "optics.dmi": "icons/mob/sprite_accessories/ipc/ipc_optics.dmi",
    "etamin_optics.dmi": "modular_ss220/robolimbs/icons/ei_optic.dmi",
    "cybersun_optics.dmi": "modular_ss220/robolimbs/icons/cs_optics.dmi",
}
for target, source in copies.items():
    shutil.copyfile(SOURCE / source, DEST / target)
    source_paths.add(source)

dm = '''// Adapted from Paradise-SS220's robolimbs and IPC sprite accessories.
// Source revision and asset licenses: modular_bandastation/species/icons/ipc/attributions.txt.
GLOBAL_LIST_INIT(ipc_chassis, init_ipc_appearance_choices(/datum/ipc_chassis))
GLOBAL_LIST_INIT(ipc_displays, init_ipc_appearance_choices(/datum/sprite_accessory/ipc_display))
GLOBAL_LIST_INIT(ipc_antennae, init_ipc_appearance_choices(/datum/sprite_accessory/ipc_antenna))

/// Both preferences and in-round customization use these server-owned choices.
/proc/init_ipc_appearance_choices(base_type)
	var/list/choices = list()
	for(var/datum/sprite_accessory/choice_type as anything in subtypesof(base_type))
		var/datum/sprite_accessory/choice = new choice_type()
		if(isnull(choice.name))
			qdel(choice)
			continue
		choices[choice.name] = choice
	return choices

/datum/ipc_chassis
	parent_type = /datum/sprite_accessory
	var/has_body = TRUE
	var/has_head = TRUE
	var/is_monitor = FALSE

'''
for typepath, definition, key, output_path, parts in catalog:
    dm += f'/datum/ipc_chassis/{key}\n\tname = {definition["company"]}\n\ticon = \'{output_path}\'\n'
    if "chest" not in parts:
        dm += '\thas_body = FALSE\n'
    if "head" not in parts:
        dm += '\thas_head = FALSE\n'
    if definition.get("is_monitor") in ("TRUE", "1"):
        dm += '\tis_monitor = TRUE\n'
    dm += '\n'

dm += '''/datum/sprite_accessory/ipc_display
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	/// Heads that can use this screen or optic arrangement.
	var/list/models_allowed
	/// A separate foreground channel used by two-color screens.
	var/secondary_state

/datum/sprite_accessory/ipc_display/off
	name = "Выключен"
	icon_state = SPRITE_ACCESSORY_NONE

'''
for base, files in [
    ("/datum/sprite_accessory/hair/ipc", ["code/modules/mob/new_player/sprite_accessories/ipc/ipc_face.dm"]),
    ("/datum/sprite_accessory/body_markings/head/optics", ["code/modules/mob/new_player/sprite_accessories/ipc/ipc_optics.dm", "modular_ss220/robolimbs/code/robolimbs.dm"]),
]:
    for typepath, definition in parse_types(files, base).items():
        if "name" not in definition:
            continue
        key = typepath.removeprefix(base).strip("/").replace("/", "_") or "humanoid_optics"
        source_icon = definition["icon"].strip("'")
        output_icon = next(k for k, v in copies.items() if v == source_icon)
        icon_state = definition["icon_state"].strip('"')
        if icon_state == "blank":
            icon_state = "None"
        else:
            icon_state += "_s"
            assert icon_state in read_dmi(SOURCE / source_icon), (typepath, icon_state)
        dm += f'/datum/sprite_accessory/ipc_display/{key}\n\tname = {definition["name"]}\n'
        dm += f'\ticon = \'modular_bandastation/species/icons/ipc/{output_icon}\'\n\ticon_state = "{icon_state}"\n'
        dm += f'\tmodels_allowed = {definition["models_allowed"]}\n'
        if "secondary_theme" in definition:
            secondary = definition["icon_state"].strip('"') + "_" + definition["secondary_theme"].strip('"') + "_s"
            assert secondary in read_dmi(SOURCE / source_icon)
            dm += f'\tsecondary_state = "{secondary}"\n'
        dm += '\n'
dm += '''/datum/sprite_accessory/ipc_antenna
	icon = 'modular_bandastation/species/icons/ipc/antennae.dmi'

/datum/sprite_accessory/ipc_antenna/none
	name = "Нет"
	icon_state = SPRITE_ACCESSORY_NONE

'''
for typepath, definition in parse_types(["code/modules/mob/new_player/sprite_accessories/ipc/ipc_head_accessories.dm"], "/datum/sprite_accessory/head_accessory/ipc").items():
    if "name" not in definition:
        continue
    key = typepath.rsplit("/", 1)[-1]
    state = definition["icon_state"].strip('"') + "_s"
    dm += f'/datum/sprite_accessory/ipc_antenna/{key}\n\tname = {definition["name"]}\n\ticon_state = "{state}"\n\n'

output_code = TARGET / "modular_bandastation/species/code/human/sprite_accessories/ipc/ipc_appearance.dm"
output_code.parent.mkdir(parents=True, exist_ok=True)
output_code.write_text(dm.rstrip() + "\n", encoding="utf-8", newline="\n")

attribution = f'''IPC chassis and displays ported from Paradise-SS220.
Authors: ParadiseSS13/Paradise and ss220club/Paradise-SS220 contributors.
Source revision: {REVISION}
License: Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0).
https://creativecommons.org/licenses/by-sa/3.0/
Source license declaration:
https://github.com/ss220club/Paradise-SS220/blob/{REVISION}/README.md#licenses

Changes: limb states renamed for TG's ipc_* layout; torso and groin combined
into chest; each leg combined with its foot; original hands retained as separate
auxiliary overlays. Alternate models inherit missing pieces from the base model.
Screens, antennae and optics are unmodified copies with original DMI animation.

Original files (history and individual contributions are available at each URL):
'''
for path in sorted(source_paths):
    attribution += f"https://github.com/ss220club/Paradise-SS220/blob/{REVISION}/{path}\n"
(DEST / "attributions.txt").write_text(attribution, encoding="utf-8", newline="\n")
print(f"Converted {len(catalog)} chassis models; copied {len(copies)} accessory files.")
