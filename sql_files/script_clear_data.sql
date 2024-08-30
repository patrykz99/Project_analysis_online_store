-- Fcn to clear data (check if table contains null values and duplicates)

CREATE OR REPLACE FUNCTION check_nulls_duplicates(table_name1 TEXT)
    -- return table with columns 'col','has_null','has_duplicates'
    RETURNS TABLE
        (
            col TEXT,
            has_null BOOLEAN,
            has_duplicate BOOLEAN
        )
AS
$$
DECLARE
    col TEXT;
    has_null BOOLEAN;
    has_duplicate BOOLEAN;
BEGIN
    FOR col IN (SELECT column_name FROM information_schema.columns WHERE table_name = table_name1)
        LOOP
        EXECUTE FORMAT('SELECT EXISTS (SELECT 1 FROM %I WHERE %I IS NULL)', table_name1, col) INTO has_null;
        EXECUTE FORMAT('SELECT EXISTS (SELECT 1 FROM %I GROUP BY %I HAVING COUNT(%I) > 1)', table_name1, col,col) INTO has_duplicate;

        RETURN QUERY SELECT col,has_null,has_duplicate;
        END LOOP;
END;

$$language plpgsql;