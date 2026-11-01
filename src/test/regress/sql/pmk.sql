----test pv_os_run_info view
select count(*)>=0 from gs_os_run_info; 

----test pv_session_memory_detail view
select count(*)>=0 from gs_session_memory_detail;

----test pg_shared_memory_detail view
select count(*)>=0 from gs_shared_memory_detail;

----test pv_session_time view
select SCHEMANAME,VIEWNAME, DEFINITION from pg_views where viewname ='pv_session_time';

select * from gs_session_time where 1=2;

select count(*) from (select * from gs_session_time limit 1);

----test pv_file_stat view
select SCHEMANAME,VIEWNAME, DEFINITION from pg_views where viewname ='pv_file_stat';

select count(*)>=0 from gs_file_stat; 

----test pv_redo_stat view
select SCHEMANAME,VIEWNAME, DEFINITION from pg_views where viewname ='pv_redo_stat';

----test pv_session_stat view
select SCHEMANAME,VIEWNAME, DEFINITION from pg_views where viewname ='pv_session_stat';

select * from gs_session_stat where 1=2;

select * from gs_session_stat where statid = -1;

select * from gs_session_memory where 1=2;

select count(*)>=0 from gs_session_memory;

select * from gs_total_memory_detail where 1=2;

select count(*) from (select * from gs_total_memory_detail limit 1);

----test total_cpu function
select total_cpu()>0;

----test get_hostname function
select get_hostname()>'0';

----test total_memory function
select total_memory()>0;

----test sessionid2pid function
select sessionid2pid('123.321');

----test pv_session_memctx_detail
select pv_session_memctx_detail(0, '');
select pv_session_memctx_detail(1, '');
create table qazxsw(pid bigint);
insert into qazxsw select pg_backend_pid();
select pv_session_memctx_detail(pid, 'TopMemoryContext') from qazxsw;

----test _ShowOption must not leak show_hook buffers allocated in session-level memory context
----(uncontrolled_memory_context's show hook allocates 1kB in CBBTopMemoryContext on every pg_settings scan)
create or replace function pmk_showopt_cbb_used() returns bigint as $$
    select coalesce(sum(usedsize), 0)::bigint from pg_catalog.pv_session_memory_detail()
     where contextname = 'CBBTopMemoryContext'
       and split_part(sessid, '.', 2) = pg_catalog.pg_current_sessid()::text;
$$ language sql volatile;
create or replace function pmk_showopt_leak_check(loops int) returns boolean as $$
declare
    before_used bigint;
    after_used bigint;
    dummy bigint;
begin
    before_used := pmk_showopt_cbb_used();
    for i in 1..loops loop
        select count(*) into dummy from pg_settings where name = 'uncontrolled_memory_context';
    end loop;
    after_used := pmk_showopt_cbb_used();
    return (after_used - before_used) < 102400;
end;
$$ language plpgsql;
select pmk_showopt_leak_check(1000);
drop function pmk_showopt_leak_check(int);
drop function pmk_showopt_cbb_used();
