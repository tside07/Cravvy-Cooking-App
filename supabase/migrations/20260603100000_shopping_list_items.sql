-- Per-user shopping list (syncs with Flutter ShoppingListProvider).

CREATE TABLE IF NOT EXISTS shopping_list_items (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  recipe_id TEXT NOT NULL,
  recipe_name TEXT NOT NULL,
  name TEXT NOT NULL,
  checked BOOLEAN NOT NULL DEFAULT false,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 1),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS shopping_list_items_user_id_idx
  ON shopping_list_items (user_id);

ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS shopping_list_items_select_own ON shopping_list_items;
CREATE POLICY shopping_list_items_select_own ON shopping_list_items
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS shopping_list_items_insert_own ON shopping_list_items;
CREATE POLICY shopping_list_items_insert_own ON shopping_list_items
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS shopping_list_items_update_own ON shopping_list_items;
CREATE POLICY shopping_list_items_update_own ON shopping_list_items
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS shopping_list_items_delete_own ON shopping_list_items;
CREATE POLICY shopping_list_items_delete_own ON shopping_list_items
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);
