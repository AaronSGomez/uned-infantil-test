# Documentación de UNED Infantil Test (Tablet)

Bienvenido a la documentación oficial del proyecto **UNED Infantil Test**, una aplicación móvil para Android diseñada para la autoevaluación y preparación de exámenes tipo test para el Grado en Educación Infantil de la UNED.

---

## 📚 Índice de Documentación

1. **[Acerca del Proyecto (About)](about.md)**:
   - Contexto académico (UNED - Grado en Educación Infantil).
   - Objetivos y filosofía de diseño (*Offline-first*, privacidad, sin cuentas).
   - Adaptabilidad para pantallas de Tablet (10-11 pulgadas).

2. **[Esquema de Datos y Arquitectura](architecture_and_schema.md)**:
   - Esquema relacional SQLite (`questions`).
   - Flujo de siembra inicial (*seed data*) vía JSON y carga incremental.
   - Arquitectura desacoplada (Clean Architecture / Separación de capas).
   - Algoritmo de calificación y penalización de errores oficial de la UNED.

3. **[Stack Tecnológico y Dependencias](technologies.md)**:
   - Framework, lenguajes y librerías utilizadas.
   - Justificación técnica de cada componente (SQLite vs Hive/Isar, Provider vs Bloc).
   - Patrones de diseño e interfaz adaptativa (NavigationRail, Material 3).

4. **[Metadatos del Proyecto](metadata.json)**:
   - Ficha técnica en JSON con versiones, compatibilidad, requerimientos de hardware/OS y configuración de build.
