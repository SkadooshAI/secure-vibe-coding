# Claude Code: lock the agent

Three pieces, each covers a gap the previous one leaves open.

| Piece | Covers | Misses |
|---|---|---|
| `permissions.deny` | Read / Edit tools, and Bash commands that name the file (`cat .env`) | `grep -r`, scripts that open files themselves, `printenv` |
| `block-secrets.sh` hook | Any tool call whose path, pattern or command points at a secret, plus env dumps | Code the agent writes and then runs (a script that reads `.env` inside) |
| Sandbox (`/sandbox`) | OS-level limits on what Bash can read and where it can send data | Tools that run outside it (see below) |

Use all three on anything that touches real users or money.

---

## 1. Deny rules

Put them in `~/.claude/settings.json` (every project) or `.claude/settings.json` (this repo, shared with the team via git). Deny lists from all files are merged, and deny always wins over allow.

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./**/.env)",
      "Read(./**/.env.*)",
      "Read(./secrets/**)",
      "Read(~/.ssh/**)",
      "Read(~/.aws/**)",
      "Read(~/.config/gcloud/**)",
      "Read(~/.kube/**)",
      "Read(~/.docker/config.json)",
      "Read(~/.npmrc)",
      "Read(~/.netrc)",
      "Read(~/.git-credentials)"
    ]
  }
}
```

Notes
- `./` is relative to the project, `~/` to your home folder.
- `Read(./.env.*)` also hides `.env.example`. That's on purpose for the deny rule. The hook below allows `.env.example`, `.env.sample` and `.env.template`, so if you want the agent to read your example file, remove `Read(./.env.*)` and rely on the hook for `.env.local` / `.env.production`.
- Type `/permissions` inside Claude Code to see what's active.

---

## 2. The hook: `block-secrets.sh`

A `PreToolUse` hook runs before every tool call. It gets the call as JSON. If it exits with code `2`, the call is blocked and the message goes back to Claude, which then picks another way.

The hook blocks:
- any path, glob, grep target or command that mentions `.env`, `.env.local`, `.env.production`…, private keys (`id_rsa`, `id_ed25519`, `.pem`, `.p12`), cloud credentials (`~/.aws/credentials`, gcloud, kube, docker), `.npmrc`, `.netrc`, `.git-credentials`, `secrets.json/yaml`, service account JSON
- commands that print the whole environment: `env`, `printenv`, `set`, `export -p`, `declare -x`, `/proc/*/environ`, `print(os.environ)`, `console.log(process.env)`

It allows:
- `.env.example`, `.env.sample`, `.env.template`
- writing code that *uses* env vars (`process.env.KEY`, `dotenv.config()`), it only looks at paths and commands, never file contents
- `env NODE_ENV=test npm test`, `set -e`, `[ -n "$KEY" ] && echo set`

### Install

```bash
mkdir -p ~/.claude/hooks
curl -fsSL https://raw.githubusercontent.com/SkadooshAI/secure-vibe-coding/main/claude-code/hooks/block-secrets.sh \
  -o ~/.claude/hooks/block-secrets.sh
chmod +x ~/.claude/hooks/block-secrets.sh
```

Add to `~/.claude/settings.json` (merge with what you have):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Edit|MultiEdit|Write|Grep|Glob|Bash|NotebookEdit",
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/block-secrets.sh" }
        ]
      }
    ]
  }
}
```

Restart Claude Code, then run `/hooks` to confirm it's loaded.

### Test it (takes 10 seconds)

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"cat .env"}}' | ~/.claude/hooks/block-secrets.sh; echo "exit $?"
# -> Blocked by block-secrets hook ... exit 2

echo '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' | ~/.claude/hooks/block-secrets.sh; echo "exit $?"
# -> exit 0
```

Then in Claude Code ask: *"what's in my .env?"*. It should refuse and offer to read `.env.example` instead.

### Limits, honestly
- It's pattern matching. A determined agent could write a script that reads `.env` and then run it. The hook blocks the obvious paths, the secret manager in [layer 2](../guides/02-keep-secrets-out.md) removes the file entirely, and the sandbox limits what that script could send out.
- If you get a false positive, the message tells Claude what was blocked. Tweak the pattern in the script, it's plain `sh`.

---

## 3. Sandbox

Claude Code can run Bash commands inside an OS-level sandbox that limits filesystem access and network destinations. Turn it on with `/sandbox` and read the official page before relying on it: <https://code.claude.com/docs/en/sandboxing>

What to know (from the docs, Nov 2026):
- Off by default. On Linux / WSL2 it needs `bubblewrap` and `socat`.
- It applies to Bash commands. The Read, WebFetch and WebSearch tools, hooks and MCP servers run outside it, which is why you still want the deny rules and the hook.
- Allowed network domains start empty, you add the ones your project needs.
- For secrets the docs point to `sandbox.filesystem.denyRead`.
- The docs call it risk reduction, not a complete isolation boundary.

---

## 4. Habits that matter more than any setting

- **Don't run with "accept all" / `--dangerously-skip-permissions` on a machine that holds production credentials.** Use it in a throwaway container or VM if you must.
- **Read the command before you approve it.** If it says `cat`, `curl`, `scp` or `printenv`, slow down.
- **Be careful what you feed it.** A random GitHub issue, a scraped web page or a README can contain instructions aimed at your agent. Don't let an agent with secrets and write access read untrusted text unsupervised.
- **MCP servers get real power.** Only install ones you trust, give their tokens the smallest scope, and remove the ones you don't use.
- **Paste [CLAUDE.md](CLAUDE.md) into `~/.claude/CLAUDE.md`.** Rules the agent reads first save you from walls it hits later.
