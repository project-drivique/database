# HU-BD-09: Contratos, versiones y firmas

La migracion `V8__contratos_versiones_y_firmas.sql` convierte la reserva en un vinculo obligatorio e inmutable del contrato. Los datos operativos del contrato deben coincidir con cliente, vehiculo, sucursales y periodo de esa reserva.

Cada cambio documental se registra como una fila nueva en `contrato_versiones`. Esas filas no pueden modificarse ni eliminarse; una correccion requiere una version posterior. Las firmas se guardan en `firmas_contrato` contra una version concreta, con fecha, firmante, tipo y evidencia verificable por hash SHA-256.

Los estados disponibles son `BORRADOR`, `PENDIENTE_FIRMA`, `ACTIVO`, `FINALIZADO` y `CANCELADO`. `es_activo` y `es_final` permiten clasificar el estado sin depender de texto de aplicacion.

`contratos_alquiler.reserva_id` es obligatorio y conserva su restriccion unica. Por ello una reserva solo puede tener un contrato y no admite contratos activos duplicados. Los indices cubren reserva, cliente, estado, versiones y firmas.

Para validar una migracion limpia y una actualizacion `V7 -> V8`:

```powershell
.\scripts\test_flyway_hu_bd_09_migrations.ps1
```
