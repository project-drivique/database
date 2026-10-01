BEGIN;

DO $$
DECLARE
    v_id UUID;
    v_img_id UUID;
    v_doc_id UUID;
    v_updated_at TIMESTAMPTZ;
    brand_id UUID;
    cat_id UUID;
    trans_id UUID;
    fuel_id UUID;
    status_id UUID;
    branch_id UUID;
BEGIN
    IF (SELECT COUNT(*) FROM fleet.vehicle_images) < 7 THEN
        RAISE EXCEPTION 'Expected at least 7 seeded vehicle images';
    END IF;

    IF (SELECT COUNT(*) FROM fleet.vehicle_documents) < 7 THEN
        RAISE EXCEPTION 'Expected at least 7 seeded vehicle documents';
    END IF;

    SELECT id INTO v_id FROM fleet.vehicles WHERE plate = 'ABC-123' LIMIT 1;

    -- 1. Test duplicate sort_order for same vehicle
    BEGIN
        INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
        VALUES (v_id, 'https://images.unsplash.com/extra-photo', FALSE, 1);
        RAISE EXCEPTION 'Expected duplicate vehicle image sort_order to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 2. Test duplicate is_primary for same vehicle
    BEGIN
        INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
        VALUES (v_id, 'https://images.unsplash.com/extra-photo-2', TRUE, 10);
        RAISE EXCEPTION 'Expected multiple primary images for vehicle to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 3. Test invalid document type check constraint
    BEGIN
        INSERT INTO fleet.vehicle_documents (vehicle_id, document_type, document_number, file_url, issued_at, expires_at)
        VALUES (v_id, 'INVALID_TYPE', 'DOC-999', 'https://docs.drivique.com/doc.pdf', CURRENT_DATE, CURRENT_DATE + 30);
        RAISE EXCEPTION 'Expected invalid document_type check constraint to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 4. Test invalid dates check constraint (expires_at < issued_at)
    BEGIN
        INSERT INTO fleet.vehicle_documents (vehicle_id, document_type, document_number, file_url, issued_at, expires_at)
        VALUES (v_id, 'INSURANCE', 'POL-999', 'https://docs.drivique.com/pol.pdf', '2025-01-01', '2024-01-01');
        RAISE EXCEPTION 'Expected expires_at < issued_at check constraint to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 5. Test active document unique constraint (vehicle_id, document_type) where is_active
    BEGIN
        INSERT INTO fleet.vehicle_documents (vehicle_id, document_type, document_number, file_url, issued_at, expires_at, is_active)
        VALUES (v_id, 'SOAT', 'SOAT-DUP', 'https://docs.drivique.com/dup.pdf', CURRENT_DATE, CURRENT_DATE + 365, TRUE);
        RAISE EXCEPTION 'Expected duplicate active document type for vehicle to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 6. Test trigger updated_at on vehicle_documents
    INSERT INTO fleet.vehicle_documents (vehicle_id, document_type, document_number, file_url, issued_at, expires_at, is_active)
    VALUES (v_id, 'INSURANCE', 'POL-100', 'https://docs.drivique.com/pol100.pdf', '2024-01-01', '2025-01-01', TRUE)
    RETURNING id, updated_at INTO v_doc_id, v_updated_at;

    UPDATE fleet.vehicle_documents
    SET document_number = 'POL-100-UPDATED'
    WHERE id = v_doc_id;

    IF (SELECT updated_at FROM fleet.vehicle_documents WHERE id = v_doc_id) < v_updated_at THEN
        RAISE EXCEPTION 'Trigger failed to maintain valid updated_at timestamp';
    END IF;

    -- 7. Test cascade delete on vehicle
    SELECT b.id, c.id, t.id, f.id, s.id, br.id
    INTO brand_id, cat_id, trans_id, fuel_id, status_id, branch_id
    FROM fleet.vehicle_brands b, fleet.vehicle_categories c, fleet.transmission_types t, fleet.fuel_types f, fleet.vehicle_statuses s, location.branches br
    WHERE b.name = 'Toyota' AND c.name = 'SUV' AND t.code = 'AUTOMATIC' AND f.code = 'HYBRID' AND s.code = 'AVAILABLE' AND br.name = 'Drivique Bogotá Centro'
    LIMIT 1;

    INSERT INTO fleet.vehicles (
        plate, vin, brand_id, category_id, transmission_type_id, fuel_type_id, status_id, current_branch_id,
        model, year, passenger_capacity, daily_rate
    ) VALUES (
        'TMP-999', 'TMPVIN99999999999', brand_id, cat_id, trans_id, fuel_id, status_id, branch_id,
        'Temp Cascade Model', 2024, 5, 200000.00
    ) RETURNING id INTO v_id;

    INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
    VALUES (v_id, 'https://images.unsplash.com/temp-image', TRUE, 1);

    INSERT INTO fleet.vehicle_documents (vehicle_id, document_type, document_number, file_url, issued_at, expires_at)
    VALUES (v_id, 'SOAT', 'TEMP-SOAT', 'https://docs.drivique.com/temp.pdf', '2024-01-01', '2025-01-01');

    DELETE FROM fleet.vehicles WHERE id = v_id;

    IF EXISTS (SELECT 1 FROM fleet.vehicle_images WHERE vehicle_id = v_id) THEN
        RAISE EXCEPTION 'Expected cascade delete on vehicle_images to succeed';
    END IF;

    IF EXISTS (SELECT 1 FROM fleet.vehicle_documents WHERE vehicle_id = v_id) THEN
        RAISE EXCEPTION 'Expected cascade delete on vehicle_documents to succeed';
    END IF;

    RAISE NOTICE 'HU-BD-20 vehicle assets tests completed successfully';
END $$;

ROLLBACK;
