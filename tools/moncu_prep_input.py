#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Chuẩn bị input cho workflow enrich macro/tag món cũ.

Đọc tools/_moncu_raw.csv (trích từ Danh mục.pdf) + thư mục ảnh -> chỉ giữ các món
CÓ ảnh (= phần user đã lọc), gán source_id ổn định và map file ảnh.

  source_id = moncu_<STT:03d>   (vd moncu_001, moncu_060)
  DUP STT 32: cá (32.jpg) -> moncu_032 ; bò (32_Bò Sốt Tiêu Đen.jpg) -> moncu_032b

Xuất tools/_moncu_input.json: [{source_id, stt, name, meal_type, ingredients[],
steps[], image_file, image_ext}] để nạp vào Workflow args.
"""
from __future__ import annotations
import csv, json, os, re, unicodedata
from pathlib import Path

RAW = Path("tools/_moncu_raw.csv")
IMG_DIR = Path(r"C:\Users\Admin\Downloads\Ảnh Danh Mục-20260626T012247Z-3-001\Ảnh Danh Mục")
OUT = Path("tools/_moncu_input.json")
BEEF_FILE = "32_Bò Sốt Tiêu Đen.jpg"

MEAL = {"Sáng": "breakfast", "Trưa": "lunch", "Tối": "dinner", "Phụ": "snack"}


def nfc(s): return unicodedata.normalize("NFC", str(s))


def main():
    # 1) ảnh: STT -> filename (chỉ file tên thuần số)
    by_stt = {}
    for f in os.listdir(IMG_DIR):
        stem = f.rsplit(".", 1)[0]
        if re.fullmatch(r"\d{1,3}", stem):
            by_stt[int(stem)] = f
    beef_present = (IMG_DIR / BEEF_FILE).exists()

    rows = list(csv.DictReader(open(RAW, encoding="utf-8-sig")))
    out = []
    for r in rows:
        stt = int(r["STT"])
        name = nfc(r["Tên món"]).strip()
        ings = [s.strip() for s in r["Nguyên liệu chính"].split("|") if s.strip()]
        steps = [s.strip() for s in r["Cách làm tóm tắt"].split("|") if s.strip()]
        meal = MEAL.get(r["Bữa ăn"].strip(), "lunch")

        # DUP STT 32: phân biệt bò / cá
        is_beef = stt == 32 and ("bò" in name.lower() or "tiêu đen" in name.lower())
        if is_beef:
            if not beef_present:
                continue
            sid, img = "moncu_032b", BEEF_FILE
        else:
            img = by_stt.get(stt)
            if not img:
                continue  # không có ảnh -> bỏ (món user đã loại)
            sid = f"moncu_{stt:03d}"

        out.append({
            "source_id": sid,
            "stt": stt,
            "name": name,
            "meal_type": meal,
            "ingredients": ings,
            "steps": steps,
            "image_file": img,
            "image_ext": img.rsplit(".", 1)[1].lower(),
        })

    # dedup source_id
    seen = {}
    for d in out:
        seen.setdefault(d["source_id"], d)
    out = list(seen.values())
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    from collections import Counter
    print(f"✓ {len(out)} món có ảnh -> {OUT}")
    print("  meal:", dict(Counter(d["meal_type"] for d in out)))
    print("  ext :", dict(Counter(d["image_ext"] for d in out)))
    print("  size:", OUT.stat().st_size, "bytes")


if __name__ == "__main__":
    main()
