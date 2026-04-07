import { NextResponse } from 'next/server';
import { getPublicPlayers } from '@/lib/players';
export async function GET() { const players = await getPublicPlayers(); return NextResponse.json({ players }); }
