#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Turnkey: tạo 159 ảnh AI cho các món MỚI -> upload Supabase Storage -> set image_url.

Đọc tools/_image_prompts.csv (source_id, name, filename, meal_type, prompt).
Tự phát hiện provider theo API key có sẵn (đặt 1 trong các key vào tools/.env hoặc env):

  OPENAI_API_KEY        -> OpenAI Images (gpt-image-1)
  GEMINI_API_KEY        -> Google Imagen 3 (Gemini API)
  REPLICATE_API_TOKEN   -> Replicate Flux (schnell, rẻ)

Chạy 1 lệnh là xong cả pipeline:

  python tools/gen_images_api.py                 # gen còn thiếu + upload + set image_url + verify
  python tools/gen_images_api.py --dry-run       # kiểm tra mọi thứ, KHÔNG gọi API / KHÔNG ghi
  python tools/gen_images_api.py --limit 5       # chỉ 5 món đầu (test rẻ)
  python tools/gen_images_api.py --only 02_trua_eat_clean_01
  python tools/gen_images_api.py --provider openai --model gpt-image-1
  python tools/gen_images_api.py --upload-only   # bỏ qua gen, chỉ upload ảnh đã có trong thư mục
  python tools/gen_images_api.py --no-upload     # chỉ gen, chưa upload

Resume an toàn: ảnh đã có trong thư mục out -> bỏ qua (trừ --force). Retry 3 lần/ảnh.
"""
from __future__ import annotations
import argparse, base64, csv, hashlib, io, os, sys, time, urllib.parse
from pathlib import Path

import httpx
from dotenv import load_dotenv
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CSV = ROOT / "tools" / "_image_prompts.csv"
OUT_DIR = ROOT / "tools" / "_gen_images"
BUCKET = "recipe-images"
SOURCE = "cravvy_curated_vn"
CT = {"jpg": "image/jpeg", "png": "image/png", "webp": "image/webp"}
TIMEOUT = 180


# ─────────────────────────── Providers (REST) ──────────────────────────────
def gen_openai(prompt, key, model, size):
    r = httpx.post(
        "https://api.openai.com/v1/images/generations",
        headers={"Authorization": f"Bearer {key}"},
        json={"model": model or "gpt-image-1", "prompt": prompt,
              "size": size or "1024x1024", "n": 1},
        timeout=TIMEOUT)
    r.raise_for_status()
    d = r.json()["data"][0]
    if d.get("b64_json"):
        return base64.b64decode(d["b64_json"])
    return httpx.get(d["url"], timeout=TIMEOUT).content


def gen_gemini(prompt, key, model, size):
    m = model or "imagen-3.0-generate-002"
    r = httpx.post(
        f"https://generativelanguage.googleapis.com/v1beta/models/{m}:predict?key={key}",
        json={"instances": [{"prompt": prompt}],
              "parameters": {"sampleCount": 1, "aspectRatio": "4:3"}},
        timeout=TIMEOUT)
    r.raise_for_status()
    preds = r.json().get("predictions", [])
    if not preds:
        raise RuntimeError(f"Gemini: không có prediction ({r.text[:200]})")
    return base64.b64decode(preds[0]["bytesBase64Encoded"])


def gen_replicate(prompt, key, model, size):
    mdl = model or "black-forest-labs/flux-schnell"
    r = httpx.post(
        f"https://api.replicate.com/v1/models/{mdl}/predictions",
        headers={"Authorization": f"Bearer {key}", "Prefer": "wait"},
        json={"input": {"prompt": prompt, "aspect_ratio": "4:3", "output_format": "jpg"}},
        timeout=TIMEOUT)
    r.raise_for_status()
    pred = r.json()
    # nếu chưa xong (không hỗ trợ Prefer:wait), poll
    url = pred.get("urls", {}).get("get")
    for _ in range(60):
        st = pred.get("status")
        if st == "succeeded":
            break
        if st in ("failed", "canceled"):
            raise RuntimeError(f"Replicate {st}: {pred.get('error')}")
        time.sleep(2)
        pred = httpx.get(url, headers={"Authorization": f"Bearer {key}"}, timeout=TIMEOUT).json()
    out = pred["output"]
    out = out[0] if isinstance(out, list) else out
    return httpx.get(out, timeout=TIMEOUT).content


def gen_pollinations(prompt, key, model, size):
    """MIỄN PHÍ, không cần key (pollinations.ai). Seed cố định theo prompt -> resume ổn định."""
    seed = int(hashlib.md5(prompt.encode("utf-8")).hexdigest()[:7], 16)
    url = ("https://image.pollinations.ai/prompt/" + urllib.parse.quote(prompt)
           + f"?width=1024&height=768&nologo=true&model={model or 'flux'}&seed={seed}")
    r = httpx.get(url, timeout=TIMEOUT, follow_redirects=True)
    r.raise_for_status()
    if r.content[:3] not in (b"\xff\xd8\xff", b"\x89PN"):
        raise RuntimeError(f"pollinations trả về non-image: {r.text[:120]}")
    return r.content


PROVIDERS = {
    "openai": ("OPENAI_API_KEY", gen_openai),
    "gemini": ("GEMINI_API_KEY", gen_gemini),
    "replicate": ("REPLICATE_API_TOKEN", gen_replicate),
    "pollinations": (None, gen_pollinations),  # free, no key
}


def detect_provider(forced):
    if forced:
        env, fn = PROVIDERS[forced]
        return forced, (os.environ.get(env) if env else "") or "", fn
    for name in ("openai", "gemini", "replicate"):
        env, fn = PROVIDERS[name]
        key = (os.environ.get(env) or "").strip()
        if key:
            return name, key, fn
    g = (os.environ.get("GOOGLE_API_KEY") or "").strip()
    if g:
        return "gemini", g, gen_gemini
    # Fallback MIỄN PHÍ: pollinations (không cần key)
    return "pollinations", "", gen_pollinations


def to_jpeg(raw: bytes) -> bytes:
    im = Image.open(io.BytesIO(raw)).convert("RGB")
    b = io.BytesIO(); im.save(b, "JPEG", quality=86)
    return b.getvalue()


# ─────────────────────────── Supabase upload ───────────────────────────────
def sb_client():
    from supabase import create_client
    url = (os.environ.get("SUPABASE_URL") or "").strip()
    key = (os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or "").strip()
    if not url or not key:
        sys.exit("Thiếu SUPABASE_URL / SERVICE_ROLE_KEY trong tools/.env")
    return create_client(url, key)


def upload_and_link(c, sid, path: Path):
    target = f"{sid}.jpg"
    data = path.read_bytes()
    try:
        c.storage.from_(BUCKET).upload(target, data,
                                       {"content-type": "image/jpeg", "upsert": "true"})
    except Exception:
        c.storage.from_(BUCKET).update(target, data,
                                       {"content-type": "image/jpeg", "upsert": "true"})
    public = c.storage.from_(BUCKET).get_public_url(target)
    c.table("recipes").update({"image_url": public}).eq("source", SOURCE).eq("source_id", sid).execute()


# ─────────────────────────────── Main ──────────────────────────────────────
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--provider", choices=list(PROVIDERS))
    ap.add_argument("--model")
    ap.add_argument("--size", help="OpenAI size, vd 1024x1024 / 1536x1024")
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--only")
    ap.add_argument("--force", action="store_true", help="gen lại cả ảnh đã có")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--no-upload", action="store_true")
    ap.add_argument("--upload-only", action="store_true")
    args = ap.parse_args()

    load_dotenv(ROOT / "tools" / ".env"); load_dotenv(ROOT / ".env")
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    rows = list(csv.DictReader(open(CSV, encoding="utf-8-sig")))
    if args.only:
        rows = [r for r in rows if r["source_id"] == args.only]
    if args.limit:
        rows = rows[:args.limit]
    print(f"Món xử lý: {len(rows)} | thư mục ảnh: {OUT_DIR}")

    # ── Phase GEN ──
    if not args.upload_only:
        prov, key, fn = detect_provider(args.provider)
        free = prov == "pollinations"
        keymsg = "FREE (no key)" if free else ("SET" if key else "MISSING")
        print(f"Provider: {prov} | model: {args.model or '(mặc định)'} | key: {keymsg}")

        todo = [r for r in rows if args.force or not (OUT_DIR / f'{r["source_id"]}.jpg').exists()]
        print(f"Cần gen: {len(todo)} (bỏ qua {len(rows) - len(todo)} ảnh đã có)")
        if args.dry_run:
            print("\n[DRY] Provider call mẫu cho món đầu:")
            if rows:
                print(f"   provider={prov or '(none)'}  prompt[:160]= {rows[0]['prompt'][:160]}…")
            print("[DRY] Không gọi API, không ghi file.")
        elif prov and (key or free):
            ok = fail = 0
            for i, r in enumerate(todo, 1):
                sid = r["source_id"]
                for attempt in range(1, 4):
                    try:
                        raw = fn(r["prompt"], key, args.model, args.size)
                        (OUT_DIR / f"{sid}.jpg").write_bytes(to_jpeg(raw))
                        ok += 1
                        print(f"  [{i}/{len(todo)}] ✓ {sid}")
                        break
                    except Exception as e:
                        msg = str(e)[:140]
                        if attempt < 3:
                            time.sleep(3 * attempt)
                        else:
                            fail += 1
                            print(f"  [{i}/{len(todo)}] ✗ {sid}: {msg}")
                time.sleep(0.4)  # nhẹ tay rate-limit
            print(f"\nGen xong: ok={ok} fail={fail}")

    # ── Phase UPLOAD + LINK ──
    if args.no_upload:
        print("(--no-upload) Bỏ qua upload.")
        return
    have = [(r["source_id"], OUT_DIR / f'{r["source_id"]}.jpg') for r in rows
            if (OUT_DIR / f'{r["source_id"]}.jpg').exists()]
    print(f"\nẢnh sẵn sàng upload: {len(have)}/{len(rows)}")
    if args.dry_run:
        for sid, p in have[:5]:
            print(f"   [dry] {p.name} -> bucket {BUCKET}/{sid}.jpg + set image_url")
        print("[DRY] Không upload.")
        return
    if not have:
        print("Chưa có ảnh nào để upload.")
        return
    c = sb_client()
    up = 0
    for sid, p in have:
        try:
            upload_and_link(c, sid, p); up += 1
            if up % 20 == 0:
                print(f"  ... upload {up}/{len(have)}")
        except Exception as e:
            print(f"  ✗ upload {sid}: {str(e)[:120]}")
    # verify: đếm món MỚI (source_id bắt đầu bằng số) đã có image_url
    allrows = c.table("recipes").select("source_id,image_url,is_active")\
        .eq("source", SOURCE).execute().data
    new159 = [r for r in allrows if r["source_id"][:1].isdigit()]
    withimg = sum(1 for r in new159 if r["image_url"])
    print(f"\nUpload+link phiên này: {up} ảnh.")
    print(f"VERIFY — món mới (source_id số): {len(new159)} | đã có image_url: {withimg} | còn thiếu: {len(new159) - withimg}")
    print("Done.")


if __name__ == "__main__":
    main()
