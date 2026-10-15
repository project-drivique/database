DROP TABLE IF EXISTS support.incident_status_history;
DROP TABLE IF EXISTS support.incident_attachments;
DROP INDEX IF EXISTS support.idx_incident_reports_assigned_to;
DROP INDEX IF EXISTS support.idx_incident_reports_branch;
ALTER TABLE support.incident_reports
    DROP CONSTRAINT IF EXISTS fk_incident_reports_assigned_to,
    DROP CONSTRAINT IF EXISTS fk_incident_reports_branch,
    DROP CONSTRAINT IF EXISTS chk_incident_reports_category,
    DROP COLUMN IF EXISTS closed_at,
    DROP COLUMN IF EXISTS resolved_at,
    DROP COLUMN IF EXISTS sla_due_at,
    DROP COLUMN IF EXISTS assigned_to_user_id,
    DROP COLUMN IF EXISTS branch_id,
    DROP COLUMN IF EXISTS category;
