--
-- gs_create_log_tables() must work on a single-node (centralized) instance:
-- it creates gs_profile_log_ft/gs_pg_log_ft and their views over log_srv.
--
SELECT count(*) AS log_srv FROM pg_catalog.pg_foreign_server WHERE srvname = 'log_srv';
DO $$ BEGIN PERFORM pg_catalog.gs_create_log_tables(); END $$;
SELECT c.relname, c.relkind FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
 WHERE n.nspname = 'public' AND c.relname IN ('gs_profile_log_ft', 'gs_pg_log_ft', 'gs_profile_log_v', 'gs_pg_log_v')
 ORDER BY c.relname;
DROP VIEW public.gs_pg_log_v;
DROP VIEW public.gs_profile_log_v;
DROP FOREIGN TABLE public.gs_pg_log_ft;
DROP FOREIGN TABLE public.gs_profile_log_ft;
