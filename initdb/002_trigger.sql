-- trigger to make sure the entry will not exceeding the entry limit.
-- do we want to lock the entry row?
create or replace function competition_entry_insert_trigger_fn() returns trigger
    language plpgsql
as
$$
DECLARE
    v_competition competitions;
    v_current_entry_count integer;
    v_exist_entry_count integer;
BEGIN
    -- we don't update the competition table, but requires a lock to prevent
    -- two concurrent inserts from exceeding the limit.
    SELECT * into v_competition
    FROM competitions cc where NEW.competition = cc.id FOR UPDATE;

    -- if it is a single entry, make sure it is not entered again.
    if v_competition.type <> 'single' then
        select count(competition_entries.player) into v_exist_entry_count from competition_entries where competition_entries.player = NEW.player;
        if v_exist_entry_count > 0 then
            raise exception 'Player (%) has already entered into the competition', new.player;
        end if;
    end if;

    -- if it is team entry, make sure it does not exist in other team already.
    if v_competition.type <> 'single' then
        select count(tp.player) into v_exist_entry_count from competition_entries
            join teams t on competition_entries.team = t.id
            join team_players tp on t.id = tp.team
            where competition_entries.competition = NEW.competition
            and tp.player = any(
                select tp2.player from teams t2 join team_players tp2 on t2.id = tp2.team
                    where t2.id = new.team
           );
        if v_exist_entry_count > 0 then
            raise exception 'Team (%) has player has already entered into the competition in other team/doubles', NEW.team;
        end if;
    end if;

    SELECT count(*) INTO v_current_entry_count
    FROM competition_entries WHERE competition = NEW.competition and withdrawn = false;

    IF (v_competition.entry_limit > 0 AND v_current_entry_count >= v_competition.entry_limit) THEN
        RAISE EXCEPTION 'Competition entry limit reached';
    end if;

    NEW.entry_number = v_current_entry_count + 1;
    NEW.competition_type = v_competition.type;

    update competitions set current_entries = v_current_entry_count + 1
    where NEW.competition = competitions.id;

    RETURN NEW;
END
$$;

create trigger competition_entry_insert_trigger
    before insert
    on competition_entries
    for each row
execute procedure competition_entry_insert_trigger_fn();
