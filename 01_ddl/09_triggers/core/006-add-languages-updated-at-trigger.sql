CREATE TRIGGER trg_languages_set_updated_at
BEFORE UPDATE ON core.languages
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
