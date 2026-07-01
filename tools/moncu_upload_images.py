#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Upload ảnh món cũ lên Supabase Storage bucket 'recipe-images' với tên = <source_id>.<ext>,
rồi set recipes.image_url cho từng món (không phụ thuộc is_active).

Map ảnh lấy từ tools/_moncu_input.json (đã gán source_id <-> image_file).

  python tools/moncu_upload_images.py --dry-run
  python tools/moncu_upload_images.py
"""
from __future__ import annotations
import argparse, json, os, sys
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client

ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "tools" / "_moncu_input.json"
IMG_DIR = Path(r"C:\Users\Admin\Downloads\Ảnh Danh Mục-20260626T012247Z-3-001\Ảnh Danh Mục")
BUCKET = "recipe-images"
SOURCE = "cravvy_curated_vn"
CT = {"jpg": "image/jpeg", "jpeg": "image/jpeg", "png": "image/png", "webp": "image/webp"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    load_dotenv(ROOT / "tools" / ".env"); load_dotenv(ROOT / ".env")
    url = (os.environ.get("SUPABASE_URL") or "").strip()
    key = (os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or "").strip()
    if not url or not key or "YOUR_PROJECT" in url:
        sys.exit("Thiếu SUPABASE_URL / SERVICE_ROLE_KEY hợp lệ trong tools/.env")
    c = create_client(url, key)

    inp = json.loads(INPUT.read_text(encoding="utf-8"))
    up = linked = skipped = 0
    for d in inp:
        sid, ext = d["source_id"], d["image_ext"]
        local = IMG_DIR / d["image_file"]
        if not local.exists():
            print(f"  ! thiếu file: {local.name}"); skipped += 1; continue
        target = f"{sid}.{ext}"
        if args.dry_run:
            print(f"  [dry] {local.name:34} -> {target}"); up += 1; continue
        data = local.read_bytes()
        try:
            c.storage.from_(BUCKET).upload(
                target, data,
                {"content-type": CT.get(ext, "image/jpeg"), "upsert": "true"})
        except Exception as e:
            # đã tồn tại -> overwrite
            try:
                c.storage.from_(BUCKET).update(
                    target, data,
                    {"content-type": CT.get(ext, "image/jpeg"), "upsert": "true"})
            except Exception as e2:
                print(f"  ! upload lỗi {target}: {e2}"); skipped += 1; continue
        public = c.storage.from_(BUCKET).get_public_url(target)
        c.table("recipes").update({"image_url": public}).eq("source", SOURCE).eq("source_id", sid).execute()
        up += 1; linked += 1
        if up % 20 == 0:
            print(f"  ... {up} ảnh")

    print(f"\n{'(DRY) ' if args.dry_run else ''}Upload: {up} | set image_url: {linked} | skip: {skipped}")


if __name__ == "__main__":
    main()
