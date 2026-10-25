# UNED Infantil Test - App de Autoevaluación para Tablet

Aplicación de autoevaluación y preparación de exámenes tipo test para el **Grado en Educación Infantil de la UNED**, desarrollada en **Flutter**, diseñada 100% offline y optimizada específicamente para pantallas tablet (10-11 pulgadas) tanto en orientación horizontal (*landscape*) como vertical (*portrait*).

---

## 📱 Características Principales

1. **Optimización Tablet (UI/UX)**:
   - Navegación lateral mediante `NavigationRail` para aprovechar el ancho en horizontal.
   - Panel lateral con cuadrícula interactiva de estado de preguntas (respondida, en blanco, favorita).
   - Tipografía amplia (20-22sp) y botones táctiles con altura mínima generosa (>56dp) para estudio prolongado sin fatiga visual.
   - Soporte nativo para modo claro y modo oscuro.

2. **Modos de Examen**:
   - **Simulación Examen UNED**:
     - Temporizador configurable de cuenta atrás.
     - Cálculo de penalización de errores oficial de la UNED:
       $$\text{Nota} = \max\left(0, \frac{\text{Aciertos} - \frac{\text{Errores}}{k-1}}{\text{Total}} \times 10\right)$$
       *(Para tests de 3 alternativas $k=3$, cada error descuenta 0.5 puntos del neto; para 4 alternativas, descuenta 0.33)*.
     - Calificación final sobre 10 con baremo universitario (Suspenso, Aprobado, Notable, Sobresaliente) y desglose de tiempo y fallos.
   - **Modo Práctica / Estudio Continuo**:
     - Corrección inmediata al pulsar cada opción.
     - Justificación didáctica contextualizada con la bibliografía de la asignatura.
     - Opción de anular respuesta / dejar en blanco.

3. **Herramientas de Estudio Inteligente**:
   - **Filtro de Falladas**: Generador de test exclusivo con las preguntas que acumulan fallos en el historial.
   - **Marcado de Dudosas / Favoritas**: Botón de estrella por pregunta para repasar conceptos clave.
   - **Historial y Estadísticas**: Tasa de acierto global, total de intentos y preguntas en el banco.

4. **100% Offline & Precarga de Datos**:
   - Base de datos relacional SQLite local (`sqflite`).
   - Carga inicial automática desde `assets/data/seed_questions.json`.
   - Módulo de importación rápida en caliente mediante pegado de JSON.

---

## 🗂️ Estructura del Proyecto

```text
uned/
├── assets/
│   └── data/
│       └── seed_questions.json      # Banco de preguntas precargado
├── lib/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── database_helper.dart # Gestor SQLite, seeds y consultas
│   │   └── models/
│   │       └── question_model.dart  # Modelo de datos de pregunta
│   ├── presentation/
│   │   ├── controllers/
│   │   │   └── exam_controller.dart # Lógica de examen, temporizador y notas
│   │   ├── screens/
│   │   │   ├── home_tablet_screen.dart # Pantalla principal con NavigationRail
│   │   │   ├── exam_screen.dart        # Pantalla de realización del test
│   │   │   └── results_screen.dart     # Pantalla de calificación y revisión
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Tema adaptativo Tablet (claro/oscuro)
│   │   └── widgets/
│   │       └── question_card.dart      # Tarjeta interactiva de pregunta
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## 📋 Esquema de Datos (SQLite)

```sql
CREATE TABLE questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  subject TEXT NOT NULL,           -- Asignatura (ej. "Desarrollo Cognitivo")
  topic TEXT NOT NULL,             -- Tema / Módulo
  question TEXT NOT NULL,          -- Enunciado
  options TEXT NOT NULL,           -- Array JSON: ["Opción A", "Opción B", "Opción C"]
  correct_index INTEGER NOT NULL,  -- Índice de la respuesta correcta (0, 1, 2)
  explanation TEXT NOT NULL,       -- Justificación didáctica según manuales UNED
  is_favorite INTEGER DEFAULT 0,   -- 1 si está marcada como duda/favorita
  times_answered INTEGER DEFAULT 0,-- Total de veces respondida
  times_failed INTEGER DEFAULT 0   -- Veces fallada por el usuario
);
```

---

## 🚀 Ejecución en Tablet o Emulador

Para ejecutar el proyecto en tu dispositivo o emulador Android:

```bash
flutter pub get
flutter run
```
