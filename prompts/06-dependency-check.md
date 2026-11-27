# 06 · Dependency check

LLMs sometimes suggest packages that don't exist, or a lookalike name. Attackers register those names and wait ("slopsquatting"). Others are just abandoned and vulnerable.

```text
Check this project's dependencies. Report only.

1. Run the audit for this ecosystem (npm audit / pnpm audit / yarn npm audit / pip-audit / cargo audit / bundle audit) and summarize: package, severity, is it reachable from our code, fix version.
2. For every DIRECT dependency, check on the registry: does it exist under exactly this name, weekly downloads, last publish date, linked source repo, number of maintainers. Flag: names that look like typos of popular packages, packages under ~1k weekly downloads that we depend on for something important, packages not updated in 2+ years, packages whose repo link is missing or doesn't match.
3. Flag install scripts (postinstall, preinstall) in direct dependencies.
4. Check the lockfile is committed and matches package.json.
5. List packages we import but don't use, and ones we use but didn't declare.

Output: "remove", "update", "replace with", "ok" per flagged package with one-line reasons. Wait before changing anything.
```

**Habit:** when an agent says *"install `some-package`"*, ask it first: *"Show me the registry page, weekly downloads and GitHub repo for that package before installing."*
