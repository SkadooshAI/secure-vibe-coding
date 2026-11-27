# Layer 1: lock the agent

Pick your tool:

- **Claude Code** → [claude-code/README.md](../claude-code/README.md): deny rules, the `block-secrets.sh` hook, sandbox
- **Codex CLI** → [codex/README.md](../codex/README.md): sandbox, network off, env var filtering
- **Cursor** → [cursor/README.md](../cursor/README.md): `.cursorignore`, no auto-run, rules

Whatever the tool, the same three ideas:

1. **Deny, don't ask nicely.** A settings rule is enforced. "Please don't read .env" in a prompt is a suggestion.
2. **Cut the way out.** An agent that read a secret but can't reach the network can't send it anywhere.
3. **Give it less to find.** The fewer real secrets on the machine, the less any rule has to hold. That's [layer 2](02-keep-secrets-out.md).
