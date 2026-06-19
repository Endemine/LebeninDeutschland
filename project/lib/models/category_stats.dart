import 'dart:math' as math;

// =============================================================================
// CATEGORY STATS MODEL
// =============================================================================
// Statistiken für eine einzelne Kategorie über alle Quiz-Durchläufe.
// Wird für die detaillierte Statistik-Ansicht verwendet.
// =============================================================================

/// Statistiken für eine einzelne Kategorie.
///
/// Speichert aggregierte Lernstatistiken für alle Fragen einer Kategorie,
/// z.B. "Allgemein", "Geschichte" oder "Verfassung".
///
/// Verwendung:
/// ```dart
/// final stats = CategoryStats(
///   category: 'Allgemein',
///   totalQuestions: 30,
///   learnedQuestions: 15,
///   correctAnswers: 12,
///   wrongAnswers: 3,
/// );
/// print('${stats.progressPercent}% gelernt');
/// ```
class CategoryStats {
  // ==========================================================================
  // Felder
  // ==========================================================================

  /// Name der Kategorie (z.B. "Allgemein", "Verfassung", "Geschichte").
  final String category;

  /// Gesamtanzahl der Fragen in dieser Kategorie.
  final int totalQuestions;

  /// Anzahl der Fragen, die der Benutzer als gelernt markiert hat.
  final int learnedQuestions;

  /// Anzahl der richtig beantworteten Fragen in dieser Kategorie.
  final int totalCorrect;

  /// Anzahl der falsch beantworteten Fragen in dieser Kategorie.
  final int totalWrong;

  /// Liste der letzten Ergebnisse (für Trend-Analyse).
  /// `true` = richtig, `false` = falsch (chronologisch sortiert).
  final List<bool> recentResults;

  // ==========================================================================
  // Konstruktor
  // ==========================================================================

  /// Erstellt neue Kategorie-Statistiken.
  ///
  /// Alle Zähler starten bei 0 wenn nicht angegeben.
  const CategoryStats({
    required this.category,
    required this.totalQuestions,
    this.learnedQuestions = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.recentResults = const [],
  });

  // ==========================================================================
  // Hilfsgetter
  // ==========================================================================

  /// Anzahl der beantworteten Fragen (richtig + falsch).
  int get totalAsked => totalCorrect + totalWrong;

  /// Unbeantwortete Fragen in dieser Kategorie.
  int get unansweredQuestions => totalQuestions - totalAsked;

  /// Der Lernfortschritt als Prozentwert (0-100).
  ///
  /// Berechnet aus gelernten Fragen vs. Gesamtfragen.
  double get progressPercent {
    if (totalQuestions == 0) return 0.0;
    return (learnedQuestions / totalQuestions) * 100;
  }

  /// Die Erfolgsrate für diese Kategorie (0-100).
  ///
  /// Berechnet aus richtigen vs. beantworteten Fragen.
  double get successRate {
    final answered = totalCorrect + totalWrong;
    if (answered == 0) return 0.0;
    return (totalCorrect / answered) * 100;
  }

  /// Erfolgsrate als Dezimalwert (0.0 - 1.0).
  double get successRateDecimal =>
      totalAsked > 0 ? totalCorrect / totalAsked : 0.0;

  /// Gibt an, ob alle Fragen in dieser Kategorie gelernt wurden.
  bool get isComplete =>
      totalQuestions > 0 && learnedQuestions >= totalQuestions;

  /// Die Kategorie gilt als Schwäche wenn die Erfolgsrate unter 60% liegt
  /// UND mindestens 5 Fragen beantwortet wurden.
  bool get isWeakness => successRate < 60.0 && totalAsked >= 5;

  /// Die Kategorie gilt als Stärke wenn die Erfolgsrate über 80% liegt
  /// UND mindestens 5 Fragen beantwortet wurden.
  bool get isStrength => successRate >= 80.0 && totalAsked >= 5;

  // ==========================================================================
  // Trend-Analyse
  // ==========================================================================

  /// Trend der letzten Ergebnisse.
  ///
  /// Positiv = verbessernd, Negativ = verschlechternd, Null = stabil.
  /// Vergleicht die erste Hälfte mit der zweiten Hälfte der letzten Ergebnisse.
  double get trend {
    if (recentResults.length < 3) return 0.0;

    final half = recentResults.length ~/ 2;
    final firstHalf = recentResults.sublist(0, half);
    final secondHalf = recentResults.sublist(half);

    final firstRate =
        firstHalf.where((r) => r).length / math.max(firstHalf.length, 1);
    final secondRate =
        secondHalf.where((r) => r).length / math.max(secondHalf.length, 1);

    return secondRate - firstRate; // Positiv = verbessernd
  }

  /// Gibt an ob der Trend positiv ist (Verbesserung).
  bool get isImproving => trend > 0.1;

  /// Gibt an ob der Trend negativ ist (Verschlechterung).
  bool get isDeclining => trend < -0.1;

  // ==========================================================================
  // Factory-Methoden
  // ==========================================================================

  /// Erstellt leere Stats für eine Kategorie.
  factory CategoryStats.empty(String category) {
    return CategoryStats(
      category: category,
      totalQuestions: 0,
      learnedQuestions: 0,
      totalCorrect: 0,
      totalWrong: 0,
      recentResults: const [],
    );
  }

  // ==========================================================================
  // Mutation (immutable)
  // ==========================================================================

  /// Kopiert mit hinzugefügtem Ergebnis (true = richtig, false = falsch).
  ///
  /// Aktualisiert [totalCorrect] oder [totalWrong] und fügt das Ergebnis
  /// zu [recentResults] hinzu (maximal 20 Einträge).
  CategoryStats addResult(bool correct) {
    final newResults = [...recentResults, correct];
    // Behalte maximal die letzten 20 Ergebnisse
    if (newResults.length > 20) {
      newResults.removeAt(0);
    }

    return CategoryStats(
      category: category,
      totalQuestions: totalQuestions,
      learnedQuestions: learnedQuestions,
      totalCorrect: correct ? totalCorrect + 1 : totalCorrect,
      totalWrong: correct ? totalWrong : totalWrong + 1,
      recentResults: List.unmodifiable(newResults),
    );
  }

  /// Zusammenführt zwei CategoryStats (z.B. aus verschiedenen Quellen).
  ///
  /// Wirft eine [ArgumentError] wenn die Kategorien nicht übereinstimmen.
  CategoryStats merge(CategoryStats other) {
    if (other.category != category) {
      throw ArgumentError(
        'Kategorien müssen übereinstimmen: "$category" vs "${other.category}"',
      );
    }

    return CategoryStats(
      category: category,
      totalQuestions: math.max(totalQuestions, other.totalQuestions),
      learnedQuestions: learnedQuestions + other.learnedQuestions,
      totalCorrect: totalCorrect + other.totalCorrect,
      totalWrong: totalWrong + other.totalWrong,
      recentResults: List.unmodifiable(
        [...recentResults, ...other.recentResults].sublist(
          0,
          math.min(
            recentResults.length + other.recentResults.length,
            20,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Copy-With
  // ==========================================================================

  /// Erzeugt eine Kopie mit aktualisierten Werten.
  CategoryStats copyWith({
    String? category,
    int? totalQuestions,
    int? learnedQuestions,
    int? totalCorrect,
    int? totalWrong,
    List<bool>? recentResults,
  }) {
    return CategoryStats(
      category: category ?? this.category,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      learnedQuestions: learnedQuestions ?? this.learnedQuestions,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalWrong: totalWrong ?? this.totalWrong,
      recentResults: recentResults ?? this.recentResults,
    );
  }

  // ==========================================================================
  // JSON-Serialisierung
  // ==========================================================================

  /// Konvertiert die Statistiken in ein JSON-Objekt.
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'totalQuestions': totalQuestions,
      'learnedQuestions': learnedQuestions,
      'correctAnswers': totalCorrect,
      'wrongAnswers': totalWrong,
      'recentResults': recentResults,
    };
  }

  /// Erstellt [CategoryStats] aus einem JSON-Objekt.
  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      category: json['category'] as String,
      totalQuestions: json['totalQuestions'] as int,
      learnedQuestions: json['learnedQuestions'] as int? ?? 0,
      totalCorrect: json['correctAnswers'] as int? ?? json['totalCorrect'] as int? ?? 0,
      totalWrong: json['wrongAnswers'] as int? ?? json['totalWrong'] as int? ?? 0,
      recentResults: (json['recentResults'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'CategoryStats($category: $learnedQuestions/$totalQuestions gelernt, '
        '${successRate.toStringAsFixed(1)}% Erfolgsrate, '
        '${isWeakness ? "SCHWÄCHE" : isStrength ? "STÄRKE" : "neutral"})';
  }
}
