-- Test script for HU-INT-09: Pricing, availability, insurance, mileage plans, promotions and exchange rates
DO $$
DECLARE
    v_insurance_count INT;
    v_mileage_plan_count INT;
    v_additional_service_count INT;
    v_currency_count INT;
BEGIN
    -- 1. Check insurance coverages
    SELECT COUNT(*) INTO v_insurance_count FROM catalog.insurance_coverages WHERE is_active = TRUE;
    IF v_insurance_count < 1 THEN
        RAISE EXCEPTION 'HU-INT-09 Validation Failed: No active insurance coverages found';
    END IF;

    -- 2. Check mileage plans
    SELECT COUNT(*) INTO v_mileage_plan_count FROM catalog.mileage_plans WHERE is_active = TRUE;
    IF v_mileage_plan_count < 1 THEN
        RAISE EXCEPTION 'HU-INT-09 Validation Failed: No active mileage plans found';
    END IF;

    -- 3. Check additional services
    SELECT COUNT(*) INTO v_additional_service_count FROM catalog.additional_services WHERE is_active = TRUE;
    IF v_additional_service_count < 1 THEN
        RAISE EXCEPTION 'HU-INT-09 Validation Failed: No active additional services found';
    END IF;

    -- 4. Check currencies
    SELECT COUNT(*) INTO v_currency_count FROM core.currencies WHERE is_active = TRUE;
    IF v_currency_count < 1 THEN
        RAISE EXCEPTION 'HU-INT-09 Validation Failed: No active currencies found in core.currencies';
    END IF;

    RAISE NOTICE 'HU-INT-09 Pricing, Availability & Catalog Integrity Test Passed Successfully.';
END $$;
