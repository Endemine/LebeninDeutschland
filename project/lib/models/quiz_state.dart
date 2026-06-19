// =============================================================================
// QUIZ STATE MODEL
// =============================================================================
// Repräsentiert den kompletten Zustand eines laufenden Quizzes.
// Enthält alle Fragen, gegebene Antworten, aktuellen Index und Zeit.
// =============================================================================

import 'dart:convert';

import 'question.dart';

/// Der aktuelle Status eines Quiz-Durchlaufs
class QuizState {
  /// Liste aller Fragen im Quiz (33 Stück: 30 allgemeine + 3 bundeslandspezifische)
  final List<Question> questions;

  /// Map: Fragen-Index → gegebene Antwort (0-3) oder null wenn unbeantwortet
  final Map<int, int?> answers;

  /// Index der aktuell angezeigten Frage (0-32)
  final int currentQuestionIndex;

  /// Verbleibende Zeit in Sekunden (3600 = 60 Minuten)
  final int remainingSeconds;

  /// Gibt an ob das Quiz beendet wurde
  final bool isFinished;

  /// Das gewählte Bundesland für dieses Quiz
  final String? selectedState;

  /// Der Startzeitpunkt des Quiz (für Zeitmessung)
  final DateTime startTime;

  /// Schwelle zum Bestehen (17 von 33 Fragen richtig)
  static const int passingThreshold = 17;

  /// Privater Konstruktor
  const QuizState._({
    required this.questions,
    required this.answers,
    required this.currentQuestionIndex,
    required this.remainingSeconds,
    required this.isFinished,
    this.selectedState,
    required this.startTime,
  });

  /// Erstellt einen leeren Initialzustand
  factory QuizState.empty() {
    return QuizState._(
      questions: const [],
      answers: const {},
      currentQuestionIndex: 0,
      remainingSeconds: 3600, // 60 Minuten
      isFinished: false,
      selectedState: null,
      startTime: DateTime.now(),
    );
  }

  /// Erstellt einen neuen Zustand für ein gestartetes Quiz
  factory QuizState.start({
    required List<Question> questions,
    required String? selectedState,
  }) {
    // Initialisiere alle Antworten als unbeantwortet (null)
    final answers = <int, int?>{
      for (int i = 0; i < questions.length; i++) i: null,
    };

    return QuizState._(
      questions: questions,
      answers: answers,
      currentQuestionIndex: 0,
      remainingSeconds: 3600,
      isFinished: false,
      selectedState: selectedState,
      startTime: DateTime.now(),
    );
  }

  /// Kopiert den Zustand mit optionalen Änderungen
  QuizState copyWith({
    List<Question>? questions,
    Map<int, int?>? answers,
    int? currentQuestionIndex,
    int? remainingSeconds,
    bool? isFinished,
    String? selectedState,
    DateTime? startTime,
  }) {
    return QuizState._(
      questions: questions ?? this.questions,
      answers: answers ?? Map.unmodifiable(this.answers),
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isFinished: isFinished ?? this.isFinished,
      selectedState: selectedState ?? this.selectedState,
      startTime: startTime ?? this.startTime,
    );
  }

  /// Gibt die Antworten als Liste zurück (null für unbeantwortete Fragen).
  List<int?> get userAnswers {
    return List.generate(
      questions.length,
      (index) => answers[index],
    );
  }

  /// Gibt die aktuelle Frage zurück
  Question get currentQuestion => questions[currentQuestionIndex];

  /// Gibt die bereits gegebene Antwort für die aktuelle Frage zurück
  int? get currentAnswer => answers[currentQuestionIndex];

  /// Gibt an wie viele Fragen bereits beantwortet wurden
  int get answeredCount =>
      answers.values.where((answer) => answer != null).length;

  /// Gibt an wie viele Fragen noch nicht beantwortet wurden
  int get unansweredCount => questions.length - answeredCount;

  /// Fortschritt als Prozentwert (0.0 - 1.0)
  double get progressPercent =>
      questions.isEmpty ? 0.0 : answeredCount / questions.length;

  /// Formatierte verbleibende Zeit (MM:SS)
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Gibt an ob das Quiz gültig ist (Fragen vorhanden)
  bool get isValid => questions.isNotEmpty;

  /// Gibt die Antwort für einen bestimmten Fragen-Index zurück
  int? getAnswer(int index) =>
      (index >= 0 && index < questions.length) ? answers[index] : null;

  /// Konvertiert zu JSON für Persistenz
  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
      'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
      'currentQuestionIndex': currentQuestionIndex,
      'remainingSeconds': remainingSeconds,
      'isFinished': isFinished,
      'selectedState': selectedState,
      'startTime': startTime.toIso8601String(),
    };
  }

  /// Erstellt aus JSON (für Wiederherstellung)
  factory QuizState.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List)
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    final answersRaw = json['answers'] as Map<String, dynamic>? ?? {};
    final answers = <int, int?>{
      for (var entry in answersRaw.entries)
        int.parse(entry.key): entry.value as int?,
    };

    return QuizState._(
      questions: questions,
      answers: answers,
      currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
      remainingSeconds: json['remainingSeconds'] as int? ?? 3600,
      isFinished: json['isFinished'] as bool? ?? false,
      selectedState: json['selectedState'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'QuizState(questions: ${questions.length}, '
        'currentIndex: $currentQuestionIndex, '
        'answered: $answeredCount/${questions.length}, '
        'time: ${formattedTime}, finished: $isFinished)';
  }
}
