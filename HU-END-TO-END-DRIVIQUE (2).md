# Historias de Usuario — Cierre End to End de Drivique

## Objetivo

Completar la integración entre **Web**, **App móvil**, **Backend** y **Base de Datos** para que todos los flujos usen información real, persistida y autorizada por el backend.

Este documento reemplaza el alcance pendiente del archivo anterior. Las HU-INT-03 y HU-INT-04 ya fueron implementadas y promovidas. **La HU-INT-06 anterior no completa el proyecto**, porque agrupaba catálogo, disponibilidad, reservas, sedes y ambos clientes en una sola historia. Ese trabajo se divide aquí en historias pequeñas, ordenadas y verificables.

El proyecto se considera cerrado solamente cuando se complete desde **HU-INT-05 hasta HU-INT-21** y se apruebe **HU-QA-04**.

---

## Estado y orden de ejecución

| Historia | Alcance | Estado |
|---|---|---|
| HU-INT-03 | Contrato API y configuración base | Completada |
| HU-INT-04 | Registro, OTP, correo y recuperación | Completada |
| HU-INT-05 | Login con Google y Facebook | Pendiente |
| HU-INT-06 | Roles, permisos, sesión y navegación | Pendiente |
| HU-INT-07 | Perfil, preferencias, documentos y cuenta | Pendiente |
| HU-INT-08 | Catálogos, sedes, vehículos e imágenes | Pendiente |
| HU-INT-09 | Disponibilidad, cotización y promociones | Pendiente |
| HU-INT-10 | Favoritos y reseñas | Pendiente |
| HU-INT-11 | Creación y consulta de reservas | Pendiente |
| HU-INT-12 | Ciclo operativo de la reserva | Pendiente |
| HU-INT-13 | Administración de sedes, personal y roles | Pendiente |
| HU-INT-14 | Administración de flota y mantenimiento | Pendiente |
| HU-INT-15 | Pagos, métodos y comprobantes | Pendiente |
| HU-INT-16 | Contratos, firma e inspecciones | Pendiente |
| HU-INT-17 | Notificaciones y preferencias de entrega | Pendiente |
| HU-INT-18 | Soporte e incidencias | Pendiente |
| HU-INT-19 | Reportes, auditoría y configuración global | Pendiente |
| HU-INT-20 | Eliminación definitiva de mocks | Pendiente |
| HU-INT-21 | Ambientes, CI/CD y observabilidad | Pendiente |
| HU-QA-04 | Certificación integral del producto | Pendiente |

---

## Reglas obligatorias para todas las historias

### Repositorios y ramas base

| Componente | Rama de desarrollo | Rama QA | Rama productiva |
|---|---|---|---|
| Backend | `dev` | `qa` | `main` |
| Database | `dev` | `qa` | `main` |
| Web | `develop` | `qa` | `main` |
| App móvil | `develop` | `qa` | `main` |

Cada HU se implementa únicamente en los repositorios indicados en su sección.

Flujo de ramas por repositorio involucrado:

1. Crear `HU-INT-XX-dev` desde la rama de desarrollo actualizada.
2. Probar y crear PR de `HU-INT-XX-dev` hacia `dev` o `develop`.
3. Crear `HU-INT-XX-qa` desde `qa`, fusionar la rama `-dev`, probar y crear PR hacia `qa`.
4. Crear `HU-INT-XX-main` desde `main`, fusionar la rama `-qa`, probar y crear PR hacia `main`.

Los commits deben escribirse en inglés y usar una intención clara, por ejemplo: `feat(reservations): connect customer booking flow`.

### Fuente de verdad y datos permitidos

- PostgreSQL y el backend son la fuente de verdad para usuarios, roles, sedes, vehículos, disponibilidad, tarifas, reservas, pagos, contratos, notificaciones, incidencias y reportes.
- Web y App no pueden importar JSON, arreglos, usuarios, códigos, cupones, vehículos, reservas, notificaciones ni respuestas simuladas como datos de producción.
- `localStorage` y `AsyncStorage` pueden guardar sesión segura, preferencias de interfaz, caché con expiración y borradores temporales. No pueden reemplazar la base de datos.
- Se permiten traducciones `i18n`, tokens visuales, iconos, textos legales y fixtures dentro de pruebas automatizadas.
- Los secretos y credenciales se suministran mediante variables protegidas del ambiente; nunca se confirman en Git.
- Se conserva el diseño visual actual. La integración no debe cambiar navegación, estilos o reglas de negocio salvo que un criterio de aceptación lo exija.
- Cada pantalla debe contemplar carga, vacío, error recuperable, sesión expirada y falta de permisos.
- Los errores de API deben mantener un contrato consistente y no revelar datos sensibles.

### Roles mínimos

- `CUSTOMER`: cliente que consulta, reserva, paga y administra su cuenta.
- `EMPLOYEE`: colaborador que atiende operaciones autorizadas de su sede.
- `BRANCH_ADMIN`: administrador limitado a su sede y personal asignado.
- `SUPER_ADMIN`: administrador global del sistema.

Los nombres definitivos deben coincidir en JWT, backend, base de datos, Web y App.

---

## 🟢 HU-INT-05 | Inicio de sesión con Google y Facebook

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Auth / Web / App / Backend / Database

Como cliente, quiero ingresar o crear mi cuenta mediante Google o Facebook para acceder de forma segura sin otra contraseña.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- Web y App usan Authorization Code con PKCE y callbacks registrados por ambiente.
- El backend valida firma, emisor, audiencia, expiración, estado y nonce antes de aceptar la identidad.
- Una cuenta social se vincula de forma segura con una cuenta existente del mismo correo, sin duplicar usuarios.
- Drivique emite sus propios access y refresh tokens después de validar al proveedor.
- Se manejan cancelación, correo no entregado, cuenta deshabilitada, token inválido y proveedor no disponible.
- Tokens del proveedor y secretos no aparecen en URLs, logs ni datos de negocio.

Story Points: 8

Depende de: HU-INT-03, HU-INT-04.

### DoR

- [ ] Aplicaciones OAuth creadas y callbacks de desarrollo y QA registrados.
- [ ] Política de vinculación de cuentas aprobada.

### DoD

- [ ] Google y Facebook funcionan en Web y App con cuentas nuevas y existentes.
- [ ] Pruebas negativas y de seguridad pasan en Backend.
- [ ] Pipelines de los cuatro repositorios están en verde.

### Checklist de ejecución y cierre

- [ ] Crear persistencia y endpoints de identidades externas.
- [ ] Integrar PKCE en Web y App.
- [ ] Probar alta, login, vinculación, cancelación y revocación.
- [ ] Documentar configuración por ambiente.

---

## 🟢 HU-INT-06 | Roles, permisos, sesión y navegación autorizada

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Seguridad / Web / App / Backend / Database

Como usuario, quiero visualizar y ejecutar únicamente las funciones permitidas por mi rol y sede.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- JWT y endpoint de sesión entregan roles, permisos y sede asignada con un contrato único.
- Backend valida autorización en cada operación; ocultar un botón no reemplaza la validación del servidor.
- Web y App restauran sesión, renuevan tokens y redirigen según `CUSTOMER`, `EMPLOYEE`, `BRANCH_ADMIN` o `SUPER_ADMIN`.
- Cerrar sesión elimina credenciales locales y lleva a la landing page.
- Un usuario sin permiso recibe 403 y una interfaz comprensible, sin ver información de otra sede.
- Usuarios bloqueados, inactivos o sin sede no conservan acceso con tokens antiguos.

Story Points: 8

Depende de: HU-INT-04.

### DoR

- [ ] Matriz rol-permiso-sede aprobada.
- [ ] Contrato de claims y renovación documentado.

### DoD

- [ ] Matriz de acceso validada mediante pruebas de Backend, Web y App.
- [ ] No existen credenciales demo ni roles decididos desde almacenamiento local.
- [ ] Navegación y cierre de sesión funcionan para todos los roles.

### Checklist de ejecución y cierre

- [ ] Unificar guards, interceptores y store de sesión.
- [ ] Aplicar autorización por endpoint y por sede.
- [ ] Probar token vencido, rol cambiado y cuenta bloqueada.
- [ ] Registrar eventos críticos de acceso.

---

## 🟢 HU-INT-07 | Perfil, preferencias, documentos y ciclo de cuenta

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Usuarios / KYC / Web / App / Backend / Database

Como cliente, quiero administrar mi perfil, preferencias, documentos y cuenta con información sincronizada.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- Consultar y editar perfil usa `/users/me` y persiste los cambios.
- Preferencias de idioma, moneda y notificaciones se guardan en backend y se reflejan en ambos clientes.
- Cédula, licencia y demás documentos se cargan mediante almacenamiento autorizado y quedan asociados al usuario.
- El estado KYC se muestra como pendiente, aprobado o rechazado con motivo permitido.
- Eliminar la cuenta revoca sesiones y aplica la política definida para reservas, pagos, auditoría y datos personales.
- Web y App muestran los mismos datos después de volver a iniciar sesión.

Story Points: 8

Depende de: HU-INT-06.

### DoR

- [ ] Política de conservación y eliminación de datos definida.
- [ ] Almacenamiento de archivos configurado.

### DoD

- [ ] Perfil, preferencias, documentos y eliminación funcionan de punta a punta.
- [ ] Archivos privados requieren autorización y no exponen rutas internas.
- [ ] No se usa almacenamiento local como perfil maestro.

### Checklist de ejecución y cierre

- [ ] Conectar formularios y adaptadores de DTO.
- [ ] Implementar carga, descarga y revisión KYC.
- [ ] Validar revocación de sesiones al eliminar o bloquear.
- [ ] Probar consistencia entre Web, App y base de datos.

---

## 🟢 HU-INT-08 | Catálogos, sedes, vehículos e imágenes reales

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Catálogo / Web / App / Backend / Database

Como visitante o cliente, quiero consultar ciudades, sedes, categorías y vehículos reales con sus imágenes y características.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- Ciudades, departamentos, sedes, categorías, características y vehículos provienen del backend.
- Búsqueda, detalle, filtros, paginación y destacados usan IDs y estados reales.
- Imágenes se entregan mediante URLs válidas, incluyen principal y alternativas, y usan placeholder visual únicamente cuando no hay archivo.
- Sedes sin vehículos muestran estado vacío; no se rellenan con vehículos ficticios.
- Solo se muestran sedes, categorías y vehículos activos según las reglas del backend.
- Web y App eliminan imports productivos de `vehicles.json`, `branches.json`, `cities.json` y equivalentes.

Story Points: 8

Depende de: HU-INT-03, HU-INT-06.

### DoR

- [ ] Datos semilla mínimos e idempotentes disponibles.
- [ ] Contratos de catálogo y almacenamiento de imágenes documentados.

### DoD

- [ ] Catálogo y detalle funcionan en Web y App con la misma información.
- [ ] Altas o cambios administrativos se reflejan sin editar el frontend.
- [ ] Estados de carga, vacío y error están probados.

### Checklist de ejecución y cierre

- [ ] Conectar catálogos y filtros.
- [ ] Conectar imágenes y características.
- [ ] Retirar JSON e imports simulados.
- [ ] Probar sedes con y sin inventario.

---

## 🟢 HU-INT-09 | Disponibilidad, cotización, moneda y promociones

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Pricing / Availability / Web / App / Backend / Database

Como cliente, quiero conocer disponibilidad y precio final antes de reservar.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- La disponibilidad se calcula en backend usando sede, fechas, estado del vehículo, reservas y mantenimiento.
- La cotización incluye tarifa, duración, kilometraje, seguros, servicios adicionales, impuestos, descuentos y total.
- Cupones y promociones se validan en backend por vigencia, sede, vehículo, usuario y límites de uso.
- La moneda seleccionada usa tasas reales del backend y muestra fecha de actualización.
- Web y App envían la misma solicitud y muestran el mismo desglose, redondeo y total.
- Una cotización vencida se recalcula antes de confirmar la reserva.

Story Points: 8

Depende de: HU-INT-08.

### DoR

- [ ] Reglas de precio y disponibilidad documentadas.
- [ ] Catálogos de seguros, kilometraje y adicionales cargados.

### DoD

- [ ] Casos con y sin promoción producen resultados consistentes.
- [ ] No existen precios, cupones ni tasas fijas en clientes.
- [ ] Pruebas de concurrencia evitan ofrecer el mismo vehículo ocupado.

### Checklist de ejecución y cierre

- [ ] Unificar DTO de búsqueda y cotización.
- [ ] Integrar promociones y moneda.
- [ ] Probar solapamiento, mantenimiento y cotización vencida.
- [ ] Comparar totales de Web, App y Backend.

---

## 🟢 HU-INT-10 | Favoritos y reseñas persistentes

**Etiqueta:** 🟡 `Should have`

### Descripción

Tipo: Catálogo / Comunidad / Web / App / Backend / Database

Como cliente, quiero guardar vehículos favoritos y publicar reseñas verificadas.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- Agregar o quitar favoritos persiste en backend y se sincroniza entre dispositivos.
- Las reseñas de vehículo o sede solo se habilitan cuando el usuario cumple la regla de reserva completada.
- Promedio, conteo y listado se recalculan con datos persistidos.
- Se manejan duplicados, contenido inválido y recursos eliminados.
- Ninguna reseña o favorito productivo se inicializa desde mocks.

Story Points: 5

Depende de: HU-INT-08, HU-INT-11.

### DoR

- [ ] Reglas de elegibilidad y moderación definidas.

### DoD

- [ ] Favoritos y reseñas se observan iguales en Web y App.
- [ ] Pruebas de autorización y duplicados pasan.

### Checklist de ejecución y cierre

- [ ] Conectar favoritos.
- [ ] Conectar publicación y consulta de reseñas.
- [ ] Actualizar métricas desde backend.
- [ ] Retirar stores y listas simuladas.

---

## 🟢 HU-INT-11 | Checkout, pago aprobado y creación de la reserva

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Reservas / Web / App / Backend / Database

Como cliente, quiero que mi reserva se cree únicamente después de que el pago haya sido aprobado.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- El flujo conserva el diseño actual y obtiene vehículo, sedes, fechas, cotización, adicionales y usuario desde APIs reales.
- Cotizar, completar el formulario o iniciar el checkout **no crea una reserva** ni genera un código de reserva.
- Al iniciar el pago, el backend puede crear una retención técnica temporal de disponibilidad con vencimiento corto. Esta retención no es una reserva y se libera automáticamente si el pago falla, se cancela o vence.
- Backend revalida disponibilidad, precio, identidad y reglas antes de iniciar el pago.
- Solo una confirmación de pago aprobada y validada por el backend crea la reserva, asigna su ID y genera su código.
- La confirmación es idempotente y evita reservas duplicadas por reintentos del cliente o del webhook.
- Si el pago no queda aprobado, no aparece ninguna reserva en el historial.
- La reserva creada puede consultarse en detalle e historial desde Web y App después de cerrar la aplicación.
- Si el pago se aprueba pero ocurre un error técnico al crear la reserva, el sistema reintenta de forma segura y alerta a operación; nunca deja un cobro aprobado sin trazabilidad.

Story Points: 13

Depende de: HU-INT-07, HU-INT-09.

### DoR

- [ ] Estados de checkout, pago y reserva definidos por separado.
- [ ] Permisos SQL mínimos del esquema `rental` aprobados.

### DoD

- [ ] Flujo búsqueda → cotización → checkout → pago aprobado → reserva → detalle funciona en Web y App.
- [ ] Solo una reserva pagada aparece en PostgreSQL y en ambos clientes.
- [ ] Pago rechazado, cancelado o vencido no crea reserva y libera la retención temporal.
- [ ] No se usa JSON ni almacenamiento local como historial.

### Checklist de ejecución y cierre

- [ ] Completar permisos de base de datos con mínimo privilegio.
- [ ] Conectar wizard de reserva sin modificar su diseño.
- [ ] Implementar retención temporal, pago y creación posterior de la reserva.
- [ ] Añadir idempotencia, reconciliación y control de concurrencia.
- [ ] Probar historial, detalle y recuperación tras reinicio.

---

## 🟢 HU-INT-12 | Ciclo operativo, cambios y cancelación de reservas

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Reservas / Operación / Web / App / Backend / Database

Como cliente u operador autorizado, quiero gestionar el ciclo completo de una reserva.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- Se implementan endpoints faltantes para cancelar, modificar fechas o servicios y consultar transiciones permitidas.
- La reserva inicia en estado confirmada después del pago aprobado; no existen reservas pendientes de pago.
- Se soportan estados definidos: confirmada, lista para entrega, activa, finalizada y cancelada, o sus equivalentes aprobados.
- Cada transición valida rol, sede, estado anterior, disponibilidad y pagos.
- Antes del pago se cancela únicamente el checkout o la retención temporal, porque todavía no existe una reserva. Una reserva confirmada puede cancelarse, pero **no genera reembolso, devolución, saldo a favor ni crédito**.
- Antes de confirmar y pagar, Web y App muestran esta política de no reembolso y exigen su aceptación expresa.
- La cancelación libera el vehículo para nuevas reservas, conserva el pago recibido y registra fecha, motivo, actor y aceptación de la política.
- Extensión, punto de entrega y devolución persisten y recalculan valores cuando aplique.
- Web y App no cambian estados de forma optimista sin confirmación del backend.
- Toda transición sensible deja auditoría y genera los eventos correspondientes.

Story Points: 13

Depende de: HU-INT-11.

### DoR

- [ ] Máquina de estados y política de cancelación sin reembolso aprobadas y publicadas.

### DoD

- [ ] Caminos normal, cancelado, expirado y extendido pasan pruebas.
- [ ] Un estado inválido produce conflicto controlado y no altera datos.
- [ ] Historial de cambios es trazable.

### Checklist de ejecución y cierre

- [ ] Completar endpoints y transacciones.
- [ ] Conectar acciones de cliente y operación.
- [ ] Integrar expiración programada.
- [ ] Probar concurrencia, liberación del vehículo y conservación del pago al cancelar.

---

## 🟢 HU-INT-13 | Administración de sedes, personal, usuarios y permisos

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Administración / Web / Backend / Database

Como administrador, quiero gestionar la estructura operativa con permisos reales.

Repositorios involucrados: Backend, Database y Web.

Criterios de aceptación:

- Ciudades, sedes, horarios, categorías de sede y estados se administran mediante API.
- Personal se crea, activa, bloquea, asigna o traslada respetando el alcance de sede.
- Roles y permisos se consultan desde backend y los cambios revocan sesiones cuando corresponde.
- `BRANCH_ADMIN` solo administra su sede; `SUPER_ADMIN` opera el alcance global.
- Paneles, calendarios y perfiles de sede no usan listas demo ni `localStorage` como fuente de verdad.
- Operaciones sensibles registran actor, fecha, recurso y resultado.

Story Points: 13

Depende de: HU-INT-06, HU-INT-08.

### DoR

- [ ] Matriz administrativa y reglas de asignación aprobadas.

### DoD

- [ ] CRUD y permisos funcionan con datos persistidos.
- [ ] Pruebas impiden acceso cruzado entre sedes.
- [ ] Tableros reflejan cambios hechos por otro usuario.

### Checklist de ejecución y cierre

- [ ] Completar APIs administrativas faltantes.
- [ ] Reemplazar servicios de administración simulados.
- [ ] Conectar calendarios y perfiles de sede.
- [ ] Probar auditoría y revocación de acceso.

---

## 🟢 HU-INT-14 | Administración de flota, archivos y mantenimiento

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Flota / Web / Backend / Database

Como operador autorizado, quiero administrar vehículos, imágenes, documentos y mantenimiento con datos reales.

Repositorios involucrados: Backend, Database y Web.

Criterios de aceptación:

- Alta, edición, activación y baja lógica de vehículos se realizan mediante API.
- Imágenes permiten carga, eliminación y selección de principal.
- SOAT, tecnomecánica, pólizas y demás documentos registran vigencia y alertas de vencimiento.
- Mantenimientos bloquean disponibilidad durante el periodo correspondiente.
- La vista pública refleja cambios administrativos válidos.
- Ninguna operación de flota depende de `vehicles.json` o colecciones locales.

Story Points: 13

Depende de: HU-INT-08, HU-INT-13.

### DoR

- [ ] Reglas de estados de vehículo y almacenamiento definidas.

### DoD

- [ ] Flota, archivos y mantenimiento funcionan con autorización por sede.
- [ ] Vehículo en mantenimiento no puede reservarse.
- [ ] Vencimientos y cambios se verifican de punta a punta.

### Checklist de ejecución y cierre

- [ ] Conectar CRUD de flota.
- [ ] Conectar imágenes y documentos.
- [ ] Conectar mantenimiento y disponibilidad.
- [ ] Retirar archivos y calendarios demo.

---

## 🟢 HU-INT-15 | Medios de pago, conciliación y comprobantes

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Billing / Web / App / Backend / Database

Como cliente, quiero pagar el checkout mediante un medio autorizado y consultar un comprobante real y seguro.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- El backend inicia transacciones de checkout con el proveedor y nunca expone llaves privadas a los clientes.
- Web y App procesan resultado pendiente, aprobado, rechazado, expirado y cancelado.
- Webhook valida autenticidad, es idempotente y crea la reserva solamente cuando el pago queda aprobado.
- Métodos guardados almacenan tokens del proveedor, nunca datos completos de tarjeta.
- Un pago en efectivo solo crea la reserva cuando un rol autorizado confirma que recibió el dinero; antes de esa confirmación no existe reserva.
- Comprobante PDF se genera desde datos persistidos y solo puede descargarlo un usuario autorizado.
- El sistema no solicita reembolsos al proveedor cuando se cancela una reserva confirmada o pagada.
- La cancelación conserva el pago recibido y el comprobante original, y registra contablemente la cancelación sin devolución de dinero.

Story Points: 13

Depende de: HU-INT-11, HU-INT-12.

### DoR

- [ ] Cuenta sandbox, webhook accesible y política de no reembolso disponible para el cliente.

### DoD

- [ ] Flujo sandbox completo crea la reserva únicamente después del pago aprobado.
- [ ] Reintentos de webhook no duplican pagos.
- [ ] Comprobante y estado coinciden con proveedor y base de datos.

### Checklist de ejecución y cierre

- [ ] Configurar proveedor por ambiente.
- [ ] Conectar checkout y métodos guardados.
- [ ] Implementar webhook, conciliación, pago en efectivo confirmado y registro de cancelación sin reembolso.
- [ ] Validar comprobante y permisos.

---

## 🟢 HU-INT-16 | Contratos, firma, entrega, devolución e inspecciones

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Contratos / Operación / Web / App / Backend / Database

Como cliente u operador, quiero completar contrato, entrega y devolución con evidencia real.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- El contrato se genera desde reserva, usuario, vehículo, sede, tarifa y pago reales.
- Firma registra consentimiento, fecha, identidad y versión del documento.
- Check-in y check-out incluyen kilometraje, combustible, observaciones, daños y fotos.
- Archivos y PDFs requieren autorización y mantienen integridad y trazabilidad.
- Cargos por daños, combustible o kilometraje se calculan en backend y se reflejan en facturación.
- Se eliminan contratos, firmas, documentos e inspecciones guardados solamente en almacenamiento local.

Story Points: 13

Depende de: HU-INT-12, HU-INT-15.

### DoR

- [ ] Plantilla contractual y listas de inspección aprobadas.

### DoD

- [ ] Reserva pagada completa firma, entrega, devolución y cierre.
- [ ] Evidencias y documentos pueden consultarse con permisos correctos.
- [ ] Totales posteriores coinciden con inspección y pago.

### Checklist de ejecución y cierre

- [ ] Conectar generación y firma.
- [ ] Conectar inspecciones multipart.
- [ ] Integrar cargos y cierre de reserva.
- [ ] Probar descarga, acceso indebido e integridad.

---

## 🟢 HU-INT-17 | Notificaciones reales y preferencias de entrega

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Notificaciones / Web / App / Backend / Database

Como usuario, quiero recibir y consultar notificaciones reales sobre mi cuenta y reservas.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- Eventos de registro, pago, reserva, cancelación, contrato, entrega, devolución, documento e incidencia crean notificaciones persistidas.
- Lista, contador, detalle, marcar como leída y marcar todas usan backend.
- Correo y notificación móvil respetan preferencias, consentimiento y criticidad del evento.
- El sistema registra intento, proveedor, estado y error de entrega sin guardar secretos.
- Reintentos usan una política controlada y no duplican mensajes.
- Se eliminan notificaciones, promociones y cupones dummy de Web y App.

Story Points: 13

Depende de: HU-INT-07, HU-INT-12, HU-INT-15.

### DoR

- [ ] Proveedores, plantillas y catálogo de eventos definidos.

### DoD

- [ ] Notificación in-app, correo y canal móvil funcionan en QA.
- [ ] Lectura se sincroniza entre Web y App.
- [ ] Fallos del proveedor son observables y reintentables.

### Checklist de ejecución y cierre

- [ ] Crear outbox o mecanismo transaccional equivalente.
- [ ] Integrar proveedores y plantillas.
- [ ] Conectar bandejas y preferencias.
- [ ] Probar duplicados, fallos y reintentos.

---

## 🟢 HU-INT-18 | Soporte, incidencias, adjuntos y seguimiento

**Etiqueta:** 🟡 `Should have`

### Descripción

Tipo: Soporte / Web / App / Backend / Database

Como cliente, quiero reportar una incidencia y seguir su atención con información real.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- Cliente crea incidencias relacionadas con reserva, vehículo, pago u otra categoría válida.
- Incidencia admite descripción, prioridad calculada, adjuntos autorizados y conversación o respuestas.
- Operador asignado cambia estado de acuerdo con transiciones permitidas.
- Cliente recibe notificación y consulta historial completo.
- Acceso se limita al cliente propietario y personal autorizado de la sede.
- Se eliminan `support.dummy`, reportes iniciales y almacenamiento local como fuente de verdad.

Story Points: 8

Depende de: HU-INT-12, HU-INT-17.

### DoR

- [ ] Categorías, SLA y estados de soporte aprobados.

### DoD

- [ ] Creación, respuesta, cambio de estado y cierre funcionan en Web y App.
- [ ] Adjuntos privados y permisos pasan pruebas.
- [ ] Notificaciones de seguimiento se entregan.

### Checklist de ejecución y cierre

- [ ] Completar APIs y persistencia de seguimiento.
- [ ] Conectar formularios, bandejas y detalle.
- [ ] Integrar adjuntos y notificaciones.
- [ ] Retirar datos demo.

---

## 🟢 HU-INT-19 | Reportes, auditoría, marca y parámetros globales

**Etiqueta:** 🟡 `Should have`

### Descripción

Tipo: Administración / Reporting / Web / Backend / Database

Como administrador global, quiero consultar operación y configurar el sistema con datos trazables.

Repositorios involucrados: Backend, Database y Web.

Criterios de aceptación:

- Reportes de reservas, ingresos, ocupación, flota, sedes e incidencias se calculan en backend con filtros y paginación.
- Exportaciones se generan en servidor y respetan permisos y límites.
- Auditoría registra accesos y cambios críticos sin exponer contraseñas, tokens ni datos de tarjeta.
- Marca, tema, monedas, políticas y parámetros globales se obtienen y actualizan mediante API versionada.
- Cambios de configuración se validan, auditan y pueden revertirse según política.
- Dashboards y configuración no usan métricas o archivos mock.

Story Points: 13

Depende de: HU-INT-13 a HU-INT-18.

### DoR

- [ ] Métricas, filtros, permisos y parámetros editables definidos.

### DoD

- [ ] Reportes coinciden con consultas de control de base de datos.
- [ ] Exportación y configuración funcionan con autorización global.
- [ ] Auditoría permite reconstruir operaciones críticas.

### Checklist de ejecución y cierre

- [ ] Conectar dashboards y exportaciones.
- [ ] Conectar configuración de marca y seguridad.
- [ ] Reemplazar auditorías y métricas locales.
- [ ] Probar volumen, permisos y reversión.

---

## 🟢 HU-INT-20 | Eliminación definitiva de mocks y fuentes locales de negocio

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: Calidad / Web / App / Backend

Como equipo, queremos impedir que el producto vuelva a usar información ficticia o local como fuente de verdad.

Repositorios involucrados: Backend, Web y App móvil.

Criterios de aceptación:

- Se identifican y clasifican todos los JSON, dummy data, usuarios demo, códigos fijos, servicios fake y fallbacks.
- Se eliminan del código productivo mocks de catálogo, sedes, usuarios, roles, reservas, pagos, contratos, documentos, soporte, notificaciones, auditoría y reportes.
- Se elimina el modo productivo `VITE_USAR_MOCK` y cualquier equivalente en App.
- CI falla si código productivo importa rutas `mocks`, `dummy`, `fixtures` o activa proveedores simulados.
- Fixtures siguen permitidos dentro de pruebas y Storybook o herramientas aisladas, sin entrar al bundle productivo.
- Cachés locales declaran TTL, invalidación y recuperación desde backend.

Story Points: 8

Depende de: HU-INT-05 a HU-INT-19.

### DoR

- [ ] Inventario de datos simulados revisado por cada repositorio.

### DoD

- [ ] Escaneo automático no encuentra datos de negocio simulados en producción.
- [ ] Builds de Web y App funcionan con backend disponible y fallan de forma clara cuando no está disponible.
- [ ] Pruebas no dependen de los datos reales de producción.

### Checklist de ejecución y cierre

- [ ] Retirar archivos, imports, stores y fallbacks simulados.
- [ ] Separar fixtures de prueba.
- [ ] Añadir regla automática de CI.
- [ ] Revisar almacenamiento local y cachés.

---

## 🟢 HU-INT-21 | Ambientes, CI/CD, secretos y observabilidad de los cuatro repositorios

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: DevOps / Backend / Database / Web / App

Como equipo, queremos desplegar y diagnosticar el sistema completo de forma repetible en desarrollo, QA y producción.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- Cada repositorio tiene pipeline de build, lint, pruebas y controles de seguridad acordes con su tecnología.
- Migraciones se validan antes del despliegue y tienen estrategia de rollback o corrección progresiva.
- URLs, SMTP, OAuth, proveedor de pagos, almacenamiento y notificaciones se configuran mediante secretos del ambiente.
- Web y App reciben la URL correcta del backend para cada ambiente, sin editar código o archivos ignorados manualmente.
- Backend expone health checks de aplicación, base de datos y dependencias sin filtrar secretos.
- Logs incluyen correlation ID y métricas de errores, latencia, correos, webhooks y trabajos programados.
- Despliegue ejecuta smoke tests y bloquea promoción si falla un flujo crítico.

Story Points: 13

Depende de: HU-INT-20.

### DoR

- [ ] Ambientes y responsables de secretos definidos.
- [ ] Estrategia de despliegue de Web, Backend, Database y App acordada.

### DoD

- [ ] Los cuatro repositorios tienen pipelines verdes.
- [ ] QA puede instalar/abrir clientes y consumir servicios de QA sin configuración local.
- [ ] Alertas y trazas permiten localizar una falla entre cliente, API, proveedor y base de datos.

### Checklist de ejecución y cierre

- [ ] Crear o completar CI/CD en los cuatro repositorios.
- [ ] Configurar secretos y variables por ambiente.
- [ ] Añadir health checks, logs, métricas y alertas.
- [ ] Automatizar smoke tests y promoción.

---

## 🟢 HU-QA-04 | Certificación integral End to End sin datos quemados

**Etiqueta:** 🔴 `Must have`

### Descripción

Tipo: QA / Seguridad / Rendimiento / Todos los repositorios

Como equipo, queremos certificar que Drivique está completo, conectado y listo para uso real.

Repositorios involucrados: Backend, Database, Web y App móvil.

Criterios de aceptación:

- Se ejecuta en QA una matriz completa por rol: visitante, cliente, empleado, administrador de sede y administrador global.
- Se prueba registro, correo, OTP, recuperación, login tradicional, Google, Facebook y cierre de sesión.
- Se prueba catálogo, disponibilidad, cotización, promoción, reserva, pago, contrato, entrega, devolución, reseña, soporte y notificación.
- Se prueba administración de usuarios, sedes, flota, mantenimiento, reservas, documentos, reportes y configuración.
- Se verifica sincronización Web ↔ Backend ↔ PostgreSQL ↔ App para cada dato crítico.
- Se prueban permisos horizontales y verticales, archivos privados, rate limits, sesión vencida e intentos duplicados.
- Se prueban accesibilidad básica, estados vacíos, pérdida de red, reintentos y tiempos de respuesta acordados.
- No existen defectos críticos o altos abiertos ni datos quemados de negocio en bundles productivos.
- La evidencia contiene caso, datos usados, resultado esperado, resultado obtenido y trazabilidad al commit desplegado.

Story Points: 13

Depende de: HU-INT-05 a HU-INT-21.

### DoR

- [ ] Ambiente QA estable, cuentas por rol y sandbox de proveedores disponibles.
- [ ] Matriz de pruebas y criterios de severidad aprobados.

### DoD

- [ ] Matriz integral aprobada en Web y App.
- [ ] Pipelines y smoke tests de los cuatro repositorios están en verde.
- [ ] Negocio acepta los flujos y la evidencia queda archivada.
- [ ] Existe plan de rollback y monitoreo posterior al despliegue.

### Checklist de ejecución y cierre

- [ ] Preparar datos aislados y cuentas por rol.
- [ ] Ejecutar pruebas funcionales, seguridad y rendimiento.
- [ ] Corregir y repetir casos fallidos.
- [ ] Emitir acta de aceptación y versión candidata.

---

## Matriz mínima de trazabilidad

| Dominio | Fuente de verdad | Web | App | Rol principal |
|---|---|---|---|---|
| Autenticación y cuenta | `iam` | Sí | Sí | Todos |
| Roles y permisos | `iam` | Sí | Sí | Todos |
| Ciudades y sedes | `location` | Sí | Sí | Público/Admin |
| Vehículos y mantenimiento | `fleet` | Sí | Sí | Público/Operación |
| Tarifas y promociones | `catalog` | Sí | Sí | Público/Admin |
| Reservas y extensiones | `rental` | Sí | Sí | Cliente/Operación |
| Pagos y comprobantes | `billing` | Sí | Sí | Cliente/Administración |
| Contratos e inspecciones | `contract` | Sí | Sí | Cliente/Operación |
| Notificaciones y soporte | `support` | Sí | Sí | Cliente/Operación |
| Auditoría y reportes | `audit` | Sí, administración | Según rol | Administración |

## Condición final de cierre del proyecto

Drivique queda End to End cuando una acción iniciada en Web o App se valida en Backend, se persiste correctamente en PostgreSQL, se refleja en el otro cliente cuando corresponda, respeta roles y sede, genera sus efectos secundarios reales y puede rastrearse sin depender de datos simulados.
