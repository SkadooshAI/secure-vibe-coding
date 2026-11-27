# Cursor: lock the agent

## 1. `.cursorignore`

Create `.cursorignore` in the project root (same syntax as `.gitignore`):

```gitignore
# secrets
.env
.env.*
!.env.example
*.pem
*.key
*.p12
secrets/
**/credentials.json
**/service-account*.json
.npmrc
```

Cursor uses it to keep files out of indexing and AI features. Cursor's own docs describe it as **best effort**: the agent's terminal, MCP tools and other paths can still reach files. Treat it as a seatbelt, not a lock.

## 2. Turn off auto-run for terminal commands

In Cursor settings, make agent terminal commands require your approval (or keep an allowlist of safe commands like `npm test`, `npm run lint`). Auto-run is how `cat .env` or `printenv` happens without you seeing it.

Add a denylist if your version supports it: `printenv`, `env`, `cat .env`, `curl`, `scp`.

## 3. Rules

Paste [../claude-code/CLAUDE.md](../claude-code/CLAUDE.md) into `.cursor/rules/security.mdc` (or your User Rules) so the agent knows what not to touch.

## 4. Same as everywhere

- No real production keys in the project folder. See [layer 2](../guides/02-keep-secrets-out.md).
- Only install MCP servers you trust, with the smallest-scope tokens.
- Run the [prompts](../prompts/) before you ship.
