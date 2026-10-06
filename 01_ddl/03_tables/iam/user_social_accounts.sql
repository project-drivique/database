CREATE TABLE iam.user_social_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    provider VARCHAR(30) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    email VARCHAR(254),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_social_accounts_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_social_accounts_provider_user_id UNIQUE (provider, provider_user_id),
    CONSTRAINT uq_user_social_accounts_user_provider UNIQUE (user_id, provider),
    CONSTRAINT chk_user_social_accounts_provider CHECK (provider IN ('GOOGLE', 'FACEBOOK'))
);

CREATE INDEX idx_user_social_accounts_user_id ON iam.user_social_accounts(user_id);
CREATE INDEX idx_user_social_accounts_provider_lookup ON iam.user_social_accounts(provider, provider_user_id);
