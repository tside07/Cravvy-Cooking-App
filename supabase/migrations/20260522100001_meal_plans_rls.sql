-- RLS for meal_plans (client CRUD). Edge Function uses service_role and bypasses RLS.

ALTER TABLE meal_plans ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS meal_plans_select_own ON meal_plans;
CREATE POLICY meal_plans_select_own ON meal_plans
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS meal_plans_insert_own ON meal_plans;
CREATE POLICY meal_plans_insert_own ON meal_plans
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS meal_plans_update_own ON meal_plans;
CREATE POLICY meal_plans_update_own ON meal_plans
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS meal_plans_delete_own ON meal_plans;
CREATE POLICY meal_plans_delete_own ON meal_plans
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);
