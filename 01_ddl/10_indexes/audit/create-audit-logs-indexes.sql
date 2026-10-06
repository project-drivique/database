CREATE INDEX idx_audit_table_date ON audit.audit_logs (entity_name, created_at);
CREATE INDEX idx_audit_actor ON audit.audit_logs (actor_user_id);
CREATE INDEX idx_audit_logs_domain ON audit.audit_logs (domain_name);
CREATE INDEX idx_audit_logs_entity_id ON audit.audit_logs (entity_id);
CREATE INDEX idx_audit_logs_branch ON audit.audit_logs (branch_id);
CREATE INDEX idx_audit_logs_operation ON audit.audit_logs (operation);
CREATE INDEX idx_audit_logs_old_data ON audit.audit_logs USING gin (old_data);
CREATE INDEX idx_audit_logs_new_data ON audit.audit_logs USING gin (new_data);
