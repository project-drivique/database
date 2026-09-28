CREATE UNIQUE INDEX uq_brand_configurations_one_active
    ON core.brand_configurations (is_active)
    WHERE is_active;
