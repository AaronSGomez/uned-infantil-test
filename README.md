# 🎓 UNED Infantil Test — App de Autoevaluación para Tablet

[![Flutter](https://img.shields.io/badge/Flutter_3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart_3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android Tablet](https://img.shields.io/badge/Platform-Android_Tablet_(10--11")-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![SQLite](https://img.shields.io/badge/Storage-SQLite_(sqflite)-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://www.sqlite.org)
[![Material 3](https://img.shields.io/badge/UI/UX-Material_3_&_NavigationRail-795548?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)
[![Offline First](https://img.shields.io/badge/Privacy-100%25_Offline_&_No_Logs-success?style=for-the-badge&logo=shield)](https://aaronsgomez.es)
[![License: MIT](https://img.shields.io/badge/License-MIT_%26_Free_Educational_Use-blue?style=for-the-badge)](LICENSE)

> **Resumen Ejecutivo**:  
> **UNED Infantil Test** es una aplicación móvil para Android optimizada específicamente para pantallas de tablet (orientación horizontal *landscape* y vertical *portrait*), diseñada para la autoevaluación y preparación de exámenes tipo test del **Grado en Educación Infantil de la UNED**. Construida bajo una filosofía *Offline-first*, no requiere conexión a internet, registros ni servidores externos, garantizando privacidad total y respuesta instantánea.

🌐 **Desarrollador & Portfolio**: [aaronsgomez.es](https://aaronsgomez.es)

---

## ✨ Propuesta de Valor y Características Principales

### 📱 1. Ergonomía y UI/UX Diseñada para Tablet (10-11")
* **Navegación Lateral `NavigationRail`**: En pantallas anchas (modo horizontal), la barra de navegación se sitúa ergonómicamente en el lateral izquierdo, facilitando la interacción con los pulgares mientras se sostiene la tablet.
* **Layout Adaptativo en Doble Columna**:
  * **Columna Lateral**: Cuadrícula interactiva de estado de preguntas (respondidas, pendientes, dudosas) y cronómetro de examen.
  * **Área Central**: Enunciados amplios y opciones de gran tamaño (altura táctil $\ge 58\text{dp}$) pensadas tanto para pulsación con los dedos como para lápices ópticos (*Stylus / S-Pen*).
* **Higiene Visual Prolongada**: Esquemas de color relajantes en modo claro y modo oscuro (*Slate Navy* y tonos neutros cálidos) con tipografía de alto contraste (18-22sp) que reducen la fatiga ocular en sesiones intensivas de estudio.

---

### 🧠 2. Modos Didácticos y de Examen

| Modo | Dinámica | Objetivo Pedagógico |
|---|---|---|
| **Modo Práctica / Repaso** | Corrección inmediata al pulsar y visualización desplegable de la **Justificación Didáctica UNED**. | Asimilación profunda de conceptos y afianzamiento de la bibliografía oficial. |
| **Simulación Examen UNED** | Bloques aleatorios de preguntas con temporizador configurable y sin feedback intermedio. | Entrenamiento bajo condiciones reales de examen universitario. |
| **Filtro de Falladas (Smart Review)** | Generador automático de tests con las preguntas erradas acumuladas en el histórico. | Eliminación de puntos débiles y refuerzo continuo. |
| **Preguntas Favoritas / Dudosas** | Marcado rápido con estrella para generar baterías de repaso focalizado. | Consolidación de conceptos dudosos antes del examen. |

---

### ⚖️ 3. Algoritmo Oficial de Calificación UNED

Los exámenes de la UNED aplican una penalización matemática a las respuestas erróneas para corregir el factor azar. La aplicación implementa el cálculo exacto sobre base 10:

$$\text{Nota} = \max\left(0, \frac{\text{Aciertos} - \frac{\text{Errores}}{k-1}}{\text{Total de Preguntas}} \times 10\right)$$

* En preguntas de **3 alternativas** ($k=3$), cada error descuenta **0.50 aciertos netos** (*2 errores anulan 1 acierto*).
* En preguntas de **4 alternativas** ($k=4$), cada error descuenta **0.33 aciertos netos** (*3 errores anulan 1 acierto*).
* Las preguntas dejadas **en blanco** puntúan con **0** (no restan).

---

## 🛠️ Tecnologías y Arquitectura

```
┌────────────────────────────────────────────────────────┐
│                   Capa de Presentación                 │
│  - Screens: HomeTabletScreen, ExamScreen, ResultsScreen │
│  - Widgets: QuestionCard, NavigatorGrid               │
│  - Theme: AppTheme (Material 3 Adaptativo Tablet)      │
└───────────────────────────┬────────────────────────────┘
                            │ (Provider / ChangeNotifier)
┌───────────────────────────▼────────────────────────────┐
│              Capa de Negocio / Estado                  │
│  - ExamController: Cronómetro, respuestas y notas UNED │
└───────────────────────────┬────────────────────────────┘
                            │ (Consultas SQL optimizadas)
┌───────────────────────────▼────────────────────────────┐
│              Capa de Persistencia Local                │
│  - SQLite (sqflite) + Transacciones Batch              │
│  - Precarga automática de assets/data/seed_questions.json│
└────────────────────────────────────────────────────────┘
```

* **Framework**: Flutter `>=3.0.0` & Dart.
* **Persistencia Relacional**: SQLite nativo a través de `sqflite` (ACID, portabilidad `.db`, cero dependencias de nube).
* **Gestión de Estado**: `Provider` + `ChangeNotifier` para un ciclo de vida predecible y eficiente.
* **Permisos**: 0 permisos requeridos en el `AndroidManifest.xml` (sin acceso a internet, archivos privados ni hardware sensible).

---

## 📂 Estructura del Repositorio

```text
uned/
├── assets/
│   └── data/
│       └── seed_questions.json          # Banco inicial de preguntas UNED
├── doc/
│   ├── README.md                        # Índice de documentación técnica
│   ├── about.md                         # Contexto académico y objetivos
│   ├── architecture_and_schema.md       # Esquema SQLite, DDL y matemáticas UNED
│   ├── metadata.json                    # Ficha técnica estructurada
│   └── technologies.md                  # Stack y justificación de decisiones
├── lib/
│   ├── data/
│   │   ├── datasources/database_helper.dart # Gestor SQLite y batch seeds
│   │   └── models/question_model.dart       # Entidad Question
│   ├── presentation/
│   │   ├── controllers/exam_controller.dart # Controlador de examen y notas
│   │   ├── screens/                         # Vistas tablet (Home, Test, Resultados)
│   │   ├── theme/app_theme.dart             # Paletas claro/oscuro de alto contraste
│   │   └── widgets/question_card.dart       # Componente de pregunta táctil
│   └── main.dart
├── LICENSE                              # Licencia MIT y cláusula Free Use
└── pubspec.yaml
```

---

## 🚀 Despliegue y Ejecución

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/AaronSGomez/uned-infantil-test.git
   cd uned-infantil-test
   ```
2. Instalar dependencias de Flutter:
   ```bash
   flutter pub get
   ```
3. Lanzar en tu tablet física o emulador Android:
   ```bash
   flutter run
   ```

---

## 📜 Autorización para Uso Libre (Free & Educational Use)

> **Uso Libre y Educativo**: Se concede autorización expresa, libre y gratuita para el uso, distribución y adaptación de esta aplicación a cualquier estudiante, opositor o docente interesado en la autoevaluación en el Grado en Educación Infantil de la UNED, sin ánimo de lucro ni requerir contraprestación económica.

---

## 👨‍💻 Autor & Contacto

**Aarón Gómez** — *Desarrollo de Software & Ciberseguridad*

* 🌐 **Sitio Web / Portfolio**: [aaronsgomez.es](https://aaronsgomez.es)
* 🐙 **GitHub**: [github.com/AaronSGomez](https://github.com/AaronSGomez)
* 💼 **LinkedIn**: [linkedin.com/in/aaronsgomez](https://www.linkedin.com/in/aaronsgomez)

---

## 📄 Licencia

Este proyecto está distribuido bajo la licencia **MIT** con cláusula de uso formativo gratuito — consulta el archivo [LICENSE](LICENSE) para más detalles.
