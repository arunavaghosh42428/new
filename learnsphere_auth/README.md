# LearnSphere — multi-page AI learning website

## Pages
- `index.html` Home
- `library.html` class/level/subject-filtered curated learning resources
- `documents.html` AI study-document generator and local file selection preview
- `tutor.html` AI tutor with language choice and text-to-speech
- `cv-builder.html` guided AI CV generator
- `career.html` career and interview planning
- `community.html` local-only question drafts
- `study-space.html` focus timer and local flashcards
- `account.html` local preferences preview

## Deploy on Netlify
1. Upload the contents of this ZIP to GitHub or deploy the extracted folder to Netlify. Keep `netlify.toml` and the entire `netlify/functions` folder.
2. In Netlify → Site configuration → Environment variables, create `GROQ_API_KEY` and paste a **new** key from https://console.groq.com/keys. Mark it as a secret if that option is shown, keep it available to Functions, and never commit it to GitHub.
3. Optional: create `GROQ_MODEL` with a model name currently available in your Groq account. Default is `llama-3.3-70b-versatile`; availability may change.
4. Redeploy after adding variables. Test the AI Tutor, Study Documents and CV Builder.

## Security and feature scope
API keys are used only inside Netlify Functions and are not sent to the browser. AI calls may consume provider quota. The community, profile preferences, flashcards, and file selection in this starter are browser-local; they are not cloud-synced. A production community requires authentication, a database, abuse prevention, and moderation. The notes file input only selects a file locally; it does not upload it. Supabase schema from the earlier starter is retained but not automatically connected. Medical resources are educational, not clinical guidance.

## Enable real sign-in / registration (Supabase Auth)
The account page now supports email/password registration, login, logout, password-reset email, and profile save through Supabase. It does not store passwords locally. You must connect your own Supabase project before these features work.

1. Create a project at https://supabase.com/.
2. In Supabase, open **Project Settings → API** (or **Connect**) and copy the **Project URL** and the **publishable key** / legacy **anon public key**.
3. Edit `supabase-config.js` and replace `https://YOUR-PROJECT-ID.supabase.co` and `YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY` with those two values. These are browser-safe public project settings. **Never put a `service_role` / secret key in this file or GitHub.**
4. In Supabase **Authentication → URL Configuration**, add your deployed Netlify URL to **Site URL** and **Redirect URLs** (for password-reset links, include `https://YOUR-SITE.netlify.app/account.html`).
5. In Supabase **SQL Editor**, run `supabase/schema.sql` to create the profile table and row-level security policies. If you have already run an older copy of this schema, inspect policy errors rather than blindly rerunning it; policies may already exist.
6. In **Authentication → Providers**, enable Email. For real users, keep email confirmation enabled where appropriate and configure SMTP if you need reliable production email delivery.
7. Commit the updated `supabase-config.js` and push to GitHub, then redeploy on Netlify. Test signup with an email you can access, confirm it if prompted, then log in and save the profile.

### Authentication safety notes
- The Supabase URL and publishable/anon key are designed for browser use; database access is still controlled by Row Level Security policies.
- Never expose a Supabase `service_role` key or any provider secret in frontend files.
- This starter implements email/password authentication and profile persistence. Social login, multi-factor authentication, account deletion workflows, and production abuse protections are not included yet.
- For production use with children/students, review privacy, consent, retention, moderation, and applicable legal requirements before collecting user data.
