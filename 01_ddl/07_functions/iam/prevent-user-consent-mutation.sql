CREATE FUNCTION iam.prevent_user_consent_mutation()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'User consent records are immutable'
        USING ERRCODE = '55000';
END;
$$;
