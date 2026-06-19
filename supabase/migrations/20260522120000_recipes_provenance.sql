-- Recipe catalog provenance (dataset import / thesis attribution)
ALTER TABLE recipes
  ADD COLUMN IF NOT EXISTS source text,
  ADD COLUMN IF NOT EXISTS source_id text,
  ADD COLUMN IF NOT EXISTS locale text DEFAULT 'vi';

COMMENT ON COLUMN recipes.source IS 'Dataset or author key, e.g. crafty_curated_vn, huggingface_recipes_nutrition';
COMMENT ON COLUMN recipes.source_id IS 'Stable id within source for idempotent upsert';
COMMENT ON COLUMN recipes.locale IS 'Primary language: vi, en, asian, etc.';

CREATE UNIQUE INDEX IF NOT EXISTS recipes_source_source_id_key
  ON recipes (source, source_id)
  WHERE source IS NOT NULL AND source_id IS NOT NULL;
