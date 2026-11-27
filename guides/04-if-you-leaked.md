# Layer 4: a key leaked. Now what

Order matters. Rotate first, clean up second. Deleting the commit, the message or the screenshot does **not** un-leak a key: bots scan public GitHub within minutes, chats and logs keep copies.

## In the first 15 minutes

1. **Rotate the key.** Create a new one in the provider dashboard, update it where the app runs (hosting env vars / secret manager), then **revoke the old one**. Revoke, not just "stop using".
2. **Check usage.** Provider dashboards show recent calls / charges. Look for spikes, unknown IPs, new resources (cloud VMs, new Stripe payouts, new users).
3. **Set or lower spend limits** while you investigate.

## Where to rotate (common ones)

| Key | Where |
|---|---|
| OpenAI / Anthropic / LLM APIs | Provider console → API keys → revoke + create |
| Stripe | Dashboard → Developers → API keys → roll key |
| Supabase | Project settings → API keys → rotate (JWT secret rotation logs everyone out) |
| Firebase | Service accounts → delete key, create new |
| AWS | IAM → user → security credentials → deactivate + delete access key. Check CloudTrail |
| GitHub token | Settings → Developer settings → tokens → delete |
| Database password | Change the user's password, update connection strings |
| SSH key | Remove the public key from servers / GitHub, generate a new pair |

## Then clean up

- **Git history:** if it was committed, removing it in a new commit isn't enough. Use `git filter-repo` (or BFG) to rewrite history, force-push, and ask collaborators to re-clone. You still must rotate, history may already be cloned.
- **GitHub:** if the repo was public, assume the key was scraped.
- **AI chats:** delete the conversation, but assume it was seen. The rotation is what protects you.
- **Logs / error trackers:** purge the events containing the key, fix the code that logged it.

## Then make it not happen again

- Add the agent blocks: [claude-code/](../claude-code/), [codex/](../codex/), [cursor/](../cursor/)
- Move secrets out of the folder: [02-keep-secrets-out.md](02-keep-secrets-out.md)
- Add the pre-commit scanner and GitHub push protection
- Run [prompts/01-secrets-sweep.md](../prompts/01-secrets-sweep.md) on every project you touched recently

## If users' data may be exposed

If personal data (emails, addresses, payments) may have been accessed, you may have legal duties to notify users or regulators depending on where you and they are (for example GDPR in the EU). Get proper advice, quickly.
