import type { ReactNode } from 'react';
import Link from 'next/link';
import { hasSupabaseEnv } from '@/lib/supabase/env';
export function SiteShell({ children }: { children: ReactNode }) {
  return (
    <div className="site-shell">
      <header className="topbar"><div className="container topbar-inner"><Link href="/" className="brand"><span className="brand-dot" /><span className="brand-word">SCHOLARS</span><span className="brand-sub">COACH ACCESS</span></Link><nav className="nav-links"><Link href="/">Home</Link><Link href="/prospects">Prospects</Link><Link href="/staff">Staff</Link><Link href="/sign-in">Sign In</Link></nav></div></header>
      {!hasSupabaseEnv() ? <div className="config-banner"><div className="container">Public pages are running from local seed data. Staff auth and protected recruiting data activate after you connect Supabase.</div></div> : null}
      <main>{children}</main>
    </div>
  );
}
