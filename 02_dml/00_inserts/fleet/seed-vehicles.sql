INSERT INTO fleet.vehicles (
    plate,
    vin,
    brand_id,
    category_id,
    transmission_type_id,
    fuel_type_id,
    status_id,
    current_branch_id,
    model,
    year,
    color,
    passenger_capacity,
    doors_count,
    trunk_capacity_liters,
    mileage,
    daily_rate,
    main_image_url,
    is_featured,
    is_active
)
SELECT
    v.plate,
    v.vin,
    b.id,
    c.id,
    t.id,
    f.id,
    s.id,
    br.id,
    v.model,
    v.year,
    v.color,
    v.passenger_capacity,
    v.doors_count,
    v.trunk_capacity_liters,
    v.mileage,
    v.daily_rate,
    v.main_image_url,
    v.is_featured,
    v.is_active
FROM (
    VALUES
        ('ABC-123', '1HGCR2F83HA000001', 'Toyota', 'SUV', 'AUTOMATIC', 'HYBRID', 'AVAILABLE', 'Drivique Bogotá Centro', 'RAV4 Hybrid Limited', 2024::SMALLINT, 'Blanco Perla', 5::SMALLINT, 5::SMALLINT, 580, 15000, 220000.00, 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7', TRUE, TRUE),
        ('DEF-456', '2T1BURHE5HC000002', 'Renault', 'Sedán', 'MANUAL', 'GASOLINE', 'AVAILABLE', 'Drivique Bogotá Centro', 'Logan Intens', 2023::SMALLINT, 'Gris Estrella', 5::SMALLINT, 4::SMALLINT, 510, 28000, 120000.00, 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d', FALSE, TRUE),
        ('GHI-789', '3VW2K7AJ4EM000003', 'Mazda', 'SUV', 'AUTOMATIC', 'GASOLINE', 'AVAILABLE', 'Drivique Medellín Centro', 'CX-5 Grand Touring', 2024::SMALLINT, 'Rojo Diamante', 5::SMALLINT, 5::SMALLINT, 506, 12000, 240000.00, 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf', TRUE, TRUE),
        ('JKL-012', '4T1B11HK8JU000004', 'Chevrolet', 'Hatchback', 'MANUAL', 'GASOLINE', 'AVAILABLE', 'Drivique Medellín Aeropuerto', 'Onix RS', 2023::SMALLINT, 'Negro Ébano', 5::SMALLINT, 5::SMALLINT, 385, 34000, 110000.00, 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d', FALSE, TRUE),
        ('MNO-345', '5N1AL0MM8KC000005', 'Toyota', 'Camioneta', 'AUTOMATIC', 'DIESEL', 'AVAILABLE', 'Drivique Cali Centro', 'Hilux SRV 4x4', 2024::SMALLINT, 'Plata Metálico', 5::SMALLINT, 4::SMALLINT, 1000, 18000, 320000.00, 'https://images.unsplash.com/photo-1559416523-140ddc3d238c', TRUE, TRUE),
        ('PQR-678', 'WBA3A5C58DF000006', 'BMW', 'Lujo', 'AUTOMATIC', 'GASOLINE', 'AVAILABLE', 'Drivique Bogotá Centro', 'Serie 3 330i M Sport', 2024::SMALLINT, 'Azul Portimao', 5::SMALLINT, 4::SMALLINT, 480, 8500, 450000.00, 'https://images.unsplash.com/photo-1555215695-3004980ad54e', TRUE, TRUE)
) AS v(plate, vin, brand_name, category_name, trans_code, fuel_code, status_code, branch_name, model, year, color, passenger_capacity, doors_count, trunk_capacity_liters, mileage, daily_rate, main_image_url, is_featured, is_active)
JOIN fleet.vehicle_brands b ON b.name = v.brand_name
JOIN fleet.vehicle_categories c ON c.name = v.category_name
JOIN fleet.transmission_types t ON t.code = v.trans_code
JOIN fleet.fuel_types f ON f.code = v.fuel_code
JOIN fleet.vehicle_statuses s ON s.code = v.status_code
JOIN location.branches br ON br.name = v.branch_name;
