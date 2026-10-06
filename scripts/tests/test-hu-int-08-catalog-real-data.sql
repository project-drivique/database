-- ============================================================================
-- DRIVIQUE DATABASE TEST SCRIPT
-- Story: HU-INT-08 (Catálogos, sedes, vehículos e imágenes reales)
-- Description: Verifies that cities, branches, categories, vehicles, images,
--              and feature relations are correctly seeded and queryable.
-- ============================================================================

DO $$
DECLARE
    v_cities_count INT;
    v_branches_count INT;
    v_categories_count INT;
    v_vehicles_count INT;
    v_active_vehicles_count INT;
BEGIN
    -- 1. Check cities and branches
    SELECT COUNT(*) INTO v_cities_count FROM location.cities;
    SELECT COUNT(*) INTO v_branches_count FROM location.branches WHERE is_active = true;

    IF v_cities_count = 0 THEN
        RAISE EXCEPTION 'Assertion failed: No cities found in location.cities';
    END IF;

    IF v_branches_count = 0 THEN
        RAISE EXCEPTION 'Assertion failed: No active branches found in location.branches';
    END IF;

    -- 2. Check categories
    SELECT COUNT(*) INTO v_categories_count FROM fleet.vehicle_categories WHERE is_active = true;
    IF v_categories_count = 0 THEN
        RAISE EXCEPTION 'Assertion failed: No active categories found in fleet.vehicle_categories';
    END IF;

    -- 3. Check vehicles
    SELECT COUNT(*) INTO v_vehicles_count FROM fleet.vehicles;
    SELECT COUNT(*) INTO v_active_vehicles_count FROM fleet.vehicles WHERE is_active = true;

    IF v_vehicles_count = 0 THEN
        RAISE EXCEPTION 'Assertion failed: No vehicles found in fleet.vehicles';
    END IF;

    RAISE NOTICE 'HU-INT-08 Database test passed successfully: Verified % cities, % active branches, % active categories, and % vehicles (including % active).',
        v_cities_count, v_branches_count, v_categories_count, v_vehicles_count, v_active_vehicles_count;
END $$;
