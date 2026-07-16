from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image, ImageDraw

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from validate_pet_package import CELL_HEIGHT, CELL_WIDTH, USED_COLUMNS, validate_package


class PetPackageValidationTests(unittest.TestCase):
    def make_package(self, root: Path, bad_scale_row: int | None = None) -> Path:
        package = root / "sample-pet"
        package.mkdir()
        atlas = Image.new("RGBA", (CELL_WIDTH * 8, CELL_HEIGHT * 11), (0, 0, 0, 0))
        draw = ImageDraw.Draw(atlas)
        for row, used in enumerate(USED_COLUMNS):
            height = 80 if row == bad_scale_row else 160
            drawn_columns = used + 1 if row == 0 else used
            for column in range(drawn_columns):
                left = column * CELL_WIDTH + 45 + column
                top = row * CELL_HEIGHT + (CELL_HEIGHT - height) // 2
                draw.rectangle((left, top, left + 70, top + height - 1),
                               fill=(40 + column, 60, 80, 255))
        atlas.save(package / "spritesheet.webp", format="WEBP", lossless=True)
        metadata = {
            "id": "sample-pet", "displayName": "Sample Pet",
            "description": "Validation fixture", "spriteVersionNumber": 2,
            "spritesheetPath": "spritesheet.webp",
        }
        (package / "pet.json").write_text(json.dumps(metadata), encoding="utf-8")
        return package

    def test_valid_package_passes(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            report = validate_package(self.make_package(Path(temp)))
        self.assertTrue(report["ok"], report["errors"])

    def test_scale_drift_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            report = validate_package(self.make_package(Path(temp), bad_scale_row=4))
        self.assertFalse(report["ok"])
        self.assertTrue(any("scale deviation" in error for error in report["errors"]))


if __name__ == "__main__":
    unittest.main()
