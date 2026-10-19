-- Vuelve a las fotos y datos originales de la flota inicial.

UPDATE fleet.vehicles SET color = 'Blanco Perla', year = 2024, main_image_url = 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7' WHERE plate = 'ABC-123';
DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'ABC-123');
INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7', TRUE, 1::SMALLINT),
        ('https://images.unsplash.com/photo-1549399542-7e3f8b79c341', FALSE, 2::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'ABC-123';

UPDATE fleet.vehicles SET color = 'Gris Estrella', year = 2023, main_image_url = 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d' WHERE plate = 'DEF-456';
DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'DEF-456');
INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://images.unsplash.com/photo-1541899481282-d53bffe3c35d', TRUE, 1::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'DEF-456';

UPDATE fleet.vehicles SET color = 'Rojo Diamante', year = 2024, main_image_url = 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf' WHERE plate = 'GHI-789';
DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'GHI-789');
INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://images.unsplash.com/photo-1533473359331-0135ef1b58bf', TRUE, 1::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'GHI-789';

UPDATE fleet.vehicles SET color = 'Negro Ébano', year = 2023, main_image_url = 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d' WHERE plate = 'JKL-012';
DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'JKL-012');
INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://images.unsplash.com/photo-1552519507-da3b142c6e3d', TRUE, 1::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'JKL-012';

UPDATE fleet.vehicles SET color = 'Plata Metálico', year = 2024, main_image_url = 'https://images.unsplash.com/photo-1559416523-140ddc3d238c' WHERE plate = 'MNO-345';
DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'MNO-345');
INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://images.unsplash.com/photo-1559416523-140ddc3d238c', TRUE, 1::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'MNO-345';

UPDATE fleet.vehicles SET color = 'Azul Portimao', year = 2024, main_image_url = 'https://images.unsplash.com/photo-1555215695-3004980ad54e' WHERE plate = 'PQR-678';
DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'PQR-678');
INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://images.unsplash.com/photo-1555215695-3004980ad54e', TRUE, 1::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'PQR-678';
