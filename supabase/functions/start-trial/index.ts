// Supabase Edge Function: kích hoạt gói dùng thử Premium 14 ngày (một lần) cho
// người dùng đã đăng nhập.
//
// Client KHÔNG còn được ghi trực tiếp subscription_tier / premium_until (đã bị
// trigger trg_protect_profile_premium khoá), nên việc bật trial phải đi qua đây
// và ghi bằng service_role. Điều kiện "một lần": chỉ hồ sơ đang `free` mới bật
// được — sau trial tier latch sang `trial` nên không thể bật lại.
//
// Auto-injected: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const TRIAL_DAYS = 14; // giữ đồng bộ với PlanLimits.premiumTrialDays

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

    // Xác thực người gọi bằng JWT của họ.
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

    // Trial chỉ một lần: chỉ hồ sơ đang `free` mới đủ điều kiện.
    const { data: profile, error: readError } = await admin
      .from("profiles")
      .select("subscription_tier")
      .eq("id", user.id)
      .maybeSingle();
    if (readError) {
      console.error("profiles read:", readError);
      return jsonResponse({ error: readError.message }, 500);
    }
    if (!profile) {
      return jsonResponse({ error: "Profile not found" }, 404);
    }
    if (profile.subscription_tier !== "free") {
      // Đã từng trial hoặc đang premium -> không bật lại.
      return jsonResponse({ error: "trial_not_eligible" }, 409);
    }

    const until = new Date(
      Date.now() + TRIAL_DAYS * 24 * 60 * 60 * 1000,
    ).toISOString();

    const { error: updateError } = await admin
      .from("profiles")
      .update({ subscription_tier: "trial", premium_until: until })
      .eq("id", user.id);
    if (updateError) {
      console.error("profiles update:", updateError);
      return jsonResponse({ error: updateError.message }, 500);
    }

    return jsonResponse({
      success: true,
      subscription_tier: "trial",
      premium_until: until,
    });
  } catch (e) {
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
