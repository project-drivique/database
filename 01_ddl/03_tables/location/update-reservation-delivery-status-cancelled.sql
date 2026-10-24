-- Actualización del constraint de estados de entrega para soportar cancelaciones automáticas y manuales
ALTER TABLE rental.reservation_delivery_points
    DROP CONSTRAINT IF EXISTS chk_reservation_delivery_points_delivery_status;

ALTER TABLE rental.reservation_delivery_points
    ADD CONSTRAINT chk_reservation_delivery_points_delivery_status
    CHECK (delivery_status IN ('PENDING', 'ASSIGNED', 'COMPLETED', 'CANCELLED'));
