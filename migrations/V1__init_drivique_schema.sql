-- ==============================================================================
-- Flyway Migration: V1__init_drivique_schema.sql
-- Descripción: Inicialización del esquema completo de Drivique
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 0. EXTENSIONES
-- ------------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------------------------
-- 1. SEGURIDAD Y USUARIOS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(40) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS permisos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(80) NOT NULL UNIQUE,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS nacionalidades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    codigo_iso CHAR(2) UNIQUE
);

CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    telefono VARCHAR(30),
    documento_tipo VARCHAR(30) NOT NULL,
    documento_numero VARCHAR(50) NOT NULL UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    nacionalidad_id UUID REFERENCES nacionalidades(id),
    password_hash VARCHAR(255) NOT NULL,
    estado_cuenta VARCHAR(30) NOT NULL DEFAULT 'ACTIVA' CHECK (estado_cuenta IN ('ACTIVA', 'INACTIVA', 'SUSPENDIDA', 'BLOQUEADA', 'PENDIENTE_VERIFICACION')),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    perfil_completo BOOLEAN NOT NULL DEFAULT FALSE,
    intentos_fallidos SMALLINT NOT NULL DEFAULT 0,
    bloqueado_hasta TIMESTAMPTZ,
    email_verificado_at TIMESTAMPTZ,
    ultimo_acceso_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS usuario_roles (
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    rol_id UUID NOT NULL REFERENCES roles(id),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES usuarios(id),
    PRIMARY KEY (usuario_id, rol_id)
);

CREATE TABLE IF NOT EXISTS rol_permisos (
    rol_id UUID NOT NULL REFERENCES roles(id),
    permiso_id UUID NOT NULL REFERENCES permisos(id),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (rol_id, permiso_id)
);

CREATE TABLE IF NOT EXISTS politicas_contrasena (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(80) NOT NULL UNIQUE,
    longitud_minima SMALLINT NOT NULL DEFAULT 12 CHECK (longitud_minima >= 8),
    requiere_mayuscula BOOLEAN NOT NULL DEFAULT TRUE,
    requiere_numero BOOLEAN NOT NULL DEFAULT TRUE,
    requiere_simbolo BOOLEAN NOT NULL DEFAULT TRUE,
    historial_passwords SMALLINT NOT NULL DEFAULT 5 CHECK (historial_passwords >= 0),
    duracion_dias SMALLINT CHECK (duracion_dias IS NULL OR duracion_dias > 0),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS configuracion_seguridad (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clave VARCHAR(100) NOT NULL UNIQUE,
    valor VARCHAR(500) NOT NULL,
    descripcion VARCHAR(255),
    updated_by UUID REFERENCES usuarios(id),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sesiones_usuario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    refresh_token_hash VARCHAR(255) NOT NULL UNIQUE,
    dispositivo_info VARCHAR(255),
    ip_origen INET,
    user_agent VARCHAR(500),
    revocado BOOLEAN NOT NULL DEFAULT FALSE,
    inicio_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expira_at TIMESTAMPTZ NOT NULL,
    cerrada_at TIMESTAMPTZ,
    revocada_at TIMESTAMPTZ,
    CHECK (expira_at > inicio_at)
);

CREATE TABLE IF NOT EXISTS codigos_verificacion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    proposito VARCHAR(40) NOT NULL CHECK (proposito IN ('VERIFICAR_CUENTA', 'RECUPERAR_CONTRASENA', 'SEGUNDO_FACTOR')),
    codigo_hash VARCHAR(255) NOT NULL,
    expira_at TIMESTAMPTZ NOT NULL,
    usado_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Índices para Seguridad y Usuarios
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_documento ON usuarios(documento_tipo, documento_numero);
CREATE INDEX IF NOT EXISTS idx_usuarios_estado_cuenta ON usuarios(estado_cuenta);
CREATE INDEX IF NOT EXISTS idx_roles_codigo ON roles(codigo);
CREATE INDEX IF NOT EXISTS idx_permisos_codigo ON permisos(codigo);
CREATE INDEX IF NOT EXISTS idx_usuario_roles_usuario ON usuario_roles(usuario_id);
CREATE INDEX IF NOT EXISTS idx_usuario_roles_rol ON usuario_roles(rol_id);
CREATE INDEX IF NOT EXISTS idx_rol_permisos_rol ON rol_permisos(rol_id);
CREATE INDEX IF NOT EXISTS idx_rol_permisos_permiso ON rol_permisos(permiso_id);
CREATE INDEX IF NOT EXISTS idx_sesiones_refresh_token_hash ON sesiones_usuario(refresh_token_hash);
CREATE INDEX IF NOT EXISTS idx_sesiones_usuario_id ON sesiones_usuario(usuario_id);
CREATE INDEX IF NOT EXISTS idx_sesiones_revocado ON sesiones_usuario(revocado);
CREATE INDEX IF NOT EXISTS idx_codigos_verificacion_usuario ON codigos_verificacion(usuario_id);

CREATE TABLE IF NOT EXISTS tipos_documento_usuario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(40) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS estados_documento_usuario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS documentos_usuario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    tipo_documento_id UUID NOT NULL REFERENCES tipos_documento_usuario(id),
    estado_id UUID NOT NULL REFERENCES estados_documento_usuario(id),
    url_anverso VARCHAR(1000) NOT NULL,
    url_reverso VARCHAR(1000),
    observacion_revision VARCHAR(500),
    revisado_por UUID REFERENCES usuarios(id),
    revisado_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS consentimientos_usuario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    tipo VARCHAR(60) NOT NULL,
    version_documento VARCHAR(40) NOT NULL,
    aceptado_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_origen INET,
    UNIQUE (usuario_id, tipo, version_documento)
);

-- ------------------------------------------------------------------------------
-- 2. CATÁLOGO Y FLOTA
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS marcas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categorias_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    tarifa_base_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_base_diaria >= 0),
    deposito_garantia NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (deposito_garantia >= 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS tipos_transmision (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS tipos_combustible (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS estados_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(40) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    permite_reserva BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS departamentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS ciudades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    departamento_id UUID NOT NULL REFERENCES departamentos(id),
    nombre VARCHAR(100) NOT NULL,
    UNIQUE (departamento_id, nombre)
);

CREATE TABLE IF NOT EXISTS sedes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(120) NOT NULL UNIQUE,
    direccion VARCHAR(255) NOT NULL,
    ciudad_id UUID NOT NULL REFERENCES ciudades(id),
    pais CHAR(2) NOT NULL DEFAULT 'CO',
    telefono VARCHAR(30),
    permite_pago_efectivo BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS usuario_sucursales (
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    sede_id UUID NOT NULL REFERENCES sedes(id),
    asignado_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, sede_id)
);

CREATE TABLE IF NOT EXISTS vehiculos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    placa VARCHAR(10) NOT NULL UNIQUE,
    marca_id UUID NOT NULL REFERENCES marcas(id),
    categoria_id UUID NOT NULL REFERENCES categorias_vehiculo(id),
    transmision_id UUID NOT NULL REFERENCES tipos_transmision(id),
    combustible_id UUID NOT NULL REFERENCES tipos_combustible(id),
    estado_id UUID NOT NULL REFERENCES estados_vehiculo(id),
    sede_actual_id UUID NOT NULL REFERENCES sedes(id),
    modelo VARCHAR(100) NOT NULL,
    anio SMALLINT NOT NULL CHECK (anio BETWEEN 1900 AND 2100),
    color VARCHAR(50),
    vin VARCHAR(17) UNIQUE,
    capacidad_pasajeros SMALLINT NOT NULL CHECK (capacidad_pasajeros > 0),
    numero_puertas SMALLINT CHECK (numero_puertas > 0),
    capacidad_maletero_litros INTEGER CHECK (capacidad_maletero_litros >= 0),
    cilindraje VARCHAR(40),
    descripcion TEXT,
    destacado BOOLEAN NOT NULL DEFAULT FALSE,
    kilometraje INTEGER NOT NULL DEFAULT 0 CHECK (kilometraje >= 0),
    tarifa_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_diaria >= 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS imagenes_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    url VARCHAR(1000) NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    orden SMALLINT NOT NULL DEFAULT 1 CHECK (orden > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (vehiculo_id, orden)
);

CREATE TABLE IF NOT EXISTS documentos_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    tipo VARCHAR(60) NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    url VARCHAR(1000) NOT NULL,
    vence_at DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS caracteristicas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    grupo VARCHAR(30) NOT NULL CHECK (grupo IN ('CARACTERISTICA', 'EQUIPAMIENTO_TECNOLOGICO')),
    descripcion VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS vehiculo_caracteristicas (
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    caracteristica_id UUID NOT NULL REFERENCES caracteristicas(id),
    PRIMARY KEY (vehiculo_id, caracteristica_id)
);

CREATE TABLE IF NOT EXISTS favoritos_vehiculo (
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, vehiculo_id)
);

CREATE TABLE IF NOT EXISTS servicios_adicionales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    tarifa_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_diaria >= 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS coberturas_seguro (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(500),
    tarifa_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_diaria >= 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS planes_kilometraje (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    kilometros_incluidos INTEGER,
    tarifa_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_diaria >= 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (kilometros_incluidos IS NULL OR kilometros_incluidos > 0)
);

CREATE TABLE IF NOT EXISTS vehiculo_servicios_adicionales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    servicio_adicional_id UUID NOT NULL REFERENCES servicios_adicionales(id),
    tarifa_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_diaria >= 0),
    UNIQUE (vehiculo_id, servicio_adicional_id)
);

CREATE TABLE IF NOT EXISTS vehiculo_coberturas_seguro (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    cobertura_id UUID NOT NULL REFERENCES coberturas_seguro(id),
    tarifa_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_diaria >= 0),
    UNIQUE (vehiculo_id, cobertura_id)
);

CREATE TABLE IF NOT EXISTS vehiculo_planes_kilometraje (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    plan_kilometraje_id UUID NOT NULL REFERENCES planes_kilometraje(id),
    tarifa_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_diaria >= 0),
    tarifa_kilometro_excedente NUMERIC(12,2) CHECK (tarifa_kilometro_excedente >= 0),
    UNIQUE (vehiculo_id, plan_kilometraje_id)
);

CREATE TABLE IF NOT EXISTS tipos_mantenimiento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS mantenimientos_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    tipo_mantenimiento_id UUID NOT NULL REFERENCES tipos_mantenimiento(id),
    fecha_programada DATE NOT NULL,
    fecha_realizada DATE,
    costo NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (costo >= 0),
    descripcion TEXT,
    creado_por UUID REFERENCES usuarios(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (fecha_realizada IS NULL OR fecha_realizada >= fecha_programada)
);

-- ------------------------------------------------------------------------------
-- 3. RESERVAS, CONTRATOS E INSPECCIONES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS estados_reserva (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(40) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    bloquea_disponibilidad BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS reservas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(30) NOT NULL UNIQUE,
    cliente_id UUID NOT NULL REFERENCES usuarios(id),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    estado_id UUID NOT NULL REFERENCES estados_reserva(id),
    vehiculo_cobertura_id UUID REFERENCES vehiculo_coberturas_seguro(id),
    vehiculo_plan_kilometraje_id UUID REFERENCES vehiculo_planes_kilometraje(id),
    sede_pago_efectivo_id UUID REFERENCES sedes(id),
    fecha_recogida TIMESTAMPTZ NOT NULL,
    fecha_devolucion TIMESTAMPTZ NOT NULL,
    tarifa_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_diaria >= 0),
    total_estimado NUMERIC(12,2) NOT NULL CHECK (total_estimado >= 0),
    tarifa_cobertura_diaria NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (tarifa_cobertura_diaria >= 0),
    tarifa_plan_kilometraje_diaria NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (tarifa_plan_kilometraje_diaria >= 0),
    codigo_pago_efectivo VARCHAR(30) UNIQUE,
    vence_pago_efectivo_at TIMESTAMPTZ,
    observaciones VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (fecha_devolucion > fecha_recogida)
);

CREATE TABLE IF NOT EXISTS puntos_reserva (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reserva_id UUID NOT NULL REFERENCES reservas(id),
    tipo VARCHAR(15) NOT NULL CHECK (tipo IN ('RECOGIDA', 'DEVOLUCION')),
    modalidad VARCHAR(15) NOT NULL CHECK (modalidad IN ('SUCURSAL', 'DOMICILIO')),
    sede_id UUID REFERENCES sedes(id),
    ciudad_id UUID REFERENCES ciudades(id),
    barrio VARCHAR(120),
    direccion VARCHAR(255),
    referencias VARCHAR(500),
    UNIQUE (reserva_id, tipo),
    CHECK (
        (modalidad = 'SUCURSAL' AND sede_id IS NOT NULL)
        OR (modalidad = 'DOMICILIO' AND ciudad_id IS NOT NULL AND direccion IS NOT NULL)
    )
);

CREATE TABLE IF NOT EXISTS reserva_servicios_adicionales (
    reserva_id UUID NOT NULL REFERENCES reservas(id),
    vehiculo_servicio_adicional_id UUID NOT NULL REFERENCES vehiculo_servicios_adicionales(id),
    cantidad SMALLINT NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    tarifa_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_diaria >= 0),
    PRIMARY KEY (reserva_id, vehiculo_servicio_adicional_id)
);

CREATE TABLE IF NOT EXISTS estados_contrato (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(40) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS contratos_alquiler (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero VARCHAR(30) NOT NULL UNIQUE,
    reserva_id UUID UNIQUE REFERENCES reservas(id),
    cliente_id UUID NOT NULL REFERENCES usuarios(id),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    estado_id UUID NOT NULL REFERENCES estados_contrato(id),
    sede_recogida_id UUID NOT NULL REFERENCES sedes(id),
    sede_devolucion_id UUID NOT NULL REFERENCES sedes(id),
    inicio_programado_at TIMESTAMPTZ NOT NULL,
    fin_programado_at TIMESTAMPTZ NOT NULL,
    inicio_real_at TIMESTAMPTZ,
    fin_real_at TIMESTAMPTZ,
    valor_base NUMERIC(12,2) NOT NULL CHECK (valor_base >= 0),
    deposito_garantia NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (deposito_garantia >= 0),
    valor_final NUMERIC(12,2) CHECK (valor_final IS NULL OR valor_final >= 0),
    aceptado_at TIMESTAMPTZ,
    pdf_url VARCHAR(1000),
    firma_url VARCHAR(1000),
    firma_trazos JSONB,
    firma_plataforma_url VARCHAR(1000),
    ciudad_firma_id UUID REFERENCES ciudades(id),
    firmado_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (fin_programado_at > inicio_programado_at),
    CHECK (fin_real_at IS NULL OR inicio_real_at IS NULL OR fin_real_at >= inicio_real_at)
);

CREATE TABLE IF NOT EXISTS clausulas_contrato (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version VARCHAR(40) NOT NULL,
    orden SMALLINT NOT NULL CHECK (orden > 0),
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (version, orden)
);

CREATE TABLE IF NOT EXISTS contrato_clausulas (
    contrato_id UUID NOT NULL REFERENCES contratos_alquiler(id),
    clausula_id UUID NOT NULL REFERENCES clausulas_contrato(id),
    PRIMARY KEY (contrato_id, clausula_id)
);

CREATE TABLE IF NOT EXISTS tipos_inspeccion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS inspecciones_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contrato_id UUID NOT NULL REFERENCES contratos_alquiler(id),
    tipo_inspeccion_id UUID NOT NULL REFERENCES tipos_inspeccion(id),
    realizado_por UUID NOT NULL REFERENCES usuarios(id),
    kilometraje INTEGER NOT NULL CHECK (kilometraje >= 0),
    nivel_combustible NUMERIC(5,2) NOT NULL CHECK (nivel_combustible BETWEEN 0 AND 100),
    observaciones TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (contrato_id, tipo_inspeccion_id)
);

CREATE TABLE IF NOT EXISTS items_checklist_inspeccion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(120) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS respuestas_checklist_inspeccion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inspeccion_id UUID NOT NULL REFERENCES inspecciones_vehiculo(id),
    item_checklist_id UUID NOT NULL REFERENCES items_checklist_inspeccion(id),
    conforme BOOLEAN NOT NULL,
    observacion TEXT,
    evidencia_url VARCHAR(1000),
    UNIQUE (inspeccion_id, item_checklist_id)
);

-- ------------------------------------------------------------------------------
-- 4. PAGOS, CALIFICACIONES Y NOTIFICACIONES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS metodos_pago (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(40) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS estados_pago (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(40) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    es_final BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS pagos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contrato_id UUID NOT NULL REFERENCES contratos_alquiler(id),
    metodo_pago_id UUID NOT NULL REFERENCES metodos_pago(id),
    estado_id UUID NOT NULL REFERENCES estados_pago(id),
    proveedor VARCHAR(80),
    referencia_externa VARCHAR(150),
    token_metodo_pago VARCHAR(255),
    monto NUMERIC(12,2) NOT NULL CHECK (monto > 0),
    moneda CHAR(3) NOT NULL DEFAULT 'COP',
    pagado_at TIMESTAMPTZ,
    confirmado_por UUID REFERENCES usuarios(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (proveedor, referencia_externa)
);

CREATE TABLE IF NOT EXISTS comprobantes_pago (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pago_id UUID NOT NULL UNIQUE REFERENCES pagos(id),
    numero VARCHAR(50) NOT NULL UNIQUE,
    url_pdf VARCHAR(1000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS solicitudes_extension_alquiler (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reserva_id UUID NOT NULL REFERENCES reservas(id),
    nueva_fecha_devolucion TIMESTAMPTZ NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('PENDIENTE', 'APROBADA', 'RECHAZADA', 'CANCELADA')),
    monto_adicional NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (monto_adicional >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    respondida_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS metodos_pago_guardados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    proveedor VARCHAR(80) NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    marca VARCHAR(40),
    ultimos_cuatro CHAR(4),
    expira_mes SMALLINT,
    expira_anio SMALLINT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS calificaciones_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reserva_id UUID NOT NULL UNIQUE REFERENCES reservas(id),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    puntuacion SMALLINT NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    comentario VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS canales_notificacion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS estados_notificacion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    es_final BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS notificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    canal_id UUID NOT NULL REFERENCES canales_notificacion(id),
    estado_id UUID NOT NULL REFERENCES estados_notificacion(id),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('GENERAL', 'PROMOCION')),
    asunto VARCHAR(255),
    mensaje TEXT NOT NULL,
    referencia_tipo VARCHAR(80),
    referencia_id UUID,
    proveedor_referencia VARCHAR(150),
    enviado_at TIMESTAMPTZ,
    leido_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS estados_reporte_incidencia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS reportes_incidencia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(30) NOT NULL UNIQUE,
    usuario_id UUID REFERENCES usuarios(id),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),
    reserva_id UUID REFERENCES reservas(id),
    estado_id UUID NOT NULL REFERENCES estados_reporte_incidencia(id),
    asunto VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    prioridad VARCHAR(20) NOT NULL CHECK (prioridad IN ('BAJA', 'MEDIA', 'ALTA')),
    creado_por UUID REFERENCES usuarios(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS respuestas_reporte_incidencia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporte_id UUID NOT NULL REFERENCES reportes_incidencia(id),
    autor_usuario_id UUID NOT NULL REFERENCES usuarios(id),
    mensaje TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS promociones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(120) NOT NULL,
    tipo_descuento VARCHAR(20) NOT NULL CHECK (tipo_descuento IN ('PORCENTAJE', 'MONTO_FIJO')),
    valor_descuento NUMERIC(12,2) NOT NULL CHECK (valor_descuento > 0),
    fecha_inicio TIMESTAMPTZ NOT NULL,
    fecha_fin TIMESTAMPTZ NOT NULL,
    condiciones TEXT,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (fecha_fin > fecha_inicio)
);

CREATE TABLE IF NOT EXISTS reserva_promociones (
    reserva_id UUID NOT NULL REFERENCES reservas(id),
    promocion_id UUID NOT NULL REFERENCES promociones(id),
    descuento_aplicado NUMERIC(12,2) NOT NULL CHECK (descuento_aplicado >= 0),
    PRIMARY KEY (reserva_id, promocion_id)
);

CREATE TABLE IF NOT EXISTS tipos_reporte_administrativo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS reportes_generados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo_reporte_id UUID NOT NULL REFERENCES tipos_reporte_administrativo(id),
    generado_por UUID NOT NULL REFERENCES usuarios(id),
    formato VARCHAR(10) NOT NULL CHECK (formato IN ('PDF', 'EXCEL', 'WORD')),
    filtros JSONB NOT NULL DEFAULT '{}'::jsonb,
    archivo_url VARCHAR(1000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS configuraciones_marca (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_empresa VARCHAR(120) NOT NULL,
    logo_url VARCHAR(1000),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    configuracion_anterior_id UUID REFERENCES configuraciones_marca(id),
    creada_por UUID REFERENCES usuarios(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS colores_configuracion_marca (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    configuracion_marca_id UUID NOT NULL REFERENCES configuraciones_marca(id),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('PRIMARIO', 'SECUNDARIO', 'ACENTO')),
    valor_hex CHAR(7) NOT NULL CHECK (valor_hex ~ '^#[0-9A-Fa-f]{6}$'),
    UNIQUE (configuracion_marca_id, tipo)
);

-- ------------------------------------------------------------------------------
-- 5. AUDITORÍA
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS auditoria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tabla_afectada VARCHAR(128),
    id_registro UUID,
    operacion VARCHAR(10) NOT NULL CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE')),
    tipo_evento VARCHAR(80) NOT NULL,
    resultado VARCHAR(20) NOT NULL CHECK (resultado IN ('EXITOSO', 'FALLIDO')),
    actor_usuario_id UUID REFERENCES usuarios(id),
    sucursal_id UUID REFERENCES sedes(id),
    fecha TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    ip_origen INET,
    aplicacion VARCHAR(100)
);
