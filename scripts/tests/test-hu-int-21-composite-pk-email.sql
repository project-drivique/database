-- ============================================================================
-- DRIVIQUE DATABASE TEST SCRIPT
-- Story: HU-INT-21 (Primary Key Compuesta con Email en iam.users)
-- Description: Verifica que la clave primaria de iam.users esté compuesta por
--              (id, email), que la restricción única uq_users_id exista,
--              que las 33 Foreign Keys hacia iam.users sigan activas e intactas,
--              y que las operaciones DML funcionen correctamente.
-- ============================================================================

BEGIN;

DO $$
DECLARE
    v_pk_cols TEXT[];
    v_uq_id_count INT;
    v_fk_count INT;
    v_test_user_id UUID;
    v_test_email TEXT := 'hu21_test_pk@drivique.com';
    v_pref_count INT;
BEGIN
    -- 1. Validar que la clave primaria de iam.users contenga exactamente (id, email)
    SELECT array_agg(a.attname ORDER BY array_position(c.conkey, a.attnum))
    INTO v_pk_cols
    FROM pg_constraint c
    JOIN pg_class t ON c.conrelid = t.oid
    JOIN pg_namespace n ON t.relnamespace = n.oid
    JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(c.conkey)
    WHERE n.nspname = 'iam' AND t.relname = 'users' AND c.contype = 'p';

    IF v_pk_cols IS NULL OR v_pk_cols <> ARRAY['id', 'email'] THEN
        RAISE EXCEPTION 'Fallo en aserción: La clave primaria de iam.users debe ser (id, email). Actual: %', v_pk_cols;
    END IF;

    -- 2. Validar que la restricción UNIQUE uq_users_id exista en iam.users(id)
    SELECT COUNT(*)
    INTO v_uq_id_count
    FROM pg_constraint c
    JOIN pg_class t ON c.conrelid = t.oid
    JOIN pg_namespace n ON t.relnamespace = n.oid
    WHERE n.nspname = 'iam' AND t.relname = 'users' AND c.conname = 'uq_users_id' AND c.contype = 'u';

    IF v_uq_id_count <> 1 THEN
        RAISE EXCEPTION 'Fallo en aserción: No se encontró la restricción uq_users_id en iam.users';
    END IF;

    -- 3. Validar que las 33 Foreign Keys hijas que referencian a iam.users sigan existiendo
    SELECT count(*)
    INTO v_fk_count
    FROM pg_constraint
    WHERE confrelid = 'iam.users'::regclass AND contype = 'f';

    IF v_fk_count <> 33 THEN
        RAISE EXCEPTION 'Fallo en aserción: Se esperaban 33 Foreign Keys referenciando a iam.users, pero se encontraron: %', v_fk_count;
    END IF;

    -- 4. Validar inserción de usuario con PK compuesta
    INSERT INTO iam.users (first_name, last_name, email, password_hash)
    VALUES ('HU21', 'Tester', v_test_email, '$2a$12$hashedPassword')
    RETURNING id INTO v_test_user_id;

    IF v_test_user_id IS NULL THEN
        RAISE EXCEPTION 'Fallo en aserción: No se pudo obtener el id del usuario insertado';
    END IF;

    -- 5. Validar que una tabla hija pueda referenciar al usuario mediante id
    INSERT INTO iam.user_preferences (user_id, theme_preference, email_notifications, sms_notifications)
    VALUES (v_test_user_id, 'SYSTEM', true, false);

    SELECT count(*) INTO v_pref_count FROM iam.user_preferences WHERE user_id = v_test_user_id;
    IF v_pref_count <> 1 THEN
        RAISE EXCEPTION 'Fallo en aserción: No se pudo insertar en la tabla hija iam.user_preferences';
    END IF;

    -- 6. Validar eliminación en cascada de la tabla hija
    DELETE FROM iam.users WHERE id = v_test_user_id;

    SELECT count(*) INTO v_pref_count FROM iam.user_preferences WHERE user_id = v_test_user_id;
    IF v_pref_count <> 0 THEN
        RAISE EXCEPTION 'Fallo en aserción: La eliminación en cascada de user_preferences falló';
    END IF;

    RAISE NOTICE 'HU-INT-21: Todas las aserciones de Primary Key compuesta y relaciones foraneas pasaron exitosamente.';
END $$;

COMMIT;
