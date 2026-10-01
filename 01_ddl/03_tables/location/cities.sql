CREATE TABLE location.cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    department_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    has_airport BOOLEAN NOT NULL DEFAULT FALSE,
    has_terminal BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cities_department
        FOREIGN KEY (department_id) REFERENCES location.departments (id),
    CONSTRAINT uq_cities_department_name UNIQUE (department_id, name),
    CONSTRAINT chk_cities_name_not_blank CHECK (btrim(name) <> '')
);
