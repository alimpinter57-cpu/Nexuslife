-- NexusLife read-only security audit for Supabase.
-- Safe to run in SQL Editor: these queries do not change database state.

-- 1) Application tables and whether RLS is enabled.
SELECT
  schemaname,
  tablename,
  rowsecurity AS rls_enabled
FROM pg_catalog.pg_tables
WHERE schemaname = 'public'
  AND tablename NOT LIKE 'pg_%'
ORDER BY tablename;

-- 2) Existing RLS policies. Empty result means no policies are defined.
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_catalog.pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 3) Table-level grants for browser-facing roles.
-- Review grants for anon/authenticated before exposing tables through Data API.
SELECT
  table_schema,
  table_name,
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND grantee IN ('anon', 'authenticated', 'PUBLIC')
ORDER BY table_name, grantee, privilege_type;

-- Note: this audit is diagnostic only. It does not prove app-level authorization,
-- and it intentionally does not enable RLS or modify grants/policies.
