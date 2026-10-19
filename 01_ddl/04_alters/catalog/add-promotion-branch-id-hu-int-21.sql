-- HU-INT-21: Agregar relación de sucursal a las promociones para delegar CRUD a encargados de sucursal
ALTER TABLE catalog.promotions ADD COLUMN IF NOT EXISTS branch_id UUID REFERENCES location.branches(id);
GRANT SELECT, INSERT, UPDATE, DELETE ON catalog.promotions TO drivique_app;
