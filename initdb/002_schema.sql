-- player could be not a user of the system.
create table players
(
    id      integer generated by default as identity
        constraint player_pkey
            primary key,
    name    text not null,
    gender  gender,
    dob     date,
    ranking integer,
    style   text -- playing style, left hand attach.
);

-- a user of the system,
create table users
(
    id     integer generated by default as identity
        constraint user_pkey
            primary key,
    name   text                     not null,
    roles  user_role[] default '{}' not null,
    player integer
        constraint user_player_fk
            references players
);

create table venues
(
    id          integer generated by default as identity
        constraint venue_pkey
            primary key,
    name        text not null,
    description text,
    address     text not null,
    city        text not null,
    province    text,
    country     text not null,
    postcode    text not null,
    location    point,
    phone       text,
    contact     integer
        constraint venue_user_fk
            references users
);

create table clubs
(
    id      integer generated by default as identity
        constraint club_pkey
            primary key,
    name    text not null,
    venue   integer
        constraint club_venue_fk
            references venues,
    contact integer
        constraint club_contact
            references users
);

create table teams
(
    id          integer generated by default as identity
        constraint team_pkey
            primary key,
    name        text,
    description integer,
    club        integer
        constraint team_club_fk
            references clubs,
    is_double   boolean default false not null
);

-- an event can be a part of event serial.
create table event_series
(
    id   integer generated by default as identity
        constraint event_serial_pkey
            primary key,
    name text not null
);

create table events
(
    id             integer generated by default as identity
        constraint event_pkey
            primary key,
    fee            money  default 0 not null,
    name           text                     not null,
    description    text                     not null,
    entry_deadline timestamp with time zone not null
        constraint entry_deadline_date_check
            check (entry_deadline <= start_date),
    ranking_level  integer,
    start_date     date                     not null,
    tags           text[] default '{}' not null,
    end_date       date                     not null
        constraint start_end_date_check
            check (start_date <= end_date),
    organizer      integer
        constraint event_organizer_fk
            references users,
    venue          integer
        constraint event_venue_fk
            references venues,
    event_serial   integer
        constraint event_event_serial_fk
            references event_series
);


create table competitions
(
    id                 integer generated by default as identity
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
            references events,
    rank_restriction   integer,
    entry_limit        integer            default 0                       not null,
    start_time         date                                               not null
);

create table rounds
(
    id          integer generated by default as identity
        constraint round_pkey
            primary key,
    number      smallint default 1 not null
        constraint round_number_check
            check ((number >= 1) AND (number < 256)),
    competition integer
        constraint round_competition_fk
            references competitions,
    event       integer
        constraint round_event_fk
            references events,
    name        text
);

drop table if exists matches;
create table matches
(
    id          integer generated by default as identity
        constraint matches_pkey
            primary key,
    number            smallint                          not null,
    round             integer                           not null
        constraint match_round_fk
            references rounds,
    competition       integer                           not null
        constraint round_competition_fk
            references competitions,
    event             integer                           not null
        constraint round_event_fk
            references events,

    player_one        integer -- player_one / team_one will always be a home match.
        constraint match_player_one_fk
            references players,
    player_two        integer
        constraint match_player_two_fk
            references players,
    team_one          integer
        constraint match_team_one_fk
            references teams,
    team_two          integer
        constraint match_team_two_fk
            references teams,
    competition_type  competition_type not null default 'single',
    parent_team_match_number integer -- which team match does this match belongs to.
                                      -- competition_type == team mean
        constraint parent_match_fk
            references matches,
    constraint match_round_number_uniq
        unique (round, number),
--     constraint check_player_all_set
--        check (player_one is null = player_two is null),
--     constraint check_team_all_set
--         check (team_one is null = team_two is null),
--     constraint check_only_player_or_team_is_set
--         check (team_one is null != player_one is null),
    constraint check_match_is_team
        check ((competition_type = 'team' OR competition_type = 'double') AND ((team_one IS NOT NULL) AND (team_two IS NOT NULL))
                   OR
              ((competition_type = 'single' ) AND ((player_one IS NOT NULL) AND (player_two IS NOT NULL))))
);

create table match_scores
(
    match integer not null
        constraint match_scores_pk
            primary key
        constraint match_scores_match_fk
            references matches,
    score_one         integer default 0 not null,
    score_two         integer default 0 not null,
    sets              integer[] default '{}'::integer[] not null,
    start_time        timestamp with time zone,
    finish_time       timestamp with time zone,
    referee           integer,
    result            competition_result not null default 'pending'
);

create table team_players
(
    team       integer               not null
        constraint team_player_team_id_fkey
            references teams,
    player     integer               not null
        constraint team_player_player_id_fkey
            references players,
    is_captain boolean default false not null,
    constraint team_player_pkey
        primary key (team, player)
);

create table competition_entries
(
    competition  integer               not null
        constraint competition_entry_competition_id_fkey
            references competitions,
    player       integer
        constraint competition_entry_player_id_fkey
            references players,
    team         integer
        constraint competition_entry_team_id_fkey
            references teams,
    is_team      boolean               not null,
    paid_time    timestamp with time zone,
    entry_number integer default 0     not null,
    withdrawn    boolean default false not null,
    constraint competition_entry_pkey
        primary key (competition, entry_number),
    constraint participants_is_team
        check ((is_team AND ((team IS NOT NULL) AND (player IS NULL))) OR
               ((NOT is_team) AND ((player IS NOT NULL) AND (team IS NULL))))
);

-- this is to make sure there is no duplication entry for player or team.
create unique index competition_entry_unique_entry_idx
    on competition_entries (competition, COALESCE(player, '-1'::integer), COALESCE(team, '-1'::integer));

