-- rollback gs_create_log_tables() to the 93_042 body
-- gs_create_log_tables() exists only in databases where the log_fdw extension is installed.
DO $do$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
               WHERE n.nspname = 'pg_catalog' AND p.proname = 'gs_create_log_tables' AND p.pronargs = 0) THEN
        EXECUTE $ddl$
create or replace function pg_catalog.gs_create_log_tables()
RETURNS void
AS $body$
declare
  sql_text varchar;
  log_line_prefix varchar;
  cols_def varchar;
begin
	CREATE FOREIGN TABLE IF NOT EXISTS public.gs_profile_log_ft(
	  dirname  text,
	  filename text,
	  hostname text,
	  logtime  timestamp with time zone,
	  nodename text,
	  thread bigint,
	  xid bigint,
	  qid bigint,
	  reqsrc text,
	  reqtype text,
	  reqok int,
	  reqcount bigint,
	  reqsize  bigint,
	  requsec  bigint
	) server log_srv OPTIONS( logtype 'gs_profile', master_only 'true', latest_files '2') DISTRIBUTE BY ROUNDROBIN;

	CREATE FOREIGN TABLE IF NOT EXISTS public.gs_pg_log_ft(
	  dirname  text,
	  filename text,
	  hostname text,
	  match    bool,
	  logtime  timestamp with time zone,
	  nodename text,
	  app text,
	  -- be from %s
	  session_start timestamp with time zone,
	  -- be from %c
	  session_id text,
	  db text,
	  remote text,
	  cmdtag text,
	  username text,
	  -- be from %v
	  vxid text,
	  pid bigint,
	  lineno bigint,
	  xid bigint,
	  qid bigint,
	  ecode text,
	  mod text,
	  level text,
	  msg text
	) server log_srv OPTIONS( logtype 'pg_log', master_only 'true', latest_files '2')  DISTRIBUTE BY ROUNDROBIN;

	CREATE VIEW public.gs_pg_log_v AS 
            SELECT * FROM public.gs_pg_log_ft order by hostname, dirname, filename, logtime;
	CREATE VIEW public.gs_profile_log_v AS 
            SELECT * FROM public.gs_profile_log_ft order by hostname, dirname, filename, logtime;
end;
$body$ language plpgsql NOT FENCED
$ddl$;
    END IF;
END
$do$;
