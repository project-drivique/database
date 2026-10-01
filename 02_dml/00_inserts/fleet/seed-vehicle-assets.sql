-- Seed vehicle images for initial fleet
INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, img.url, img.is_primary, img.sort_order::SMALLINT
FROM (
    VALUES
        ('ABC-123', 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7', TRUE, 1),
        ('ABC-123', 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341', FALSE, 2),
        ('DEF-456', 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d', TRUE, 1),
        ('GHI-789', 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf', TRUE, 1),
        ('JKL-012', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d', TRUE, 1),
        ('MNO-345', 'https://images.unsplash.com/photo-1559416523-140ddc3d238c', TRUE, 1),
        ('PQR-678', 'https://images.unsplash.com/photo-1555215695-3004980ad54e', TRUE, 1)
) AS img(plate, url, is_primary, sort_order)
JOIN fleet.vehicles v ON v.plate = img.plate;

-- Seed vehicle documents (SOAT and TECHNICAL_INSPECTION)
INSERT INTO fleet.vehicle_documents (vehicle_id, document_type, document_number, file_url, issued_at, expires_at, is_active)
SELECT v.id, doc.doc_type, doc.doc_num, doc.file_url, doc.issued_at::DATE, doc.expires_at::DATE, TRUE
FROM (
    VALUES
        ('ABC-123', 'SOAT', 'SOAT-2024-001', 'https://documents.drivique.com/soat/ABC123-2024.pdf', '2024-01-01', '2025-01-01'),
        ('ABC-123', 'TECHNICAL_INSPECTION', 'RTM-2024-001', 'https://documents.drivique.com/rtm/ABC123-2024.pdf', '2024-01-01', '2025-01-01'),
        ('DEF-456', 'SOAT', 'SOAT-2024-002', 'https://documents.drivique.com/soat/DEF456-2024.pdf', '2024-02-01', '2025-02-01'),
        ('GHI-789', 'SOAT', 'SOAT-2024-003', 'https://documents.drivique.com/soat/GHI789-2024.pdf', '2024-03-01', '2025-03-01'),
        ('JKL-012', 'SOAT', 'SOAT-2024-004', 'https://documents.drivique.com/soat/JKL012-2024.pdf', '2024-01-15', '2025-01-15'),
        ('MNO-345', 'SOAT', 'SOAT-2024-005', 'https://documents.drivique.com/soat/MNO345-2024.pdf', '2024-04-01', '2025-04-01'),
        ('PQR-678', 'SOAT', 'SOAT-2024-006', 'https://documents.drivique.com/soat/PQR678-2024.pdf', '2024-05-01', '2025-05-01')
) AS doc(plate, doc_type, doc_num, file_url, issued_at, expires_at)
JOIN fleet.vehicles v ON v.plate = doc.plate;
