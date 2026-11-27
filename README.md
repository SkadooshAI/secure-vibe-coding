<div align="center">

<img src="https://skadoosh.fluentagent.io/assets/banner.jpg" alt="Skadoosh" width="100%">

# Secure Vibe Coding

**Your AI agent can read every key in your project. This repo makes sure it doesn't, and checks the app it built for you.**

Settings, a hook, copy-paste prompts and checklists for Claude Code, Codex and Cursor.
Made for people who ship with AI and don't have a security team.

[![X](https://img.shields.io/badge/X-@SkadooshGG-111?logo=x)](https://x.com/SkadooshGG)
[![Prompts](https://img.shields.io/badge/more%20prompts-free-7A8F4E)](https://github.com/SkadooshAI/prompts)
![License](https://img.shields.io/badge/license-MIT-9AD0FA)

</div>

---

## Why this exists

A QA engineer asked an AI coding agent to review merge requests. The project notes mentioned one GitLab token stored in `.env`.

So the agent read the **whole** `.env` file. Every session. **10 sessions over 3 weeks.** Production passwords for an internal admin tool, an HR API token, a BI client secret, all of it went into the agent's context. In one session the `.env` was missing, so the command printed the entire shell environment instead.

Nobody noticed. The agent flagged it itself:

> "I leaked secrets into this session's tool output… I'd rotate them."

([NordLayer, AI agent investigations, Nov 2026](https://nordlayer.com/blog/ai-agent-investigations/))

The agent wasn't hacked and wasn't evil. It did exactly what it was asked, with access nobody limited. That's the normal setup for most of us.

---

## The 2 minute fix (Claude Code)

Add this to `~/.claude/settings.json` (applies to every project):

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  }
}
```

Deny rules win over everything else. Claude's file tools can no longer open `.env`, and Bash commands that name the file (`cat .env`, `head .env`) are blocked too.

That covers the obvious path. It does **not** cover `grep -r` across the folder, a Python script that opens the file itself, or `printenv`. For that, add the hook below. 👇

---

## The full setup in 4 layers

| Layer | What it stops | Time | Where |
|---|---|---|---|
| **1. Lock the agent** | Agent reading `.env`, keys, `~/.ssh`, dumping env vars | 5 min | [claude-code/](claude-code/) · [codex/](codex/) · [cursor/](cursor/) |
| **2. Keep secrets out of the folder** | Keys sitting in plain text where any tool can read them | 15 min | [guides/02-keep-secrets-out.md](guides/02-keep-secrets-out.md) |
| **3. Secure the app it built** | Open databases, missing auth, keys in the frontend bundle | 30 min | [guides/03-secure-the-app.md](guides/03-secure-the-app.md) + [prompts/](prompts/) |
| **4. Plan for the leak** | Panic when a key does get out | read once | [guides/04-if-you-leaked.md](guides/04-if-you-leaked.md) |

Start with layer 1 today. Do the rest before you put real users or real money behind the app.

---

## Layer 1 in one copy-paste (Claude Code, macOS / Linux)

```bash
# 1. the hook that blocks secret files and env dumps (also through Bash)
mkdir -p ~/.claude/hooks
curl -fsSL https://raw.githubusercontent.com/SkadooshAI/secure-vibe-coding/main/claude-code/hooks/block-secrets.sh \
  -o ~/.claude/hooks/block-secrets.sh
chmod +x ~/.claude/hooks/block-secrets.sh
less ~/.claude/hooks/block-secrets.sh   # read it before you trust it, always
```

Then merge [claude-code/settings.json](claude-code/settings.json) into your `~/.claude/settings.json` and restart Claude Code. Details, testing and the "why" for every line: [claude-code/README.md](claude-code/README.md).

Also paste [claude-code/CLAUDE.md](claude-code/CLAUDE.md) into your global `~/.claude/CLAUDE.md` so the agent knows the rules before it hits the wall.

---

## Prompts that audit your vibe-coded app

Copy, paste into Claude Code / Codex / Cursor inside your project. Each one tells the agent to **report first and fix only after you approve**, and to never print secret values.

| Prompt | Use it when |
|---|---|
| [01 · Secrets sweep](prompts/01-secrets-sweep.md) | Before your first commit, and after any AI session that touched config |
| [02 · Full security audit](prompts/02-full-security-audit.md) | Before launch, then monthly |
| [03 · Database rules (Supabase / Firebase)](prompts/03-database-rules.md) | You use Supabase or Firebase. Do this one first |
| [04 · API route review](prompts/04-api-route-review.md) | After the agent adds or changes endpoints |
| [05 · Pre-deploy check](prompts/05-pre-deploy-check.md) | Every deploy to production |
| [06 · Dependency check](prompts/06-dependency-check.md) | Weekly, and before adding a package the agent suggested |
| [07 · Prompt-injection check](prompts/07-prompt-injection.md) | Your app sends user content or web pages to an LLM |

---

## The 10 rules (print this)

1. The agent never needs your real production keys to write code. Give it test keys with tiny limits.
2. Block `.env`, `~/.ssh`, `~/.aws` and friends in the agent's settings. Deny rules beat "please don't".
3. Real secrets live in a secret manager or are injected at run time, never in plain text in the project folder.
4. Anything with `NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_` or `REACT_APP_` in front ships to every visitor's browser.
5. Supabase `service_role` / secret keys and Firebase Admin keys only ever run on a server.
6. Every table has Row Level Security on. Every API route checks who is asking **and** whether they own the thing.
7. A secret scanner runs before every commit. GitHub push protection is on.
8. If a key ever touched a chat, a log, a screenshot or a public repo, rotate it. Deleting the message doesn't un-send it.
9. Don't paste untrusted repos, issues or web pages into an agent that has write access and secrets. That's how prompt injection gets in.
10. Read what the agent runs. "Accept all" on a project with production access is how the story above happens.

Full checklist: [CHECKLIST.md](CHECKLIST.md)

---

## FAQ

**Doesn't Claude Code already ask before reading files?**
Reading files inside your project is allowed by default, that's how it understands the code. `.env` sits inside your project. So you have to deny it explicitly.

**Is `.claudeignore` / `.gitignore` enough?**
No. Claude Code's docs say `.claudeignore` has no effect, use `Read` deny rules. `.gitignore` only keeps the file out of git, the agent can still read it.

**Will this break my workflow?**
The agent can still run your app, run tests and read `.env.example` to learn variable names. It just can't see the values. If it truly needs one checked, it asks you.

**Is this a complete security solution?**
No. It removes the most common, most embarrassing leaks. Layered defence (settings + hook + secret manager + scanner + sandbox) is the point. Nothing here replaces a real review before you handle payments or personal data.

---

<div align="center">

Built by [@SkadooshGG](https://x.com/SkadooshGG) · building apps and AI agents every day

⭐ Star it so you find it again the day you need it

</div>
