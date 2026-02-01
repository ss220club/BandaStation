import sys
import os
import re

def flip_dir(match):
    # extract dir x
    full_match = match.group(0)
    try:
        val = int(match.group(1))
        if val == 4: return "dir = 8"
        if val == 8: return "dir = 4"
        # NE, NW, SE, SW bitmask combine
        new_dir = val
        if val & 4: new_dir = (new_dir & ~4) | 8
        elif val & 8: new_dir = (new_dir & ~8) | 4
        return f"dir = {new_dir}"
    except:
        return full_match

def flip_path(match):
    path = match.group(0)
    if "/east" in path: return path.replace("/east", "/west")
    if "/west" in path: return path.replace("/west", "/east")
    return path

def main():
    if len(sys.argv) < 2:
        print("Drag .dmm file!")
        return

    input_path = sys.argv[1]
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()

    print("Flipping (dir)...")
    content = re.sub(r'dir\s*=\s*(\d+)', flip_dir, content)

    print("Flipping (directional)...")
    content = re.sub(r'/[^\s,}]*(?:east|west)[^\s,}]*', flip_path, content)

    print("Flipping grid...")
    # the grid is just a vec3, gotta find x first for a mirror remap (max_x - x + 1)
    coords = re.findall(r'\((\d+),(\d+),(\d+)\)', content)
    if not coords:
        print("Wrong coords!")
        return

    max_x = max(int(c[0]) for c in coords)

    def flip_coord(match):
        x = int(match.group(1))
        y = int(match.group(2))
        z = int(match.group(3))
        new_x = max_x - x + 1 # mirror
        return f"({new_x},{y},{z})"

    content = re.sub(r'\((\d+),(\d+),(\d+)\)', flip_coord, content)

    output_path = input_path.replace(".dmm", "_flipped.dmm")
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Done! Max width: {max_x}")
    print(f"Output: {output_path}")

if __name__ == "__main__":
    main()
