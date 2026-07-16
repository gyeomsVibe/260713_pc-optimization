#!/usr/bin/env python3
"""Clear cells that are unused by the Codex v2 animation contract."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


CELL_WIDTH = 192
CELL_HEIGHT = 208
USED_COLUMNS = (7, 8, 8, 4, 5, 8, 6, 6, 6, 8, 8)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--webp-output", type=Path)
    args = parser.parse_args()

    with Image.open(args.input) as opened:
        atlas = opened.convert("RGBA")
    if atlas.size != (1536, 2288):
        raise SystemExit(f"expected 1536x2288, got {atlas.width}x{atlas.height}")

    transparent = Image.new("RGBA", (CELL_WIDTH, CELL_HEIGHT), (0, 0, 0, 0))
    for row, used in enumerate(USED_COLUMNS):
        for column in range(used, 8):
            atlas.paste(transparent, (column * CELL_WIDTH, row * CELL_HEIGHT))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(args.output, format="PNG")
    if args.webp_output:
        args.webp_output.parent.mkdir(parents=True, exist_ok=True)
        atlas.save(args.webp_output, format="WEBP", lossless=True, quality=100, method=6)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
