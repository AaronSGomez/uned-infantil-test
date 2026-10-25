import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/exam_controller.dart';
import '../widgets/question_card.dart';
import 'results_screen.dart';

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExamController>();
    final theme = Theme.of(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (controller.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Evaluación')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No hay preguntas disponibles con este filtro.', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Regresar'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQ = controller.currentQuestion!;
    final currentIndex = controller.currentIndex;
    final total = controller.questions.length;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('¿Deseas salir del test?'),
            content: const Text('El progreso del test en curso no se guardará.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Continuar test')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salir')),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            controller.mode == ExamMode.simulation ? 'Simulación Examen UNED' : 'Modo Práctica / Estudio',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (controller.isTimerRunning)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: controller.secondsRemaining < 300
                      ? Colors.red.withOpacity(0.15)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: controller.secondsRemaining < 300 ? Colors.red : theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(controller.secondsRemaining),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: controller.secondsRemaining < 300 ? Colors.red : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FilledButton.tonal(
                onPressed: () => _confirmFinish(context, controller),
                child: const Text('Finalizar'),
              ),
            ),
          ],
        ),
        body: isLandscape
            ? Row(
                children: [
                  // Cuadrícula lateral de preguntas para Tablet Landscape
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
                      color: theme.cardTheme.color?.withOpacity(0.5),
                    ),
                    child: _buildQuestionNavigator(context, controller),
                  ),
                  // Área principal de la pregunta
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: QuestionCard(
                            question: currentQ,
                            questionNumber: currentIndex + 1,
                            totalQuestions: total,
                            selectedOption: controller.userAnswers[currentIndex],
                            isPracticeMode: controller.mode == ExamMode.practice,
                            isRevealed: controller.revealedAnswers[currentIndex] ?? false,
                            onOptionSelected: (opt) => controller.selectOption(opt),
                            onClearSelection: () => controller.clearSelection(),
                            onToggleFavorite: () => controller.toggleCurrentFavorite(),
                          ),
                        ),
                        _buildBottomControlBar(context, controller),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / total,
                    backgroundColor: theme.dividerColor.withOpacity(0.2),
                  ),
                  Expanded(
                    child: QuestionCard(
                      question: currentQ,
                      questionNumber: currentIndex + 1,
                      totalQuestions: total,
                      selectedOption: controller.userAnswers[currentIndex],
                      isPracticeMode: controller.mode == ExamMode.practice,
                      isRevealed: controller.revealedAnswers[currentIndex] ?? false,
                      onOptionSelected: (opt) => controller.selectOption(opt),
                      onClearSelection: () => controller.clearSelection(),
                      onToggleFavorite: () => controller.toggleCurrentFavorite(),
                    ),
                  ),
                  _buildBottomControlBar(context, controller),
                ],
              ),
      ),
    );
  }

  Widget _buildQuestionNavigator(BuildContext context, ExamController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Navegador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${controller.userAnswers.length} / ${controller.questions.length} resp.', style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: controller.questions.length,
            itemBuilder: (context, index) {
              final isCurrent = index == controller.currentIndex;
              final isAnswered = controller.userAnswers.containsKey(index);
              final isFav = controller.questions[index].isFavorite;

              Color btnColor = theme.dividerColor.withOpacity(0.1);
              Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

              if (isCurrent) {
                btnColor = theme.colorScheme.primary;
                textColor = Colors.white;
              } else if (isAnswered) {
                btnColor = theme.colorScheme.primary.withOpacity(0.25);
              }

              return InkWell(
                onTap: () => controller.goToQuestion(index),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent ? theme.colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                        ),
                      ),
                      if (isFav)
                        const Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(Icons.star, size: 14, color: Colors.amber),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControlBar(BuildContext context, ExamController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.15))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Anterior', style: TextStyle(fontSize: 16)),
            onPressed: controller.currentIndex > 0 ? () => controller.goToPrevious() : null,
          ),
          Text(
            'Pregunta ${controller.currentIndex + 1} de ${controller.questions.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          ElevatedButton.icon(
            icon: Icon(
              controller.currentIndex < controller.questions.length - 1
                  ? Icons.arrow_forward_rounded
                  : Icons.check_circle_rounded,
            ),
            label: Text(
              controller.currentIndex < controller.questions.length - 1 ? 'Siguiente' : 'Finalizar Test',
              style: const TextStyle(fontSize: 16),
            ),
            onPressed: () {
              if (controller.currentIndex < controller.questions.length - 1) {
                controller.goToNext();
              } else {
                _confirmFinish(context, controller);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmFinish(BuildContext context, ExamController controller) {
    final unanswered = controller.questions.length - controller.userAnswers.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Finalizar y calificar el test?'),
        content: Text(
          unanswered > 0
              ? 'Tienes $unanswered preguntas sin responder que computarán como 0 puntos según la norma UNED.'
              : 'Has respondido todas las preguntas. ¿Deseas ver tu calificación final y justificaciones?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Seguir revisando')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.finishExam();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ResultsScreen()),
                );
              }
            },
            child: const Text('Calificar ahora'),
          ),
        ],
      ),
    );
  }
}
