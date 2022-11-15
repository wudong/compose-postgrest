create view player_competition_entries as
select p.id as player_id, ce.*, c.name as competition_name, e.name as event_name, e.start_date as event_date, e.id as event
from competition_entries ce, competitions c, events e, players p
where c.id = ce.competition and c.event = e.id and
    ((competition_type = 'single' and ce.player = p.id)
        or (competition_type != 'single' and ce.team in
                                             (select id from get_team_by_players(ARRAY[p.id], c.type = 'double'))));

