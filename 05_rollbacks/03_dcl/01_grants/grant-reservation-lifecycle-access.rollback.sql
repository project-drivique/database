REVOKE SELECT, INSERT, UPDATE ON TABLE
    rental.rental_extension_requests
FROM drivique_app;

REVOKE INSERT ON TABLE
    audit.audit_logs
FROM drivique_app;
