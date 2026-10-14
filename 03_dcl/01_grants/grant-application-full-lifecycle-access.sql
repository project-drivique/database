GRANT USAGE ON SCHEMA core, catalog, billing, audit TO drivique_app;

-- Core
GRANT SELECT ON TABLE
    core.languages,
    core.currencies,
    core.exchange_rates,
    core.brand_configurations
TO drivique_app;

-- Catalog
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
    catalog.additional_services,
    catalog.insurance_coverages,
    catalog.mileage_plans,
    catalog.promotions,
    catalog.user_coupon_usages
TO drivique_app;

-- Billing
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
    billing.payment_methods,
    billing.payment_statuses,
    billing.payments,
    billing.payment_receipts,
    billing.user_saved_payment_methods
TO drivique_app;

-- Audit
GRANT SELECT, INSERT ON TABLE
    audit.audit_logs,
    audit.administrative_report_types,
    audit.generated_reports
TO drivique_app;

-- IAM (KYC, perfiles y catálogos)
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
    iam.user_documents,
    iam.user_profiles,
    iam.user_consents
TO drivique_app;

GRANT SELECT ON TABLE
    iam.document_types,
    iam.document_statuses,
    iam.nationalities,
    iam.security_configurations
TO drivique_app;

-- Fleet
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
    fleet.vehicle_documents,
    fleet.vehicle_maintenances
TO drivique_app;

GRANT SELECT ON TABLE
    fleet.maintenance_types
TO drivique_app;

-- Support
GRANT SELECT, INSERT, UPDATE ON TABLE
    support.incident_reports,
    support.incident_responses
TO drivique_app;

-- Location
GRANT SELECT ON TABLE
    location.branch_users
TO drivique_app;

-- Sequences en todos los esquemas operativos
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA core, catalog, billing, audit, iam, fleet, support, rental, location TO drivique_app;
