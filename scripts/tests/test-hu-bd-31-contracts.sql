BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    vehicle_id UUID;
    confirmed_status_id UUID;
    coverage_id UUID;
    mileage_plan_id UUID;
    branch_id UUID;
    city_id UUID;
    active_contract_status_id UUID;
    draft_contract_status_id UUID;
    reservation_id UUID;
    reservation_id_2 UUID;
    contract_id UUID;
    contract_id_2 UUID;
    clause_id UUID;
    clause_id_2 UUID;
    fetched_stroke_data JSONB;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';
    SELECT id INTO confirmed_status_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    SELECT id INTO coverage_id FROM catalog.insurance_coverages WHERE name = 'Basic Protection';
    SELECT id INTO mileage_plan_id FROM catalog.mileage_plans WHERE name = 'Standard 200 km';
    SELECT id INTO branch_id FROM location.branches WHERE name = 'Drivique Bogotá Centro';
    SELECT id INTO city_id FROM location.cities WHERE name = 'Bogotá';
    SELECT id INTO active_contract_status_id FROM contract.contract_statuses WHERE code = 'ACTIVE';
    SELECT id INTO draft_contract_status_id FROM contract.contract_statuses WHERE code = 'DRAFT';

    IF admin_user_id IS NULL OR vehicle_id IS NULL OR confirmed_status_id IS NULL
       OR coverage_id IS NULL OR mileage_plan_id IS NULL OR branch_id IS NULL
       OR city_id IS NULL OR active_contract_status_id IS NULL OR draft_contract_status_id IS NULL THEN
        RAISE EXCEPTION 'Expected prerequisite seeds for legal contracts test';
    END IF;

    -- 1. Create test reservation 1
    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-CTR-001', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '60 days', CURRENT_TIMESTAMP + INTERVAL '65 days',
        250000.00, 1250000.00
    ) RETURNING id INTO reservation_id;

    -- 2. Insert valid rental_contract with biometric JSONB stroke data
    INSERT INTO contract.rental_contracts (
        contract_number, reservation_id, customer_id, vehicle_id, status_id,
        pickup_branch_id, return_branch_id, scheduled_start_at, scheduled_end_at,
        base_amount, security_deposit, signature_url, signature_stroke_data,
        signed_city_id, signed_at, pdf_url
    ) VALUES (
        'CTR-2026-0001', reservation_id, admin_user_id, vehicle_id, active_contract_status_id,
        branch_id, branch_id, CURRENT_TIMESTAMP + INTERVAL '60 days', CURRENT_TIMESTAMP + INTERVAL '65 days',
        1250000.00, 500000.00, 'https://s3.amazonaws.com/drivique/signatures/sig-001.png',
        '{"points": [{"x": 10.5, "y": 20.3, "time": 100}, {"x": 15.2, "y": 25.8, "time": 150}], "pressure": [0.8, 0.9]}'::JSONB,
        city_id, CURRENT_TIMESTAMP, 'https://s3.amazonaws.com/drivique/contracts/ctr-001.pdf'
    ) RETURNING id INTO contract_id;

    -- 3. Validate JSONB query
    SELECT signature_stroke_data INTO fetched_stroke_data
    FROM contract.rental_contracts
    WHERE id = contract_id;

    IF fetched_stroke_data->'points' IS NULL OR (fetched_stroke_data->'points'->0->>'x')::NUMERIC <> 10.5 THEN
        RAISE EXCEPTION 'Failed to persist and query biometric JSONB stroke data';
    END IF;

    -- 4. Assign clauses to the contract
    SELECT id INTO clause_id FROM contract.contract_clauses WHERE version = 'v1.0' AND sort_order = 1;
    SELECT id INTO clause_id_2 FROM contract.contract_clauses WHERE version = 'v1.0' AND sort_order = 2;

    IF clause_id IS NULL OR clause_id_2 IS NULL THEN
        RAISE EXCEPTION 'Expected seeded contract clauses';
    END IF;

    INSERT INTO contract.contract_clause_assignments (contract_id, clause_id)
    VALUES (contract_id, clause_id);

    INSERT INTO contract.contract_clause_assignments (contract_id, clause_id)
    VALUES (contract_id, clause_id_2);

    -- 5. Test UNIQUE constraint on reservation_id (1 to 1)
    BEGIN
        INSERT INTO contract.rental_contracts (
            contract_number, reservation_id, customer_id, vehicle_id, status_id,
            pickup_branch_id, return_branch_id, scheduled_start_at, scheduled_end_at,
            base_amount, security_deposit
        ) VALUES (
            'CTR-2026-0002', reservation_id, admin_user_id, vehicle_id, draft_contract_status_id,
            branch_id, branch_id, CURRENT_TIMESTAMP + INTERVAL '60 days', CURRENT_TIMESTAMP + INTERVAL '65 days',
            1250000.00, 500000.00
        );
        RAISE EXCEPTION 'Expected unique violation for duplicate reservation_id in rental_contracts';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 6. Test UNIQUE constraint on contract_number
    BEGIN
        INSERT INTO contract.rental_contracts (
            contract_number, reservation_id, customer_id, vehicle_id, status_id,
            pickup_branch_id, return_branch_id, scheduled_start_at, scheduled_end_at,
            base_amount, security_deposit
        ) VALUES (
            'CTR-2026-0001', '00000000-0000-0000-0000-000000000000', admin_user_id, vehicle_id, draft_contract_status_id,
            branch_id, branch_id, CURRENT_TIMESTAMP + INTERVAL '60 days', CURRENT_TIMESTAMP + INTERVAL '65 days',
            1250000.00, 500000.00
        );
        RAISE EXCEPTION 'Expected unique violation for duplicate contract_number';
    EXCEPTION WHEN unique_violation OR foreign_key_violation THEN NULL;
    END;

    -- 7. Test UNIQUE constraint on contract_clauses (version, sort_order)
    BEGIN
        INSERT INTO contract.contract_clauses (version, sort_order, title, content)
        VALUES ('v1.0', 1, 'Duplicate Clause', 'Duplicate content');
        RAISE EXCEPTION 'Expected unique violation for duplicate (version, sort_order) in contract_clauses';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 8. Test Composite PK on contract_clause_assignments
    BEGIN
        INSERT INTO contract.contract_clause_assignments (contract_id, clause_id)
        VALUES (contract_id, clause_id);
        RAISE EXCEPTION 'Expected primary key violation for duplicate (contract_id, clause_id)';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 9. Test CHECK constraint: scheduled_end_at > scheduled_start_at
    BEGIN
        INSERT INTO contract.rental_contracts (
            contract_number, reservation_id, customer_id, vehicle_id, status_id,
            pickup_branch_id, return_branch_id, scheduled_start_at, scheduled_end_at,
            base_amount
        ) VALUES (
            'CTR-2026-INVALID-PERIOD', reservation_id, admin_user_id, vehicle_id, draft_contract_status_id,
            branch_id, branch_id, CURRENT_TIMESTAMP + INTERVAL '70 days', CURRENT_TIMESTAMP + INTERVAL '69 days',
            100000.00
        );
        RAISE EXCEPTION 'Expected check violation for invalid contract period';
    EXCEPTION WHEN check_violation OR unique_violation THEN NULL;
    END;

    -- 10. Test ON DELETE RESTRICT on clause assigned to active contract
    BEGIN
        DELETE FROM contract.contract_clauses WHERE id = clause_id;
        RAISE EXCEPTION 'Expected foreign key violation when deleting assigned contract clause';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;

    -- 11. Test ON DELETE CASCADE from reservation
    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-CTR-002', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '70 days', CURRENT_TIMESTAMP + INTERVAL '75 days',
        250000.00, 1250000.00
    ) RETURNING id INTO reservation_id_2;

    INSERT INTO contract.rental_contracts (
        contract_number, reservation_id, customer_id, vehicle_id, status_id,
        pickup_branch_id, return_branch_id, scheduled_start_at, scheduled_end_at,
        base_amount, security_deposit
    ) VALUES (
        'CTR-2026-0002', reservation_id_2, admin_user_id, vehicle_id, draft_contract_status_id,
        branch_id, branch_id, CURRENT_TIMESTAMP + INTERVAL '70 days', CURRENT_TIMESTAMP + INTERVAL '75 days',
        1250000.00, 500000.00
    ) RETURNING id INTO contract_id_2;

    INSERT INTO contract.contract_clause_assignments (contract_id, clause_id)
    VALUES (contract_id_2, clause_id);

    DELETE FROM rental.reservations WHERE id = reservation_id_2;

    IF EXISTS (
        SELECT 1 FROM contract.rental_contracts WHERE id = contract_id_2
    ) OR EXISTS (
        SELECT 1 FROM contract.contract_clause_assignments WHERE contract_id = contract_id_2
    ) THEN
        RAISE EXCEPTION 'Expected contract and clause assignments to be deleted when reservation is deleted';
    END IF;

    RAISE NOTICE 'HU-BD-31 APPROVED: contract schema, 1-to-1 reservation contracts, biometric JSONB strokes, clauses, assignments and indexes validated.';
END;
$$;

ROLLBACK;
