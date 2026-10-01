BEGIN;

DO $$
DECLARE
    colombia_id UUID;
    cc_id UUID;
    admin_id UUID;
    initial_updated_at TIMESTAMPTZ;
    updated_timestamp TIMESTAMPTZ;
BEGIN
    SELECT id INTO colombia_id FROM iam.nationalities WHERE iso_code = 'CO';
    SELECT id INTO cc_id FROM iam.document_types WHERE code = 'CC';
    SELECT id INTO admin_id FROM iam.users WHERE email = 'admin@drivique.com';

    IF colombia_id IS NULL OR cc_id IS NULL OR admin_id IS NULL THEN
        RAISE EXCEPTION 'Expected Colombia, CC and admin user seeds';
    END IF;

    IF (SELECT count(*) FROM iam.document_types) <> 5 THEN
        RAISE EXCEPTION 'Expected five document type seeds';
    END IF;

    IF (SELECT count(*) FROM iam.document_statuses) <> 3 THEN
        RAISE EXCEPTION 'Expected three document status seeds';
    END IF;

    UPDATE iam.users
    SET document_type_id = cc_id, nationality_id = colombia_id
    WHERE id = admin_id;

    BEGIN
        INSERT INTO iam.nationalities (name, iso_code)
        VALUES ('Duplicate Colombia', 'CO');
        RAISE EXCEPTION 'Expected duplicated ISO code to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO iam.document_types (code, name, requires_front_and_back)
        VALUES ('invalid-type', 'Invalid type', TRUE);
        RAISE EXCEPTION 'Expected invalid document type code to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        UPDATE iam.users
        SET nationality_id = gen_random_uuid()
        WHERE id = admin_id;
        RAISE EXCEPTION 'Expected invalid user nationality reference to fail';
    EXCEPTION
        WHEN foreign_key_violation THEN NULL;
    END;

    SELECT updated_at INTO initial_updated_at
    FROM iam.document_types
    WHERE id = cc_id;

    UPDATE iam.document_types
    SET updated_at = initial_updated_at - INTERVAL '1 day', name = 'Citizenship Card Updated'
    WHERE id = cc_id;

    SELECT updated_at INTO updated_timestamp
    FROM iam.document_types
    WHERE id = cc_id;

    IF updated_timestamp <= initial_updated_at - INTERVAL '1 day' THEN
        RAISE EXCEPTION 'Expected document type updated_at trigger to refresh the timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-11 APPROVED: identity catalogs, seeds, uniqueness and user foreign keys validated.';
END;
$$;

ROLLBACK;
