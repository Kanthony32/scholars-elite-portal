'use client';
import { useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';
export function StaffNoteForm({ playerId }: { playerId: string }) {
  const router = useRouter(); const [body, setBody] = useState(''); const [saving, setSaving] = useState(false); const [error, setError] = useState<string | null>(null);
  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); if (!body.trim()) return; setSaving(true); setError(null);
    try {
      const response = await fetch('/api/staff/notes', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ playerId, body: body.trim(), noteType: 'staff_note' }) });
      if (!response.ok) { const payload = await response.json().catch(() => ({})); throw new Error(payload.error ?? 'Unable to save note.'); }
      setBody(''); router.refresh();
    } catch (caught) { const err = caught as Error; setError(err.message || 'Unable to save note.'); } finally { setSaving(false); }
  }
  return (
    <form onSubmit={handleSubmit} className="note-form"><textarea value={body} onChange={(event) => setBody(event.target.value)} rows={4} placeholder="Add a staff-only recruiting note" /><div className="note-form-footer"><button type="submit" className="primary-button" disabled={saving}>{saving ? 'Saving…' : 'Save note'}</button>{error ? <span className="error-copy">{error}</span> : null}</div></form>
  );
}
