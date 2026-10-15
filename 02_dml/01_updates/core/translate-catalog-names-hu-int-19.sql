-- Los códigos no cambian; solo el texto que se muestra a las personas.
UPDATE iam.roles SET name = 'Administrador general', description = 'Acceso total al sistema y administración de la plataforma' WHERE code = 'SUPER_ADMIN';
UPDATE iam.roles SET name = 'Encargado de sucursal', description = 'Gestión operativa de la sucursal asignada' WHERE code = 'BRANCH_ADMIN';
UPDATE iam.roles SET name = 'Empleado', description = 'Atención en mostrador, inspecciones y servicio al cliente' WHERE code = 'EMPLOYEE';
UPDATE iam.roles SET name = 'Cliente', description = 'Alquiler de vehículos y autogestión del perfil' WHERE code = 'CUSTOMER';

UPDATE iam.permissions SET name = 'Consultar auditoría' WHERE code = 'AUDIT_READ';
UPDATE iam.permissions SET name = 'Gestionar sucursales' WHERE code = 'BRANCHES_MANAGE';
UPDATE iam.permissions SET name = 'Gestionar la marca' WHERE code = 'BRAND_CONFIGURATION_MANAGE';
UPDATE iam.permissions SET name = 'Gestionar catálogo' WHERE code = 'CATALOG_MANAGE';
UPDATE iam.permissions SET name = 'Gestionar contratos' WHERE code = 'CONTRACTS_MANAGE';
UPDATE iam.permissions SET name = 'Gestionar flota' WHERE code = 'FLEET_MANAGE';
UPDATE iam.permissions SET name = 'Gestionar pagos' WHERE code = 'PAYMENTS_MANAGE';
UPDATE iam.permissions SET name = 'Consultar reportes' WHERE code = 'REPORTS_READ';
UPDATE iam.permissions SET name = 'Gestionar reservas' WHERE code = 'RESERVATIONS_MANAGE';
UPDATE iam.permissions SET name = 'Consultar reservas' WHERE code = 'RESERVATIONS_READ';
UPDATE iam.permissions SET name = 'Gestionar roles' WHERE code = 'ROLES_MANAGE';
UPDATE iam.permissions SET name = 'Gestionar soporte' WHERE code = 'SUPPORT_MANAGE';
UPDATE iam.permissions SET name = 'Gestionar usuarios' WHERE code = 'USERS_MANAGE';
UPDATE iam.permissions SET name = 'Consultar usuarios' WHERE code = 'USERS_READ';

UPDATE fleet.vehicle_statuses SET name = 'Disponible' WHERE code = 'AVAILABLE';
UPDATE fleet.vehicle_statuses SET name = 'Alquilado' WHERE code = 'RENTED';
UPDATE fleet.vehicle_statuses SET name = 'Mantenimiento' WHERE code = 'MAINTENANCE';
UPDATE fleet.vehicle_statuses SET name = 'Inactivo' WHERE code = 'INACTIVE';

UPDATE rental.reservation_statuses SET name = 'Pendiente de pago' WHERE code = 'PENDING_PAYMENT';
UPDATE rental.reservation_statuses SET name = 'Confirmada' WHERE code = 'CONFIRMED';
UPDATE rental.reservation_statuses SET name = 'En curso' WHERE code = 'IN_PROGRESS';
UPDATE rental.reservation_statuses SET name = 'Finalizada' WHERE code = 'COMPLETED';
UPDATE rental.reservation_statuses SET name = 'Cancelada por tiempo' WHERE code = 'CANCELLED_BY_TIMEOUT';
UPDATE rental.reservation_statuses SET name = 'Cancelada por el usuario' WHERE code = 'CANCELLED_BY_USER';
UPDATE rental.reservation_statuses SET name = 'Rechazada' WHERE code = 'REJECTED';
UPDATE rental.reservation_statuses SET name = 'Pendiente de revisión de documentos' WHERE code = 'PENDING_DOCUMENT_REVIEW';
UPDATE rental.reservation_statuses SET name = 'Pendiente del horario de la sucursal' WHERE code = 'PENDING_SCHEDULE';

UPDATE iam.document_statuses SET name = 'Pendiente' WHERE code = 'PENDING';
UPDATE iam.document_statuses SET name = 'Aprobado' WHERE code = 'APPROVED';
UPDATE iam.document_statuses SET name = 'Rechazado' WHERE code = 'REJECTED';

UPDATE billing.payment_methods SET name = 'Efectivo' WHERE code = 'CASH';
UPDATE billing.payment_methods SET name = 'Tarjeta de crédito' WHERE code = 'CREDIT_CARD';
UPDATE billing.payment_methods SET name = 'Tarjeta de débito' WHERE code = 'DEBIT_CARD';

UPDATE billing.payment_statuses SET name = 'Pendiente' WHERE code = 'PENDING';
UPDATE billing.payment_statuses SET name = 'Aprobado' WHERE code = 'APPROVED';
UPDATE billing.payment_statuses SET name = 'Rechazado' WHERE code = 'DECLINED';
UPDATE billing.payment_statuses SET name = 'Reembolsado' WHERE code = 'REFUNDED';
UPDATE billing.payment_statuses SET name = 'Anulado' WHERE code = 'VOIDED';

UPDATE fleet.transmission_types SET name = 'Automática' WHERE code = 'AUTOMATIC';
UPDATE fleet.fuel_types SET name = 'Gasolina' WHERE code = 'GASOLINE';
UPDATE fleet.fuel_types SET name = 'Diésel' WHERE code = 'DIESEL';
UPDATE fleet.fuel_types SET name = 'Eléctrico' WHERE code = 'ELECTRIC';
UPDATE fleet.fuel_types SET name = 'Híbrido' WHERE code = 'HYBRID';

UPDATE iam.document_types SET name = 'Cédula de ciudadanía' WHERE code = 'CC';
UPDATE iam.document_types SET name = 'Cédula de extranjería' WHERE code = 'CE';
UPDATE iam.document_types SET name = 'Pasaporte' WHERE code = 'PASSPORT';
UPDATE iam.document_types SET name = 'Número de identificación tributaria (NIT)' WHERE code = 'NIT';
UPDATE iam.document_types SET name = 'Licencia de conducción' WHERE code = 'DRIVER_LICENSE';
UPDATE iam.document_types SET name = 'Tarjeta de identidad' WHERE code = 'TI';

UPDATE contract.contract_statuses SET name = 'Borrador' WHERE code = 'DRAFT';
UPDATE contract.contract_statuses SET name = 'Pendiente de firma' WHERE code = 'PENDING_SIGNATURE';
UPDATE contract.contract_statuses SET name = 'Activo' WHERE code = 'ACTIVE';
UPDATE contract.contract_statuses SET name = 'Finalizado' WHERE code = 'FINALIZED';
UPDATE contract.contract_statuses SET name = 'Cancelado' WHERE code = 'CANCELLED';
