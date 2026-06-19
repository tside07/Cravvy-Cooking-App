// Supabase Edge Function: AI cooking & health assistant chat.
//
// Reads the user's profile + a recipe shortlist (real catalog) to ground the
// reply, calls Gemini, and persists ONLY the visible messages to chat_messages
// (via service role) so the per-day cap cannot be bypassed.
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

const RESPONSE_SCHEMA = {
  type: "object",
  properties: {
    reply: { type: "string" },
    recipe_ids: { type: "array", items: { type: "string" } },
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

async function callGemini(
  apiKey: string,
  systemPrompt: string,
  contents: Array<{ role: string; parts: Array<{ text: string }> }>,
): Promise<string> {
  const model = geminiModelName();
  let lastErr: unknown;
  for (let retry = 0; retry < 2; retry++) {
    try {
      return await callGeminiOnce(apiKey, model, systemPrompt, contents);
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
    `- Goal: ${profile.goal ?? "maintain"}`,
    `- Diets: ${JSON.stringify(profile.diets ?? [])}`,
    `- Avoid foods/allergens: ${JSON.stringify(profile.avoid_foods ?? [])}`,
    `- Cooking time preference: ${profile.cooking_time ?? "any"}`,
    weekBlock,
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
      .select("id, goal, diets, avoid_foods, cooking_time, subscription_tier")
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
      // 429 after retry → ask client to retry without consuming the message.
      if (isRateLimitError(e)) {
        return jsonResponse({ error: "busy", retry_after: 8 }, 200);
      }
      console.error("Gemini failed, using fallback:", e);
      reply =
        "I'm having trouble thinking right now. Meanwhile, here are a few dishes from your catalog you might enjoy.";
      referencedIds = shortlist.slice(0, 3).map((r) => String(r.id));
    }

    // ── Persist both turns (service role) ──────────────────────────────────
    const userContent = String(lastMessage.content).slice(0, MAX_CONTENT_CHARS);
    const { error: insertError } = await admin.from("chat_messages").insert([
      { user_id: userId, role: "user", content: userContent },
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
