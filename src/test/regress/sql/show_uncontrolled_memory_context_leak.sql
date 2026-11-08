--
-- Regression test for the show_uncontrolled_memory_context() memory leak.
--
-- Background: show_uncontrolled_memory_context() used to allocate a 1KB buffer
-- from the session-level CBBTopMemoryContext on every call and never free it.
-- _ShowOption() pstrdup()s the returned pointer into the statement context, so
-- the hook buffer itself is never retained by the caller. As a result every
-- scan of pg_settings leaked ~1KB into the long-lived session CBBTopMemoryContext
-- until the connection exhausted its memory and dropped.
--
-- The fix makes the hook return a thread-local fixed buffer (like its sibling
-- hooks show_memory_detail_tracking() and show_enable_memory_limit()), so that
-- repeated scans no longer grow the session CBBTopMemoryContext.
--
-- This test scans pg_settings 2000 times in one session and checks that the
-- current session's CBBTopMemoryContext usedsize does not grow by anything close
-- to what the leak would have produced (2000 * 1KB ~= 2MB). A generous 512KB
-- slack covers unrelated per-session bookkeeping; exceeding it means the per-call
-- leak is still present.
--
\c postgres

create or replace function public.show_uncontrolled_leak_check() returns text as $$
declare
    before_bytes bigint;
    after_bytes  bigint;
    dummy        bigint;
begin
    -- warm up so one-off allocations are not counted as growth
    perform count(*) from pg_settings;

    select coalesce(sum(usedsize), 0)::bigint into before_bytes
      from gs_session_memory_context
      where sessid = pg_catalog.pg_current_sessionid()
        and contextname = 'CBBTopMemoryContext';

    for i in 1..2000 loop
        select count(*) into dummy from pg_settings;
    end loop;

    select coalesce(sum(usedsize), 0)::bigint into after_bytes
      from gs_session_memory_context
      where sessid = pg_catalog.pg_current_sessionid()
        and contextname = 'CBBTopMemoryContext';

    if (after_bytes - before_bytes) > 512 * 1024 then
        return 'fail';
    else
        return 'pass';
    end if;
end;
$$ language plpgsql;

select public.show_uncontrolled_leak_check() as result;

drop function public.show_uncontrolled_leak_check();
