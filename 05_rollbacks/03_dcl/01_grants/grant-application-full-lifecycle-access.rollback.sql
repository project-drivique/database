REVOKE ALL ON SCHEMA core, catalog, billing, audit FROM drivique_app;

REVOKE ALL ON TABLE
    core.languages,
    core.currencies,
    core.exchange_rates,
    core.brand_configurations
FROM drivique_app;

REVOKE ALL ON TABLE
    catalog.additional_services,
    catalog.insurance_coverages,
    catalog.mileage_plans,
    catalog.promotions,
    catalog.user_coupon_usages
FROM drivique_app;

REVOKE ALL ON TABLE
    billing.payment_methods,
    billing.payment_statuses,
    billing.payments,
    billing.payment_receipts,
    billing.user_saved_payment_methods
FROM drivique_app;

REVOKE ALL ON TABLE
    audit.audit_logs,
    audit.administrative_report_types,
    audit.generated_reports
FROM drivique_app;

REVOKE ALL ON TABLE
    iam.user_documents,
    iam.user_profiles,
    iam.user_consents,
    iam.document_types,
    iam.document_statuses,
    iam.nationalities,
    iam.security_configurations
FROM drivique_app;

REVOKE ALL ON TABLE
    fleet.vehicle_documents,
    fleet.vehicle_maintenances,
    fleet.maintenance_types
FROM drivique_app;

REVOKE ALL ON TABLE
    support.incident_reports,
    support.incident_responses
FROM drivique_app;

REVOKE ALL ON TABLE
    location.branch_users
FROM drivique_app;
