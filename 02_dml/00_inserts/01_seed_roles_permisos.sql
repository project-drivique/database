-- ==============================================================================
-- Drivique - Insercion Semilla de Roles y Permisos (DML)
-- ==============================================================================

-- 1. Insercion de Roles Base del Sistema
INSERT INTO roles (codigo, nombre, descripcion, activo)
VALUES
    ('ROLE_ADMIN', 'Administrador del Sistema', 'Acceso total a la plataforma y configuracion administrativa', TRUE),
    ('ROLE_CUSTOMER', 'Cliente / Conductor', 'Usuario que alquila vehiculos y gestiona sus reservas', TRUE),
    ('ROLE_OPERATOR', 'Operador de Flota', 'Encargado de inspecciones, entrega y recepcion de vehiculos', TRUE),
    ('ROLE_SUPPORT', 'Agente de Soporte', 'Atencion a incidencias y asistencia a usuarios', TRUE)
ON CONFLICT (codigo) DO UPDATE
SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    activo = EXCLUDED.activo;

-- 2. Insercion de Catalogo de Permisos
INSERT INTO permisos (codigo, nombre, descripcion)
VALUES
    -- Autenticacion y Usuarios
    ('AUTH_LOGIN', 'Iniciar Sesion', 'Permite autenticarse en el sistema y renovar tokens'),
    ('USER_READ_SELF', 'Consultar Perfil Propio', 'Permite ver los datos del propio usuario'),
    ('USER_UPDATE_SELF', 'Actualizar Perfil Propio', 'Permite modificar informacion del propio perfil'),
    ('USER_READ_ALL', 'Listar Usuarios', 'Permite consultar el listado completo de usuarios'),
    ('USER_MANAGE_STATUS', 'Gestionar Estado de Usuario', 'Permite bloquear, suspender o activar cuentas'),

    -- Vehiculos y Flota
    ('VEHICLE_CATALOG_READ', 'Ver Catalogo de Vehiculos', 'Permite explorar los vehiculos disponibles'),
    ('VEHICLE_MANAGE', 'Gestionar Flota de Vehiculos', 'Permite registrar, editar o cambiar estado de vehiculos'),
    ('INSPECTION_MANAGE', 'Realizar Inspecciones', 'Permite registrar inspecciones de entrega y devolucion'),

    -- Reservas y Contratos
    ('RESERVATION_CREATE', 'Crear Reserva', 'Permite solicitar una reserva de vehiculo'),
    ('RESERVATION_READ_SELF', 'Ver Mis Reservas', 'Permite consultar el historial propio de reservas'),
    ('RESERVATION_MANAGE_ALL', 'Administrar Reservas', 'Permite aprobar, cancelar o modificar cualquier reserva'),
    ('CONTRACT_SIGN', 'Firmar Contrato', 'Permite firmar digitalmente el contrato de alquiler'),

    -- Pagos y Facturacion
    ('PAYMENT_EXECUTE', 'Realizar Pago', 'Permite procesar transacciones y pagos de reserva'),
    ('PAYMENT_REFUND_MANAGE', 'Gestionar Reembolsos', 'Permite autorizar y emitir reembolsos de pagos'),

    -- Reportes y Auditoria
    ('AUDIT_READ', 'Consultar Auditoria', 'Permite visualizar registros de auditoria y trazas del sistema'),
    ('REPORTS_VIEW', 'Ver Reportes Administrativos', 'Permite generar y visualizar reportes de operacion y negocio')
ON CONFLICT (codigo) DO UPDATE
SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion;

-- 3. Asignacion de Permisos por Rol (rol_permisos)

-- Permisos para ROLE_ADMIN (Todos los permisos)
INSERT INTO rol_permisos (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permisos p
WHERE r.codigo = 'ROLE_ADMIN'
ON CONFLICT (rol_id, permiso_id) DO NOTHING;

-- Permisos para ROLE_CUSTOMER
INSERT INTO rol_permisos (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r, permisos p
WHERE r.codigo = 'ROLE_CUSTOMER'
  AND p.codigo IN (
      'AUTH_LOGIN',
      'USER_READ_SELF',
      'USER_UPDATE_SELF',
      'VEHICLE_CATALOG_READ',
      'RESERVATION_CREATE',
      'RESERVATION_READ_SELF',
      'CONTRACT_SIGN',
      'PAYMENT_EXECUTE'
  )
ON CONFLICT (rol_id, permiso_id) DO NOTHING;

-- Permisos para ROLE_OPERATOR
INSERT INTO rol_permisos (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r, permisos p
WHERE r.codigo = 'ROLE_OPERATOR'
  AND p.codigo IN (
      'AUTH_LOGIN',
      'USER_READ_SELF',
      'VEHICLE_CATALOG_READ',
      'VEHICLE_MANAGE',
      'INSPECTION_MANAGE',
      'RESERVATION_MANAGE_ALL'
  )
ON CONFLICT (rol_id, permiso_id) DO NOTHING;

-- Permisos para ROLE_SUPPORT
INSERT INTO rol_permisos (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r, permisos p
WHERE r.codigo = 'ROLE_SUPPORT'
  AND p.codigo IN (
      'AUTH_LOGIN',
      'USER_READ_SELF',
      'USER_READ_ALL',
      'VEHICLE_CATALOG_READ',
      'RESERVATION_MANAGE_ALL',
      'REPORTS_VIEW'
  )
ON CONFLICT (rol_id, permiso_id) DO NOTHING;
