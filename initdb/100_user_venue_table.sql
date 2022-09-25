
insert into users (id, name, roles, player)
values (0, 'wtt', '{ event_admin }', null),
       (1, 'Wudong Liu', '{ system_admin }', null),
       (2, 'Yi Zhou', '{ system_admin }', null),
       (3, 'Grace Liu', '{ player }', null),
       (4, 'Helen Yue Pan', '{ player }', null)
ON CONFLICT ON CONSTRAINT user_pkey do nothing;

insert into venues (id, name, description, address, city, province, country, postcode, location, phone,
                    contact)
values (0, 'Marrara Indoor Stadium','', '10 Abala Rd', 'Marrara', '', 'Australia', 'NT 0812','(-12.3995475,130.8821411)', '+61889226888', null),
       (1, 'Cairo Stadium Indoor Halls Complex','', '10 Abala Rd', 'Cairo', '', 'Egypt', '','(30.0685911,31.3059116)', null, null),
       (2, 'Tap Seac Multisport Pavilion','', 'R. de Ferreira do Amaral', 'Macao', '', 'China', '','(22.1959897,113.5471575)', '+85328522021', null)
ON CONFLICT ON CONSTRAINT venue_pkey do nothing;
