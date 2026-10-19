-- Fotos (hasta 8 URLs por vehículo) y datos de los vehículos de la flota inicial, tal como los dejó el encargado.
-- La primera foto es la principal (main_image_url) y el resto forma la galería del catálogo.

-- ABC-123
UPDATE fleet.vehicles
SET color = 'Plateado', year = 2024, main_image_url = 'https://http2.mlstatic.com/D_NQ_NP_2X_924725-MCO116408874024_092026-F.webp'
WHERE plate = 'ABC-123';

DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'ABC-123');

INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://http2.mlstatic.com/D_NQ_NP_2X_924725-MCO116408874024_092026-F.webp', TRUE, 1::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_664399-MCO117817185497_092026-F.webp', FALSE, 2::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_781855-MCO117817531485_092026-F.webp', FALSE, 3::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_671072-MCO117816406171_092026-F.webp', FALSE, 4::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_990900-MCO117815783979_092026-F.webp', FALSE, 5::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_605071-MCO117817740061_092026-F.webp', FALSE, 6::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_868597-MCO116321467064_092026-F.webp', FALSE, 7::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_816434-MCO116320960786_092026-F.webp', FALSE, 8::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'ABC-123';

-- DEF-456
UPDATE fleet.vehicles
SET color = 'Gris Estrella', year = 2023, main_image_url = 'https://cdn.group.renault.com/ren/co/vehicles/logan/home/logan-frontal.jpg.ximg.mediumx2.webp/f7ace6050d.webp'
WHERE plate = 'DEF-456';

DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'DEF-456');

INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://cdn.group.renault.com/ren/co/vehicles/logan/home/logan-frontal.jpg.ximg.mediumx2.webp/f7ace6050d.webp', TRUE, 1::SMALLINT),
        ('https://cdn.group.renault.com/ren/co/vehicles/logan/design/exterior/logan-baul.jpg.ximg.mediumx2.webp/15ee9dc388.webp', FALSE, 2::SMALLINT),
        ('https://cdn.group.renault.com/ren/co/vehicles/logan/design/exterior/logan-rin.jpg.ximg.mediumx2.webp/db387a9f58.webp', FALSE, 3::SMALLINT),
        ('https://cdn.group.renault.com/ren/co/vehicles/logan/home/logan-interior.jpg.ximg.mediumx2.webp/b3a2ebf5f7.webp', FALSE, 4::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'DEF-456';

-- GHI-789
UPDATE fleet.vehicles
SET color = 'Blanco Perla', year = 2024, main_image_url = 'https://http2.mlstatic.com/D_NQ_NP_2X_807462-MCO116605541634_092026-F.webp'
WHERE plate = 'GHI-789';

DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'GHI-789');

INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://http2.mlstatic.com/D_NQ_NP_2X_807462-MCO116605541634_092026-F.webp', TRUE, 1::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_821566-MCO116571018458_092026-F.webp', FALSE, 2::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_685724-MCO116571166410_092026-F.webp', FALSE, 3::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_712336-MCO116571136742_092026-F.webp', FALSE, 4::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_783851-MCO116571166436_092026-F.webp', FALSE, 5::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_815122-MCO116571166596_092026-F.webp', FALSE, 6::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_941693-MCO118080244187_092026-F.webp', FALSE, 7::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_600697-MCO116571137278_092026-F.webp', FALSE, 8::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'GHI-789';

-- JKL-012
UPDATE fleet.vehicles
SET color = 'Rojo Carmesí', year = 2026, main_image_url = 'https://images.dailyrevs.com/0000/v3/Chevrolet/699d8a504860039b71192769/2026-onix-rs-chevrolet-2tzarasst4c0bequziwnytr.jpeg'
WHERE plate = 'JKL-012';

DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'JKL-012');

INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://images.dailyrevs.com/0000/v3/Chevrolet/699d8a504860039b71192769/2026-onix-rs-chevrolet-2tzarasst4c0bequziwnytr.jpeg', TRUE, 1::SMALLINT),
        ('https://images.dailyrevs.com/0000/v3/Chevrolet/699d8a504860039b71192769/2026-onix-rs-chevrolet-2u1s43llm8o0elby22qv2rg.jpeg', FALSE, 2::SMALLINT),
        ('https://images.dailyrevs.com/0000/v3/Chevrolet/699d8a504860039b71192769/2026-onix-rs-chevrolet-2u2p47777oi022n3o5vnt4i.jpeg', FALSE, 3::SMALLINT),
        ('https://images.dailyrevs.com/0000/v3/Chevrolet/699d8a504860039b71192769/2026-onix-rs-chevrolet-2u8dhssst4c0ou6j2wf0q5.jpeg', FALSE, 4::SMALLINT),
        ('https://images.dailyrevs.com/0000/v3/Chevrolet/699d8a504860039b71192769/2026-onix-rs-chevrolet-2ubo3eeeek60tbx9bkvz0ka.jpeg', FALSE, 5::SMALLINT),
        ('https://images.dailyrevs.com/0000/v3/Chevrolet/699d8a504860039b71192769/2026-onix-rs-chevrolet-2ucr83llm8o0wl4vob0l9vi.jpeg', FALSE, 6::SMALLINT),
        ('https://images.dailyrevs.com/0000/v3/Chevrolet/699d8a504860039b71192769/2026-onix-rs-chevrolet-2ue63eeeek60f4jx80bkuzp.jpeg', FALSE, 7::SMALLINT),
        ('https://images.dailyrevs.com/0000/v3/Chevrolet/699d8a504860039b71192769/2026-onix-rs-chevrolet-2ug5l0sqsf322wad.jpeg', FALSE, 8::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'JKL-012';

-- MNO-345
UPDATE fleet.vehicles
SET color = 'Blanco Perla', year = 2024, main_image_url = 'https://http2.mlstatic.com/D_NQ_NP_2X_753252-MCO114076525204_072026-F.webp'
WHERE plate = 'MNO-345';

DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'MNO-345');

INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://http2.mlstatic.com/D_NQ_NP_2X_753252-MCO114076525204_072026-F.webp', TRUE, 1::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_687779-MCO114028478156_072026-F.webp', FALSE, 2::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_726139-MCO114029032306_072026-F.webp', FALSE, 3::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_724080-MCO114028361882_072026-F.webp', FALSE, 4::SMALLINT),
        ('https://http2.mlstatic.com/D_NQ_NP_2X_684857-MCO114028884122_072026-F.webp', FALSE, 5::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'MNO-345';

-- PQR-678
UPDATE fleet.vehicles
SET color = 'Blanco Perla', year = 2024, main_image_url = 'https://drive.gianhangvn.com/image/oz5etz3-2403939j32705.jpg'
WHERE plate = 'PQR-678';

DELETE FROM fleet.vehicle_images WHERE vehicle_id = (SELECT id FROM fleet.vehicles WHERE plate = 'PQR-678');

INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, i.url, i.is_primary, i.sort_order
FROM fleet.vehicles v,
    (VALUES
        ('https://drive.gianhangvn.com/image/oz5etz3-2403939j32705.jpg', TRUE, 1::SMALLINT),
        ('https://drive.gianhangvn.com/image/2t99tz0-2403940j32705.jpg', FALSE, 2::SMALLINT),
        ('https://drive.gianhangvn.com/image/bwiytz1-2403941j32705.jpg', FALSE, 3::SMALLINT),
        ('https://drive.gianhangvn.com/image/9689tz2-2403942j32705.jpg', FALSE, 4::SMALLINT),
        ('https://drive.gianhangvn.com/image/rgontz4-2403943j32705.jpg', FALSE, 5::SMALLINT),
        ('https://drive.gianhangvn.com/image/22wgtz5-2403944j32705.jpg', FALSE, 6::SMALLINT),
        ('https://drive.gianhangvn.com/image/rzibtz6-2403945j32705.jpg', FALSE, 7::SMALLINT)
    ) AS i(url, is_primary, sort_order)
WHERE v.plate = 'PQR-678';
