// Supabase Edge Function: AI cooking & health assistant chat.
//
// Reads the user's profile + a recipe shortlist (real catalog) to ground the
// reply, calls Gemini, and persists ONLY the visible messages to chat_messages
// (via service role) so the per-day cap cannot be bypassed.
//
// Auto-injected: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY
// Secrets: GEMINI_API_KEY (required); GEMINI_MODEL (optional, default
//   gemini-2.5-flash); GEMINI_FALLBACK_MODEL (optional, default gemini-2.0-flash
//   — used ONLY when the primary is transiently overloaded); DEBUG_CHAT
//   (optional: "1" surfaces the real model error in the reply for diagnosis).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Keep in sync with `PlanLimits.freeRecipeSources` (Flutter).
const FREE_RECIPE_SOURCES = ["cravvy_curated_vn"] as const;

// Keep in sync with `PlanLimits.chatDailyLimit*` (Flutter).
const FREE_DAILY_LIMIT = 15;
const PREMIUM_DAILY_LIMIT = 60;

// Token budget guards.
const MAX_HISTORY_MESSAGES = 10;
const MAX_CONTENT_CHARS = 2000;
const SHORTLIST_SIZE = 30;

interface IncomingMessage {
  role: string;
  content: string;
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

// Secondary model, used ONLY when the primary is transiently overloaded.
function geminiFallbackModelName(): string {
  return Deno.env.get("GEMINI_FALLBACK_MODEL") ?? "gemini-2.0-flash";
}

function usesThinkingBudget(model: string): boolean {
  return model.includes("2.5");
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Transient Gemini failures worth retrying / surfacing as "busy" rather than
// dumping the user into the canned fallback: 429 (rate) and 5xx / UNAVAILABLE
// ("high demand", model overloaded).
function isTransientError(e: unknown): boolean {
  const msg = (e instanceof Error ? e.message : String(e)).toLowerCase();
  return msg.includes("429") ||
    msg.includes("rate") ||
    msg.includes("503") ||
    msg.includes("500") ||
    msg.includes("unavailable") ||
    msg.includes("overloaded") ||
    msg.includes("high demand");
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

// Gemini's REST API expects the OpenAPI `Type` enum in UPPERCASE
// (OBJECT/STRING/ARRAY). Lowercase values are rejected with HTTP 400, which
// would make every call fall back to the canned "trouble thinking" reply.
const RESPONSE_SCHEMA = {
  type: "OBJECT",
  properties: {
    reply: { type: "STRING" },
    recipe_ids: { type: "ARRAY", items: { type: "STRING" } },
  },
  required: ["reply"],
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
  contents: Array<{ role: string; parts: Array<{ text: string }> }>,
): Promise<string> {
  const generationConfig: Record<string, unknown> = {
    temperature: 0.6,
    maxOutputTokens: 1024,
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
        contents,
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

// One model, with bounded retries on transient overload (jittered backoff).
async function callModelWithRetry(
  apiKey: string,
  model: string,
  systemPrompt: string,
  contents: Array<{ role: string; parts: Array<{ text: string }> }>,
  maxAttempts: number,
): Promise<string> {
  let lastErr: unknown;
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await callGeminiOnce(apiKey, model, systemPrompt, contents);
    } catch (e) {
      lastErr = e;
      if (isTransientError(e) && attempt < maxAttempts - 1) {
        // Jittered backoff so retries don't all slam the same spike.
        await sleep(800 * (attempt + 1) + Math.floor(Math.random() * 400));
        continue;
      }
      break;
    }
  }
  throw lastErr;
}

// Fallback chain: try the primary model first; ONLY if it is transiently
// overloaded (429 / 503 UNAVAILABLE) do we drop to the secondary model for this
// one request. The primary serves the vast majority of traffic, so everyday
// answer quality is unchanged — the secondary only rescues the rare spike
// (a decent answer beats "try again later").
async function callGemini(
  apiKey: string,
  systemPrompt: string,
  contents: Array<{ role: string; parts: Array<{ text: string }> }>,
): Promise<string> {
  const primary = geminiModelName();
  try {
    return await callModelWithRetry(apiKey, primary, systemPrompt, contents, 2);
  } catch (e) {
    const fallback = geminiFallbackModelName();
    if (isTransientError(e) && fallback && fallback !== primary) {
      console.warn(
        `Primary ${primary} overloaded; falling back to ${fallback}`,
      );
      return await callModelWithRetry(
        apiKey,
        fallback,
        systemPrompt,
        contents,
        2,
      );
    }
    throw e;
  }
}

function buildSystemPrompt(
  profile: Record<string, unknown>,
  shortlist: Array<Record<string, unknown>>,
  weekPlanLines: string[],
  locale: string,
): string {
  const catalog = shortlist
    .map((r) =>
      `${r.id} | ${r.name} | ${r.meal_type} | ${r.calories}kcal | ${
        Array.isArray(r.tags) ? (r.tags as string[]).slice(0, 3).join(",") : ""
      }`
    )
    .join("\n");

  const weekBlock = weekPlanLines.length
    ? `\nThe user's planned meals this week:\n${weekPlanLines.join("\n")}\n`
    : "";

  const lang = locale.startsWith("vi") ? "Vietnamese" : "English";

  return [
    "You are Cravvy's culinary and nutrition expert assistant.",
    "Give friendly, practical cooking and healthy-eating advice tailored to the user.",
    `Always answer in ${lang}.`,
    "",
    "User profile:",
    `- Age: ${profile.age ?? "unknown"}`,
    `- Sex: ${profile.gender ?? "unknown"}`,
    `- Height: ${profile.height_cm ?? "unknown"} cm`,
    `- Weight: ${profile.weight_kg ?? "unknown"} kg`,
    `- Goal: ${profile.goal ?? "maintain"}`,
    `- Diets: ${JSON.stringify(profile.diets ?? [])}`,
    `- Avoid foods/allergens: ${JSON.stringify(profile.avoid_foods ?? [])}`,
    `- Cooking time preference: ${profile.cooking_time ?? "any"}`,
    weekBlock,
    "When the user asks about calories, TDEE, a deficit/surplus, or macros,",
    "estimate them from the profile above plus any details in the message,",
    "briefly explain the numbers, and offer a simple one-day sample of meals",
    "with a Protein/Carbs/Fat split. Prefer catalog dishes for the sample.",
    "When recommending specific dishes, ONLY use dishes from this catalog and",
    "return their UUIDs in `recipe_ids`. Never invent recipe IDs. You may also",
    "give general advice without referencing a dish.",
    "Respect the user's diets and avoid_foods strictly.",
    "Do NOT give medical diagnoses or treatment; suggest consulting a",
    "professional for medical concerns.",
    "",
    "Recipe catalog (id | name | meal_type | calories | tags):",
    catalog,
    "",
    'Respond as JSON: {"reply": "<text>", "recipe_ids": ["<uuid>", ...]}.',
  ].join("\n");
}

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
      messages?: IncomingMessage[];
      include_week_plan?: boolean;
      locale?: string;
    } | null;

    const rawMessages = body?.messages ?? [];
    const locale = (body?.locale ?? "en").toString();
    const includeWeekPlan = body?.include_week_plan === true;

    if (!Array.isArray(rawMessages) || rawMessages.length === 0) {
      return jsonResponse({ error: "messages required" }, 400);
    }
    const lastMessage = rawMessages[rawMessages.length - 1];
    if (!lastMessage || lastMessage.role !== "user" || !lastMessage.content) {
      return jsonResponse({ error: "last message must be from user" }, 400);
    }

    const admin = createClient(supabaseUrl, serviceKey);
    const userId = user.id;

    // ── Profile + tier ────────────────────────────────────────────────────
    const { data: profile } = await admin
      .from("profiles")
      .select(
        "id, goal, diets, avoid_foods, cooking_time, subscription_tier, age, gender, height_cm, weight_kg",
      )
      .eq("id", userId)
      .single();
    const safeProfile = profile ?? {};
    const tier = String(safeProfile.subscription_tier ?? "free");
    const dailyLimit = isPremiumTier(tier)
      ? PREMIUM_DAILY_LIMIT
      : FREE_DAILY_LIMIT;

    // ── Daily cap (count user messages stored today) ───────────────────────
    const { count: usedToday } = await admin
      .from("chat_messages")
      .select("*", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("role", "user")
      .gte("created_at", startOfTodayUtcIso());

    const used = usedToday ?? 0;
    if (used >= dailyLimit) {
      return jsonResponse({ error: "daily_limit", remaining_today: 0 }, 200);
    }

    // ── Recipe shortlist (real catalog, free-source filtered) ──────────────
    let recipesQuery = admin
      .from("recipes")
      .select("id, name, meal_type, calories, tags")
      .eq("is_active", true)
      .limit(SHORTLIST_SIZE);
    if (!isPremiumTier(tier)) {
      recipesQuery = recipesQuery.or(
        `source.in.(${FREE_RECIPE_SOURCES.join(",")}),source.is.null`,
      );
    }
    const { data: recipes } = await recipesQuery;
    const shortlist = recipes ?? [];
    const validIds = new Set(shortlist.map((r) => String(r.id)));

    // ── Optional: this week's planned meals (read-only context) ────────────
    const weekPlanLines: string[] = [];
    if (includeWeekPlan) {
      const today = new Date();
      const day = (today.getUTCDay() + 6) % 7; // Monday = 0
      const monday = new Date(
        Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate()),
      );
      monday.setUTCDate(monday.getUTCDate() - day);
      const sunday = new Date(monday);
      sunday.setUTCDate(monday.getUTCDate() + 6);
      const iso = (d: Date) => d.toISOString().slice(0, 10);

      const { data: planRows } = await admin
        .from("meal_plans")
        .select("date, meal_type, recipes(name)")
        .eq("user_id", userId)
        .gte("date", iso(monday))
        .lte("date", iso(sunday))
        .order("date", { ascending: true });

      for (const row of planRows ?? []) {
        const name = (row as { recipes?: { name?: string } }).recipes?.name;
        if (name) {
          weekPlanLines.push(
            `${(row as { date: string }).date} ${
              (row as { meal_type: string }).meal_type
            }: ${name}`,
          );
        }
      }
    }

    // ── Build Gemini conversation ──────────────────────────────────────────
    const systemPrompt = buildSystemPrompt(
      safeProfile,
      shortlist,
      weekPlanLines,
      locale,
    );
    const trimmed = rawMessages.slice(-MAX_HISTORY_MESSAGES);
    const contents = trimmed.map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: String(m.content ?? "").slice(0, MAX_CONTENT_CHARS) }],
    }));

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return jsonResponse({ error: "Server configuration missing" }, 500);
    }

    // ── Call Gemini ────────────────────────────────────────────────────────
    let reply = "";
    let referencedIds: string[] = [];
    try {
      const text = await callGemini(apiKey, systemPrompt, contents);
      const parsed = JSON.parse(text) as {
        reply?: string;
        recipe_ids?: string[];
      };
      reply = (parsed.reply ?? "").trim();
      referencedIds = (parsed.recipe_ids ?? [])
        .map((id) => String(id))
        .filter((id) => validIds.has(id));
      if (!reply) throw new Error("Empty reply");
    } catch (e) {
      // Overloaded even after retries (429 / 503 UNAVAILABLE) → ask the client
      // to retry shortly, without consuming the daily quota or persisting.
      if (isTransientError(e)) {
        return jsonResponse({ error: "busy", retry_after: 8 }, 200);
      }
      const detail = e instanceof Error ? e.message : String(e);
      console.error("Gemini failed, using fallback:", detail);
      // Set the `DEBUG_CHAT=1` functions secret to surface the real Gemini
      // error in the chat bubble while diagnosing. Remove it in production.
      reply = Deno.env.get("DEBUG_CHAT") === "1"
        ? `⚠️ Gemini call failed: ${detail}`
        : "I'm having trouble thinking right now. Meanwhile, here are a few dishes from your catalog you might enjoy.";
      referencedIds = shortlist.slice(0, 3).map((r) => String(r.id));
    }

    // ── Persist both turns (service role) ──────────────────────────────────
    const userContent = String(lastMessage.content).slice(0, MAX_CONTENT_CHARS);
    // Both rows must carry the same keys: a heterogeneous bulk insert makes
    // supabase-js send an explicit NULL for any key missing on a row, which
    // violates the NOT NULL `referenced_recipe_ids` column (the DEFAULT '{}'
    // only applies when the column is omitted from every row).
    const { error: insertError } = await admin.from("chat_messages").insert([
      {
        user_id: userId,
        role: "user",
        content: userContent,
        referenced_recipe_ids: [],
      },
      {
        user_id: userId,
        role: "assistant",
        content: reply,
        referenced_recipe_ids: referencedIds,
      },
    ]);
    if (insertError) {
      console.error("chat_messages insert:", insertError);
    }

    return jsonResponse({
      reply,
      referenced_recipe_ids: referencedIds,
      remaining_today: Math.max(0, dailyLimit - (used + 1)),
    });
  } catch (e) {
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
