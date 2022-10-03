insert into players (id, name, gender, dob)
values (1, 'Wudong Liu', 'male', '1978-10-13' ),
       (2, 'Yi Zhou', 'male', '1979-10-13'),
       (3, 'Grace Liu', 'female', '2012-10-25'),
       (4, 'Helen Yue Pan', 'female', '1984-11-22'),
       (5, 'Yeqing Zeng', 'male', '1980-01-11'),
       (6, 'Ethan Zeng', 'male', '2008-01-01'),
       (7, 'Stephen Holland', 'male', '1958-12-10'),
       (8, 'Chester Chung', 'male', '1984-04-04')
ON CONFLICT ON CONSTRAINT player_pkey do nothing;

insert into users (id, name, roles, player)
values (0, 'wtt', '{ event_admin }', null),
       (1, 'Wudong Liu', '{ system_admin, player }', 1),
       (2, 'Yi Zhou', '{ system_admin, player }', 2),
       (3, 'Grace Liu', '{ player }', 3),
       (4, 'Helen Yue Pan', '{ player }', 4)
ON CONFLICT ON CONSTRAINT user_pkey do nothing;

insert into venues (id, name, description, address, city, province, country, postcode, location, phone,
                    contact)
values (0, 'Marrara Indoor Stadium','', '10 Abala Rd', 'Marrara', '', 'Australia', 'NT 0812','(-12.3995475,130.8821411)', '+61889226888', null),
       (1, 'Cairo Stadium Indoor Halls Complex','', '10 Abala Rd', 'Cairo', '', 'Egypt', '','(30.0685911,31.3059116)', null, null),
       (2, 'Tap Seac Multisport Pavilion','', 'R. de Ferreira do Amaral', 'Macao', '', 'China', '','(22.1959897,113.5471575)', '+85328522021', null)
ON CONFLICT ON CONSTRAINT venue_pkey do nothing;

insert into teams (id, name, is_double, gender)
values (0, '', true, 'male'),
       (1, '', true, 'female'),
       (2, '', true, 'male'),
       (3, '', true, 'male')
ON CONFLICT ON CONSTRAINT team_pkey do nothing;

insert into team_players(team, player)
values (0, 1),
       (0, 2),
       (1, 3),
       (1, 4),
       (2, 5),
       (2, 6),
       (3, 7),
       (3, 8)
on conflict on constraint team_player_pkey do nothing;
