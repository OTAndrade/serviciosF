# iNeed Flutter v0.3.1 - Correccion de inicializacion Firebase

## Correccion aplicada

Se corrigio el bloqueo del Splash Screen cuando Firebase no podia inicializarse o cuando la aplicacion se ejecutaba en Web.

Cambios principales:

1. Se agrego `lib/firebase_options.dart` con configuracion centralizada para Android, iOS y Web.
2. `FirebaseBootstrapService.initialize()` ahora usa `DefaultFirebaseOptions.currentPlatform`.
3. El Splash Screen ya no intenta validar sesion si Firebase no inicializo correctamente.
4. Si Firebase falla, se muestra el error tecnico en pantalla en lugar de quedar cargando indefinidamente.

## Nota

Para Web, el `appId` debe ser validado contra la app Web real registrada en Firebase Console. Android e iOS usan los datos de `google-services.json` y `GoogleService-Info.plist`.
