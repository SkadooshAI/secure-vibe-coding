# Codex CLI: lock the agent

Codex runs commands inside a sandbox. The defaults are decent, the trick is not undoing them.

## 1. Keep the sandbox on, network off

`~/.codex/config.toml`

```toml
# the agent can write inside the project, nowhere else
sandbox_mode = "workspace-write"

# ask before doing anything outside the sandbox
approval_policy = "on-request"

[sandbox_workspace_write]
# default is already false: the agent's commands can't send data anywhere
network_access = false

[shell_environment_policy]
# commands the agent runs only see these env vars, not your API keys
include_only = ["PATH", "HOME", "LANG", "TERM"]
```

- `network_access = false` is the big one. Even if the agent reads a secret, the command it runs can't `curl` it out. Turn it on for a single run when you need it: `codex --config sandbox_workspace_write.network_access=true`
- `shell_environment_policy` decides which environment variables reach the commands Codex launches. Your shell may hold `OPENAI_API_KEY`, `AWS_SECRET_ACCESS_KEY`, `GITHUB_TOKEN`… the agent's `npm test` doesn't need any of them. Add only what your build really needs.
- Newer Codex versions also have permission profiles (beta). If you use them, follow the official page instead of mixing both styles: <https://developers.openai.com/codex/permissions>

Official reference: <https://developers.openai.com/codex/config-reference> · security: <https://developers.openai.com/codex/agent-approvals-security>

## 2. The sandbox doesn't hide files inside your project

`workspace-write` limits **writing** and **network**. Files inside the project folder, `.env` included, are still readable. So for Codex, [layer 2](../guides/02-keep-secrets-out.md) is not optional:

- No real `.env` in the project folder. Inject secrets at run time with a secret manager (`op run`, `doppler run`, `infisical run`, `dotenvx`).
- Or keep a `.env` with **test keys only** (tiny limits, test mode), so a leak costs nothing.

## 3. Put the rules where Codex reads them

Paste [../claude-code/CLAUDE.md](../claude-code/CLAUDE.md) into your project's `AGENTS.md` (or `~/.codex/AGENTS.md` for every project). Codex reads `AGENTS.md` before it starts.

## 4. Don'ts

- Don't use `--dangerously-bypass-approvals-and-sandbox` / "full access" on a machine with production credentials. If you need it, use a throwaway container.
- Don't turn network on permanently "because installs failed". Turn it on for that one run.
