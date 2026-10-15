UPDATE catalog.promotions SET
    name = 'Cupón de Bienvenida Drivique',
    conditions = 'Válido para cualquier categoría de vehículo en todas las sucursales de Colombia.',
    is_featured = TRUE
WHERE code = 'BIENVENIDO10' AND name IS NULL;

UPDATE catalog.promotions SET
    name = 'Bono Fijo de Alquiler',
    conditions = 'Bono directo de $50.000 COP aplicable a reservas superiores a $200.000 COP.',
    minimum_amount = 200000
WHERE code = 'DRIVIQUE50K' AND name IS NULL;

UPDATE catalog.promotions SET
    name = 'Especial Aventura SUV',
    conditions = 'Descuento del 20% en vehículos de la categoría SUV.',
    is_featured = TRUE,
    vehicle_category_id = (SELECT id FROM fleet.vehicle_categories WHERE name = 'SUV')
WHERE code = 'SUV20' AND name IS NULL;
