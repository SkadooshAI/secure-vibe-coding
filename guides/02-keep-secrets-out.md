# Layer 2: keep real secrets out of the project folder

Blocking the agent is good. Not having anything to leak is better.

The idea: your project folder holds **names** of variables, never production **values**. Values are injected when the app runs, or they are test keys that are worthless if stolen.

---

## Option A: test keys only (easiest, do this at minimum)

Most services give you separate keys for testing. Use those on your laptop, always.

| Service | What to use locally |
|---|---|
| Stripe | `sk_test_…` keys, test mode. Never `sk_live_` on your laptop |
| OpenAI / Anthropic / other LLM APIs | A separate project/workspace key with a low monthly spend limit |
| Supabase / Firebase | A separate dev project, not your production one |
| AWS / GCP | A dev account or a user with only the permissions the app needs |
| GitHub tokens | Fine-grained token, one repo, only the permissions needed, short expiry |

If the agent leaks a test key with a $5 limit, you rotate it and move on. That's the whole point.

---

## Option B: inject secrets at run time

The `.env` file disappears from disk. A CLI fetches values from a vault and passes them to your app process only.

**1Password CLI**
```bash
# .env.tpl  (safe to commit: only references, no values)
STRIPE_SECRET_KEY=op://Dev/Stripe/secret_key
OPENAI_API_KEY=op://Dev/OpenAI/api_key
```
```bash
op run --env-file=.env.tpl -- npm run dev
```

**Doppler**
```bash
doppler setup          # once, pick project + config
doppler run -- npm run dev
```

**Infisical**
```bash
infisical init
infisical run -- npm run dev
```

**dotenvx** (keeps a `.env`, but encrypted)
```bash
dotenvx encrypt         # encrypts values in .env, writes the key to .env.keys
dotenvx run -- npm run dev
```
With dotenvx, `.env.keys` is the new secret: block it in the agent settings and never commit it.

Then tell the agent in `CLAUDE.md` / `AGENTS.md`: *"Run the app with `op run --env-file=.env.tpl -- npm run dev`"*. It can start the app without ever seeing a value.

---

## Option C: if you keep a plain `.env`

- It's in `.gitignore` (check: `git check-ignore .env` prints `.env`).
- It's blocked for the agent ([claude-code/](../claude-code/), [codex/](../codex/), [cursor/](../cursor/)).
- It has only dev/test values.
- You have a `.env.example` with the same names and empty values, so the agent (and teammates) know what exists.

```bash
# .env.example
DATABASE_URL=
STRIPE_SECRET_KEY=
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

---

## The frontend trap (most common vibe-coding leak)

Frameworks copy some env vars **into the JavaScript every visitor downloads**:

| Framework | Public prefix |
|---|---|
| Next.js | `NEXT_PUBLIC_` |
| Vite / SvelteKit / Astro (Vite-based) | `VITE_` / `PUBLIC_` |
| Expo / React Native | `EXPO_PUBLIC_` |
| Create React App | `REACT_APP_` |

If an agent "fixes" an error by renaming `OPENAI_API_KEY` to `NEXT_PUBLIC_OPENAI_API_KEY`, your key is now public. Anyone can open DevTools and use it.

Rule: secrets are only used in server code (API routes, server actions, edge functions, backend). The browser calls **your** server, your server calls the paid API.

Check your built app:
```bash
npm run build
grep -rEo "sk-[A-Za-z0-9_-]{20,}|sk_live_[A-Za-z0-9]{10,}|service_role|AKIA[0-9A-Z]{16}" .next/static dist build 2>/dev/null | head
```
Any hit = a secret in your public bundle.

Note on Supabase: the anon / publishable key **is meant** to be public. It's safe only because Row Level Security protects your tables. See [layer 3](03-secure-the-app.md).

---

## Catch secrets before they reach git

**Pre-commit scan with gitleaks**
```bash
brew install gitleaks        # or download from github.com/gitleaks/gitleaks
pip install pre-commit
```
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2
    hooks:
      - id: gitleaks
```
```bash
pre-commit install
gitleaks git -v                   # scan the whole git history once (older versions: gitleaks detect -v)
```

**GitHub push protection**
Repo → Settings → Code security → enable *Secret scanning* and *Push protection*. GitHub then blocks pushes that contain known key formats. Free for public repos.

**Never use `git commit --no-verify`** to get past the scanner, and tell your agent the same (it's in the [CLAUDE.md rules](../claude-code/CLAUDE.md)).

---

## Other places secrets hide

- Screenshots and screen recordings of your terminal or dashboard (yes, including the ones you post on X)
- Chat messages to an AI ("here's my key, why doesn't it work?")
- Logs: `console.log(req.headers)`, `console.log(process.env)`, error trackers that capture request bodies
- Shell history: `export OPENAI_API_KEY=sk-...` typed directly. Prefer the secret manager
- CI logs that echo variables
- Docker images built with `COPY . .` and a `.env` inside. Add `.env*` to `.dockerignore`
