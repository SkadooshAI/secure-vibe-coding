# 02 · Full security audit

The big one. Gives you a prioritized list of real risks in your app, explained in plain words.

Use: before launch, then monthly. Works best with your strongest model and a fresh session.

```text
Act as a senior application security engineer reviewing this codebase before a public launch. The app was built quickly with AI help, so assume common AI-generated mistakes are present until proven otherwise.

Rules:
- Report first. Do not modify any files until I approve.
- Never open .env / secret files and never print secret values. If you need to know whether a variable is set, ask me.
- For every finding give evidence: file:line and the exact code path. No generic advice without evidence.
- If you are not sure something is exploitable, say so and say how I can test it.

Step 1. Map the app (short):
- Stack, frameworks, hosting, database, auth provider, payment provider, third-party APIs.
- Every entry point: pages, API routes, server actions, edge functions, webhooks, cron jobs, background workers, file uploads, admin pages.
- Where user data is stored and which keys can read it.

Step 2. Check, with evidence:
1. Authentication: every protected route and server action verifies the session on the server. No auth decisions made only in the frontend.
2. Authorization / IDOR: every read/update/delete by ID checks the record belongs to the current user (or their org). Roles and prices are never taken from the client.
3. Database exposure: Supabase RLS enabled with sensible policies on every table / Firebase rules not open; service_role or admin SDK never reachable from the client.
4. Secrets: none hardcoded, none in public env prefixes, none in client bundles, none in logs.
5. Paid / expensive endpoints (LLM calls, email, SMS, file processing): auth required, rate limits, per-user caps.
6. Auth endpoints: rate limiting on login, signup, reset, OTP; secure password reset flow; session expiry.
7. Webhooks: signature verified on raw body, idempotent handling.
8. Injection: SQL built from strings, shell commands with user input, XSS sinks (dangerouslySetInnerHTML, v-html, innerHTML), path traversal in file access.
9. SSRF: any feature that fetches a user-supplied URL.
10. File uploads: type/size validation, storage permissions, public URLs.
11. CORS, cookies (HttpOnly, Secure, SameSite), CSRF protection for cookie-based auth, security headers.
12. Error handling and logging: stack traces or internals returned to users; secrets or personal data in logs.
13. Leftovers: debug routes, seed endpoints, test accounts, admin pages without role checks, verbose source maps.
14. LLM features: user content or fetched pages reaching a model that can call tools or see secrets (prompt injection).
15. Dependencies: run the package manager's audit and flag packages that look unmaintained or suspicious.

Step 3. Output:
- A table sorted by severity (Critical / High / Medium / Low): title, where (file:line), how an attacker would use it in one sentence, fix in one sentence, effort (S/M/L).
- "Fix first" list: the top 5 by risk ÷ effort.
- Anything you could not check and why.

Then stop and wait for me to pick what to fix.
```

**After it reports:** fix in small batches: *"Fix findings 1 to 3 only. For each, show the diff, add a test that would have caught it, and do not weaken any existing test."*
