import { NextResponse } from 'next/server';
import { requireStaff } from '@/lib/auth';
import { getStaffPlayersList } from '@/lib/staff-data';
export async function GET() { await requireStaff(); const players = await getStaffPlayersList(); return NextResponse.json({ players }); }
