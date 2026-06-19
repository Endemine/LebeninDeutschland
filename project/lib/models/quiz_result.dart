import 'question.dart';
import 'quiz_state.dart';

/// Repräsentiert das Ergebnis eines abgeschlossenen Einbürgerungstests.
///
/// Speichert alle relevanten Daten eines Quiz-Durchlaufs:
/// - Statistiken (richtig/falsch/unbeantwortet)
/// - Bestehensstatus (mind. 17 von 33 Fragen richtig)
/// - Dauer und Datum
/// - Detaillierte Antworten pro Frage
///
/// Ein Test gilt als bestanden wenn mindestens 17 der 33 Fragen
/// richtig beantwortet wurden.
class QuizResult {
  /// Eindeutige ID dieses Ergebnisses (UUID).
  final String id;

  /// Datum und Uhrzeit der Testdurchführung.
  final DateTime date;

  /// Gesamtanzahl der Fragen (immer 33).
  final int totalQuestions;

  /// Anzahl der richtig beantworteten Fragen.
  final int correctAnswers;

  /// Anzahl der falsch beantworteten Fragen.
  final int wrongAnswers;

  /// Anzahl der nicht beantworteten Fragen.
  final int unanswered;

  /// Gibt an, ob der Test bestanden wurde (>=17 richtig).
  final bool passed;

  /// Dauer des Tests in Sekunden.
  final int durationSeconds;

  /// Detaillierte Antworten für jede Frage.
  final List<QuestionAnswer> questionAnswers;

  /// Das gewählte Bundesland für diesen Test.
  /// `null` wenn nur allgemeine Fragen getestet wurden.
  final String? state;

  /// Erstellt ein neues Quiz-Ergebnis.
  ///
  /// Alle Werte werden direkt gesetzt. Für die Berechnung aus einem
  /// [QuizState] sollte [QuizResult.fromQuizState] verwendet werden.
  const QuizResult({
    required this.id,
    required this.date,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unanswered,
    required this.passed,
    required this.durationSeconds,
    required this.questionAnswers,
    this.state,
  });

  /// Berechnet ein Quiz-Ergebnis aus einem abgeschlossenen [QuizState].
  ///
  /// Zählt automatisch die richtigen, falschen und unbeantworteten Fragen
  /// und bestimmt den Bestehensstatus.
  ///
  /// Alternative Signatur die direkt die Antworten und Fragen entgegennimmt,
  /// wie sie vom [QuizProvider] verwendet wird.
  factory QuizResult.fromQuizState({
    required Map<int, int?> answers,
    required List<Question> questions,
    required int timeTakenSeconds,
    String? selectedState,
  }) {
    int correct = 0;
    int wrong = 0;
    int unanswered = 0;

    final List<QuestionAnswer> questionAnswers = [];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = answers[i];

      questionAnswers.add(QuestionAnswer(
        question: question,
        userAnswer: userAnswer,
      ));

      if (userAnswer == null) {
        unanswered++;
      } else if (userAnswer == question.correctAnswerIndex) {
        correct++;
      } else {
        wrong++;
      }
    }

    return QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      totalQuestions: questions.length,
      correctAnswers: correct,
      wrongAnswers: wrong,
      unanswered: unanswered,
      passed: correct >= QuizState.passingThreshold,
      durationSeconds: timeTakenSeconds,
      questionAnswers: questionAnswers,
      state: selectedState,
    );
  }

  /// Die erreichte Prozentzahl (0-100).
  double get percentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  /// Alias für [percentage] - verwendet von StatisticsProvider.
  double get scorePercent => percentage;

  /// Formatierte Darstellung der Prozentzahl mit einer Nachkommastelle.
  String get percentageText => '${percentage.toStringAsFixed(1)}%';

  /// Prozentzahl als Text ohne Nachkommastelle (z.B. '52%').
  String get scorePercentText => '${percentage.toStringAsFixed(0)}%';

  /// Die erreichte Punktzahl im Format "17/33".
  String get scoreText => '$correctAnswers/$totalQuestions';

  /// Alias für [passed] - verwendet von UI und StatisticsProvider.
  bool get isPassed => passed;

  /// Alias für [date] - verwendet von StatisticsProvider.
  DateTime get completedAt => date;

  /// Alias für [durationSeconds] - verwendet von StatisticsProvider.
  int get timeTakenSeconds => durationSeconds;

  /// Die Fragen dieses Quiz-Ergebnisses (aus den Antworten abgeleitet).
  List<Question> get questions =>
      questionAnswers.map((qa) => qa.question).toList();

  /// Gibt an ob die Antwort für eine bestimmte Frage richtig war.
  ///
  /// [index] Der Fragen-Index. Gibt `false` zurück wenn der Index ungültig ist.
  bool questionCorrect(int index) {
    if (index < 0 || index >= questionAnswers.length) return false;
    return questionAnswers[index].isCorrect;
  }

  /// Formatierte Dauer im Format "MM:SS".
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Gibt eine Zusammenfassung der Ergebnisse pro Kategorie zurück.
  Map<String, CategoryResult> get resultsByCategory {
    final Map<String, CategoryResult> results = {};

    for (final qa in questionAnswers) {
      final category = qa.question.category.name;
      results.putIfAbsent(
        category,
        () => CategoryResult(category: category),
      );
      results[category]!.addAnswer(qa);
    }

    return results;
  }

  // ==========================================================================
  // JSON-Serialisierung
  // ==========================================================================

  /// Konvertiert das Ergebnis in ein JSON-Objekt.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'unanswered': unanswered,
      'passed': passed,
      'durationSeconds': durationSeconds,
      'state': state,
      'questionAnswers': questionAnswers.map((qa) => qa.toJson()).toList(),
    };
  }

  /// Erstellt ein QuizResult aus einem JSON-Objekt.
  ///
  /// [allQuestionsMap] ist eine Map von Fragen-ID zur Question-Instanz,
  /// die zum Nachschlagen der Fragen verwendet wird.
  factory QuizResult.fromJson(
    Map<String, dynamic> json,
    Map<int, Question> allQuestionsMap,
  ) {
    final answersJson = json['questionAnswers'] as List<dynamic>;
    final questionAnswers = answersJson
        .map((e) => QuestionAnswer.fromJson(
              e as Map<String, dynamic>,
              allQuestionsMap,
            ))
        .toList();

    return QuizResult(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      unanswered: json['unanswered'] as int,
      passed: json['passed'] as bool,
      durationSeconds: json['durationSeconds'] as int,
      state: json['state'] as String?,
      questionAnswers: questionAnswers,
    );
  }

  /// Erstellt ein QuizResult aus einem JSON-Objekt ohne Fragen-Nachschlagung.
  ///
  /// Verwendet von [StatisticsProvider] wenn keine Fragen-Map verfügbar ist.
  /// Die Fragen werden als Platzhalter geladen.
  factory QuizResult.fromJsonSimple(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      unanswered: json['unanswered'] as int,
      passed: json['passed'] as bool,
      durationSeconds: json['durationSeconds'] as int,
      state: json['state'] as String?,
      questionAnswers: [],
    );
  }

  @override
  String toString() {
    return 'QuizResult(id: $id, score: $scoreText, '
        '${passed ? "BESTANDEN" : "NICHT BESTANDEN"}, '
        'Dauer: $formattedDuration)';
  }
}

// =============================================================================
// QuestionAnswer
// =============================================================================

/// Repräsentiert die Antwort des Benutzers auf eine einzelne Frage.
///
/// Verknüpft die [Question] mit der vom Benutzer gewählten Antwort
/// und bietet Hilfsmethoden zur Bewertung.
class QuestionAnswer {
  /// Die Frage, auf die geantwortet wurde.
  final Question question;

  /// Der Index der vom Benutzer gewählten Antwort (0-3).
  /// `null` wenn die Frage nicht beantwortet wurde.
  final int? userAnswer;

  /// Erstellt eine neue QuestionAnswer.
  const QuestionAnswer({
    required this.question,
    this.userAnswer,
  });

  /// Gibt an, ob die Frage richtig beantwortet wurde.
  ///
  /// Gibt `false` zurück wenn [userAnswer] null ist (nicht beantwortet)
  /// oder wenn die Antwort falsch ist.
  bool get isCorrect => userAnswer == question.correctAnswerIndex;

  /// Gibt an, ob die Frage beantwortet wurde.
  bool get isAnswered => userAnswer != null;

  /// Gibt den Text der gewählten Antwort zurück.
  /// Leerer String wenn nicht beantwortet.
  String get userAnswerText =>
      userAnswer != null ? question.answers[userAnswer!] : '';

  /// Gibt den Buchstaben der gewählten Antwort zurück (A-D).
  /// Leerer String wenn nicht beantwortet.
  String get userAnswerLetter =>
      userAnswer != null ? String.fromCharCode(65 + userAnswer!) : '';

  // ==========================================================================
  // JSON-Serialisierung
  // ==========================================================================

  /// Konvertiert die Antwort in ein JSON-Objekt.
  ///
  /// Speichert nur die Fragen-ID und die Benutzerantwort,
  /// nicht die komplette Frage.
  Map<String, dynamic> toJson() {
    return {
      'questionId': question.id,
      'userAnswer': userAnswer,
    };
  }

  /// Erstellt eine QuestionAnswer aus einem JSON-Objekt.
  ///
  /// [allQuestionsMap] wird verwendet um die Frage anhand der ID nachzuschlagen.
  factory QuestionAnswer.fromJson(
    Map<String, dynamic> json,
    Map<int, Question> allQuestionsMap,
  ) {
    final questionId = json['questionId'] as int;
    final question = allQuestionsMap[questionId];

    if (question == null) {
      throw FormatException(
        'Frage mit ID $questionId nicht gefunden beim Laden des Quiz-Ergebnisses',
      );
    }

    return QuestionAnswer(
      question: question,
      userAnswer: json['userAnswer'] as int?,
    );
  }
}

// =============================================================================
// CategoryResult
// =============================================================================

/// Aggregiert die Ergebnisse für eine bestimmte Kategorie.
///
/// Wird von [QuizResult.resultsByCategory] verwendet um eine
/// übersichtliche Darstellung pro Kategorie zu erstellen.
class CategoryResult {
  /// Name der Kategorie.
  final String category;

  /// Anzahl der Fragen in dieser Kategorie.
  int totalQuestions = 0;

  /// Anzahl der richtig beantworteten Fragen.
  int correctAnswers = 0;

  /// Anzahl der falsch beantworteten Fragen.
  int wrongAnswers = 0;

  /// Anzahl der unbeantworteten Fragen.
  int unanswered = 0;

  /// Erstellt ein leeres CategoryResult.
  CategoryResult({required this.category});

  /// Fügt eine [QuestionAnswer] zu den Statistiken hinzu.
  void addAnswer(QuestionAnswer answer) {
    totalQuestions++;
    if (!answer.isAnswered) {
      unanswered++;
    } else if (answer.isCorrect) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }
  }

  /// Prozentzahl der richtigen Antworten in dieser Kategorie.
  double get percentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  /// Der Prozentsatz als Text mit einer Nachkommastelle.
  String get percentageText => '${percentage.toStringAsFixed(1)}%';
}
