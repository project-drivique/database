CREATE TRIGGER trg_reservations_apply_rules
BEFORE INSERT OR UPDATE ON rental.reservations
FOR EACH ROW
EXECUTE FUNCTION rental.apply_reservation_rules();
