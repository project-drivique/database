-- Seed maintenance types catalog
INSERT INTO fleet.maintenance_types (code, name, is_active)
VALUES
    ('PREVENTIVE', 'Mantenimiento Preventivo', TRUE),
    ('CORRECTIVE', 'Mantenimiento Correctivo', TRUE),
    ('OIL_CHANGE', 'Cambio de Aceite y Filtros', TRUE),
    ('TIRES', 'Revisión y Cambio de Llantas', TRUE)
ON CONFLICT (code) DO NOTHING;

-- Seed initial sample maintenance for history audit
INSERT INTO fleet.vehicle_maintenances (
    vehicle_id,
    maintenance_type_id,
    scheduled_date,
    completed_date,
    cost,
    description
)
SELECT
    v.id,
    mt.id,
    '2024-02-01'::DATE,
    '2024-02-02'::DATE,
    250000.00,
    'Cambio preventivo de aceite sintético 5W-30 y filtros de aire'
FROM fleet.vehicles v
CROSS JOIN fleet.maintenance_types mt
WHERE v.plate = 'ABC-123' AND mt.code = 'OIL_CHANGE'
LIMIT 1;
