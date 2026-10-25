import 'dart:convert';

class Question {
  final int? id;
  final String subject;
  final String topic;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final bool isFavorite;
  final int timesAnswered;
  final int timesFailed;

  Question({
    this.id,
    required this.subject,
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.isFavorite = false,
    this.timesAnswered = 0,
    this.timesFailed = 0,
  });

  Question copyWith({
    int? id,
    String? subject,
    String? topic,
    String? question,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    bool? isFavorite,
    int? timesAnswered,
    int? timesFailed,
  }) {
    return Question(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      question: question ?? this.question,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      isFavorite: isFavorite ?? this.isFavorite,
      timesAnswered: timesAnswered ?? this.timesAnswered,
      timesFailed: timesFailed ?? this.timesFailed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'topic': topic,
      'question': question,
      'options': jsonEncode(options),
      'correct_index': correctIndex,
      'explanation': explanation,
      'is_favorite': isFavorite ? 1 : 0,
      'times_answered': timesAnswered,
      'times_failed': timesFailed,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    List<String> parsedOptions = [];
    if (map['options'] is String) {
      final decoded = jsonDecode(map['options']);
      if (decoded is List) {
        parsedOptions = decoded.map((e) => e.toString()).toList();
      }
    } else if (map['options'] is List) {
      parsedOptions = (map['options'] as List).map((e) => e.toString()).toList();
    }

    return Question(
      id: map['id'] as int?,
      subject: map['subject'] ?? 'General',
      topic: map['topic'] ?? 'Tema general',
      question: map['question'] ?? '',
      options: parsedOptions,
      correctIndex: map['correct_index'] ?? map['correctIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      isFavorite: (map['is_favorite'] ?? map['isFavorite'] ?? 0) == 1,
      timesAnswered: map['times_answered'] ?? map['timesAnswered'] ?? 0,
      timesFailed: map['times_failed'] ?? map['timesFailed'] ?? 0,
    );
  }
}
