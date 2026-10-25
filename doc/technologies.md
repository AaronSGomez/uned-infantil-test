# Stack Tecnológico y Dependencias

Este documento detalla las tecnologías, librerías y decisiones de diseño seleccionadas para **UNED Infantil Test**.

---

## 🛠️ Tecnologías Principales

| Categoría | Tecnología | Versión | Propósito |
|---|---|---|---|
| **Framework** | [Flutter](https://flutter.dev) | `>=3.0.0` | Desarrollo multiplataforma nativo compilado con alto rendimiento gráfico (Skia/Impeller). |
| **Lenguaje** | [Dart](https://dart.dev) | `>=3.0.0 <4.0.0` | Lenguaje fuertemente tipado con soporte nulo por defecto (*Sound Null Safety*). |
| **Motor de Base de Datos** | [SQLite](https://www.sqlite.org/) | 3.x | Motor relacional embebido, robusto y estándar de la industria para almacenamiento persistente y transaccional offline. |
| **Plugin BD** | [`sqflite`](https://pub.dev/packages/sqflite) | `^2.3.0` | Driver SQLite nativo para Android (y otras plataformas) con soporte para transacciones por lotes (*batch operations*). |
| **Gestión de Rutas/Path** | [`path`](https://pub.dev/packages/path) | `^1.8.3` | Manipulación multiplataforma y segura de rutas de archivos en el sistema operativo. |
| **Gestión de Estado** | [`provider`](https://pub.dev/packages/provider) | `^6.1.1` | Gestión reactiva de estado basada en `ChangeNotifier`, sencilla, predecible y con bajo consumo de memoria. |
| **Tipografía** | [`google_fonts`](https://pub.dev/packages/google_fonts) | `^6.1.0` | Gestión de tipografías claras de lectura prolongada para tablet. |

---

## 💡 Justificación de Decisiones Técnicas

### ¿Por qué SQLite (`sqflite`) frente a Hive o Isar?
1. **Portabilidad y Respaldo**: El formato SQLite es un archivo universal (`.db`). Si en el futuro se desea generar o exportar bancos de miles de preguntas desde un script Python, SQL estándar o un Excel/CSV, SQLite es el estándar con mayor interoperabilidad.
2. **Capacidad de Consulta Relacional**: Consultas directas como `SELECT DISTINCT subject`, agregaciones de estadísticas (`SUM(times_failed)`), y ordenamiento aleatorio nativo (`ORDER BY RANDOM() LIMIT 20`) se resuelven en el motor C de SQLite en milisegundos sin cargar colecciones enteras en la memoria RAM de la tablet.
3. **Transacciones Atómicas (*ACID*)**: Garantiza que si la tablet se apaga o la app se suspende en mitad de un examen, la base de datos nunca se corrompe.

### ¿Por qué `Provider` frente a Bloc o Riverpod?
- Para una app de estudio individual offline sin flujos de red asíncronos complejos, **Provider** ofrece el equilibrio perfecto entre desacoplamiento y simplicidad:
  - Sin necesidad de generar código repetitivo (*code-gen*).
  - Curva de aprendizaje limpia para mantenimiento personal.
  - Gestión fluida del ciclo de vida del temporizador y las respuestas.

### Enfoque de Interfaz y Diseño para Tablet
- **Material Design 3**: Se utilizan los componentes y estándares visuales de Material 3 (`ColorScheme.fromSeed`, tarjetas con elevación suave, estados `InkWell` interactivos).
- **NavigationRail**: Recomendado por las guías oficiales de Android y Material Design para pantallas de gran formato (tablets y plegables), reemplazando la típica barra inferior de móvil (`NavigationBar`) que queda estirada y desaprovechada en tablets horizontales.
- **Sin permisos requeridos**: No necesita permisos de Internet (`INTERNET`), cámara ni localización en el `AndroidManifest.xml`, garantizando la máxima autonomía de batería y total privacidad.
