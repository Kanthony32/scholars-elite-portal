import { NextResponse } from 'next/server';
import { requireStaff } from '@/lib/auth';
type NotePayload = { playerId?: string; body?: string; noteType?: string };
export async function POST(request: Request) {
  const { user, profile, supabase } = await requireStaff(); const payload = (await request.json()) as NotePayload;
  if (!payload.playerId || !payload.body?.trim()) return NextResponse.json({ error: 'playerId and body are required.' }, { status: 400 });
  const { data, error } = await supabase.from('player_notes').insert({ player_id: payload.playerId, author_id: user.id, author_name: profile.full_name ?? profile.email, note_type: payload.noteType ?? 'staff_note', body: payload.body.trim() }).select('id, player_id, author_id, author_name, note_type, body, created_at').single();
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ note: data }, { status: 201 });
}
