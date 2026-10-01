CREATE TABLE location.branch_users (
    user_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_branch_users PRIMARY KEY (user_id, branch_id),
    CONSTRAINT fk_branch_users_user
        FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE CASCADE,
    CONSTRAINT fk_branch_users_branch
        FOREIGN KEY (branch_id) REFERENCES location.branches (id) ON DELETE CASCADE
);
