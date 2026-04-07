import { NextResponse } from 'next/server';
import { createServerSupabaseClient } from '@/lib/supabase/server';
export async function GET(request: Request) {
  const url = new URL(request.url); const supabase = await createServerSupabaseClient(); await supabase.auth.signOut(); return NextResponse.redirect(new URL('/', url.origin));
}
