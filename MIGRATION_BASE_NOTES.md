# iNeed Flutter - Base visual v0.2

Esta version incorpora la identidad visual migrada desde la carpeta `res` del proyecto Android original.

## Cambios incluidos

- Paleta oficial desde `res/values/colors.xml`.
- Fuente oficial `Fq` desde `res/font`.
- Logos e imagenes principales en `assets/logos` y `assets/images`.
- Pines oficiales en `assets/markers`:
  - `ic_alfilerac.png`
  - `ic_alfilerel.png`
  - `ic_alfilerpe.png`
- Centralizacion de assets en `lib/core/constants/app_assets.dart`.
- Centralizacion de colores en `lib/app/theme/app_colors.dart`.
- Tema Flutter actualizado en `lib/app/theme/app_theme.dart`.
- `MarkerIconRegistry` actualizado para usar los PNG originales.
- `GoogleService-Info.plist` copiado a `ios/Runner` e incorporado al proyecto iOS.

## Pendiente

- Validar en equipo local con:

```bash
flutter clean
flutter pub get
flutter run
```

- Si se compila iOS, validar desde macOS/Xcode que `GoogleService-Info.plist` este asociado al target Runner.
- Continuar con la migracion del modulo de autenticacion.
