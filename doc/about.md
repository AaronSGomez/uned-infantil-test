# Acerca de UNED Infantil Test

## 1. Contexto Académico
Los exámenes del **Grado en Educación Infantil de la UNED** (Universidad Nacional de Educación a Distancia) se basan tradicionalmente en pruebas objetivas de elección múltiple (tipo test). Estas pruebas poseen una particularidad pedagógica y evaluativa determinante:
- Las preguntas cuentan con 3 o 4 opciones de respuesta.
- Los errores tienen una penalización matemática para neutralizar el efecto del azar.
- La preparación exige afianzar no solo la respuesta correcta, sino la **justificación conceptual** respaldada por los manuales y guías didácticas de cada asignatura (Didáctica, Desarrollo Cognitivo, Sociología de la Educación, Organización del Centro Escolar, etc.).

---

## 2. Visión del Proyecto y Filosofía de Diseño

### 🔒 100% Offline y Privacidad Absoluta
- **Cero dependencias de servidores externos**: La aplicación funciona en cualquier lugar sin conexión a internet (en viajes, bibliotecas o entornos sin cobertura).
- **Sin registros ni cuentas**: Sin formularios de inicio de sesión, sin tracking ni telemetría invasiva.
- **Persistencia local transparente**: Las estadísticas, preguntas falladas y favoritas se almacenan exclusivamente en el dispositivo del usuario mediante SQLite.

### 📱 Experiencia Tablet-First (10-11")
La mayoría de apps de test del mercado están pensadas exclusivamente para teléfonos móviles en vertical. Esta aplicación fue conceptualizada específicamente para tablet:
- **Modo Horizontal (Landscape)**: Aprovecha la amplitud de pantalla dividiendo la interfaz en un panel de control/navegador rápido y un área central de lectura relajada.
- **Navegación tipo NavigationRail**: Menú lateral ergonómico accesible con los pulgares mientras se sostiene la tablet.
- **Tipografía e Higiene Visual**: Fuentes de 18-22sp y fondos con bajo contraste agresivo (Slate Navy y Blanco roto en modo claro; Obsidian Slate en modo oscuro) para evitar la fatiga ocular durante sesiones de 2 a 4 horas de estudio continuo.
- **Botones táctiles grandes**: Altura mínima de opciones de 58dp para pulsaciones cómodas tanto con los dedos como con lápices ópticos (Stylus / S-Pen).

---

## 3. Modos de Uso

1. **Modo Práctica / Estudio Guiado**:
   - Corrección inmediata tras pulsar una opción.
   - Apertura automática de la caja de **Justificación Didáctica UNED** para comprender el fundamento teórico del acierto o fallo.
   - Posibilidad de marcar con estrella preguntas clave o dudosas.

2. **Modo Simulación UNED**:
   - Baterías de 10, 20 o 30 preguntas aleatorias o por asignatura.
   - Temporizador de cuenta atrás opcional.
   - Sin retroalimentación durante el test para emular la presión real del examen.
   - Pantalla final de resultados con calificación sobre 10 según la fórmula UNED y desglose analítico.

3. **Banco Inteligente de Repaso (Smart Review)**:
   - Filtro instantáneo de preguntas falladas para enfocar el esfuerzo en los puntos débiles.
   - Test enfocado en preguntas favoritas/dudosas.
