# Launch checklist
- [ ] Revoke any API key shared in chat/screenshots; create a replacement.
- [ ] Deploy this folder to Netlify; preserve `netlify.toml` and `netlify/functions/`.
- [ ] Set `GROQ_API_KEY` as a secret environment variable for Functions. Do not put it in GitHub.
- [ ] Optional: set `GROQ_MODEL` to a model available in your Groq account.
- [ ] Redeploy after setting environment variables.
- [ ] Test all navigation links on desktop and mobile.
- [ ] Test AI Tutor, study-guide generation, and CV generation.
- [ ] Before launch to public users, add authentication, cloud storage, rate limits, privacy policy, moderation, and accessible error reporting.
