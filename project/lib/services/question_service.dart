import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/question.dart';

/// Service-Klasse zum Laden und Verwalten der Einbürgerungstest-Fragen.
///
/// Lädt die Fragen aus der JSON-Datei `assets/questions.json` und bietet
/// verschiedene Filter- und Auswahlmethoden.
///
/// Die Fragen sind in zwei Gruppen unterteilt:
/// - **300 allgemeine Fragen**: Für alle Bundesländer identisch
/// - **10 Fragen pro Bundesland**: 16 x 10 = 160 bundeslandspezifische Fragen
///
/// Ein Test besteht aus 33 Fragen: 30 zufällige allgemeine + 3 Bundesland-Fragen.
///
/// Verwendung:
/// ```dart
/// final questionService = QuestionService();
/// await questionService.loadQuestions();
/// final general = questionService.getGeneralQuestions();
/// final state = questionService.getStateQuestions('Bayern');
/// ```
class QuestionService {
  // ==========================================================================
  // Felder
  // ==========================================================================

  /// Alle geladenen Fragen (allgemeine + bundeslandspezifische).
  List<Question> _allQuestions = [];

  /// Gibt an, ob die Fragen bereits geladen wurden.
  bool _isLoaded = false;

  /// Zufalls-Generator für die Auswahl zufälliger Fragen.
  final Random _random = Random();

  // ==========================================================================
  // Konstanten
  // ==========================================================================

  /// Anzahl der allgemeinen Fragen pro Test.
  static const int _generalQuestionsPerQuiz = 30;

  /// Anzahl der Bundesland-Fragen pro Test.
  static const int _stateQuestionsPerQuiz = 3;

  /// Anzahl der allgemeinen Fragen im Katalog.
  static const int _totalGeneralQuestions = 300;

  /// Pfad zur JSON-Datei mit den Fragen.
  static const String _questionsAssetPath = 'assets/questions.json';

  /// Pfad zur JSON-Datei mit den bundeslandspezifischen Fragen.
  /// Falls die Bundesland-Fragen in einer separaten Datei liegen.
  static const String _stateQuestionsAssetPath =
      'assets/state_questions.json';

  // ==========================================================================
  // Laden der Fragen
  // ==========================================================================

  /// Lädt alle Fragen aus den JSON-Assets.
  ///
  /// Muss vor der Verwendung anderer Methoden aufgerufen werden.
  /// Lädt sowohl allgemeine als auch bundeslandspezifische Fragen.
  ///
  /// Kann mehrfach aufgerufen werden, lädt die Daten aber nur beim ersten Mal.
  Future<void> loadQuestions() async {
    if (_isLoaded) return;

    try {
      // Allgemeine Fragen laden
      final String questionsJson =
          await rootBundle.loadString(_questionsAssetPath);
      final List<dynamic> questionsList =
          jsonDecode(questionsJson) as List<dynamic>;

      _allQuestions = questionsList
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();

      // Versuche auch Bundesland-Fragen zu laden
      await _loadStateQuestions();

      _isLoaded = true;
    } catch (e) {
      throw StateError(
        'Fehler beim Laden der Fragen aus $_questionsAssetPath: $e',
      );
    }
  }

  /// Lädt bundeslandspezifische Fragen aus einer separaten Datei.
  ///
  /// Fängt Fehler ab wenn die Datei nicht existiert.
  Future<void> _loadStateQuestions() async {
    try {
      final String stateJson =
          await rootBundle.loadString(_stateQuestionsAssetPath);
      final List<dynamic> stateQuestionsList =
          jsonDecode(stateJson) as List<dynamic>;

      final stateQuestions = stateQuestionsList
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();

      _allQuestions.addAll(stateQuestions);
    } catch (e) {
      // Wenn die Datei nicht existiert, sind die Bundesland-Fragen
      // möglicherweise bereits in questions.json enthalten
      // oder es gibt keine separaten Bundesland-Fragen
    }
  }

  /// Prüft ob die Fragen geladen wurden.
  ///
  /// Wirft einen [StateError] wenn die Fragen noch nicht geladen wurden.
  void _ensureLoaded() {
    if (!_isLoaded) {
      throw StateError(
        'Fragen wurden noch nicht geladen. '
        'Rufe loadQuestions() auf bevor du auf die Daten zugreifst.',
      );
    }
  }

  // ==========================================================================
  // Zugriffsmethoden
  // ==========================================================================

  /// Gibt alle geladenen Fragen zurück.
  ///
  /// Inkludiert sowohl allgemeine als auch bundeslandspezifische Fragen.
  List<Question> getAllQuestions() {
    _ensureLoaded();
    return List.unmodifiable(_allQuestions);
  }

  /// Gibt alle allgemeinen Fragen zurück (300 Stück).
  ///
  /// Allgemeine Fragen haben kein Bundesland (`state == null`).
  List<Question> getGeneralQuestions() {
    _ensureLoaded();
    return List.unmodifiable(
      _allQuestions.where((q) => !q.isStateSpecific).toList(),
    );
  }

  /// Gibt alle Fragen für ein bestimmtes Bundesland zurück (10 Stück).
  ///
  /// [state] muss eines der 16 deutschen Bundesländer sein.
  /// Gibt eine leere Liste zurück wenn keine Fragen für das Bundesland existieren.
  List<Question> getStateQuestions(String state) {
    _ensureLoaded();
    final normalizedState = _normalizeStateName(state);
    return List.unmodifiable(
      _allQuestions.where((q) => q.state == normalizedState).toList(),
    );
  }

  /// Gibt alle Fragen einer bestimmten Kategorie zurück.
  ///
  /// Verfügbare Kategorien:
  /// - Allgemein
  /// - Verfassung
  /// - Recht
  /// - Geschichte
  /// - Politik
  /// - Gesellschaft
  /// - Europa
  /// - Religion
  /// - Wahl
  /// - Interkulturelles
  List<Question> getQuestionsByCategory(String category) {
    _ensureLoaded();
    return List.unmodifiable(
      _allQuestions.where((q) => q.category.name == category).toList(),
    );
  }

  /// Sucht eine Frage anhand ihrer ID.
  ///
  /// Gibt `null` zurück wenn keine Frage mit der ID existiert.
  Question? getQuestionById(int id) {
    _ensureLoaded();
    try {
      return _allQuestions.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gibt alle verfügbaren Kategorien zurück.
  ///
  /// Die Kategorien sind alphabetisch sortiert.
  List<String> getAllCategories() {
    _ensureLoaded();
    final categories =
        _allQuestions.map((q) => q.category.name).toSet().toList();
    categories.sort();
    return List.unmodifiable(categories);
  }

  /// Gibt alle 16 deutschen Bundesländer zurück.
  ///
  /// Die Liste ist alphabetisch sortiert.
  List<String> getAllStates() {
    return List.unmodifiable([
      'Baden-Württemberg',
      'Bayern',
      'Berlin',
      'Brandenburg',
      'Bremen',
      'Hamburg',
      'Hessen',
      'Mecklenburg-Vorpommern',
      'Niedersachsen',
      'Nordrhein-Westfalen',
      'Rheinland-Pfalz',
      'Saarland',
      'Sachsen',
      'Sachsen-Anhalt',
      'Schleswig-Holstein',
      'Thüringen',
    ]);
  }

  // ==========================================================================
  // Quiz-Generierung
  // ==========================================================================

  /// Erstellt ein vollständiges Quiz mit 33 Fragen.
  ///
  /// Das Quiz besteht aus:
  /// - 30 zufällig ausgewählten allgemeinen Fragen
  /// - 3 zufälligen Fragen für das angegebene Bundesland
  ///
  /// [state] muss eines der 16 deutschen Bundesländer sein.
  /// Gibt `null` zurück wenn nicht genug Fragen verfügbar sind.
  List<Question>? generateQuizQuestions({required String state}) {
    _ensureLoaded();

    // Allgemeine Fragen sammeln und mischen
    final generalQuestions = getGeneralQuestions();
    if (generalQuestions.length < _generalQuestionsPerQuiz) {
      return null;
    }

    // 30 zufällige allgemeine Fragen auswählen
    final shuffledGeneral = List<Question>.from(generalQuestions)..shuffle();
    final selectedGeneral =
        shuffledGeneral.take(_generalQuestionsPerQuiz).toList();

    // Bundesland-Fragen sammeln und mischen
    final stateQuestions = getStateQuestions(state);
    if (stateQuestions.isEmpty) {
      // Keine Bundesland-Fragen verfügbar, nur allgemeine zurückgeben
      return List.unmodifiable(selectedGeneral);
    }

    final shuffledState = List<Question>.from(stateQuestions)..shuffle();
    final selectedState =
        shuffledState.take(_stateQuestionsPerQuiz).toList();

    // Kombinieren: Allgemeine zuerst, dann Bundesland-Fragen
    return List.unmodifiable([
      ...selectedGeneral,
      ...selectedState,
    ]);
  }

  /// Gibt 10 zufällige Fragen aus einer Kategorie zurück.
  ///
  /// Nützlich für gezieltes Üben einer Kategorie.
  /// Wenn weniger als 10 Fragen verfügbar sind, werden alle zurückgegeben.
  List<Question> getRandomQuestionsByCategory(
    String category, {
    int count = 10,
  }) {
    _ensureLoaded();
    final questions = getQuestionsByCategory(category);
    if (questions.isEmpty) return List.empty();

    final shuffled = List<Question>.from(questions)..shuffle();
    return List.unmodifiable(
      shuffled.take(count.clamp(1, questions.length)).toList(),
    );
  }

  /// Gibt eine zufällige Frage zurück.
  ///
  /// Optional kann eine Kategorie angegeben werden.
  Question? getRandomQuestion({String? category}) {
    _ensureLoaded();
    final questions = category != null
        ? getQuestionsByCategory(category)
        : _allQuestions;

    if (questions.isEmpty) return null;
    return questions[_random.nextInt(questions.length)];
  }

  // ==========================================================================
  // Statistiken
  // ==========================================================================

  /// Gibt die Gesamtanzahl aller Fragen zurück.
  int get totalQuestionCount {
    _ensureLoaded();
    return _allQuestions.length;
  }

  /// Gibt die Anzahl der allgemeinen Fragen zurück.
  int get generalQuestionCount {
    _ensureLoaded();
    return _allQuestions.where((q) => !q.isStateSpecific).length;
  }

  /// Gibt die Anzahl der Fragen pro Kategorie zurück.
  Map<String, int> getQuestionCountByCategory() {
    _ensureLoaded();
    final Map<String, int> counts = {};
    for (final question in _allQuestions) {
      counts[question.category.name] =
          (counts[question.category.name] ?? 0) + 1;
    }
    return Map.unmodifiable(counts);
  }

  /// Gibt die Anzahl der Fragen für ein Bundesland zurück.
  int getStateQuestionCount(String state) {
    _ensureLoaded();
    return getStateQuestions(state).length;
  }

  // ==========================================================================
  // Hilfsmethoden
  // ==========================================================================

  /// Normalisiert einen Bundesland-Namen.
  ///
  /// Entfernt überflüssige Leerzeichen und prüft gegen die Liste
  /// der gültigen Bundesländer.
  String _normalizeStateName(String state) {
    final trimmed = state.trim();
    final states = getAllStates();

    // Exakte Übereinstimmung
    if (states.contains(trimmed)) return trimmed;

    // Groß-/Kleinschreibung ignorieren
    final lowerTrimmed = trimmed.toLowerCase();
    for (final s in states) {
      if (s.toLowerCase() == lowerTrimmed) return s;
    }

    // Nächstgelegene Übereinstimmung zurückgeben
    return trimmed;
  }
}
