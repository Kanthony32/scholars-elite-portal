import Link from 'next/link';
import type { PublicPlayer } from '@/lib/types';
import { formatStat } from '@/lib/utils';
export function FeaturedPlayerCard({ player }: { player: PublicPlayer }) {
  return (
    <Link href={`/prospects/${player.id}`} className="featured-card">
      <div className="featured-top"><span className="eyebrow">Featured Prospect</span><span className="chip chip-team">{player.team}</span></div>
      <div className="featured-main"><div><h3>{player.name}</h3><p>{player.position} • {player.height} • {player.school} • {player.state}</p></div><div className="featured-initials" style={{ background: `${player.color}20`, color: player.color }}>{player.initials}</div></div>
      <div className="featured-eval">{player.evaluation}</div>
      <div className="featured-stats"><div><span>PPG</span><strong>{formatStat(player.stats.ppg)}</strong></div><div><span>APG</span><strong>{formatStat(player.stats.apg)}</strong></div><div><span>RPG</span><strong>{formatStat(player.stats.rpg)}</strong></div><div><span>SPG</span><strong>{formatStat(player.stats.spg)}</strong></div></div>
    </Link>
  );
}
