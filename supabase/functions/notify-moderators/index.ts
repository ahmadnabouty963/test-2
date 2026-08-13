import { createClient } from "npm:@supabase/supabase-js@2.112.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: corsHeaders });

function secretKey() {
  const legacy = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (legacy) return legacy;
  const keys = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (!keys) throw new Error("Supabase server key is unavailable");
  const parsed = JSON.parse(keys);
  return parsed.default || Object.values(parsed)[0];
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);

  try {
    const authorization = request.headers.get("Authorization") || "";
    const accessToken = authorization.replace(/^Bearer\s+/i, "");
    if (!accessToken) return json({ error: "Authentication required" }, 401);

    const admin = createClient(Deno.env.get("SUPABASE_URL")!, secretKey(), {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: authData, error: authError } = await admin.auth.getUser(accessToken);
    if (authError || !authData.user) return json({ error: "Invalid session" }, 401);

    const { conversation_id } = await request.json();
    if (!conversation_id || typeof conversation_id !== "string") {
      return json({ error: "conversation_id is required" }, 400);
    }

    const { data: conversation, error: conversationError } = await admin
      .from("conversations")
      .select("id,user_id,topic,language,status,created_at")
      .eq("id", conversation_id)
      .single();
    if (conversationError || !conversation) return json({ error: "Conversation not found" }, 404);
    if (conversation.user_id !== authData.user.id) return json({ error: "Not allowed" }, 403);
    if (conversation.status !== "waiting") return json({ skipped: "conversation_not_waiting" });

    const { data: existing } = await admin
      .from("notification_events")
      .select("pushed_at,emailed_at")
      .eq("conversation_id", conversation.id)
      .maybeSingle();
    if (existing?.pushed_at && existing?.emailed_at) return json({ already_sent: true });

    await admin.from("notification_events").upsert(
      { conversation_id: conversation.id, requested_at: new Date().toISOString(), last_error: null },
      { onConflict: "conversation_id" },
    );

    const { data: staffProfiles, error: staffError } = await admin
      .from("profiles")
      .select("id,role")
      .in("role", ["moderator", "admin"]);
    if (staffError) throw staffError;
    const staffIds = (staffProfiles || []).map((profile) => profile.id);

    let pushRecipientCount = 0;
    let pushedAt: string | null = existing?.pushed_at || null;
    if (!pushedAt && staffIds.length) {
      const { data: devices, error: deviceError } = await admin
        .from("device_push_tokens")
        .select("token")
        .in("user_id", staffIds)
        .eq("enabled", true);
      if (deviceError) throw deviceError;
      const tokens = [...new Set((devices || []).map((device) => device.token))];
      if (tokens.length) {
        const messages = tokens.map((token) => ({
          to: token,
          sound: "default",
          title: "Haven · Someone needs a listener",
          body: "Open the private moderator queue when you are available.",
          data: { route: "moderator-queue" },
          channelId: "new-conversations",
          priority: "high",
        }));
        const headers: Record<string, string> = { "Content-Type": "application/json" };
        const expoToken = Deno.env.get("EXPO_ACCESS_TOKEN");
        if (expoToken) headers.Authorization = `Bearer ${expoToken}`;
        const pushResponse = await fetch("https://exp.host/--/api/v2/push/send", {
          method: "POST",
          headers,
          body: JSON.stringify(messages),
        });
        if (!pushResponse.ok) throw new Error(`Expo push failed (${pushResponse.status})`);
        pushRecipientCount = tokens.length;
        pushedAt = new Date().toISOString();
      }
    }

    let emailRecipientCount = 0;
    let emailedAt: string | null = existing?.emailed_at || null;
    const resendKey = Deno.env.get("RESEND_API_KEY");
    const emailFrom = Deno.env.get("HAVEN_EMAIL_FROM");
    if (!emailedAt && resendKey && emailFrom && staffIds.length) {
      const { data: usersPage, error: usersError } = await admin.auth.admin.listUsers({ page: 1, perPage: 1000 });
      if (usersError) throw usersError;
      const staffSet = new Set(staffIds);
      const emails = usersPage.users
        .filter((user) => staffSet.has(user.id) && user.email)
        .map((user) => user.email as string);
      if (emails.length) {
        const emailResponse = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${resendKey}` },
          body: JSON.stringify({
            from: emailFrom,
            to: emails,
            subject: "Haven: A guest is waiting for a moderator",
            html: "<p>A guest is waiting for a human listener.</p><p>Open the protected Haven moderator dashboard when you are available. Conversation details are intentionally not included in this email.</p>",
          }),
        });
        if (!emailResponse.ok) throw new Error(`Email delivery failed (${emailResponse.status})`);
        emailRecipientCount = emails.length;
        emailedAt = new Date().toISOString();
      }
    }

    await admin.from("notification_events").update({
      pushed_at: pushedAt,
      emailed_at: emailedAt,
      push_recipient_count: pushRecipientCount,
      email_recipient_count: emailRecipientCount,
      last_error: null,
    }).eq("conversation_id", conversation.id);

    return json({
      delivered: { push: pushRecipientCount, email: emailRecipientCount },
      email_configured: Boolean(resendKey && emailFrom),
    });
  } catch (error) {
    console.error(error);
    return json({ error: error instanceof Error ? error.message : "Notification failed" }, 500);
  }
});
