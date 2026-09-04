# CU-007A — Paso 2 — Imagen + validaciones v1.6.3

## Equivalencia revisada en Android
Fuente:
`ui/registra/RegistraFragment.java`

### Imagen
La app original:
- abre únicamente la galería (`Intent.ACTION_PICK`, `image/*`);
- muestra una vista previa;
- exige una imagen antes de continuar.

Flutter mantiene ese comportamiento mediante `image_picker` con
`ImageSource.gallery`. No se incorporó cámara porque no forma parte del
flujo original.

### Validaciones
Se conserva el orden y mensajes funcionales originales:

1. oficio/profesión seleccionado de la lista;
2. descripción obligatoria;
3. año de inicio obligatorio;
4. año entre año actual - 40 y año actual;
5. costo obligatorio;
6. dirección obligatoria;
7. ubicación seleccionada;
8. imagen obligatoria.

`numeroRegistro` permanece opcional, igual que Android.

### Confirmación
Después de validar se presenta el diálogo original:

Título:
`Alerta!!`

Mensaje:
`La información que desea registrar estará sujeta a verificación,
presione Grabar si desea continuar.`

Opciones:
- Cancelar
- Grabar

IMPORTANTE: en este Paso 2, aceptar `Grabar` NO escribe todavía en
Firebase Storage ni en Realtime Database. Solo confirma que formulario e
imagen pasan las validaciones. La persistencia se incorpora en Paso 3.

## Dependencia nueva
`image_picker: ^1.1.2`

En iOS se agrega `NSPhotoLibraryUsageDescription`.

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/features/registra_oficio/presentation/registra_oficio_screen.dart
- pubspec.yaml
- ios/Runner/Info.plist

## ARCHIVOS A ELIMINAR
- Ninguno.

## Después de aplicar
Ejecutar:
`flutter pub get`
