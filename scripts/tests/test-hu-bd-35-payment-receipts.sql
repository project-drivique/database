BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    vehicle_id UUID;
    reservation_status_id UUID;
    coverage_id UUID;
    mileage_plan_id UUID;
    branch_id UUID;
    contract_status_id UUID;
    payment_method_id UUID;
    payment_status_id UUID;
    currency_id UUID;
    reservation_id UUID;
    contract_id UUID;
    first_payment_id UUID;
    second_payment_id UUID;
    receipt_id UUID;
    receipt_updated_at TIMESTAMPTZ;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';
    SELECT id INTO reservation_status_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    SELECT id INTO coverage_id FROM catalog.insurance_coverages WHERE name = 'Basic Protection';
    SELECT id INTO mileage_plan_id FROM catalog.mileage_plans WHERE name = 'Standard 200 km';
    SELECT id INTO branch_id FROM location.branches WHERE name = 'Drivique Bogotá Centro';
    SELECT id INTO contract_status_id FROM contract.contract_statuses WHERE code = 'PENDING_SIGNATURE';
    SELECT id INTO payment_method_id FROM billing.payment_methods WHERE code = 'CREDIT_CARD';
    SELECT id INTO payment_status_id FROM billing.payment_statuses WHERE code = 'APPROVED';
    SELECT id INTO currency_id FROM core.currencies WHERE code = 'COP';

    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-RECEIPT-TEST', admin_user_id, vehicle_id, reservation_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '40 days', CURRENT_TIMESTAMP + INTERVAL '42 days', 220000.00, 440000.00
    ) RETURNING id INTO reservation_id;

    INSERT INTO contract.rental_contracts (
        contract_number, reservation_id, customer_id, vehicle_id, status_id, pickup_branch_id, return_branch_id,
        scheduled_start_at, scheduled_end_at, base_amount
    ) VALUES (
        'CON-RECEIPT-TEST', reservation_id, admin_user_id, vehicle_id, contract_status_id, branch_id, branch_id,
        CURRENT_TIMESTAMP + INTERVAL '40 days', CURRENT_TIMESTAMP + INTERVAL '42 days', 440000.00
    ) RETURNING id INTO contract_id;

    INSERT INTO billing.payments (
        contract_id, payment_method_id, status_id, gateway_provider, gateway_reference, amount, currency_id
    ) VALUES (
        contract_id, payment_method_id, payment_status_id, 'WOMPI', 'WOMPI-RECEIPT-001', 440000.00, currency_id
    ) RETURNING id INTO first_payment_id;

    INSERT INTO billing.payments (
        contract_id, payment_method_id, status_id, gateway_provider, gateway_reference, amount, currency_id
    ) VALUES (
        contract_id, payment_method_id, payment_status_id, 'WOMPI', 'WOMPI-RECEIPT-002', 1000.00, currency_id
    ) RETURNING id INTO second_payment_id;

    INSERT INTO billing.payment_receipts (payment_id, receipt_number, pdf_url)
    VALUES (first_payment_id, 'RCP-TEST-001', 'https://files.drivique.test/receipts/RCP-TEST-001.pdf')
    RETURNING id INTO receipt_id;

    BEGIN
        INSERT INTO billing.payment_receipts (payment_id, receipt_number, pdf_url)
        VALUES (first_payment_id, 'RCP-TEST-002', 'https://files.drivique.test/receipts/RCP-TEST-002.pdf');
        RAISE EXCEPTION 'Expected duplicate receipt payment to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO billing.payment_receipts (payment_id, receipt_number, pdf_url)
        VALUES (second_payment_id, 'RCP-TEST-001', 'https://files.drivique.test/receipts/RCP-TEST-003.pdf');
        RAISE EXCEPTION 'Expected duplicate receipt number to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO billing.payment_receipts (payment_id, receipt_number, pdf_url)
        VALUES (second_payment_id, 'RCP-TEST-003', ' ');
        RAISE EXCEPTION 'Expected blank receipt URL to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    UPDATE billing.payment_receipts
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = receipt_id;

    SELECT updated_at INTO receipt_updated_at FROM billing.payment_receipts WHERE id = receipt_id;
    IF receipt_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected payment receipt audit trigger';
    END IF;

    RAISE NOTICE 'HU-BD-35 APPROVED: receipt relation, uniqueness, URL validation and audit validated.';
END;
$$;

ROLLBACK;
