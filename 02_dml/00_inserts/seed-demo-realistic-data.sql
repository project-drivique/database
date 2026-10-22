-- =============================================================================
-- DRIVIQUE - SEED DE DATOS REALISTAS PARA SUSTENTACIÓN / DEMOSTRACIÓN OFICIAL
-- Genera clientes reales colombianos, reservas en diversos estados,
-- expedientes KYC (aprobados y pendientes), incidencias operativas y reseñas.
-- Seguro y reejecutable: utiliza ON CONFLICT / WHERE NOT EXISTS.
-- =============================================================================

DO $$
DECLARE
    v_cc_id UUID;
    v_lic_id UUID;
    v_role_customer_id UUID;
    v_status_pending_kyc_id UUID;
    v_status_approved_kyc_id UUID;
    
    v_branch_bogota UUID;
    v_branch_med_centro UUID;
    v_branch_med_aero UUID;
    v_branch_cali UUID;
    v_branch_baq UUID;
    
    v_veh_rav4 UUID;
    v_veh_logan UUID;
    v_veh_cx5 UUID;
    v_veh_onix UUID;
    v_veh_hilux UUID;
    v_veh_bmw UUID;
    
    v_res_pending_doc UUID;
    v_res_pending_pay UUID;
    v_res_confirmed UUID;
    v_res_in_progress UUID;
    v_res_completed UUID;
    
    v_cov_standard UUID;
    v_cov_premium UUID;
    v_mileage_unlimited UUID;
    v_mileage_standard UUID;
    
    v_admin_user_id UUID;
    v_encargado_bogota_id UUID;
    v_encargado_med_id UUID;

    v_res_id_1 UUID := 'd0000000-0000-0000-0000-000000000001';
    v_res_id_2 UUID := 'd0000000-0000-0000-0000-000000000002';
    v_res_id_3 UUID := 'd0000000-0000-0000-0000-000000000003';
    v_res_id_4 UUID := 'd0000000-0000-0000-0000-000000000004';
    v_res_id_5 UUID := 'd0000000-0000-0000-0000-000000000005';
    v_res_id_6 UUID := 'd0000000-0000-0000-0000-000000000006';

BEGIN
    -- 1. Obtener catálogos base
    SELECT id INTO v_cc_id FROM iam.document_types WHERE code = 'CC' LIMIT 1;
    SELECT id INTO v_lic_id FROM iam.document_types WHERE code IN ('DRIVER_LICENSE', 'LIC', 'LICENCIA') LIMIT 1;
    IF v_cc_id IS NULL THEN SELECT id INTO v_cc_id FROM iam.document_types LIMIT 1; END IF;
    IF v_lic_id IS NULL THEN SELECT id INTO v_lic_id FROM iam.document_types WHERE id <> v_cc_id LIMIT 1; END IF;
    IF v_lic_id IS NULL THEN v_lic_id := v_cc_id; END IF;

    SELECT id INTO v_role_customer_id FROM iam.roles WHERE code = 'CUSTOMER' LIMIT 1;
    IF v_role_customer_id IS NULL THEN SELECT id INTO v_role_customer_id FROM iam.roles LIMIT 1; END IF;
    
    SELECT id INTO v_status_pending_kyc_id FROM iam.document_statuses WHERE code = 'PENDING' LIMIT 1;
    SELECT id INTO v_status_approved_kyc_id FROM iam.document_statuses WHERE code = 'APPROVED' LIMIT 1;

    SELECT id INTO v_branch_bogota FROM location.branches WHERE name ILIKE '%Bogot%' LIMIT 1;
    SELECT id INTO v_branch_med_centro FROM location.branches WHERE name ILIKE '%Centro%' OR name ILIKE '%Medell%' LIMIT 1;
    SELECT id INTO v_branch_med_aero FROM location.branches WHERE name ILIKE '%Aeropuerto%' LIMIT 1;
    SELECT id INTO v_branch_cali FROM location.branches WHERE name ILIKE '%Cali%' LIMIT 1;
    SELECT id INTO v_branch_baq FROM location.branches WHERE name ILIKE '%Barranquilla%' LIMIT 1;

    -- Si alguna sucursal no coincide por nombre exacto, tomar la primera
    IF v_branch_bogota IS NULL THEN SELECT id INTO v_branch_bogota FROM location.branches LIMIT 1; END IF;
    IF v_branch_med_centro IS NULL THEN v_branch_med_centro := v_branch_bogota; END IF;
    IF v_branch_med_aero IS NULL THEN v_branch_med_aero := v_branch_bogota; END IF;
    IF v_branch_cali IS NULL THEN v_branch_cali := v_branch_bogota; END IF;
    IF v_branch_baq IS NULL THEN v_branch_baq := v_branch_bogota; END IF;

    -- Vehículos
    SELECT id INTO v_veh_rav4 FROM fleet.vehicles WHERE plate = 'ABC-123' LIMIT 1;
    SELECT id INTO v_veh_logan FROM fleet.vehicles WHERE plate = 'DEF-456' LIMIT 1;
    SELECT id INTO v_veh_cx5 FROM fleet.vehicles WHERE plate = 'GHI-789' LIMIT 1;
    SELECT id INTO v_veh_onix FROM fleet.vehicles WHERE plate = 'JKL-012' LIMIT 1;
    SELECT id INTO v_veh_hilux FROM fleet.vehicles WHERE plate = 'MNO-345' LIMIT 1;
    SELECT id INTO v_veh_bmw FROM fleet.vehicles WHERE plate = 'PQR-678' LIMIT 1;

    IF v_veh_rav4 IS NULL THEN SELECT id INTO v_veh_rav4 FROM fleet.vehicles LIMIT 1; END IF;
    IF v_veh_logan IS NULL THEN v_veh_logan := v_veh_rav4; END IF;
    IF v_veh_cx5 IS NULL THEN v_veh_cx5 := v_veh_rav4; END IF;
    IF v_veh_onix IS NULL THEN v_veh_onix := v_veh_rav4; END IF;
    IF v_veh_hilux IS NULL THEN v_veh_hilux := v_veh_rav4; END IF;
    IF v_veh_bmw IS NULL THEN v_veh_bmw := v_veh_rav4; END IF;

    -- Estados de reserva
    SELECT id INTO v_res_confirmed FROM rental.reservation_statuses WHERE code = 'CONFIRMED' LIMIT 1;
    SELECT id INTO v_res_in_progress FROM rental.reservation_statuses WHERE code = 'IN_PROGRESS' LIMIT 1;
    SELECT id INTO v_res_completed FROM rental.reservation_statuses WHERE code = 'COMPLETED' LIMIT 1;
    SELECT id INTO v_res_pending_doc FROM rental.reservation_statuses WHERE code = 'PENDING_DOCUMENT_REVIEW' LIMIT 1;
    SELECT id INTO v_res_pending_pay FROM rental.reservation_statuses WHERE code = 'PENDING_PAYMENT' LIMIT 1;

    -- Si no existe PENDING_DOCUMENT_REVIEW, crearlo
    IF v_res_pending_doc IS NULL THEN
        INSERT INTO rental.reservation_statuses (code, name, blocks_availability)
        VALUES ('PENDING_DOCUMENT_REVIEW', 'Pending document review', TRUE)
        RETURNING id INTO v_res_pending_doc;
    END IF;
    IF v_res_confirmed IS NULL THEN v_res_confirmed := v_res_pending_doc; END IF;
    IF v_res_in_progress IS NULL THEN v_res_in_progress := v_res_confirmed; END IF;
    IF v_res_completed IS NULL THEN v_res_completed := v_res_confirmed; END IF;
    IF v_res_pending_pay IS NULL THEN v_res_pending_pay := v_res_confirmed; END IF;

    -- Coberturas y kilometrajes
    SELECT id INTO v_cov_standard FROM catalog.insurance_coverages LIMIT 1;
    SELECT id INTO v_cov_premium FROM catalog.insurance_coverages ORDER BY daily_rate DESC LIMIT 1;
    SELECT id INTO v_mileage_standard FROM catalog.mileage_plans LIMIT 1;
    SELECT id INTO v_mileage_unlimited FROM catalog.mileage_plans ORDER BY daily_rate DESC LIMIT 1;

    -- Usuarios revisores / encargados
    SELECT id INTO v_admin_user_id FROM iam.users WHERE email = 'admin@drivique.com' LIMIT 1;
    SELECT id INTO v_encargado_bogota_id FROM iam.users WHERE email = 'encargado.bogota@drivique.com' LIMIT 1;
    SELECT id INTO v_encargado_med_id FROM iam.users WHERE email = 'encargado.medellin.centro@drivique.com' LIMIT 1;

    IF v_admin_user_id IS NULL THEN SELECT id INTO v_admin_user_id FROM iam.users LIMIT 1; END IF;
    IF v_encargado_bogota_id IS NULL THEN v_encargado_bogota_id := v_admin_user_id; END IF;
    IF v_encargado_med_id IS NULL THEN v_encargado_med_id := v_admin_user_id; END IF;

    -- =========================================================================
    -- 2. CLIENTES REALES COLOMBIANOS (Contraseña de todos: Cliente123*)
    -- =========================================================================
    INSERT INTO iam.users (
        id, first_name, last_name, email, document_number, document_type_id,
        phone, birth_date, password_hash, account_status, is_profile_complete, email_verified_at, created_at
    ) VALUES
        ('c0000000-0000-0000-0000-000000000001', 'Alejandro', 'Morales Restrepo', 'alejandro.morales@drivique.com', '1017234589', v_cc_id, '+57 312 458 9210', '1992-05-14', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days'),
        ('c0000000-0000-0000-0000-000000000002', 'Valentina', 'Ospina Gómez', 'valentina.ospina@drivique.com', '1020456781', v_cc_id, '+57 320 674 1123', '1995-11-20', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP - INTERVAL '25 days', CURRENT_TIMESTAMP - INTERVAL '25 days'),
        ('c0000000-0000-0000-0000-000000000003', 'Mateo', 'Rodríguez Cárdenas', 'mateo.rodriguez@drivique.com', '1032890123', v_cc_id, '+57 301 892 4455', '1989-03-08', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_TIMESTAMP - INTERVAL '20 days'),
        ('c0000000-0000-0000-0000-000000000004', 'Camila', 'Herrera Benítez', 'camila.herrera@drivique.com', '1047123984', v_cc_id, '+57 318 903 5566', '1997-08-25', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '15 days'),
        ('c0000000-0000-0000-0000-000000000005', 'Sebastián', 'Vargas Quintero', 'sebastian.vargas@drivique.com', '1088456123', v_cc_id, '+57 315 789 2234', '1991-01-30', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP - INTERVAL '12 days', CURRENT_TIMESTAMP - INTERVAL '12 days'),
        ('c0000000-0000-0000-0000-000000000006', 'Daniela', 'Pineda Salazar', 'daniela.pineda@drivique.com', '1037894120', v_cc_id, '+57 310 445 6677', '1996-09-12', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', FALSE, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
        ('c0000000-0000-0000-0000-000000000007', 'Andrés Felipe', 'Jaramillo Osorio', 'andres.jaramillo@drivique.com', '1019567843', v_cc_id, '+57 317 665 4433', '1994-04-18', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', FALSE, CURRENT_TIMESTAMP - INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '1 hour')
    ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash,
        account_status = 'ACTIVE',
        updated_at = CURRENT_TIMESTAMP;

    -- Asignar rol CUSTOMER a todos ellos
    IF v_role_customer_id IS NOT NULL THEN
        INSERT INTO iam.user_roles (user_id, role_id)
        SELECT u.id, v_role_customer_id
        FROM iam.users u
        WHERE u.email IN (
            'alejandro.morales@drivique.com', 'valentina.ospina@drivique.com',
            'mateo.rodriguez@drivique.com', 'camila.herrera@drivique.com',
            'sebastian.vargas@drivique.com', 'daniela.pineda@drivique.com',
            'andres.jaramillo@drivique.com'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- =========================================================================
    -- 3. EXPEDIENTES KYC (Aprobados y Pendientes de Validación para la Demo)
    -- =========================================================================
    INSERT INTO iam.user_documents (
        user_id, document_type_id, status_id, document_number, front_url, back_url,
        review_notes, reviewed_by, branch_id, reviewed_at, created_at
    ) VALUES
        ('c0000000-0000-0000-0000-000000000001', v_cc_id, v_status_approved_kyc_id, '1017234589', '/uploads/kyc/cc_alejandro_front.pdf', NULL, 'Cédula de ciudadanía legible, bordes completos y vigente.', v_encargado_bogota_id, v_branch_bogota, CURRENT_TIMESTAMP - INTERVAL '29 days', CURRENT_TIMESTAMP - INTERVAL '30 days'),
        ('c0000000-0000-0000-0000-000000000001', v_lic_id, v_status_approved_kyc_id, '1017234589', '/uploads/kyc/lic_alejandro_front.pdf', NULL, 'Licencia categoría B1 verificada en RUNT activo sin comparendos.', v_encargado_bogota_id, v_branch_bogota, CURRENT_TIMESTAMP - INTERVAL '29 days', CURRENT_TIMESTAMP - INTERVAL '30 days'),

        ('c0000000-0000-0000-0000-000000000002', v_cc_id, v_status_approved_kyc_id, '1020456781', '/uploads/kyc/cc_valentina_front.pdf', NULL, 'Documento de identidad verificado correctamente.', v_encargado_med_id, v_branch_med_centro, CURRENT_TIMESTAMP - INTERVAL '24 days', CURRENT_TIMESTAMP - INTERVAL '25 days'),
        ('c0000000-0000-0000-0000-000000000002', v_lic_id, v_status_approved_kyc_id, '1020456781', '/uploads/kyc/lic_valentina_front.pdf', NULL, 'Licencia de conducción categoría C1 aprobada.', v_encargado_med_id, v_branch_med_centro, CURRENT_TIMESTAMP - INTERVAL '24 days', CURRENT_TIMESTAMP - INTERVAL '25 days'),

        ('c0000000-0000-0000-0000-000000000003', v_cc_id, v_status_approved_kyc_id, '1032890123', '/uploads/kyc/cc_mateo_front.pdf', NULL, 'Documento verificado por la sucursal.', v_encargado_bogota_id, v_branch_bogota, CURRENT_TIMESTAMP - INTERVAL '19 days', CURRENT_TIMESTAMP - INTERVAL '20 days'),
        ('c0000000-0000-0000-0000-000000000003', v_lic_id, v_status_approved_kyc_id, '1032890123', '/uploads/kyc/lic_mateo_front.pdf', NULL, 'Licencia B1 vigente validada.', v_encargado_bogota_id, v_branch_bogota, CURRENT_TIMESTAMP - INTERVAL '19 days', CURRENT_TIMESTAMP - INTERVAL '20 days'),

        -- Clientes PENDIENTES (Daniela en Bogotá y Andrés en Medellín) -> Aparecen en Validación de Documentos
        ('c0000000-0000-0000-0000-000000000006', v_cc_id, v_status_pending_kyc_id, '1037894120', '/uploads/kyc/cc_daniela_front.pdf', NULL, NULL, NULL, v_branch_bogota, NULL, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
        ('c0000000-0000-0000-0000-000000000006', v_lic_id, v_status_pending_kyc_id, '1037894120', '/uploads/kyc/lic_daniela_front.pdf', NULL, NULL, NULL, v_branch_bogota, NULL, CURRENT_TIMESTAMP - INTERVAL '2 hours'),

        ('c0000000-0000-0000-0000-000000000007', v_cc_id, v_status_pending_kyc_id, '1019567843', '/uploads/kyc/cc_andres_front.pdf', NULL, NULL, NULL, v_branch_med_centro, NULL, CURRENT_TIMESTAMP - INTERVAL '1 hour'),
        ('c0000000-0000-0000-0000-000000000007', v_lic_id, v_status_pending_kyc_id, '1019567843', '/uploads/kyc/lic_andres_front.pdf', NULL, NULL, NULL, v_branch_med_centro, NULL, CURRENT_TIMESTAMP - INTERVAL '1 hour')
    ON CONFLICT DO NOTHING;

    -- =========================================================================
    -- 4. RESERVAS EN DIFERENTES ESTADOS (CONFIRMED, IN_PROGRESS, COMPLETED, PENDING_DOC)
    -- =========================================================================
    
    -- Reserva 1: Alejandro - Toyota RAV4 - CONFIRMADA (Bogotá)
    INSERT INTO rental.reservations (
        id, code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        cash_payment_branch_id, pickup_date, return_date, daily_rate, total_estimated,
        blocks_availability, created_at
    ) VALUES (
        v_res_id_1, 'RES-2026-BOG-0101', 'c0000000-0000-0000-0000-000000000001', v_veh_rav4,
        v_res_confirmed, v_cov_premium, v_mileage_unlimited,
        v_branch_bogota, CURRENT_TIMESTAMP + INTERVAL '1 day', CURRENT_TIMESTAMP + INTERVAL '4 days',
        220000.00, 825000.00, TRUE, CURRENT_TIMESTAMP - INTERVAL '2 days'
    ) ON CONFLICT (code) DO NOTHING;

    -- Reserva 2: Valentina - Mazda CX-5 - EN CURSO (Medellín Centro)
    INSERT INTO rental.reservations (
        id, code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        cash_payment_branch_id, pickup_date, return_date, daily_rate, total_estimated,
        blocks_availability, created_at
    ) VALUES (
        v_res_id_2, 'RES-2026-MDE-0204', 'c0000000-0000-0000-0000-000000000002', v_veh_cx5,
        v_res_in_progress, v_cov_standard, v_mileage_standard,
        v_branch_med_centro, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP + INTERVAL '2 days',
        240000.00, 795000.00, TRUE, CURRENT_TIMESTAMP - INTERVAL '3 days'
    ) ON CONFLICT (code) DO NOTHING;

    -- Reserva 3: Mateo - Renault Logan - COMPLETADA (Bogotá)
    INSERT INTO rental.reservations (
        id, code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        cash_payment_branch_id, pickup_date, return_date, daily_rate, total_estimated,
        blocks_availability, created_at
    ) VALUES (
        v_res_id_3, 'RES-2026-BOG-0098', 'c0000000-0000-0000-0000-000000000003', v_veh_logan,
        v_res_completed, v_cov_standard, v_mileage_standard,
        v_branch_bogota, CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '7 days',
        120000.00, 420000.00, FALSE, CURRENT_TIMESTAMP - INTERVAL '12 days'
    ) ON CONFLICT (code) DO NOTHING;

    -- Reserva 4: Camila - Chevrolet Onix - CONFIRMADA (Medellín Aeropuerto)
    INSERT INTO rental.reservations (
        id, code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        cash_payment_branch_id, pickup_date, return_date, daily_rate, total_estimated,
        blocks_availability, created_at
    ) VALUES (
        v_res_id_4, 'RES-2026-MDE-0312', 'c0000000-0000-0000-0000-000000000004', v_veh_onix,
        v_res_confirmed, v_cov_standard, v_mileage_unlimited,
        v_branch_med_aero, CURRENT_TIMESTAMP + INTERVAL '2 days', CURRENT_TIMESTAMP + INTERVAL '6 days',
        110000.00, 580000.00, TRUE, CURRENT_TIMESTAMP - INTERVAL '1 day'
    ) ON CONFLICT (code) DO NOTHING;

    -- Reserva 5: Sebastián - Toyota Hilux - COMPLETADA (Cali)
    INSERT INTO rental.reservations (
        id, code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        cash_payment_branch_id, pickup_date, return_date, daily_rate, total_estimated,
        blocks_availability, created_at
    ) VALUES (
        v_res_id_5, 'RES-2026-CAL-0055', 'c0000000-0000-0000-0000-000000000005', v_veh_hilux,
        v_res_completed, v_cov_premium, v_mileage_unlimited,
        v_branch_cali, CURRENT_TIMESTAMP - INTERVAL '8 days', CURRENT_TIMESTAMP - INTERVAL '4 days',
        320000.00, 1540000.00, FALSE, CURRENT_TIMESTAMP - INTERVAL '9 days'
    ) ON CONFLICT (code) DO NOTHING;

    -- Reserva 6: Daniela - BMW Serie 3 - PENDIENTE DE REVISIÓN DOCUMENTAL (Bogotá)
    INSERT INTO rental.reservations (
        id, code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        cash_payment_branch_id, pickup_date, return_date, daily_rate, total_estimated,
        blocks_availability, created_at
    ) VALUES (
        v_res_id_6, 'RES-2026-BOG-0155', 'c0000000-0000-0000-0000-000000000006', v_veh_bmw,
        v_res_pending_doc, v_cov_premium, v_mileage_unlimited,
        v_branch_bogota, CURRENT_TIMESTAMP + INTERVAL '3 days', CURRENT_TIMESTAMP + INTERVAL '5 days',
        450000.00, 1060000.00, TRUE, CURRENT_TIMESTAMP - INTERVAL '2 hours'
    ) ON CONFLICT (code) DO NOTHING;

    -- Puntos de entrega y devolución de sucursal
    INSERT INTO rental.reservation_delivery_points (reservation_id, point_type, modality, branch_id)
    VALUES
        (v_res_id_1, 'PICKUP', 'BRANCH', v_branch_bogota),
        (v_res_id_1, 'RETURN', 'BRANCH', v_branch_bogota),
        (v_res_id_2, 'PICKUP', 'BRANCH', v_branch_med_centro),
        (v_res_id_2, 'RETURN', 'BRANCH', v_branch_med_centro),
        (v_res_id_3, 'PICKUP', 'BRANCH', v_branch_bogota),
        (v_res_id_3, 'RETURN', 'BRANCH', v_branch_bogota),
        (v_res_id_4, 'PICKUP', 'BRANCH', v_branch_med_aero),
        (v_res_id_4, 'RETURN', 'BRANCH', v_branch_med_aero),
        (v_res_id_5, 'PICKUP', 'BRANCH', v_branch_cali),
        (v_res_id_5, 'RETURN', 'BRANCH', v_branch_cali),
        (v_res_id_6, 'PICKUP', 'BRANCH', v_branch_bogota),
        (v_res_id_6, 'RETURN', 'BRANCH', v_branch_bogota)
    ON CONFLICT (reservation_id, point_type) DO NOTHING;

    -- =========================================================================
    -- 5. RESEÑAS REALISTAS DE SUCURSAL Y VEHÍCULO
    -- =========================================================================
    INSERT INTO rental.branch_reviews (
        branch_id, user_id, reservation_id, rating, comment, manager_reply, replied_by, replied_at, created_at
    ) VALUES
        (v_branch_bogota, 'c0000000-0000-0000-0000-000000000001', v_res_id_1, 5,
         'Excelente atención en la sede Bogotá Centro. La camioneta RAV4 estaba impecable, tanque lleno y el proceso de entrega tomó menos de 10 minutos. Totalmente recomendados.',
         'Muchas gracias Alejandro, fue un placer atenderte. Esperamos que disfrutes tu viaje y verte pronto de nuevo en Drivique.',
         v_encargado_bogota_id, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '2 days'),

        (v_branch_med_centro, 'c0000000-0000-0000-0000-000000000002', v_res_id_2, 5,
         'El Mazda CX-5 se comportó excelente en carretera hacia Guatapé. Muy cómodo, suave y con excelente rendimiento. La atención en Medellín Centro fue súper ágil.',
         '¡Hola Valentina! Nos alegra mucho saber que tu viaje a Guatapé fue un éxito. Gracias por confiar en nuestra flota.',
         v_encargado_med_id, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '2 days'),

        (v_branch_cali, 'c0000000-0000-0000-0000-000000000005', v_res_id_5, 5,
         'La Hilux 4x4 es una máquina insuperable para trocha y caminos difíciles. El personal en Cali fue muy atento y me entregaron el vehículo en perfectas condiciones mecánicas.',
         'Gracias Sebastián por preferirnos en Cali. Siempre a tu entera disposición para tus recorridos.',
         v_encargado_bogota_id, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '3 days')
    ON CONFLICT (reservation_id, branch_id) DO NOTHING;

    -- Calificaciones de vehículos
    INSERT INTO rental.vehicle_ratings (
        reservation_id, vehicle_id, user_id, rating, comment, created_at
    ) VALUES
        (v_res_id_1, v_veh_rav4, 'c0000000-0000-0000-0000-000000000001', 5,
         'La RAV4 Hybrid es comodísima, silenciosa y muy económica en combustible. Espacio de baúl ideal para equipaje familiar.', CURRENT_TIMESTAMP - INTERVAL '2 days'),
        (v_res_id_2, v_veh_cx5, 'c0000000-0000-0000-0000-000000000002', 5,
         'Excelente camioneta, diseño interior de lujo y respuesta inmediata en subidas de montaña.', CURRENT_TIMESTAMP - INTERVAL '2 days'),
        (v_res_id_5, v_veh_hilux, 'c0000000-0000-0000-0000-000000000005', 5,
         'Fuerza y tracción excelentes. Aire acondicionado enfría rapidísimo bajo el calor de Cali.', CURRENT_TIMESTAMP - INTERVAL '3 days')
    ON CONFLICT (reservation_id) DO NOTHING;

    -- =========================================================================
    -- 6. REPORTES DE INCIDENCIAS OPERATIVAS REALES (Gestión de Flota)
    -- =========================================================================
    INSERT INTO support.incident_reports (
        incident_code, vehicle_id, reservation_id, reported_by_user_id,
        status, priority, subject, description, created_at
    ) VALUES
        ('INC-2026-001', v_veh_logan, v_res_id_3, 'c0000000-0000-0000-0000-000000000003',
         'RESOLVED', 'MEDIUM', 'Pérdida de presión en llanta trasera derecha',
         'El cliente reportó pérdida de presión de aire en la llanta trasera derecha durante su trayecto por la Autopista Norte. Se coordinó asistencia vial y cambio de neumático en 35 minutos. Inspección técnica determinó válvula desajustada, resuelto satisfactoriamente.',
         CURRENT_TIMESTAMP - INTERVAL '8 days'),

        ('INC-2026-002', v_veh_logan, NULL, v_encargado_bogota_id,
         'IN_REVIEW', 'LOW', 'Testigo preventivo de mantenimiento a los 28.000 km',
         'El vehículo Logan Intens DEF-456 encendió el testigo preventivo de cambio de aceite y filtros de los 28.000 km. Vehículo programado para revisión preventiva en taller de concesionario.',
         CURRENT_TIMESTAMP - INTERVAL '4 days'),

        ('INC-2026-003', v_veh_cx5, v_res_id_2, 'c0000000-0000-0000-0000-000000000002',
         'OPEN', 'LOW', 'Raspón superficial en paragolpes delantero derecho',
         'Al momento de estacionar en parqueadero de centro comercial se produjo un raspón superficial en el bómper plástico delantero derecho. No compromete partes mecánicas ni sensores.',
         CURRENT_TIMESTAMP - INTERVAL '1 day'),

        ('INC-2026-004', v_veh_hilux, v_res_id_5, 'c0000000-0000-0000-0000-000000000005',
         'CLOSED', 'MEDIUM', 'Objeto olvidado en guantera devuelto al titular',
         'El cliente Sebastián Vargas reportó haber dejado sus gafas de sol formuladas en la gaveta central del vehículo tras la entrega. El encargado de Cali las custodió y coordinó la entrega al titular.',
         CURRENT_TIMESTAMP - INTERVAL '4 days')
    ON CONFLICT (incident_code) DO NOTHING;

    -- Respuestas a incidencias
    INSERT INTO support.incident_responses (
        incident_report_id, author_user_id, message, created_at
    )
    SELECT id, v_encargado_bogota_id, 'Asistencia técnica en sitio completada. Neumático calibrado a 32 PSI.', CURRENT_TIMESTAMP - INTERVAL '7 days'
    FROM support.incident_reports WHERE incident_code = 'INC-2026-001'
    ON CONFLICT DO NOTHING;

    INSERT INTO support.incident_responses (
        incident_report_id, author_user_id, message, created_at
    )
    SELECT id, v_encargado_bogota_id, 'Pertenencia entregada en recepción previa firma de planilla.', CURRENT_TIMESTAMP - INTERVAL '3 days'
    FROM support.incident_reports WHERE incident_code = 'INC-2026-004'
    ON CONFLICT DO NOTHING;

END $$;
