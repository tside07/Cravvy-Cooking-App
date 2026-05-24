// Supabase Edge Function: generate 7-day meal plan via Gemini Flash
// Secrets: GEMINI_API_KEY (required), GEMINI_MODEL (optional, default gemini-2.0-flash)
// Auto-injected: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const MEAL_TYPES = ["breakfast", "lunch", "dinner", "snack"] as const;
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

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

function catalogLine(r: Record<string, unknown>): string {
  return [
    r.id,
    r.meal_type,
    r.name,
    `${r.calories}kcal`,
    `P${r.protein}g`,
    (r.tags as string[] | undefined)?.slice(0, 3).join(",") ?? "",
  ].join("|");
}

async function callGemini(
  apiKey: string,
  profile: Record<string, unknown>,
  recipes: Record<string, unknown>[],
  weekStart: Date,
): Promise<DayPlan[]> {
  const weekDates = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(weekStart);
    d.setUTCDate(weekStart.getUTCDate() + i);
    return dateStr(d);
  });

  const catalog = recipes.map(catalogLine).join("\n");
  const prompt = `You are a nutrition meal planner. Build a 7-day meal plan using ONLY recipe IDs from the catalog below.

User profile:
- goal: ${profile.goal ?? "maintain"}
- diets: ${JSON.stringify(profile.diets ?? [])}
- avoid_foods: ${JSON.stringify(profile.avoid_foods ?? [])}
- age: ${profile.age}, gender: ${profile.gender}
- weight_kg: ${profile.weight_kg}, height_cm: ${profile.height_cm}
- cooking_time preference: ${profile.cooking_time ?? "any"}

Week dates (use exactly these): ${weekDates.join(", ")}

For EACH date, assign exactly one recipe per meal_type: breakfast, lunch, dinner, snack.
Rules:
1. ONLY use recipe_id values that appear in the catalog (UUID format).
2. Match meal_type on each recipe to the slot.
3. Respect avoid_foods and diets.
4. Prefer lower calories for lose-weight; higher protein for build-muscle.
5. Do not repeat the same recipe_id more than 3 times in the week.

Catalog (id|meal_type|name|calories|protein|tags):
${catalog}

Respond with ONLY valid JSON, no markdown:
{
  "days": [
    { "date": "YYYY-MM-DD", "meals": [
      { "meal_type": "breakfast", "recipe_id": "uuid" },
      { "meal_type": "lunch", "recipe_id": "uuid" },
      { "meal_type": "dinner", "recipe_id": "uuid" },
      { "meal_type": "snack", "recipe_id": "uuid" }
    ]}
  ]
}`;

  const model = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.0-flash";
  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.4,
          maxOutputTokens: 8192,
          responseMimeType: "application/json",
        },
      }),
    },
  );

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Gemini API error ${res.status}: ${errText}`);
  }

  const data = await res.json();
  const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) throw new Error("Empty Gemini response");

  const cleaned = text.replace(/```json\n?/g, "").replace(/```/g, "").trim();
  const parsed = JSON.parse(cleaned) as { days: DayPlan[] };
  if (!parsed?.days?.length) throw new Error("Invalid Gemini JSON shape");
  return parsed.days;
}

function validateAndFillDays(
  days: DayPlan[],
  weekDates: string[],
  recipes: Record<string, unknown>[],
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
    for (const mealType of MEAL_TYPES) {
      const slot = src?.meals?.find((m) => m.meal_type === mealType);
      const pool = byType.get(mealType) ?? [];
      let recipeId = slot?.recipe_id;
      const valid = pool.some((r) => r.id === recipeId);
      if (!valid && pool.length > 0) {
        const pick = pool[Math.floor(Math.random() * pool.length)];
        recipeId = pick.id as string;
      }
      if (recipeId) meals.push({ meal_type: mealType, recipe_id: recipeId });
    }
    result.push({ date, meals });
  }
  return result;
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
    const forceRefresh = Boolean(body.force_refresh);
    const weekStart = parseWeekStart(body.week_start as string | undefined);
    const weekStartStr = dateStr(weekStart);

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

    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select(
        "id, goal, diets, avoid_foods, age, gender, weight_kg, height_cm, cooking_time, meal_plan_profile_hash, meal_plan_week_start",
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
          entries_count: count,
          week_start: weekStartStr,
        });
      }
    }

    const { data: recipes, error: recipesError } = await admin
      .from("recipes")
      .select("id, name, meal_type, calories, protein, carbs, fat, tags")
      .eq("is_active", true);

    if (recipesError || !recipes?.length) {
      return jsonResponse({ error: "No recipes in catalog" }, 400);
    }

    const weekDates = Array.from({ length: 7 }, (_, i) => {
      const d = new Date(weekStart);
      d.setUTCDate(weekStart.getUTCDate() + i);
      return dateStr(d);
    });

    let days: DayPlan[];
    try {
      days = await callGemini(geminiKey, profile, recipes, weekStart);
    } catch (geminiErr) {
      console.error("Gemini failed:", geminiErr);
      return jsonResponse(
        { error: "AI generation failed", details: String(geminiErr) },
        502,
      );
    }

    days = validateAndFillDays(days, weekDates, recipes);

    const rows = days.flatMap((day) =>
      day.meals.map((m) => ({
        user_id: user.id,
        date: day.date,
        meal_type: m.meal_type,
        recipe_id: m.recipe_id,
        is_logged: false,
      })),
    );

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
      entries_count: rows.length,
      week_start: weekStartStr,
    });
  } catch (e) {
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
