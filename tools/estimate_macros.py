#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Ước tính carbs/fat (và cross-check calo) cho các món Cravvy từ lượng gram nguyên liệu.

Cách tính: với mỗi nguyên liệu -> tách lượng gram (hoặc ml ~ g) -> nhân với
giá trị dinh dưỡng per-100g (bảng NUTRI bên dưới, lấy theo USDA / Viện Dinh Dưỡng).
Cộng dồn cả món -> carbs/fat. Đồng thời tính lại calo để ĐỐI CHIẾU với "Calo (est)"
của bạn; món lệch > FLAG_PCT sẽ được liệt kê để rà tay (verify USDA có trọng tâm).

  python tools/estimate_macros.py "C:\\Users\\Admin\\Downloads\\Cravvy_FoodDB_All.csv"

Xuất:
  * <input>_with_macros.csv  — thêm cột "Carbs (g)", "Fat (g)", "Calo_tinh", "Cov_%"
  * In báo cáo: độ phủ nguyên liệu, top món lệch calo, nguyên liệu chưa map.

LƯU Ý: đây là ƯỚC TÍNH tự động, KHÔNG thay thế kiểm chứng cuối của con người.
Hãy rà các món bị flag + món có Cov_% thấp trước khi import thật.
"""

from __future__ import annotations

import csv
import re
import sys
from collections import Counter
from pathlib import Path

FLAG_PCT = 30          # lệch calo > 30% -> flag
LOW_COVERAGE = 70      # phủ nguyên liệu < 70% (theo gram) -> cảnh báo

# ─── Bảng dinh dưỡng per-100g: keyword -> (carb, fat, kcal, protein) ──────────
# Khớp theo THỨ TỰ: mục cụ thể đặt TRƯỚC mục chung (ví dụ "bơ đậu phộng" trước "bơ").
NUTRI = [
    # Phần CHỈ lấy nước/không ăn -> 0 (đặt TRƯỚC "gà"/"cá"/"heo")
    ("xương",        (0, 0, 0, 0)),
    # Nấm — đặt TRƯỚC "đùi gà"/"gà" để 'nấm đùi gà' không bị tính thành thịt gà
    ("nấm đùi gà",   (3.3, 0.3, 35, 3)),
    ("nấm kim châm", (5, 0.3, 37, 2.7)),
    ("nấm bào ngư",  (5, 0.3, 33, 3)),
    ("nấm đông cô",  (7, 0.5, 34, 2.2)),
    ("nấm hương",    (7, 0.5, 34, 2.2)),
    ("nấm rơm",      (4, 0.3, 29, 3)),
    # Dầu / chất béo
    ("bơ đậu phộng", (20, 50, 588, 25)),
    ("dầu",          (0, 100, 884, 0)),
    ("bơ lạt",       (0, 81, 717, 1)),
    ("bơ thực vật",  (0, 80, 717, 0)),
    ("bơ nhạt",      (0, 81, 717, 1)),
    ("mayo",         (4, 75, 680, 1)),
    ("nước cốt dừa", (6, 24, 230, 2)),
    # Tinh bột / ngũ cốc  (LƯU Ý: "cơm" đặt TRƯỚC "gạo lứt" -> 'cơm gạo lứt nguội'
    # tính theo cơm CHÍN, còn '100g gạo lứt sống' mới tính theo gạo sống)
    ("cơm",          (28, 0.3, 130, 2.7)),
    ("gạo lứt",      (76, 2.9, 370, 8)),     # gạo SỐNG (data ghi "100g gạo lứt sống")
    ("gạo nếp",      (80, 0.6, 370, 7)),
    ("yến mạch",     (66, 7, 389, 17)),
    ("bột yến mạch", (66, 7, 389, 17)),
    ("quinoa",       (64, 6, 368, 14)),
    ("diêm mạch",    (64, 6, 368, 14)),
    ("bánh phở",     (80, 0.5, 360, 6)),     # khô
    ("bún",          (78, 0.6, 350, 6)),     # khô
    ("miến",         (84, 0.1, 350, 0.2)),
    ("nui",          (75, 1.5, 371, 13)),
    ("mì ý",         (75, 1.5, 371, 13)),
    ("mì ý nguyên cám", (72, 2.5, 348, 14)),
    ("mì",           (75, 1.5, 371, 13)),
    ("bánh mì",      (49, 3.5, 265, 9)),
    ("bánh gạo lứt", (81, 3, 387, 8)),
    ("bánh tráng",   (80, 0.5, 333, 4)),
    ("bánh tráng",   (80, 0.5, 333, 4)),
    ("granola",      (64, 15, 471, 10)),
    # Củ giàu tinh bột
    ("khoai lang",   (20, 0.1, 86, 1.6)),
    ("khoai tây",    (17, 0.1, 77, 2)),
    ("bí đỏ",        (7, 0.1, 26, 1)),
    ("bí ngô",       (7, 0.1, 26, 1)),
    ("ngô",          (19, 1.4, 86, 3.3)),
    ("bắp",          (19, 1.4, 86, 3.3)),
    # Đạm động vật  ("trứng" đặt TRƯỚC "gà" để 'trứng gà' không thành thịt gà)
    ("trứng",        (1.1, 11, 155, 13)),
    ("ức gà",        (0, 3.6, 165, 31)),
    ("đùi gà",       (0, 10, 209, 26)),
    ("gà",           (0, 8, 190, 27)),
    ("thịt bò",      (0, 15, 250, 26)),
    ("bò",           (0, 15, 250, 26)),
    ("sườn",         (0, 24, 290, 17)),
    ("thịt heo nạc", (0, 8, 180, 27)),
    ("heo nạc",      (0, 8, 180, 27)),
    ("thịt heo",     (0, 21, 242, 27)),
    ("heo",          (0, 21, 242, 27)),
    ("cá hồi",       (0, 13, 208, 20)),
    ("cá thu",       (0, 14, 205, 19)),
    ("cá basa",      (0, 3, 90, 15)),
    ("cá ngừ",       (0, 1, 116, 26)),
    ("cá",           (0, 5, 120, 20)),
    ("tôm",          (0.2, 1.7, 99, 24)),
    ("mực",          (3, 1.4, 92, 16)),
    ("ốc",           (2, 0.7, 90, 15)),
    # Đạm thực vật / sữa
    ("đậu hũ",       (1.9, 4.8, 76, 8)),
    ("đậu phụ",      (1.9, 4.8, 76, 8)),
    ("đậu gà",       (27, 2.6, 164, 9)),
    ("hummus",       (14, 10, 166, 8)),
    ("đậu lăng",     (20, 0.4, 116, 9)),
    ("đậu nành",     (30, 20, 446, 36)),
    ("edamame",      (8, 5, 121, 12)),
    ("đậu cô ve",    (7, 0.2, 31, 1.8)),
    ("đậu ve",       (7, 0.2, 31, 1.8)),
    ("đậu que",      (7, 0.2, 31, 1.8)),
    ("đậu bắp",      (7, 0.2, 33, 1.9)),
    ("đậu hà lan",   (14, 0.4, 81, 5)),
    ("đậu xanh",     (63, 1.2, 347, 24)),    # khô bóc vỏ
    ("đậu đỏ",       (63, 0.5, 337, 21)),
    ("whey",         (8, 3, 400, 80)),
    ("sữa chua hy lạp", (4, 0.4, 59, 10)),
    ("sữa chua",     (5, 3.3, 61, 3.5)),
    ("sữa hạt",      (3, 1.2, 35, 1)),
    ("sữa tươi",     (5, 1.5, 50, 3.3)),
    ("sữa đậu nành", (3, 1.8, 45, 3.3)),
    ("phô mai",      (3, 25, 320, 22)),
    ("cream cheese", (4, 34, 342, 6)),
    # Hạt
    ("hạt chia",     (42, 31, 486, 17)),
    ("mè",           (23, 50, 573, 18)),
    ("vừng",         (23, 50, 573, 18)),
    ("hạnh nhân",    (22, 50, 579, 21)),
    ("óc chó",       (14, 65, 654, 15)),
    ("hạt điều",     (30, 44, 553, 18)),
    ("hạt dẻ cười",  (28, 45, 560, 20)),
    ("hạt bí",       (11, 49, 559, 30)),
    ("hạt hướng dương", (20, 51, 584, 21)),
    ("hạt sen",      (64, 2, 332, 15)),      # khô
    # (KHÔNG đặt "hạt" chung — dễ khớp nhầm 'hạt lựu' (kiểu thái) / 'hạt nêm')
    # Trái cây
    ("chuối",        (23, 0.3, 89, 1.1)),
    ("xoài",         (15, 0.4, 60, 0.8)),
    ("táo",          (14, 0.2, 52, 0.3)),
    ("việt quất",    (14, 0.3, 57, 0.7)),
    ("dâu",          (8, 0.3, 32, 0.7)),
    ("cam",          (12, 0.1, 47, 0.9)),
    ("dứa",          (13, 0.1, 50, 0.5)),
    ("thanh long",   (11, 0.4, 60, 1.2)),
    ("nha đam",      (2, 0.1, 15, 0.5)),
    ("long nhãn",    (15, 0.1, 60, 1)),
    ("trái cây",     (13, 0.2, 55, 0.7)),
    # Rau củ (ít macro)
    ("cà rốt",       (10, 0.2, 41, 0.9)),
    ("cà chua",      (3.9, 0.2, 18, 0.9)),
    ("hành tây",     (9, 0.1, 40, 1.1)),
    ("bông cải",     (7, 0.4, 34, 2.8)),
    ("súp lơ",       (5, 0.3, 25, 1.9)),
    ("măng tây",     (3.9, 0.1, 20, 2.2)),
    ("nấm",          (3.3, 0.3, 22, 3.1)),
    ("rau muống",    (3.1, 0.2, 19, 2.6)),
    ("cải bó xôi",   (3.6, 0.4, 23, 2.9)),
    ("rau bina",     (3.6, 0.4, 23, 2.9)),
    ("bắp cải",      (6, 0.1, 25, 1.3)),
    ("dưa leo",      (3.6, 0.1, 15, 0.7)),
    ("xà lách",      (2.9, 0.2, 15, 1.4)),
    ("rau diếp",     (2.9, 0.2, 15, 1.4)),
    ("cần tây",      (3, 0.2, 16, 0.7)),
    ("ớt chuông",    (6, 0.3, 31, 1)),
    ("bí ngòi",      (3.1, 0.3, 17, 1.2)),
    ("bí xanh",      (3, 0.1, 13, 0.6)),
    ("su su",        (4.5, 0.1, 19, 0.8)),
    ("giá",          (5.9, 0.2, 30, 3)),
    ("mít non",      (24, 0.6, 95, 1.7)),
    ("cà tím",       (6, 0.2, 25, 1)),
    ("rong biển",    (9, 0.6, 45, 1.7)),
    ("rau",          (4, 0.2, 25, 1.8)),     # rau chung
    # Gia vị / chất tạo ngọt
    ("mật ong",      (82, 0, 304, 0.3)),
    ("đường",        (100, 0, 387, 0)),
    ("miso",         (25, 6, 199, 12)),
    ("tương",        (15, 4, 120, 8)),       # gochujang/tương HQ
    ("tỏi",          (33, 0.5, 149, 6)),
    ("gừng",         (18, 0.8, 80, 1.8)),
    ("hành tím",     (17, 0.1, 72, 2.5)),
    ("hành lá",      (7, 0.5, 32, 1.8)),
    ("sả",           (25, 0.5, 99, 1.8)),
    ("me",           (63, 0.6, 239, 2.8)),
    # ── Bổ sung MÓN CŨ truyền thống (USDA / Viện Dinh Dưỡng) ──────────────────
    # Đạm động vật bổ sung (đặt ở đây an toàn: không trùng substring với kw thịt phía trên)
    ("ba chỉ",       (0, 53, 518, 9)),      # thịt ba chỉ (pork belly) — rất béo
    ("lợn nạc",      (0, 8, 180, 27)),      # 'lợn' = 'heo' (miền Bắc)
    ("thịt lợn",     (0, 21, 242, 27)),
    ("lợn",          (0, 21, 242, 27)),
    ("thịt băm",     (0, 18, 230, 18)),     # thịt băm (mặc định heo) — sau 'thịt bò'
    ("nạc vai",      (0, 12, 200, 20)),     # thịt nạc vai heo
    ("giò sống",     (3, 20, 270, 14)),     # giò sống / mọc
    ("mọc",          (3, 20, 270, 14)),
    ("vịt",          (0, 28, 337, 19)),     # thịt vịt (cả da)
    ("tép",          (1, 1, 85, 15)),       # tép đồng (sau strip_qty, 'tép tỏi' -> 'tỏi')
    ("ngán",         (4, 1, 86, 14)),       # ngán / ngao (nghêu)
    ("ngao",         (4, 1, 86, 14)),
    # Củ giàu tinh bột bổ sung
    ("khoai sọ",     (26, 0.1, 112, 1.5)),
    ("khoai môn",    (26, 0.1, 112, 1.5)),
    ("khoai mỡ",     (28, 0.2, 118, 1.5)),
    ("khoai mì",     (38, 0.3, 160, 1.4)),
    ("sắn",          (38, 0.3, 160, 1.4)),  # củ sắn = khoai mì
    ("cốm",          (74, 1, 350, 8)),
    ("bột năng",     (88, 0, 358, 0.2)),    # bột năng / tinh bột sắn
    ("bột nếp",      (80, 0.6, 360, 7)),
    ("bột gạo",      (80, 0.6, 360, 7)),
    # Rau / quả / sữa bổ sung (đặt SAU 'măng tây' phía trên)
    ("khổ qua",      (4, 0.2, 17, 1)),
    ("mướp đắng",    (4, 0.2, 17, 1)),
    ("măng",         (5, 0.3, 27, 2.6)),    # măng tươi / măng chua
    ("đu đủ",        (11, 0.3, 43, 0.5)),
    ("khế",          (7, 0.3, 31, 1)),
    ("sấu",          (9, 0.2, 38, 1)),      # quả sấu (chua)
    ("riềng",        (15, 0.5, 71, 1)),
    ("dừa nạo",      (15, 33, 354, 3)),
    ("sữa đặc",      (54, 8, 321, 8)),
    # Bổ sung / fallback (đặt cuối)
    ("bơ",           (9, 15, 160, 2)),       # quả bơ (avocado) — sau các loại bơ béo ở trên
    ("bí đao",       (3, 0.1, 12, 0.6)),
    ("mộc nhĩ",      (10, 0.1, 25, 1)),
    ("nước dừa",     (3.7, 0.2, 19, 0.7)),
    ("bạch quả",     (38, 2, 182, 4)),
    ("hành",         (9, 0.1, 40, 1.1)),
    ("cải",          (4, 0.2, 25, 1.8)),     # các loại cải / rau cải
]

# Đơn vị đếm -> gram ước lượng (khi KHÔNG có g/ml tường minh và không có (~Xg))
UNIT_G = {
    "tép": 4, "củ": 15, "nhánh": 5, "lá": 8, "tấm": 10, "miếng": 25,
    "scoop": 30, "nhúm": 1, "cây": 50, "viên": 8, "quả": 90, "trái": 90,
    "thanh": 8, "hoa": 2, "mcf": 5,
}

NEG_ZERO = ("muối", "tiêu", "nước lọc", "nước dùng", "nước", "giấm", "chanh",
            "nước mắm", "hạt nêm", "bột nêm", "đá", "rau thơm", "ngò", "húng",
            "hương thảo", "lá chanh", "hoa hồi", "quế", "mù tạt", "tương ớt",
            "bột ớt", "ớt", "rượu", "sa tế", "dầu hào", "bột ngũ vị", "ngũ vị hương")


def smart_split(text, delim):
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


def frac(s):
    s = s.replace(",", ".")
    if "/" in s:
        a, b = s.split("/", 1)
        try:
            return float(a) / float(b)
        except (ValueError, ZeroDivisionError):
            return None
    try:
        return float(s)
    except ValueError:
        return None


def extract_grams(item):
    """Trả về số gram của 1 dòng nguyên liệu (ml ~ g).

    ƯU TIÊN gram NGOÀI ngoặc trước, vì ngoặc thường là 'tương đương' gây nhầm
    (vd '100g gạo lứt sống (~250g cơm chín)' -> phải lấy 100g, không phải 250g).
    """
    noparen = re.sub(r"\([^)]*\)", "", item)
    # 0) kg / lít (đặt TRƯỚC 'g'/'ml') -> đổi ra gram
    m = re.search(r"(\d+(?:[.,]\d+)?)\s*kg\b", noparen)
    if m:
        return float(m.group(1).replace(",", ".")) * 1000
    m = re.search(r"(\d+(?:[.,]\d+)?)\s*(?:lít|lit)\b", noparen)
    if m:
        return float(m.group(1).replace(",", ".")) * 1000
    # 1) gram ngoài ngoặc: "100g ức gà"
    m = re.search(r"(\d+(?:[.,]\d+)?)\s*g\b", noparen)
    if m:
        return float(m.group(1).replace(",", "."))
    # 2) ml ngoài ngoặc ~ g: "200ml sữa", "5ml dầu"
    m = re.search(r"(\d+(?:[.,]\d+)?)\s*ml\b", noparen)
    if m:
        return float(m.group(1).replace(",", "."))
    # 3) gram trong ngoặc (khi ngoài không có): "1/2 quả bơ (~80g)", "2 trứng (~100g)"
    m = re.search(r"~?\s*(\d+(?:[.,]\d+)?)\s*g\b", item)
    if m:
        return float(m.group(1).replace(",", "."))
    # 4) đơn vị đếm: "2 tép tỏi", "1/2 quả bơ"
    m = re.search(r"(\d+(?:[./,]\d+)?)\s*(tép|củ|nhánh|lá|tấm|miếng|scoop|nhúm|cây|viên|quả|trái|thanh|hoa|mcf)\b", item, flags=re.IGNORECASE)
    if m:
        n = frac(m.group(1)) or 0
        return n * UNIT_G.get(m.group(2).lower(), 0)
    return 0.0


_BOUND = r"(?:^|[\s,()/\-–+])"  # ranh giới: đầu/cuối chuỗi hoặc dấu cách/ngăn cách
_BOUND_END = r"(?:$|[\s,()/\-–+])"


def contains_kw(name, kw):
    """Khớp keyword theo RANH GIỚI TỪ, tránh 'miến'⊂'miếng', 'heo'⊂'theo'."""
    return re.search(_BOUND + re.escape(kw) + _BOUND_END, name) is not None


def lookup(name_lower):
    for kw, vals in NUTRI:
        if contains_kw(name_lower, kw):
            return vals
    return None


def strip_qty(item):
    s = re.sub(r"\([^)]*\)", "", item)
    s = re.sub(r"[~≈]", "", s)
    s = re.sub(r"\b\d+([.,/]\d+)?\s*(g|gram|ml|kg|l|mcf|muỗng|thìa|tép|củ|quả|lá|cây|tấm|nhánh|miếng|hộp|scoop|cái|lát|nhúm|thanh|hoa|viên)\b", "", s, flags=re.IGNORECASE)
    s = re.sub(r"^\s*\d+([.,/]\d+)?\s*", "", s)
    return re.sub(r"\s+", " ", s).strip(" ,.:|-").lower()


def split_ingredients(text):
    delim = "|" if "|" in text else ","
    return smart_split(text, delim)


# Keyword đạm chính (thịt/cá/trứng/hải sản) -> dùng ước lượng số khẩu phần
MEAT_KW = {
    "ức gà", "đùi gà", "gà", "thịt bò", "bò", "sườn", "thịt heo nạc", "heo nạc",
    "thịt heo", "heo", "ba chỉ", "lợn nạc", "thịt lợn", "lợn", "thịt băm",
    "nạc vai", "giò sống", "mọc", "vịt", "cá hồi", "cá thu", "cá basa", "cá ngừ",
    "cá", "tôm", "mực", "ốc", "tép", "ngán", "ngao", "trứng",
}


def estimate_servings(meat_g, total_g):
    """Ước lượng số khẩu phần để quy macro về 1 phần ăn.

    Món có đạm: ~160g đạm sống / phần. Món rau/chè: ~350g thực phẩm / phần.
    """
    if meat_g >= 80:
        return max(1, min(6, round(meat_g / 160)))
    if total_g >= 300:
        return max(1, min(5, round(total_g / 350)))
    return 1


def estimate_dish(ing_text):
    carbs = fat = kcal = prot = 0.0
    matched_g = total_g = meat_g = 0.0
    unmatched = []
    for item in split_ingredients(ing_text):
        g = extract_grams(item)
        name = strip_qty(item)
        total_g += g
        if any(z in name for z in NEG_ZERO) and lookup(name) is None:
            matched_g += g  # coi gia vị như đã xử lý (macro ~0)
            continue
        vals = lookup(name)
        if vals is None:
            if g > 0:
                unmatched.append(name)
            continue
        c, fa, kc, pr = vals
        carbs += g * c / 100
        fat += g * fa / 100
        kcal += g * kc / 100
        prot += g * pr / 100
        matched_g += g
        for mk in MEAT_KW:
            if contains_kw(name, mk):
                meat_g += g
                break
    cov = (matched_g / total_g * 100) if total_g else 100.0
    servings = estimate_servings(meat_g, total_g)
    return {
        "carbs": round(carbs), "fat": round(fat),
        "kcal": round(kcal), "protein": round(prot),
        "cov": round(cov), "unmatched": unmatched, "servings": servings,
    }


def main():
    if len(sys.argv) < 2:
        sys.exit("Cách dùng: python tools/estimate_macros.py <Cravvy_FoodDB_All.csv>")
    src = Path(sys.argv[1])
    out = src.with_name(src.stem + "_with_macros.csv")

    rows, fieldnames = [], None
    flags, low_cov = [], []
    unmatched_all = Counter()
    processed = 0

    with src.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        cols = {(c or "").lower(): c for c in reader.fieldnames}
        fieldnames = list(reader.fieldnames)
        for c in ("Carbs (g)", "Fat (g)", "Calo_tinh", "Protein_tinh", "Cov_%", "Servings_est"):
            if c not in fieldnames:
                fieldnames.append(c)

        ncol = cols.get("nguyên liệu chính")
        for row in reader:
            sheet = row.get(cols.get("sheet_id"), "")
            approved = (row.get(cols.get("approved")) or "").upper()
            ing = row.get(ncol) or ""
            if sheet != "05_72_Mon_Cu" and approved == "APPROVED" and ing.strip():
                est = estimate_dish(ing)
                row["Carbs (g)"] = est["carbs"]
                row["Fat (g)"] = est["fat"]
                row["Calo_tinh"] = est["kcal"]
                row["Protein_tinh"] = est["protein"]
                row["Cov_%"] = est["cov"]
                row["Servings_est"] = est["servings"]
                processed += 1
                for u in est["unmatched"]:
                    unmatched_all[u] += 1
                name = row.get(cols.get("tên món"), "")
                cal_est = None
                m = re.search(r"\d+", (row.get(cols.get("calo (est)")) or ""))
                if m:
                    cal_est = int(m.group())
                if cal_est and cal_est > 0:
                    dev = abs(est["kcal"] - cal_est) / cal_est * 100
                    if dev > FLAG_PCT:
                        flags.append((round(dev), cal_est, est["kcal"], est["cov"], f"{sheet}#{row.get(cols.get('stt'))}", name))
                if est["cov"] < LOW_COVERAGE:
                    low_cov.append((est["cov"], f"{sheet}#{row.get(cols.get('stt'))}", name))
            rows.append(row)

    with out.open("w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)

    print(f"✓ Đã tính macro cho {processed} món -> {out}")
    print(f"\n— {len(flags)} món LỆCH CALO > {FLAG_PCT}% (calo_est vs calo_tính) — nên rà tay:")
    for dev, ce, ck, cov, tag, name in sorted(flags, reverse=True):
        print(f"   {dev:>3}%  est={ce:<4} tính={ck:<4} cov={cov:>3}%  {tag}  {name}")
    print(f"\n— {len(low_cov)} món PHỦ NGUYÊN LIỆU < {LOW_COVERAGE}% (có thể thiếu trong bảng):")
    for cov, tag, name in sorted(low_cov):
        print(f"   cov={cov:>3}%  {tag}  {name}")
    if unmatched_all:
        print(f"\n— Nguyên liệu CHƯA map (top 25, cân nhắc thêm vào bảng NUTRI):")
        for name, c in unmatched_all.most_common(25):
            print(f"   {c:>3}x  {name}")


if __name__ == "__main__":
    main()
