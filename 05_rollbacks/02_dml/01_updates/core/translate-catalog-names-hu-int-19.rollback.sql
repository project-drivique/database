UPDATE iam.roles SET name = 'Super Administrator', description = 'Full system access and tenant management' WHERE code = 'SUPER_ADMIN';
UPDATE iam.roles SET name = 'Branch Administrator', description = 'Branch-level operational management' WHERE code = 'BRANCH_ADMIN';
UPDATE iam.roles SET name = 'Employee', description = 'Front-desk operations, inspections, and customer service' WHERE code = 'EMPLOYEE';
UPDATE iam.roles SET name = 'Customer', description = 'End-user vehicle rental and profile self-service' WHERE code = 'CUSTOMER';

UPDATE iam.permissions SET name = 'Read Audit Log' WHERE code = 'AUDIT_READ';
UPDATE iam.permissions SET name = 'Manage Branches' WHERE code = 'BRANCHES_MANAGE';
UPDATE iam.permissions SET name = 'Manage Brand Configuration' WHERE code = 'BRAND_CONFIGURATION_MANAGE';
UPDATE iam.permissions SET name = 'Manage Catalog' WHERE code = 'CATALOG_MANAGE';
UPDATE iam.permissions SET name = 'Manage Contracts' WHERE code = 'CONTRACTS_MANAGE';
UPDATE iam.permissions SET name = 'Manage Fleet' WHERE code = 'FLEET_MANAGE';
UPDATE iam.permissions SET name = 'Manage Payments' WHERE code = 'PAYMENTS_MANAGE';
UPDATE iam.permissions SET name = 'Read Reports' WHERE code = 'REPORTS_READ';
UPDATE iam.permissions SET name = 'Manage Reservations' WHERE code = 'RESERVATIONS_MANAGE';
UPDATE iam.permissions SET name = 'Read Reservations' WHERE code = 'RESERVATIONS_READ';
UPDATE iam.permissions SET name = 'Manage Roles' WHERE code = 'ROLES_MANAGE';
UPDATE iam.permissions SET name = 'Manage Support' WHERE code = 'SUPPORT_MANAGE';
UPDATE iam.permissions SET name = 'Manage Users' WHERE code = 'USERS_MANAGE';
UPDATE iam.permissions SET name = 'Read Users' WHERE code = 'USERS_READ';

UPDATE fleet.vehicle_statuses SET name = 'Available' WHERE code = 'AVAILABLE';
UPDATE fleet.vehicle_statuses SET name = 'Rented' WHERE code = 'RENTED';
UPDATE fleet.vehicle_statuses SET name = 'Maintenance' WHERE code = 'MAINTENANCE';
UPDATE fleet.vehicle_statuses SET name = 'Inactive' WHERE code = 'INACTIVE';

UPDATE rental.reservation_statuses SET name = 'Pending payment' WHERE code = 'PENDING_PAYMENT';
UPDATE rental.reservation_statuses SET name = 'Confirmed' WHERE code = 'CONFIRMED';
UPDATE rental.reservation_statuses SET name = 'In progress' WHERE code = 'IN_PROGRESS';
UPDATE rental.reservation_statuses SET name = 'Completed' WHERE code = 'COMPLETED';
UPDATE rental.reservation_statuses SET name = 'Cancelled by timeout' WHERE code = 'CANCELLED_BY_TIMEOUT';
UPDATE rental.reservation_statuses SET name = 'Cancelled by user' WHERE code = 'CANCELLED_BY_USER';
UPDATE rental.reservation_statuses SET name = 'Rejected' WHERE code = 'REJECTED';
UPDATE rental.reservation_statuses SET name = 'Pending document review' WHERE code = 'PENDING_DOCUMENT_REVIEW';
UPDATE rental.reservation_statuses SET name = 'Pending branch schedule' WHERE code = 'PENDING_SCHEDULE';

UPDATE iam.document_statuses SET name = 'Pending' WHERE code = 'PENDING';
UPDATE iam.document_statuses SET name = 'Approved' WHERE code = 'APPROVED';
UPDATE iam.document_statuses SET name = 'Rejected' WHERE code = 'REJECTED';

UPDATE billing.payment_methods SET name = 'Cash' WHERE code = 'CASH';
UPDATE billing.payment_methods SET name = 'Credit card' WHERE code = 'CREDIT_CARD';
UPDATE billing.payment_methods SET name = 'Debit card' WHERE code = 'DEBIT_CARD';

UPDATE billing.payment_statuses SET name = 'Pending' WHERE code = 'PENDING';
UPDATE billing.payment_statuses SET name = 'Approved' WHERE code = 'APPROVED';
UPDATE billing.payment_statuses SET name = 'Declined' WHERE code = 'DECLINED';
UPDATE billing.payment_statuses SET name = 'Refunded' WHERE code = 'REFUNDED';
UPDATE billing.payment_statuses SET name = 'Voided' WHERE code = 'VOIDED';

UPDATE fleet.transmission_types SET name = 'Automatic' WHERE code = 'AUTOMATIC';
UPDATE fleet.fuel_types SET name = 'Gasoline' WHERE code = 'GASOLINE';
UPDATE fleet.fuel_types SET name = 'Diesel' WHERE code = 'DIESEL';
UPDATE fleet.fuel_types SET name = 'Electric' WHERE code = 'ELECTRIC';
UPDATE fleet.fuel_types SET name = 'Hybrid' WHERE code = 'HYBRID';

UPDATE iam.document_types SET name = 'Citizenship Card' WHERE code = 'CC';
UPDATE iam.document_types SET name = 'Foreign Resident ID' WHERE code = 'CE';
UPDATE iam.document_types SET name = 'Passport' WHERE code = 'PASSPORT';
UPDATE iam.document_types SET name = 'Tax Identification Number' WHERE code = 'NIT';
UPDATE iam.document_types SET name = 'Driver License' WHERE code = 'DRIVER_LICENSE';
UPDATE iam.document_types SET name = 'Identity Card' WHERE code = 'TI';

UPDATE contract.contract_statuses SET name = 'Draft' WHERE code = 'DRAFT';
UPDATE contract.contract_statuses SET name = 'Pending Signature' WHERE code = 'PENDING_SIGNATURE';
UPDATE contract.contract_statuses SET name = 'Active' WHERE code = 'ACTIVE';
UPDATE contract.contract_statuses SET name = 'Finalized' WHERE code = 'FINALIZED';
UPDATE contract.contract_statuses SET name = 'Cancelled' WHERE code = 'CANCELLED';
