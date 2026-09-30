CREATE TABLE iam.user_profiles (
    user_id UUID PRIMARY KEY,
    address VARCHAR(255),
    city_of_residence VARCHAR(100),
    department_of_residence VARCHAR(100),
    postal_code VARCHAR(20),
    gender VARCHAR(20),
    emergency_contact_name VARCHAR(150),
    emergency_contact_phone VARCHAR(30),
    avatar_url VARCHAR(1000),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE,
    CONSTRAINT chk_user_profiles_gender CHECK (gender IS NULL OR gender IN ('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'))
);
