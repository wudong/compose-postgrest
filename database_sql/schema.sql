drop type if exists gender;
create type gender as enum ('male', 'female');

drop type if exists age_restriction;
create type age_restriction as enum ('open', 'u11', 'u13', 'u15','u17', 'u19', 'u21', 'o40', 'o50', 'o60', 'o70', 'o80');

drop type if exists gender_restriction;
create type gender_restriction as enum ('male', 'female', 'mix');

drop type if exists competition_type;
create type competition_type as enum ('single', 'double', 'team');


drop type if exists club_role;
create type club_role as enum ('owner', 'volunteer');

drop table if exists venue;
create table venue
(
    id integer generated always as identity
        constraint venue_pkey
            primary key
);

drop table if exists "user";
create table "user"
(
    id integer generated always as identity
        constraint user_pkey
            primary key
);

drop table if exists player;
create table player
(
    id integer generated always as identity
        constraint player_pkey
            primary key
);

drop table if exists team;
create table team
(
    id          integer generated always as identity
        constraint team_pkey
            primary key,
    name        text,
    description integer,
    club        integer
        constraint team_club_fk
            references club
);

drop table if exists team_player;
create table team_player
(
    team integer not null
        constraint team_player_team_id_fkey
            references team,
    player integer not null
        constraint team_player_player_id_fkey
            references player,
    constraint team_player_pkey
        primary key (team, player),
    is_captain boolean not null default false
);

drop table if exists club;
create table club
(
    id integer generated always as identity
        constraint club_pkey
            primary key
);

drop table if exists event;
create table event
(
    id             integer generated always as identity
        constraint event_pkey
            primary key,
    fee            money default 0          not null,
    name           text                     not null,
    description    text                     not null,
    start_time     timestamp with time zone,
    entry_deadline timestamp with time zone not null,
    organizer      integer
        constraint event_organizer_fk
            references "user",
    ranking_level  integer
);

drop table if exists competition;
create table competition
(
    id                 integer generated always as identity
        constraint competition_pkey
            primary key,
    type               competition_type                                   not null,
    name               text                                               not null,
    description        text,
    is_team            boolean            default false                   not null,
    fee                money              default 0                       not null,
    age_restriction    age_restriction    default 'open'::age_restriction not null,
    gender_restriction gender_restriction default 'mix'::gender_restriction,
    event              integer
        constraint competition_event_fk
            references event,
    rank_restriction   integer
);


drop table if exists competition_entry;
create table competition_entry
(
    competition integer not null
        constraint competition_entry_competition_id_fkey
            references competition,
    player      integer
        constraint competition_entry_player_id_fkey
            references player,
    team        integer
        constraint competition_entry_team_id_fkey
            references team,
    is_team boolean not null,
    paid_time timestamptz,
    constraint competition_entry_pkey
        primary key (competition, player, team),
    constraint participants_is_team check ((is_team and (team is not null)) or ((not is_team) and (player is not null)))
);

drop table if exists round;
create table round
(
    id          integer generated always as identity
        constraint round_pkey
            primary key,
    number      smallint default 1 not null
        constraint round_number_check
            check ((number >= 1) AND (number < 256)),
    competition integer
        constraint round_competition_fk
            references competition,
    event       integer
        constraint round_event_fk
            references event,
    name        text,
    start_time  timestamptz,
    finish_time timestamptz
);

drop table if exists match;
create table match
(
    number      smallint  default 1               not null,
    round       integer                           not null
        constraint match_round_fk
            references round,
    competition integer not null
        constraint round_competition_fk
            references competition,
    event       integer not null
        constraint round_event_fk
            references event,
    is_team     boolean                          not null,
    start_time  timestamp with time zone,
    finish_time timestamp with time zone,
    score_one   integer,
    score_two   integer,
    player_one  integer
        constraint match_player_one_fk
            references player,
    player_two  integer
        constraint match_player_two_fk
            references player,
    team_one    integer
        constraint match_team_one_fk
            references team,
    team_two    integer
        constraint match_team_two_fk
            references team,
    sets        integer[] default '{}'::integer[] not null,
    constraint match_pk
        primary key (round, number),
    constraint check_match_is_team
        check ((is_team AND ((team_one IS NOT NULL) AND (team_two IS NOT NULL))) OR
               ((NOT is_team) AND ((player_one IS NOT NULL) AND (player_two IS NOT NULL))))
);

