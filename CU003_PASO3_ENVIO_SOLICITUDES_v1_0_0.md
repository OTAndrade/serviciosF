# CU-003 — Paso 3 — Envío real de solicitudes v1.0.0

## Fuente validada
Se replica la lógica de `ui/oferta/OfertaFragment.java`, método `grabaSolicitudesFB()` y la preparación de `solicitud[]` en `base(Ofertantes[])`.

## Comportamiento implementado
Por cada ofertante elegible dentro del radio:
1. Se omite si `idDr == idPcte`, igual que Android original.
2. Se genera un `push key` desde la raíz `Solicitudes`.
3. Se usa ese mismo key en `Solicitudes` y `Bandeja`.
4. Se escribe:
   - `Solicitudes/{idPcte}/{dd-MM-yyyy}/{key}`
   - `Bandeja/{idDr}/{dd-MM-yyyy}/{key}`
5. Estado inicial: `ELABORADA`.
6. `fechaSolicitud`: `dd-MM-yyyy hh:mm:ss`.
7. `fechaAceptacion`, `fechaConfirmacion`, `fechaCita`, `horaCita`: un espacio `" "`, igual que Android.
8. El botón queda deshabilitado mientras se realiza el envío para evitar doble pulsación.
9. Al finalizar se muestra el mensaje de confirmación equivalente al Android original.

## Campos de Solicitudes
- nombreDr
- nombrePcte
- distancia
- servicio
- latOfertante
- lonOfertante
- telefonoDr (mantiene el comportamiento original: valor de `Ofertantes.instancia`)
- idDr
- idPcte
- fechaSolicitud
- fechaAceptacion
- fechaConfirmacion
- fechaCita
- horaCita
- direccion
- estado
- costo
- experiencia

## Campos de Bandeja
- nombreDr
- nombrePcte
- distancia
- servicio
- latSolicitante
- lonSolicitante
- telefonoPcte
- idDr
- idPcte
- fechaSolicitud
- fechaAceptacion
- fechaConfirmacion
- fechaCita
- horaCita
- estado

## ARCHIVOS NUEVOS
- lib/features/buscar_servicio/application/enviar_solicitudes_service.dart

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Alcance pendiente
Después del envío, Android original ejecuta `recuperaSolicitudes()` y muestra las solicitudes del día con sus pines/estados. Esa visualización en tiempo real será el siguiente paso de CU-003; este parche se concentra en reproducir correctamente la escritura en Firebase.
