DO $$
DECLARE
    v_has_insert_reservations BOOLEAN;
    v_has_insert_promotions BOOLEAN;
BEGIN
    SELECT has_table_privilege('drivique_app', 'rental.reservations', 'INSERT') INTO v_has_insert_reservations;
    SELECT has_table_privilege('drivique_app', 'rental.reservation_promotions', 'INSERT') INTO v_has_insert_promotions;

    IF NOT v_has_insert_reservations OR NOT v_has_insert_promotions THEN
        RAISE EXCEPTION 'HU-INT-11 FAILED: drivique_app does not have required insert privileges on rental schema tables.';
    END IF;

    RAISE NOTICE 'HU-INT-11 APPROVED: reservation creation grants validated.';
END $$;
