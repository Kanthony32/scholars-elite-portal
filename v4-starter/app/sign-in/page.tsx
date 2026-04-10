import { SignInForm } from '@/components/sign-in-form';
export default function SignInPage() {
  return (
    <div className="sign-in-page"><h1>Coach Access Sign‑In</h1><p>Enter your work email to receive a magic login link.</p><SignInForm nextPath="/staff" /></div>
  );
}
