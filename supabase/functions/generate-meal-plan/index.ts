// Profile-aware recipe filtering for meal plans.
// Keep logic in sync with lib/core/utils/profile_recipe_filter.dart

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

export const SOFT_DIETS = new Set([
  "No Specific Diet",
  "Eat Clean",
  "High-Protein",
  "Intermittent Fasting",
]);

export const AVOID_TOKEN_MAP: Record<string, string[]> = {
  Peanuts: ["peanut", "peanuts", "đậu phộng", "lac"],
  Shellfish: ["shellfish", "shrimp", "prawn", "crab", "lobster", "tôm", "cua"],
  Dairy: ["dairy", "milk", "cheese", "cream", "butter", "yogurt", "sữa", "phô mai"],
  Gluten: ["gluten", "wheat", "flour", "bread", "mì", "bánh mì"],
  Eggs: ["egg", "eggs", "trứng"],
  Soy: ["soy", "tofu", "đậu nành", "tương"],
  "Tree Nuts": ["almond", "walnut", "cashew", "pecan", "hazelnut", "hạnh nhân", "óc chó"],
  Fish: ["fish", "salmon", "tuna", "cá"],
  "No Pork": ["pork", "heo", "thịt heo"],
  "No Beef": ["beef", "bò", "thịt bò"],
  "No Seafood": [
    "seafood",
    "fish",
    "shellfish",
    "shrimp",
    "prawn",
    "crab",
    "lobster",
    "tôm",
    "cua",
    "cá",
  ],
  "No Spicy": ["spicy", "chili", "chilli", "pepper", "cay", "ớt"],
  "No Raw Foods": ["raw", "sống", "sashimi"],
};

const MEAT_FISH_TOKENS = [
  "pork",
  "beef",
  "chicken",
  "meat",
  "fish",
  "seafood",
  "shellfish",
  "shrimp",
  "prawn",
  "crab",
  "lobster",
  "salmon",
  "tuna",
  "thịt",
  "gà",
  "bò",
  "heo",
  "cá",
  "tôm",
  "cua",
];

const ANIMAL_PRODUCT_TOKENS = [
  ...MEAT_FISH_TOKENS,
  "egg",
  "eggs",
  "dairy",
  "milk",
  "cheese",
  "cream",
  "butter",
  "yogurt",
  "honey",
  "gelatin",
  "trứng",
  "sữa",
  "phô mai",
];

const GLUTEN_TOKENS = [
  "gluten",
  "wheat",
  "flour",
  "bread",
  "noodle",
  "pasta",
  "mì",
  "bánh mì",
];

const SUGAR_TOKENS = [
  "sugar",
  "sweet",
  "dessert",
  "candy",
  "syrup",
  "đường",
  "ngọt",
];

export function normalizeDietToken(value: string): string {
  return value.toLowerCase().replaceAll("-", " ").trim();
}

export function expandAvoidTokens(label: string): string[] {
  const trimmed = label.trim();
  if (!trimmed) return [];
  return AVOID_TOKEN_MAP[trimmed] ?? [trimmed.toLowerCase()];
}

export function recipeCorpus(r: Record<string, unknown>): string {
  const tags = ((r.tags as string[]) ?? []).join(" ");
  const ingredients = ((r.ingredients as string[]) ?? []).join(" ");
  return `${String(r.name ?? "")} ${tags} ${ingredients}`.toLowerCase();
}

function corpusContainsAny(corpus: string, tokens: string[]): boolean {
  return tokens.some((t) => corpus.includes(t));
}

export function violatesAvoidFoods(
  r: Record<string, unknown>,
  avoidFoods: string[],
): boolean {
  if (!avoidFoods.length) return false;
  const corpus = recipeCorpus(r);
  for (const item of avoidFoods) {
    const tokens = expandAvoidTokens(item);
    if (corpusContainsAny(corpus, tokens)) return true;
  }
  return false;
}

function passesSingleDiet(
  r: Record<string, unknown>,
  diet: string,
): boolean {
  const corpus = recipeCorpus(r);
  const tags = ((r.tags as string[]) ?? []).map(normalizeDietToken);
  const carbs = Number(r.carbs ?? 0);

  switch (diet) {
    case "Vegan":
      return !corpusContainsAny(corpus, ANIMAL_PRODUCT_TOKENS);
    case "Vegetarian":
      return !corpusContainsAny(corpus, MEAT_FISH_TOKENS);
    case "Gluten-Free":
      if (tags.some((t) => t.includes("gluten free"))) return true;
      return !corpusContainsAny(corpus, GLUTEN_TOKENS);
    case "Keto":
      if (tags.some((t) => t.includes("keto"))) return true;
      return carbs <= 25;
    case "Low-Carb":
      if (tags.some((t) => t.includes("low carb"))) return true;
      return carbs <= 45;
    case "Low-Sugar":
      if (tags.some((t) => t.includes("low sugar"))) return true;
      return !corpusContainsAny(corpus, SUGAR_TOKENS);
    default:
      return true;
  }
}

export function passesDietHardFilters(
  r: Record<string, unknown>,
  diets: string[],
): boolean {
  if (!diets.length || diets.includes("No Specific Diet")) return true;

  const active = diets.filter((d) => !SOFT_DIETS.has(d));
  if (!active.length) return true;

  return active.every((diet) => passesSingleDiet(r, diet));
}

export function matchesProfile(
  r: Record<string, unknown>,
  profile: Record<string, unknown>,
): boolean {
  const avoid = ((profile.avoid_foods as string[]) ?? []);
  const diets = ((profile.diets as string[]) ?? []);
  if (violatesAvoidFoods(r, avoid)) return false;
  if (!passesDietHardFilters(r, diets)) return false;
  return true;
}

export function filterRecipesForProfile(
  recipes: Record<string, unknown>[],
  profile: Record<string, unknown>,
): Record<string, unknown>[] {
  return recipes.filter((r) => matchesProfile(r, profile));
}

function tagMatchesDiet(tag: string, diet: string): boolean {
  const normalizedTag = normalizeDietToken(tag);
  const normalizedDiet = normalizeDietToken(diet);
  return normalizedTag.includes(normalizedDiet) ||
    normalizedDiet.includes(normalizedTag);
}

export function scoreRecipe(
  r: Record<string, unknown>,
  profile: Record<string, unknown>,
): number {
  const goal = String(profile.goal ?? "maintain");
  const calories = Number(r.calories ?? 0);
  const protein = Number(r.protein ?? 0);
  const tags = ((r.tags as string[]) ?? []);
  const diets = ((profile.diets as string[]) ?? []);

  let score = 0;
  switch (goal) {
    case "lose-weight":
      if (calories < 350) score += 3;
      if (calories < 450) score += 1;
      if (tags.some((t) => normalizeDietToken(t).includes("low carb"))) {
        score += 2;
      }
      break;
    case "build-muscle":
      if (protein >= 30) score += 4;
      if (protein >= 20) score += 2;
      if (tags.some((t) => normalizeDietToken(t).includes("high protein"))) {
        score += 2;
      }
      break;
    default:
      if (calories < 600) score += 1;
  }

  for (const diet of diets) {
    if (SOFT_DIETS.has(diet)) continue;
    if (tags.some((t) => tagMatchesDiet(t, diet))) score += 3;
  }
  return score;
}



// Supabase Edge Function: generate 7-day meal plan via Gemini Flash
// Secrets: GEMINI_API_KEY (required), GEMINI_MODEL (optional, default gemini-2.5-flash)
// Auto-injected: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

const MEAL_TYPES = ["breakfast", "lunch", "dinner", "snack"] as const;
const MAX_CATALOG_PER_TYPE = 20;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Keep in sync with `PlanLimits.freeRecipeSources` (Flutter).
const FREE_RECIPE_SOURCES = ["cravvy_curated_vn"] as const;

/** Min interval between force_refresh calls (protects Gemini quota). */
const AI_REFRESH_COOLDOWN_MS = 5 * 60 * 1000;

type MealSlot = { meal_type: string; recipe_id: string };
type DayPlan = { date: string; meals: MealSlot[] };

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function dateStr(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function parseWeekStart(raw: string | undefined): Date {
  if (raw) {
    const d = new Date(raw + "T00:00:00Z");
    if (!isNaN(d.getTime())) return d;
  }
  const now = new Date();
  const day = now.getUTCDay();
  const diff = day === 0 ? -6 : 1 - day;
  const monday = new Date(now);
  monday.setUTCDate(now.getUTCDate() + diff);
  monday.setUTCHours(0, 0, 0, 0);
  return monday;
}

function weekNumberFromDate(d: Date): number {
  const startOfYear = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const dayOfYear = Math.floor(
    (d.getTime() - startOfYear.getTime()) / 86400000,
  );
  return Math.floor((dayOfYear - d.getUTCDay() + 10) / 7);
}

function hashCode(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) {
    h = ((h << 5) - h + s.charCodeAt(i)) | 0;
  }
  return Math.abs(h);
}

async function sha256Hex(text: string): Promise<string> {
  const data = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

async function buildProfileHash(profile: Record<string, unknown>): Promise<string> {
  const payload = JSON.stringify({
    goal: profile.goal ?? null,
    diets: profile.diets ?? [],
    avoid_foods: profile.avoid_foods ?? [],
    age: profile.age ?? null,
    gender: profile.gender ?? null,
    weight_kg: profile.weight_kg ?? null,
    height_cm: profile.height_cm ?? null,
    cooking_time: profile.cooking_time ?? null,
  });
  return sha256Hex(payload);
}

function shuffleWithSeed<T>(arr: T[], seed: number): T[] {
  const out = [...arr];
  let s = seed >>> 0;
  for (let i = out.length - 1; i > 0; i--) {
    s = (s * 1664525 + 1013904223) >>> 0;
    const j = s % (i + 1);
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

function parseForceRefresh(body: Record<string, unknown>): boolean {
  const raw = body.force_refresh;
  return raw === true || raw === "true" || raw === 1 || raw === "1";
}

function compactCatalogLine(r: Record<string, unknown>): string {
  return [r.id, r.meal_type, r.calories, r.protein].join("|");
}

/** Trim catalog sent to Gemini — max N recipes per meal type, profile-aware. */
function trimCatalogForGemini(
  recipes: Record<string, unknown>[],
  profile: Record<string, unknown>,
  options: { forceRefresh?: boolean; refreshSeed?: number } = {},
): Record<string, unknown>[] {
  const { forceRefresh = false, refreshSeed = 0 } = options;
  const cookingTime = String(profile.cooking_time ?? "any");
  const byType = new Map<string, Record<string, unknown>[]>();

  for (const r of recipes) {
    const t = String(r.meal_type);
    if (!byType.has(t)) byType.set(t, []);
    byType.get(t)!.push(r);
  }

  const trimmed: Record<string, unknown>[] = [];
  for (const mealType of MEAL_TYPES) {
    let pool = filterRecipesForProfile(byType.get(mealType) ?? [], profile);
    if (!pool.length) continue;

    if (cookingTime === "quick" || cookingTime === "15") {
      const quick = pool.filter((r) => Number(r.prep_time ?? 999) <= 20);
      if (quick.length) pool = quick;
    }

    pool = [...pool].sort(
      (a, b) => scoreRecipe(b, profile) - scoreRecipe(a, profile),
    );

    if (forceRefresh && pool.length > MAX_CATALOG_PER_TYPE) {
      const window = pool.slice(0, Math.min(pool.length, MAX_CATALOG_PER_TYPE * 2));
      pool = shuffleWithSeed(
        window,
        refreshSeed + mealType.charCodeAt(0),
      ).slice(0, MAX_CATALOG_PER_TYPE);
    } else {
      pool = pool.slice(0, MAX_CATALOG_PER_TYPE);
    }

    trimmed.push(...pool);
  }
  return trimmed;
}

const WEEK_RESPONSE_SCHEMA = {
  type: "OBJECT",
  properties: {
    days: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          date: { type: "STRING" },
          meals: {
            type: "ARRAY",
            items: {
              type: "OBJECT",
              properties: {
                meal_type: { type: "STRING" },
                recipe_id: { type: "STRING" },
              },
              required: ["meal_type", "recipe_id"],
            },
          },
        },
        required: ["date", "meals"],
      },
    },
  },
  required: ["days"],
};

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

function isRateLimitError(err: unknown): boolean {
  return String(err).includes("429");
}

function stripCodeFences(text: string): string {
  return text.replace(/```json\n?/g, "").replace(/```/g, "").trim();
}

function repairJsonText(raw: string): string {
  let s = stripCodeFences(raw);
  s = s.replace(/,\s*(\]|\})/g, "$1");
  const openBrace = (s.match(/\{/g) || []).length;
  const closeBrace = (s.match(/\}/g) || []).length;
  const openBracket = (s.match(/\[/g) || []).length;
  const closeBracket = (s.match(/\]/g) || []).length;
  for (let i = 0; i < openBracket - closeBracket; i++) s += "]";
  for (let i = 0; i < openBrace - closeBrace; i++) s += "}";
  return s;
}

function extractMealsFromText(text: string): MealSlot[] {
  const meals: MealSlot[] = [];
  const seen = new Set<string>();

  const patterns = [
    /"meal_type"\s*:\s*"(breakfast|lunch|dinner|snack)"\s*,\s*"recipe_id"\s*:\s*"([^"]+)"/gi,
    /"recipe_id"\s*:\s*"([^"]+)"\s*,\s*"meal_type"\s*:\s*"(breakfast|lunch|dinner|snack)"/gi,
  ];

  for (const re of patterns) {
    for (const m of text.matchAll(re)) {
      const mealType = (re === patterns[0] ? m[1] : m[2]).toLowerCase();
      const recipeId = re === patterns[0] ? m[2] : m[1];
      if (!seen.has(mealType)) {
        seen.add(mealType);
        meals.push({ meal_type: mealType, recipe_id: recipeId });
      }
    }
  }
  return meals;
}

function normalizeDay(raw: Record<string, unknown>, expectedDate: string): DayPlan {
  const meals = ((raw.meals as MealSlot[]) ?? [])
    .filter((m) => m?.meal_type && m?.recipe_id)
    .map((m) => ({
      meal_type: String(m.meal_type).toLowerCase(),
      recipe_id: String(m.recipe_id),
    }));
  return {
    date: String(raw.date ?? expectedDate).slice(0, 10),
    meals,
  };
}

function parseGeminiDay(text: string, expectedDate: string): DayPlan {
  const cleaned = stripCodeFences(text);
  for (const attempt of [
    () => JSON.parse(cleaned),
    () => JSON.parse(repairJsonText(cleaned)),
  ]) {
    try {
      const parsed = attempt() as Record<string, unknown> & { days?: DayPlan[] };
      if (parsed?.days?.[0]) {
        return normalizeDay(
          parsed.days[0] as unknown as Record<string, unknown>,
          expectedDate,
        );
      }
      if (parsed?.date || parsed?.meals) {
        return normalizeDay(parsed, expectedDate);
      }
    } catch {
      // next
    }
  }
  const meals = extractMealsFromText(text);
  if (meals.length) return { date: expectedDate, meals };
  throw new Error(`Could not parse day JSON: ${cleaned.slice(0, 120)}`);
}

function parseGeminiWeek(text: string, expectedDates: string[]): DayPlan[] {
  const cleaned = stripCodeFences(text);
  const parseAttempts: (() => { days?: DayPlan[] })[] = [
    () => JSON.parse(cleaned),
    () => JSON.parse(repairJsonText(cleaned)),
    () => {
      const match = cleaned.match(/\{[\s\S]*\}/);
      if (!match) throw new Error("no json object");
      return JSON.parse(repairJsonText(match[0]));
    },
  ];

  for (const attempt of parseAttempts) {
    try {
      const parsed = attempt();
      const rawDays = parsed?.days ?? [];
      if (rawDays.length) {
        return expectedDates.map((date) => {
          const src = rawDays.find((d) =>
            String(d.date).slice(0, 10) === date
          );
          return src
            ? normalizeDay(src as unknown as Record<string, unknown>, date)
            : { date, meals: [] as MealSlot[] };
        });
      }
    } catch {
      // next strategy
    }
  }

  // Regex salvage: pull complete day objects from broken JSON.
  const salvaged: DayPlan[] = [];
  for (const date of expectedDates) {
    const blockRe = new RegExp(
      `"date"\\s*:\\s*"${date}"[\\s\\S]*?"meals"\\s*:\\s*\\[[\\s\\S]*?\\]`,
      "i",
    );
    const block = text.match(blockRe);
    if (block) {
      try {
        salvaged.push(parseGeminiDay(`{${block[0]}}`, date));
        continue;
      } catch {
        // fall through
      }
    }
    const meals = extractMealsFromText(text);
    if (meals.length >= 4) {
      salvaged.push({ date, meals: meals.slice(0, 4) });
    }
  }

  if (salvaged.length === expectedDates.length) return salvaged;
  throw new Error(
    `Could not parse week JSON (${salvaged.length}/${expectedDates.length} days): ${
      cleaned.slice(0, 120)
    }`,
  );
}

function geminiModelName(): string {
  return Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash";
}

function usesThinkingBudget(model: string): boolean {
  return model.includes("2.5");
}

function extractTextFromGeminiResponse(data: unknown): string {
  const candidates = (data as {
    candidates?: Array<{ content?: { parts?: Array<{ text?: string; thought?: boolean }> } }>;
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

async function fetchGeminiTextOnce(
  apiKey: string,
  prompt: string,
  temperature: number,
  model: string,
  useSchema: boolean,
  maxOutputTokens: number,
  schema: Record<string, unknown>,
): Promise<string> {
  const generationConfig: Record<string, unknown> = {
    temperature,
    maxOutputTokens,
    responseMimeType: "application/json",
  };

  if (useSchema) {
    generationConfig.responseSchema = schema;
  }

  if (usesThinkingBudget(model)) {
    generationConfig.thinkingConfig = { thinkingBudget: 0 };
  }

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
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

async function fetchGeminiText(
  apiKey: string,
  prompt: string,
  temperature: number,
  maxOutputTokens = 8192,
): Promise<string> {
  const model = geminiModelName();
  let lastErr: unknown;

  for (const useSchema of [true, false]) {
    for (let retry = 0; retry < 3; retry++) {
      try {
        return await fetchGeminiTextOnce(
          apiKey,
          prompt,
          temperature,
          model,
          useSchema,
          maxOutputTokens,
          WEEK_RESPONSE_SCHEMA,
        );
      } catch (e) {
        lastErr = e;
        if (isRateLimitError(e) && retry < 2) {
          const waitMs = 4000 * (retry + 1);
          console.warn(`Gemini 429 — retry ${retry + 1} in ${waitMs}ms`);
          await sleep(waitMs);
          continue;
        }
        break;
      }
    }
  }

  throw lastErr;
}

function buildWeekPrompt(
  profile: Record<string, unknown>,
  catalogRecipes: Record<string, unknown>[],
  weekDates: string[],
  options: {
    forceRefresh?: boolean;
    refreshSeed?: number;
    previousRecipeIds?: string[];
  },
): string {
  const { forceRefresh = false, refreshSeed = 0, previousRecipeIds = [] } =
    options;
  const catalog = catalogRecipes.map(compactCatalogLine).join("\n");
  const avoidRepeat = previousRecipeIds.length
    ? `\nAvoid repeating these recipe_ids where possible: ${
      previousRecipeIds.slice(0, 20).join(", ")
    }\n`
    : "";
  const refreshHint = forceRefresh
    ? `\nRefresh #${refreshSeed} — create a different weekly menu.\n`
    : "";

  return (
    `Build a 7-day meal plan for dates: ${weekDates.join(", ")}.\n` +
    `Use ONLY recipe_id UUIDs from catalog. Match meal_type per slot.\n` +
    `Profile goal: ${profile.goal ?? "maintain"}, diets: ${
      JSON.stringify(profile.diets ?? [])
    }, avoid: ${JSON.stringify(profile.avoid_foods ?? [])}.\n` +
    refreshHint +
    avoidRepeat +
    `Each day MUST have breakfast, lunch, dinner, snack.\n` +
    `IMPORTANT — VARIETY: use a DIFFERENT recipe_id for every slot across the whole week. ` +
    `Do NOT repeat any recipe_id within the week unless that meal_type has fewer than 7 catalog options. ` +
    `Aim for 28 distinct dishes (7 days x 4 slots).\n` +
    `Catalog (id|meal_type|calories|protein):\n${catalog}\n` +
    `Return JSON: {"days":[{"date":"YYYY-MM-DD","meals":[{"meal_type":"breakfast","recipe_id":"uuid"},...]},...]}`
  );
}

async function callGeminiWeekBatch(
  apiKey: string,
  profile: Record<string, unknown>,
  catalogRecipes: Record<string, unknown>[],
  weekDates: string[],
  options: {
    forceRefresh?: boolean;
    refreshSeed?: number;
    previousRecipeIds?: string[];
  },
): Promise<DayPlan[]> {
  const prompt = buildWeekPrompt(profile, catalogRecipes, weekDates, options);
  const text = await fetchGeminiText(
    apiKey,
    prompt,
    options.forceRefresh ? 0.7 : 0.35,
    8192,
  );
  const days = parseGeminiWeek(text, weekDates);
  const filled = days.filter((d) => d.meals.length >= 4);
  if (filled.length < weekDates.length) {
    throw new Error(
      `Incomplete week from Gemini (${filled.length}/${weekDates.length} days)`,
    );
  }
  return days;
}

async function callGemini(
  apiKey: string,
  profile: Record<string, unknown>,
  catalogRecipes: Record<string, unknown>[],
  _allRecipes: Record<string, unknown>[],
  weekDates: string[],
  _weekStart: Date,
  _userId: string,
  options: {
    forceRefresh?: boolean;
    refreshSeed?: number;
    previousRecipeIds?: string[];
  } = {},
): Promise<{ days: DayPlan[]; aiDays: number }> {
  const model = geminiModelName();

  // 1 API call for full week (free tier ~15 RPM — day-by-day hits 429).
  try {
    const days = await callGeminiWeekBatch(
      apiKey,
      profile,
      catalogRecipes,
      weekDates,
      options,
    );
    console.log(
      `Gemini week batch: ${weekDates.length}/${weekDates.length} days from AI (1 call, ${model})`,
    );
    return { days, aiDays: weekDates.length };
  } catch (fullWeekErr) {
    console.warn("Gemini full week failed:", String(fullWeekErr).slice(0, 200));
  }

  // Fallback: 2 half-week calls (max 3 API calls total per refresh).
  const mid = Math.ceil(weekDates.length / 2);
  await sleep(2000);
  const first = await callGeminiWeekBatch(
    apiKey,
    profile,
    catalogRecipes,
    weekDates.slice(0, mid),
    options,
  );
  await sleep(2000);
  const second = await callGeminiWeekBatch(
    apiKey,
    profile,
    catalogRecipes,
    weekDates.slice(mid),
    options,
  );
  const days = [...first, ...second];
  console.log(
    `Gemini week batch: ${weekDates.length}/${weekDates.length} days from AI (2 calls, ${model})`,
  );
  return { days, aiDays: weekDates.length };
}

/** Deterministic server fallback — mirrors Flutter MealSuggester. */
function buildLocalWeekPlan(
  profile: Record<string, unknown>,
  recipes: Record<string, unknown>[],
  weekStart: Date,
  userId: string,
  refreshSeed = 0,
): DayPlan[] {
  const cookingTime = String(profile.cooking_time ?? "any");
  const weekNumber = weekNumberFromDate(weekStart);

  const byType = new Map<string, Record<string, unknown>[]>();
  for (const r of recipes) {
    const t = String(r.meal_type);
    if (!byType.has(t)) byType.set(t, []);
    byType.get(t)!.push(r);
  }

  const weekDates = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(weekStart);
    d.setUTCDate(weekStart.getUTCDate() + i);
    return dateStr(d);
  });

  return weekDates.map((date, dayOffset) => {
    const meals: MealSlot[] = [];
    for (const mealType of MEAL_TYPES) {
      let pool = filterRecipesForProfile(byType.get(mealType) ?? [], profile);
      if (!pool.length) continue;

      if (cookingTime === "quick" || cookingTime === "15") {
        const quick = pool.filter((r) => Number(r.prep_time ?? 999) <= 20);
        if (quick.length) pool = quick;
      }

      const scored = [...pool].sort(
        (a, b) => scoreRecipe(b, profile) - scoreRecipe(a, profile),
      );
      const topN = scored.slice(0, Math.min(8, scored.length));
      const seed = hashCode(userId) + weekNumber * 31 +
        (mealType.charCodeAt(0) % 100) + dayOffset * 7 +
        hashCode(String(refreshSeed));
      const pick = topN[seed % topN.length];
      meals.push({ meal_type: mealType, recipe_id: String(pick.id) });
    }
    return { date, meals };
  });
}

function validateAndFillDays(
  days: DayPlan[],
  weekDates: string[],
  recipes: Record<string, unknown>[],
  profile: Record<string, unknown>,
): DayPlan[] {
  const byType = new Map<string, Record<string, unknown>[]>();
  for (const r of recipes) {
    const t = r.meal_type as string;
    if (!byType.has(t)) byType.set(t, []);
    byType.get(t)!.push(r);
  }

  const result: DayPlan[] = [];
  for (const date of weekDates) {
    const src = days.find((d) => d.date === date);
    const meals: MealSlot[] = [];
    const dayOffset = weekDates.indexOf(date);
    for (const mealType of MEAL_TYPES) {
      const slot = src?.meals?.find((m) => m.meal_type === mealType);
      const pool = filterRecipesForProfile(byType.get(mealType) ?? [], profile);
      if (!pool.length) continue;

      let recipeId = slot?.recipe_id;
      const inPool = pool.some((r) => r.id === recipeId);
      if (!inPool) {
        const scored = [...pool].sort(
          (a, b) => scoreRecipe(b, profile) - scoreRecipe(a, profile),
        );
        const topN = scored.slice(0, Math.min(5, scored.length));
        const seed = hashCode(String(profile.id ?? "")) + dayOffset * 7 +
          (mealType.charCodeAt(0) % 100);
        recipeId = String(topN[seed % topN.length].id);
      }
      if (recipeId) meals.push({ meal_type: mealType, recipe_id: recipeId });
    }
    result.push({ date, meals });
  }
  return result;
}

/**
 * Đảm bảo ĐA DẠNG cấp tuần: với mỗi meal_type, 7 ngày dùng món KHÁC nhau.
 * Chạy SAU mọi nguồn (Gemini/local) — giữ lựa chọn hợp lệ & không trùng; chỉ
 * thay món trùng/không hợp lệ bằng món điểm-cao CHƯA dùng trong tuần. Khi pool
 * < số ngày thì mới buộc lặp (xoay vòng). Path-agnostic nên fix mọi đường sinh.
 */
function diversifyWeek(
  days: DayPlan[],
  recipes: Record<string, unknown>[],
  profile: Record<string, unknown>,
  weekDates: string[],
): DayPlan[] {
  const cookingTime = String(profile.cooking_time ?? "any");
  const byType = new Map<string, Record<string, unknown>[]>();
  for (const r of recipes) {
    const t = String(r.meal_type);
    if (!byType.has(t)) byType.set(t, []);
    byType.get(t)!.push(r);
  }

  // Pool id theo điểm giảm dần cho từng meal_type.
  const pools = new Map<string, string[]>();
  for (const mt of MEAL_TYPES) {
    let pool = filterRecipesForProfile(byType.get(mt) ?? [], profile);
    if (cookingTime === "quick" || cookingTime === "15") {
      const quick = pool.filter((r) => Number(r.prep_time ?? 999) <= 20);
      if (quick.length) pool = quick;
    }
    pool = [...pool].sort((a, b) => scoreRecipe(b, profile) - scoreRecipe(a, profile));
    pools.set(mt, pool.map((r) => String(r.id)));
  }

  const dayByDate = new Map(days.map((d) => [d.date, d]));
  for (const mt of MEAL_TYPES) {
    const pool = pools.get(mt) ?? [];
    if (!pool.length) continue;
    const poolSet = new Set(pool);
    const used = new Set<string>();
    for (const date of weekDates) {
      const day = dayByDate.get(date);
      if (!day) continue;
      const slot = day.meals.find((m) => m.meal_type === mt);
      const cur = slot?.recipe_id;
      if (cur && poolSet.has(cur) && !used.has(cur)) {
        used.add(cur);
        continue;
      }
      // cần thay: ưu tiên món điểm-cao chưa dùng; pool cạn -> xoay vòng.
      let pick = pool.find((id) => !used.has(id));
      if (!pick) pick = pool[used.size % pool.length];
      used.add(pick);
      if (slot) slot.recipe_id = pick;
      else day.meals.push({ meal_type: mt, recipe_id: pick });
    }
  }
  return days;
}

function isPremiumAccess(profile: Record<string, unknown>): boolean {
  const tier = String(profile.subscription_tier ?? "free");
  const isTierPremium = tier === "premium" || tier === "trial";
  if (!isTierPremium) return false;

  const untilRaw = profile.premium_until;
  if (untilRaw == null) return true;
  const until = new Date(String(untilRaw));
  if (isNaN(until.getTime())) return true;
  return until.getTime() > Date.now();
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Missing Authorization" }, 401);
    }

    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!geminiKey || !supabaseUrl || !serviceKey) {
      return jsonResponse({ error: "Server configuration missing" }, 500);
    }

    const body = await req.json().catch(() => ({}));
    const forceRefresh = parseForceRefresh(body);
    const weekStart = parseWeekStart(body.week_start as string | undefined);
    const weekStartStr = dateStr(weekStart);
    const refreshSeed = forceRefresh ? Date.now() : 0;

    const userClient = createClient(
      supabaseUrl,
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );
    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();
    if (userError || !user) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    const admin = createClient(supabaseUrl, serviceKey);

    if (forceRefresh) {
      const { data: usageRows } = await admin
        .from("user_weekly_usage")
        .select("last_ai_refresh_at")
        .eq("user_id", user.id)
        .not("last_ai_refresh_at", "is", null)
        .order("last_ai_refresh_at", { ascending: false })
        .limit(1);

      const lastRaw = usageRows?.[0]?.last_ai_refresh_at;
      if (lastRaw) {
        const elapsed = Date.now() - new Date(String(lastRaw)).getTime();
        if (elapsed < AI_REFRESH_COOLDOWN_MS) {
          const retryAfterSeconds = Math.ceil(
            (AI_REFRESH_COOLDOWN_MS - elapsed) / 1000,
          );
          return jsonResponse(
            {
              error: "cooldown",
              retry_after_seconds: retryAfterSeconds,
            },
            429,
          );
        }
      }

      const nowIso = new Date().toISOString();
      const { data: weekUsage } = await admin
        .from("user_weekly_usage")
        .select("swap_count, ai_refresh_count")
        .eq("user_id", user.id)
        .eq("week_start", weekStartStr)
        .maybeSingle();

      if (weekUsage) {
        await admin
          .from("user_weekly_usage")
          .update({
            last_ai_refresh_at: nowIso,
            updated_at: nowIso,
          })
          .eq("user_id", user.id)
          .eq("week_start", weekStartStr);
      } else {
        await admin.from("user_weekly_usage").insert({
          user_id: user.id,
          week_start: weekStartStr,
          swap_count: 0,
          ai_refresh_count: 0,
          last_ai_refresh_at: nowIso,
        });
      }
    }

    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select(
        "id, goal, diets, avoid_foods, age, gender, weight_kg, height_cm, cooking_time, meal_plan_profile_hash, meal_plan_week_start, subscription_tier, premium_until",
      )
      .eq("id", user.id)
      .single();

    if (profileError || !profile) {
      return jsonResponse({ error: "Profile not found" }, 404);
    }

    const profileHash = await buildProfileHash(profile);

    if (
      !forceRefresh &&
      profile.meal_plan_profile_hash === profileHash &&
      profile.meal_plan_week_start === weekStartStr
    ) {
      const { count } = await admin
        .from("meal_plans")
        .select("*", { count: "exact", head: true })
        .eq("user_id", user.id)
        .gte("date", weekStartStr)
        .lte(
          "date",
          dateStr(new Date(weekStart.getTime() + 6 * 86400000)),
        );
      if ((count ?? 0) >= 20) {
        return jsonResponse({
          cached: true,
          success: true,
          ai_generated: true,
          entries_count: count,
          week_start: weekStartStr,
        });
      }
    }

    const premium = isPremiumAccess(profile);

    let recipesQuery = admin
      .from("recipes")
      .select(
        "id, name, meal_type, calories, protein, carbs, fat, prep_time, tags, ingredients, source",
      )
      .eq("is_active", true);

    if (!premium) {
      recipesQuery = recipesQuery.or(
        `source.in.(${FREE_RECIPE_SOURCES.join(",")}),source.is.null`,
      );
    }

    const { data: recipes, error: recipesError } = await recipesQuery;

    if (recipesError || !recipes?.length) {
      return jsonResponse({ error: "No recipes in catalog" }, 400);
    }

    const weekDates = Array.from({ length: 7 }, (_, i) => {
      const d = new Date(weekStart);
      d.setUTCDate(weekStart.getUTCDate() + i);
      return dateStr(d);
    });

    const weekEndStr = weekDates[weekDates.length - 1];

    const { data: existingRows } = await admin
      .from("meal_plans")
      .select("date, meal_type, recipe_id")
      .eq("user_id", user.id)
      .gte("date", weekStartStr)
      .lte("date", weekEndStr);

    const previousRecipeIds = [
      ...new Set(
        (existingRows ?? []).map((r) => String(r.recipe_id)).filter(Boolean),
      ),
    ];

    const existingKey = (date: string, mealType: string) =>
      `${date}|${mealType}`;
    const existingBySlot = new Map(
      (existingRows ?? []).map((r) => [
        existingKey(String(r.date), String(r.meal_type)),
        String(r.recipe_id),
      ]),
    );

    const catalogForGemini = trimCatalogForGemini(recipes, profile, {
      forceRefresh,
      refreshSeed,
    });
    let days: DayPlan[];
    let aiGenerated = true;
    let aiDaysCount = 0;

    try {
      const geminiResult = await callGemini(
        geminiKey,
        profile,
        catalogForGemini.length ? catalogForGemini : recipes,
        recipes,
        weekDates,
        weekStart,
        user.id,
        { forceRefresh, refreshSeed, previousRecipeIds },
      );
      days = geminiResult.days;
      aiDaysCount = geminiResult.aiDays;
      aiGenerated = aiDaysCount > 0;
      // Không log user_id (PII) — chỉ giữ chỉ số vận hành để chẩn đoán.
      console.log("Gemini OK", {
        force_refresh: forceRefresh,
        refresh_seed: refreshSeed,
        ai_days: aiDaysCount,
      });
    } catch (geminiErr) {
      console.error("Gemini week generation failed:", geminiErr);
      days = buildLocalWeekPlan(
        profile,
        recipes,
        weekStart,
        user.id,
        refreshSeed,
      );
      aiGenerated = false;
    }

    days = validateAndFillDays(days, weekDates, recipes, profile);
    // Đa dạng hoá cấp tuần — fix trùng món giữa các ngày (mọi path).
    days = diversifyWeek(days, recipes, profile, weekDates);

    const rows = days.flatMap((day) =>
      day.meals.map((m) => ({
        user_id: user.id,
        date: day.date,
        meal_type: m.meal_type,
        recipe_id: m.recipe_id,
        is_logged: false,
      }))
    );

    let recipesChanged = 0;
    for (const row of rows) {
      const prev = existingBySlot.get(
        existingKey(row.date, row.meal_type),
      );
      if (prev !== row.recipe_id) recipesChanged++;
    }

    const { error: upsertError } = await admin.from("meal_plans").upsert(
      rows,
      { onConflict: "user_id,date,meal_type" },
    );

    if (upsertError) {
      return jsonResponse({ error: upsertError.message }, 500);
    }

    await admin
      .from("profiles")
      .update({
        meal_plan_profile_hash: profileHash,
        meal_plan_week_start: weekStartStr,
      })
      .eq("id", user.id);

    return jsonResponse({
      success: true,
      cached: false,
      ai_generated: aiGenerated,
      ai_days: aiDaysCount,
      recipes_changed: recipesChanged,
      entries_count: rows.length,
      week_start: weekStartStr,
    });
  } catch (e) {
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
