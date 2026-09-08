# HU-BD-07: Reservas y maquina de estados

La migracion `V7__reservas_y_maquina_de_estados.sql` evoluciona la tabla `reservas` existente. Cada reserva nueva requiere cliente, vehiculo, sucursal de recogida, sucursal de devolucion y un periodo `[fecha_recogida, fecha_devolucion)`.

## Estados

| Estado | Bloquea la disponibilidad | Descripcion |
| --- | --- | --- |
| `PENDIENTE_PAGO` | Si | Estado inicial mientras se valida el pago. |
| `CONFIRMADA` | Si | Pago validado y vehiculo apartado. |
| `EN_CURSO` | Si | Vehiculo entregado al cliente. |
| `COMPLETADA` | No | Alquiler finalizado. |
| `CANCELADA` | No | Reserva cancelada antes de finalizar. |
| `EXPIRADA` | No | Vencio el plazo de pago. |

## Transiciones permitidas

```text
PENDIENTE_PAGO -> CONFIRMADA | CANCELADA | EXPIRADA
CONFIRMADA     -> EN_CURSO | CANCELADA
EN_CURSO       -> COMPLETADA
```

El trigger `trg_validar_estado_y_disponibilidad_reserva` exige el estado inicial y rechaza cualquier transicion que no este en `transiciones_estado_reserva`. Cada cambio queda auditado en `historial_estados_reserva`.

## Disponibilidad

La restriccion `reservas_vehiculo_periodo_sin_solapamiento` usa una exclusion GIST sobre el vehiculo y el rango de tiempo. Solo incluye reservas cuyos estados bloquean disponibilidad, por lo que una reserva cancelada, expirada o completada libera el periodo.

## Validacion

Con Docker Desktop iniciado, ejecutar desde la raiz del repositorio:

```powershell
.\scripts\test_flyway_migrations.ps1
```

El script comprueba una instalacion limpia V1 a V7 y una actualizacion V6 a V7. Al final ejecuta `test_hu_bd_07_reservas.sql`, que se ejecuta en una transaccion y termina en `ROLLBACK`.
