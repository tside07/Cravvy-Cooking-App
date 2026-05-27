#!/usr/bin/env python3
"""
Validate data/seeds/vietnamese_recipes.json before Supabase import.

Usage:
  python tools/generate_vn_seed.py
  python tools/validate_seed.py
  python tools/validate_seed.py --file path/to/custom.json

Exit code 0 = pass, 1 = validation errors.
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_FILE = ROOT / "data" / "seeds" / "vietnamese_recipes.json"
EXPECTED_SOURCE = "cravvy_curated_vn"
VALID_MEAL_TYPES = {"breakfast", "lunch", "dinner", "snack"}
VALID_DIFFICULTY = {"easy", "medium", "hard"}
MIN_RECIPES = 80
TARGET_RECIPES = 100


def load_recipes(path: Path) -> list[dict]:
    if not path.is_file():
        print(f"ERROR: File not found: {path}", file=sys.stderr)
        print("Run: python tools/generate_vn_seed.py", file=sys.stderr)
        sys.exit(1)

    data = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(data, list):
        return data
    if isinstance(data, dict) and "recipes" in data:
        return data["recipes"]
    raise ValueError("JSON must be a list or { recipes: [...] }")


def validate(recipes: list[dict]) -> list[str]:
    errors: list[str] = []
    warnings: list[str] = []

    if len(recipes) < MIN_RECIPES:
        errors.append(f"Too few recipes: {len(recipes)} (min {MIN_RECIPES})")
    elif len(recipes) < TARGET_RECIPES:
        warnings.append(
            f"Recipe count {len(recipes)} < target {TARGET_RECIPES} (still OK if >= {MIN_RECIPES})"
        )

    seen_source_ids: set[str] = set()
    meal_counts: Counter[str] = Counter()

    for i, r in enumerate(recipes):
        prefix = f"recipe[{i}]"
        name = (r.get("name") or "").strip()
        if not name:
            errors.append(f"{prefix}: missing name")
            continue

        meal = str(r.get("meal_type", "")).lower()
        if meal not in VALID_MEAL_TYPES:
            errors.append(f"{prefix} '{name}': invalid meal_type '{meal}'")
        else:
            meal_counts[meal] += 1

        diff = str(r.get("difficulty", "easy")).lower()
        if diff not in VALID_DIFFICULTY:
            errors.append(f"{prefix} '{name}': invalid difficulty '{diff}'")

        source = r.get("source")
        if source != EXPECTED_SOURCE:
            errors.append(
                f"{prefix} '{name}': source must be '{EXPECTED_SOURCE}', got '{source}'"
            )

        sid = str(r.get("source_id") or "").strip()
        if not sid:
            errors.append(f"{prefix} '{name}': missing source_id")
        elif sid in seen_source_ids:
            errors.append(f"{prefix} '{name}': duplicate source_id '{sid}'")
        else:
            seen_source_ids.add(sid)

        for field in ("calories", "protein", "carbs", "fat", "prep_time"):
            val = r.get(field)
            if val is None:
                errors.append(f"{prefix} '{name}': missing {field}")
            elif not isinstance(val, (int, float)) or val < 0:
                errors.append(f"{prefix} '{name}': invalid {field}={val!r}")

        steps = r.get("steps") or []
        if not isinstance(steps, list) or len(steps) < 1:
            errors.append(f"{prefix} '{name}': steps must be non-empty list")

        tags = r.get("tags") or []
        if not isinstance(tags, list):
            errors.append(f"{prefix} '{name}': tags must be a list")

    for mt in VALID_MEAL_TYPES:
        if meal_counts[mt] < 5:
            warnings.append(f"Low count for meal_type '{mt}': {meal_counts[mt]}")

    for w in warnings:
        print(f"WARN: {w}")

    return errors


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate Vietnamese recipe seed JSON")
    parser.add_argument("--file", type=Path, default=DEFAULT_FILE)
    args = parser.parse_args()

    recipes = load_recipes(args.file)
    print(f"Validating {len(recipes)} recipes from {args.file}")

    errors = validate(recipes)
    if errors:
        print(f"\nFAILED with {len(errors)} error(s):", file=sys.stderr)
        for e in errors[:30]:
            print(f"  - {e}", file=sys.stderr)
        if len(errors) > 30:
            print(f"  ... and {len(errors) - 30} more", file=sys.stderr)
        sys.exit(1)

    by_meal: Counter[str] = Counter(r["meal_type"] for r in recipes)
    print("PASS")
    print("By meal_type:", dict(by_meal))
    print(f"Unique source_ids: {len({r['source_id'] for r in recipes})}")
    sys.exit(0)


if __name__ == "__main__":
    main()
