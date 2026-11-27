# 01 · Secrets sweep

Finds hardcoded keys, tokens and passwords in your code and git history, **without printing them**.

Use: before your first commit, before making a repo public, and after any AI session that touched config.

```text
You are doing a secrets sweep of this repository. Your job is to FIND and REPORT, not to fix yet.

Hard rules:
- Never print, echo, quote or summarize any secret value. When you find one, show only: file path, line number, the kind of secret (e.g. "Stripe live secret key", "Postgres connection string with password"), and the first 4 characters followed by "…".
- Do not open .env, .env.* (except .env.example), private keys or credential files. If a check needs them, tell me and I will check myself.
- Do not run env, printenv or anything that prints environment variables.
- Do not change any file in this step.

Check:
1. Source code, configs, tests, fixtures, scripts, docs, notebooks, CI files, Dockerfiles and docker-compose files for hardcoded keys, tokens, passwords, private keys, connection strings with credentials, JWT secrets and webhook secrets.
2. Known formats: sk-, sk_live_, sk_test_, rk_live_, AKIA, ghp_, github_pat_, xox, AIza, -----BEGIN … PRIVATE KEY-----, postgres://user:pass@, mongodb+srv://user:pass@, Bearer tokens.
3. Env vars with public prefixes (NEXT_PUBLIC_, VITE_, PUBLIC_, EXPO_PUBLIC_, REACT_APP_) that hold anything secret. List every public-prefixed variable name and say whether it is safe to be public.
4. Server-only keys (Supabase service_role/secret key, Stripe secret key, LLM API keys, Firebase Admin) imported anywhere that ends up in client code.
5. Whether .env and similar files are in .gitignore and .dockerignore. Run: git check-ignore -v .env
6. Git history: run `git log -p --all -S "<pattern>"` for the formats above and report commits that added secrets, even if later removed. (If gitleaks is installed, run `gitleaks git -v --redact` instead.)
7. Logging that could print secrets: console.log / print / logger calls with headers, env, config objects or full request bodies.

Output a table: severity (critical/high/medium), file:line or commit, kind of secret, why it matters, recommended fix. Critical = a live production secret that is committed or shipped to the browser.

Then list the keys I should ROTATE (by kind and provider, no values), and stop. Wait for my approval before fixing anything.
```

**After it reports:** rotate the critical ones first ([guides/04-if-you-leaked.md](../guides/04-if-you-leaked.md)), then say *"fix the code issues, move values to env vars, add the names to .env.example, do not touch git history"*.
