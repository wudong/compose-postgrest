-- given the list of players, find the team that
-- contains all the players.
create or replace function get_team_by_players(players integer[], is_double boolean)
    returns
        table
        (
            id      integer,
            gender  gender_restriction,
            ranking integer,
            players players[]
        )
    language sql
    IMMUTABLE
as
$$
select t.id, t.gender, t.ranking, array_agg(p) as players
from teams t
         join team_players tp on t.id = tp.team
         join players p on tp.player = p.id
where t.is_double = is_double and (tp.player in players)
group by t.id
having array_length(array_agg(p), 1) >= array_length(players, 1);
$$;

create or replace function get_double_gender(gender_1 gender, gender_2 gender) returns gender_restriction
    language sql
    IMMUTABLE
as
$$
select case gender_1 = gender_2
       when
           true then 'mix'::gender_restriction
       else
           gender_1::text::gender_restriction
       end;
$$;

create or replace function create_double(player_1 integer, player_2 integer) returns integer
    language plpgsql
as
$$
declare
    team_id  integer;
    genders gender[];
    gender   gender_restriction;
begin
    select id into team_id from get_team_by_players(array(player_1, player_2), true);
    IF team_id is NULL then
        select array_agg(p.gender) into genders from players p where p.id = player_1 OR p.id = player_2;

        if array_length(genders, 1) <> 2 then
            raise exception 'players must be two';
        end if;

        insert into teams(is_double, gender) values (true, get_double_gender(genders[1], genders[2]))
                                             returning id into team_id;
        insert into team_players(team, player) values (team_id, player_1);
        insert into team_players(team, player) values (team_id, player_2);
    end if;
    return team_id;
end
$$


create or replace function create_team(players players[]) returns integer
    language plpgsql
as
$$
declare
team_id  integer;
    genders gender[];
    gender   gender_restriction;
begin
select id into team_id from get_double(player_1, player_2);
IF team_id is NULL then
select array_agg(p.gender) into genders from players p where p.id = player_1 OR p.id = player_2;

if array_length(genders, 1) <> array_length(players, 1) then
            raise exception 'not all players exists';
end if;

insert into teams(is_double, gender) values (true, get_double_gender(genders[1], genders[2]))
    returning id into team_id;
insert into team_players(team, player) values (team_id, player_1);
insert into team_players(team, player) values (team_id, player_2);
end if;
return team_id;
end
$$

