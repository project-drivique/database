INSERT INTO support.notification_templates (
    code, name, event_type, channel, subject_template, body_template
) VALUES
(
    'REGISTRATION_WELCOME_EMAIL',
    'Bienvenida al registrarse',
    'REGISTRATION',
    'EMAIL',
    '¡Bienvenido a Drivique, {{firstName}}!',
    'Hola {{firstName}}, tu cuenta en Drivique ha sido creada con éxito. Ya puedes explorar y reservar tu vehículo.'
),
(
    'PAYMENT_SUCCESS_EMAIL',
    'Confirmación de pago exitoso',
    'PAYMENT',
    'EMAIL',
    'Comprobante de pago - Reserva {{bookingCode}}',
    'Hemos recibido tu pago de {{amount}} {{currency}} para la reserva {{bookingCode}}. Adjuntamos el recibo correspondiente.'
),
(
    'PAYMENT_SUCCESS_IN_APP',
    'Comprobante in-app de pago exitoso',
    'PAYMENT',
    'IN_APP',
    '¡Pago exitoso de tu reserva {{bookingCode}}!',
    'Tu pago de {{amount}} {{currency}} fue aprobado exitosamente. Tu reserva está confirmada.'
),
(
    'PAYMENT_FAILED_EMAIL',
    'Notificación de fallo en pago',
    'PAYMENT',
    'EMAIL',
    'Problema con tu pago - Reserva {{bookingCode}}',
    'No pudimos procesar tu pago de {{amount}} {{currency}}. Por favor actualiza tu método de pago para mantener tu reserva.'
),
(
    'PAYMENT_FAILED_IN_APP',
    'Notificación in-app de pago rechazado',
    'PAYMENT',
    'IN_APP',
    'Pago rechazado - Reserva {{bookingCode}}',
    'La transacción de {{amount}} {{currency}} fue rechazada. Reintenta tu pago para mantener la reserva.'
),
(
    'RESERVATION_CONFIRMATION_EMAIL',
    'Confirmación de reserva',
    'RESERVATION',
    'EMAIL',
    'Tu reserva {{bookingCode}} está confirmada',
    'Tu reserva del vehículo {{vehicleModel}} para el {{pickupDate}} en la sede {{branchName}} ha sido confirmada.'
),
(
    'RESERVATION_CONFIRMATION_PUSH',
    'Push de reserva confirmada',
    'RESERVATION',
    'PUSH',
    'Reserva confirmada',
    'Tu reserva {{bookingCode}} está lista. Consulta los detalles de recogida en la app.'
),
(
    'RESERVATION_CONFIRMATION_IN_APP',
    'Confirmación in-app de reserva',
    'RESERVATION',
    'IN_APP',
    'Reserva {{bookingCode}} confirmada',
    'Tu reserva ha sido confirmada con éxito. Ya puedes revisar los detalles y firmar el contrato.'
),
(
    'RESERVATION_CANCELLED_EMAIL',
    'Cancelación de reserva',
    'CANCELLATION',
    'EMAIL',
    'Reserva {{bookingCode}} cancelada',
    'Tu reserva {{bookingCode}} ha sido cancelada conforme a nuestras políticas de cancelación.'
),
(
    'RESERVATION_CANCELLED_IN_APP',
    'Cancelación in-app de reserva',
    'CANCELLATION',
    'IN_APP',
    'Reserva {{bookingCode}} cancelada',
    'Tu reserva {{bookingCode}} ha sido cancelada ({{reason}}). El vehículo ha sido liberado.'
),
(
    'PAYMENT_EXPIRATION_WARNING_EMAIL',
    'Aviso de vencimiento de plazo de pago',
    'PAYMENT_EXPIRATION_WARNING',
    'EMAIL',
    'Plazo de pago por vencer - Reserva {{bookingCode}}',
    'Hola, te recordamos que el plazo para pagar tu reserva {{bookingCode}} está próximo a vencer. Completa tu pago para no perder tu vehículo.'
),
(
    'PAYMENT_EXPIRATION_WARNING_IN_APP',
    'Aviso in-app de vencimiento de pago',
    'PAYMENT_EXPIRATION_WARNING',
    'IN_APP',
    'Plazo de pago por vencer - Reserva {{bookingCode}}',
    'Atención: Tu plazo para pagar la reserva {{bookingCode}} vencerá pronto. Realiza el pago para no perder la reserva.'
),
(
    'CONTRACT_SIGNATURE_EMAIL',
    'Solicitud de firma de contrato',
    'CONTRACT',
    'EMAIL',
    'Firma digital requerida - Contrato {{contractNumber}}',
    'Tu contrato de alquiler {{contractNumber}} está listo para firma digital. Accede para completarlo antes de la entrega.'
),
(
    'VEHICLE_DELIVERY_PUSH',
    'Entrega de vehículo confirmada',
    'DELIVERY',
    'PUSH',
    'Vehículo entregado',
    'La entrega de tu vehículo {{vehiclePlate}} fue registrada exitosamente. ¡Disfruta tu viaje!'
),
(
    'VEHICLE_RETURN_EMAIL',
    'Cierre y devolución de vehículo',
    'RETURN',
    'EMAIL',
    'Devolución completada - Contrato {{contractNumber}}',
    'La inspección de devolución del vehículo {{vehiclePlate}} ha concluido satisfactoriamente.'
),
(
    'DOCUMENT_STATUS_UPDATE_PUSH',
    'Actualización de validación documental',
    'DOCUMENT',
    'PUSH',
    'Estado de tus documentos KYC',
    'Tu documento {{documentType}} ha cambiado a estado {{status}}.'
),
(
    'INCIDENT_REGISTERED_EMAIL',
    'Reporte de incidencia recibido',
    'INCIDENT',
    'EMAIL',
    'Incidencia {{incidentCode}} recibida',
    'Hemos recibido tu reporte de incidencia {{incidentCode}}. Nuestro equipo de soporte está revisando el caso.'
),
(
    'INCIDENT_UPDATE_IN_APP',
    'Actualización de incidencia en la app',
    'INCIDENT',
    'IN_APP',
    'Actualización en tu reporte {{incidentCode}}',
    'Hay novedades en la atención de tu incidencia {{incidentCode}}. Revisa el detalle en el centro de ayuda.'
)
ON CONFLICT (code) DO NOTHING;
