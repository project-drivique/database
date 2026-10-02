CREATE TRIGGER trg_vehicle_ratings_set_updated_at
BEFORE UPDATE ON rental.vehicle_ratings
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

CREATE TRIGGER trg_branch_reviews_set_updated_at
BEFORE UPDATE ON rental.branch_reviews
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
