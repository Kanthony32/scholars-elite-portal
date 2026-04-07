import { NextResponse } from 'next/server';
import { requireStaff } from '@/lib/auth';
import { getStaffPlayerBundle } from '@/lib/staff-data';
type RouteProps = { params: Promise<{ id: string }> };
export async function GET(_: Request, { params }: RouteProps) { await requireStaff(); const { id } = await params; const player = await getStaffPlayerBundle(id); if (!player) return NextResponse.json({ error: 'Player not found' }, { status: 404 }); return NextResponse.json({ player }); }
