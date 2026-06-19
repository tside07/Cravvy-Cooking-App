#!/usr/bin/env python3
"""Quick Supabase checks for Slice B (freemium schema + recipe catalog)."""
from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv
from supabase import create_client

ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / "tools" / ".env")

url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
if not url or not key:
    raise SystemExit("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in tools/.env")

client = create_client(url, key)

recipes = client.table("recipes").select("id", count="exact").eq("is_active", True).execute()
print(f"Active recipes: {recipes.count}")

sample = (
    client.table("recipes")
    .select("name, ingredients, source")
    .eq("source", "cravvy_curated_vn")
    .limit(3)
    .execute()
)
print("Sample curated VN recipes:")
for row in sample.data or []:
    ing = row.get("ingredients") or []
    name = str(row.get("name", "")).encode("ascii", "replace").decode()
    print(f"  - {name}: {len(ing)} ingredients")

profiles = client.table("profiles").select("subscription_tier, premium_until").limit(1).execute()
if profiles.data:
    print("profiles.subscription_tier: OK")
else:
    print("profiles: no rows (column may still exist)")

try:
    client.table("user_weekly_usage").select("user_id").limit(1).execute()
    print("user_weekly_usage table: OK")
except Exception as exc:
    print(f"user_weekly_usage: MISSING — run supabase/RUN_IN_SQL_EDITOR_slice_b.sql ({exc})")
    raise SystemExit(1) from exc

print("\nSlice B verify: PASS")
