# HU-BD-08: Pagos virtuales y en efectivo

La migracion `V9__pagos_virtuales_y_efectivo.sql` vincula cada pago con su reserva, contrato, proveedor y metodo. La base valida que la reserva sea la misma vinculada al contrato.

La dupla `proveedor_id` y `referencia_externa` evita procesar dos veces la misma respuesta externa. La dupla `proveedor_id` y `clave_idempotencia` permite reintentos seguros desde la aplicacion.

Los estados `PENDIENTE`, `PENDIENTE_EFECTIVO`, `APROBADO`, `CONFIRMADO_EFECTIVO`, `RECHAZADO` y `CANCELADO` se auditan en `historial_estados_pago`. Una fila en `confirmaciones_efectivo` solo puede corresponder a un metodo `EFECTIVO`; al registrarla, el pago pasa a `CONFIRMADO_EFECTIVO` y queda trazado con cajero, fecha, referencia y evidencia.

No se crean columnas de tarjeta. Los triggers rechazan tokens que contengan secuencias de 13 a 19 digitos, protegiendo contra persistencia accidental de PAN completos. Solo deben guardarse tokens emitidos por la pasarela y, cuando aplique, marca y ultimos cuatro digitos.

Para validar migracion limpia y actualizacion `V8 -> V9`:

```powershell
.\scripts\test_flyway_hu_bd_08_migrations.ps1
```
