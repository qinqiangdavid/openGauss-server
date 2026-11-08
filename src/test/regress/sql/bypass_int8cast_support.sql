--
-- SQL-bypass (opfusion) support for narrowing int8 casts in prepared INSERT.
--
-- When a prepared INSERT binds a bigint (int8) parameter into a narrower int4 /
-- int2 column, the planner wraps the Param in an int8->int4 (int84, oid 480) or
-- int8->int2 (int82, oid 714) cast FuncExpr in the target list. checkExpr() in
-- opfusion_util.cpp consults the bypass function_id whitelist for every
-- FuncExpr; those two cast oids were missing from the whitelist, so such
-- INSERTs silently lost the SQL-bypass fast path and fell back to the slow
-- executor. The whitelist already contained the int2<->int4 casts (313/314),
-- so only the int8 narrowing casts were affected.
--
-- After adding 480 and 714 to the whitelist, EXPLAIN must show the "[Bypass]"
-- marker for these prepared INSERTs. "explain (costs off)" keeps the plan text
-- deterministic.
--
set enable_opfusion = on;
set enable_bitmapscan = off;
set enable_seqscan = off;

drop table if exists t_i8cast;
create table t_i8cast(c2 int2, c4 int4);
create index i_t_i8cast on t_i8cast(c4);

-- bigint parameter into an int4 column -> int84 (oid 480) cast; must bypass
prepare ins4(bigint) as insert into t_i8cast(c4) values($1);
explain (costs off) execute ins4(1);
execute ins4(1);

-- bigint parameter into an int2 column -> int82 (oid 714) cast; must bypass
prepare ins2(bigint) as insert into t_i8cast(c2) values($1);
explain (costs off) execute ins2(1);
execute ins2(1);

select count(*) = 2 as inserted_ok from t_i8cast;

deallocate ins4;
deallocate ins2;
drop table t_i8cast;
reset enable_opfusion;
reset enable_bitmapscan;
reset enable_seqscan;
