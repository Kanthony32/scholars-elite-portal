import Link from 'next/link';
import type { PublicPlayer } from '@/lib/types';
import { formatStat } from '@/lib/utils';
export function PlayerCard({ player }: { player: PublicPlayer }) {
  return (
    <Link href={`/prospects/${player.id}`} className="player-card">
      <div className="player-card-hero" style={{ borderColor: `${player.color}66` }}>
        <div className="player-card-badge-row"><span className="chip chip-team">{player.team}</span><span className="chip chip-status">{player.publicStatus === 'committed' ? 'Committed' : 'Available'}</span></div>
        <div className="initials-orb" style={{ background: `${player.color}22`, color: player.color }}>{player.initials}</div>
        <div><h3>{player.name}</h3><p>{player.position} • Class {player.gradYear} • {player.school}</p></div>
      </div>
      <div className="player-card-body">
        <div className="stat-row"><div><span>PPG</span><strong>{formatStat(player.stats.ppg)}</strong></div><div><span>APG</span><strong>{formatStat(player.stats.apg)}</strong></div><div><span>RPG</span><strong>{formatStat(player.stats.rpg)}</strong></div><div><span>SPG</span><strong>{formatStat(player.stats.spg)}</strong></div></div>
        <div className="player-card-meta"><span>{player.archetype}</span><span>{player.height}</span><span>{player.state}</span></div>
        {player.award ? <div className="award-pill">★ {player.award}</div> : null}
      </div>
    </Link>
  );
}
