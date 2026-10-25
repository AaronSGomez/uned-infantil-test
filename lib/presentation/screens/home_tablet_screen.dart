import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/database_helper.dart';
import '../controllers/exam_controller.dart';
import 'exam_screen.dart';

class HomeTabletScreen extends StatefulWidget {
  const HomeTabletScreen({super.key});

  @override
  State<HomeTabletScreen> createState() => _HomeTabletScreenState();
}

class _HomeTabletScreenState extends State<HomeTabletScreen> {
  int _selectedNavigationIndex = 0;
  List<String> _subjects = ['Todas las asignaturas'];
  String _selectedSubject = 'Todas las asignaturas';
  int _questionCount = 20;
  ExamMode _selectedMode = ExamMode.practice;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final subs = await DatabaseHelper.instance.getSubjects();
    final stats = await DatabaseHelper.instance.getGlobalStats();
    setState(() {
      _subjects = ['Todas las asignaturas', ...subs];
      _selectedSubject = 'Todas las asignaturas';
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // NavigationRail para aprovechar el ancho en tablet
            NavigationRail(
              extended: isLandscape,
              minExtendedWidth: 230,
              selectedIndex: _selectedNavigationIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedNavigationIndex = index);
                if (index == 2) _loadInitialData();
              },
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_rounded, size: 36, color: theme.colorScheme.primary),
                    if (isLandscape) ...[
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UNED Infantil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('Autoevaluación', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.quiz_outlined),
                  selectedIcon: Icon(Icons.quiz_rounded),
                  label: Text('Tests de Estudio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.rule_folder_outlined),
                  selectedIcon: Icon(Icons.rule_folder_rounded),
                  label: Text('Repaso Falladas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: Text('Estadísticas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.file_upload_outlined),
                  selectedIcon: Icon(Icons.file_upload_rounded),
                  label: Text('Importar / Datos'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Contenido dinámico según pestaña seleccionada
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSelectedContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedContent(BuildContext context) {
    switch (_selectedNavigationIndex) {
      case 0:
        return _buildTestConfigView(context);
      case 1:
        return _buildReviewView(context);
      case 2:
        return _buildStatsView(context);
      case 3:
        return _buildImportView(context);
      default:
        return _buildTestConfigView(context);
    }
  }

  // Pestaña 1: Configuración de Test
  Widget _buildTestConfigView(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preparar Sesión de Test', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Elige la asignatura, el modo didáctico y el volumen de preguntas para tu sesión de estudio.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Selector de Asignatura
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. Asignatura o Módulo UNED', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    ),
                    items: _subjects.map((sub) => DropdownMenuItem(value: sub, child: Text(sub, style: const TextStyle(fontSize: 16)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSubject = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Selector de Modo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('2. Modo de Examen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModeOption(
                          title: 'Modo Práctica / Repaso',
                          subtitle: 'Corrección inmediata al pulsar y justificación didáctica visible para asimilar conceptos.',
                          icon: Icons.lightbulb_outline_rounded,
                          mode: ExamMode.practice,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModeOption(
                          title: 'Simulación Examen UNED',
                          subtitle: 'Sin retroalimentación hasta terminar, con temporizador y penalización oficial de errores.',
                          icon: Icons.timer_outlined,
                          mode: ExamMode.simulation,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Selector de Preguntas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('3. Cantidad de preguntas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    children: [10, 20, 30, 50].map((count) {
                      final isSelected = _questionCount == count;
                      return ChoiceChip(
                        label: Text('$count preguntas', style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        onSelected: (sel) {
                          if (sel) setState(() => _questionCount = count);
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Botón Iniciar
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text('Iniciar Test Ahora', style: TextStyle(fontSize: 18)),
            onPressed: () async {
              final controller = context.read<ExamController>();
              await controller.startExam(
                mode: _selectedMode,
                subject: _selectedSubject == 'Todas las asignaturas' ? null : _selectedSubject,
                count: _questionCount,
              );
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExamScreen()),
                ).then((_) => _loadInitialData());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required ExamMode mode,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedMode == mode;
    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: isSelected ? theme.colorScheme.primary : Colors.grey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? theme.colorScheme.primary : null)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pestaña 2: Repaso de Falladas y Favoritas
  Widget _buildReviewView(BuildContext context) {
    final theme = Theme.of(context);
    final failedCount = _stats['totalFailed'] ?? 0;
    final favCount = _stats['totalFavorites'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Banco de Falladas y Dudosas', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Repite las preguntas en las que has tropezado para fijar conceptos clave.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Test de Preguntas Falladas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Tienes $failedCount fallos acumulados en tu histórico de estudio.', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Practicar Falladas'),
                          onPressed: failedCount == 0
                              ? null
                              : () async {
                                  final controller = context.read<ExamController>();
                                  await controller.startExam(mode: ExamMode.practice, onlyFailed: true);
                                  if (context.mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamScreen())).then((_) => _loadInitialData());
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.star_rounded, size: 40, color: Colors.amber),
                        const SizedBox(height: 16),
                        const Text('Preguntas Marcadas con Estrella', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Tienes $favCount preguntas guardadas como dudosas o favoritas.', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.star_outline_rounded),
                          label: const Text('Practicar Favoritas'),
                          onPressed: favCount == 0
                              ? null
                              : () async {
                                  final controller = context.read<ExamController>();
                                  await controller.startExam(mode: ExamMode.practice, onlyFavorites: true);
                                  if (context.mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamScreen())).then((_) => _loadInitialData());
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Pestaña 3: Estadísticas Globales
  Widget _buildStatsView(BuildContext context) {
    final theme = Theme.of(context);
    final totalQ = _stats['totalQuestions'] ?? 0;
    final totalAnswered = _stats['totalAnswered'] ?? 0;
    final totalFailed = _stats['totalFailed'] ?? 0;
    final correctTotal = totalAnswered > totalFailed ? totalAnswered - totalFailed : 0;
    final accuracy = totalAnswered > 0 ? ((correctTotal / totalAnswered) * 100).toStringAsFixed(1) : '0.0';

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rendimiento y Progreso', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text('Seguimiento general de tu preparación para el grado.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildBigStatCard('Banco Total', '$totalQ', 'Preguntas en local', Colors.blue),
              const SizedBox(width: 16),
              _buildBigStatCard('Contestadas', '$totalAnswered', 'Intentos de examen', Colors.teal),
              const SizedBox(width: 16),
              _buildBigStatCard('Tasa de Acierto', '$accuracy%', '$correctTotal aciertos', Colors.green),
              const SizedBox(width: 16),
              _buildBigStatCard('Total Fallos', '$totalFailed', 'Para reforzar', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigStatCard(String title, String mainValue, String subValue, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 12),
              Text(mainValue, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 6),
              Text(subValue, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  // Pestaña 4: Importación / Gestión de Base de Datos
  Widget _buildImportView(BuildContext context) {
    final theme = Theme.of(context);
    final textController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Importación de Preguntas', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Puedes importar preguntas pegando un JSON con la estructura estándar (o cargando archivos externos).',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: textController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: '[\n  {\n    "subject": "Didáctica",\n    "topic": "Tema 1",\n    "question": "¿Enunciado?",\n    "options": ["Opción A", "Opción B", "Opción C"],\n    "correctIndex": 0,\n    "explanation": "Justificación..."\n  }\n]',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.download_rounded),
            label: const Text('Importar a Base de Datos Local'),
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              try {
                final count = await DatabaseHelper.instance.bulkImportFromJson(textController.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('¡Se han importado $count preguntas con éxito!')),
                  );
                  _loadInitialData();
                  textController.clear();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al procesar el JSON: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
