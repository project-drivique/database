INSERT INTO audit.administrative_report_types (code, name, description, is_active)
VALUES
    ('EXECUTIVE_SUMMARY', 'Resumen Ejecutivo y Operativo', 'Balance global del negocio con indicadores clave de reservas, ingresos, flota, contratos e incidencias', true),
    ('FINANCIAL_CONSOLIDATED', 'Consolidado Financiero e Ingresos', 'Ingresos por sucursal, métodos de pago y ticket promedio', true),
    ('INCIDENTS_MAINTENANCE', 'Balance de Incidencias y Mantenimiento', 'Incidencias por gravedad, estado y costo estimado', true),
    ('RESERVATIONS', 'Reporte Específico de Reservas', 'Listado detallado de reservas', true),
    ('VEHICLES', 'Reporte Específico de Flota y Vehículos', 'Inventario de vehículos', true),
    ('CONTRACTS', 'Reporte Específico de Contratos', 'Relación de contratos de arrendamiento', true),
    ('INCIDENTS', 'Reporte Específico de Incidencias', 'Listado de incidencias reportadas', true),
    ('USERS', 'Reporte Específico de Clientes y Usuarios', 'Directorio de usuarios del sistema', true),
    ('PROMOTIONS', 'Reporte Específico de Promociones y Cupones', 'Catálogo de promociones y cupones', true)
ON CONFLICT (code) DO NOTHING;
