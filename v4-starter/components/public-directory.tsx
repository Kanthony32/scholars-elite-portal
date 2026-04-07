'use client';
import { useMemo, useState } from 'react';
import type { PublicPlayer } from '@/lib/types';
import { PlayerCard } from '@/components/player-card';
import { teamSortValue } from '@/lib/utils';
export function PublicDirectory({ players }: { players: PublicPlayer[] }) {
  const [query, setQuery] = useState('');
  const [team, setTeam] = useState('');
  const [position, setPosition] = useState('');
  const filteredPlayers = useMemo(() => {
    const q = query.trim().toLowerCase();
    return [...players].filter((player) => {
      const matchesQuery = !q || player.name.toLowerCase().includes(q) || player.school.toLowerCase().includes(q) || player.position.toLowerCase().includes(q);
      const matchesTeam = !team || player.team === team;
      const matchesPosition = !position || player.position.includes(position);
      return matchesQuery && matchesTeam && matchesPosition;
    }).sort((a, b) => {
      const teamDelta = teamSortValue(a.team) - teamSortValue(b.team);
      if (teamDelta !== 0) return teamDelta;
      return a.name.localeCompare(b.name);
    });
  }, [players, position, query, team]);
  return (
    <div className="directory-shell">
      <div className="filter-bar"><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search name, school, or position" /><select value={team} onChange={(event) => setTeam(event.target.value)}><option value="">All Teams</option><option value="17U">17U</option><option value="16U">16U</option><option value="15U">15U</option></select><select value={position} onChange={(event) => setPosition(event.target.value)}><option value="">All Positions</option><option value="PG">PG</option><option value="SG">SG</option><option value="G">G</option><option value="SF">SF</option><option value="PF">PF</option><option value="F">F</option><option value="C">C</option></select><button type="button" className="ghost-button" onClick={() => { setQuery(''); setTeam(''); setPosition(''); }}>Reset</button></div>
      <div className="directory-count">{filteredPlayers.length} prospects</div>
      <div className="card-grid">{filteredPlayers.map((player) => <PlayerCard key={player.id} player={player} />)}</div>
    </div>
  );
}
