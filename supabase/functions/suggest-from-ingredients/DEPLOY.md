# Deploy: `suggest-from-ingredients`

AI "cook from my ingredients" feature (Search → Type tab).
Strategy: **Cache → DB recipes → Gemini (last)** so it runs on the Gemini free tier.

---

## Prerequisites

- Supabase CLI installed (`supabase --version` → 2.x).
- You know your **project-ref** (Dashboard → Settings → General → "Reference ID",
  or the slug in `https://supabase.com/dashboard/project/<project-ref>`).

---

## 1. Database tables (run SQL by hand)

Two new tables back this feature:

- `ingredient_suggestion_cache` — server-side cache keyed by sorted ingredients
  + locale (24h TTL). Many users with the same ingredients cost ONE Gemini call.
- `ingredient_suggestion_usage` — per-user/day counter of REAL Gemini calls
  (cache/DB hits are free and not counted).

**Apply via Dashboard (does NOT touch the 12 older migrations):**

1. Open **Supabase Dashboard → SQL Editor → New query**.
2. Copy the full contents of
   [`supabase/migrations/20260617100000_ingredient_suggestions.sql`](../../migrations/20260617100000_ingredient_suggestions.sql)
   and paste it in.
3. Click **Run**. You should see "Success. No rows returned".

> Re-running is safe — every statement uses `IF NOT EXISTS` / `DROP POLICY IF EXISTS`.

---

## 2. Log in + link (one-time)

```bash
supabase login                              # opens browser; no token to share
supabase link --project-ref <YOUR_REF>      # asks for DB password
```

---

## 3. Gemini secret

The function needs `GEMINI_API_KEY`. The existing `generate-meal-plan` and
`cooking-chat` functions already use it, so it's likely set. Verify:

```bash
supabase secrets list
```

If `GEMINI_API_KEY` is missing:

```bash
supabase secrets set GEMINI_API_KEY=<your-gemini-key>
```

Optional model override (defaults to `gemini-2.5-flash`):

```bash
supabase secrets set GEMINI_MODEL=gemini-2.5-flash
```

### Dish photos (Pexels) — optional but recommended

AI-generated dishes rarely match a real `recipes` row, so without this they fall
back to a meal-type icon. Set a free Pexels key to fetch a real stock photo per
dish (the model returns English `image_query` keywords for better matches):

1. Sign up at <https://www.pexels.com/api/> → "Get Started" (free, instant).
2. Copy your API key from the dashboard.
3. Set it:

```bash
supabase secrets set PEXELS_API_KEY=<your-pexels-key>
```

Free tier: ~200 requests/hour, 20,000/month. Pexels is only hit on a cache-miss
+ AI generation, and the result is cached for 24h, so real traffic stays far
under the limit. If `PEXELS_API_KEY` is unset, the feature still works — dishes
just show the icon placeholder.

---

## 4. Deploy the function

```bash
supabase functions deploy suggest-from-ingredients
```

`config.toml` already declares it with `verify_jwt = true`, matching the other
functions (a logged-in user's JWT is required).

---

## 5. Smoke test

In the app: Search tab → add a few ingredients (e.g. rice, egg, onion) →
tap **"Suggest dishes with AI"**. You should get 3–4 dishes; tapping one opens
the existing meal-detail + cooking-mode flow with full steps.

Server-side logs:

```bash
supabase functions logs suggest-from-ingredients
```

What to expect:
- First call for a new ingredient set → may hit Gemini (slower, ~a few seconds).
- Repeat call with the same ingredients → served from cache (instant).
- If Gemini is rate-limited / over quota → you still get DB matches plus an
  "AI is busy" note in the UI (never a blank screen).

---

## Rate limits (per user / day — counts REAL Gemini calls only)

| Tier | Limit |
|------|-------|
| Free | 5 |
| Premium / Trial | 15 |

Cache hits and DB-matched results do **not** count against the limit.
Tune in two places (keep them in sync):
- Flutter: `PlanLimits.freeAiSuggestDailyLimit` / `premiumAiSuggestDailyLimit`
- Edge Function: `FREE_DAILY_LIMIT` / `PREMIUM_DAILY_LIMIT` at the top of `index.ts`

> ⚠️ The Gemini key is currently on the **free tier** (~250 requests/day for the
> WHOLE app, shared across all 3 functions). The cache is what makes this viable.
> Before a real ~100-user launch, set up billing (Pay-as-you-go Tier 1) and you
> can raise the limits by editing just those constants.
