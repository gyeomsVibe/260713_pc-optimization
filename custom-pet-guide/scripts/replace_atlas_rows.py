#!/usr/bin/env python3
"""Replace complete animation rows in a Codex pet atlas without touching others."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image


CELL_WIDTH = 192
CELL_HEIGHT = 208
STATE_ROWS = {
    "idle": (0, 6),
    "running-right": (1, 8),
    "running-left": (2, 8),
    "waving": (3, 4),
    "jumping": (4, 5),
    "failed": (5, 8),
    "waiting": (6, 6),
    "running": (7, 6),
    "review": (8, 6),
}


def parse_replacement(value: str) -> tuple[str, Path]:
    """Parse STATE=FRAME_DIRECTORY."""

    if "=" not in value:
        raise argparse.ArgumentTypeError("replacement must be STATE=FRAME_DIRECTORY")
    state, path = value.split("=", 1)
    if state not in STATE_ROWS:
        raise argparse.ArgumentTypeError(f"unsupported state: {state}")
    return state, Path(path)


def replace_rows(
    source: Path,
    output: Path,
    replacements: list[tuple[str, Path]],
    report_path: Path,
) -> dict[str, object]:
    """Copy validated 192x208 frame cells into selected standard rows."""

    atlas = Image.open(source).convert("RGBA")
    if atlas.width != CELL_WIDTH * 8 or atlas.height != CELL_HEIGHT * 11:
        raise ValueError(
            f"expected a 1536x2288 v2 atlas, got {atlas.width}x{atlas.height}"
        )

    row_reports: list[dict[str, object]] = []
    for state, frame_dir in replacements:
        row, expected = STATE_ROWS[state]
        frames = sorted(frame_dir.glob("[0-9][0-9].png"))
        if len(frames) != expected:
            raise ValueError(
                f"{state} requires {expected} frames, found {len(frames)} in {frame_dir}"
            )
        for column, frame_path in enumerate(frames):
            frame = Image.open(frame_path).convert("RGBA")
            if frame.size != (CELL_WIDTH, CELL_HEIGHT):
                raise ValueError(f"{frame_path} must be 192x208, got {frame.size}")
            if frame.getchannel("A").getbbox() is None:
                raise ValueError(f"{frame_path} is fully transparent")
            atlas.paste(frame, (column * CELL_WIDTH, row * CELL_HEIGHT))
        clear_from = 7 if row == 0 else expected
        for column in range(clear_from, 8):
            atlas.paste(
                Image.new("RGBA", (CELL_WIDTH, CELL_HEIGHT), (0, 0, 0, 0)),
                (column * CELL_WIDTH, row * CELL_HEIGHT),
            )
        row_reports.append(
            {
                "state": state,
                "row": row,
                "frame_count": expected,
                "frames_directory": str(frame_dir),
            }
        )

    output.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(output)
    report = {
        "ok": True,
        "source": str(source),
        "output": str(output),
        "replacements": row_reports,
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return report


def main() -> None:
    """Run the command-line row replacement."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument(
        "--replace", type=parse_replacement, action="append", required=True
    )
    args = parser.parse_args()
    report = replace_rows(args.source, args.output, args.replace, args.report)
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
