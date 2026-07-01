#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Merge steps đã enrich (tools/_steps_out_*.json) -> cập nhật field "steps" trong
data/seeds/cravvy_curated_159.json. KHÔNG đụng field nào khác.

  python tools/steps_merge_to_seed.py            # dry-run: chỉ báo cáo
  python tools/steps_merge_to_seed.py --write     # ghi vào seed (có backup .bak)
"""
from __future__ import annotations
import argparse, glob, json, unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEED = ROOT / "data" / "seeds" / "cravvy_curated_159.json"


def nfc(s: str) -> str:
    return unicodedata.normalize("NFC", str(s)).strip()


def load_outputs() -> dict[str, list[str]]:
    out: dict[str, list[str]] = {}
    files = sorted(glob.glob(str(ROOT / "tools" / "_steps_out_*.json")))
    for f in files:
        try:
            data = json.loads(Path(f).read_text(encoding="utf-8"))
        except Exception as e:
            print(f"  ! parse fail {Path(f).name}: {e}")
            continue
        # chấp nhận cả [..] lẫn {"recipes":[..]}
        if isinstance(data, dict):
            data = data.get("recipes") or data.get("steps") or []
        for r in data:
            sid = nfc(r.get("source_id", ""))
            steps = [nfc(s) for s in (r.get("steps") or []) if nfc(s)][:12]
            if sid and steps:
                out[sid] = steps
    print(f"Đọc {len(files)} file output -> {len(out)} món có steps.")
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()

    doc = json.loads(SEED.read_text(encoding="utf-8"))
    recs = doc["recipes"]
    seed_ids = {nfc(r["source_id"]) for r in recs}

    enriched = load_outputs()
    enriched_ids = set(enriched)

    missing = sorted(seed_ids - enriched_ids)   # trong seed nhưng chưa enrich
    extra = sorted(enriched_ids - seed_ids)      # enrich ra source_id lạ
    print(f"Seed: {len(recs)} món | enriched: {len(enriched)} | thiếu: {len(missing)} | lạ: {len(extra)}")
    if missing:
        print("  THIẾU:", missing)
    if extra:
        print("  LẠ   :", extra)

    # so sánh độ dài steps trước/sau
    before = sum(len(r.get("steps") or []) for r in recs)
    after = sum(len(enriched.get(nfc(r["source_id"]), r.get("steps") or [])) for r in recs)
    print(f"Tổng số bước: trước={before} -> sau={after} (TB {before/len(recs):.1f} -> {after/len(recs):.1f})")

    if not args.write:
        print("\n[DRY-RUN] chưa ghi. Thêm --write để cập nhật seed.")
        return

    if missing:
        print("\n! Còn món THIẾU steps — KHÔNG ghi để tránh seed dở dang. Chạy lại workflow cho chunk lỗi trước.")
        return

    bak = SEED.with_suffix(".bak.json")
    bak.write_text(SEED.read_text(encoding="utf-8"), encoding="utf-8")
    for r in recs:
        sid = nfc(r["source_id"])
        if sid in enriched:
            r["steps"] = enriched[sid]
    SEED.write_text(json.dumps(doc, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\nĐã ghi seed (backup: {bak.name}). Cập nhật steps cho {len(enriched)} món.")


if __name__ == "__main__":
    main()
