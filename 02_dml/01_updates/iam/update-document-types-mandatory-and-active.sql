-- Solo la licencia de conducción es obligatoria para todos los conductores.
-- Los tipos de documento de identidad individuales (CC, CE, PASSPORT, etc.) no son obligatorios simultáneamente.
UPDATE iam.document_types
SET is_mandatory = FALSE;

UPDATE iam.document_types
SET is_mandatory = TRUE
WHERE code = 'DRIVER_LICENSE';

-- Deshabilitar TI para alquiler de vehículos (solo mayores de edad con licencia)
UPDATE iam.document_types
SET is_active = FALSE
WHERE code = 'TI';
