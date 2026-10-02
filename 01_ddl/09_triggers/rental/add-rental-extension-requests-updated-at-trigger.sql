CREATE TRIGGER trg_rental_extension_requests_set_updated_at
BEFORE UPDATE ON rental.rental_extension_requests
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
