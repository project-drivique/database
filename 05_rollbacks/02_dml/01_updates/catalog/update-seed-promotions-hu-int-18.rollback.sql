UPDATE catalog.promotions SET name = NULL, conditions = NULL, minimum_amount = 0, is_featured = FALSE, vehicle_category_id = NULL
WHERE code IN ('BIENVENIDO10', 'DRIVIQUE50K', 'SUV20');
