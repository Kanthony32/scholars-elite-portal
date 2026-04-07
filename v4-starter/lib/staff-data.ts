import type { PlayerEngagementMetrics, PlayerNote, StaffPlayerBundle, StaffPlayerProfile } from '@/lib/types';
import { createServerSupabaseClient } from '@/lib/supabase/server';
import { getPublicPlayerById, getPublicPlayers } from '@/lib/players';
export async function getStaffPlayersList() {
  const players = await getPublicPlayers();
  const supabase = await createServerSupabaseClient();
  const { data: metrics, error } = await supabase.from('player_engagement_metrics').select('player_id, views, downloads, watchlist_saves, updated_at');
  if (error) throw new Error(`Failed to load engagement metrics: ${error.message}`);
  const metricMap = new Map<string, PlayerEngagementMetrics>((metrics ?? []).map((row: any) => [row.player_id, row]));
  return players.map((player) => ({ ...player, engagementSummary: metricMap.get(player.id) ? { views: metricMap.get(player.id)!.views, downloads: metricMap.get(player.id)!.downloads, watchlistSaves: metricMap.get(player.id)!.watchlist_saves } : player.engagementSummary }));
}
export async function getStaffPlayerBundle(playerId: string): Promise<StaffPlayerBundle | null> {
  const player = await getPublicPlayerById(playerId); if (!player) return null;
  const supabase = await createServerSupabaseClient();
  const [{ data: staffProfile, error: staffProfileError }, { data: metrics, error: metricsError }, { data: notes, error: notesError }] = await Promise.all([
    supabase.from('player_staff_profiles').select('player_id, internal_priority, recruiting_board_status, internal_summary, coach_fit_notes, updated_at').eq('player_id', playerId).maybeSingle<StaffPlayerProfile>(),
    supabase.from('player_engagement_metrics').select('player_id, views, downloads, watchlist_saves, updated_at').eq('player_id', playerId).maybeSingle<PlayerEngagementMetrics>(),
    supabase.from('player_notes').select('id, player_id, author_id, author_name, note_type, body, created_at').eq('player_id', playerId).order('created_at', { ascending: false }).returns<PlayerNote[]>(),
  ]);
  if (staffProfileError) throw new Error(`Failed to load staff player profile: ${staffProfileError.message}`);
  if (metricsError) throw new Error(`Failed to load player metrics: ${metricsError.message}`);
  if (notesError) throw new Error(`Failed to load player notes: ${notesError.message}`);
  return { player: { ...player, engagementSummary: metrics ? { views: metrics.views, downloads: metrics.downloads, watchlistSaves: metrics.watchlist_saves } : player.engagementSummary }, staffProfile, metrics, notes: notes ?? [] };
}
