# iNeed Flutter - CU-003 Paso 1 (v0.8)

Alcance de este parche:
- Lee en tiempo real el nodo `Especialidades` de Firebase Realtime Database.
- Conserva como nombre funcional el campo original `Especialidad`.
- Ordena alfabéticamente los servicios.
- Filtra la lista mientras el usuario escribe.
- Permite seleccionar una especialidad y mantiene la selección en la pantalla.
- `Limpiar` restablece la selección y el radio visual provisional.
- `Enviar Solicitudes` permanece deshabilitado: todavía no se ha migrado la búsqueda de ofertantes ni el envío real.

No modifica:
- estructura de Firebase;
- estados de negocio;
- Solicitudes/Bandeja;
- configuración Android, iOS o Web;
- API Keys de Google Maps.

Aplicación:
Copiar el contenido de este ZIP sobre la raíz del proyecto v0.7.1 ya configurado, conservando la estructura de carpetas.
