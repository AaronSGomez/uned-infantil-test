import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/models/question_model.dart';

enum ExamMode { simulation, practice }

class ExamController extends ChangeNotifier {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  ExamMode _mode = ExamMode.simulation;
  ExamMode get mode => _mode;

  List<Question> _questions = [];
  List<Question> get questions => _questions;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // Mapa de respuestas del usuario: questionIndex -> selectedOptionIndex
  final Map<int, int> _userAnswers = {};
  Map<int, int> get userAnswers => _userAnswers;

  // Estado de si se ha revelado la solución en modo práctica
  final Map<int, bool> _revealedAnswers = {};
  Map<int, bool> get revealedAnswers => _revealedAnswers;

  // Temporizador para Simulación
  Timer? _timer;
  int _secondsRemaining = 0;
  int get secondsRemaining => _secondsRemaining;
  bool _isTimerRunning = false;
  bool get isTimerRunning => _isTimerRunning;

  bool _isFinished = false;
  bool get isFinished => _isFinished;

  Future<void> startExam({
    required ExamMode mode,
    String? subject,
    int count = 20,
    bool onlyFailed = false,
    bool onlyFavorites = false,
    int durationMinutes = 30,
  }) async {
    _mode = mode;
    _currentIndex = 0;
    _userAnswers.clear();
    _revealedAnswers.clear();
    _isFinished = false;

    if (onlyFailed) {
      _questions = await dbHelper.getFailedQuestions(count: count);
    } else if (onlyFavorites) {
      _questions = await dbHelper.getFavoriteQuestions();
    } else {
      _questions = await dbHelper.getRandomQuestions(subject: subject, count: count);
    }

    if (_mode == ExamMode.simulation && durationMinutes > 0) {
      _startTimer(durationMinutes * 60);
    } else {
      _stopTimer();
    }

    notifyListeners();
  }

  void _startTimer(int seconds) {
    _secondsRemaining = seconds;
    _isTimerRunning = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        finishExam();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
  }

  void selectOption(int optionIndex) {
    if (_isFinished) return;
    
    // Si ya se ha respondido en modo práctica, no permitir cambiar
    if (_mode == ExamMode.practice && _revealedAnswers[_currentIndex] == true) {
      return;
    }

    _userAnswers[_currentIndex] = optionIndex;

    if (_mode == ExamMode.practice) {
      _revealedAnswers[_currentIndex] = true;
      // Actualizar estadísticas inmediatas en BD
      final q = currentQuestion;
      if (q != null && q.id != null) {
        final isCorrect = optionIndex == q.correctIndex;
        dbHelper.updateQuestionStats(q.id!, isCorrect: isCorrect);
      }
    }

    notifyListeners();
  }

  void clearSelection() {
    if (_mode == ExamMode.practice && _revealedAnswers[_currentIndex] == true) return;
    _userAnswers.remove(_currentIndex);
    notifyListeners();
  }

  void goToNext() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void goToPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  Future<void> toggleCurrentFavorite() async {
    final q = currentQuestion;
    if (q != null && q.id != null) {
      final newFav = !q.isFavorite;
      await dbHelper.toggleFavorite(q.id!, newFav);
      _questions[_currentIndex] = q.copyWith(isFavorite: newFav);
      notifyListeners();
    }
  }

  Future<void> finishExam() async {
    _stopTimer();
    _isFinished = true;

    // Si estábamos en simulación, guardamos estadísticas en la BD
    if (_mode == ExamMode.simulation) {
      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        if (q.id != null && _userAnswers.containsKey(i)) {
          final isCorrect = _userAnswers[i] == q.correctIndex;
          await dbHelper.updateQuestionStats(q.id!, isCorrect: isCorrect);
        }
      }
    }

    notifyListeners();
  }

  Question? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;

  int get correctCount {
    int count = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }

  int get wrongCount {
    int count = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers.containsKey(i) && _userAnswers[i] != _questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }

  int get blankCount => _questions.length - _userAnswers.length;

  /// Cálculo de nota UNED sobre 10:
  /// Formula estándar: [Aciertos - Errores / (k - 1)] * (10 / Total)
  /// Para 3 alternativas: k=3 => penalización de 0.5 (o 0.33 según asignatura, calculable dinámicamente)
  double get scoreOver10 {
    if (_questions.isEmpty) return 0.0;
    double netPoints = 0.0;
    for (int i = 0; i < _questions.length; i++) {
      if (!_userAnswers.containsKey(i)) continue;
      final q = _questions[i];
      final k = q.options.length > 1 ? q.options.length : 3;
      final penaltyFactor = 1.0 / (k - 1);

      if (_userAnswers[i] == q.correctIndex) {
        netPoints += 1.0;
      } else {
        netPoints -= penaltyFactor;
      }
    }
    if (netPoints < 0) netPoints = 0.0;
    final score = (netPoints / _questions.length) * 10;
    return double.parse(score.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
