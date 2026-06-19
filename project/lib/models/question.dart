// =============================================================================
// QUESTION MODEL
// =============================================================================
// Repräsentiert eine einzelne Frage des Einbürgerungstests.
// Jede Frage hat eine eindeutige ID, einen Fragetext, 4 Antwortmöglichkeiten,
// den Index der richtigen Antwort, eine Kategorie und ein optionales Bundesland.
// =============================================================================

import 'dart:convert';

/// Kategorien für Einbürgerungstest-Fragen
enum QuestionCategory {
  /// Allgemeine Fragen (gesamter Fragenpool)
  allgemein,

  /// Bundeslandspezifische Fragen
  bundesland,
}

/// Extension für die Anzeige-Namen der Kategorien
extension QuestionCategoryExtension on QuestionCategory {
  /// Der deutsche Anzeigename der Kategorie
  String get displayName {
    switch (this) {
      case QuestionCategory.allgemein:
        return 'Allgemein';
      case QuestionCategory.bundesland:
        return 'Bundesland';
    }
  }
}

/// Repräsentiert eine Einbürgerungstest-Frage
class Question {
  /// Eindeutige ID der Frage (1-300 für allgemeine, 301+ für bundeslandspezifische)
  final int id;

  /// Der Fragetext
  final String text;

  /// Die 4 Antwortmöglichkeiten
  final List<String> answers;

  /// Index der richtigen Antwort (0-3)
  final int correctAnswerIndex;

  /// Kategorie der Frage
  final QuestionCategory category;

  /// Optionales Bundesland (null für allgemeine Fragen)
  final String? state;

  /// Erklärungstext zur richtigen Antwort (für Lernmodus)
  final String? explanation;

  /// Englische Übersetzung des Fragetexts
  final String? questionEn;

  /// Arabische Übersetzung des Fragetexts
  final String? questionAr;

  /// Englische Übersetzungen der Antworten
  final List<String>? answersEn;

  /// Arabische Übersetzungen der Antworten
  final List<String>? answersAr;

  /// Konstruktor
  const Question({
    required this.id,
    required this.text,
    required this.answers,
    required this.correctAnswerIndex,
    required this.category,
    this.state,
    this.explanation,
    this.questionEn,
    this.questionAr,
    this.answersEn,
    this.answersAr,
  });

  /// Liefert den Fragetext in der gewünschten Sprache ('de', 'en', 'ar')
  String questionFor(String lang) {
    switch (lang) {
      case 'en':
        return questionEn ?? text;
      case 'ar':
        return questionAr ?? text;
      default:
        return text;
    }
  }

  /// Liefert die Antworten in der gewünschten Sprache ('de', 'en', 'ar')
  List<String> answersFor(String lang) {
    switch (lang) {
      case 'en':
        return (answersEn != null && answersEn!.length == answers.length)
            ? answersEn!
            : answers;
      case 'ar':
        return (answersAr != null && answersAr!.length == answers.length)
            ? answersAr!
            : answers;
      default:
        return answers;
    }
  }

  /// Erstellt eine Kopie mit Übersetzungen
  Question withTranslations({
    String? questionEn,
    String? questionAr,
    List<String>? answersEn,
    List<String>? answersAr,
  }) {
    return Question(
      id: id,
      text: text,
      answers: answers,
      correctAnswerIndex: correctAnswerIndex,
      category: category,
      state: state,
      explanation: explanation,
      questionEn: questionEn ?? this.questionEn,
      questionAr: questionAr ?? this.questionAr,
      answersEn: answersEn ?? this.answersEn,
      answersAr: answersAr ?? this.answersAr,
    );
  }

  /// Factory: Erstellt eine Question aus JSON
  /// Unterstützt sowohl das interne Format (text/correctAnswerIndex/category.name)
  /// als auch das Asset-Format (question/correct/category als String)
  factory Question.fromJson(Map<String, dynamic> json) {
    // Asset-Format: {question, answers, correct (int), category (String)}
    final text = json['question'] as String? ?? json['text'] as String;
    final answers = List<String>.from(json['answers'] as List);
    final correctIndex = json['correct'] is int
        ? json['correct'] as int
        : json['correctAnswerIndex'] as int;

    // Category-Mapping: Asset-String → QuestionCategory
    final categoryStr = json['category'] as String? ?? '';
    QuestionCategory category;
    switch (categoryStr) {
      case 'Allgemein':
        category = QuestionCategory.allgemein;
        break;
      case 'Bundesland':
        category = QuestionCategory.bundesland;
        break;
      default:
        category = QuestionCategory.allgemein;
    }

    return Question(
      id: json['id'] as int,
      text: text,
      answers: answers,
      correctAnswerIndex: correctIndex,
      category: category,
      state: json['state'] as String?,
      explanation: json['explanation'] as String?,
    );
  }

  /// Konvertiert die Question zu JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'answers': answers,
      'correctAnswerIndex': correctAnswerIndex,
      'category': category.name,
      'state': state,
      'explanation': explanation,
    };
  }

  /// Konvertiert die Question zu einem JSON-String
  String toJsonString() => jsonEncode(toJson());

  /// Gibt die richtige Antwort zurück
  String get correctAnswer => answers[correctAnswerIndex];

  /// Prüft ob eine Antwort korrekt ist
  bool isCorrect(int answerIndex) => answerIndex == correctAnswerIndex;

  /// Gibt an ob es eine bundeslandspezifische Frage ist
  bool get isStateSpecific => state != null;

  @override
  String toString() =>
      'Question(id: $id, text: ${text.substring(0, text.length > 30 ? 30 : text.length)}..., category: ${category.name})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
