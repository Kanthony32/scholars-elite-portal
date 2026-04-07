import seedPlayersData from '@/data/seed-players.json';
import type { PublicPlayer } from '@/lib/types';
import { hasSupabaseEnv } from '@/lib/supabase/env';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { teamSortValue } from '@/lib/utils';
const seedPlayers = seedPlayersData as PublicPlayer[];
function sortPlayers(players: PublicPlayer[]) {
  return [...players].sort((a, b) => {
    if (a.featured !== b.featured) return Number(b.featured) - Number(a.featured);
    const teamDelta = teamSortValue(a.team) - teamSortValue(b.team);
    if (teamDelta !== 0) return teamDelta;
    return a.name.localeCompare(b.name);
  });
}
function normalizeRow(row: any): PublicPlayer {
  return {
    id: row.id, name: row.name, firstName: row.first_name, lastName: row.last_name, initials: row.initials, color: row.color,
    team: row.team, position: row.position, gradYear: row.grad_year, height: row.height, wingspan: row.wingspan, school: row.school, state: row.state,
    gpa: row.gpa, gpaDisplay: row.gpa_display, academicStanding: row.academic_standing, testScore: row.test_score, intendedMajor: row.intended_major,
    transcriptStatus: row.transcript_status, archetype: row.archetype, award: row.award, featured: row.featured,
    stats: { ppg: row.stats_ppg, apg: row.stats_apg, rpg: row.stats_rpg, spg: row.stats_spg },
    evaluation: row.evaluation, offensiveStrengths: row.offensive_strengths ?? [], defensiveStrengths: row.defensive_strengths ?? [],
    intangibles: row.intangibles ?? [], developmentFocus: row.development_focus ?? [], collegeFit: row.college_fit ?? '',
    offers: row.offers ?? [], interest: row.interest ?? [], skillScores: row.skill_scores ?? {}, film: row.film ?? [],
    engagementSummary: { views: 0, downloads: 0, watchlistSaves: 0 }, internalNotes: [], evaluationDate: row.evaluation_date ?? '', publicStatus: row.public_status,
  };
}
async function getPlayersFromSupabase() {
  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase.from('players').select('*').order('featured', { ascending: false }).order('team', { ascending: false }).order('name', { ascending: true });
  if (error) throw new Error(`Failed to load players from Supabase: ${error.message}`);
  return (data ?? []).map(normalizeRow);
}
export async function getPublicPlayers() { return hasSupabaseEnv() ? sortPlayers(await getPlayersFromSupabase()) : sortPlayers(seedPlayers); }
export async function getFeaturedPlayers() { const players = await getPublicPlayers(); return players.filter((player) => player.featured).slice(0, 2); }
export async function getPublicPlayerById(id: string) { const players = hasSupabaseEnv() ? await getPlayersFromSupabase() : seedPlayers; return players.find((player) => player.id === id) ?? null; }
