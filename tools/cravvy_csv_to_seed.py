#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Convert Cravvy_FoodDB_All.csv -> seed JSON cho pipeline import có sẵn.

Đầu ra dùng CHUNG định dạng với data/seeds/vietnamese_recipes.json, nên chạy được
ngay với validate_seed.py + import_recipes.py:

    python tools/cravvy_csv_to_seed.py Cravvy_FoodDB_All.csv
    python tools/validate_seed.py --file data/seeds/cravvy_curated_159.json
    python tools/import_recipes.py --file data/seeds/cravvy_curated_159.json --dry-run
    python tools/import_recipes.py --file data/seeds/cravvy_curated_159.json

Phạm vi: chỉ 159 món APPROVED có công thức (bỏ nhóm 05_72_Mon_Cu).
- source = 'cravvy_curated_vn', locale = 'vi', is_active = False (staging).
- tags = gộp tag_diet + tag_allergy + tag_avoid + tag_nutrition.
- carbs/fat đọc từ cột "Carbs (g)" / "Fat (g)" (thêm sau khi verify USDA).
  Thiếu macro -> để null => validate_seed.py FAIL (cổng chặn verify USDA).
  Dùng --allow-zero-macros để dry-run thử pipeline khi CHƯA verify.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUT = ROOT / "data" / "seeds" / "cravvy_curated_159.json"

SOURCE = "cravvy_curated_vn"
LOCALE = "vi"
EXCLUDE_SHEET = "05_72_Mon_Cu"
DEFAULT_PREP_MINUTES = 25

MEAL_TYPE_MAP = {
    "sáng": "breakfast",
    "trưa": "lunch",
    "tối": "dinner",
    "snack": "snack",
    "phụ": "snack",
}
TAG_COLUMNS = ["tag_diet", "tag_allergy", "tag_avoid", "tag_nutrition"]


def make_getter(fieldnames):
    norm = {(f or "").strip().lower(): f for f in fieldnames}

    def get(row, *candidates):
        for c in candidates:
            key = norm.get(c.strip().lower())
            if key is not None:
                return (row.get(key) or "").strip()
        return ""

    return get


def parse_int(raw):
    if not raw:
        return None
    m = re.search(r"\d+", raw.replace(",", ""))
    return int(m.group()) if m else None


def smart_split(text, delim):
    """Tách theo delim nhưng bỏ qua delim trong ngoặc ( ) hoặc [ ]."""
    parts, depth, cur = [], 0, ""
    for ch in text:
        if ch in "([":
            depth += 1
        elif ch in ")]":
            depth = max(0, depth - 1)
        if ch == delim and depth == 0:
            parts.append(cur)
            cur = ""
        else:
            cur += ch
    parts.append(cur)
    return [p.strip() for p in parts if p.strip()]


def split_ingredients(text):
    if not text:
        return []
    delim = "|" if "|" in text else ","
    return smart_split(text, delim)[:30]


def split_steps(text):
    if not text:
        return []
    steps = smart_split(text, "|") if "|" in text else re.split(r"(?<=[.!?])\s+", text)
    out = []
    for s in steps:
        s = s.strip().rstrip(".").strip()
        if s:
            out.append(s)
    return out[:12]


def parse_prep_minutes(steps):
    best = 0
    for s in steps:
        for m in re.finditer(r"(\d+)\s*(?:p|phút|phut|min)", s, flags=re.IGNORECASE):
            best = max(best, int(m.group(1)))
    return max(5, min(180, best)) if best else DEFAULT_PREP_MINUTES


def infer_difficulty(prep_time):
    if prep_time <= 20:
        return "easy"
    if prep_time <= 45:
        return "medium"
    return "hard"


def build_tags(get, row):
    seen, tags = set(), []
    for col in TAG_COLUMNS:
        for tok in smart_split(get(row, col), ","):
            t = tok.strip().lower()
            if t and t not in seen:
                seen.add(t)
                tags.append(t)
    return tags[:20]


def make_source_id(sheet_id, stt):
    base = re.sub(r"[^a-z0-9]+", "_", sheet_id.lower()).strip("_")
    return f"{base}_{int(stt):02d}"


def transform_row(get, row, allow_zero, warnings):
    sheet_id = get(row, "sheet_id")
    stt = get(row, "STT")
    name = get(row, "Tên món", "Ten mon")
    tag = f"[{sheet_id}#{stt}] {name}"

    meal_raw = get(row, "Bữa ăn", "Bua an").lower()
    meal_type = MEAL_TYPE_MAP.get(meal_raw, "lunch")
    if meal_raw not in MEAL_TYPE_MAP:
        warnings.append(f"{tag}: bữa ăn lạ '{meal_raw}' -> lunch")

    ingredients = split_ingredients(get(row, "Nguyên liệu chính", "Nguyen lieu chinh"))
    if not ingredients:
        warnings.append(f"{tag}: KHÔNG có nguyên liệu — bỏ qua")
        return None
    steps = split_steps(get(row, "Cách làm tóm tắt", "Cach lam tom tat"))
    if not steps:
        steps = [f"Sơ chế và chế biến {name} theo công thức."]

    # Ưu tiên số TÍNH (estimate_macros.py) nếu có; fallback số team trong CSV gốc.
    calories = parse_int(get(row, "Calo_tinh", "Calo (est)", "Calo")) or 0
    protein = parse_int(get(row, "Protein_tinh", "Protein (g)", "Protein")) or 0
    carbs = parse_int(get(row, "Carbs (g)", "Carbs", "carbs_g"))
    fat = parse_int(get(row, "Fat (g)", "Fat", "fat_g"))

    if carbs is None or fat is None:
        if allow_zero:
            warnings.append(f"{tag}: thiếu carbs/fat -> 0 (CHƯA verify USDA)")
            carbs = 0 if carbs is None else carbs
            fat = 0 if fat is None else fat
        else:
            # Để null => validate_seed.py sẽ FAIL, ép verify USDA trước khi import thật.
            warnings.append(f"{tag}: thiếu carbs/fat -> null (validate sẽ FAIL)")

    prep_time = parse_prep_minutes(steps)
    return {
        "name": name,
        "description": None,
        "image_url": None,  # placeholder; gắn sau theo source_id
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fat,
        "prep_time": prep_time,
        "difficulty": infer_difficulty(prep_time),
        "meal_type": meal_type,
        "tags": build_tags(get, row),
        "steps": steps,
        "ingredients": ingredients,
        "source": SOURCE,
        "source_id": make_source_id(sheet_id, stt),
        "locale": LOCALE,
        "is_active": False,
    }


def main():
    ap = argparse.ArgumentParser(description="Cravvy CSV -> seed JSON")
    ap.add_argument("csv", help="Đường dẫn Cravvy_FoodDB_All.csv")
    ap.add_argument("-o", "--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--allow-zero-macros", action="store_true",
                    help="Điền carbs/fat=0 khi thiếu (chỉ để dry-run, KHÔNG import thật)")
    args = ap.parse_args()

    csv_path = Path(args.csv)
    if not csv_path.exists():
        sys.exit(f"Không tìm thấy file: {csv_path}")

    records, warnings, seen = [], [], set()
    with csv_path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        get = make_getter(reader.fieldnames)
        for row in reader:
            if get(row, "sheet_id") == EXCLUDE_SHEET:
                continue
            if get(row, "approved").upper() != "APPROVED":
                continue
            rec = transform_row(get, row, args.allow_zero_macros, warnings)
            if rec is None:
                continue
            if rec["source_id"] in seen:
                warnings.append(f"source_id trùng: {rec['source_id']} — bỏ bản sau")
                continue
            seen.add(rec["source_id"])
            records.append(rec)

    by_meal = {}
    for r in records:
        by_meal[r["meal_type"]] = by_meal.get(r["meal_type"], 0) + 1

    args.out.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "version": 3,
        "project": "Cravvy Cooking App",
        "catalog_note": "Converted from Cravvy_FoodDB_All.csv (159 APPROVED). is_active=false (staging).",
        "count": len(records),
        "recipes": records,
    }
    args.out.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"✓ Ghi {len(records)} món -> {args.out}", file=sys.stderr)
    print(f"  Phân bổ bữa: {by_meal}", file=sys.stderr)
    if warnings:
        print(f"\n⚠ {len(warnings)} cảnh báo:", file=sys.stderr)
        for w in warnings:
            print("  - " + w, file=sys.stderr)


if __name__ == "__main__":
    main()
