ALTER TABLE catalog.promotions
    ADD COLUMN name VARCHAR(120),
    ADD COLUMN conditions TEXT,
    ADD COLUMN minimum_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    ADD COLUMN vehicle_category_id UUID REFERENCES fleet.vehicle_categories (id),
    ADD COLUMN vehicle_id UUID REFERENCES fleet.vehicles (id),
    ADD COLUMN audience VARCHAR(20) NOT NULL DEFAULT 'ALL',
    ADD COLUMN is_featured BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE catalog.promotions
    ADD CONSTRAINT chk_promotions_audience CHECK (audience IN ('ALL', 'NEW', 'FREQUENT')),
    ADD CONSTRAINT chk_promotions_minimum_amount CHECK (minimum_amount >= 0);
