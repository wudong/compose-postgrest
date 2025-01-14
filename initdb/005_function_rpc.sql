-- given the list of players, find the team that
-- contains all the players.
-- IMPORTANT, it is possible to have a two player team that is not a double.
create or replace function get_team_by_players(v_players integer[], v_is_double boolean)
    returns
        table
        (
            id      integer,
            gender  gender_restriction,
            ranking integer,
            is_double boolean,
            players players[]
        )
    language sql
    IMMUTABLE
as
$$
select t.id, t.gender, t.ranking, t.is_double, array_agg(p) as players
from teams t
         join team_players tp on t.id = tp.team
         join players p on tp.player = p.id
where t.is_double = v_is_double and (p.id = any(v_players))
group by t.id
having array_length(array_agg(p), 1) >= array_length(v_players, 1);
$$;

-- get a team's gender based on its players' gender.
create or replace function get_team_gender(v_genders gender[]) returns gender_restriction
    language sql
    IMMUTABLE
as
$$
    select case
           when t.has_male and not t.has_female then 'male'::gender_restriction
           when not t.has_male and t.has_female then 'female'::gender_restriction
           else 'mix'::gender_restriction
        end
    from (select 'male' = any (v_genders) as has_male, 'female' = any (v_genders) as has_female) as t;
$$;

-- create a team.
drop function if exists create_team;
create or replace function create_team(v_players  integer[], v_is_double boolean) returns integer
    language plpgsql
as
$$
declare
    v_all_player_exists integer;
    v_team_id  integer;
    v_player_id  integer;
    v_gender   gender_restriction;
begin
    if array_length(v_players, 1) <= 1 then
        raise exception 'team must more than 1 player';
    end if;

    if array_length(v_players, 1) <> 2 and v_is_double then
        raise exception 'double can only has two players';
    end if;

    -- verify all player_id exists.
    -- this is actually not needed cause it would failed the foreigh key.
--     select array_length(array_agg(id), 1) into v_all_player_exists from players where id = any(v_players);
--     if v_all_player_exists <> array_length(v_players, 1) then
--         raise exception 'some player_id not exists';
--     end if;

    select id into v_team_id from get_team_by_players(v_players, v_is_double);

    if v_team_id is NULL then
        select get_team_gender(array_agg(p.gender)) into v_gender from players p where p.id = any(array[1,2,3]);

        insert into teams(is_double, gender) values (v_is_double, v_gender) returning id into v_team_id;

        foreach v_player_id in array v_players
        loop
            insert into team_players(team, player) values (v_team_id, v_player_id);
        end loop;
    end if;
    return v_team_id;
end
$$;


create type user_with_player as
    (
    "user" users,
    player players
    );
-- get or create user after the user login.
-- we use email from jwt token to associate the user.
drop function if exists get_or_create_user;
create or replace function get_or_create_user() returns user_with_player
    language plpgsql
as
$$
declare
    v_email text;
    v_user user_with_player;
    vv_user users;
    vv_player players;
    v_name text;
begin
    SELECT current_setting('request.jwt.claims', true)::json->>'email' into v_email;
    SELECT current_setting('request.jwt.claims', true)::json->>'name' into v_name;

    if v_email is NULL then
        raise exception 'email not found in jwt token';
    end if;

    select row(u.*) as "user", row(p.*) as player into v_user from users u
        join players p on u.player = p.id
        where u.email = v_email;
    if found then
        return v_user;
    else
        -- create user and its player.
        insert into users (email, name) values (v_email, v_name) returning * into vv_user;
        insert into players (name, registered_user)
                 values (v_name, vv_user.id ) returning * into vv_player;
        update users set player = vv_player.id where id = vv_user.id;
        return (v_user, vv_player);
    end if;
end
$$;
