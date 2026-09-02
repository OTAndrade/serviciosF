# CU-003 Paso 1 - Corrección SubRubro v0.8.1

Corrección funcional de la fuente de servicios.

- La lista visible se obtiene de `SubRubro`.
- El nombre del servicio es la clave de cada hijo de `SubRubro`.
- El valor del hijo se conserva como rubro/categoría asociada.
- Ejemplos:
  - `SubRubro/Agente Inmobiliario = "Tecnicos"` -> servicio: `Agente Inmobiliario`, rubro: `Tecnicos`.
  - `SubRubro/Alergologia = "Medicina"` -> servicio: `Alergologia`, rubro: `Medicina`.
- Se eliminan del parche el modelo y repositorio basados en `Especialidades`.
- No se modifica aún la búsqueda de ofertantes ni el envío de solicitudes.
