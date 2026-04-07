export type PlayerStats = { ppg: number | null; apg: number | null; rpg: number | null; spg: number | null };
export type FilmEntry = { title: string; subtitle: string; url: string | null };
export type PublicPlayer = {
  id: string; name: string; firstName: string; lastName: string; initials: string; color: string;
  team: string; position: string; gradYear: string; height: string; wingspan: string; school: string; state: string;
  gpa: number | null; gpaDisplay: string; academicStanding: string; testScore: number | null; intendedMajor: string;
  transcriptStatus: string | null; archetype: string; award: string | null; featured: boolean; stats: PlayerStats;
  evaluation: string; offensiveStrengths: string[]; defensiveStrengths: string[]; intangibles: string[];
  developmentFocus: string[]; collegeFit: string; offers: string[]; interest: string[]; skillScores: Record<string, number>;
  film: FilmEntry[]; engagementSummary: { views: number; downloads: number; watchlistSaves: number };
  internalNotes: Array<{ type: string; body: string; dateLabel: string; color: string }>;
  evaluationDate: string; publicStatus: 'available' | 'committed';
};
export type StaffProfile = { user_id: string; email: string; full_name: string | null; role: 'admin' | 'coach' | 'recruiting' | 'viewer'; is_active: boolean };
export type StaffPlayerProfile = { player_id: string; internal_priority: number | null; recruiting_board_status: string | null; internal_summary: string | null; coach_fit_notes: string | null; updated_at: string };
export type PlayerEngagementMetrics = { player_id: string; views: number; downloads: number; watchlist_saves: number; updated_at: string };
export type PlayerNote = { id: string; player_id: string; author_id: string | null; author_name: string | null; note_type: string; body: string; created_at: string };
export type StaffPlayerBundle = { player: PublicPlayer; staffProfile: StaffPlayerProfile | null; metrics: PlayerEngagementMetrics | null; notes: PlayerNote[] };
