/* Projeto DW SEED */

/* DCL */
create user seed
password '99999999999'

grant usage on schema dw to seed;

grant select on all tables in schema dw to seed;

grant select on table dw.cliente to integracao_seed;

select d.datname as database_name,
       u.usename as owner
from pg_database d
join pg_user u on d.datdba = u.usesysid;

