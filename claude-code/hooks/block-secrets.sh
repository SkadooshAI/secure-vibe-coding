#!/bin/sh
# block-secrets.sh: a Claude Code PreToolUse hook.
# Stops the agent from reading secret files or dumping your environment,
# including through Bash (cat, grep, python -c ...), not only the Read tool.
#
# Claude Code sends the tool call as JSON on stdin. Exit code 2 blocks the call
# and the text on stderr goes back to Claude so it can pick a safer way.
# Plain POSIX sh + grep + sed: works on macOS and Linux with nothing to install.
#
# Install: see claude-code/README.md

input=$(cat)

# Only look at the parts of the call that point at files or run commands.
# (Never at the code being written, so writing `dotenv.config()` stays allowed.)
fields=$(printf '%s' "$input" | grep -Eo '"(file_path|path|pattern|glob|command|notebook_path)" *: *"([^"\\]|\\.)*"')

[ -z "$fields" ] && exit 0

# Example / template files are fine to read: drop them before checking.
fields=$(printf '%s' "$fields" | sed -E 's/\.env\.(example|sample|template|dist|defaults)//g')

secret_files='(^|[^A-Za-z0-9_])\.env([^A-Za-z0-9_]|$)|\.env\.[A-Za-z0-9_]+|id_rsa|id_ed25519|id_ecdsa|\.pem([^A-Za-z0-9_]|$)|\.p12([^A-Za-z0-9_]|$)|\.pfx([^A-Za-z0-9_]|$)|\.keystore|\.aws/credentials|\.config/gcloud|service[-_]account[A-Za-z0-9_.-]*\.json|credentials\.json|\.npmrc|\.pypirc|\.netrc|\.git-credentials|\.docker/config\.json|\.kube/config|secrets?\.(json|ya?ml|toml)'

if printf '%s' "$fields" | grep -Eq "$secret_files"; then
  echo "Blocked by block-secrets hook: this touches a secret file (.env, private keys or credentials). Do not read, search or print secrets. Read .env.example to learn the variable NAMES, and ask the user if a value needs checking." >&2
  exit 2
fi

# Commands that print every environment variable. One real agent leaked a whole
# shell environment this way when the .env file it wanted was missing.
commands=$(printf '%s' "$fields" | grep -E '^"command"')
env_dump='(: *"|[;&|(`] *)(printenv|env|export -p|declare -x|declare -p|set)( *($|[;&|)`"]))|/proc/[^ ]*/environ|print\(os\.environ\)|console\.log\(process\.env\)|json\.dumps\(dict\(os\.environ'

if [ -n "$commands" ] && printf '%s' "$commands" | grep -Eq "$env_dump"; then
  echo "Blocked by block-secrets hook: this prints environment variables, which hold secrets. Check one NAME exists instead, for example: [ -n \"\$STRIPE_SECRET_KEY\" ] && echo set" >&2
  exit 2
fi

exit 0
