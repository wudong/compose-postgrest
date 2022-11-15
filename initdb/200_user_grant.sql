CREATE ROLE anonymous noinherit;
CREATE ROLE webuser inherit;
CREATE ROLE webadmin inherit bypassrls;

grant anonymous to webuser;
grant webuser to webadmin;

GRANT USAGE ON SCHEMA public TO anonymous;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO anonymous;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO webuser;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO webuser;

