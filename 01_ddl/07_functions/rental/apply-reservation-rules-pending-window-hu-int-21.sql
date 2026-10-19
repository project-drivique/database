-- El plazo de vencimiento aplica a toda reserva pendiente (efectivo o en línea), no solo a las de efectivo:
-- así una reserva sin gestionar libera las fechas al vencer.
CREATE OR REPLACE FUNCTION rental.apply_reservation_rules()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    status_blocks_availability BOOLEAN;
BEGIN
    SELECT blocks_availability
    INTO status_blocks_availability
    FROM rental.reservation_statuses
    WHERE id = NEW.status_id;

    NEW.blocks_availability = status_blocks_availability;

    IF NEW.cash_payment_branch_id IS NULL AND NEW.cash_payment_code IS NULL THEN
        -- sin pago en efectivo: se conserva el plazo que calculó la aplicación
        NEW.cash_payment_expires_at = NEW.cash_payment_expires_at;
    ELSIF NEW.cash_payment_branch_id IS NOT NULL AND NEW.cash_payment_code IS NOT NULL THEN
        NEW.cash_payment_expires_at = COALESCE(NEW.cash_payment_expires_at, NEW.created_at + INTERVAL '72 hours');
    ELSE
        RAISE EXCEPTION 'Cash payment branch and code must be provided together';
    END IF;

    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;
