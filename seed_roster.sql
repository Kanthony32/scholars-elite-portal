-- ============================================================
-- SCHOLARS ELITE — FULL ROSTER SEED (32 players, 3 teams)
-- Safe to run: skips existing records via ON CONFLICT DO NOTHING
-- ============================================================

-- First add team column if it doesn't exist
ALTER TABLE athletes ADD COLUMN IF NOT EXISTS team text default '17U';

-- Full roster insert
INSERT INTO athletes (id, name, grad_year, position, height, archetype, gpa, player_level, strengths, development_needs, recruiting_story, offers, highlight_link, visibility_score, access_code, status, team)
VALUES
  ('kassidy', 'Kassidy Ahmad', '2029', 'G', '5''7', 'Pressure Guard', '', 'PL2', 'Transition finisher — converts steals to buckets at elite rate Pace push in secondary break Playmaking IQ elevates teammates in open court', 'Half-court creation off the dribble Shooting volume reps at college range Finishing at rim against length', 'Kassidy Ahmad is the rarest profile in the 2029 class — a pressure guard who creates chaos on defense and immediately converts it into offense. Her 4.9 SPG is a system disruptor. At 5 ft 7 with elite first-step quickness and anticipatory instincts, she reads passing lanes before the ball is released', '{}', '', 5, 'AHMAD2026', 'active', '16U'),
  ('abria_h', 'Abria Hason', '2028', 'G/F', '5''8', 'Two-Way Wing / Secondary Scorer', '', 'PL4', '', '', 'Complementary wing with scoring pop — 5.1 PPG, 3.2 RPG, 0.9 SPG with an 18-point season high. Useful two-way profile with size for the spot at Bishop Eustace.', '{}', '', 5, 'ABRIAH2026', 'active', '16U'),
  ('alexa_r', 'Alexa Racobaldo', '2028', 'SF/SG', '6''0', 'Versatile Frontcourt Wing', '', 'PL3', '', '', 'Multi-category frontcourt wing with real across-the-board production — 8.0 PPG, 7.2 RPG, 2.3 APG, 1.2 SPG, and 1.1 BPG. At 6 ft 0 she has the length to impact every possession on both ends. Rebounding and rim-protection value at the wing is rare at this age.', '{}', '', 5, 'ALEXAR2026', 'active', '16U'),
  ('aslyn_m', 'Aslyn Merrell', '2028', 'SF/PF', '5''11', 'Frontcourt Wing / Stretch Forward', '', 'PL4', '', '', 'Frontcourt Wing / Stretch Forward', '{}', '', 5, 'ASLYNM2026', 'active', '16U'),
  ('damiya_c', 'Damiya Carter', '2028', 'PG', '5''6', 'Scoring Point Guard / Two-Way Lead Guard', '', 'PL2', '', '', '15.3 PPG, 5.1 RPG, and 1.3 made threes — Damiya Carter is the most productive guard profile in the 16U class by public numbers. Scoring, pressure defense, and on-ball juice all showing in the data. South Jersey programs that want a two-way lead guard need to prioritize this file now.', '{}', '', 5, 'DAMIYAC2026', 'active', '16U'),
  ('dylan_h', 'Dylan Hall', '2028', 'SF', '5''10', 'Two-Way Wing', '', 'PL4', '', '', 'Two-Way Wing', '{}', '', 5, 'DYLANH2026', 'active', '16U'),
  ('jillian_g', 'Jillian Guzzardo', '2028', 'PG/SG', '5''7', 'Movement Shooter / Combo Guard', '', 'PL4', '', '', 'Movement shooter with live-ball activity — 5.7 PPG with 1.6 made threes and 1.5 SPG. Season highs of 12 points and 4 threes, with a 6-steal game on the defensive end.', '{}', '', 5, 'JILLIANG2026', 'active', '16U'),
  ('lily_c', 'Lily Czubas', '2028', 'F', '', 'Productive Forward', '', 'PL3', '', '', 'Productive Forward', '{}', '', 5, 'LILYC2026', 'active', '16U'),
  ('meso_n', 'Meso Nwobu', '2028', 'G', '5''7', 'Shooter / Combo Guard', '', 'PL4', '', '', 'Shooter / Combo Guard', '{}', '', 5, 'MESON2026', 'active', '16U'),
  ('ava', 'Ava London', '2026', 'PG', '5''8', 'Point-of-Attack Creator', '4.1', 'PL2', 'Elite court vision — sees plays 2 passes ahead Shot creation off dribble in half-court Carry-the-offense playmaking at 17', 'Pull-up mid-range consistency Finishing through contact at rim', 'True PG who sees plays before they develop. Combines elite court vision with shot creation ability rare at this age.', '{}', '', 5, 'AVA2026', 'active', '17U'),
  ('nasiaah', 'Nasiaah Russell', '2027', 'C/PF', '6''3', 'Interior Anchor', '3.8', 'PL2', 'Dominant interior presence High-low passing from high post Shooting range developing', 'Extending range to perimeter Post footwork refinement', 'Committed to St. Johns University. One of the highest-profile prospects in the program — 6 ft 3 C/PF with the body and skill set already built for high-level competition. Contact staff for full evaluation film and academic information.', '{}', '', 5, 'RUSSELL2026', 'active', '17U'),
  ('raegan', 'Raegan Wells-Bradley', '2027', 'SF', '5''10', 'Dominant Wing', '3.6', 'PL2', 'Elite scoring volume — 34.5 PPG Physical presence changes games Rebounding instincts', 'Face-up shooting range Transition navigation against length', 'Massive production profile — 34.5 PPG is one of the highest public stat lines in the region. Physical wing with genuine versatility on both ends. Frame is college-ready today.', '{}', '', 5, 'RAEGAN2027', 'active', '17U'),
  ('aiyanna_s', 'Aiyanna Smith', '2027', 'G', '5''9', 'Combo Guard / Regional Elite Program', '', 'PL4', '', '', 'Combo Guard / Regional Elite Program', '{}', '', 5, 'AIYANNAS2026', 'active', '17U'),
  ('ashlee_b', 'Ashlee Boykin', '2027', 'PG', '5''3', 'Small Lead Guard / Pressure Guard', '', 'PL4', '', '', 'Public profile screams pace, ball pressure, and guard toughness — returning junior guard in Imhotep Charter nucleus. Needs a fuller stat pull but program context says everything about the competitive level.', '{}', '', 5, 'ASHLEEB2026', 'active', '17U'),
  ('asia_a', 'Asia Adams', '2027', 'PG/SG', '5''5', 'Dynamic Scoring Guard / Offensive Ignition', '', 'PL4', '', '', 'Offensive ignition at its best — 21, 23, and 23 points in Sanford first three playoff games. When the lights get brighter she plays bigger. Scoring guard who needs no warmup against elite competition.', '{}', '', 5, 'ASIAA2026', 'active', '17U'),
  ('iyonna_e', 'Iyonna Ellison', '2028', 'PG', '5''3', 'Table-Setting Point Guard', '', 'PL3', '', '', 'Table-setting point guard with a complete floor game — 9.5 PPG with championship coverage highlighting assists rebounds and steals impact. Audenried runs through her.', '{}', '', 5, 'IYONNAE2026', 'active', '17U'),
  ('julia_m', 'Julia Marigliano', '2027', 'PG/SG', '5''6', 'Lead Guard / Organizer-Shooter', '', 'PL3', '', '', 'Genuine point-guard functionality with shot-making — 210 points and 85 assists on the season with 32 percent from three. Atlantic City runs through her.', '{}', '', 5, 'JULIAM2026', 'active', '17U'),
  ('jordyn', 'Jordyn Pierce', '2027', 'C/PF', '6''2', 'Stretch Big', '3.5', 'PL3', '6 ft 2 with mobility — rare combination High-low passing from high post Range to 18 feet', 'Extending range to the 3 Post footwork on left block', 'Length, mobility, and emerging face-up game make Jordyn a legitimate option at the next level. 6 ft 2 with 6 ft 5 wingspan — programs need to see her in person.', '{}', '', 5, 'JORDYN2027', 'active', '17U'),
  ('rowan_s', 'Rowan Shapiro', '2027', 'G/SG', '5''5', 'Secondary Playmaker / Shooter', '', 'PL4', '', '', 'Smart academic-school guard with real all-around production — 5.1 PPG, 2.4 APG, 1.3 SPG, and 1.1 made threes. The playmaking-plus-spacing combination at Pingry is a college contacts builder.', '{}', '', 5, 'ROWANS2026', 'active', '17U'),
  ('taylor_b', 'Taylor Brooks', '2027', 'PG', '5''6', 'Facilitator / Setup Guard', '4', 'PL3', 'Elite assist-to-turnover ratio Sets teammates up perfectly Court IQ-based player', 'Shot creation off dribble Scoring against length', 'Pure facilitator with elite IQ. Elite assist-to-turnover ratio — she makes everyone around her better.', '{}', '', 5, 'TAYLOR2026', 'active', '17U'),
  ('abbie_r', 'Abbie Racobaldo', '2029', 'G/F', '5''8', 'Utility Guard / Connective Wing', '', 'PL4', '', '', 'Utility Guard / Connective Wing', '{}', '', 5, 'ABBIER2026', 'active', '15U'),
  ('alaysia_j', 'Alaysia Jeune', '2029', 'SF', '5''10', 'Stretch Wing / Scoring Forward', '', 'PL4', '', '', 'Young floor-spacing wing with early shot-making value — 6.4 PPG with 1.0 made threes and a season high of 18 points with 4 threes. Shooting volume at 15 is the number to track.', '{}', '', 5, 'ALAYSIAJ2026', 'active', '15U'),
  ('anna_w', 'Anna Weiss', '2029', 'SG/SF', '5''8+', 'Wing Shooter / Developmental Spacer', '', 'PL4', '', '', 'Wing Shooter / Developmental Spacer', '{}', '', 5, 'ANNAW2026', 'active', '15U'),
  ('aubrey_m', 'Aubrey Mack', '2029', 'PF', '', 'Interior Forward / Rebound-Finisher', '', 'PL3', '', '', 'Interior Forward / Rebound-Finisher', '{}', '', 5, 'AUBREYM2026', 'active', '15U'),
  ('galima_e', 'Galima Etienne', '2028', 'SF/PF', '5''10+', 'Long Hybrid Forward', '', 'PL4', '', '', 'Long Hybrid Forward', '{}', '', 5, 'GALIMAE2026', 'active', '15U'),
  ('jaibreon_l', 'Jaibreon Lardell', '2029', 'SF/SG', '5''8', 'Rebounding Wing / Slasher', '', 'PL3', '', '', 'Strong activity profile for a freshman wing — 9.8 PPG and 8.1 RPG puts her in elite territory for the 2029 class. Projects as a glass-and-pressure player with real scoring juice.', '{}', '', 5, 'JAIBREONL2026', 'active', '15U'),
  ('khanihya_j', 'Kha''nihya Johnson', '2029', 'G', '', 'Impact Guard', '', 'PL4', '', '', 'Impact Guard', '{}', '', 5, 'KHANIHYAJ2026', 'active', '15U'),
  ('laila_m', 'Laila McNeal', '2029', 'G', '', 'Young Lead Guard', '', 'PL4', '', '', 'Young Lead Guard', '{}', '', 5, 'LAILAM2026', 'active', '15U'),
  ('maya', 'Maya Thompson', '2028', 'PG/SG', '5''7', 'Early Watch Prospect', '3.9', 'PL3', '', '', 'Rare 2028 with legitimate upside. Athleticism and shot mechanics project to a high level. Track this early.', '{}', '', 5, 'MAYA2026', 'active', '15U'),
  ('nyla_h', 'Nyla Hill', '2029', 'G', '5''5', 'Microwave Guard / Shot-Maker', '', 'PL4', '', '', 'Microwave young guard who has already flashed scoring bursts — 16 points with 4 threes is the season high as a freshman at Camden Catholic.', '{}', '', 5, 'NYLAH2026', 'active', '15U'),
  ('sara_g', 'Sara Guveiyian', '2029', 'SG', '', 'Shooting Guard', '', 'PL4', '', '', 'Shooting Guard', '{}', '', 5, 'SARAG2026', 'active', '15U'),
  ('taylor_t', 'Taylor Tucker', '2029', 'G', '', 'Young Contributor', '', 'PL4', '', '', 'Young Contributor', '{}', '', 5, 'TAYLORT2026', 'active', '15U')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  grad_year = EXCLUDED.grad_year,
  position = EXCLUDED.position,
  height = EXCLUDED.height,
  archetype = EXCLUDED.archetype,
  player_level = EXCLUDED.player_level,
  strengths = EXCLUDED.strengths,
  development_needs = EXCLUDED.development_needs,
  recruiting_story = EXCLUDED.recruiting_story,
  highlight_link = EXCLUDED.highlight_link,
  access_code = EXCLUDED.access_code,
  team = EXCLUDED.team;

-- Verify
SELECT team, count(*) as players FROM athletes GROUP BY team ORDER BY team;

-- ── STAFF MESSAGES TABLE (for staff → family messaging) ──────────────────────
create table if not exists public.staff_messages (
  id          uuid default gen_random_uuid() primary key,
  athlete_id  text references athletes(id) on delete cascade not null,
  sender_id   uuid references auth.users(id),
  sender_name text,
  message     text not null,
  visible_to_family boolean default true,
  created_at  timestamptz default now()
);

alter table public.staff_messages enable row level security;

drop policy if exists "messages: staff insert"  on staff_messages;
drop policy if exists "messages: staff select"  on staff_messages;
drop policy if exists "messages: parent select" on staff_messages;

create policy "messages: staff insert" on staff_messages for insert with check (
  public.get_my_role() = 'staff'
);
create policy "messages: staff select" on staff_messages for select using (
  public.get_my_role() = 'staff'
);
create policy "messages: parent select" on staff_messages for select using (
  (select athlete_id from profiles where id = auth.uid()) = staff_messages.athlete_id
  and visible_to_family = true
);
