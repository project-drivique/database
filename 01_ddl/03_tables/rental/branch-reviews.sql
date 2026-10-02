CREATE TABLE rental.branch_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL,
    user_id UUID NOT NULL,
    reservation_id UUID NOT NULL,
    rating SMALLINT NOT NULL,
    comment VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_branch_reviews_reservation_branch UNIQUE (reservation_id, branch_id),
    CONSTRAINT fk_branch_reviews_branch FOREIGN KEY (branch_id) REFERENCES location.branches (id) ON DELETE RESTRICT,
    CONSTRAINT fk_branch_reviews_user FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_branch_reviews_reservation FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE RESTRICT,
    CONSTRAINT chk_branch_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_branch_reviews_comment_not_blank CHECK (comment IS NULL OR btrim(comment) <> '')
);
