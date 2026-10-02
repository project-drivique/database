CREATE TRIGGER trg_reservation_delivery_points_set_updated_at
BEFORE UPDATE ON rental.reservation_delivery_points
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
