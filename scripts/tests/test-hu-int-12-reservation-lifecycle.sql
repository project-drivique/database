DO $$
DECLARE
    v_has_ext_insert BOOLEAN;
    v_has_ext_update BOOLEAN;
    v_has_audit_insert BOOLEAN;
BEGIN
    SELECT has_table_privilege('drivique_app', 'rental.rental_extension_requests', 'INSERT') INTO v_has_ext_insert;
    SELECT has_table_privilege('drivique_app', 'rental.rental_extension_requests', 'UPDATE') INTO v_has_ext_update;
    SELECT has_table_privilege('drivique_app', 'audit.audit_logs', 'INSERT') INTO v_has_audit_insert;

    IF NOT v_has_ext_insert OR NOT v_has_ext_update OR NOT v_has_audit_insert THEN
        RAISE EXCEPTION 'HU-INT-12 FAILED: drivique_app does not have required privileges on rental/audit tables.';
    END IF;

    RAISE NOTICE 'HU-INT-12 APPROVED: reservation lifecycle grants validated.';
END $$;
