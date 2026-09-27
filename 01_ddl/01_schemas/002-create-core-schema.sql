--liquibase formatted sql

--changeset danna:002-create-core-schema labels:hu-bd-02
CREATE SCHEMA IF NOT EXISTS core;

--rollback DROP SCHEMA core;
