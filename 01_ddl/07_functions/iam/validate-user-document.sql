CREATE FUNCTION iam.validate_user_document()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    requires_front_and_back BOOLEAN;
    status_code VARCHAR(20);
BEGIN
    SELECT document_type.requires_front_and_back
    INTO requires_front_and_back
    FROM iam.document_types AS document_type
    WHERE document_type.id = NEW.document_type_id;

    IF requires_front_and_back AND NEW.back_url IS NULL THEN
        RAISE EXCEPTION 'Documents of this type require front and back images'
            USING ERRCODE = '23514';
    END IF;

    SELECT document_status.code
    INTO status_code
    FROM iam.document_statuses AS document_status
    WHERE document_status.id = NEW.status_id;

    IF status_code IN ('APPROVED', 'REJECTED') THEN
        IF NEW.reviewed_by IS NULL OR NEW.reviewed_at IS NULL THEN
            RAISE EXCEPTION 'Approved and rejected documents require reviewer and review timestamp'
                USING ERRCODE = '23514';
        END IF;

        IF status_code = 'REJECTED' AND NEW.review_notes IS NULL THEN
            RAISE EXCEPTION 'Rejected documents require review notes'
                USING ERRCODE = '23514';
        END IF;
    ELSIF status_code = 'PENDING' AND (NEW.reviewed_by IS NOT NULL OR NEW.reviewed_at IS NOT NULL) THEN
        RAISE EXCEPTION 'Pending documents cannot have review data'
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;
