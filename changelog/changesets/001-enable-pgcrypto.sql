--liquibase formatted sql

--changeset danna:001-enable-pgcrypto labels:hu-bd-01
CREATE EXTENSION IF NOT EXISTS pgcrypto;

--rollback DROP EXTENSION IF EXISTS pgcrypto;

