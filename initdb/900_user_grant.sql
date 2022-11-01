CREATE ROLE anonymous;
-- All login user would have this role.
CREATE ROLE webuser;

GRANT USAGE ON SCHEMA public TO anonymous;
GRANT USAGE ON SCHEMA public TO webuser;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO anonymous;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO anonymous;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO webuser;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO webuser;

-- need to execute this last, cause newly created table does not have the permission from the grant.
-- https://dba.stackexchange.com/questions/33943/granting-access-to-all-tables-for-a-user
