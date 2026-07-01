#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Backfill recipes.image_url từ ảnh đã upload lên Supabase Storage bucket 'recipe-images'.

Quy ước: tên file ảnh = source_id (vd '01_pool_bua_sang_03.jpg' / '.png' / '.webp').
Script liệt kê file trong bucket, ghép theo source_id, rồi UPDATE image_url = public URL.

  python tools/backfill_images.py            # chạy thật
  python tools/backfill_images.py --dry-run  # chỉ xem sẽ cập nhật gì
"""
from __future__ import annotations
import argparse, os, sys
from dotenv import load_dotenv
from supabase import create_client

BUCKET = "recipe-images"
SOURCE = "cravvy_curated_vn"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    load_dotenv("tools/.env"); load_dotenv(".env")
    url = (os.environ.get("SUPABASE_URL") or "").strip()
    key = (os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or "").strip()
    if not url or not key or "YOUR_PROJECT" in url:
        sys.exit("Thiếu SUPABASE_URL / SERVICE_ROLE_KEY hợp lệ trong tools/.env")
    c = create_client(url, key)

    # 1) Liệt kê file trong bucket (phân trang)
    files, off = [], 0
    while True:
        batch = c.storage.from_(BUCKET).list(
            options={"limit": 100, "offset": off, "sortBy": {"column": "name", "order": "asc"}})
        if not batch:
            break
        files += [f["name"] for f in batch if f.get("name") and not f["name"].startswith(".")]
        if len(batch) < 100:
            break
        off += 100
    # stem (bỏ đuôi) -> tên file
    by_stem = {}
    for fn in files:
        stem = fn.rsplit(".", 1)[0]
        by_stem.setdefault(stem, fn)
    print(f"Ảnh trong bucket '{BUCKET}': {len(files)}")

    # 2) Lấy recipe đang hiện
    rows = c.table("recipes").select("id,source_id,name,image_url")\
        .eq("source", SOURCE).eq("is_active", True).execute().data

    upd = miss = 0
    for r in rows:
        fn = by_stem.get(r["source_id"])
        if not fn:
            miss += 1
            continue
        public_url = c.storage.from_(BUCKET).get_public_url(fn)
        if r.get("image_url") == public_url:
            continue
        if args.dry_run:
            print(f"  [dry] {r['source_id']:<22} <- {fn}")
        else:
            c.table("recipes").update({"image_url": public_url}).eq("id", r["id"]).execute()
        upd += 1

    print(f"\n{'(DRY) ' if args.dry_run else ''}Cập nhật image_url: {upd} món")
    print(f"Chưa có ảnh trong bucket: {miss} món (chưa upload file <source_id>.jpg)")


if __name__ == "__main__":
    main()
