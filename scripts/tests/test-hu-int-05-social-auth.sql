-- ==============================================================================
-- Test Script: HU-INT-05 - Inicio de sesión social seguro con Google y Facebook
-- ==============================================================================

BEGIN;

DO $$
DECLARE
    test_user_id UUID;
    test_social_id UUID;
    duplicate_failed BOOLEAN := FALSE;
    invalid_provider_failed BOOLEAN := FALSE;
BEGIN
    RAISE NOTICE 'Iniciando pruebas de HU-INT-05 (iam.user_social_accounts)...';

    -- 1. Crear usuario de prueba
    INSERT INTO iam.users (
        first_name, last_name, email, password_hash, account_status, is_profile_complete
    ) VALUES (
        'Social', 'Tester', 'social.tester@drivique.com', '$2a$12$e8r0.unusable.hash.for.oauth', 'ACTIVE', TRUE
    ) RETURNING id INTO test_user_id;

    -- 2. Vincular cuenta de Google
    INSERT INTO iam.user_social_accounts (
        user_id, provider, provider_user_id, email
    ) VALUES (
        test_user_id, 'GOOGLE', 'google-uid-100200300', 'social.tester@drivique.com'
    ) RETURNING id INTO test_social_id;

    ASSERT test_social_id IS NOT NULL, 'Error: No se insertó la cuenta social de Google.';

    -- 3. Vincular cuenta de Facebook para el mismo usuario
    INSERT INTO iam.user_social_accounts (
        user_id, provider, provider_user_id, email
    ) VALUES (
        test_user_id, 'FACEBOOK', 'fb-uid-400500600', 'social.tester@drivique.com'
    );

    -- 4. Validar unicidad de (provider, provider_user_id)
    BEGIN
        INSERT INTO iam.user_social_accounts (
            user_id, provider, provider_user_id, email
        ) VALUES (
            test_user_id, 'GOOGLE', 'google-uid-100200300', 'other@drivique.com'
        );
    EXCEPTION WHEN unique_violation THEN
        duplicate_failed := TRUE;
    END;

    ASSERT duplicate_failed, 'Error: Permitió duplicar provider + provider_user_id.';

    -- 5. Validar check constraint de proveedor permitido
    BEGIN
        INSERT INTO iam.user_social_accounts (
            user_id, provider, provider_user_id, email
        ) VALUES (
            test_user_id, 'TWITTER', 'tw-123', 'twitter@drivique.com'
        );
    EXCEPTION WHEN check_violation THEN
        invalid_provider_failed := TRUE;
    END;

    ASSERT invalid_provider_failed, 'Error: Permitió un proveedor no soportado.';

    RAISE NOTICE 'Pruebas de HU-INT-05 finalizadas exitosamente.';
END $$;

ROLLBACK;
