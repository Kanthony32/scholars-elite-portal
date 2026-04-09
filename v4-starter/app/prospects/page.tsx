import { fetchPublicPlayers } from '@/lib/data/public';
import { FeaturedPlayerCard } from '@/components/featured-player-card';
import { PublicDirectory } from '@/components/public-directory';
export default async function ProspectsPage() {
  const featured = (await fetchPublicPlayers()).find((p) => p.featured) ?? null;
  const allPlayers = await fetchPublicPlayers();
  return (
    <div className="prospects-page"><header className="hero-header"><h1>Scholars Elite • Player Directory</h1><p>Public-facing evaluations and statistical profiles</p></header>{featured ? <FeaturedPlayerCard player={featured} /> : null}<h2 className="section">All Prospects</h2><PublicDirectory players={allPlayers} /></div>
  );
}
