GRANT INSERT, UPDATE ON TABLE
    rental.reservations,
    rental.reservation_delivery_points
TO drivique_app;

GRANT SELECT, INSERT, DELETE ON TABLE
    rental.reservation_additional_services,
    rental.reservation_promotions
TO drivique_app;
