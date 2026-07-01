#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Ghép input món cũ (tools/_moncu_input.json) + kết quả enrich từ workflow
(scratch/chunk_*.json) -> seed JSON cho import_recipes.py.

- name / meal_type / ảnh: lấy từ input (chuẩn theo PDF + ảnh user lọc).
- macro / tag / ingredients / steps / description / prep_time / difficulty: từ enrich.
- Món nào workflow thiếu -> fallback macro từ _moncu_raw_with_macros.csv (per-serving).
- source=cravvy_curated_vn, locale=vi, is_active=False (staging). image_url=null (gắn sau).

  python tools/moncu_build_seed.py
"""
from __future__ import annotations
import csv, glob, json, os, unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "tools" / "_moncu_input.json"
MACRO_CSV = ROOT / "tools" / "_moncu_raw_with_macros.csv"
SCRATCH = Path(r"C:\Users\Admin\AppData\Local\Temp\claude\e--Project-Flutter-CravvyCookingApp-Cravvy-Cooking-App\ddbee199-93e3-4565-a869-f11787962792\scratchpad")
OUT = ROOT / "data" / "seeds" / "cravvy_moncu.json"


def nfc(s): return unicodedata.normalize("NFC", str(s)).strip()


# File output workflow (structured return, đầy đủ 94 món) — ưu tiên.
TASKS_DIR = Path(r"C:\Users\Admin\AppData\Local\Temp\claude\e--Project-Flutter-CravvyCookingApp-Cravvy-Cooking-App\ddbee199-93e3-4565-a869-f11787962792\tasks")


def load_enriched():
    """Gộp theo source_id: ưu tiên structured return trong tasks/*.output (đủ 94),
    bổ sung từ chunk_*.json nếu thiếu."""
    by_sid = {}
    # 1) chunk files (bổ sung)
    for fp in glob.glob(str(SCRATCH / "chunk_*.json")):
        try:
            data = json.loads(Path(fp).read_text(encoding="utf-8"))
        except Exception as e:
            print(f"  ! Bỏ {os.path.basename(fp)}: {e}")
            continue
        items = data.get("dishes") if isinstance(data, dict) else data
        for d in (items or []):
            if d.get("source_id"):
                by_sid[d["source_id"]] = d
    # 2) GỘP mọi file output workflow (v2 + tail). Chỉ nhận source_id thuộc input.
    #    (các file output cũ/hỏng đã được xoá thủ công nên gộp toàn bộ là an toàn.)
    want = {d["source_id"] for d in json.loads(INPUT.read_text(encoding="utf-8"))}
    for fp in glob.glob(str(TASKS_DIR / "*.output")):
        try:
            data = json.loads(Path(fp).read_text(encoding="utf-8"))
        except Exception:
            continue
        for d in ((data.get("result") or {}).get("dishes") or []):
            sid = d.get("source_id")
            if sid in want:
                by_sid[sid] = d
    print(f"  (gộp output: khớp {len(by_sid)}/{len(want)} source_id)")
    return by_sid


def macro_fallback():
    """Per-serving macro từ estimator (khi thiếu enrich)."""
    out = {}
    if not MACRO_CSV.exists():
        return out
    for r in csv.DictReader(open(MACRO_CSV, encoding="utf-8-sig")):
        stt = r["STT"]
        try:
            s = max(1, int(r.get("Servings_est") or 1))
            out[stt] = {
                "calories": round(int(r["Calo_tinh"]) / s),
                "protein": round(int(r["Protein_tinh"]) / s),
                "carbs": round(int(r["Carbs (g)"]) / s),
                "fat": round(int(r["Fat (g)"]) / s),
            }
        except Exception:
            pass
    return out


def main():
    inp = json.loads(INPUT.read_text(encoding="utf-8"))
    enr = load_enriched()
    fb = macro_fallback()
    print(f"Input: {len(inp)} món | Enriched: {len(enr)} | fallback rows: {len(fb)}")

    recipes, missing = [], []
    for d in inp:
        sid = d["source_id"]
        e = enr.get(sid)
        if e:
            rec = {
                "name": d["name"],
                "description": nfc(e.get("description") or "") or None,
                "image_url": None,
                "calories": int(e.get("calories") or 0),
                "protein": int(e.get("protein") or 0),
                "carbs": int(e.get("carbs") or 0),
                "fat": int(e.get("fat") or 0),
                "prep_time": int(e.get("prep_time") or 25),
                "difficulty": e.get("difficulty") or "medium",
                "meal_type": d["meal_type"],
                "tags": [nfc(t).lower() for t in (e.get("tags") or []) if nfc(t)][:15],
                "steps": [nfc(s) for s in (e.get("steps") or []) if nfc(s)][:12],
                "ingredients": [nfc(i) for i in (e.get("ingredients") or []) if nfc(i)][:30],
                "source": "cravvy_curated_vn",
                "source_id": sid,
                "locale": "vi",
                "is_active": False,
            }
        else:
            missing.append(sid)
            # tráng miệng/snack: default hợp lý (estimator chia thiếu khẩu phần -> sai nặng)
            if d["meal_type"] == "snack":
                m = {"calories": 280, "protein": 5, "carbs": 52, "fat": 5}
            else:
                m = fb.get(str(d["stt"]), {"calories": 400, "protein": 20, "carbs": 40, "fat": 15})
                # kẹp biên nếu estimator cho giá trị vô lý
                if not (120 <= m["calories"] <= 800):
                    m = {"calories": 450, "protein": 25, "carbs": 40, "fat": 18}
            rec = {
                "name": d["name"], "description": None, "image_url": None,
                "calories": m["calories"], "protein": m["protein"], "carbs": m["carbs"], "fat": m["fat"],
                "prep_time": 25, "difficulty": "medium", "meal_type": d["meal_type"],
                "tags": ["truyền thống", "món việt"],
                "steps": d["steps"][:12] or [f"Chế biến {d['name']} theo công thức."],
                "ingredients": d["ingredients"][:30],
                "source": "cravvy_curated_vn", "source_id": sid, "locale": "vi", "is_active": False,
            }
        # đảm bảo steps không rỗng
        if not rec["steps"]:
            rec["steps"] = [f"Chế biến {d['name']} theo công thức."]
        recipes.append(rec)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(
        {"version": 1, "project": "Cravvy Cooking App",
         "catalog_note": "Món cũ truyền thống (Danh mục.pdf) — enrich macro/tag bằng workflow. is_active=false.",
         "count": len(recipes), "recipes": recipes},
        ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"✓ Ghi {len(recipes)} món -> {OUT}")
    if missing:
        print(f"⚠ {len(missing)} món THIẾU enrich (dùng fallback): {missing}")
    from collections import Counter
    print("  meal:", dict(Counter(r["meal_type"] for r in recipes)))


if __name__ == "__main__":
    main()
