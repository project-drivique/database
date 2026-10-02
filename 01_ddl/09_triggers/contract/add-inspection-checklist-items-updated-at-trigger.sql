CREATE TRIGGER trg_inspection_checklist_items_set_updated_at
BEFORE UPDATE ON contract.inspection_checklist_items
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
