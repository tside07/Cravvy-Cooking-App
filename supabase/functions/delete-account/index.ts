// Supabase Edge Function: permanently delete the authenticated user and app data.
// Auto-injected: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
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
    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();
    if (userError || !user) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    const admin = createClient(supabaseUrl, serviceKey);
    const userId = user.id;

    // Explicit cleanup (safe even when FK CASCADE is missing on meal_plans).
    const { error: mealPlansError } = await admin
      .from("meal_plans")
      .delete()
      .eq("user_id", userId);
    if (mealPlansError) {
      console.error("meal_plans delete:", mealPlansError);
      return jsonResponse({ error: mealPlansError.message }, 500);
    }

    const { error: usageError } = await admin
      .from("user_weekly_usage")
      .delete()
      .eq("user_id", userId);
    if (usageError) {
      console.error("user_weekly_usage delete:", usageError);
      return jsonResponse({ error: usageError.message }, 500);
    }

    const { error: shoppingError } = await admin
      .from("shopping_list_items")
      .delete()
      .eq("user_id", userId);
    if (shoppingError) {
      console.error("shopping_list_items delete:", shoppingError);
      return jsonResponse({ error: shoppingError.message }, 500);
    }

    const { error: profileError } = await admin
      .from("profiles")
      .delete()
      .eq("id", userId);
    if (profileError) {
      console.error("profiles delete:", profileError);
      return jsonResponse({ error: profileError.message }, 500);
    }

    const { error: deleteAuthError } = await admin.auth.admin.deleteUser(
      userId,
    );
    if (deleteAuthError) {
      console.error("auth.admin.deleteUser:", deleteAuthError);
      return jsonResponse({ error: deleteAuthError.message }, 500);
    }

    return jsonResponse({ success: true });
  } catch (e) {
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
