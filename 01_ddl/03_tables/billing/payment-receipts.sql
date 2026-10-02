CREATE TABLE billing.payment_receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL,
    receipt_number VARCHAR(50) NOT NULL,
    pdf_url VARCHAR(1000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_payment_receipts_payment UNIQUE (payment_id),
    CONSTRAINT uq_payment_receipts_number UNIQUE (receipt_number),
    CONSTRAINT fk_payment_receipts_payment FOREIGN KEY (payment_id) REFERENCES billing.payments (id) ON DELETE RESTRICT,
    CONSTRAINT chk_payment_receipts_number_not_blank CHECK (btrim(receipt_number) <> ''),
    CONSTRAINT chk_payment_receipts_pdf_url_not_blank CHECK (btrim(pdf_url) <> '')
);
