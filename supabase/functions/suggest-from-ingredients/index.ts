// Supabase Edge Function: "Cook from my ingredients" (Search > Type tab).
//
// Given the ingredients a user already has, returns 3-4 cookable dishes with
// full steps + nutrition + a best-effort image. Strategy is CACHE → DB recipes
// → Gemini (last), because the Gemini free tier (~250 req/day for the WHOLE
// app) cannot sustain an AI-call-per-request design.
//
//   1. Cache  — keyed by sorted ingredients + locale (24h TTL). Many users with
//               the same ingredients cost ONE Gemini call.
//   2. DB     — match real `recipes` rows by ingredient overlap (real images +
//               steps, zero tokens).
//   3. Gemini — only when cache misses AND DB has too few matches. Result is
//               written back to cache. Counts against the per-user daily cap.
//
// On Gemini quota/429 the function still returns DB matches (never a blank
// screen) with `ai_unavailable: true` so the client can show a "try later" note.
//
// Auto-injected: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY
// Secrets: GEMINI_API_KEY (required), GEMINI_MODEL (optional, default gemini-2.5-flash)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Keep in sync with `PlanLimits.freeRecipeSources` (Flutter).
const FREE_RECIPE_SOURCES = ["cravvy_curated_vn"] as const;

// Keep in sync with `PlanLimits.aiSuggest*` (Flutter). Counts REAL Gemini calls
// only — cache/DB hits are free and never counted.
const FREE_DAILY_LIMIT = 5;
const PREMIUM_DAILY_LIMIT = 15;

const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24h
const TARGET_SUGGESTIONS = 4; // how many dishes we try to return
const DB_MIN_BEFORE_GEMINI = 3; // enough DB matches → skip Gemini entirely
const MEAL_TYPES = ["breakfast", "lunch", "dinner", "snack"] as const;

interface Suggestion {
  name: string;
  description: string;
  meal_type: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  prep_time: number;
  difficulty: string;
  steps: string[];
  ingredients: string[];
  missing_ingredients: string[];
  image_url: string | null;
  source: "db" | "ai";
}

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function geminiModelName(): string {
  return Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash";
}

function usesThinkingBudget(model: string): boolean {
  return model.includes("2.5");
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isRateLimitError(e: unknown): boolean {
  const msg = e instanceof Error ? e.message : String(e);
  return msg.includes("429") || msg.toLowerCase().includes("rate");
}

function isPremiumTier(tier: string): boolean {
  return tier === "premium" || tier === "trial";
}

function startOfTodayUtcIso(): string {
  const now = new Date();
  const start = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
  );
  return start.toISOString();
}

/** Normalize + sort ingredients so "Rice, Egg" and "egg rice" share a key. */
function normalizeIngredients(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  const seen = new Set<string>();
  const out: string[] = [];
  for (const item of raw) {
    const s = String(item ?? "").trim().toLowerCase();
    if (s && !seen.has(s)) {
      seen.add(s);
      out.push(s);
    }
  }
  out.sort();
  return out.slice(0, 15); // guard against abusive payloads
}

async function sha256Hex(text: string): Promise<string> {
  const data = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function clampMealType(raw: unknown): string {
  const s = String(raw ?? "").toLowerCase();
  return (MEAL_TYPES as readonly string[]).includes(s) ? s : "lunch";
}

function clampDifficulty(raw: unknown): string {
  const s = String(raw ?? "").toLowerCase();
  return ["easy", "medium", "hard"].includes(s) ? s : "easy";
}

function toInt(raw: unknown): number {
  const n = Number(raw);
  return Number.isFinite(n) ? Math.max(0, Math.round(n)) : 0;
}

function toStringList(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  return raw.map((s) => String(s ?? "").trim()).filter(Boolean);
}

// ── DB matching ───────────────────────────────────────────────────────────────

/** Count how many of the user's ingredients appear in a recipe's corpus. */
function ingredientMatchScore(
  recipe: Record<string, unknown>,
  userIngredients: string[],
): number {
  const corpus = [
    String(recipe.name ?? ""),
    ...((recipe.ingredients as string[]) ?? []),
    ...((recipe.tags as string[]) ?? []),
  ]
    .join(" ")
    .toLowerCase();
  let score = 0;
  for (const ing of userIngredients) {
    if (corpus.includes(ing)) score++;
  }
  return score;
}

function recipeToSuggestion(r: Record<string, unknown>): Suggestion {
  return {
    name: String(r.name ?? ""),
    description: String(r.description ?? ""),
    meal_type: clampMealType(r.meal_type),
    calories: toInt(r.calories),
    protein: toInt(r.protein),
    carbs: toInt(r.carbs),
    fat: toInt(r.fat),
    prep_time: toInt(r.prep_time),
    difficulty: clampDifficulty(r.difficulty),
    steps: toStringList(r.steps),
    ingredients: toStringList(r.ingredients),
    missing_ingredients: [],
    image_url: (r.image_url as string | null) ?? null,
    source: "db",
  };
}

/** Best-effort image for an AI dish: reuse a real recipe photo by name/tag. */
function findImageForName(
  name: string,
  recipes: Record<string, unknown>[],
): string | null {
  const lower = name.toLowerCase();
  for (const r of recipes) {
    const rName = String(r.name ?? "").toLowerCase();
    const url = r.image_url as string | null;
    if (!url) continue;
    if (rName && (lower.includes(rName) || rName.includes(lower))) return url;
  }
  return null;
}

// ── Stock photos (Pexels) ─────────────────────────────────────────────────────
// Best-effort dish photo from Pexels when no DB image matched. Free tier:
// ~200 req/hour, 20k/month — only hit on cache-miss + AI generation, and the
// result is cached, so real traffic stays well under the limit.

async function fetchPexelsImage(
  query: string,
  apiKey: string,
): Promise<string | null> {
  const q = query.trim();
  if (!q) return null;
  try {
    const res = await fetch(
      `https://api.pexels.com/v1/search?per_page=1&orientation=landscape&query=${
        encodeURIComponent(q + " food dish")
      }`,
      { headers: { Authorization: apiKey } },
    );
    if (!res.ok) return null;
    const data = await res.json() as {
      photos?: Array<{ src?: { medium?: string; large?: string } }>;
    };
    const src = data.photos?.[0]?.src;
    return src?.medium ?? src?.large ?? null;
  } catch {
    return null;
  }
}

/** Fill missing images for AI suggestions via Pexels, in parallel. */
async function fillPexelsImages(
  items: Array<{ suggestion: Suggestion; imageQuery: string }>,
): Promise<void> {
  // Accept the common "PIXELS" misspelling as well as the correct "PEXELS".
  const apiKey = Deno.env.get("PEXELS_API_KEY") ??
    Deno.env.get("PIXELS_API_KEY");
  if (!apiKey) return; // Not configured → keep icon placeholders.

  await Promise.all(
    items.map(async ({ suggestion, imageQuery }) => {
      if (suggestion.image_url) return; // DB image already found.
      const query = imageQuery.trim() || suggestion.name;
      suggestion.image_url = await fetchPexelsImage(query, apiKey);
    }),
  );
}

// ── Gemini ──────────────────────────────────────────────────────────────────

const RESPONSE_SCHEMA = {
  type: "object",
  properties: {
    sufficient: { type: "boolean" },
    suggestions: {
      type: "array",
      items: {
        type: "object",
        properties: {
          name: { type: "string" },
          description: { type: "string" },
          meal_type: { type: "string" },
          calories: { type: "number" },
          protein: { type: "number" },
          carbs: { type: "number" },
          fat: { type: "number" },
          prep_time: { type: "number" },
          difficulty: { type: "string" },
          steps: { type: "array", items: { type: "string" } },
          ingredients: { type: "array", items: { type: "string" } },
          missing_ingredients: { type: "array", items: { type: "string" } },
          image_query: { type: "string" },
        },
        required: ["name", "meal_type", "calories", "steps", "ingredients"],
      },
    },
  },
  required: ["sufficient", "suggestions"],
} as const;

function extractTextFromGeminiResponse(data: unknown): string {
  const candidates = (data as {
    candidates?: Array<
      { content?: { parts?: Array<{ text?: string; thought?: boolean }> } }
    >;
  })?.candidates;
  const parts = candidates?.[0]?.content?.parts ?? [];
  const visible = parts
    .filter((p) => p.text && !p.thought)
    .map((p) => p.text as string);
  if (visible.length) return visible.join("");
  const anyText = parts.map((p) => p.text).filter(Boolean).join("");
  if (anyText) return anyText;
  throw new Error("Empty Gemini response");
}

async function callGeminiOnce(
  apiKey: string,
  model: string,
  systemPrompt: string,
  userPrompt: string,
): Promise<string> {
  const generationConfig: Record<string, unknown> = {
    temperature: 0.5,
    maxOutputTokens: 2048,
    responseMimeType: "application/json",
    responseSchema: RESPONSE_SCHEMA,
  };
  if (usesThinkingBudget(model)) {
    generationConfig.thinkingConfig = { thinkingBudget: 0 };
  }

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: systemPrompt }] },
        contents: [{ role: "user", parts: [{ text: userPrompt }] }],
        generationConfig,
      }),
    },
  );

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(
      `Gemini API error ${res.status} (${model}): ${errText.slice(0, 240)}`,
    );
  }

  const data = await res.json();
  return extractTextFromGeminiResponse(data);
}

async function callGemini(
  apiKey: string,
  systemPrompt: string,
  userPrompt: string,
): Promise<string> {
  const model = geminiModelName();
  let lastErr: unknown;
  for (let retry = 0; retry < 2; retry++) {
    try {
      return await callGeminiOnce(apiKey, model, systemPrompt, userPrompt);
    } catch (e) {
      lastErr = e;
      if (isRateLimitError(e) && retry < 1) {
        await sleep(3000 * (retry + 1));
        continue;
      }
      break;
    }
  }
  throw lastErr;
}

function buildSystemPrompt(
  profile: Record<string, unknown>,
  locale: string,
): string {
  const lang = locale.startsWith("vi") ? "Vietnamese" : "English";
  return [
    "You are Cravvy's recipe generator.",
    "The user tells you the ingredients they ALREADY have at home. Propose real,",
    "common dishes that are genuinely cooked MAINLY from those ingredients.",
    "",
    "HARD RULES — follow exactly:",
    "1. You may ONLY rely on the user's ingredients plus basic seasonings/pantry",
    "   staples: salt, pepper, sugar, cooking oil, water, fish sauce, soy sauce,",
    "   vinegar, and common dried spices. Nothing else is assumed.",
    "2. Do NOT introduce any other MAIN ingredient the user did not list — no",
    "   bread, rice, noodles, oats, flour, potato, meat, seafood, dairy, eggs,",
    "   or vegetables unless the user listed them. (E.g. if they only gave eggs",
    "   and tomato, suggest 'tomato egg stir-fry' or 'tomato egg soup', NEVER",
    "   'egg sandwich' or 'oatmeal with egg'.)",
    "3. If a dish realistically needs a small extra item (e.g. spring onion),",
    "   you MAY include it but you MUST list it in `missing_ingredients`.",
    "   Keep missing_ingredients SHORT and minor — never a main protein/carb.",
    "4. Prefer dishes that use as MANY of the user's ingredients as possible.",
    "",
    "Set `sufficient` to false when the listed ingredients are too few, too",
    "plain, or incompatible to make a complete, sensible, safe meal — in that",
    "case still return the best simple dishes you honestly can.",
    "",
    `Write all names, descriptions and steps in ${lang}.`,
    "",
    "User profile (respect strictly):",
    `- Goal: ${profile.goal ?? "maintain"}`,
    `- Diets: ${JSON.stringify(profile.diets ?? [])}`,
    `- Avoid foods/allergens: ${JSON.stringify(profile.avoid_foods ?? [])}`,
    `- Cooking time preference: ${profile.cooking_time ?? "any"}`,
    `- Cooking skill level: ${profile.skill_level ?? "intermediate"}`,
    "Never suggest a dish that uses an avoided food/allergen.",
    "Match the cooking time preference (quick≈≤15min, short≈≤30min,",
    "medium≈≤45min, long=elaborate) and keep steps appropriate to the skill",
    "level (beginner = simple, few steps; advanced = more technique is fine).",
    "",
    "For each dish provide: name, one-sentence description, meal_type (one of",
    "breakfast/lunch/dinner/snack), realistic calories/protein/carbs/fat (grams),",
    "prep_time (minutes), difficulty (easy/medium/hard), clear ordered cooking",
    "steps, the ingredients list (with rough quantities), and missing_ingredients",
    "(items needed beyond what the user has + basic seasonings; empty if none).",
    "Also include `image_query`: 2-4 ENGLISH keywords describing the finished",
    "dish for a stock-photo search (e.g. 'tomato egg soup', 'grilled salmon",
    "salad'). Always in English even when the dish name is Vietnamese.",
    'Respond as JSON: {"sufficient": <bool>, "suggestions": [ ... ]}.',
  ].join("\n");
}

function buildUserPrompt(ingredients: string[], count: number): string {
  return [
    `Ingredients I have: ${ingredients.join(", ")}.`,
    `Suggest ${count} different dishes I can cook mainly from these.`,
    "Prefer dishes that use as many of my ingredients as possible.",
  ].join("\n");
}

function parseGeminiSuggestions(
  text: string,
  recipes: Record<string, unknown>[],
): {
  sufficient: boolean;
  items: Array<{ suggestion: Suggestion; imageQuery: string }>;
} {
  let parsed: { suggestions?: unknown[]; sufficient?: unknown };
  try {
    parsed = JSON.parse(text);
  } catch {
    // Strip code fences then retry once.
    const cleaned = text.replace(/```json\n?/g, "").replace(/```/g, "").trim();
    parsed = JSON.parse(cleaned);
  }
  const list = Array.isArray(parsed.suggestions) ? parsed.suggestions : [];
  const items = list
    .map((raw) => {
      const r = raw as Record<string, unknown>;
      const name = String(r.name ?? "").trim();
      if (!name) return null;
      const suggestion: Suggestion = {
        name,
        description: String(r.description ?? "").trim(),
        meal_type: clampMealType(r.meal_type),
        calories: toInt(r.calories),
        protein: toInt(r.protein),
        carbs: toInt(r.carbs),
        fat: toInt(r.fat),
        prep_time: toInt(r.prep_time),
        difficulty: clampDifficulty(r.difficulty),
        steps: toStringList(r.steps),
        ingredients: toStringList(r.ingredients),
        missing_ingredients: toStringList(r.missing_ingredients),
        image_url: findImageForName(name, recipes),
        source: "ai",
      };
      return { suggestion, imageQuery: String(r.image_query ?? "").trim() };
    })
    .filter((x): x is { suggestion: Suggestion; imageQuery: string } =>
      x !== null
    );
  // Default to false only when explicitly false; missing flag ⇒ assume ok.
  const sufficient = parsed.sufficient !== false;
  return { sufficient, items };
}

// ── Handler ───────────────────────────────────────────────────────────────────

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Missing Authorization" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceKey) {
      return jsonResponse({ error: "Server configuration missing" }, 500);
    }

    const userClient = createClient(
      supabaseUrl,
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: userError } = await userClient.auth
      .getUser();
    if (userError || !user) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    const body = await req.json().catch(() => null) as {
      ingredients?: unknown;
      locale?: string;
    } | null;

    const ingredients = normalizeIngredients(body?.ingredients);
    const locale = (body?.locale ?? "en").toString();
    if (!ingredients.length) {
      return jsonResponse({ error: "ingredients required" }, 400);
    }

    const admin = createClient(supabaseUrl, serviceKey);
    const userId = user.id;

    // ── Profile + tier ────────────────────────────────────────────────────
    const { data: profile } = await admin
      .from("profiles")
      .select(
        "id, goal, diets, avoid_foods, cooking_time, skill_level, subscription_tier",
      )
      .eq("id", userId)
      .single();
    const safeProfile = profile ?? {};
    const tier = String(safeProfile.subscription_tier ?? "free");
    const dailyLimit = isPremiumTier(tier)
      ? PREMIUM_DAILY_LIMIT
      : FREE_DAILY_LIMIT;

    // ── 1. Cache lookup (free, no token) ───────────────────────────────────
    const cacheKey = await sha256Hex(ingredients.join(",") + "|" + locale);
    const { data: cached } = await admin
      .from("ingredient_suggestion_cache")
      .select("suggestions, created_at")
      .eq("cache_key", cacheKey)
      .maybeSingle();

    if (cached) {
      const age = Date.now() - new Date(String(cached.created_at)).getTime();
      if (age < CACHE_TTL_MS) {
        // Payload is `{ suggestions, sufficient }`; tolerate legacy bare arrays.
        const payload = cached.suggestions;
        const suggestions = Array.isArray(payload)
          ? payload
          : (payload?.suggestions ?? []);
        const sufficient = Array.isArray(payload)
          ? true
          : (payload?.sufficient ?? true);
        return jsonResponse({
          suggestions,
          sufficient,
          cached: true,
          ai_unavailable: false,
        });
      }
    }

    // ── Load catalog once (used for DB match + AI image lookup) ─────────────
    let recipesQuery = admin
      .from("recipes")
      .select(
        "id, name, description, image_url, meal_type, calories, protein, carbs, fat, prep_time, difficulty, tags, steps, ingredients, source",
      )
      .eq("is_active", true);
    if (!isPremiumTier(tier)) {
      recipesQuery = recipesQuery.or(
        `source.in.(${FREE_RECIPE_SOURCES.join(",")}),source.is.null`,
      );
    }
    const { data: recipes } = await recipesQuery;
    const catalog = recipes ?? [];

    // ── 2. DB matches by ingredient overlap (free, real images + steps) ─────
    // Require a meaningful overlap so a single shared word (e.g. only "gà" in
    // "Mì Quảng gà") doesn't surface a recipe that needs ingredients the user
    // doesn't have. Demand at least 2 matched ingredients (or all, if fewer).
    const requiredScore = Math.min(ingredients.length, 2);
    const dbMatches: Suggestion[] = catalog
      .map((r) => ({ r, score: ingredientMatchScore(r, ingredients) }))
      .filter((x) => x.score >= requiredScore)
      .sort((a, b) => b.score - a.score)
      .slice(0, TARGET_SUGGESTIONS)
      .map((x) => recipeToSuggestion(x.r));

    // Enough real recipes → return them, skip Gemini entirely.
    if (dbMatches.length >= DB_MIN_BEFORE_GEMINI) {
      // Backfill photos for any DB recipe lacking an image_url.
      await fillPexelsImages(
        dbMatches.map((s) => ({ suggestion: s, imageQuery: s.name })),
      );
      await admin.from("ingredient_suggestion_cache").upsert({
        cache_key: cacheKey,
        suggestions: { suggestions: dbMatches, sufficient: true },
        created_at: new Date().toISOString(),
      });
      return jsonResponse({
        suggestions: dbMatches,
        sufficient: true,
        cached: false,
        ai_unavailable: false,
      });
    }

    // ── Per-user daily cap (only gates the REAL Gemini call below) ──────────
    const { count: usedToday } = await admin
      .from("ingredient_suggestion_usage")
      .select("*", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", startOfTodayUtcIso());

    if ((usedToday ?? 0) >= dailyLimit) {
      // Out of AI budget → still return whatever DB had (may be empty).
      return jsonResponse({
        suggestions: dbMatches,
        sufficient: true,
        cached: false,
        ai_unavailable: true,
        error: "daily_limit",
        remaining_today: 0,
      });
    }

    // ── 3. Gemini (last resort) ─────────────────────────────────────────────
    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return jsonResponse({
        suggestions: dbMatches,
        sufficient: true,
        cached: false,
        ai_unavailable: true,
        error: "server_config",
      });
    }

    try {
      const text = await callGemini(
        apiKey,
        buildSystemPrompt(safeProfile, locale),
        buildUserPrompt(ingredients, TARGET_SUGGESTIONS),
      );
      const parsed = parseGeminiSuggestions(text, catalog);
      if (!parsed.items.length) throw new Error("Empty AI suggestions");

      // Best-effort dish photos for anything without a DB image.
      await fillPexelsImages(parsed.items);
      const aiSuggestions = parsed.items.map((x) => x.suggestion);

      // Record one AI call against the daily cap + cache the result.
      await admin.from("ingredient_suggestion_usage").insert({
        user_id: userId,
      });
      await admin.from("ingredient_suggestion_cache").upsert({
        cache_key: cacheKey,
        suggestions: { suggestions: aiSuggestions, sufficient: parsed.sufficient },
        created_at: new Date().toISOString(),
      });

      return jsonResponse({
        suggestions: aiSuggestions,
        sufficient: parsed.sufficient,
        cached: false,
        ai_unavailable: false,
        remaining_today: Math.max(0, dailyLimit - ((usedToday ?? 0) + 1)),
      });
    } catch (e) {
      console.error("Gemini suggest failed, falling back to DB:", e);
      // 429 / failure → DB fallback + "try later" flag (no blank screen).
      return jsonResponse({
        suggestions: dbMatches,
        sufficient: true,
        cached: false,
        ai_unavailable: true,
        error: isRateLimitError(e) ? "busy" : "failed",
      });
    }
  } catch (e) {
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
