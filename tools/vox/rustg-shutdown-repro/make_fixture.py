"""Create one fresh 32x32 DMI state; no station or Vox assets are inputs."""
import sys
from pathlib import Path
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[3]))
from tools.dmi import Dmi

icon = Dmi(32, 32)
state = icon.state("probe", dirs=4)
for colour in ("red", "green", "blue", "yellow"):
    state.frame(Image.new("RGBA", (32, 32), colour))
icon.to_file(sys.argv[1])
