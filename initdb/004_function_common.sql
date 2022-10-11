create or replace function array_compare_as_set(anyarray, anyarray) returns boolean
    immutable
    strict
    language sql
as
$$
SELECT array_length($1, 1) = array_length($2, 1) AND $1 @> $2
$$;