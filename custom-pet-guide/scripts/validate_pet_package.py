#!/usr/bin/env python3
"""Validate a Codex pet package, including scale and motion quality gates."""

from __future__ import annotations

import argparse
import json
import statistics
from pathlib import Path

from PIL import Image, ImageChops


CELL_WIDTH = 192
CELL_HEIGHT = 208
USED_COLUMNS = (6, 8, 8, 4, 5, 8, 6, 6, 6, 8, 8)
EXPECTED_SIZE = (1536, 2288)


def visible_height(cell: Image.Image) -> int:
    bbox = cell.getchannel("A").getbbox()
    return 0 if bbox is None else bbox[3] - bbox[1]


def cell_at(atlas: Image.Image, row: int, column: int) -> Image.Image:
    return atlas.crop((column * CELL_WIDTH, row * CELL_HEIGHT,
                       (column + 1) * CELL_WIDTH, (row + 1) * CELL_HEIGHT))


def validate_package(package_dir: Path, *, max_scale_deviation: float = 0.08,
                     minimum_motion_ratio: float = 0.002) -> dict[str, object]:
    """Validate metadata, atlas structure, scale, and frame variation."""
    errors: list[str] = []
    warnings: list[str] = []
    pet_path = package_dir / "pet.json"
    if not pet_path.is_file():
        return {"ok": False, "errors": ["pet.json is missing"], "warnings": []}
    try:
        pet = json.loads(pet_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return {"ok": False, "errors": [f"pet.json is invalid: {exc}"], "warnings": []}

    required = ("id", "displayName", "description", "spriteVersionNumber", "spritesheetPath")
    for key in required:
        if key not in pet:
            errors.append(f"pet.json missing key: {key}")
    if pet.get("spriteVersionNumber") != 2:
        errors.append("spriteVersionNumber must be 2")
    sheet_name = pet.get("spritesheetPath", "spritesheet.webp")
    sheet_path = package_dir / str(sheet_name)
    if not sheet_path.is_file():
        errors.append(f"spritesheet is missing: {sheet_name}")
        return {"ok": False, "errors": errors, "warnings": warnings}

    with Image.open(sheet_path) as opened:
        source_mode = opened.mode
        atlas = opened.convert("RGBA")
    if atlas.size != EXPECTED_SIZE:
        errors.append(f"atlas size must be 1536x2288, got {atlas.width}x{atlas.height}")
    if source_mode != "RGBA":
        warnings.append(f"source image mode is {source_mode}; RGBA is preferred")

    transparent_residue = sum(
        1 for red, green, blue, alpha in atlas.get_flattened_data()
        if alpha == 0 and (red or green or blue)
    )
    if transparent_residue:
        errors.append(f"transparent RGB residue pixels: {transparent_residue}")

    row_medians: list[float] = []
    motion_ratios: dict[str, list[float]] = {}
    for row, used_columns in enumerate(USED_COLUMNS):
        heights: list[int] = []
        cells: list[Image.Image] = []
        for column in range(8):
            cell = cell_at(atlas, row, column)
            special_neutral = row == 0 and column == 6
            if column < used_columns or special_neutral:
                height = visible_height(cell)
                if height == 0:
                    errors.append(f"used cell r{row}c{column} is empty")
                elif column < used_columns:
                    heights.append(height)
                    cells.append(cell)
            elif cell.getchannel("A").getbbox() is not None:
                errors.append(f"unused cell r{row}c{column} is not empty")
        row_medians.append(float(statistics.median(heights)) if heights else 0.0)

        if row <= 8:
            ratios: list[float] = []
            for index, (first, second) in enumerate(zip(cells, cells[1:])):
                difference = ImageChops.difference(first, second)
                changed = sum(1 for pixel in difference.get_flattened_data()
                              if pixel != (0, 0, 0, 0))
                ratio = changed / (CELL_WIDTH * CELL_HEIGHT)
                ratios.append(ratio)
                if ratio < minimum_motion_ratio:
                    errors.append(
                        f"frames r{row}c{index} and r{row}c{index + 1} are effectively static"
                    )
            motion_ratios[f"row_{row}"] = ratios

    reference = row_medians[0]
    scale_deviations: list[float] = []
    for row in range(9):
        deviation = 1.0 if reference <= 0 else abs(row_medians[row] - reference) / reference
        scale_deviations.append(deviation)
        if deviation > max_scale_deviation:
            errors.append(
                f"row {row} scale deviation {deviation:.1%} exceeds {max_scale_deviation:.1%}"
            )

    return {
        "ok": not errors,
        "package": str(package_dir),
        "atlas": str(sheet_path),
        "size": list(atlas.size),
        "row_median_visible_heights": row_medians,
        "row_scale_deviations": scale_deviations,
        "motion_change_ratios": motion_ratios,
        "transparent_rgb_residue_pixels": transparent_residue,
        "errors": errors,
        "warnings": warnings,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("package_dir", type=Path)
    parser.add_argument("--max-scale-deviation", type=float, default=0.08)
    parser.add_argument("--minimum-motion-ratio", type=float, default=0.002)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    report = validate_package(args.package_dir,
                              max_scale_deviation=args.max_scale_deviation,
                              minimum_motion_ratio=args.minimum_motion_ratio)
    output = json.dumps(report, ensure_ascii=False, indent=2)
    print(output)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(output + "\n", encoding="utf-8")
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
