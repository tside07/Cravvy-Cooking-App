# Import recipe catalog — Cravvy

## Quick start (Windows)

```powershell
cd E:\Project\Flutter\CravvyCookingApp\Cravvy-Cooking-App
copy tools\.env.example tools\.env
# Edit tools\.env with SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY

.\tools\import_catalog.ps1
```

## Manual steps

```bash
pip install -r tools/requirements.txt
python tools/generate_vn_seed.py      # ~100 VN dishes → data/seeds/vietnamese_recipes.json
python tools/validate_seed.py         # must exit 0
python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json --dry-run
python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json
```

## Verify on Supabase

```sql
SELECT count(*) FROM recipes WHERE source = 'cravvy_curated_vn' AND is_active = true;
```

Target: **≥ 100** rows.

## Prerequisites

- Run **`supabase/migrations/20260522120000_recipes_provenance.sql`** in Supabase SQL Editor  
  (fixes error `42P10` / `no unique constraint matching ON CONFLICT`)
- Service role key in `tools/.env` (never commit real keys)

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Python was not found` | Install Python 3.11+, disable Store alias, or use WSL |
| Upsert conflict | Ensure unique index on `(source, source_id)` exists |
| Empty catalog in app | Run import; check `is_active = true` |
| Free user sees no recipes | Recipes need `source = 'cravvy_curated_vn'` or `source IS NULL` |

See also: [docs/WEEK4_PRE_DEPLOY_CHECKLIST.md](../docs/WEEK4_PRE_DEPLOY_CHECKLIST.md)
