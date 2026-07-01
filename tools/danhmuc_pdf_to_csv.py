#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Trích bảng món ăn từ "Danh mục.pdf" (catalog món cũ, có ảnh + công thức) -> CSV
ăn khớp pipeline estimate_macros.py + cravvy_csv_to_seed.py.

Bảng PDF có cột (theo toạ độ x0):
  STT(~27) | Danh mục/Bữa(~50) | Tên món(~86) | Ảnh(~139,trống) |
  Nguyên Liệu(~219) | Hướng dẫn(~298) | Link Video(~509)

  python tools/danhmuc_pdf_to_csv.py "C:\\...\\Danh mục.pdf" -o tools/_moncu_raw.csv

Mỗi món = từ dòng có STT (số nguyên ở cột STT) tới ngay trước STT kế tiếp.
Cột Nguyên liệu nối bằng '|' (mỗi dòng = 1 nguyên liệu); cột Hướng dẫn tách theo 'N.'.
Output: sheet_id=moncu, approved=APPROVED, tag_* để trống (điền ở bước sau).
"""
from __future__ import annotations
import argparse, csv, re, sys, unicodedata
from pathlib import Path

import pdfplumber

# Ranh giới cột theo x0 (px, trang rộng 612)
def col_of(x0):
    if x0 < 45:   return "stt"
    if x0 < 82:   return "bua"
    if x0 < 135:  return "name"
    if x0 < 200:  return "anh"      # ảnh — bỏ
    if x0 < 296:  return "ing"
    if x0 < 505:  return "hd"
    return "link"

MEAL_MAP = {"sáng": "Sáng", "trưa": "Trưa", "tối": "Tối", "phụ": "Phụ"}
# Nhãn "Món Canh"/"Món Gà"... (món phụ kèm) -> mặc định bữa trưa
DEFAULT_MEAL_FOR_MON = "Trưa"


def nfc(s): return unicodedata.normalize("NFC", str(s)).strip()


def group_lines(words, ytol=3.0):
    """Gom word thành dòng theo toạ độ top (trong dung sai ytol)."""
    rows = []
    for w in sorted(words, key=lambda w: (round(w["top"]), w["x0"])):
        if rows and abs(w["top"] - rows[-1]["top"]) <= ytol:
            rows[-1]["words"].append(w)
        else:
            rows.append({"top": w["top"], "words": [w]})
    return rows


def line_cols(line):
    """Trả dict cột -> text của 1 dòng."""
    out = {}
    for w in sorted(line["words"], key=lambda w: w["x0"]):
        c = col_of(w["x0"])
        out.setdefault(c, []).append(nfc(w["text"]))
    return {k: " ".join(v).strip() for k, v in out.items()}


def parse_pdf(path):
    # Thu thập mọi dòng theo thứ tự (page, top)
    all_lines = []
    with pdfplumber.open(path) as pdf:
        for pi, page in enumerate(pdf.pages):
            words = page.extract_words(use_text_flow=False, keep_blank_chars=False)
            for ln in group_lines(words):
                all_lines.append((pi, ln["top"], line_cols(ln)))

    # Xác định các dòng "mở đầu món": cột stt là số nguyên 1..104 + có 'Bữa' ở cột bua
    dishes = []
    cur = None
    for pi, top, cols in all_lines:
        stt_txt = cols.get("stt", "")
        m = re.fullmatch(r"\d{1,3}", stt_txt)
        is_head = bool(m) and re.match(r"^(bữa|món)", cols.get("bua", "").lower())
        if is_head:
            if cur:
                dishes.append(cur)
            cur = {"stt": int(stt_txt), "bua": cols.get("bua", ""),
                   "name": [], "ing": [], "hd": []}
        if cur is None:
            continue
        if cols.get("name"):
            cur["name"].append(cols["name"])
        if cols.get("ing"):
            cur["ing"].append(cols["ing"])
        if cols.get("hd"):
            cur["hd"].append(cols["hd"])
    if cur:
        dishes.append(cur)
    return dishes


def clean_name(parts):
    name = " ".join(parts)
    name = re.sub(r"\s+", " ", name).strip()
    # cắt phần lỡ dính tiêu đề cột nếu có
    name = re.sub(r"\s*(NGUYÊN LIỆU.*|Nguyên liệu.*)$", "", name).strip()
    return name


def merge_ingredients(lines):
    """Mỗi dòng PDF = 1 nguyên liệu (KHÔNG nối dòng — tránh dính nhầm 2 nguyên
    liệu khiến lookup macro sai, vd 'nước dừa tươi'+'dầu' -> tính ra 1L dầu ăn).
    Dòng không có số lượng -> giữ nguyên nhưng extract_grams=0 nên macro ~0."""
    return [nfc(ln) for ln in lines if len(nfc(ln)) > 1]


def split_steps(hd_lines):
    text = " ".join(nfc(x) for x in hd_lines)
    text = re.sub(r"\s+", " ", text).strip()
    # tách theo 'N.' (1. 2. 3.) — mốc bước
    parts = re.split(r"(?<!\d)(\d{1,2})\.\s*", text)
    steps = []
    if len(parts) >= 3:
        # parts = [pre, '1', body1, '2', body2, ...]
        it = iter(parts[1:])
        for num, body in zip(it, it):
            body = body.strip(" .")
            if body:
                steps.append(body)
    if not steps:
        steps = [s.strip() for s in re.split(r"(?<=[.!?])\s+", text) if s.strip()]
    return steps


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf")
    ap.add_argument("-o", "--out", default="tools/_moncu_raw.csv")
    args = ap.parse_args()

    dishes = parse_pdf(args.pdf)
    print(f"Bắt được {len(dishes)} món; STT {min(d['stt'] for d in dishes)}..{max(d['stt'] for d in dishes)}",
          file=sys.stderr)

    cols = ["sheet_id", "STT", "Tên món", "Bữa ăn", "Nguyên liệu chính",
            "Cách làm tóm tắt", "approved", "tag_diet", "tag_allergy",
            "tag_avoid", "tag_nutrition"]
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        for d in dishes:
            bua_raw = d["bua"].strip()
            if bua_raw.lower().startswith("món"):
                meal = DEFAULT_MEAL_FOR_MON
            else:
                bua = bua_raw.replace("Bữa", "").strip()
                meal = MEAL_MAP.get(bua.lower(), "Trưa")
            ings = merge_ingredients(d["ing"])
            steps = split_steps(d["hd"])
            w.writerow({
                "sheet_id": "moncu",
                "STT": d["stt"],
                "Tên món": clean_name(d["name"]),
                "Bữa ăn": meal,
                "Nguyên liệu chính": " | ".join(ings),
                "Cách làm tóm tắt": " | ".join(steps),
                "approved": "APPROVED",
                "tag_diet": "", "tag_allergy": "", "tag_avoid": "", "tag_nutrition": "",
            })
    print(f"✓ Ghi {len(dishes)} dòng -> {out}", file=sys.stderr)


if __name__ == "__main__":
    main()
