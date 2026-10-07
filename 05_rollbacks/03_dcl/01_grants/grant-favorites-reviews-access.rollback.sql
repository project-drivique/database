REVOKE SELECT, INSERT ON TABLE
    rental.vehicle_ratings,
    rental.branch_reviews
FROM drivique_app;
REVOKE SELECT ON TABLE
    rental.reservations,
    rental.reservation_statuses,
    rental.reservation_delivery_points
FROM drivique_app;
REVOKE USAGE ON SCHEMA rental FROM drivique_app;

REVOKE SELECT, INSERT, DELETE ON TABLE fleet.user_favorite_vehicles FROM drivique_app;
