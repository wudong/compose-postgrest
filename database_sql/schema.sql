create type gender as enum ('male', 'female');

create type gender_restriction as enum ('male', 'female', 'mix');

create type competition_type as enum ('single', 'double', 'team');

create type age_restriction as enum ('open', 'u11', 'u13', 'u15', 'u17', 'u19', 'u21', 'o40', 'o50', 'o60', 'o70', 'o80');

create table venue
(
    id          integer generated always as identity
        constraint venue_pkey
            primary key,
    name        text not null,
    description text,
    location    point,
    phone       text
);

create table player
(
    id      integer generated always as identity
        constraint player_pkey
            primary key,
    name    text not null,
    gender  gender,
    dob     date,
    ranking integer
);

create table "user"
(
    id     integer generated always as identity
        constraint user_pkey
            primary key,
    player integer
        constraint user_player_fk
            references player
);

create table club
(
    id      integer generated always as identity
        constraint club_pkey
            primary key,
    name    text not null,
    venue   integer
        constraint club_venue_fk
            references venue,
    contact integer
        constraint club_contact
            references "user"
);

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
    name        text
);

create table match
(
    number      smallint  default 1               not null,
    round       integer                           not null
        constraint match_round_fk
            references round,
    competition integer                           not null
        constraint round_competition_fk
            references competition,
    event       integer                           not null
        constraint round_event_fk
            references event,
    is_team     boolean                           not null,
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

create table team_player
(
    team       integer               not null
        constraint team_player_team_id_fkey
            references team,
    player     integer               not null
        constraint team_player_player_id_fkey
            references player,
    is_captain boolean default false not null,
    constraint team_player_pkey
        primary key (team, player)
);

create table competition_entry
(
    competition integer not null
        constraint competition_entry_competition_id_fkey
            references competition,
    player      integer not null
        constraint competition_entry_player_id_fkey
            references player,
    team        integer not null
        constraint competition_entry_team_id_fkey
            references team,
    is_team     boolean not null,
    paid_time   timestamp with time zone,
    constraint competition_entry_pkey
        primary key (competition, player, team),
    constraint participants_is_team
        check ((is_team AND (team IS NOT NULL)) OR ((NOT is_team) AND (player IS NOT NULL)))
);