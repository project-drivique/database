CREATE TABLE IF NOT EXISTS location.branch_categories (
    branch_id UUID NOT NULL,
    category_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_branch_categories PRIMARY KEY (branch_id, category_id),
    CONSTRAINT fk_branch_categories_branch FOREIGN KEY (branch_id) REFERENCES location.branches (id),
    CONSTRAINT fk_branch_categories_category FOREIGN KEY (category_id) REFERENCES fleet.vehicle_categories (id)
);

CREATE INDEX IF NOT EXISTS idx_branch_categories_category ON location.branch_categories (category_id);

-- Cada sucursal ofrece inicialmente todas las categorías activas; el encargado puede deshabilitarlas.
INSERT INTO location.branch_categories (branch_id, category_id)
SELECT b.id, c.id
FROM location.branches b
CROSS JOIN fleet.vehicle_categories c
WHERE c.is_active = TRUE
ON CONFLICT DO NOTHING;
