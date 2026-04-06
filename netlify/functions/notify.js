// Netlify serverless function — handles Supabase webhook on activity_feed INSERT
// Sends email via Resend API

export default async (req, context) => {
  const secret = req.headers.get("x-webhook-secret");
  if (secret !== Netlify.env.get("SUPABASE_WEBHOOK_SECRET")) {
    return new Response("Unauthorized", { status: 401 });
  }

  let body;
  try { body = await req.json(); } catch { return new Response("Bad Request", { status: 400 }); }

  const record = body.record || body;
  const { athlete_id, message, type, actor_name } = record;
  if (!athlete_id || !message) return new Response("OK", { status: 200 });

  // Skip internal/low-priority events
  const skipTypes = ["progress_view", "session_start"];
  if (skipTypes.includes(type)) return new Response("OK", { status: 200 });

  const RESEND_KEY = Netlify.env.get("RESEND_API_KEY");
  const SUPABASE_URL = Netlify.env.get("SUPABASE_URL");
  const SUPABASE_KEY = Netlify.env.get("SUPABASE_SERVICE_ROLE_KEY");

  // Get athlete + family email from Supabase
  const athleteRes = await fetch(
    `${SUPABASE_URL}/rest/v1/athletes?id=eq.${athlete_id}&select=name,team,grad_year`,
    { headers: { "apikey": SUPABASE_KEY, "Authorization": `Bearer ${SUPABASE_KEY}` } }
  );
  const athletes = await athleteRes.json();
  const athlete = athletes[0];
  if (!athlete) return new Response("OK", { status: 200 });

  // Get family email
  const profileRes = await fetch(
    `${SUPABASE_URL}/rest/v1/profiles?athlete_id=eq.${athlete_id}&role=eq.parent&select=id`,
    { headers: { "apikey": SUPABASE_KEY, "Authorization": `Bearer ${SUPABASE_KEY}` } }
  );
  const profiles = await profileRes.json();
  if (!profiles || profiles.length === 0) return new Response("OK", { status: 200 });

  // Get auth users for those profile IDs
  const emailRes = await fetch(
    `${SUPABASE_URL}/auth/v1/admin/users`,
    { headers: { "apikey": SUPABASE_KEY, "Authorization": `Bearer ${SUPABASE_KEY}` } }
  );
  const usersData = await emailRes.json();
  const profileIds = new Set(profiles.map(p => p.id));
  const familyEmails = (usersData.users || [])
    .filter(u => profileIds.has(u.id))
    .map(u => u.email)
    .filter(Boolean);

  if (familyEmails.length === 0) return new Response("OK", { status: 200 });

  const typeLabels = {
    school_added: "📚 New School Added",
    school_removed: "School Removed",
    committed: "🎉 Commitment Logged",
    signed: "🏆 NLI Signed",
    staff_note: "📬 Staff Note",
    offer_received: "🎯 Offer Received",
  };
  const subject = typeLabels[type] || "📊 Portal Update";

  const emailBody = `
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"/></head>
<body style="margin:0;padding:0;background:#0A0515;font-family:'DM Sans',Arial,sans-serif;color:#EDE8F8;">
<div style="max-width:520px;margin:0 auto;padding:32px 20px;">
  <div style="text-align:center;margin-bottom:28px;">
    <div style="font-family:Georgia,serif;font-size:24px;font-weight:700;background:linear-gradient(135deg,#7B3FC4,#D63FCC);-webkit-background-clip:text;-webkit-text-fill-color:transparent;letter-spacing:2px;">SCHOLARS ELITE</div>
    <div style="font-size:11px;color:#7060A0;letter-spacing:3px;">ACADEMY · FAMILY PORTAL</div>
  </div>
  <div style="background:#140E28;border:1px solid #2E1D52;border-radius:16px;padding:24px;margin-bottom:20px;">
    <div style="font-size:20px;font-weight:800;color:#EDE8F8;margin-bottom:4px;">${athlete.name}</div>
    <div style="font-size:12px;color:#7060A0;margin-bottom:20px;">${athlete.team} · Class of ${athlete.grad_year}</div>
    <div style="background:#7B3FC420;border:1px solid #7B3FC455;border-radius:12px;padding:16px;">
      <div style="font-size:11px;font-weight:700;letter-spacing:2px;color:#D63FCC;margin-bottom:8px;text-transform:uppercase;">${subject}</div>
      <div style="font-size:14px;color:#B8A8D8;line-height:1.6;">${message}</div>
      ${actor_name ? `<div style="font-size:11px;color:#7060A0;margin-top:8px;">— ${actor_name}</div>` : ""}
    </div>
  </div>
  <div style="text-align:center;">
    <a href="https://scholars-elite-portal-v2.netlify.app" style="display:inline-block;padding:12px 28px;border-radius:12px;background:linear-gradient(135deg,#7B3FC4,#D63FCC);color:white;font-size:13px;font-weight:700;text-decoration:none;">View Portal →</a>
  </div>
  <div style="text-align:center;margin-top:24px;font-size:11px;color:#7060A0;">
    Scholars Elite Academy · scholarselitegirls.org
  </div>
</div>
</body>
</html>`;

  // Send to all family emails
  const sendPromises = familyEmails.map(email =>
    fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { "Authorization": `Bearer ${RESEND_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        from: "Scholars Elite <portal@scholarselitegirls.org>",
        to: email,
        subject: `${subject} — ${athlete.name}`,
        html: emailBody,
      })
    })
  );

  await Promise.allSettled(sendPromises);
  return new Response(JSON.stringify({ sent: familyEmails.length }), { status: 200 });
};

export const config = {
  path: "/api/notify"
};
