import 'package:flutter/material.dart';
import '../../data/models/question_model.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedOption;
  final bool isPracticeMode;
  final bool isRevealed;
  final Function(int) onOptionSelected;
  final VoidCallback onClearSelection;
  final VoidCallback onToggleFavorite;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedOption,
    required this.isPracticeMode,
    required this.isRevealed,
    required this.onOptionSelected,
    required this.onClearSelection,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final letters = ['A', 'B', 'C', 'D', 'E'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera de la pregunta: Asignatura + Favorito
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                label: Text(
                  '${question.subject} • ${question.topic}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                iconSize: 32,
                tooltip: question.isFavorite ? 'Quitar de favoritas' : 'Marcar como duda / favorita',
                icon: Icon(
                  question.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: question.isFavorite ? Colors.amber : Colors.grey,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Enunciado con tipografía grande y cómoda
          Container(
            padding: const EdgeInsets.all(22.0),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
            ),
            child: Text(
              '$questionNumber. ${question.question}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Opciones de respuesta
          ...List.generate(question.options.length, (index) {
            final optionLetter = letters[index % letters.length];
            final optionText = question.options[index];
            final isSelected = selectedOption == index;
            final isCorrect = question.correctIndex == index;

            Color borderColor = theme.dividerColor.withOpacity(0.2);
            Color backgroundColor = theme.cardTheme.color ?? Colors.white;
            Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

            if (isPracticeMode && isRevealed) {
              if (isCorrect) {
                borderColor = Colors.green;
                backgroundColor = Colors.green.withOpacity(0.12);
                textColor = Colors.green.shade900;
              } else if (isSelected) {
                borderColor = Colors.red;
                backgroundColor = Colors.red.withOpacity(0.12);
                textColor = Colors.red.shade900;
              }
            } else if (isSelected) {
              borderColor = theme.colorScheme.primary;
              backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
              textColor = theme.colorScheme.primary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: isRevealed && isPracticeMode ? null : () => onOptionSelected(index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: isSelected || (isPracticeMode && isRevealed && isCorrect) ? 2.2 : 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isPracticeMode && isRevealed
                                  ? (isCorrect ? Colors.green : Colors.red)
                                  : theme.colorScheme.primary)
                              : theme.dividerColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          optionLetter,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: textColor,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Botón dejar en blanco si está seleccionada
          if (selectedOption != null && (!isPracticeMode || !isRevealed))
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Dejar en blanco (anular respuesta)'),
                onPressed: onClearSelection,
              ),
            ),

          // En Modo Práctica: Explicación Didáctica tras responder
          if (isPracticeMode && isRevealed) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade700, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, color: Colors.amber.shade800, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Justificación Didáctica UNED',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    question.explanation.isNotEmpty
                        ? question.explanation
                        : 'Esta respuesta se fundamenta en las guías y manuales docentes oficiales de la asignatura.',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.brown.shade900,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
