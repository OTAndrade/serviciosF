# CU-003 — Paso 5 — Confirmar ofertante v1.2.0

## Referencia Android original
Se replicó el flujo de `ui/oferta/OfertaFragment.java` asociado a
`setOnInfoWindowClickListener`.

Cuando una solicitud está `ACEPTADA`, al tocar su InfoWindow:

1. Se identifica directamente la solicitud con:
   - `id` (key Firebase)
   - `idDr`
   - `idPcte`

2. Se actualizan los registros originales del día:
   - `Solicitudes/{idPcte}/{fechaActual}/{key}`
   - `Bandeja/{idDr}/{fechaActual}/{key}`

   con:
   - `estado = CONFIRMADA`
   - `fechaConfirmacion = dd-MM-yyyy hh:mm:ss`

3. Si `fechaCita` es distinta a la fecha actual, se replica el comportamiento
   Android de crear también la solicitud y bandeja bajo `fechaCita`, con el
   mismo key y estado `CONFIRMADA`.

4. Se recorren las otras solicitudes del día y se cancelan aquellas que:
   - no son la seleccionada;
   - no están `CONFIRMADA`;
   - corresponden al mismo `servicio`.

   Se actualizan ambos lados:
   - `Solicitudes`
   - `Bandeja`

5. El listener Realtime ya existente actualiza automáticamente los pines:
   - la elegida pasa a `ic_alfilerac`;
   - las `CANCELADA` dejan de mostrarse.

## Decisión técnica: no SQLite
La app Android guardaba temporalmente `urlDr` y `urlPct` en una tabla SQLite
`relacion` y asociaba esos registros al `zIndex` del marcador.

Flutter no utiliza esa tabla. La relación está disponible directamente en
`SolicitudModel` mediante:
- `id`
- `idDr`
- `idPcte`

Esto elimina estado local redundante sin cambiar rutas, estados ni lógica
de negocio en Firebase.

## Mejora técnica sin cambio funcional
La confirmación se aplica mediante un `multi-location update` de Realtime
Database para reducir el riesgo de que `Solicitudes` y `Bandeja` queden en
estados intermedios diferentes. El resultado funcional es el mismo que en
Android.

## ARCHIVOS NUEVOS
- lib/features/buscar_servicio/application/confirmar_solicitud_service.dart

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno por este parche.

## SQLite
No se agrega ninguna dependencia ni archivo SQLite.

## Aún no incluido
- Lógica del proveedor para cambiar `ELABORADA` a `ACEPTADA`.
  Eso pertenece al caso de uso `Atiende tus solicitudes`.
