REVOKE INSERT, UPDATE ON TABLE
    rental.reservations,
    rental.reservation_delivery_points
FROM drivique_app;

REVOKE SELECT, INSERT, DELETE ON TABLE
    rental.reservation_additional_services,
    rental.reservation_promotions
FROM drivique_app;
