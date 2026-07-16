#!/usr/bin/env python3
"""Normalize apparent character scale per animation row in a Codex pet atlas."""

from __future__ import annotations

import argparse
import json
import statistics
from pathlib import Path

from PIL import Image


CELL_WIDTH = 192
CELL_HEIGHT = 208
USED_COLUMNS = (6, 8, 8, 4, 5, 8, 6, 6, 6, 8, 8)


def alpha_bbox(cell: Image.Image) -> tuple[int, int, int, int] | None:
    """Return the visible alpha bounds for one cell."""

    return cell.getchannel("A").getbbox()


def row_median_height(atlas: Image.Image, row: int) -> float:
    """Measure the median visible height of used cells in a row."""

    heights: list[int] = []
    for column in range(USED_COLUMNS[row]):
        cell = atlas.crop(
            (
                column * CELL_WIDTH,
                row * CELL_HEIGHT,
                (column + 1) * CELL_WIDTH,
                (row + 1) * CELL_HEIGHT,
            )
        )
        bbox = alpha_bbox(cell)
        if bbox is not None:
            heights.append(bbox[3] - bbox[1])
    if not heights:
        raise ValueError(f"row {row} has no visible used cells")
    return float(statistics.median(heights))


def normalize_row(
    atlas: Image.Image,
    row: int,
    scale: float,
    margin: int,
) -> tuple[Image.Image, list[dict[str, object]]]:
    """Apply one shared scale to every used cell while preserving its center."""

    result = atlas.copy()
    cells: list[dict[str, object]] = []
    for column in range(USED_COLUMNS[row]):
        box = (
            column * CELL_WIDTH,
            row * CELL_HEIGHT,
            (column + 1) * CELL_WIDTH,
            (row + 1) * CELL_HEIGHT,
        )
        cell = atlas.crop(box)
        bbox = alpha_bbox(cell)
        if bbox is None:
            cells.append({"column": column, "status": "empty"})
            continue

        sprite = cell.crop(bbox)
        effective_scale = min(
            scale,
            (CELL_WIDTH - 2 * margin) / sprite.width,
            (CELL_HEIGHT - 2 * margin) / sprite.height,
        )
        new_size = (
            max(1, round(sprite.width * effective_scale)),
            max(1, round(sprite.height * effective_scale)),
        )
        sprite = sprite.resize(new_size, Image.Resampling.LANCZOS)

        center_x = (bbox[0] + bbox[2]) / 2
        center_y = (bbox[1] + bbox[3]) / 2
        left = round(center_x - sprite.width / 2)
        top = round(center_y - sprite.height / 2)
        left = min(max(margin, left), CELL_WIDTH - margin - sprite.width)
        top = min(max(margin, top), CELL_HEIGHT - margin - sprite.height)

        normalized = Image.new("RGBA", (CELL_WIDTH, CELL_HEIGHT), (0, 0, 0, 0))
        normalized.alpha_composite(sprite, (left, top))
        result.paste(normalized, (box[0], box[1]))
        cells.append(
            {
                "column": column,
                "status": "normalized",
                "source_bbox": list(bbox),
                "requested_scale": round(scale, 6),
                "effective_scale": round(effective_scale, 6),
                "output_position": [left, top],
                "output_size": list(new_size),
            }
        )
    return result, cells


def normalize_atlas(
    source: Path,
    output: Path,
    report_path: Path,
    reference_row: int = 0,
    rows: tuple[int, ...] = tuple(range(9)),
    margin: int = 5,
) -> dict[str, object]:
    """Normalize selected rows to the reference row's median visible height."""

    atlas = Image.open(source).convert("RGBA")
    if atlas.width != CELL_WIDTH * 8 or atlas.height not in {
        CELL_HEIGHT * 9,
        CELL_HEIGHT * 11,
    }:
        raise ValueError(
            f"expected 1536x1872 or 1536x2288 atlas, got {atlas.width}x{atlas.height}"
        )

    max_row = atlas.height // CELL_HEIGHT - 1
    if reference_row > max_row or any(row > max_row for row in rows):
        raise ValueError("requested row is outside the source atlas")

    before = {row: row_median_height(atlas, row) for row in rows}
    target = row_median_height(atlas, reference_row)
    result = atlas
    row_reports: list[dict[str, object]] = []
    for row in rows:
        requested_scale = target / before[row]
        result, cells = normalize_row(result, row, requested_scale, margin)
        after_height = row_median_height(result, row)
        row_reports.append(
            {
                "row": row,
                "before_median_height": before[row],
                "target_median_height": target,
                "requested_scale": round(requested_scale, 6),
                "after_median_height": after_height,
                "deviation_ratio": round(abs(after_height - target) / target, 6),
                "cells": cells,
            }
        )

    output.parent.mkdir(parents=True, exist_ok=True)
    result.save(output)
    report = {
        "ok": all(item["deviation_ratio"] <= 0.08 for item in row_reports),
        "source": str(source),
        "output": str(output),
        "reference_row": reference_row,
        "target_median_height": target,
        "margin": margin,
        "rows": row_reports,
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return report


def parse_rows(value: str) -> tuple[int, ...]:
    """Parse a comma-separated row list."""

    rows = tuple(dict.fromkeys(int(item.strip()) for item in value.split(",")))
    if not rows or any(row < 0 or row >= len(USED_COLUMNS) for row in rows):
        raise argparse.ArgumentTypeError("rows must be integers from 0 through 10")
    return rows


def main() -> None:
    """Run the command-line scale normalizer."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument("--reference-row", type=int, default=0)
    parser.add_argument("--rows", type=parse_rows, default=tuple(range(9)))
    parser.add_argument("--margin", type=int, default=5)
    args = parser.parse_args()
    report = normalize_atlas(
        args.source,
        args.output,
        args.report,
        args.reference_row,
        args.rows,
        args.margin,
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))
    raise SystemExit(0 if report["ok"] else 1)


if __name__ == "__main__":
    main()
