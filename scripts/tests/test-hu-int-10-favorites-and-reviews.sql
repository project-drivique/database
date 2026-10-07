-- Test script for HU-INT-10: Persistent Favorites and Verified Reviews
DO $$
DECLARE
    v_fav_table_exists BOOLEAN;
    v_ratings_table_exists BOOLEAN;
    v_branch_reviews_table_exists BOOLEAN;
BEGIN
    -- 1. Verify fleet.user_favorite_vehicles table exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'fleet' AND table_name = 'user_favorite_vehicles'
    ) INTO v_fav_table_exists;

    IF NOT v_fav_table_exists THEN
        RAISE EXCEPTION 'HU-INT-10 Validation Failed: Table fleet.user_favorite_vehicles does not exist';
    END IF;

    -- 2. Verify rental.vehicle_ratings table exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'rental' AND table_name = 'vehicle_ratings'
    ) INTO v_ratings_table_exists;

    IF NOT v_ratings_table_exists THEN
        RAISE EXCEPTION 'HU-INT-10 Validation Failed: Table rental.vehicle_ratings does not exist';
    END IF;

    -- 3. Verify rental.branch_reviews table exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'rental' AND table_name = 'branch_reviews'
    ) INTO v_branch_reviews_table_exists;

    IF NOT v_branch_reviews_table_exists THEN
        RAISE EXCEPTION 'HU-INT-10 Validation Failed: Table rental.branch_reviews does not exist';
    END IF;

    RAISE NOTICE 'HU-INT-10 Favorites and Reviews Schema Integrity Test Passed Successfully.';
END $$;
