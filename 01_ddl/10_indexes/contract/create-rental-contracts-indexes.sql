CREATE INDEX idx_contracts_reservation ON contract.rental_contracts (reservation_id);
CREATE INDEX idx_contracts_customer ON contract.rental_contracts (customer_id);
CREATE INDEX idx_contracts_status ON contract.rental_contracts (status_id);
