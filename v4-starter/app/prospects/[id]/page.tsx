import { notFound } from 'next/navigation';
import { fetchPublicPlayerById } from '@/lib/data/public';
export default async function ProspectProfilePage({ params }: { params: { id: string } }) {
  const player = await fetchPublicPlayerById(params.id);
  if (!player) notFound();
  return (
    <div className="prospect-profile"><header className="profile-header"><div><h1>{player.name}</h1><p>{player.position} • Class {player.gradYear}</p></div><div className="initials-orb-xl" style={{ background: `${player.color}22`, color: player.color }}>{player.initials}</div></header><section className="eval-block"><h2>Evaluation</h2><p>{player.evaluation}</p></section><section className="stat-sheet"><h2>Stats</h2><ul><li><strong>PPG:</strong> {player.stats.ppg}</li><li><strong>APG:</strong> {player.stats.apg}</li><li><strong>RPG:</strong> {player.stats.rpg}</li><li><strong>SPG:</strong> {player.stats.spg}</li></ul></section></div>
  );
}
