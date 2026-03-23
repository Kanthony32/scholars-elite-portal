import type { Config } from "@netlify/functions";

// ── EMAIL TEMPLATES ───────────────────────────────────────────────────────────
const BRAND = {
  primary: "#602F96",
  fuchsia: "#C233BF",
  green: "#22C55E",
  gold: "#F5A623",
  red: "#DD1026",
  bg: "#09060F",
  card: "#120D1E",
  text: "#EDE8F8",
  muted: "#A898C8",
};

type ActivityType =
  | "school_added"
  | "school_removed"
  | "score_updated"
  | "offer_received"
  | "profile_updated"
  | "player_level_set"
  | "committed";

interface ActivityRecord {
  id: string;
  athlete_id: string;
  actor_id: string;
  actor_name: string;
  type: ActivityType;
  message: string;
  meta: Record<string, unknown>;
  created_at: string;
}

function getEmailContent(activity: ActivityRecord, athleteName: string) {
  const typeMap: Record<ActivityType, { emoji: string; subject: string; color: string }> = {
    school_added:     { emoji: "🏫", subject: `New school added to ${athleteName}'s board`, color: BRAND.primary },
    school_removed:   { emoji: "🗑️", subject: `School removed from ${athleteName}'s board`, color: BRAND.muted },
    score_updated:    { emoji: "📊", subject: `Fit score updated for ${athleteName}`, color: BRAND.fuchsia },
    offer_received:   { emoji: "🎉", subject: `Scholarship offer logged for ${athleteName}!`, color: BRAND.green },
    profile_updated:  { emoji: "✏️", subject: `${athleteName}'s profile updated`, color: BRAND.fuchsia },
    player_level_set: { emoji: "⚡", subject: `${athleteName}'s player level updated by staff`, color: BRAND.gold },
    committed:        { emoji: "🏆", subject: `${athleteName} has committed!`, color: BRAND.green },
  };

  const info = typeMap[activity.type] || { emoji: "🔔", subject: `Update on ${athleteName}`, color: BRAND.primary };

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>${info.subject}</title>
</head>
<body style="margin:0;padding:0;background:#F5F5F5;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#F5F5F5;padding:32px 16px;">
    <tr><td align="center">
      <table width="560" cellpadding="0" cellspacing="0" style="max-width:560px;width:100%;">

        <!-- Header -->
        <tr><td style="background:linear-gradient(135deg,${BRAND.primary},${BRAND.fuchsia});border-radius:16px 16px 0 0;padding:28px 32px;text-align:center;">
          <div style="font-size:36px;margin-bottom:8px;">${info.emoji}</div>
          <div style="font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;font-size:22px;font-weight:900;color:#FFFFFF;letter-spacing:2px;text-transform:uppercase;">SCHOLARS ELITE</div>
          <div style="font-size:11px;color:rgba(255,255,255,0.65);letter-spacing:3px;text-transform:uppercase;margin-top:4px;">Family Recruiting Portal</div>
        </td></tr>

        <!-- Body -->
        <tr><td style="background:#FFFFFF;padding:32px;border-left:1px solid #E5E5E5;border-right:1px solid #E5E5E5;">
          <div style="font-size:20px;font-weight:700;color:#1A1A2E;margin-bottom:12px;">${info.subject}</div>
          <div style="font-size:15px;color:#444;line-height:1.6;margin-bottom:24px;">${activity.message}</div>

          ${activity.meta?.school ? `
          <div style="background:#F8F4FF;border-left:4px solid ${info.color};border-radius:0 8px 8px 0;padding:16px 20px;margin-bottom:24px;">
            <div style="font-size:11px;font-weight:700;color:${info.color};letter-spacing:1px;text-transform:uppercase;margin-bottom:4px;">School</div>
            <div style="font-size:17px;font-weight:700;color:#1A1A2E;">${activity.meta.school}</div>
            ${activity.meta.score ? `<div style="font-size:13px;color:#666;margin-top:2px;">Placement Score: <strong>${activity.meta.score}/100</strong></div>` : ""}
          </div>` : ""}

          <div style="text-align:center;margin-bottom:8px;">
            <a href="https://scholars-elite-portal-v2.netlify.app" style="display:inline-block;background:linear-gradient(135deg,${BRAND.primary},${BRAND.fuchsia});color:#FFFFFF;text-decoration:none;font-size:14px;font-weight:700;padding:14px 32px;border-radius:12px;letter-spacing:0.5px;">
              View ${athleteName}'s Board →
            </a>
          </div>
        </td></tr>

        <!-- Footer -->
        <tr><td style="background:#F0EDF8;border-radius:0 0 16px 16px;border:1px solid #E5E5E5;border-top:none;padding:20px 32px;text-align:center;">
          <div style="font-size:12px;color:#888;line-height:1.6;">
            This update was made by <strong>${activity.actor_name || "your coaching staff"}</strong> on ${new Date(activity.created_at).toLocaleDateString("en-US", { weekday: "long", year: "numeric", month: "long", day: "numeric" })}.<br/>
            You're receiving this because you have a Scholars Elite family portal account.<br/>
            <a href="https://scholars-elite-portal-v2.netlify.app" style="color:${BRAND.primary};text-decoration:none;font-weight:600;">Open Portal</a>
          </div>
        </td></tr>

      </table>
    </td></tr>
  </table>
</body>
</html>`;

  return { subject: info.subject, html };
}

// ── HANDLER ───────────────────────────────────────────────────────────────────
export default async (req: Request) => {
  // Only accept POST
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // Verify Supabase webhook secret
  const webhookSecret = Netlify.env.get("SUPABASE_WEBHOOK_SECRET");
  if (webhookSecret) {
    const signature = req.headers.get("x-webhook-secret");
    if (signature !== webhookSecret) {
      return new Response("Unauthorized", { status: 401 });
    }
  }

  const resendKey = Netlify.env.get("RESEND_API_KEY");
  const supabaseUrl = Netlify.env.get("SUPABASE_URL");
  const supabaseServiceKey = Netlify.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const fromEmail = Netlify.env.get("FROM_EMAIL") || "portal@scholarselitegirls.org";

  if (!resendKey || !supabaseUrl || !supabaseServiceKey) {
    console.error("Missing env vars: RESEND_API_KEY, SUPABASE_URL, or SUPABASE_SERVICE_ROLE_KEY");
    return new Response("Configuration error", { status: 500 });
  }

  let payload: { type: string; record: ActivityRecord };
  try {
    payload = await req.json();
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  // Only process INSERT events on activity_feed
  if (payload.type !== "INSERT" || !payload.record) {
    return new Response("OK — skipped", { status: 200 });
  }

  const activity = payload.record;

  // Skip profile_updated events (too noisy)
  if (activity.type === "profile_updated") {
    return new Response("OK — skipped profile_updated", { status: 200 });
  }

  // Skip events triggered by parents themselves (only notify for staff actions)
  // Check if actor is staff by querying profiles
  const profileRes = await fetch(
    `${supabaseUrl}/rest/v1/profiles?id=eq.${activity.actor_id}&select=role`,
    { headers: { "apikey": supabaseServiceKey, "Authorization": `Bearer ${supabaseServiceKey}` } }
  );
  const profiles = await profileRes.json();
  if (!profiles?.[0] || profiles[0].role !== "staff") {
    return new Response("OK — skipped non-staff action", { status: 200 });
  }

  // Get the athlete name
  const athleteRes = await fetch(
    `${supabaseUrl}/rest/v1/athletes?id=eq.${activity.athlete_id}&select=name`,
    { headers: { "apikey": supabaseServiceKey, "Authorization": `Bearer ${supabaseServiceKey}` } }
  );
  const athletes = await athleteRes.json();
  const athleteName = athletes?.[0]?.name || "your athlete";

  // Find parent email linked to this athlete
  const parentRes = await fetch(
    `${supabaseUrl}/rest/v1/profiles?athlete_id=eq.${activity.athlete_id}&role=eq.parent&select=id`,
    { headers: { "apikey": supabaseServiceKey, "Authorization": `Bearer ${supabaseServiceKey}` } }
  );
  const parents = await parentRes.json();

  if (!parents || parents.length === 0) {
    return new Response("OK — no parent linked", { status: 200 });
  }

  // Get emails from auth.users via admin API
  const emailsSent: string[] = [];
  for (const parent of parents) {
    const userRes = await fetch(
      `${supabaseUrl}/auth/v1/admin/users/${parent.id}`,
      { headers: { "apikey": supabaseServiceKey, "Authorization": `Bearer ${supabaseServiceKey}` } }
    );
    const user = await userRes.json();
    const email = user?.email;
    if (!email) continue;

    const { subject, html } = getEmailContent(activity, athleteName);

    // Send via Resend
    const emailRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${resendKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: `Scholars Elite <${fromEmail}>`,
        to: [email],
        subject,
        html,
      }),
    });

    if (emailRes.ok) {
      emailsSent.push(email);
    } else {
      const err = await emailRes.text();
      console.error(`Failed to send to ${email}:`, err);
    }
  }

  return new Response(JSON.stringify({ sent: emailsSent.length, to: emailsSent }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
};

export const config: Config = {
  path: "/api/notify",
};
