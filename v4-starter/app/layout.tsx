import type { Metadata } from 'next';
import type { ReactNode } from 'react';
import '@/app/globals.css';
import { SiteShell } from '@/components/site-shell';
export const metadata: Metadata = { title: 'Scholars Coach Access V4', description: 'Protected recruiting hub for Scholars Elite staff and college coaches.' };
export default function RootLayout({ children }: Readonly<{ children: ReactNode }>) {
  return <html lang="en"><body><SiteShell>{children}</SiteShell></body></html>;
}
