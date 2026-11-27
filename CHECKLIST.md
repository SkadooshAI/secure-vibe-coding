# Secure Vibe Coding checklist

Copy into your project as `SECURITY-CHECKLIST.md` and tick it off.

## Agent (once per machine)
- [ ] Claude Code: `.env` / keys denied in `~/.claude/settings.json` ([how](claude-code/README.md))
- [ ] Claude Code: `block-secrets.sh` hook installed and tested
- [ ] Codex: `workspace-write`, network off, `shell_environment_policy` set ([how](codex/README.md))
- [ ] Cursor: `.cursorignore`, terminal auto-run off ([how](cursor/README.md))
- [ ] Security rules pasted into `~/.claude/CLAUDE.md` / `AGENTS.md` / Cursor rules
- [ ] No "accept all" / skip-permissions on a machine with production credentials
- [ ] Only trusted MCP servers, smallest-scope tokens, unused ones removed

## Secrets (once per project)
- [ ] Local keys are test / dev keys with low limits
- [ ] Production secrets only in hosting env settings or a secret manager
- [ ] `.env*` in `.gitignore` and `.dockerignore`, `.env.example` has names only
- [ ] No secrets behind `NEXT_PUBLIC_` / `VITE_` / `EXPO_PUBLIC_` / `REACT_APP_`
- [ ] Client build grepped for key patterns: clean
- [ ] gitleaks pre-commit hook installed, full history scanned once
- [ ] GitHub secret scanning + push protection on
- [ ] Spend limits set on every paid API

## App (before launch, then monthly)
- [ ] RLS / security rules on every table, tested with two accounts ([prompt](prompts/03-database-rules.md))
- [ ] Every API route: server-side auth + ownership check ([prompt](prompts/04-api-route-review.md))
- [ ] Rate limits on auth, LLM, email/SMS and payment endpoints
- [ ] Webhook signatures verified on raw body
- [ ] No SQL/shell built from strings, no raw HTML from users
- [ ] Uploads validated, stored privately
- [ ] No debug / seed / admin routes open
- [ ] Errors don't leak internals, logs don't hold secrets
- [ ] Dependencies audited, no invented packages ([prompt](prompts/06-dependency-check.md))
- [ ] LLM features can't do more than the logged-in user ([prompt](prompts/07-prompt-injection.md))
- [ ] Full audit run and top 5 fixed ([prompt](prompts/02-full-security-audit.md))

## Every deploy
- [ ] [Pre-deploy check](prompts/05-pre-deploy-check.md): GO

## If something leaks
- [ ] Rotate → revoke old → check usage → then clean up ([playbook](guides/04-if-you-leaked.md))
