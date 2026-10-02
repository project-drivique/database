CREATE TRIGGER trg_reservation_statuses_set_updated_at
BEFORE UPDATE ON rental.reservation_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
