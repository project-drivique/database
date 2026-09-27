CREATE UNIQUE INDEX uq_languages_one_default
    ON core.languages (is_default)
    WHERE is_default;

CREATE UNIQUE INDEX uq_currencies_one_default
    ON core.currencies (is_default)
    WHERE is_default;
