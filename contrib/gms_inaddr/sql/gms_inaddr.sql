create extension gms_output;
create extension gms_inaddr;

begin
gms_output.enable;
gms_output.put_line(gms_inaddr.get_host_address('localhost'));
gms_output.put_line(gms_inaddr.get_host_name('127.0.0.1'));
gms_output.put_line(gms_inaddr.get_host_address(null));
gms_output.put_line(gms_inaddr.get_host_name(null));
end
/

CREATE TABLE tb1_22 (col1 number primary key, check(col1<100),col2 nchar(15) not null,address1 varchar2 default gms_inaddr.GET_HOST_NAME,name1 varchar2 default gms_inaddr.get_host_address);

begin
gms_output.enable;
gms_output.put_line(gms_inaddr.get_host_address('localhostxx'));
gms_output.put_line(gms_inaddr.get_host_name('127.0.0.1'));
end;
/

begin
gms_output.enable;
gms_output.put_line(gms_inaddr.get_host_name('10.254.180.400'));
end;
/

begin
gms_output.enable;
gms_output.put_line(gms_inaddr.get_host_name('::1'));
end;
/

drop table tb1_22;
drop extension gms_output;
drop extension gms_inaddr;

-- B compatibility: '' is not NULL there, it must behave like NULL (local host) instead of being resolved
create database gms_inaddr_testdb_b dbcompatibility='B';
\c gms_inaddr_testdb_b
create extension gms_inaddr;
select gms_inaddr.get_host_address('') = gms_inaddr.get_host_address(null) as same_address;
select gms_inaddr.get_host_name('') = gms_inaddr.get_host_name(null) as same_name;
create table tb_b (col1 int, address1 varchar default gms_inaddr.get_host_name(''), name1 varchar default gms_inaddr.get_host_address(''));
insert into tb_b(col1) values (1);
select address1 = gms_inaddr.get_host_name(null) as same_name, name1 = gms_inaddr.get_host_address(null) as same_address from tb_b;
drop table tb_b;
drop extension gms_inaddr;
\c contrib_regression
drop database gms_inaddr_testdb_b;
