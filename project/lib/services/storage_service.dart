import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/user_progress.dart';

/// Service-Klasse für die lokale Datenspeicherung mit SharedPreferences.
///
/// Speichert und lädt folgende Daten:
/// - [UserProgress]: Lernfortschritt, Lesezeichen, Quiz-Historie
/// - [AppSettings]: Benutzereinstellungen (Bundesland, Dark Mode, Sprache, etc.)
///
/// Alle Daten werden als JSON-Strings in SharedPreferences gespeichert.
/// Die Fragenreferenzen werden über IDs aufgelöst.
///
/// Verwendung:
/// ```dart
/// final storage = StorageService();
/// await storage.saveProgress(userProgress);
/// final progress = await storage.loadProgress(allQuestionsMap);
/// ```
class StorageService {
  // ==========================================================================
  // Konstanten für SharedPreferences-Schlüssel
  // ==========================================================================

  /// Schlüssel für den gespeicherten Lernfortschritt.
  static const String _keyProgress = 'user_progress';

  /// Schlüssel für die gespeicherten App-Einstellungen.
  static const String _keySettings = 'app_settings';

  /// Schlüssel für die Liste der bestandenen Fragen-IDs.
  static const String _keyLearnedIds = 'learned_question_ids';

  /// Schlüssel für die Liste der Lesezeichen-Fragen-IDs.
  static const String _keyBookmarkedIds = 'bookmarked_question_ids';

  /// Schlüssel für die Anzahl der absolvierten Quizze.
  static const String _keyQuizCount = 'quiz_count';

  /// Schlüssel für das zuletzt gespeicherte Bundesland.
  static const String _keyLastState = 'last_selected_state';

  // ==========================================================================
  // Singleton Pattern
  // ==========================================================================

  /// Die einzige Instanz des StorageService.
  static StorageService? _instance;

  /// Die SharedPreferences-Instanz.
  SharedPreferences? _prefs;

  /// Privater Konstruktor für das Singleton-Pattern.
  StorageService._internal();

  /// Gibt die Singleton-Instanz zurück.
  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// Initialisiert den Service und lädt SharedPreferences.
  ///
  /// Muss einmalig vor der Verwendung aufgerufen werden.
  /// Wird automatisch von [saveProgress], [loadProgress] etc. aufgerufen.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Stellt sicher, dass SharedPreferences initialisiert sind.
  Future<SharedPreferences> _getPrefs() async {
    await init();
    return _prefs!;
  }

  // ==========================================================================
  // UserProgress speichern/laden
  // ==========================================================================

  /// Speichert den aktuellen Lernfortschritt.
  ///
  /// Serialisiert [UserProgress] als JSON und speichert es
  /// in SharedPreferences unter dem Schlüssel [_keyProgress].
  ///
  /// Wirft eine [StateError] wenn das Speichern fehlschlägt.
  Future<void> saveProgress(UserProgress progress) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = jsonEncode(progress.toJson());
      final success = await prefs.setString(_keyProgress, jsonString);

      if (!success) {
        throw StateError('Konnte Fortschritt nicht speichern');
      }
    } catch (e) {
      throw StateError('Fehler beim Speichern des Fortschritts: $e');
    }
  }

  /// Lädt den gespeicherten Lernfortschritt.
  ///
  /// [allQuestionsMap] wird benötigt um Fragenreferenzen in QuizResult
  /// anhand ihrer ID aufzulösen.
  ///
  /// Gibt [UserProgress.empty] zurück wenn noch kein Fortschritt gespeichert wurde.
  ///
  /// Wirft eine [StateError] wenn das Laden oder Parsen fehlschlägt.
  Future<UserProgress> loadProgress(
    Map<int, Question> allQuestionsMap,
  ) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_keyProgress);

      if (jsonString == null || jsonString.isEmpty) {
        return UserProgress.empty();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProgress.fromJson(json, allQuestionsMap);
    } catch (e) {
      // Bei Fehlern: Leeren Fortschritt zurückgeben
      return UserProgress.empty();
    }
  }

  // ==========================================================================
  // AppSettings speichern/laden
  // ==========================================================================

  /// Speichert die aktuellen App-Einstellungen.
  ///
  /// Serialisiert [AppSettings] als JSON und speichert es
  /// in SharedPreferences unter dem Schlüssel [_keySettings].
  ///
  /// Wirft eine [StateError] wenn das Speichern fehlschlägt.
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = jsonEncode(settings.toJson());
      final success = await prefs.setString(_keySettings, jsonString);

      if (!success) {
        throw StateError('Konnte Einstellungen nicht speichern');
      }
    } catch (e) {
      throw StateError('Fehler beim Speichern der Einstellungen: $e');
    }
  }

  /// Lädt die gespeicherten App-Einstellungen.
  ///
  /// Gibt [AppSettings.defaults] zurück wenn noch keine Einstellungen
  /// gespeichert wurden.
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_keySettings);

      if (jsonString == null || jsonString.isEmpty) {
        return AppSettings.defaults();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (e) {
      // Bei Fehlern: Standardeinstellungen zurückgeben
      return AppSettings.defaults();
    }
  }

  // ==========================================================================
  // Partielle Updates (Performance-optimiert)
  // ==========================================================================

  /// Fügt eine Frage zur Liste der gelernten Fragen hinzu.
  ///
  /// Aktualisiert nur die Lernliste ohne den gesamten Fortschritt
  /// neu zu serialisieren.
  Future<void> addLearnedQuestion(int questionId) async {
    try {
      final prefs = await _getPrefs();
      final ids = prefs.getStringList(_keyLearnedIds) ?? [];
      final idString = questionId.toString();

      if (!ids.contains(idString)) {
        ids.add(idString);
        await prefs.setStringList(_keyLearnedIds, ids);
      }
    } catch (e) {
      // Fehler beim Speichern ignorieren
    }
  }

  /// Entfernt eine Frage von der Liste der gelernten Fragen.
  Future<void> removeLearnedQuestion(int questionId) async {
    try {
      final prefs = await _getPrefs();
      final ids = prefs.getStringList(_keyLearnedIds) ?? [];
      ids.remove(questionId.toString());
      await prefs.setStringList(_keyLearnedIds, ids);
    } catch (e) {
      // Fehler ignorieren
    }
  }

  /// Lädt die IDs der gelernten Fragen.
  ///
  /// Gibt ein leeres Set zurück wenn noch keine Daten gespeichert wurden.
  Future<Set<int>> loadLearnedQuestionIds() async {
    try {
      final prefs = await _getPrefs();
      final ids = prefs.getStringList(_keyLearnedIds) ?? [];
      return ids.map(int.parse).toSet();
    } catch (e) {
      return {};
    }
  }

  /// Fügt ein Lesezeichen für eine Frage hinzu.
  Future<void> addBookmark(int questionId) async {
    try {
      final prefs = await _getPrefs();
      final ids = prefs.getStringList(_keyBookmarkedIds) ?? [];
      final idString = questionId.toString();

      if (!ids.contains(idString)) {
        ids.add(idString);
        await prefs.setStringList(_keyBookmarkedIds, ids);
      }
    } catch (e) {
      // Fehler ignorieren
    }
  }

  /// Entfernt ein Lesezeichen für eine Frage.
  Future<void> removeBookmark(int questionId) async {
    try {
      final prefs = await _getPrefs();
      final ids = prefs.getStringList(_keyBookmarkedIds) ?? [];
      ids.remove(questionId.toString());
      await prefs.setStringList(_keyBookmarkedIds, ids);
    } catch (e) {
      // Fehler ignorieren
    }
  }

  /// Lädt die IDs der markierten Fragen.
  ///
  /// Gibt ein leeres Set zurück wenn noch keine Daten gespeichert wurden.
  Future<Set<int>> loadBookmarkedQuestionIds() async {
    try {
      final prefs = await _getPrefs();
      final ids = prefs.getStringList(_keyBookmarkedIds) ?? [];
      return ids.map(int.parse).toSet();
    } catch (e) {
      return {};
    }
  }

  /// Speichert das zuletzt ausgewählte Bundesland.
  Future<void> saveLastState(String state) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_keyLastState, state);
    } catch (e) {
      // Fehler ignorieren
    }
  }

  /// Lädt das zuletzt ausgewählte Bundesland.
  ///
  /// Gibt `null` zurück wenn kein Bundesland gespeichert wurde.
  Future<String?> loadLastState() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_keyLastState);
    } catch (e) {
      return null;
    }
  }

  // ==========================================================================
  // Quiz-Historie
  // ==========================================================================

  /// Fügt ein Quiz-Ergebnis zur Historie hinzu.
  ///
  /// Lädt die bestehende Historie, fügt das neue Ergebnis hinzu
  /// und speichert alles zurück.
  Future<void> addQuizResultToHistory(
    QuizResult result,
    Map<int, Question> allQuestionsMap,
  ) async {
    try {
      final prefs = await _getPrefs();

      // Bestehende Historie laden
      final List<QuizResult> history = await _loadQuizHistory(allQuestionsMap);
      history.add(result);

      // Maximal 50 Ergebnisse behalten
      if (history.length > 50) {
        history.removeAt(0);
      }

      // Historie als JSON speichern
      final historyJson = history.map((r) => r.toJson()).toList();
      final historyString = jsonEncode(historyJson);
      await prefs.setString('quiz_history', historyString);

      // Quiz-Zähler aktualisieren
      await prefs.setInt(_keyQuizCount, history.length);
    } catch (e) {
      throw StateError('Fehler beim Speichern des Quiz-Ergebnisses: $e');
    }
  }

  /// Lädt die Quiz-Historie.
  ///
  /// Gibt eine chronologisch sortierte Liste zurück
  /// (ältestes Ergebnis zuerst).
  Future<List<QuizResult>> loadQuizHistory(
    Map<int, Question> allQuestionsMap,
  ) async {
    return _loadQuizHistory(allQuestionsMap);
  }

  Future<List<QuizResult>> _loadQuizHistory(
    Map<int, Question> allQuestionsMap,
  ) async {
    try {
      final prefs = await _getPrefs();
      final historyString = prefs.getString('quiz_history');

      if (historyString == null || historyString.isEmpty) {
        return [];
      }

      final historyJson = jsonDecode(historyString) as List<dynamic>;
      return historyJson
          .map(
            (json) => QuizResult.fromJson(
              json as Map<String, dynamic>,
              allQuestionsMap,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==========================================================================
  // Löschmethoden
  // ==========================================================================

  /// Löscht alle gespeicherten Daten.
  ///
  /// Setzt die App in den Auslieferungszustand zurück.
  /// Verwendet mit Vorsicht!
  Future<void> clearAll() async {
    try {
      final prefs = await _getPrefs();

      // Alle relevanten Schlüssel löschen
      await prefs.remove(_keyProgress);
      await prefs.remove(_keySettings);
      await prefs.remove(_keyLearnedIds);
      await prefs.remove(_keyBookmarkedIds);
      await prefs.remove(_keyQuizCount);
      await prefs.remove(_keyLastState);
      await prefs.remove('quiz_history');
    } catch (e) {
      throw StateError('Fehler beim Löschen aller Daten: $e');
    }
  }

  /// Löscht nur den Lernfortschritt (nicht Einstellungen).
  Future<void> clearProgress() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_keyProgress);
      await prefs.remove(_keyLearnedIds);
      await prefs.remove(_keyBookmarkedIds);
      await prefs.remove(_keyQuizCount);
      await prefs.remove('quiz_history');
    } catch (e) {
      throw StateError('Fehler beim Löschen des Fortschritts: $e');
    }
  }

  /// Löscht nur die Quiz-Historie.
  Future<void> clearQuizHistory() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove('quiz_history');
      await prefs.remove(_keyQuizCount);
    } catch (e) {
      throw StateError('Fehler beim Löschen der Quiz-Historie: $e');
    }
  }

  /// Löscht alle Lesezeichen.
  Future<void> clearBookmarks() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_keyBookmarkedIds);
    } catch (e) {
      throw StateError('Fehler beim Löschen der Lesezeichen: $e');
    }
  }

  // ==========================================================================
  // Statistiken
  // ==========================================================================

  /// Gibt die Anzahl der absolvierten Quizze zurück.
  Future<int> getQuizCount() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getInt(_keyQuizCount) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Gibt an, ob bereits Daten gespeichert wurden.
  Future<bool> hasData() async {
    try {
      final prefs = await _getPrefs();
      return prefs.containsKey(_keyProgress) ||
          prefs.containsKey(_keySettings);
    } catch (e) {
      return false;
    }
  }
}
