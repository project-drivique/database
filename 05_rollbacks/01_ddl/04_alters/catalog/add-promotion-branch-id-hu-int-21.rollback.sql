-- ROLLBACK HU-INT-21: quitar la sucursal de las promociones
ALTER TABLE catalog.promotions DROP COLUMN IF EXISTS branch_id;
