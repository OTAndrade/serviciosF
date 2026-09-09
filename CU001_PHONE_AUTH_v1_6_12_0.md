# CU-001 — Autenticación por teléfono v1.6.12.0

## Android original revisado
- `LoginFonoActivity.java`
- `Usuario.java`
- `ProfesionOficio.java`

## Flujo migrado

### 1. Número
- código de país;
- número local;
- mínimo 8 caracteres, igual que Android.

Por compatibilidad Web/Android/iOS el código de país se muestra como campo
editable y se inicializa en `+591`.

La app Android detectaba el país desde la SIM. Web no dispone de SIM,
por lo que el campo editable conserva la capacidad multi-país.

### 2. SMS
Android/iOS:
`FirebaseAuth.verifyPhoneNumber`

Web:
`FirebaseAuth.signInWithPhoneNumber`

En Web Firebase administra automáticamente reCAPTCHA.

### 3. Código
Se valida el SMS y se autentica con Firebase.

Android también puede completar automáticamente la verificación cuando
Firebase obtiene el código sin intervención del usuario.

### 4. Usuario existente
Después de autenticar:
`Usuarios/{uid}`

Si existe:
- no se vuelve a crear;
- se invalida `currentUsuarioProvider`;
- entra a Home.

### 5. Usuario nuevo
Si `Usuarios/{uid}` no existe se habilitan:
- nombre;
- correo;
- ciudad;
- aceptación de Términos.

Las ciudades se consultan desde:
`Pais/{codigoPais}`

Solo se utilizan hijos cuyo valor sea `true`.

### 6. Creación
Se crea `Usuarios/{uid}` con la estructura original del login telefónico:

- pais
- ciudad
- instancia
- email
- tipoUsuario = "1"
- estado = "AC"
- nombre
- pass = "Telefono"
- fbUid = uid
- tokenMsg, cuando Firebase Messaging puede obtenerlo

### 7. Términos
Reutiliza CU-009:
`AppRoutes.terminos`

No se duplica visor ni acceso a `Terminos/Archivo`.

### 8. Post-registro
El usuario entra a Home como tipo 1.

En Android original aparecía primero `ProfesionOficio`, donde podía:
- registrar un oficio;
- o salir a MainActivity.

En Flutter esta capacidad ya está integrada en el menú dinámico:
`Registra tu oficio/profesión`.

El usuario conserva las dos posibilidades sin duplicar una pantalla
intermedia antigua.

## Arquitectura
La lógica Firebase Auth queda centralizada en `AuthService`:
- startPhoneVerification()
- confirmPhoneCode()
- clearPhoneVerification()

La lectura de ciudades queda centralizada en `PaisRepository`.

## ARCHIVOS NUEVOS
- lib/data/repositories/pais_repository.dart

## ARCHIVOS MODIFICADOS
- lib/data/services/auth_service.dart
- lib/features/auth/presentation/phone_login_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Configuración requerida para prueba
Firebase Authentication debe tener habilitado el proveedor Phone.

Web:
el dominio donde se ejecuta la aplicación debe estar autorizado en
Firebase Authentication.

Para pruebas es recomendable configurar un número telefónico de prueba y
un código fijo en Firebase Authentication para evitar consumir SMS reales.

## Pruebas recomendadas

### Usuario existente
1. Login con teléfono.
2. Obtener código.
3. Ingresar código.
4. Debe ingresar directamente a Home.
5. Debe conservar tipoUsuario y menú existentes.

### Usuario nuevo
1. Usar un número que no tenga `Usuarios/{uid}`.
2. Verificar SMS.
3. Deben aparecer nombre/correo/ciudad/términos.
4. Abrir Términos.
5. Intentar continuar sin aceptar -> debe bloquear.
6. Completar datos.
7. Debe crearse `Usuarios/{uid}`.
8. `tipoUsuario` debe ser "1".
9. Menú debe mostrar `Registra tu oficio/profesión`.
