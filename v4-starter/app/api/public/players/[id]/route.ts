import { NextResponse } from 'next/server';
import { getPublicPlayerById } from '@/lib/players';
type RouteProps = { params: Promise<{ id: string }> };
export async function GET(_: Request, { params }: RouteProps) { const { id } = await params; const player = await getPublicPlayerById(id); if (!player) return NextResponse.json({ error: 'Player not found' }, { status: 404 }); return NextResponse.json({ player }); }
