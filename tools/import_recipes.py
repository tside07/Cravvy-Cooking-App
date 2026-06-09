#!/usr/bin/env python3
"""
Import recipes into Supabase `recipes` table (idempotent upsert on source + source_id).

Usage:
  pip install -r tools/requirements.txt
  cp tools/.env.example tools/.env   # fill SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY

  python tools/generate_vn_seed.py
  python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json

  # Hugging Face CSV (recipes-with-nutrition style):
  python tools/import_recipes.py --hf-csv path/to/recipes.csv --limit 500 --source huggingface_recipes_nutrition

  python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json --dry-run
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import unicodedata
from pathlib import Path
from typing import Any

from dotenv import load_dotenv
from supabase import Client, create_client

ROOT = Path(__file__).resolve().parents[1]
VALID_MEAL_TYPES = {"breakfast", "lunch", "dinner", "snack"}
VALID_DIFFICULTY = {"easy", "medium", "hard"}
BATCH_SIZE = 40


def slugify(name: str) -> str:
    s = unicodedata.normalize("NFD", name)
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    s = s.lower().encode("ascii", "ignore").decode("ascii")
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s[:120] or "recipe"


def clamp_int(val: Any, default: int, lo: int, hi: int) -> int:
    try:
        n = int(float(val))
        return max(lo, min(hi, n))
    except (TypeError, ValueError):
        return default


def infer_meal_type(row: dict[str, Any], title: str) -> str:
    for key in ("meal_type", "MealType", "mealType", "type"):
        raw = row.get(key)
        if raw and str(raw).lower() in VALID_MEAL_TYPES:
            return str(raw).lower()
    t = title.lower()
    if any(x in t for x in ("breakfast", "pancake", "oat", "cereal", "smoothie", "phở", "pho", "cháo", "chao")):
        return "breakfast"
    if any(x in t for x in ("snack", "dessert", "cookie", "chè", "cake", "bar ")):
        return "snack"
    if any(x in t for x in ("dinner", "steak", "roast", "lẩu", "hot pot")):
        return "dinner"
    return "lunch"


def infer_difficulty(prep_time: int) -> str:
    if prep_time <= 20:
        return "easy"
    if prep_time <= 45:
        return "medium"
    return "hard"


def normalize_recipe(raw: dict[str, Any], default_source: str | None = None) -> dict[str, Any]:
    name = (raw.get("name") or raw.get("title") or "").strip()
    if not name:
        raise ValueError("Recipe missing name/title")

    meal_type = str(raw.get("meal_type", "lunch")).lower()
    if meal_type not in VALID_MEAL_TYPES:
        meal_type = "lunch"

    difficulty = str(raw.get("difficulty", "easy")).lower()
    if difficulty not in VALID_DIFFICULTY:
        difficulty = infer_difficulty(clamp_int(raw.get("prep_time"), 25, 5, 180))

    tags = raw.get("tags") or []
    if isinstance(tags, str):
        tags = [t.strip() for t in tags.split(",") if t.strip()]

    steps = raw.get("steps") or raw.get("instructions") or []
    if isinstance(steps, str):
        steps = [s.strip() for s in re.split(r"\n+|\.\s+", steps) if s.strip()][:12]
    if isinstance(steps, list):
        steps = [str(s).strip() for s in steps if str(s).strip()][:12]

    ingredients = raw.get("ingredients") or []
    if isinstance(ingredients, str):
        ingredients = [i.strip() for i in ingredients.split(",") if i.strip()]
    if isinstance(ingredients, list):
        ingredients = [str(i).strip() for i in ingredients if str(i).strip()][:30]

    source = raw.get("source") or default_source or "import"
    source_id = raw.get("source_id") or slugify(name)

    row = {
        "name": name[:200],
        "description": (raw.get("description") or raw.get("desc") or "")[:500] or None,
        "image_url": raw.get("image_url") or raw.get("image") or None,
        "calories": clamp_int(raw.get("calories"), 400, 80, 1200),
        "protein": clamp_int(raw.get("protein"), 20, 0, 80),
        "carbs": clamp_int(raw.get("carbs"), 45, 0, 150),
        "fat": clamp_int(raw.get("fat"), 12, 0, 80),
        "prep_time": clamp_int(raw.get("prep_time"), 30, 5, 180),
        "difficulty": difficulty,
        "meal_type": meal_type,
        "tags": tags[:15],
        "steps": steps if steps else [f"Chuẩn bị và nấu {name} theo công thức chuẩn."],
        "ingredients": ingredients,
        "source": source,
        "source_id": str(source_id)[:120],
        "locale": raw.get("locale") or "vi",
        "is_active": raw.get("is_active", True) is not False,
    }
    return row


def load_json(path: Path) -> list[dict[str, Any]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(data, list):
        return data
    if isinstance(data, dict) and "recipes" in data:
        return data["recipes"]
    raise ValueError("JSON must be a list or { recipes: [...] }")


def load_hf_csv(path: Path, limit: int, source: str) -> list[dict[str, Any]]:
    """Map common columns from datahiveai/recipes-with-nutrition CSV exports."""
    out: list[dict[str, Any]] = []
    with path.open(encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader):
            if limit and i >= limit:
                break
            title = (
                row.get("title")
                or row.get("Title")
                or row.get("recipe_title")
                or row.get("name")
                or ""
            ).strip()
            if not title:
                continue

            instructions = row.get("instructions") or row.get("directions") or row.get("steps") or ""
            steps: list[str] = []
            if instructions:
                steps = [s.strip() for s in re.split(r"\n+", instructions) if s.strip()][:10]

            cuisine = (row.get("cuisine") or row.get("cuisine_type") or "").strip()
            tags = ["imported"]
            if cuisine:
                tags.append(cuisine.lower().replace(" ", "-"))

            out.append(
                normalize_recipe(
                    {
                        "name": title,
                        "description": (row.get("description") or "")[:500],
                        "calories": row.get("calories") or row.get("Calories"),
                        "protein": row.get("protein") or row.get("Protein"),
                        "carbs": row.get("carbs") or row.get("Carbohydrates") or row.get("carbohydrates"),
                        "fat": row.get("fat") or row.get("Fat"),
                        "prep_time": row.get("prep_time") or row.get("minutes") or row.get("total_time"),
                        "meal_type": infer_meal_type(row, title),
                        "tags": tags,
                        "steps": steps,
                        "source": source,
                        "source_id": row.get("id") or row.get("recipe_id") or slugify(title),
                        "locale": "en",
                    },
                    default_source=source,
                )
            )
    return out


def _validate_supabase_env(url: str | None, key: str | None) -> None:
    if not url or not key:
        print(
            "Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in tools/.env\n"
            "(copy from tools/.env.example, then paste values from Supabase Dashboard).",
            file=sys.stderr,
        )
        sys.exit(1)
    url = url.strip()
    if "YOUR_PROJECT" in url or "your_project" in url.lower():
        print(
            "SUPABASE_URL is still the example placeholder.\n"
            "Fix tools/.env → Project Settings → API → Project URL\n"
            "Example: https://abcdefghijklmnop.supabase.co",
            file=sys.stderr,
        )
        sys.exit(1)
    if key.strip() in ("your_service_role_key_here", "", "YOUR_KEY"):
        print(
            "SUPABASE_SERVICE_ROLE_KEY is still the example placeholder.\n"
            "Fix tools/.env → Project Settings → API → service_role (secret).\n"
            "Do NOT use the anon key for import.",
            file=sys.stderr,
        )
        sys.exit(1)
    if not url.startswith("https://") or ".supabase.co" not in url:
        print(f"SUPABASE_URL looks invalid: {url[:80]}", file=sys.stderr)
        sys.exit(1)


def get_client() -> Client:
    load_dotenv(ROOT / "tools" / ".env")
    load_dotenv(ROOT / ".env")
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    _validate_supabase_env(url, key)
    try:
        return create_client(url.strip(), key.strip())  # type: ignore[arg-type]
    except Exception as e:
        print(f"Cannot create Supabase client: {e}", file=sys.stderr)
        sys.exit(1)


def upsert_batch(client: Client, rows: list[dict[str, Any]], dry_run: bool) -> int:
    if dry_run:
        return len(rows)
    # Requires migration recipes_source_source_id_key
    client.table("recipes").upsert(rows, on_conflict="source,source_id").execute()
    return len(rows)


def main() -> None:
    parser = argparse.ArgumentParser(description="Import recipes to Supabase")
    parser.add_argument("--file", type=Path, help="JSON seed file")
    parser.add_argument("--hf-csv", type=Path, help="Hugging Face / external CSV")
    parser.add_argument("--limit", type=int, default=0, help="Max rows for CSV")
    parser.add_argument(
        "--source",
        default="huggingface_recipes_nutrition",
        help="source column for CSV imports",
    )
    parser.add_argument("--dry-run", action="store_true", help="Validate only, no DB write")
    args = parser.parse_args()

    if not args.file and not args.hf_csv:
        parser.error("Provide --file or --hf-csv")

    recipes: list[dict[str, Any]] = []
    default_source = None

    if args.file:
        default_source = None
        raw_list = load_json(args.file)
        recipes = [normalize_recipe(r) for r in raw_list]
    elif args.hf_csv:
        recipes = load_hf_csv(args.hf_csv, args.limit, args.source)

    # Validate
    errors = 0
    for r in recipes:
        try:
            if r["meal_type"] not in VALID_MEAL_TYPES:
                raise ValueError("bad meal_type")
        except Exception as e:
            print(f"Skip invalid: {r.get('name')}: {e}")
            errors += 1
    recipes = [r for r in recipes if r.get("name")]

    print(f"Prepared {len(recipes)} recipes ({errors} skipped)")

    if args.dry_run:
        by_type: dict[str, int] = {}
        for r in recipes:
            by_type[r["meal_type"]] = by_type.get(r["meal_type"], 0) + 1
        print("By meal_type:", by_type)
        print("Dry run — no database writes.")
        return

    client = get_client()
    host = os.environ.get("SUPABASE_URL", "").replace("https://", "").split("/")[0]
    print(f"Connecting to {host} ...")
    total = 0
    try:
        for i in range(0, len(recipes), BATCH_SIZE):
            batch = recipes[i : i + BATCH_SIZE]
            n = upsert_batch(client, batch, dry_run=False)
            total += n
            print(f"Upserted {total}/{len(recipes)}")
    except Exception as e:
        err = str(e).lower()
        if "getaddrinfo" in err or "connect" in err:
            print(
                "\nNetwork/DNS error — cannot reach Supabase.\n"
                "1) Check internet / VPN\n"
                "2) Fix SUPABASE_URL in tools/.env (real project URL, not YOUR_PROJECT)\n"
                "3) Open the URL in a browser to confirm it loads",
                file=sys.stderr,
            )
        elif "42p10" in err or "on conflict" in err:
            print(
                "\nDatabase missing UNIQUE (source, source_id) on table recipes.\n"
                "Run migration in Supabase SQL Editor:\n"
                "  supabase/migrations/20260522120000_recipes_provenance.sql\n"
                "Then run import again.",
                file=sys.stderr,
            )
        raise
    print("Done.")


if __name__ == "__main__":
    main()
