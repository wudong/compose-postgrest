-- CREATE SCHEMA public;

CREATE ROLE anon;

GRANT USAGE ON SCHEMA public TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO anon;

-- need to execute this last, cause newly created table does not have the permission from the grant.
-- https://dba.stackexchange.com/questions/33943/granting-access-to-all-tables-for-a-user
