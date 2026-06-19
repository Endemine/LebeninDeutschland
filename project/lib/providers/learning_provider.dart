// =============================================================================
// LEARNING PROVIDER
// =============================================================================
// Verwaltet den Lernmodus: Fragen laden, Filtern, Bookmarking und Fortschritt.
// Der LearningProvider ist das Herzstück des Lernmodus der App.
// =============================================================================

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';

/// Der LearningProvider verwaltet den Lernmodus der Einbürgerungstest-App.
///
/// Funktionsumfang:
/// - Laden aller Fragen (aus Assets oder lokal)
/// - Filtern nach Kategorie, Bundesland und Suchbegriff
/// - Bookmarking von Fragen
/// - Markieren von Fragen als "gelernt"
/// - Navigation durch die gefilterte Fragenliste
/// - Fortschritts-Statistiken pro Kategorie
///
/// Usage:
/// ```dart
/// final learningProvider = context.read<LearningProvider>();
/// await learningProvider.loadQuestions();
/// learningProvider.setCategoryFilter(QuestionCategory.history);
/// ```
class LearningProvider extends ChangeNotifier {
  // ===========================================================================
  // PERSISTENZ-SCHLÜSSEL
  // ===========================================================================

  static const String _kLearnedKey = 'learned_question_ids';
  static const String _kBookmarkedKey = 'bookmarked_question_ids';

  // ===========================================================================
  // INTERNER ZUSTAND
  // ===========================================================================

  /// Alle verfügbaren Fragen (un gefiltert)
  List<Question> _allQuestions = [];

  /// IDs der als "gelernt" markierten Fragen
  Set<int> _learnedIds = {};

  /// IDs der gebookmarkten Fragen
  Set<int> _bookmarkedIds = {};

  /// Aktueller Kategorie-Filter
  QuestionCategory? _filterCategory;

  /// Aktueller Bundesland-Filter
  String? _filterState;

  /// Aktueller Suchbegriff
  String _searchQuery = '';

  /// Aktueller Index in der gefilterten Fragenliste
  int _currentQuestionIndex = 0;

  /// Lade-Status
  bool _isLoading = false;

  /// Anzeige-Sprache für Fragen ('de', 'en', 'ar')
  String _viewLanguage = 'de';

  static const String _kViewLanguageKey = 'view_language';

  /// Fehlermeldung (falls vorhanden)
  String? _error;

  /// Zufallsgenerator für "Zufällige Frage"-Feature
  final Random _random = Random();

  // ===========================================================================
  // GETTER
  // ===========================================================================

  /// Alle ungefilterten Fragen
  List<Question> get allQuestions => List.unmodifiable(_allQuestions);

  /// Die gefilterte Fragenliste (nach Kategorie, Bundesland und Suche)
  List<Question> get filteredQuestions {
    return _allQuestions.where((question) {
      // === Kategorie-Filter ===
      if (_filterCategory != null && question.category != _filterCategory) {
        return false;
      }

      // === Bundesland-Filter ===
      if (_filterState != null && question.state != _filterState) {
        return false;
      }

      // === Such-Filter ===
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final textMatch = question.text.toLowerCase().contains(query);
        final answerMatch = question.answers
            .any((a) => a.toLowerCase().contains(query));
        final categoryMatch = question.category.displayName
            .toLowerCase()
            .contains(query);

        if (!textMatch && !answerMatch && !categoryMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Die aktuell angezeigte Frage (aus der gefilterten Liste)
  Question get currentQuestion {
    final filtered = filteredQuestions;
    if (filtered.isEmpty) {
      // Fallback: Leere Platzhalter-Frage wenn keine Fragen verfügbar
      return _placeholderQuestion();
    }
    // Sicherstellen dass der Index im gültigen Bereich liegt
    final safeIndex = _currentQuestionIndex.clamp(0, filtered.length - 1);
    return filtered[safeIndex];
  }

  /// Gibt an ob eine Frage als gelernt markiert ist
  bool isLearned(int questionId) => _learnedIds.contains(questionId);

  /// Gibt an ob eine Frage gebookmarkt ist
  bool isBookmarked(int questionId) => _bookmarkedIds.contains(questionId);

  /// Liste aller gebookmarkten Fragen
  List<Question> get bookmarkedQuestions {
    return _allQuestions
        .where((q) => _bookmarkedIds.contains(q.id))
        .toList();
  }

  /// Liste aller gelernten Fragen
  List<Question> get learnedQuestions {
    return _allQuestions
        .where((q) => _learnedIds.contains(q.id))
        .toList();
  }

  /// Aktueller Index in der gefilterten Liste
  int get currentIndex => _currentQuestionIndex;

  /// Anzahl der gefilterten Fragen
  int get filteredCount => filteredQuestions.length;

  /// Gibt an ob Daten geladen werden
  bool get isLoading => _isLoading;

  /// Fehlermeldung (null wenn kein Fehler)
  String? get error => _error;

  // ===========================================================================
  // FRAGEN LADEN
  // ===========================================================================

  /// Lädt alle Fragen aus den App-Assets und die gelernten/bookmarkten IDs
  /// aus SharedPreferences.
  ///
  /// Diese Methode sollte beim App-Start aufgerufen werden.
  Future<void> loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // === Fragen aus JSON-Asset laden ===
      _allQuestions = await _loadQuestionsFromAsset();

      // === Übersetzungen laden und an Fragen anhängen ===
      await _loadTranslations();

      // === Persistierte Lernfortschritte laden ===
      await _loadLearnedIds();

      // === Persistierte Bookmarks laden ===
      await _loadBookmarkedIds();

      // === Gespeicherte Anzeige-Sprache laden ===
      await _loadViewLanguage();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Fehler beim Laden der Fragen: $e';
      notifyListeners();
    }
  }

  /// Lädt die Übersetzungen (EN/AR) und hängt sie an die geladenen Fragen.
  Future<void> _loadTranslations() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/translations.json');
      final Map<String, dynamic> map =
          jsonDecode(jsonString) as Map<String, dynamic>;

      _allQuestions = _allQuestions.map((q) {
        final t = map['${q.id}'];
        if (t == null) return q;
        final tr = t as Map<String, dynamic>;
        return q.withTranslations(
          questionEn: tr['question_en'] as String?,
          questionAr: tr['question_ar'] as String?,
          answersEn: tr['answers_en'] != null
              ? List<String>.from(tr['answers_en'] as List)
              : null,
          answersAr: tr['answers_ar'] != null
              ? List<String>.from(tr['answers_ar'] as List)
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Fehler beim Laden der Übersetzungen: $e');
    }
  }

  /// Aktuelle Anzeige-Sprache ('de', 'en', 'ar')
  String get viewLanguage => _viewLanguage;

  /// Setzt die Anzeige-Sprache und persistiert sie.
  void setViewLanguage(String lang) {
    if (_viewLanguage == lang) return;
    _viewLanguage = lang;
    _persistViewLanguage();
    notifyListeners();
  }

  /// Lädt die gespeicherte Anzeige-Sprache.
  Future<void> _loadViewLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _viewLanguage = prefs.getString(_kViewLanguageKey) ?? 'de';
    } catch (e) {
      _viewLanguage = 'de';
    }
  }

  /// Speichert die Anzeige-Sprache.
  Future<void> _persistViewLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kViewLanguageKey, _viewLanguage);
    } catch (e) {
      debugPrint('Fehler beim Speichern der Sprache: $e');
    }
  }

  /// Lädt Fragen aus der lokalen JSON-Datei.
  ///
  /// Im Produktiv-Einsatz würde diese Methode die Fragen aus dem
  /// Asset-Bundle laden. Für Tests können Fragen auch direkt übergeben werden.
  Future<List<Question>> _loadQuestionsFromAsset() async {
    try {
      final jsonString = await rootBundle.loadString('assets/questions.json');
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((j) => Question.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Fehler beim Laden der Fragen-Assets: $e');
      return [];
    }
  }

  /// Setzt die Fragenliste direkt (für Tests oder externe Datenquellen).
  void setQuestions(List<Question> questions) {
    _allQuestions = List.unmodifiable(questions);
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  // ===========================================================================
  // FILTER-METHODEN
  // ===========================================================================

  /// Setzt den Kategorie-Filter und setzt den Index zurück.
  ///
  /// [category] Die zu filternde Kategorie, oder null um den Filter zu entfernen
  void setCategoryFilter(QuestionCategory? category) {
    _filterCategory = category;
    _currentQuestionIndex = 0; // Index zurücksetzen
    notifyListeners();
  }

  /// Setzt den Bundesland-Filter und setzt den Index zurück.
  ///
  /// [state] Das zu filternde Bundesland, oder null um den Filter zu entfernen
  void setStateFilter(String? state) {
    _filterState = state;
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  /// Setzt den Suchbegriff für die Volltextsuche.
  ///
  /// [query] Der Suchbegriff (leer = keine Suche)
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  /// Entfernt alle Filter und setzt die Suche zurück.
  void clearAllFilters() {
    _filterCategory = null;
    _filterState = null;
    _searchQuery = '';
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  /// Aktueller Kategorie-Filter
  QuestionCategory? get filterCategory => _filterCategory;

  /// Aktueller Bundesland-Filter
  String? get filterState => _filterState;

  /// Aktueller Suchbegriff
  String get searchQuery => _searchQuery;

  /// Gibt an ob aktive Filter gesetzt sind
  bool get hasActiveFilters =>
      _filterCategory != null || _filterState != null || _searchQuery.isNotEmpty;

  // ===========================================================================
  // LERNFORTSCHRITT
  // ===========================================================================

  /// Markiert eine Frage als "gelernt".
  ///
  /// [questionId] Die ID der Frage
  void markAsLearned(int questionId) {
    if (_learnedIds.add(questionId)) {
      _persistLearnedIds();
      notifyListeners();
    }
  }

  /// Entfernt die "gelernt"-Markierung von einer Frage.
  ///
  /// [questionId] Die ID der Frage
  void markAsUnlearned(int questionId) {
    if (_learnedIds.remove(questionId)) {
      _persistLearnedIds();
      notifyListeners();
    }
  }

  /// Toggelt den "gelernt"-Status einer Frage.
  ///
  /// [questionId] Die ID der Frage
  void toggleLearned(int questionId) {
    if (_learnedIds.contains(questionId)) {
      markAsUnlearned(questionId);
    } else {
      markAsLearned(questionId);
    }
  }

  // ===========================================================================
  // BOOKMARKS
  // ===========================================================================

  /// Toggelt den Bookmark-Status einer Frage.
  ///
  /// [questionId] Die ID der Frage
  void toggleBookmark(int questionId) {
    if (_bookmarkedIds.contains(questionId)) {
      _bookmarkedIds.remove(questionId);
    } else {
      _bookmarkedIds.add(questionId);
    }
    _persistBookmarkedIds();
    notifyListeners();
  }

  /// Anzahl der gebookmarkten Fragen
  int get bookmarkCount => _bookmarkedIds.length;

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  /// Springt zur nächsten Frage in der gefilterten Liste.
  void nextQuestion() {
    final filtered = filteredQuestions;
    if (filtered.isEmpty) return;

    if (_currentQuestionIndex < filtered.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Springt zur vorherigen Frage in der gefilterten Liste.
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Springt zu einer bestimmten Frage in der gefilterten Liste.
  ///
  /// [index] Der Ziel-Index (0-basiert)
  void goToQuestion(int index) {
    final filtered = filteredQuestions;
    if (index >= 0 && index < filtered.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  /// Springt zu einer zufälligen Frage.
  void goToRandomQuestion() {
    final filtered = filteredQuestions;
    if (filtered.length <= 1) return;

    int newIndex;
    do {
      newIndex = _random.nextInt(filtered.length);
    } while (newIndex == _currentQuestionIndex && filtered.length > 1);

    _currentQuestionIndex = newIndex;
    notifyListeners();
  }

  // ===========================================================================
  // FORTSCHRITTS-STATISTIKEN
  // ===========================================================================

  /// Gesamtfortschritt als Prozentsatz (0.0 - 1.0).
  ///
  /// Berechnet: Anzahl gelernte Fragen / Gesamtanzahl Fragen
  double get overallProgress {
    if (_allQuestions.isEmpty) return 0.0;
    return _learnedIds.length / _allQuestions.length;
  }

  /// Fortschritt pro Kategorie.
  ///
  /// Returns: Map von Kategorie → Anzahl gelernte Fragen
  Map<QuestionCategory, int> get categoryProgress {
    final result = <QuestionCategory, int>{};

    for (final category in QuestionCategory.values) {
      final categoryQuestions = _allQuestions
          .where((q) => q.category == category)
          .length;
      final learnedInCategory = _allQuestions
          .where((q) => q.category == category && _learnedIds.contains(q.id))
          .length;

      result[category] = learnedInCategory;
    }

    return result;
  }

  /// Fortschritt pro Kategorie als Prozentsatz.
  ///
  /// Returns: Map von Kategorie → Fortschritt (0.0 - 1.0)
  Map<QuestionCategory, double> get categoryProgressPercent {
    final result = <QuestionCategory, double>{};

    for (final category in QuestionCategory.values) {
      final totalInCategory = _allQuestions
          .where((q) => q.category == category)
          .length;
      final learnedInCategory = _allQuestions
          .where((q) => q.category == category && _learnedIds.contains(q.id))
          .length;

      result[category] = totalInCategory > 0
          ? learnedInCategory / totalInCategory
          : 0.0;
    }

    return result;
  }

  /// Anzahl der gelernten Fragen insgesamt
  int get learnedCount => _learnedIds.length;

  /// Anzahl der insgesamt verfügbaren Fragen
  int get totalQuestionCount => _allQuestions.length;

  // ===========================================================================
  // PERSISTENZ (SharedPreferences)
  // ===========================================================================

  /// Lädt die IDs gelernter Fragen aus SharedPreferences.
  Future<void> _loadLearnedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kLearnedKey);
      if (jsonString != null) {
        final list = jsonDecode(jsonString) as List<dynamic>;
        _learnedIds = list.cast<int>().toSet();
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der gelernten Fragen: $e');
      _learnedIds = {};
    }
  }

  /// Speichert die IDs gelernter Fragen in SharedPreferences.
  Future<void> _persistLearnedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_learnedIds.toList());
      await prefs.setString(_kLearnedKey, jsonString);
    } catch (e) {
      debugPrint('Fehler beim Speichern der gelernten Fragen: $e');
    }
  }

  /// Lädt die IDs gebookmarkter Fragen aus SharedPreferences.
  Future<void> _loadBookmarkedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kBookmarkedKey);
      if (jsonString != null) {
        final list = jsonDecode(jsonString) as List<dynamic>;
        _bookmarkedIds = list.cast<int>().toSet();
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Bookmarks: $e');
      _bookmarkedIds = {};
    }
  }

  /// Speichert die IDs gebookmarkter Fragen in SharedPreferences.
  Future<void> _persistBookmarkedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_bookmarkedIds.toList());
      await prefs.setString(_kBookmarkedKey, jsonString);
    } catch (e) {
      debugPrint('Fehler beim Speichern der Bookmarks: $e');
    }
  }

  // ===========================================================================
  // PROGRESS RESET
  // ===========================================================================

  /// Löscht alle Lernfortschritte ("gelernt"-Markierungen).
  Future<void> clearLearnedProgress() async {
    _learnedIds.clear();
    await _persistLearnedIds();
    notifyListeners();
  }

  /// Löscht alle Bookmarks.
  Future<void> clearBookmarks() async {
    _bookmarkedIds.clear();
    await _persistBookmarkedIds();
    notifyListeners();
  }

  // ===========================================================================
  // HILFSMETHODEN
  // ===========================================================================

  /// Erstellt eine Platzhalter-Frage für den Fall dass keine Fragen geladen sind.
  Question _placeholderQuestion() {
    return Question(
      id: -1,
      text: 'Keine Fragen verfügbar. Bitte laden Sie die Fragen-Daten.',
      answers: const ['A', 'B', 'C', 'D'],
      correctAnswerIndex: 0,
      category: QuestionCategory.allgemein,
    );
  }

  /// Gibt eine Frage anhand ihrer ID zurück.
  ///
  /// [id] Die ID der gesuchten Frage
  /// Returns: Die Frage oder null wenn nicht gefunden
  Question? getQuestionById(int id) {
    try {
      return _allQuestions.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gibt alle verfügbaren Kategorien zurück die Fragen enthalten.
  List<QuestionCategory> get availableCategories {
    return _allQuestions.map((q) => q.category).toSet().toList();
  }

  /// Gibt alle verfügbaren Bundesländer zurück die Fragen enthalten.
  List<String> get availableStates {
    return _allQuestions
        .where((q) => q.state != null)
        .map((q) => q.state!)
        .toSet()
        .toList();
  }

  @override
  String toString() {
    return 'LearningProvider(total: ${_allQuestions.length}, '
        'learned: ${_learnedIds.length}, bookmarked: ${_bookmarkedIds.length})';
  }
}
