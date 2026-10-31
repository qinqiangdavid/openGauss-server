create schema alter_ctable_compress;
set search_path='alter_ctable_compress';
create table test1(id int) with (orientation='column', compression=yes);
create table test2(id int) with (orientation='column', compression=no);
alter table test1 set nocompress;
alter table test2 set compress;
insert into test1 select generate_series(1,50000);
insert into test2 select generate_series(1,50000);
select pg_table_size('test1') > pg_table_size('test2') as t;
-- bare COMPRESS / NOCOMPRESS are the same command as SET COMPRESS / SET NOCOMPRESS
alter table test1 compress;
alter table test2 nocompress;
select c.relname, c.reloptions from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'alter_ctable_compress' and c.relname in ('test1', 'test2') order by c.relname;
create table test3(id int);
alter table test3 compress;
alter table test3 nocompress;
drop schema alter_ctable_compress cascade;
