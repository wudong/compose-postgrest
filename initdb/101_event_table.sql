insert into event_series (id, name)
values (0, 'WTT Youth Contender'),
       (1, 'WTT Youth Star Contender'),
       (2, 'WTT Contender'),
       (3, 'WTT Champions'),
       (4, 'WTT Feeder Series')
ON CONFLICT ON CONSTRAINT event_serial_pkey do nothing;

insert into events (id, fee, name, description, entry_deadline, ranking_level, start_date, end_date, organizer, venue,event_serial)
values (0, 0, 'WTT Youth Contender Tbilisi 2022', '', '2022-09-01', 1, '2022-09-19', '2022-09-25', 0, 0, 0),
       (1, 0, 'WTT Youth Contender Darwin 2022', '', '2022-09-17', 1, '2022-09-27', '2022-09-29', 0, 0, 0),
       (2, 1, 'WTT Youth Star Contender Podgorica 2022', '', '2022-10-17', 2, '2022-10-27', '2022-10-30', 0, 0, 0),
       (3, 1, 'WTT Youth Contender Cairo 2022', '', '2022-10-20', 2, '2022-10-24', '2022-10-30', 0, 1, 0),
       (4, 1, 'WTT Champions Macao 2022', '', '2022-10-19', 2, '2022-10-19', '2022-10-23', 0, 2, 0)
ON CONFLICT ON CONSTRAINT event_pkey do nothing;

-- Generate competitions
DO
$$
DECLARE
    r record;
    age age_restriction;
    ages age_restriction[] := '{ u11, u13, u15, u17, u19 }'::age_restriction[];
BEGIN
    FOR r IN SELECT * FROM events
    LOOP
        FOREACH age IN ARRAY ages LOOP
            INSERT INTO competitions (type, name, description, age_restriction, gender_restriction, event, start_time)
            VALUES ('single', 'Boys Single ' || age, '', age, 'male', r.id, r.start_date),
                   ('single', 'Girls Single ' || age, '', age, 'female', r.id, r.start_date +1);
       end loop;
    END LOOP;
END
$$;