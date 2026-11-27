# 03 · Database rules (Supabase / Firebase)

The most common way vibe-coded apps leak every user's data. Do this one first if you use Supabase or Firebase.

## Supabase

```text
Audit Row Level Security for this Supabase project. Do not change anything yet.

1. List every table in the public schema (and any other exposed schema). For each: is RLS enabled, which policies exist (command, role, USING and WITH CHECK expressions).
   Read this from migrations / schema files in the repo. If they are missing, give me a SQL query to run in the Supabase SQL editor and wait for me to paste the result.
2. Flag as CRITICAL: any table with RLS disabled; any policy with USING (true) or WITH CHECK (true) for anon or authenticated on tables holding user data; UPDATE policies without WITH CHECK (users could change user_id to someone else's).
3. Flag storage buckets that are public but hold private files, and storage policies that don't check ownership.
4. Find every place the service_role / secret key is used. Confirm each is server-only code. Any use reachable from the browser or a mobile app is CRITICAL.
5. Find RPC / database functions declared SECURITY DEFINER and check they validate auth.uid() themselves.
6. For each table, propose the minimal correct policies (select/insert/update/delete) based on how the app actually uses it, typically `auth.uid() = user_id`, or org membership via a join.

Output: table-by-table findings, then a single SQL migration with the proposed policies, then a manual test plan: two test users, what each should and should NOT be able to see. Wait for my approval before applying.
```

Test it yourself after: log in as user A, create data; log in as user B; try to read/update A's rows through the app **and** directly with the anon key (e.g. from the browser console with the Supabase client). Both must fail.

## Firebase (Firestore / Storage)

```text
Audit Firebase Security Rules in this project (firestore.rules, storage.rules, database.rules.json). Do not change anything yet.

1. Show each match path and its allow rules.
2. Flag as CRITICAL: allow read, write: if true; rules that only check request.auth != null for collections holding other users' data; test-mode date rules; wildcard matches that open subcollections.
3. Check every collection the app writes: can a user write fields they shouldn't (role, isAdmin, balance, ownerId)? Rules should validate request.resource.data.
4. Find any Admin SDK / service account usage and confirm it is server-only.
5. Propose corrected rules with ownership checks (request.auth.uid == resource.data.ownerId) and field validation, plus emulator tests for allowed and denied cases.

Wait for my approval before changing rules.
```
