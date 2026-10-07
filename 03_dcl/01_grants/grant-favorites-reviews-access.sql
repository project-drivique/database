GRANT SELECT, INSERT, DELETE ON TABLE fleet.user_favorite_vehicles TO drivique_app;

GRANT USAGE ON SCHEMA rental TO drivique_app;
GRANT SELECT ON TABLE
    rental.reservations,
    rental.reservation_statuses,
    rental.reservation_delivery_points
TO drivique_app;
GRANT SELECT, INSERT ON TABLE
    rental.vehicle_ratings,
    rental.branch_reviews
TO drivique_app;
