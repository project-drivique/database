CREATE INDEX idx_exchange_rates_currency_pair_fetched_at
    ON core.exchange_rates (from_currency_id, to_currency_id, fetched_at DESC);
