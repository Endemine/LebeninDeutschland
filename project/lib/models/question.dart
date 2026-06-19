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
  /// Grundsätze der Verfassung (Demokratie, Rechte, Freiheiten)
  constitution,

  /// Deutsche Geschichte
  history,

  /// Gesellschaft und Soziales
  society,

  /// Recht und Rechtssystem
  law,

  /// Politik und Staatsaufbau
  politics,

  /// Kultur und Bildung
  culture,

  /// Religion und Weltanschauung
  religion,

  /// Europa und die Welt
  europe,

  /// Natur und Umwelt
  environment,

  /// Wirtschaft und Arbeit
  economy,
}

/// Extension für die Anzeige-Namen der Kategorien
extension QuestionCategoryExtension on QuestionCategory {
  /// Der deutsche Anzeigename der Kategorie
  String get displayName {
    switch (this) {
      case QuestionCategory.constitution:
        return 'Verfassungsprinzipien';
      case QuestionCategory.history:
        return 'Geschichte';
      case QuestionCategory.society:
        return 'Gesellschaft';
      case QuestionCategory.law:
        return 'Recht';
      case QuestionCategory.politics:
        return 'Politik';
      case QuestionCategory.culture:
        return 'Kultur & Bildung';
      case QuestionCategory.religion:
        return 'Religion';
      case QuestionCategory.europe:
        return 'Europa & Welt';
      case QuestionCategory.environment:
        return 'Natur & Umwelt';
      case QuestionCategory.economy:
        return 'Wirtschaft & Arbeit';
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

  /// Konstruktor
  const Question({
    required this.id,
    required this.text,
    required this.answers,
    required this.correctAnswerIndex,
    required this.category,
    this.state,
    this.explanation,
  });

  /// Factory: Erstellt eine Question aus JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      text: json['text'] as String,
      answers: List<String>.from(json['answers'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      category: QuestionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => QuestionCategory.politics,
      ),
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
