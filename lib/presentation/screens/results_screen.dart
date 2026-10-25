import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/exam_controller.dart';
import 'exam_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExamController>();
    final theme = Theme.of(context);
    final score = controller.scoreOver10;

    Color badgeColor;
    String badgeText;
    if (score >= 9.0) {
      badgeColor = Colors.green.shade700;
      badgeText = 'SOBRESALIENTE';
    } else if (score >= 7.0) {
      badgeColor = Colors.teal.shade700;
      badgeText = 'NOTABLE';
    } else if (score >= 5.0) {
      badgeColor = Colors.blue.shade700;
      badgeText = 'APROBADO';
    } else {
      badgeColor = Colors.red.shade700;
      badgeText = 'NO APTO (SUSPENSO)';
    }

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados de la Evaluación'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Volver al Menú Principal',
            icon: const Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: isLandscape
            ? Row(
                children: [
                  // Panel lateral de Calificación (Landscape Tablet)
                  SizedBox(
                    width: 380,
                    child: Card(
                      margin: const EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildSummaryPanel(context, controller, score, badgeColor, badgeText),
                      ),
                    ),
                  ),
                  // Detalle de revisión de preguntas
                  Expanded(
                    child: _buildDetailedReview(context, controller),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildSummaryPanel(context, controller, score, badgeColor, badgeText),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Revisión Detallada de Respuestas',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailedReviewList(context, controller),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryPanel(
    BuildContext context,
    ExamController controller,
    double score,
    Color badgeColor,
    String badgeText,
  ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('CALIFICACIÓN FINAL UNED', style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Text(
          score.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: badgeColor,
          ),
        ),
        Text('sobre 10.00', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Chip(
          backgroundColor: badgeColor.withOpacity(0.15),
          label: Text(
            badgeText,
            style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Aciertos', '${controller.correctCount}', Colors.green),
            _buildStatItem('Fallos', '${controller.wrongCount}', Colors.red),
            _buildStatItem('En blanco', '${controller.blankCount}', Colors.grey),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Repetir Preguntas Falladas'),
          onPressed: controller.wrongCount == 0
              ? null
              : () async {
                  await controller.startExam(
                    mode: ExamMode.practice,
                    onlyFailed: true,
                  );
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ExamScreen()),
                    );
                  }
                },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Volver al Inicio'),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildDetailedReview(BuildContext context, ExamController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: controller.questions.length,
      itemBuilder: (context, index) {
        return _buildQuestionReviewCard(context, controller, index);
      },
    );
  }

  Widget _buildDetailedReviewList(BuildContext context, ExamController controller) {
    return Column(
      children: List.generate(
        controller.questions.length,
        (index) => _buildQuestionReviewCard(context, controller, index),
      ),
    );
  }

  Widget _buildQuestionReviewCard(BuildContext context, ExamController controller, int index) {
    final q = controller.questions[index];
    final userAnswer = controller.userAnswers[index];
    final isCorrect = userAnswer == q.correctIndex;
    final isBlank = userAnswer == null;

    final statusColor = isBlank
        ? Colors.grey
        : (isCorrect ? Colors.green : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isBlank
                      ? Icons.remove_circle_outline_rounded
                      : (isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded),
                  color: statusColor,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  'Pregunta ${index + 1} • ${q.subject}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(q.question, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Text(
              'Tu respuesta: ${isBlank ? 'Dejada en blanco' : q.options[userAnswer]}',
              style: TextStyle(color: isBlank ? Colors.grey.shade700 : (isCorrect ? Colors.green.shade800 : Colors.red.shade800), fontWeight: FontWeight.w500),
            ),
            if (!isCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Respuesta correcta: ${q.options[q.correctIndex]}',
                  style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Justificación: ${q.explanation}',
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
