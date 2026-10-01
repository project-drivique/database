BEGIN;

DO $$
DECLARE
    admin_id UUID;
    cc_type_id UUID;
    passport_type_id UUID;
    pending_status_id UUID;
    approved_status_id UUID;
    rejected_status_id UUID;
    document_id UUID;
    initial_updated_at TIMESTAMPTZ;
    updated_timestamp TIMESTAMPTZ;
BEGIN
    SELECT id INTO admin_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO cc_type_id FROM iam.document_types WHERE code = 'CC';
    SELECT id INTO passport_type_id FROM iam.document_types WHERE code = 'PASSPORT';
    SELECT id INTO pending_status_id FROM iam.document_statuses WHERE code = 'PENDING';
    SELECT id INTO approved_status_id FROM iam.document_statuses WHERE code = 'APPROVED';
    SELECT id INTO rejected_status_id FROM iam.document_statuses WHERE code = 'REJECTED';

    IF admin_id IS NULL OR cc_type_id IS NULL OR passport_type_id IS NULL
       OR pending_status_id IS NULL OR approved_status_id IS NULL OR rejected_status_id IS NULL THEN
        RAISE EXCEPTION 'Expected IAM and KYC catalog seeds';
    END IF;

    INSERT INTO iam.user_documents (
        user_id, document_type_id, status_id, front_url
    ) VALUES (
        admin_id, passport_type_id, pending_status_id, 'https://files.drivique.test/passport-front.jpg'
    ) RETURNING id INTO document_id;

    BEGIN
        INSERT INTO iam.user_documents (
            user_id, document_type_id, status_id, front_url
        ) VALUES (
            admin_id, cc_type_id, pending_status_id, 'https://files.drivique.test/cc-front.jpg'
        );
        RAISE EXCEPTION 'Expected a two-sided document without back URL to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO iam.user_documents (
            user_id, document_type_id, status_id, front_url
        ) VALUES (
            admin_id, passport_type_id, approved_status_id, 'https://files.drivique.test/passport-approved.jpg'
        );
        RAISE EXCEPTION 'Expected an approved document without review data to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO iam.user_documents (
            user_id, document_type_id, status_id, front_url, reviewed_by, reviewed_at
        ) VALUES (
            admin_id, passport_type_id, rejected_status_id,
            'https://files.drivique.test/passport-rejected.jpg', admin_id, CURRENT_TIMESTAMP
        );
        RAISE EXCEPTION 'Expected a rejected document without review notes to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    UPDATE iam.user_documents
    SET status_id = approved_status_id,
        reviewed_by = admin_id,
        reviewed_at = CURRENT_TIMESTAMP
    WHERE id = document_id;

    IF NOT EXISTS (
        SELECT 1 FROM iam.user_documents
        WHERE id = document_id
          AND status_id = approved_status_id
          AND reviewed_by = admin_id
          AND reviewed_at IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Expected approved document review data to persist';
    END IF;

    SELECT updated_at INTO initial_updated_at
    FROM iam.user_documents
    WHERE id = document_id;

    UPDATE iam.user_documents
    SET updated_at = initial_updated_at - INTERVAL '1 day',
        review_notes = 'Approved after document quality review.'
    WHERE id = document_id;

    SELECT updated_at INTO updated_timestamp
    FROM iam.user_documents
    WHERE id = document_id;

    IF updated_timestamp <= initial_updated_at - INTERVAL '1 day' THEN
        RAISE EXCEPTION 'Expected user document updated_at trigger to refresh the timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-12 APPROVED: KYC documents, review integrity and timestamps validated.';
END;
$$;

ROLLBACK;
