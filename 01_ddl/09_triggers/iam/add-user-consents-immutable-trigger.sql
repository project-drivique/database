CREATE TRIGGER trg_user_consents_immutable
BEFORE UPDATE OR DELETE ON iam.user_consents
FOR EACH ROW
EXECUTE FUNCTION iam.prevent_user_consent_mutation();
