#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sinh 159 prompt AI-image (đồng bộ 1 style) cho các món MỚI (source_id bắt đầu bằng số).
Đọc data/seeds/cravvy_curated_159.json -> _image_prompts.csv + _image_prompts.html.

Dịch tên món VN -> mô tả EN bằng từ điển ẩm thực (khớp cụm dài trước), kèm tên VN gốc
làm ngữ cảnh dự phòng cho model. Báo các từ chưa dịch để bổ sung từ điển.

  python tools/gen_image_prompts.py
"""
from __future__ import annotations
import csv, html, json, re, unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEED = json.load(open(ROOT / "data/seeds/cravvy_curated_159.json", encoding="utf-8"))["recipes"]
OUT_CSV = ROOT / "tools" / "_image_prompts.csv"
OUT_HTML = ROOT / "tools" / "_image_prompts.html"

# Style ĐỒNG BỘ cho cả 159 ảnh (đổi ở 1 chỗ -> đổi cả bộ)
STYLE = ("appetizing professional food photography, healthy Vietnamese meal-prep style, "
         "served in a simple modern ceramic bowl or plate on a light oak wood table with soft linen, "
         "bright soft natural daylight, 45-degree angle, vibrant fresh colours, shallow depth of field, "
         "clean minimal styling, photorealistic, high detail, 4:3, no text, no watermark, no hands")

MEAL_CTX = {"breakfast": "a healthy breakfast of", "lunch": "a healthy lunch of",
            "dinner": "a healthy dinner of", "snack": "a healthy snack/dessert of"}

# Từ điển VN -> EN (cụm DÀI đặt TRƯỚC để khớp ưu tiên)
TERMS = [
    # phương pháp + cụm
    ("không tinh bột", "low-carb"), ("tinh bột", "starch"), ("không cơm", "no rice"),
    ("không đường", "unsweetened"), ("không", "no"),
    ("bơ đậu phộng", "peanut butter"), ("đậu phộng", "peanut"), ("hạnh nhân", "almond"),
    ("hạt dẻ cười", "pistachio"), ("hạt điều", "cashew"), ("óc chó", "walnut"),
    ("nấm bào ngư", "oyster mushroom"), ("bào ngư", "abalone"), ("nấm đông cô", "shiitake mushroom"),
    ("hành tây", "onion"), ("hành lá", "scallion"), ("hành", "scallion"), ("phi lê", "fillet"),
    ("đậu hà lan", "green peas"), ("đậu nành", "soybean"), ("rang khô", "dry-roasted"),
    ("cải xanh", "mustard greens"), ("ngô", "sweet corn"), ("bắp", "sweet corn"),
    ("dầu olive", "olive oil"), ("dầu", "olive oil"), ("ít đường", "low-sugar"),
    ("tự làm", "homemade"), ("tự nhiên", "natural"), ("nguyên hạt", "wholegrain"),
    ("sốt chanh dây", "passion-fruit sauce"), ("sốt cam tỏi", "orange-garlic sauce"),
    ("sốt chanh", "lemon sauce"), ("sốt cà chua", "tomato sauce"), ("sốt mè rang", "roasted sesame sauce"),
    ("sốt mè", "sesame sauce"), ("sốt sữa chua", "yogurt dressing"), ("sốt bơ", "avocado dressing"),
    ("sốt tương hàn quốc", "korean soybean sauce"), ("sốt miso", "miso sauce"), ("sốt", "sauce"),
    ("áp chảo", "pan-seared"), ("nướng giấy bạc", "foil-grilled"), ("nướng mật ong", "honey-grilled"),
    ("nướng", "grilled"), ("hấp", "steamed"), ("luộc", "boiled"), ("xào", "stir-fried"),
    ("kho tiêu", "pepper-braised"), ("kho", "braised"), ("chiên", "fried"), ("cuộn", "rolled"),
    ("rim", "caramel-braised"), ("rang", "roasted"), ("trộn", "tossed"), ("nghiền", "mashed"),
    ("cuốn", "rolls"), ("nhồi", "stuffed"), ("xé", "shredded"), ("bằm", "minced"), ("băm", "minced"),
    # đạm
    ("ức gà", "chicken breast"), ("đùi gà", "chicken thigh"), ("gà", "chicken"),
    ("thịt bò", "beef"), ("bò", "beef"), ("thịt heo nạc", "lean pork"), ("thịt nạc", "lean pork"),
    ("heo", "pork"), ("sườn", "ribs"), ("cá hồi", "salmon"), ("cá basa", "basa fish"),
    ("cá thu", "mackerel"), ("cá ngừ", "tuna"), ("cá", "fish"), ("tôm", "shrimp"), ("mực", "squid"),
    ("ốc", "snails"), ("trứng ốp la", "fried egg"), ("trứng", "egg"), ("đậu hũ non", "silken tofu"),
    ("đậu hũ", "tofu"), ("đậu phụ", "tofu"), ("đậu gà", "chickpeas"), ("đậu lăng", "lentils"),
    ("edamame", "edamame"), ("whey", "whey protein"), ("phô mai", "cheese"),
    # tinh bột
    ("yến mạch", "oats"), ("cơm gạo lứt", "brown rice"), ("gạo lứt", "brown rice"),
    ("bún gạo lứt", "brown-rice noodles"), ("bún lứt", "brown-rice noodles"), ("bún", "rice noodles"),
    ("bánh mì đen", "dark wholegrain bread"), ("bánh mì nguyên cám", "wholegrain bread"),
    ("bánh mì", "bread"), ("bánh tráng", "rice paper"), ("khoai lang", "sweet potato"),
    ("khoai tây", "potato"), ("quinoa", "quinoa"), ("diêm mạch", "quinoa"), ("granola", "granola"),
    ("xôi xéo", "turmeric sticky rice"), ("xôi", "sticky rice"), ("miến", "glass noodles"),
    ("nui", "macaroni"), ("mì ý", "pasta"), ("mì", "noodles"), ("phở", "pho noodle soup"),
    ("cháo", "rice/oat porridge"), ("bánh chuối", "banana cake"), ("bánh roti", "roti flatbread"),
    ("bánh", "cake"), ("overnight oats", "overnight oats"),
    # rau củ
    ("rau củ", "mixed vegetables"), ("rau muống", "water spinach"), ("rau bina", "spinach"),
    ("cải bó xôi", "spinach"), ("cải cầu vồng", "rainbow chard"), ("bông cải xanh", "broccoli"),
    ("bông cải", "broccoli"), ("súp lơ", "cauliflower"), ("măng tây", "asparagus"),
    ("ớt chuông", "bell pepper"), ("cà chua", "tomato"), ("cà rốt", "carrot"), ("dưa leo", "cucumber"),
    ("bí đỏ", "pumpkin"), ("bí ngòi", "zucchini"), ("bí đao", "winter melon"), ("nấm kim châm", "enoki mushroom"),
    ("nấm đùi gà", "king oyster mushroom"), ("nấm", "mushroom"), ("đậu bắp", "okra"),
    ("đậu cô ve", "green beans"), ("đậu ve", "green beans"), ("bắp cải", "cabbage"),
    ("xà lách", "lettuce"), ("rau diếp", "lettuce"), ("cần tây", "celery"), ("hạt sen", "lotus seeds"),
    ("cà tím", "eggplant"), ("mít non", "young jackfruit"), ("rong biển", "seaweed"), ("rau sống", "fresh herbs"),
    ("măng", "bamboo shoots"), ("mộc nhĩ", "wood-ear mushroom"), ("salad", "salad"),
    # trái cây / topping
    ("chuối", "banana"), ("xoài", "mango"), ("việt quất", "blueberry"), ("dâu", "strawberry"),
    ("táo", "apple"), ("cam", "orange"), ("dứa", "pineapple"), ("nha đam", "aloe vera"),
    ("long nhãn", "longan"), ("trái cây", "fresh fruit"), ("bơ", "avocado"), ("hạt chia", "chia seeds"),
    ("hạt", "nuts and seeds"), ("mè", "sesame"), ("dừa", "coconut"),
    # món / chế biến
    ("sinh tố", "smoothie"), ("smoothie", "smoothie"), ("sữa chua hy lạp", "greek yogurt"),
    ("sữa chua", "yogurt"), ("sữa hạt", "plant-based milk"), ("sữa tươi", "milk"), ("sữa đậu nành", "soy milk"),
    ("súp", "soup"), ("canh", "clear soup"), ("chè", "sweet bean dessert"), ("nước ép", "fresh juice"),
    ("sữa", "milk"),
    # gia vị / phụ
    ("mật ong", "honey"), ("mật mía", "molasses"), ("muối mè", "sesame salt"), ("muối ớt", "chilli salt"),
    ("muối", "salt"), ("chanh dây", "passion fruit"), ("chanh", "lime"), ("sả", "lemongrass"),
    ("gừng", "ginger"), ("tỏi", "garlic"), ("ớt", "chilli"), ("tiêu", "pepper"),
    ("nguyên cám", "wholegrain"), ("ít béo", "low-fat"),
    ("theo mùa", "seasonal"), ("tươi", "fresh"), ("chín", "ripe"), ("hà lan", "peas"),
    ("nấu", "with"), ("hầm", "stewed"), ("thịt", "meat"), ("đậu", "beans"),
    ("cơm", "rice"), ("cải", "leafy greens"), ("rau", "vegetables"),
    # nối / bỏ
    (" và ", " and "), ("bỏ da", "skinless"),
]
DROP = {"mix", "non", "ngọt", "nạc", "đỏ", "xanh", "trắng", "đen", "cát", "ta", "đồng", "biển",
        "½", "quả", "ngũ", "sắc", "thập", "cẩm", "kiểu", "vị", "cốt", "bột", "khô", "tây",
        "nguyên", "mùa", "lê", "bó", "m", "g", "nhân", "phộng", "dẻ", "cười", "đông", "cô"}


def strip_acc(s):
    s = unicodedata.normalize("NFD", s)
    return "".join(c for c in s if unicodedata.category(c) != "Mn").replace("đ", "d").replace("Đ", "D")


def translate(name):
    s = name.lower()
    s = re.sub(r"\([^)]*\)", " ", s)        # bỏ ngoặc
    s = re.sub(r"[,/+]", " ", s)
    s = " " + re.sub(r"\s+", " ", s).strip() + " "
    for vn, en in TERMS:
        # chỉ thay khi vn là CHUỖI TOKEN trọn vẹn (kề hai bên là dấu cách) -> tránh 'cá'⊂'cám'
        s = re.sub(r"(?<= )" + re.escape(vn.strip()) + r"(?= )", " " + en + " ", s)
        s = re.sub(r"\s+", " ", s)
    s = s.strip()
    leftover = [w for w in s.split() if any(ord(c) > 127 for c in w) and w not in DROP]
    words, seen = [], set()
    for w in s.split():
        if any(ord(c) > 127 for c in w) or w in DROP:
            continue
        if w not in seen or w in {"and", "with"}:   # bỏ lặp từ (vd 'chicken chicken')
            seen.add(w); words.append(w)
    gloss = " ".join(words).strip(" ,-")
    return gloss, leftover


def main():
    new = [r for r in SEED if r["source_id"][0].isdigit()]
    rows, leftovers = [], {}
    for r in sorted(new, key=lambda x: x["source_id"]):
        gloss, lo = translate(r["name"])
        for w in lo:
            leftovers[w] = leftovers.get(w, 0) + 1
        ctx = MEAL_CTX.get(r["meal_type"], "a healthy dish of")
        prompt = f'{ctx} {gloss} (Vietnamese dish "{r["name"]}"), {STYLE}'
        rows.append({"source_id": r["source_id"], "name": r["name"],
                     "filename": f'{r["source_id"]}.jpg', "meal_type": r["meal_type"],
                     "gloss": gloss, "prompt": prompt})

    with OUT_CSV.open("w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["source_id", "name", "filename", "meal_type", "prompt"])
        w.writeheader()
        for r in rows:
            w.writerow({k: r[k] for k in ["source_id", "name", "filename", "meal_type", "prompt"]})

    # HTML copy-friendly (artifact)
    def esc(x): return html.escape(str(x))
    trs = "\n".join(
        f'<tr data-n="{esc(r["name"].lower())}"><td class="sid">{esc(r["filename"])}'
        f'<span class="meal {r["meal_type"]}">{r["meal_type"]}</span></td>'
        f'<td class="nm">{esc(r["name"])}</td>'
        f'<td class="pr"><span>{esc(r["prompt"])}</span>'
        f'<button class="cp" data-p="{esc(r["prompt"])}">Copy</button></td></tr>' for r in rows)
    OUT_HTML.write_text(f'''<title>159 prompt ảnh AI — Cravvy</title>
<meta name="description" content="159 prompt tạo ảnh AI đồng bộ cho các món eat-clean của Cravvy, kèm nút copy.">
<style>
:root{{--paper:#F6F2EC;--ink:#241F1B;--muted:#8A7F73;--line:#E7DFD4;--accent:#9C3A26;}}
*{{box-sizing:border-box}}
body{{margin:0;background:var(--paper);color:var(--ink);font-family:-apple-system,"Segoe UI",Roboto,sans-serif;line-height:1.5}}
.wrap{{max-width:1080px;margin:0 auto;padding:22px 18px 70px}}
h1{{font-family:Georgia,serif;font-size:23px;margin:0 0 4px}}
h1 b{{color:var(--accent)}}
.lead{{color:var(--muted);font-size:13.5px;margin:0 0 18px}}
.style{{background:#fff;border:1px solid var(--line);border-radius:10px;padding:12px 14px;margin-bottom:18px}}
.style .lbl{{font-size:11px;letter-spacing:.6px;text-transform:uppercase;color:var(--accent);font-weight:700}}
.style code{{display:block;font-family:ui-monospace,Consolas,monospace;font-size:12px;color:#3f3a34;margin-top:6px;line-height:1.5}}
.bar{{display:flex;gap:10px;align-items:center;margin-bottom:12px;position:sticky;top:0;background:var(--paper);padding:10px 0;border-bottom:1px solid var(--line);z-index:2}}
.bar input{{flex:1;padding:8px 12px;border:1px solid var(--line);border-radius:8px;font-size:14px}}
table{{border-collapse:collapse;width:100%;background:#fff;border:1px solid var(--line);border-radius:10px;overflow:hidden}}
th{{text-align:left;padding:9px 11px;background:#efe7db;font-size:12px;text-transform:uppercase;letter-spacing:.4px}}
td{{border-top:1px solid var(--line);padding:9px 11px;vertical-align:top;font-size:13px}}
.sid{{font-family:ui-monospace,Consolas,monospace;font-size:11px;white-space:nowrap;color:var(--muted)}}
.meal{{display:block;margin-top:4px;font-family:-apple-system,sans-serif;font-size:10px;color:#fff;background:#b9a78f;border-radius:4px;padding:1px 5px;width:max-content;text-transform:uppercase}}
.meal.breakfast{{background:#C26A1B}}.meal.lunch{{background:#2E7D4F}}.meal.dinner{{background:#2D6A9F}}.meal.snack{{background:#9C3A26}}
.nm{{font-family:Georgia,serif;min-width:140px}}
.pr{{color:#4a443d}}
.pr span{{display:block}}
.cp{{margin-top:7px;font-size:11px;border:1px solid var(--line);background:#faf7f2;border-radius:6px;padding:3px 10px;cursor:pointer;color:var(--ink)}}
.cp:hover{{background:#fff}}.cp.ok{{background:#2E7D4F;color:#fff;border-color:#2E7D4F}}
footer{{color:var(--muted);font-size:12px;margin-top:18px}}
</style>
<div class="wrap">
<h1><b>Cravvy</b> · 159 prompt ảnh AI (style đồng bộ)</h1>
<p class="lead">Dán từng prompt vào trình tạo ảnh AI (Gemini / ChatGPT / Flux…). Lưu ảnh đúng tên <code>filename</code> rồi upload lên bucket <code>recipe-images</code> → chạy <code>backfill_images.py</code>.</p>
<div class="style"><span class="lbl">Style chung (đã nằm trong mọi prompt)</span><code id="st">{esc(STYLE)}</code>
<button class="cp" data-p="{esc(STYLE)}" style="margin-top:8px">Copy style</button></div>
<div class="bar"><input id="q" type="search" placeholder="Lọc món… (vd: salad, cá hồi, chè)"><span id="ct" class="sid"></span></div>
<table><thead><tr><th>File / bữa</th><th>Món</th><th>Prompt (kèm nút copy)</th></tr></thead>
<tbody id="tb">{trs}</tbody></table>
<footer>{len(rows)} món · ảnh AI nên khai báo trong mục đạo đức báo cáo · đặt tên file = source_id để pipeline tự gắn link.</footer>
</div>
<script>
const rows=[...document.querySelectorAll('#tb tr')],q=document.getElementById('q'),ct=document.getElementById('ct');
function upd(){{const t=q.value.trim().toLowerCase();let n=0;rows.forEach(r=>{{const ok=!t||r.dataset.n.includes(t);r.style.display=ok?'':'none';if(ok)n++}});ct.textContent=n+' món'}}
q.addEventListener('input',upd);upd();
document.addEventListener('click',e=>{{const b=e.target.closest('.cp');if(!b)return;
navigator.clipboard.writeText(b.dataset.p).then(()=>{{const o=b.textContent;b.textContent='✓ Đã copy';b.classList.add('ok');setTimeout(()=>{{b.textContent=o;b.classList.remove('ok')}},1200)}})}});
</script>''', encoding="utf-8")

    print(f"✓ {len(rows)} prompt -> {OUT_CSV.name} + {OUT_HTML.name}")
    if leftovers:
        print(f"⚠ {len(leftovers)} từ CHƯA dịch (bổ sung TERMS nếu nhiều):")
        for w, c in sorted(leftovers.items(), key=lambda x: -x[1])[:25]:
            print(f"   {c:>2}x  {w}")
    print("\n--- 4 prompt mẫu ---")
    for r in rows[:4]:
        print(f'[{r["filename"]}] {r["prompt"]}\n')


if __name__ == "__main__":
    main()
