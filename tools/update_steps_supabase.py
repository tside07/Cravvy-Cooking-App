#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Cập nhật CHỈ cột "steps" của 159 món mới trên Supabase (UPDATE theo source+source_id).
KHÔNG đụng image_url / macro / tag... -> giữ nguyên link ảnh Pollinations đã set.

  python tools/update_steps_supabase.py --dry-run
  python tools/update_steps_supabase.py            # thực thi
"""
from __future__ import annotations
import argparse, json, os, sys
from pathlib import Path

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[1]
SEED = ROOT / "data" / "seeds" / "cravvy_curated_159.json"
SOURCE = "cravvy_curated_vn"


def client():
    load_dotenv(ROOT / "tools" / ".env"); load_dotenv(ROOT / ".env")
    from supabase import create_client
    url = (os.environ.get("SUPABASE_URL") or "").strip()
    key = (os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or "").strip()
    if not url or not key:
        sys.exit("Thiếu SUPABASE_URL / SERVICE_ROLE_KEY trong tools/.env")
    return create_client(url, key)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    recs = json.loads(SEED.read_text(encoding="utf-8"))["recipes"]
    # chỉ món mới (source_id bắt đầu bằng số)
    new = [r for r in recs if str(r["source_id"])[:1].isdigit()]
    print(f"Món mới trong seed: {len(new)}")

    if args.dry_run:
        for r in new[:3]:
            print(f"  [dry] {r['source_id']} <- {len(r['steps'])} bước: {r['steps'][0][:50]}…")
        print("[DRY-RUN] không gọi DB.")
        return

    c = client()
    up = fail = 0
    for r in new:
        sid = str(r["source_id"])
        try:
            c.table("recipes").update({"steps": r["steps"]}) \
                .eq("source", SOURCE).eq("source_id", sid).execute()
            up += 1
            if up % 30 == 0:
                print(f"  ... {up}/{len(new)}")
        except Exception as e:
            fail += 1
            print(f"  ✗ {sid}: {str(e)[:120]}")

    # verify: đọc lại từ DB, đếm món mới có steps >=3 và image_url còn nguyên
    rows = c.table("recipes").select("source_id,steps,image_url") \
        .eq("source", SOURCE).execute().data
    new_rows = [x for x in rows if str(x["source_id"])[:1].isdigit()]
    with_steps = sum(1 for x in new_rows if x.get("steps") and len(x["steps"]) >= 3)
    with_img = sum(1 for x in new_rows if (x.get("image_url") or "").strip())
    print(f"\nUpdate steps: ok={up} fail={fail}")
    print(f"VERIFY DB — món mới: {len(new_rows)} | steps>=3: {with_steps} | image_url còn: {with_img}")
    print("Done.")


if __name__ == "__main__":
    main()
