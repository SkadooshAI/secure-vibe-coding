# Layer 3: secure the app your agent built

AI writes code that works. "Works" and "safe" are different tests. These are the holes that show up again and again in vibe-coded apps, roughly in order of how often they hurt people.

Each section has a **quick check** you can run or ask about, and the matching prompt in [../prompts/](../prompts/).

---

## 1. The database is open to anyone (Supabase / Firebase)

**What happens:** The frontend talks to the database directly with a public key. If Row Level Security (Supabase) or Security Rules (Firebase) aren't set, anyone with that public key can read or change **every row**: other users' emails, orders, messages.

**Quick check (Supabase):** Dashboard → Table Editor. Every table should show RLS enabled, and have policies. In SQL:
```sql
select schemaname, tablename, rowsecurity
from pg_tables where schemaname = 'public';
-- rowsecurity must be true for every table
```

**Quick check (Firebase):** Firestore → Rules. If you see `allow read, write: if true;` or a test-mode date rule, your data is public.

**Also:** `service_role` / secret keys bypass RLS completely. Server only, never in the frontend, never in a mobile app.

Prompt: [03-database-rules.md](../prompts/03-database-rules.md)

---

## 2. Logged in ≠ allowed (broken access control / IDOR)

**What happens:** `/api/orders/123` checks the user is logged in, but not that order 123 is **theirs**. Change the number, see someone else's order. This is the #1 web risk in OWASP's list and AI-written CRUD code does it constantly.

**Quick check:** Log in as user A, copy a URL or API call with an ID, log in as user B in another browser, paste it. If B sees A's data, you have it.

**Fix pattern:** every query filters by the authenticated user (`where user_id = session.user.id`), or RLS does it for you. Never trust a `userId`, `role`, `isAdmin` or `price` sent from the client.

Prompt: [04-api-route-review.md](../prompts/04-api-route-review.md)

---

## 3. Paid APIs anyone can call

**What happens:** `/api/chat` forwards to OpenAI with your key, no auth, no limit. Someone finds it and runs their whole product on your bill.

**Fix:** require auth, add per-user rate limits and a daily cap, set a hard spend limit in the provider dashboard, log usage per user.

---

## 4. No rate limiting on auth

Login, signup, password reset, OTP and magic-link endpoints without limits = credential stuffing, SMS/email bombing on your bill, brute-forced codes. Use your auth provider's built-in limits or add a limiter (per IP and per account).

---

## 5. Webhooks that trust anyone

**What happens:** `/api/stripe-webhook` marks an order as paid when it receives `{"type":"checkout.session.completed"}`. Anyone can send that.

**Fix:** verify the signature on the **raw** request body with the provider SDK before doing anything (Stripe: `stripe.webhooks.constructEvent(rawBody, sigHeader, endpointSecret)`). Same for GitHub, Shopify, Clerk, etc. Make handlers idempotent so replays don't double-credit.

---

## 6. Injection

- **SQL:** string-built queries (`"... where email = '" + email + "'"`). Use the ORM or parameterized queries.
- **Shell:** `exec("convert " + filename)`. Never pass user input to a shell. Use argument arrays.
- **XSS:** `dangerouslySetInnerHTML`, `v-html`, `innerHTML` with user content. Sanitize (DOMPurify) or don't.
- **Prompt injection:** user text or fetched web pages go into an LLM that can call tools. See [07-prompt-injection.md](../prompts/07-prompt-injection.md).

---

## 7. File uploads

Check type by content, not extension. Limit size. Store outside the web root or in object storage with private ACLs and signed URLs. Never serve uploaded HTML/SVG from your main domain. Strip EXIF from photos if privacy matters.

---

## 8. SSRF: "fetch this URL for me"

Features like link previews, "import from URL" or webhooks-to-anywhere let attackers make **your server** call internal addresses (`169.254.169.254` cloud metadata, `localhost` admin panels). Allowlist schemes and hosts, block private IP ranges after DNS resolution.

---

## 9. Leaky errors and logs

Production errors show stack traces, SQL or env values. Logs store passwords, tokens or full request bodies. Return generic errors to users, log details server-side, scrub secrets from logs and error trackers.

---

## 10. Admin and debug leftovers

`/admin` with no role check, `/api/debug`, `/api/seed`, test users with `password123`, `DEBUG=true`, open Swagger/GraphQL playgrounds, source maps with comments in production. Search for them before every launch.

---

## 11. CORS and cookies

`Access-Control-Allow-Origin: *` together with credentials, or reflecting any origin. Session cookies without `HttpOnly`, `Secure`, `SameSite`. Ask the agent to list your CORS config and cookie flags, it takes one prompt.

---

## 12. Dependencies the agent invented

LLMs sometimes suggest packages that don't exist, and attackers register those names ("slopsquatting"). Before installing anything new: check it exists, has real downloads, a real repo and recent maintenance. Run `npm audit` / `pip-audit` regularly.

Prompt: [06-dependency-check.md](../prompts/06-dependency-check.md)

---

## Before launch, minimum

- [ ] RLS / security rules on every table, tested with two accounts
- [ ] Every API route: auth + ownership check
- [ ] No secrets in the frontend bundle (grep from [layer 2](02-keep-secrets-out.md))
- [ ] Rate limits on auth and paid endpoints, spend caps set at providers
- [ ] Webhook signatures verified
- [ ] Debug/admin/seed routes removed or protected
- [ ] `npm audit` / `pip-audit` clean or understood
- [ ] [05-pre-deploy-check.md](../prompts/05-pre-deploy-check.md) run and fixed
