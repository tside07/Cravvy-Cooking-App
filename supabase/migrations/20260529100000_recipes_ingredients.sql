-- Add ingredients list to recipes (short strings from seed / import).
alter table public.recipes
  add column if not exists ingredients text[] not null default '{}';

comment on column public.recipes.ingredients is
  'Ingredient lines for meal detail & shopping list (e.g. "200g ức gà", "hành lá").';
