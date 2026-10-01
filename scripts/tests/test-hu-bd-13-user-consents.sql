BEGIN;

DO $$
DECLARE
    admin_id UUID;
    consent_id UUID;
    consent_ip INET;
BEGIN
    SELECT id INTO admin_id FROM iam.users WHERE email = 'admin@drivique.com';
    IF admin_id IS NULL THEN
        RAISE EXCEPTION 'Expected admin user seed';
    END IF;

    INSERT INTO iam.user_consents (
        user_id, consent_type, document_version, ip_address
    ) VALUES (
        admin_id, 'TERMS_AND_CONDITIONS', '2026-09', '2001:db8::1'
    ) RETURNING id, ip_address INTO consent_id, consent_ip;

    IF consent_ip <> '2001:db8::1'::INET THEN
        RAISE EXCEPTION 'Expected IPv6 address to persist as INET';
    END IF;

    BEGIN
        INSERT INTO iam.user_consents (
            user_id, consent_type, document_version, ip_address
        ) VALUES (
            admin_id, 'TERMS_AND_CONDITIONS', '2026-09', '127.0.0.1'
        );
        RAISE EXCEPTION 'Expected duplicated user consent version to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO iam.user_consents (
            user_id, consent_type, document_version, ip_address
        ) VALUES (
            admin_id, ' ', '2026-10', '127.0.0.1'
        );
        RAISE EXCEPTION 'Expected blank consent type to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        UPDATE iam.user_consents
        SET accepted_at = accepted_at + INTERVAL '1 minute'
        WHERE id = consent_id;
        RAISE EXCEPTION 'Expected user consent update to fail';
    EXCEPTION
        WHEN object_not_in_prerequisite_state THEN NULL;
    END;

    BEGIN
        DELETE FROM iam.user_consents WHERE id = consent_id;
        RAISE EXCEPTION 'Expected user consent delete to fail';
    EXCEPTION
        WHEN object_not_in_prerequisite_state THEN NULL;
    END;

    RAISE NOTICE 'HU-BD-13 APPROVED: legal consent uniqueness, IP traceability and immutability validated.';
END;
$$;

ROLLBACK;
