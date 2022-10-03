insert into event_series (id, name)
values (0, 'WTT Youth Contender'),
       (1, 'WTT Youth Star Contender'),
       (2, 'WTT Contender'),
       (3, 'WTT Champions'),
       (4, 'WTT Feeder Series')
ON CONFLICT ON CONSTRAINT event_serial_pkey do nothing;

insert into events (id, fee, name, description,  entry_deadline, ranking_level, start_date, end_date, organizer, venue,event_serial, tags)
values (0, 0, 'WTT Youth Contender Tbilisi 2022',  '','2022-09-01', 1, '2022-09-19', '2022-09-25', 0, 0, 0, '{team, women, men}'),
       (1, 0, 'WTT Youth Contender Darwin 2022', '','2022-09-17', 1, '2022-09-27', '2022-09-29', 0, 0, 0, '{ms,ws,u11}'),
       (2, 1, 'WTT Youth Star Contender Podgorica 2022','', '2022-10-17', 2, '2022-10-27', '2022-10-30', 0, 0, 0, '{ms,ws,u11}'),
       (3, 1, 'WTT Youth Contender Cairo 2022', '', '2022-10-20', 2, '2022-10-24', '2022-10-30', 0, 1, 0, '{men, women, single, double}'),
       (4, 1, 'WTT Champions Macao 2022','', '2022-10-19', 2, '2022-10-19', '2022-10-23', 0, 2, 0, '{girl,boy,u11, u13}'),
       (5, 3, 'WTT World Team Championship Chengdu 2022','', '2022-10-01', 2, '2022-10-01', '2022-10-07', 0, 2, 0, '{team, men, women}')
ON CONFLICT ON CONSTRAINT event_pkey do nothing;

update events
set description = 'The 2022 World Team Table Tennis Championships are held in Chengdu, China from 30 September to 9 October 2022.[1][2] The World Team Championships were originally scheduled in April and pushed back to September due to the COVID-19 pandemic.'
where id= 5;

-- Generate competitions
DO
$$
DECLARE
    r record;
    p record;
    c integer;
    age age_restriction;
    ages age_restriction[] := '{ u11, u13, u15, u17, u19 }'::age_restriction[];
BEGIN
    -- single events.
    FOR r IN SELECT * FROM events where id < 4
    LOOP
        FOREACH age IN ARRAY ages
        LOOP
            INSERT INTO competitions (type, name, description, age_restriction, gender_restriction, event, start_time, entry_limit, fee)
            VALUES ('single', 'Boys Single ' || age, '', age, 'male', r.id, r.start_date, 64, 1)
            ON CONFLICT ON CONSTRAINT competition_pkey do nothing returning ID into c;

            FOR p IN SELECT * FROM players where gender = 'male'
            LOOP
                INSERT INTO competition_entries (competition, player, team, competition_type, paid_time)
                VALUES (c, p.id, null, 'single', now())
                ON CONFLICT ON CONSTRAINT competition_entry_pkey do nothing ;
            END LOOP;

            INSERT INTO competitions (type, name, description, age_restriction, gender_restriction, event, start_time, entry_limit, fee)
            VALUES ('single', 'Girls Single ' || age, '', age, 'female', r.id, r.start_date, 64, 1)
            ON CONFLICT ON CONSTRAINT competition_pkey do nothing returning ID into c;

            FOR p IN SELECT * FROM players where gender='female'
            LOOP
                INSERT INTO competition_entries (competition, player, team, competition_type, paid_time)
                VALUES (c, p.id, null, 'single', now())
                ON CONFLICT ON CONSTRAINT competition_entry_pkey do nothing ;
            END LOOP;

            INSERT INTO competitions (type, name, description, age_restriction, gender_restriction, event, start_time, entry_limit, fee)
            VALUES ('double', 'Boys double ' || age, '', age, 'male', r.id, r.start_date, 64, 1)
            ON CONFLICT ON CONSTRAINT competition_pkey do nothing returning ID into c;

            FOR p IN SELECT * FROM teams where gender='male'
                LOOP
                    INSERT INTO competition_entries (competition, player, team, competition_type, paid_time)
                    VALUES (c, null, p.id, 'double', now())
                    ON CONFLICT ON CONSTRAINT competition_entry_pkey do nothing ;
           END LOOP;

            INSERT INTO competitions (type, name, description, age_restriction, gender_restriction, event, start_time, entry_limit, fee)
            VALUES ('double', 'Girls double ' || age, '', age, 'female', r.id, r.start_date, 64, 1)
            ON CONFLICT ON CONSTRAINT competition_pkey do nothing returning ID into c;

            FOR p IN SELECT * FROM teams where gender='female'
                LOOP
                    INSERT INTO competition_entries (competition, player, team, competition_type, paid_time)
                    VALUES (c, null, p.id, 'double', now())
                    ON CONFLICT ON CONSTRAINT competition_entry_pkey do nothing ;
           END LOOP;

       END LOOP;
    END LOOP;
END
$$;

-- team events.
INSERT INTO competitions (type, name, description, age_restriction, gender_restriction, event, start_time, entry_limit, fee)
VALUES ('team', 'Men''s team ', '', 'open', 'male', 5, '2022-10-01', 64, 100),
       ('team', 'Women''s team ', '', 'open', 'female', 5, '2022-10-01', 64, 100)
ON CONFLICT ON CONSTRAINT competition_pkey do nothing;



