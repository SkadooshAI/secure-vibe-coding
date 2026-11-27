# 05 · Pre-deploy check

Five minutes before every production deploy.

```text
Run a pre-deploy security check on the current state of the repo. Report only. Never print secret values.

1. Secrets: search the diff since the last release tag (or the last 20 commits) for added keys/tokens/passwords or new public-prefixed env vars (NEXT_PUBLIC_, VITE_, PUBLIC_, EXPO_PUBLIC_, REACT_APP_). Build the app and grep the client build output for key patterns (sk-, sk_live_, service_role, AKIA, ghp_, github_pat_, BEGIN PRIVATE KEY).
2. New or changed routes: do they all check auth and ownership?
3. New database tables or columns: RLS / rules updated in the same change?
4. Debug leftovers: console.log of objects with user data or headers, debug/seed/test routes, TODO "remove before prod", DEBUG flags, test credentials.
5. Dependencies: run the audit command for this package manager. Any new package added since last release: does it really exist on the registry, is it widely used, is it the one we meant?
6. Config: production env uses production URLs, CORS isn't "*", cookies are Secure/HttpOnly, source maps not publicly served (or acceptable).
7. Tests: did any test get deleted, skipped, or have its assertions weakened since the last release? List them.

Output a GO / NO-GO with the blocking items first.
```
