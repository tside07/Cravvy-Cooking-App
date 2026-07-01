#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Tạo trang review HTML (thumbnail base64 + macro/tag) cho 94 món cũ đã import."""
from __future__ import annotations
import base64, html, io, json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SEED = json.load(open(ROOT / "data/seeds/cravvy_moncu.json", encoding="utf-8"))["recipes"]
INP = {d["source_id"]: d for d in json.loads((ROOT / "tools/_moncu_input.json").read_text(encoding="utf-8"))}
IMG_DIR = Path(r"C:\Users\Admin\Downloads\Ảnh Danh Mục-20260626T012247Z-3-001\Ảnh Danh Mục")
OUT = ROOT / "tools" / "_moncu_review.html"

MEALS = [("breakfast", "Bữa sáng"), ("lunch", "Bữa trưa"), ("dinner", "Bữa tối"), ("snack", "Ăn vặt / Tráng miệng")]


def thumb(path: Path, w=300) -> str:
    im = Image.open(path).convert("RGB")
    if im.width > w:
        im = im.resize((w, round(im.height * w / im.width)))
    b = io.BytesIO()
    im.save(b, "JPEG", quality=72)
    return "data:image/jpeg;base64," + base64.b64encode(b.getvalue()).decode()


def esc(s): return html.escape(str(s))


def card(r):
    sid = r["source_id"]
    img = INP[sid]["image_file"]
    src = thumb(IMG_DIR / img)
    tags = "".join(f'<span class="tag">{esc(t)}</span>' for t in r["tags"][:6])
    name = esc(r["name"])
    return f'''<article class="card" data-name="{name.lower()}" data-meal="{r['meal_type']}">
  <div class="thumb"><img loading="lazy" src="{src}" alt="{name}"></div>
  <div class="body">
    <h3>{name}</h3>
    <div class="sid">{esc(sid)} &middot; {esc(img)}</div>
    <div class="macros">
      <span class="m cal"><b>{r['calories']}</b><i>kcal</i></span>
      <span class="m pro"><b>{r['protein']}</b><i>đạm</i></span>
      <span class="m car"><b>{r['carbs']}</b><i>carb</i></span>
      <span class="m fat"><b>{r['fat']}</b><i>béo</i></span>
    </div>
    <div class="tags">{tags}</div>
  </div>
</article>'''


def main():
    by_meal = {m: [] for m, _ in MEALS}
    for r in sorted(SEED, key=lambda x: x["source_id"]):
        by_meal.setdefault(r["meal_type"], []).append(r)

    sections = []
    for key, label in MEALS:
        items = by_meal.get(key, [])
        if not items:
            continue
        cards = "\n".join(card(r) for r in items)
        sections.append(
            f'<section class="meal" data-section="{key}">'
            f'<div class="sec-head"><h2>{label}</h2><span class="count">{len(items)} món</span></div>'
            f'<div class="grid">{cards}</div></section>')

    total = len(SEED)
    counts = " &middot; ".join(f"{lbl} {len(by_meal.get(k, []))}" for k, lbl in MEALS if by_meal.get(k))

    page = f'''<title>Món cũ — review {total} món</title>
<meta name="description" content="Soát ảnh, macro và tag của {total} món truyền thống trước khi lên app Cravvy.">
<style>
:root{{
  --paper:#F6F2EC; --card:#FFFFFF; --ink:#241F1B; --muted:#8A7F73; --line:#E7DFD4;
  --accent:#9C3A26; --cal:#B8860B; --pro:#2E7D4F; --car:#2D6A9F; --fat:#C26A1B;
}}
*{{box-sizing:border-box}}
body{{margin:0;background:var(--paper);color:var(--ink);
  font-family:-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;line-height:1.45}}
.wrap{{max-width:1180px;margin:0 auto;padding:0 18px 64px}}
header.top{{position:sticky;top:0;z-index:5;background:rgba(246,242,236,.94);
  backdrop-filter:blur(8px);border-bottom:1px solid var(--line);padding:14px 18px;margin-bottom:8px}}
.top-in{{max-width:1180px;margin:0 auto;display:flex;flex-wrap:wrap;gap:12px 18px;align-items:baseline}}
.brand{{font-family:Georgia,"Times New Roman",serif;font-size:21px;font-weight:700;
  letter-spacing:.2px}}
.brand b{{color:var(--accent)}}
.sub{{color:var(--muted);font-size:13px}}
.search{{margin-left:auto;flex:0 1 280px}}
.search input{{width:100%;padding:8px 12px;border:1px solid var(--line);border-radius:8px;
  background:#fff;font-size:14px;color:var(--ink)}}
.search input:focus{{outline:2px solid var(--accent);outline-offset:1px;border-color:transparent}}
.meal{{margin-top:30px}}
.sec-head{{display:flex;align-items:baseline;gap:12px;margin:0 0 14px;
  border-bottom:2px solid var(--accent);padding-bottom:6px}}
.sec-head h2{{font-family:Georgia,"Times New Roman",serif;font-size:19px;margin:0;font-weight:700}}
.count{{color:var(--muted);font-size:13px;font-variant-numeric:tabular-nums}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(212px,1fr));gap:16px}}
.card{{background:var(--card);border:1px solid var(--line);border-radius:12px;overflow:hidden;
  display:flex;flex-direction:column;box-shadow:0 1px 2px rgba(36,31,27,.04)}}
.thumb{{aspect-ratio:4/3;background:#efe7db;overflow:hidden}}
.thumb img{{width:100%;height:100%;object-fit:cover;display:block}}
.body{{padding:11px 12px 13px;display:flex;flex-direction:column;gap:7px}}
.body h3{{font-family:Georgia,"Times New Roman",serif;font-size:15px;margin:0;line-height:1.25;
  text-wrap:balance}}
.sid{{font-family:ui-monospace,"Cascadia Mono",Consolas,monospace;font-size:10.5px;color:var(--muted);
  word-break:break-all}}
.macros{{display:flex;gap:6px;flex-wrap:wrap;margin-top:2px}}
.m{{display:flex;flex-direction:column;align-items:center;min-width:42px;padding:5px 6px;
  border-radius:7px;background:#faf7f2;border:1px solid var(--line)}}
.m b{{font-size:14px;font-variant-numeric:tabular-nums;line-height:1}}
.m i{{font-style:normal;font-size:9.5px;color:var(--muted);margin-top:3px;text-transform:uppercase;
  letter-spacing:.4px}}
.m.cal b{{color:var(--cal)}} .m.pro b{{color:var(--pro)}}
.m.car b{{color:var(--car)}} .m.fat b{{color:var(--fat)}}
.tags{{display:flex;flex-wrap:wrap;gap:4px;margin-top:2px}}
.tag{{font-size:10.5px;color:#5c5249;background:#f1ece4;border:1px solid var(--line);
  padding:2px 7px;border-radius:99px}}
.empty{{color:var(--muted);padding:40px 0;text-align:center;display:none}}
footer{{margin-top:40px;color:var(--muted);font-size:12px;text-align:center;
  border-top:1px solid var(--line);padding-top:18px}}
@media (max-width:520px){{.grid{{grid-template-columns:repeat(auto-fill,minmax(150px,1fr))}}}}
</style>

<header class="top">
  <div class="top-in">
    <span class="brand"><b>Cravvy</b> · Món cũ truyền thống</span>
    <span class="sub">{total} món · ảnh thật · macro/khẩu phần ước tính (USDA/VN) · {counts}</span>
    <span class="search"><input id="q" type="search" placeholder="Tìm món… (vd: phở, vịt, chè)" aria-label="Tìm món"></span>
  </div>
</header>

<div class="wrap">
{''.join(sections)}
  <div class="empty" id="empty">Không có món nào khớp.</div>
  <footer>Ảnh từ danh mục bạn lọc · macro/tag chuẩn hoá tự động per khẩu phần (có disclaimer dinh dưỡng trong app) · source_id <code>moncu_*</code> · is_active=true.</footer>
</div>

<script>
const q=document.getElementById('q'),cards=[...document.querySelectorAll('.card')],
  secs=[...document.querySelectorAll('.meal')],empty=document.getElementById('empty');
q.addEventListener('input',()=>{{
  const t=q.value.trim().toLowerCase();let n=0;
  cards.forEach(c=>{{const ok=!t||c.dataset.name.includes(t);c.style.display=ok?'':'none';if(ok)n++;}});
  secs.forEach(s=>{{const vis=[...s.querySelectorAll('.card')].some(c=>c.style.display!=='none');
    s.style.display=vis?'':'none';}});
  empty.style.display=n?'none':'block';
}});
</script>'''
    OUT.write_text(page, encoding="utf-8")
    print(f"✓ {OUT}  ({OUT.stat().st_size//1024} KB, {total} món)")


if __name__ == "__main__":
    main()
