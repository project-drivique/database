CREATE INDEX idx_incident_reports_code ON support.incident_reports (incident_code);
CREATE INDEX idx_incident_reports_vehicle ON support.incident_reports (vehicle_id);
CREATE INDEX idx_incident_reports_reservation ON support.incident_reports (reservation_id);
CREATE INDEX idx_incident_reports_reported_by ON support.incident_reports (reported_by_user_id);
CREATE INDEX idx_incident_reports_status ON support.incident_reports (status);
CREATE INDEX idx_incident_responses_report ON support.incident_responses (incident_report_id);
CREATE INDEX idx_incident_responses_author ON support.incident_responses (author_user_id);
