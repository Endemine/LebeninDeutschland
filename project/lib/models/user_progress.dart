import 'category_stats.dart';
import 'question.dart';
import 'quiz_result.dart';

/// Repräsentiert den Lernfortschritt des Benutzers über alle Sitzungen.
///
/// Speichert:
/// - Welche Fragen bereits gelernt wurden
/// - Lesezeichen für wichtige Fragen
/// - Statistiken pro Kategorie
/// - Historie aller abgeschlossenen Quizze
/// - Das ausgewählte Bundesland
///
/// Wird mit [StorageService] persistiert und bei App-Start geladen.
class UserProgress {
  /// IDs der Fragen, die der Benutzer mindestens einmal richtig beantwortet hat.
  final Set<int> learnedQuestionIds;

  /// IDs der Fragen, die der Benutzer als Lesezeichen markiert hat.
  final Set<int> bookmarkedQuestionIds;

  /// Statistiken für jede Kategorie.
  /// Schlüssel: Kategoriename (z.B. "Allgemein")
  /// Wert: [CategoryStats] mit Lernstatistiken
  final Map<String, CategoryStats> categoryStats;

  /// Chronologische Liste aller abgeschlossenen Quiz-Ergebnisse.
  /// Das neueste Ergebnis steht am Ende der Liste.
  final List<QuizResult> quizHistory;

  /// Das vom Benutzer ausgewählte Bundesland.
  /// `null` wenn noch kein Bundesland ausgewählt wurde.
  final String? selectedState;

  /// Erstellt den Benutzerfortschritt.
  ///
  /// Alle Sammlungen werden als unveränderbare Kopien gespeichert.
  UserProgress({
    Set<int>? learnedQuestionIds,
    Set<int>? bookmarkedQuestionIds,
    Map<String, CategoryStats>? categoryStats,
    List<QuizResult>? quizHistory,
    this.selectedState,
  })  : learnedQuestionIds = Set.unmodifiable(learnedQuestionIds ?? {}),
        bookmarkedQuestionIds =
            Set.unmodifiable(bookmarkedQuestionIds ?? {}),
        categoryStats = Map.unmodifiable(
          categoryStats ?? {},
        ),
        quizHistory = List.unmodifiable(quizHistory ?? []);

  /// Erstellt einen leeren Fortschritt für einen neuen Benutzer.
  factory UserProgress.empty() => UserProgress();

  // ==========================================================================
  // Hilfsgetter
  // ==========================================================================

  /// Gibt die Gesamtzahl der gelernten Fragen zurück.
  int get learnedCount => learnedQuestionIds.length;

  /// Gibt die Anzahl der markierten Fragen zurück.
  int get bookmarkedCount => bookmarkedQuestionIds.length;

  /// Gibt die Anzahl der abgeschlossenen Quizze zurück.
  int get quizCount => quizHistory.length;

  /// Gibt an, ob ein Bundesland ausgewählt wurde.
  bool get hasSelectedState => selectedState != null;

  /// Gibt die besten 3 Quiz-Ergebnisse zurück (nach Anzahl richtiger Antworten).
  List<QuizResult> get bestResults {
    final sorted = List<QuizResult>.from(quizHistory)
      ..sort((a, b) => b.correctAnswers.compareTo(a.correctAnswers));
    return sorted.take(3).toList();
  }

  /// Gibt das beste Quiz-Ergebnis zurück oder null wenn noch keins existiert.
  QuizResult? get bestResult {
    if (quizHistory.isEmpty) return null;
    return quizHistory.reduce(
      (best, current) =>
          current.correctAnswers > best.correctAnswers ? current : best,
    );
  }

  /// Gibt die durchschnittliche Anzahl richtiger Antworten über alle Quizze zurück.
  double get averageCorrect {
    if (quizHistory.isEmpty) return 0.0;
    final total = quizHistory.fold<int>(
      0,
      (sum, result) => sum + result.correctAnswers,
    );
    return total / quizHistory.length;
  }

  /// Gibt die Anzahl der bestandenen Tests zurück.
  int get passedCount =>
      quizHistory.where((result) => result.passed).length;

  /// Gibt die Anzahl der nicht bestandenen Tests zurück.
  int get failedCount =>
      quizHistory.where((result) => !result.passed).length;

  /// Gibt die Bestehensquote als Prozentwert zurück (0-100).
  double get passRate {
    if (quizHistory.isEmpty) return 0.0;
    return (passedCount / quizHistory.length) * 100;
  }

  // ==========================================================================
  // Prüfmethoden
  // ==========================================================================

  /// Prüft ob eine Frage als gelernt markiert ist.
  bool isLearned(int questionId) => learnedQuestionIds.contains(questionId);

  /// Prüft ob eine Frage als Lesezeichen markiert ist.
  bool isBookmarked(int questionId) =>
      bookmarkedQuestionIds.contains(questionId);

  /// Gibt die Statistik für eine Kategorie zurück.
  ///
  /// Gibt eine leere [CategoryStats] zurück wenn die Kategorie noch nicht existiert.
  CategoryStats getCategoryStats(String category) {
    return categoryStats[category] ??
        CategoryStats.empty(category);
  }

  // ==========================================================================
  // Copy-With Methoden
  // ==========================================================================

  /// Erzeugt eine Kopie mit aktualisierten Werten.
  UserProgress copyWith({
    Set<int>? learnedQuestionIds,
    Set<int>? bookmarkedQuestionIds,
    Map<String, CategoryStats>? categoryStats,
    List<QuizResult>? quizHistory,
    String? selectedState,
  }) {
    return UserProgress(
      learnedQuestionIds: learnedQuestionIds ?? this.learnedQuestionIds,
      bookmarkedQuestionIds:
          bookmarkedQuestionIds ?? this.bookmarkedQuestionIds,
      categoryStats: categoryStats ?? this.categoryStats,
      quizHistory: quizHistory ?? this.quizHistory,
      selectedState: selectedState ?? this.selectedState,
    );
  }

  /// Fügt eine gelernte Frage hinzu und gibt den aktualisierten Fortschritt zurück.
  UserProgress markAsLearned(int questionId) {
    final newLearned = Set<int>.from(learnedQuestionIds)..add(questionId);
    return copyWith(learnedQuestionIds: newLearned);
  }

  /// Fügt ein Lesezeichen hinzu und gibt den aktualisierten Fortschritt zurück.
  UserProgress addBookmark(int questionId) {
    final newBookmarks = Set<int>.from(bookmarkedQuestionIds)..add(questionId);
    return copyWith(bookmarkedQuestionIds: newBookmarks);
  }

  /// Entfernt ein Lesezeichen und gibt den aktualisierten Fortschritt zurück.
  UserProgress removeBookmark(int questionId) {
    final newBookmarks = Set<int>.from(bookmarkedQuestionIds)
      ..remove(questionId);
    return copyWith(bookmarkedQuestionIds: newBookmarks);
  }

  /// Fügt ein Quiz-Ergebnis zur Historie hinzu.
  UserProgress addQuizResult(QuizResult result) {
    final newHistory = List<QuizResult>.from(quizHistory)..add(result);
    return copyWith(quizHistory: newHistory);
  }

  /// Aktualisiert die Statistik für eine Kategorie.
  UserProgress updateCategoryStats(CategoryStats stats) {
    final newStats = Map<String, CategoryStats>.from(categoryStats)
      ..[stats.category] = stats;
    return copyWith(categoryStats: newStats);
  }

  // ==========================================================================
  // JSON-Serialisierung
  // ==========================================================================

  /// Konvertiert den Fortschritt in ein JSON-Objekt.
  Map<String, dynamic> toJson() {
    return {
      'learnedQuestionIds': learnedQuestionIds.toList(),
      'bookmarkedQuestionIds': bookmarkedQuestionIds.toList(),
      'categoryStats': categoryStats.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'quizHistory': quizHistory.map((r) => r.toJson()).toList(),
      'selectedState': selectedState,
    };
  }

  /// Erstellt einen [UserProgress] aus einem JSON-Objekt.
  ///
  /// [allQuestionsMap] wird benötigt um Fragen in QuizResult nachzuschlagen.
  factory UserProgress.fromJson(
    Map<String, dynamic> json,
    Map<int, Question> allQuestionsMap,
  ) {
    final learnedIds = (json['learnedQuestionIds'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toSet() ??
        {};

    final bookmarkedIds = (json['bookmarkedQuestionIds'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toSet() ??
        {};

    final statsJson =
        (json['categoryStats'] as Map<String, dynamic>?) ?? {};
    final stats = statsJson.map(
      (key, value) => MapEntry(
        key,
        CategoryStats.fromJson(value as Map<String, dynamic>),
      ),
    );

    final historyJson = (json['quizHistory'] as List<dynamic>?) ?? [];
    final history = historyJson
        .map((e) => QuizResult.fromJson(
              e as Map<String, dynamic>,
              allQuestionsMap,
            ))
        .toList();

    return UserProgress(
      learnedQuestionIds: learnedIds,
      bookmarkedQuestionIds: bookmarkedIds,
      categoryStats: stats,
      quizHistory: history,
      selectedState: json['selectedState'] as String?,
    );
  }

  @override
  String toString() {
    return 'UserProgress(gelernt: $learnedCount, Lesezeichen: $bookmarkedCount, '
        'Quizze: $quizCount, Bundesland: $selectedState)';
  }
}
