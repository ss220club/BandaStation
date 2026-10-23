# IPC asset conversion

`convert_assets.py` reproducibly adapts the public IPC chassis and display assets
from [Paradise-SS220](https://github.com/ss220club/Paradise-SS220/tree/0fffca1f1f29a63aff49d9b56524813eedf82c6d)
at revision `0fffca1f1f29a63aff49d9b56524813eedf82c6d` to TG's bodypart layout.
It requires Python 3.11+, Pillow, Git, and a checkout of that exact source revision.
The target repository's `tools/requirements.txt` supplies Pillow.

From the BandaStation repository root:

```sh
python tools/ipc/convert_assets.py --source ../Paradise-SS220
```

The script regenerates:

- `modular_bandastation/species/icons/ipc/`: 26 chassis DMIs, five unchanged
  accessory DMIs, and `attributions.txt` with pinned source paths and license.
- `modular_bandastation/species/code/human/sprite_accessories/ipc/ipc_appearance.dm`:
  server-side model, screen, optic, and antenna catalogs.

The torso and groin become one chest, and each foot is merged into its leg. Hands
remain separate sprite states used by TG's auxiliary hand overlays. Missing
pieces of head-only and heavy variants inherit from their manufacturer base.
Screen, optic, and antenna animations are copied without modification.

Only the normal `robolimbs` and IPC accessory definitions are imported. Personal
screen maps, private hairstyles, whitelist settings, and donor assets are not
read. Morpheus is retained as the default body because the source's machine
external organs use it by default; its `unavailable_at_chargen` flag applies to
the ordinary prosthetic manufacturer picker.

After regeneration, run the `ipc_appearance_assets` and
`ipc_appearance_screenshots` DM unit tests. Review screenshot changes before
accepting any new baselines.
