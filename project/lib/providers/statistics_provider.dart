// =============================================================================
// STATISTICS PROVIDER
// =============================================================================
// Verwaltet alle Quiz-Statistiken: Verlauf, Erfolgsraten, Kategorie-Analyse,
// Trend-Daten für Charts und Schwächen-Identifikation.
// =============================================================================

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/category_stats.dart';

/// Ein Datenpunkt für Trend-Charts (Punkt in einem Liniendiagramm).
///
/// [x] ist typischerweise der Quiz-Index (0, 1, 2, ...)
/// [y] ist der Wert (z.B. Punktzahl in Prozent)
class FlSpot {
  final double x;
  final double y;

  const FlSpot(this.x, this.y);

  @override
  String toString() => 'FlSpot($x, $y)';
}

/// Der StatisticsProvider verwaltet alle Statistiken der App.
///
/// Funktionsumfang:
/// - Persistente Speicherung aller Quiz-Ergebnisse
/// - Aggregierte Statistiken (Gesamt, Bestanden, Durchschnitt)
/// - Kategorie-basierte Analyse (Stärken/Schwächen)
/// - Trend-Daten für Charts (Punktzahl über Zeit)
/// - Schwächste Kategorien für gezieltes Lernen
///
/// Usage:
/// ```dart
/// final statsProvider = context.read<StatisticsProvider>();
/// await statsProvider.loadStatistics();
/// statsProvider.addQuizResult(result);
/// ```
class StatisticsProvider extends ChangeNotifier {
  // ===========================================================================
  // PERSISTENZ-SCHLÜSSEL
  // ===========================================================================

  static const String _kQuizHistoryKey = 'quiz_history';

  // ===========================================================================
  // INTERNER ZUSTAND
  // ===========================================================================

  /// Liste aller abgeschlossenen Quiz-Ergebnisse (chronologisch)
  List<QuizResult> _quizHistory = [];

  /// Lade-Status
  bool _isLoading = false;

  /// Fehlermeldung
  String? _error;

  // ===========================================================================
  // GETTER
  // ===========================================================================

  /// Alle gespeicherten Quiz-Ergebnisse (chronologisch sortiert)
  List<QuizResult> get quizHistory => List.unmodifiable(_quizHistory);

  /// Gesamtanzahl der abgeschlossenen Quizze
  int get totalQuizzes => _quizHistory.length;

  /// Anzahl der bestandenen Quizze (mindestens 17/33 richtig)
  int get passedQuizzes => _quizHistory.where((r) => r.isPassed).length;

  /// Anzahl der nicht bestandenen Quizze
  int get failedQuizzes => _quizHistory.where((r) => !r.isPassed).length;

  /// Durchschnittliche Punktzahl über alle Quizze (0.0 - 100.0)
  double get averageScore {
    if (_quizHistory.isEmpty) return 0.0;
    final total = _quizHistory.fold<double>(
      0.0,
      (sum, r) => sum + r.scorePercent,
    );
    return total / _quizHistory.length;
  }

  /// Bestehensrate als Prozentsatz (0.0 - 100.0)
  double get passRate {
    if (_quizHistory.isEmpty) return 0.0;
    return (passedQuizzes / _quizHistory.length) * 100;
  }

  /// Die letzten 10 Quiz-Ergebnisse (für die Startseite)
  List<QuizResult> get recentResults {
    final sorted = List<QuizResult>.from(_quizHistory)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sorted.take(10).toList();
  }

  /// Gibt an ob Statistiken vorhanden sind
  bool get hasStatistics => _quizHistory.isNotEmpty;

  /// Lade-Status
  bool get isLoading => _isLoading;

  /// Fehlermeldung
  String? get error => _error;

  // ===========================================================================
  // LADEN & SPEICHERN
  // ===========================================================================

  /// Lädt die gespeicherten Statistiken aus SharedPreferences.
  ///
  /// Sollte beim App-Start aufgerufen werden.
  Future<void> loadStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kQuizHistoryKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        _quizHistory = jsonList
            .map((json) => QuizResult.fromJsonSimple(json as Map<String, dynamic>))
            .toList();

        // Nach Abschlussdatum sortieren (neueste zuerst)
        _quizHistory.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      } else {
        _quizHistory = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Fehler beim Laden der Statistiken: $e';
      _quizHistory = [];
      notifyListeners();
    }
  }

  /// Fügt ein neues Quiz-Ergebnis hinzu und speichert es persistent.
  ///
  /// [result] Das abgeschlossene Quiz-Ergebnis
  Future<void> addQuizResult(QuizResult result) async {
    // Ergebnis zur Historie hinzufügen (am Anfang, da neueste zuerst)
    _quizHistory = [result, ..._quizHistory];

    // Persistieren
    await _persistHistory();

    notifyListeners();
  }

  // ===========================================================================
  // KATEGORIE-STATISTIKEN
  // ===========================================================================

  /// Statistiken pro Kategorie über alle Quiz-Durchläufe.
  ///
  /// Aggregiert die Ergebnisse aller Quizze nach Kategorie und berechnet
  /// Erfolgsraten, Trend und Schwächen-Analyse.
  Map<QuestionCategory, CategoryStats> get categoryStats {
    final statsMap = <QuestionCategory, CategoryStats>{};

    // Initialisiere alle Kategorien mit leeren Stats
    for (final category in QuestionCategory.values) {
      statsMap[category] = CategoryStats.empty(category.name);
    }

    // Aggregiere Daten aus allen Quiz-Ergebnissen
    for (final result in _quizHistory) {
      for (int i = 0; i < result.questions.length; i++) {
        final question = result.questions[i];
        final wasCorrect = result.questionCorrect(i);

        final currentStats = statsMap[question.category]!;
        statsMap[question.category] = currentStats.addResult(wasCorrect);
      }
    }

    return statsMap;
  }

  /// Liste der schwächsten Kategorien (unter 60% Erfolgsrate).
  ///
  /// Sortiert nach Erfolgsrate aufsteigend (schwächste zuerst).
  /// Enthält nur Kategorien mit mindestens 5 beantworteten Fragen.
  List<String> get weakestCategories {
    final stats = categoryStats;

    final weakCategories = stats.entries
        .where((entry) => entry.value.isWeakness)
        .toList()
      ..sort((a, b) => a.value.successRate.compareTo(b.value.successRate));

    return weakCategories.map((e) => e.value.category).toList();
  }

  /// Liste der stärksten Kategorien (über 80% Erfolgsrate).
  ///
  /// Sortiert nach Erfolgsrate absteigend (stärkste zuerst).
  List<String> get strongestCategories {
    final stats = categoryStats;

    final strongCategories = stats.entries
        .where((entry) => entry.value.isStrength)
        .toList()
      ..sort((a, b) => b.value.successRate.compareTo(a.value.successRate));

    return strongCategories.map((e) => e.value.category).toList();
  }

  /// Gibt die Erfolgsrate für eine bestimmte Kategorie zurück.
  ///
  /// [category] Die zu analysierende Kategorie
  /// Returns: Erfolgsrate in Prozent (0.0 - 100.0)
  double getCategorySuccessRate(QuestionCategory category) {
    return categoryStats[category]?.successRate ?? 0.0;
  }

  // ===========================================================================
  // TREND-DATEN FÜR CHARTS
  // ===========================================================================

  /// Trend-Daten für die Punktzahl-Übersicht.
  ///
  /// Returns: Liste von FlSpot-Datenpunkten für ein Liniendiagramm.
  /// Der x-Wert ist der Quiz-Index, der y-Wert ist die Punktzahl (0-100).
  List<FlSpot> get scoreTrend {
    if (_quizHistory.isEmpty) return [];

    // Chronologisch sortieren (älteste zuerst für den Chart)
    final chronological = List<QuizResult>.from(_quizHistory)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    return chronological.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final result = entry.value;
      return FlSpot(index, result.scorePercent);
    }).toList();
  }

  /// Trend-Daten für die Bestehensrate über Zeit.
  ///
  /// Berechnet einen gleitenden Durchschnitt der letzten 5 Quizze.
  /// Returns: Liste von FlSpot-Datenpunkten.
  List<FlSpot> get passRateTrend {
    if (_quizHistory.length < 2) return [];

    // Chronologisch sortieren
    final chronological = List<QuizResult>.from(_quizHistory)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final spots = <FlSpot>[];
    final windowSize = math.min(5, chronological.length);

    for (int i = windowSize - 1; i < chronological.length; i++) {
      // Gleitender Durchschnitt der letzten [windowSize] Ergebnisse
      final window = chronological.sublist(
        math.max(0, i - windowSize + 1),
        i + 1,
      );

      final passedCount = window.where((r) => r.isPassed).length;
      final rate = (passedCount / window.length) * 100;

      spots.add(FlSpot(i.toDouble(), rate));
    }

    return spots;
  }

  /// Trend-Daten für die durchschnittliche Bearbeitungszeit.
  ///
  /// Returns: Liste von FlSpot-Datenpunkten (Zeit in Minuten).
  List<FlSpot> get timeTrend {
    if (_quizHistory.isEmpty) return [];

    final chronological = List<QuizResult>.from(_quizHistory)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    return chronological.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final timeInMinutes = entry.value.timeTakenSeconds / 60.0;
      return FlSpot(index, timeInMinutes);
    }).toList();
  }

  // ===========================================================================
  // ZEIT-STATISTIKEN
  // ===========================================================================

  /// Durchschnittliche Bearbeitungszeit in Sekunden.
  double get averageTimeSeconds {
    if (_quizHistory.isEmpty) return 0.0;
    final total = _quizHistory.fold<int>(
      0,
      (sum, r) => sum + r.timeTakenSeconds,
    );
    return total / _quizHistory.length;
  }

  /// Kürzeste Bearbeitungszeit in Sekunden.
  int get fastestTimeSeconds {
    if (_quizHistory.isEmpty) return 0;
    return _quizHistory
        .map((r) => r.timeTakenSeconds)
        .reduce(math.min);
  }

  /// Längste Bearbeitungszeit in Sekunden.
  int get slowestTimeSeconds {
    if (_quizHistory.isEmpty) return 0;
    return _quizHistory
        .map((r) => r.timeTakenSeconds)
        .reduce(math.max);
  }

  // ===========================================================================
  // HIGHSCORE & MEILENSTEINE
  // ===========================================================================

  /// Höchste jemals erreichte Punktzahl.
  double get bestScore {
    if (_quizHistory.isEmpty) return 0.0;
    return _quizHistory
        .map((r) => r.scorePercent)
        .reduce(math.max);
  }

  /// Niedrigste Punktzahl.
  double get worstScore {
    if (_quizHistory.isEmpty) return 0.0;
    return _quizHistory
        .map((r) => r.scorePercent)
        .reduce(math.min);
  }

  /// Anzahl aufeinanderfolgender bestandener Quizze (aktuelle Serie).
  int get currentStreak {
    int streak = 0;
    // Neueste zuerst
    final sorted = List<QuizResult>.from(_quizHistory)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    for (final result in sorted) {
      if (result.isPassed) {
        streak++;
      } else {
        break; // Serie unterbrochen
      }
    }
    return streak;
  }

  /// Beste jemals erreichte Serie.
  int get bestStreak {
    if (_quizHistory.isEmpty) return 0;

    int bestStreak = 0;
    int currentStreak = 0;

    // Chronologisch sortieren
    final sorted = List<QuizResult>.from(_quizHistory)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    for (final result in sorted) {
      if (result.isPassed) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return bestStreak;
  }

  // ===========================================================================
  // RESET
  // ===========================================================================

  /// Löscht alle gespeicherten Statistiken (Quiz-Verlauf).
  ///
  /// Achtung: Diese Aktion kann nicht rückgängig gemacht werden!
  Future<void> clearAll() async {
    _quizHistory = [];
    await _persistHistory();
    notifyListeners();
  }

  // ===========================================================================
  // PERSISTENZ-HILFSMETHODEN
  // ===========================================================================

  /// Speichert den Quiz-Verlauf in SharedPreferences.
  Future<void> _persistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Maximal die letzten 100 Ergebnisse speichern (Speicherplatz)
      final resultsToSave = _quizHistory.length > 100
          ? _quizHistory.sublist(0, 100)
          : _quizHistory;

      final jsonList = resultsToSave.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_kQuizHistoryKey, jsonString);
    } catch (e) {
      debugPrint('Fehler beim Speichern der Statistiken: $e');
    }
  }

  @override
  String toString() {
    return 'StatisticsProvider(total: $totalQuizzes, passed: $passedQuizzes, '
        'avg: ${averageScore.toStringAsFixed(1)}%)';
  }
}
