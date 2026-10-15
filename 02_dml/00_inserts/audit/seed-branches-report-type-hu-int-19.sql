INSERT INTO audit.administrative_report_types (code, name, description, is_active)
VALUES ('BRANCHES', 'Reporte de Sedes', 'Vehículos, reservas, ingresos, incidencias y calificación por sucursal', true)
ON CONFLICT (code) DO NOTHING;
