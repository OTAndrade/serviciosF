# iNeed Flutter - Base de migracion

## Cambios aplicados

- Se cambio el paquete Android a `com.ineedserv.servicios`.
- Se cambio el nombre visible de la app a `iNeed`.
- Se ajusto el bundle identifier iOS a `com.ineedserv.servicios`.
- Se dejo la app enfocada en Android, iOS y Web.
- Se aplico arquitectura Feature First.
- Se incorporo Riverpod como base de gestion de estado.
- Se centralizaron constantes de estados, rutas Firebase, assets, strings, fechas y calculo de distancia.
- Se creo una capa base de servicios y repositorios para Firebase Realtime Database.
- Se crearon pantallas base para Home, Login, Buscar el servicio y Atiende tus solicitudes.
- Se preparo Google Maps como fondo para los modulos principales.

## Pendiente para ejecutar

1. Ejecutar:

```bash
flutter clean
flutter pub get
flutter run
```

2. Reemplazar la API key de Google Maps en:

```text
android/app/src/main/res/values/strings.xml
```

3. Agregar configuracion Firebase:

```text
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
web/firebase-config
```

4. Migrar los PNG reales de pines, logos e iconos desde el proyecto Android original hacia:

```text
assets/markers/
assets/logos/
assets/icons/
assets/images/
```

## Nota

La logica de negocio y la estructura de Firebase no fueron modificadas.
