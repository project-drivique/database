BEGIN;

DO $$
DECLARE
    initial_updated_at TIMESTAMPTZ;
    updated_timestamp TIMESTAMPTZ;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM core.brand_configurations
        WHERE company_name = 'Drivique'
          AND primary_color = '#2563EB'
          AND secondary_color = '#1E3A8A'
          AND accent_color = '#60A5FA'
          AND default_theme = 'SYSTEM'
          AND is_active
    ) THEN
        RAISE EXCEPTION 'Expected the official Drivique brand configuration seed';
    END IF;

    BEGIN
        INSERT INTO core.brand_configurations (
            company_name, primary_color, secondary_color, accent_color, is_active
        ) VALUES (
            'Invalid hex', '2563EB', '#1E3A8A', '#60A5FA', FALSE
        );
        RAISE EXCEPTION 'Expected malformed HEX color to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO core.brand_configurations (
            company_name, primary_color, secondary_color, accent_color, default_theme, is_active
        ) VALUES (
            'Invalid theme', '#0F172A', '#334155', '#38BDF8', 'BLUE', FALSE
        );
        RAISE EXCEPTION 'Expected invalid default theme to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO core.brand_configurations (
            company_name, primary_color, secondary_color, accent_color, is_active
        ) VALUES (
            'Second active brand', '#0F172A', '#334155', '#38BDF8', TRUE
        );
        RAISE EXCEPTION 'Expected a second active brand configuration to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    INSERT INTO core.brand_configurations (
        company_name, primary_color, secondary_color, accent_color, is_active
    ) VALUES (
        'Historical brand', '#0F172A', '#334155', '#38BDF8', FALSE
    );

    SELECT updated_at INTO initial_updated_at
    FROM core.brand_configurations
    WHERE company_name = 'Drivique';

    UPDATE core.brand_configurations
    SET updated_at = initial_updated_at - INTERVAL '1 day',
        favicon_url = 'https://assets.drivique.test/favicon.ico'
    WHERE company_name = 'Drivique';

    SELECT updated_at INTO updated_timestamp
    FROM core.brand_configurations
    WHERE company_name = 'Drivique';

    IF updated_timestamp <= initial_updated_at - INTERVAL '1 day' THEN
        RAISE EXCEPTION 'Expected updated_at trigger to refresh the timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-04 APPROVED: brand configuration, validations, active uniqueness and timestamps validated.';
END;
$$;

ROLLBACK;
