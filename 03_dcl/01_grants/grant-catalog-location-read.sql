GRANT USAGE ON SCHEMA fleet, location TO drivique_app;
GRANT SELECT ON TABLE
    fleet.vehicles,
    fleet.vehicle_brands,
    fleet.vehicle_categories,
    fleet.transmission_types,
    fleet.fuel_types,
    fleet.vehicle_statuses,
    fleet.features,
    fleet.vehicle_features,
    fleet.vehicle_images,
    location.branches,
    location.cities,
    location.departments
TO drivique_app;
