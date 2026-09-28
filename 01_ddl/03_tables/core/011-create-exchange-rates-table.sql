CREATE TABLE core.exchange_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_currency_id UUID NOT NULL,
    to_currency_id UUID NOT NULL,
    rate NUMERIC(16, 6) NOT NULL,
    provider VARCHAR(80) NOT NULL,
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exchange_rates_from_currency
        FOREIGN KEY (from_currency_id) REFERENCES core.currencies (id),
    CONSTRAINT fk_exchange_rates_to_currency
        FOREIGN KEY (to_currency_id) REFERENCES core.currencies (id),
    CONSTRAINT uq_exchange_rates_pair_fetched_at
        UNIQUE (from_currency_id, to_currency_id, fetched_at),
    CONSTRAINT chk_exchange_rates_rate_positive CHECK (rate > 0),
    CONSTRAINT chk_exchange_rates_currency_pair CHECK (from_currency_id <> to_currency_id)
);
