INSERT INTO audit.administrative_report_types (code, name, description, is_active)
VALUES
    ('FLEET_OCCUPANCY', 'Ocupación de Flota', 'Reporte analítico de disponibilidad y tasa de uso de vehículos', true),
    ('REVENUE_SUMMARY', 'Resumen de Ingresos', 'Consolidado financiero de pagos, facturación y cobros de alquiler', true),
    ('AUDIT_TRAIL', 'Trazabilidad de Auditoría', 'Registro pormenorizado de operaciones y eventos de seguridad', true),
    ('MAINTENANCE', 'Mantenimiento Preventivo y Correctivo', 'Historial y planificación de mantenimientos de flota', true)
ON CONFLICT (code) DO NOTHING;
