import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/question_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('uned_infantil.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        topic TEXT NOT NULL,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_index INTEGER NOT NULL,
        explanation TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        times_answered INTEGER NOT NULL DEFAULT 0,
        times_failed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Pre-poblar datos iniciales si existen en assets
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/seed_questions.json');
      final List<dynamic> list = jsonDecode(jsonString);
      final batch = db.batch();
      for (var item in list) {
        batch.insert('questions', {
          'subject': item['subject'] ?? 'General',
          'topic': item['topic'] ?? 'Tema general',
          'question': item['question'] ?? '',
          'options': jsonEncode(item['options'] ?? []),
          'correct_index': item['correctIndex'] ?? 0,
          'explanation': item['explanation'] ?? '',
          'is_favorite': item['isFavorite'] ?? 0,
          'times_answered': item['timesAnswered'] ?? 0,
          'times_failed': item['timesFailed'] ?? 0,
        });
      }
      await batch.commit(noResult: true);
    } catch (e) {
      // Si no existe el asset durante testing o inicialización temprana, continuar de forma segura
    }
  }

  Future<List<String>> getSubjects() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT DISTINCT subject FROM questions ORDER BY subject ASC');
    return result.map((r) => r['subject'] as String).toList();
  }

  Future<List<Question>> getRandomQuestions({String? subject, int count = 20}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;
    if (subject != null && subject.isNotEmpty && subject != 'Todas') {
      result = await db.query(
        'questions',
        where: 'subject = ?',
        whereArgs: [subject],
        orderBy: 'RANDOM()',
        limit: count,
      );
    } else {
      result = await db.query(
        'questions',
        orderBy: 'RANDOM()',
        limit: count,
      );
    }
    return result.map((json) => Question.fromMap(json)).toList();
  }

  Future<List<Question>> getFailedQuestions({int count = 30}) async {
    final db = await instance.database;
    final result = await db.query(
      'questions',
      where: 'times_failed > 0',
      orderBy: 'times_failed DESC',
      limit: count,
    );
    return result.map((json) => Question.fromMap(json)).toList();
  }

  Future<List<Question>> getFavoriteQuestions() async {
    final db = await instance.database;
    final result = await db.query(
      'questions',
      where: 'is_favorite = 1',
      orderBy: 'id DESC',
    );
    return result.map((json) => Question.fromMap(json)).toList();
  }

  Future<void> updateQuestionStats(int questionId, {required bool isCorrect}) async {
    final db = await instance.database;
    await db.rawUpdate('''
      UPDATE questions 
      SET times_answered = times_answered + 1,
          times_failed = times_failed + ?
      WHERE id = ?
    ''', [isCorrect ? 0 : 1, questionId]);
  }

  Future<void> toggleFavorite(int questionId, bool isFavorite) async {
    final db = await instance.database;
    await db.update(
      'questions',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  Future<int> insertQuestion(Question question) async {
    final db = await instance.database;
    return await db.insert('questions', question.toMap());
  }

  Future<int> bulkImportFromJson(String rawJson) async {
    final db = await instance.database;
    final List<dynamic> list = jsonDecode(rawJson);
    final batch = db.batch();
    for (var item in list) {
      batch.insert('questions', {
        'subject': item['subject'] ?? 'General',
        'topic': item['topic'] ?? 'Tema general',
        'question': item['question'] ?? '',
        'options': jsonEncode(item['options'] ?? []),
        'correct_index': item['correctIndex'] ?? 0,
        'explanation': item['explanation'] ?? '',
        'is_favorite': 0,
        'times_answered': 0,
        'times_failed': 0,
      });
    }
    final results = await batch.commit(noResult: true);
    return results.length;
  }

  Future<Map<String, int>> getGlobalStats() async {
    final db = await instance.database;
    final totalQ = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM questions')) ?? 0;
    final totalAnswered = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(times_answered) FROM questions')) ?? 0;
    final totalFailed = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(times_failed) FROM questions')) ?? 0;
    final totalFav = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM questions WHERE is_favorite = 1')) ?? 0;

    return {
      'totalQuestions': totalQ,
      'totalAnswered': totalAnswered,
      'totalFailed': totalFailed,
      'totalFavorites': totalFav,
    };
  }
}
