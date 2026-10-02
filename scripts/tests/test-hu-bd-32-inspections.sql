BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    vehicle_id UUID;
    confirmed_status_id UUID;
    coverage_id UUID;
    mileage_plan_id UUID;
    branch_id UUID;
    active_contract_status_id UUID;
    reservation_id UUID;
    contract_id UUID;
    checkin_inspection_id UUID;
    checkout_inspection_id UUID;
    item_llantas_id UUID;
    item_luces_id UUID;
    item_carroceria_id UUID;
    item_espejos_id UUID;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';
    SELECT id INTO confirmed_status_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    SELECT id INTO coverage_id FROM catalog.insurance_coverages WHERE name = 'Basic Protection';
    SELECT id INTO mileage_plan_id FROM catalog.mileage_plans WHERE name = 'Standard 200 km';
    SELECT id INTO branch_id FROM location.branches WHERE name = 'Drivique Bogotá Centro';
    SELECT id INTO active_contract_status_id FROM contract.contract_statuses WHERE code = 'ACTIVE';

    SELECT id INTO item_llantas_id FROM contract.inspection_checklist_items WHERE name = 'Llantas';
    SELECT id INTO item_luces_id FROM contract.inspection_checklist_items WHERE name = 'Luces';
    SELECT id INTO item_carroceria_id FROM contract.inspection_checklist_items WHERE name = 'Carrocería';
    SELECT id INTO item_espejos_id FROM contract.inspection_checklist_items WHERE name = 'Espejos';

    IF admin_user_id IS NULL OR vehicle_id IS NULL OR confirmed_status_id IS NULL
       OR coverage_id IS NULL OR mileage_plan_id IS NULL OR branch_id IS NULL
       OR active_contract_status_id IS NULL OR item_llantas_id IS NULL
       OR item_luces_id IS NULL OR item_carroceria_id IS NULL OR item_espejos_id IS NULL THEN
        RAISE EXCEPTION 'Expected prerequisite seeds for vehicle inspections test';
    END IF;

    -- 1. Create test reservation and contract
    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-INSP-001', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '80 days', CURRENT_TIMESTAMP + INTERVAL '85 days',
        200000.00, 1000000.00
    ) RETURNING id INTO reservation_id;

    INSERT INTO contract.rental_contracts (
        contract_number, reservation_id, customer_id, vehicle_id, status_id,
        pickup_branch_id, return_branch_id, scheduled_start_at, scheduled_end_at,
        base_amount, security_deposit
    ) VALUES (
        'CTR-INSP-001', reservation_id, admin_user_id, vehicle_id, active_contract_status_id,
        branch_id, branch_id, CURRENT_TIMESTAMP + INTERVAL '80 days', CURRENT_TIMESTAMP + INTERVAL '85 days',
        1000000.00, 400000.00
    ) RETURNING id INTO contract_id;

    -- 2. Insert CHECK_IN vehicle inspection
    INSERT INTO contract.vehicle_inspections (
        contract_id, inspection_type, inspector_user_id, mileage, fuel_level_percent, observations
    ) VALUES (
        contract_id, 'CHECK_IN', admin_user_id, 45000, 100.00, 'Vehículo entregado en perfecto estado'
    ) RETURNING id INTO checkin_inspection_id;

    -- 3. Insert checklist answers for CHECK_IN
    INSERT INTO contract.inspection_checklist_answers (
        inspection_id, checklist_item_id, is_compliant, observation, evidence_photo_url
    ) VALUES
        (checkin_inspection_id, item_llantas_id, TRUE, 'Labrado en 80%', 'https://s3.amazonaws.com/drivique/inspections/llantas-in.jpg'),
        (checkin_inspection_id, item_luces_id, TRUE, 'Todas operativas', NULL),
        (checkin_inspection_id, item_carroceria_id, TRUE, 'Sin rayones visibles', 'https://s3.amazonaws.com/drivique/inspections/body-in.jpg'),
        (checkin_inspection_id, item_espejos_id, TRUE, 'Espejos limpios y ajustados', NULL);

    -- 4. Insert CHECK_OUT vehicle inspection
    INSERT INTO contract.vehicle_inspections (
        contract_id, inspection_type, inspector_user_id, mileage, fuel_level_percent, observations
    ) VALUES (
        contract_id, 'CHECK_OUT', admin_user_id, 45850, 95.50, 'Vehículo recibido de vuelta conforme'
    ) RETURNING id INTO checkout_inspection_id;

    -- 5. Insert checklist answers for CHECK_OUT
    INSERT INTO contract.inspection_checklist_answers (
        inspection_id, checklist_item_id, is_compliant, observation
    ) VALUES
        (checkout_inspection_id, item_llantas_id, TRUE, 'Desgaste normal'),
        (checkout_inspection_id, item_luces_id, TRUE, 'Operativas'),
        (checkout_inspection_id, item_carroceria_id, FALSE, 'Pequeño raspón en puerta trasera'),
        (checkout_inspection_id, item_espejos_id, TRUE, 'En buen estado');

    -- 6. Test UNIQUE constraint (contract_id, inspection_type): duplicate CHECK_IN fails
    BEGIN
        INSERT INTO contract.vehicle_inspections (
            contract_id, inspection_type, inspector_user_id, mileage, fuel_level_percent
        ) VALUES (
            contract_id, 'CHECK_IN', admin_user_id, 45100, 100.00
        );
        RAISE EXCEPTION 'Expected unique violation for duplicate (contract_id, inspection_type)';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 7. Test UNIQUE constraint (inspection_id, checklist_item_id): duplicate answer fails
    BEGIN
        INSERT INTO contract.inspection_checklist_answers (
            inspection_id, checklist_item_id, is_compliant
        ) VALUES (
            checkin_inspection_id, item_llantas_id, TRUE
        );
        RAISE EXCEPTION 'Expected unique violation for duplicate (inspection_id, checklist_item_id)';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 8. Test CHECK constraint: invalid inspection_type
    BEGIN
        INSERT INTO contract.vehicle_inspections (
            contract_id, inspection_type, inspector_user_id, mileage, fuel_level_percent
        ) VALUES (
            contract_id, 'MID_TERM', admin_user_id, 45500, 50.00
        );
        RAISE EXCEPTION 'Expected check violation for invalid inspection_type';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 9. Test CHECK constraint: negative mileage
    BEGIN
        INSERT INTO contract.vehicle_inspections (
            contract_id, inspection_type, inspector_user_id, mileage, fuel_level_percent
        ) VALUES (
            contract_id, 'CHECK_OUT', admin_user_id, -50, 50.00
        );
        RAISE EXCEPTION 'Expected check violation for negative mileage';
    EXCEPTION WHEN check_violation OR unique_violation THEN NULL;
    END;

    -- 10. Test CHECK constraint: fuel_level_percent > 100
    BEGIN
        INSERT INTO contract.vehicle_inspections (
            contract_id, inspection_type, inspector_user_id, mileage, fuel_level_percent
        ) VALUES (
            contract_id, 'CHECK_OUT', admin_user_id, 46000, 105.00
        );
        RAISE EXCEPTION 'Expected check violation for fuel_level_percent > 100';
    EXCEPTION WHEN check_violation OR unique_violation THEN NULL;
    END;

    -- 11. Test ON DELETE CASCADE from contract
    DELETE FROM contract.rental_contracts WHERE id = contract_id;

    IF EXISTS (
        SELECT 1 FROM contract.vehicle_inspections WHERE contract_id = contract_id
    ) OR EXISTS (
        SELECT 1 FROM contract.inspection_checklist_answers WHERE inspection_id = checkin_inspection_id
    ) THEN
        RAISE EXCEPTION 'Expected vehicle inspections and answers to be deleted when contract is deleted';
    END IF;

    RAISE NOTICE 'HU-BD-32 APPROVED: vehicle inspections, checklist items, answers, unique constraints and fuel bounds validated.';
END;
$$;

ROLLBACK;
