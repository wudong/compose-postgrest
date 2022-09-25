-- trigger to make sure the entry will not exceeding the entry limit.
-- do we want to lock the entry row?
create or replace function competition_entry_insert_trigger_fn() returns trigger
    language plpgsql
as
$$
DECLARE
    entry_limit integer;
    current_entry_count integer;
BEGIN
    -- we don't update the competition table, but requires a lock to prevent
    -- two concurrent inserts from exceeding the limit.
    SELECT competitions.entry_limit INTO entry_limit
    FROM competitions where NEW.competition = competitions.id FOR UPDATE;

    SELECT count(*) INTO current_entry_count
    FROM competition_entries WHERE competition = NEW.competition and withdrawn = false;

    IF (entry_limit > 0 AND current_entry_count >= entry_limit) THEN
        RAISE EXCEPTION 'Competition entry limit reached';
    ELSE
        NEW.entry_number = current_entry_count + 1;
    END IF;

    RETURN NEW;
END;
$$;

create trigger competition_entry_insert_trigger
    before insert
    on competition_entries
    for each row
execute procedure competition_entry_insert_trigger_fn();
