CREATE TABLE core.brand_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(100) NOT NULL,
    logo_url VARCHAR(2048),
    favicon_url VARCHAR(2048),
    primary_color VARCHAR(7) NOT NULL,
    secondary_color VARCHAR(7) NOT NULL,
    accent_color VARCHAR(7) NOT NULL,
    default_theme VARCHAR(10) NOT NULL DEFAULT 'SYSTEM',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_brand_configurations_primary_color_hex
        CHECK (primary_color ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_brand_configurations_secondary_color_hex
        CHECK (secondary_color ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_brand_configurations_accent_color_hex
        CHECK (accent_color ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_brand_configurations_distinct_colors
        CHECK (
            primary_color <> secondary_color
            AND primary_color <> accent_color
            AND secondary_color <> accent_color
        ),
    CONSTRAINT chk_brand_configurations_default_theme
        CHECK (default_theme IN ('LIGHT', 'DARK', 'SYSTEM'))
);
