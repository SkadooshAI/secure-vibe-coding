# 04 · API route review

Use after the agent adds or changes endpoints. Short and focused, so run it often.

```text
Review the API routes / server actions changed in this branch (use git diff main...HEAD; if there is no branch, review all routes). Report only, no edits.

For each route give one row:
- method + path (or action name)
- who should be allowed to call it
- does it verify the session on the server? (file:line)
- does it check the current user owns / may access the specific record? (file:line) - IDOR check
- does it trust any client-sent field it shouldn't (userId, role, price, amount, isAdmin, ownerId)?
- input validation present? (schema / zod / pydantic, or none)
- rate limit present? needed? (yes if it sends email/SMS, calls an LLM, charges money, or is auth-related)
- what it returns on error (any stack traces, SQL, internals?)

Then list concrete exploits in one sentence each, e.g. "User B can GET /api/invoices/123 and read user A's invoice because the query doesn't filter by user_id".

Finally propose fixes as a minimal diff per route plus one test per exploit that fails before the fix and passes after. Wait for approval.
```
