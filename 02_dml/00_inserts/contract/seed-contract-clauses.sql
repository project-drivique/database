INSERT INTO contract.contract_clauses (version, sort_order, title, content, is_active) VALUES
    ('v1.0', 1, 'Objeto del Contrato', 'El arrendador entrega en arrendamiento al arrendatario el vehículo automotor descrito en la carátula del presente contrato.', TRUE),
    ('v1.0', 2, 'Uso y Destinación', 'El arrendatario se compromete a usar el vehículo exclusivamente para transporte particular lícito dentro del territorio nacional autorizado.', TRUE),
    ('v1.0', 3, 'Obligaciones del Arrendatario', 'El arrendatario deberá restituir el vehículo en la fecha, hora y sede acordadas, en el mismo estado mecánico y estético recibido.', TRUE),
    ('v1.0', 4, 'Depósito de Garantía y Cargos', 'El arrendatario autoriza el bloqueo del depósito de garantía y el cobro de deducibles, multas de tránsito o combustible faltante.', TRUE),
    ('v1.0', 5, 'Firma y Validez Jurídica', 'Las partes reconocen plena validez legal y probatoria a la firma electrónica y biométrica capturada en la plataforma Drivique.', TRUE)
ON CONFLICT (version, sort_order) DO NOTHING;
