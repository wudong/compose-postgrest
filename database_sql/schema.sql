create type gender as enum ('m', 'f');

alter type gender owner to postgres;

create table "user"
(
    id      bigint generated always as identity
        constraint user_pk
            primary key,
    name    text                                   not null,
    dob     date,
    gender  gender,
    created timestamp with time zone default now() not null
);

alter table "user"
    owner to postgres;

create table event
(
    id          bigint generated always as identity
        constraint event_pk
            primary key,
    name        text                                   not null,
    description text                                   not null,
    organizer   bigint                                 not null
        constraint event_organizer_fk
            references "user",
    created     timestamp with time zone default now() not null
);

alter table event
    owner to postgres;

grant select on event to anon;

grant select on "user" to anon;

create table event_participants
(
    event_id  integer                                not null
        constraint event_participants_event_fk
            references event,
    user_id   integer                                not null
        constraint event_participants_user_fk
            references "user",
    created   timestamp with time zone default now() not null,
    paid_time timestamp with time zone,
    constraint event_participants_pk
        primary key (event_id, user_id)
);

comment on column event_participants.created is 'the timestamp that user enter the event.';

comment on column event_participants.paid_time is 'when paid_time is not null, it means paid.';

alter table event_participants
    owner to postgres;

grant select on event_participants to anon;

