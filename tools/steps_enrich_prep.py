#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Prep input cho workflow ENRICH STEPS của 159 món mới.

Chia data/seeds/cravvy_curated_159.json thành các chunk nhỏ, mỗi chunk 1 file
tools/_steps_in_{N}.json. Mỗi agent đọc đúng file của mình -> copy source_id y
nguyên -> trả steps đã chuẩn hoá (tránh nhầm index như đợt món cũ).

  python tools/steps_enrich_prep.py            # chunk mặc định 10 món/agent
  python tools/steps_enrich_prep.py --chunk 12
"""
from __future__ import annotations
import argparse, json, math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEED = ROOT / "data" / "seeds" / "cravvy_curated_159.json"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--chunk", type=int, default=10)
    args = ap.parse_args()

    recs = json.loads(SEED.read_text(encoding="utf-8"))["recipes"]
    # dọn file chunk cũ
    for old in ROOT.glob("tools/_steps_in_*.json"):
        old.unlink()

    n = args.chunk
    nchunks = math.ceil(len(recs) / n)
    manifest = []
    for ci in range(nchunks):
        part = recs[ci * n:(ci + 1) * n]
        items = [{
            "source_id": r["source_id"],
            "name": r["name"],
            "meal_type": r["meal_type"],
            "prep_time": r.get("prep_time"),
            "difficulty": r.get("difficulty"),
            "calories": r.get("calories"),
            "ingredients": r.get("ingredients") or [],
            "current_steps": r.get("steps") or [],
        } for r in part]
        f = ROOT / "tools" / f"_steps_in_{ci}.json"
        f.write_text(json.dumps(items, ensure_ascii=False, indent=2), encoding="utf-8")
        manifest.append({"chunk": ci, "file": f.name, "count": len(items),
                         "first": items[0]["source_id"], "last": items[-1]["source_id"]})

    print(json.dumps({"total": len(recs), "chunk_size": n, "nchunks": nchunks,
                      "manifest": manifest}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
