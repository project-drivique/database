GRANT SELECT, UPDATE ON TABLE fleet.vehicles TO drivique_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA rental, fleet, catalog, billing, iam, support, audit TO drivique_app;
