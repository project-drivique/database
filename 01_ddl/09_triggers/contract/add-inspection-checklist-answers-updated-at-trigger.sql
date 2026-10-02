CREATE TRIGGER trg_inspection_checklist_answers_set_updated_at
BEFORE UPDATE ON contract.inspection_checklist_answers
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
