'use client';
import { useMemo, useState, type FormEvent } from 'react';
import { createBrowserSupabaseClient } from '@/lib/supabase/client';
export function SignInForm({ nextPath }: { nextPath: string }) {
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const redirectTo = useMemo(() => {
    if (typeof window === 'undefined') return '';
    const next = encodeURIComponent(nextPath || '/staff');
    return `${window.location.origin}/auth/callback?next=${next}`;
  }, [nextPath]);
  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); setLoading(true); setError(null); setMessage(null);
    try {
      const supabase = createBrowserSupabaseClient();
      const { error: signInError } = await supabase.auth.signInWithOtp({ email, options: { emailRedirectTo: redirectTo } });
      if (signInError) throw signInError;
      setMessage('Magic link sent. Check your inbox and open it in the same browser.');
      setEmail('');
    } catch (caught) {
      const err = caught as Error; setError(err.message || 'Unable to start sign-in.');
    } finally { setLoading(false); }
  }
  return (
    <form onSubmit={handleSubmit} className="sign-in-form"><label>Work email<input type="email" value={email} onChange={(event) => setEmail(event.target.value)} placeholder="coach@school.edu" required /></label><button className="primary-button" type="submit" disabled={loading}>{loading ? 'Sending…' : 'Send magic link'}</button>{message ? <p className="success-copy">{message}</p> : null}{error ? <p className="error-copy">{error}</p> : null}</form>
  );
}
