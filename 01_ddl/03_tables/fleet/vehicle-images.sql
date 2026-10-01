CREATE TABLE fleet.vehicle_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL,
    url VARCHAR(1000) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order SMALLINT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_images_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE,
    CONSTRAINT uq_vehicle_images_vehicle_sort_order UNIQUE (vehicle_id, sort_order),
    CONSTRAINT chk_vehicle_images_url_not_blank CHECK (btrim(url) <> ''),
    CONSTRAINT chk_vehicle_images_sort_order CHECK (sort_order > 0)
);
