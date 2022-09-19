CREATE OR REPLACE FUNCTION competition_entry_insert_trigger_fn()
    RETURNS trigger AS
$$
DECLARE
    entry_limit integer;
    current_entry_count integer;
BEGIN
    SELECT competition.entry_limit INTO entry_limit
        FROM competition where NEW.competition = competition.id;
    SELECT count(*) INTO current_entry_count
        FROM competition_entry WHERE competition = NEW.competition and withdrawn = false;

    IF (entry_limit > 0 AND current_entry_count >= entry_limit) THEN
        RAISE EXCEPTION 'Competition entry limit reached';
    ELSE
        NEW.entry_number = current_entry_count + 1;
    END IF;

    RETURN NEW;
END;
$$LANGUAGE 'plpgsql';

drop trigger if exists competition_entry_insert_trigger on competition_entry;
CREATE TRIGGER competition_entry_insert_trigger
    BEFORE INSERT
    ON "competition_entry"
    FOR EACH ROW
EXECUTE PROCEDURE competition_entry_insert_trigger_fn();


drop index if exists competition_entry_unique_entry_idx;
CREATE UNIQUE INDEX competition_entry_unique_entry_idx ON competition_entry( competition, COALESCE( player, -1), COALESCE( team, -1));