// =============================================================================
// SETTINGS PROVIDER
// =============================================================================
// Verwaltet alle App-Einstellungen: Bundesland, Sprache,
// Benachrichtigungen und Lern-Einstellungen.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Der SettingsProvider verwaltet alle persistierbaren Einstellungen der App.
///
/// Funktionsumfang:
/// - Bundesland-Auswahl für bundeslandspezifische Fragen
/// - Sprachauswahl
/// - Benachrichtigungs-Einstellungen
/// - Lern-Einstellungen (tägliches Ziel, Sound, Timer)
/// - Zurücksetzen aller Daten
///
/// Usage:
/// ```dart
/// final settingsProvider = context.read<SettingsProvider>();
/// await settingsProvider.loadSettings();
/// settingsProvider.setState('Bayern');
/// ```
class SettingsProvider extends ChangeNotifier {
  // ===========================================================================
  // PERSISTENZ-SCHLÜSSEL
  // ===========================================================================

  static const String _kSettingsKey = 'app_settings';

  // ===========================================================================
  // INTERNER ZUSTAND
  // ===========================================================================

  /// Aktuelle App-Einstellungen
  AppSettings _settings = AppSettings.defaults();

  /// Lade-Status
  bool _isLoading = false;

  /// Fehlermeldung
  String? _error;

  /// Gibt an ob Einstellungen geladen wurden
  bool _isInitialized = false;

  // ===========================================================================
  // GETTER
  // ===========================================================================

  /// Aktuelle App-Einstellungen
  AppSettings get settings => _settings;

  /// Das ausgewählte Bundesland
  String get selectedState => _settings.selectedState;

  /// Aktuelle Sprache
  AppLanguage get language => _settings.language;

  /// Benachrichtigungen aktiviert
  bool get notificationsEnabled => _settings.notificationsEnabled;

  /// Tägliches Lernziel
  int get dailyGoal => _settings.dailyGoal;

  /// Sound-Effekte aktiviert
  bool get soundEnabled => _settings.soundEnabled;

  /// Quiz-Timer anzeigen
  bool get showTimer => _settings.showTimer;

  /// Timer-Warnsound
  bool get timerWarningSound => _settings.timerWarningSound;

  /// Liste aller verfügbaren Bundesländer
  List<String> get availableStates => GermanStates.all;

  /// Liste aller verfügbaren Sprachen
  List<AppLanguage> get availableLanguages => AppLanguage.values;

  /// Gibt an ob Einstellungen geladen wurden
  bool get isInitialized => _isInitialized;

  /// Lade-Status
  bool get isLoading => _isLoading;

  /// Fehlermeldung
  String? get error => _error;

  // ===========================================================================
  // LADEN & SPEICHERN
  // ===========================================================================

  /// Lädt die gespeicherten Einstellungen aus SharedPreferences.
  ///
  /// Diese Methode sollte beim App-Start in main() aufgerufen werden.
  /// Sollte vor anderen Operationen abgeschlossen sein.
  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kSettingsKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        _settings = AppSettings.fromJsonString(jsonString);
      } else {
        // Keine gespeicherten Einstellungen - Defaults verwenden
        _settings = AppSettings.defaults();
        // Defaults sofort speichern
        await saveSettings();
      }

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Fehler beim Laden der Einstellungen: $e';
      // Fallback auf Defaults
      _settings = AppSettings.defaults();
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Speichert die aktuellen Einstellungen in SharedPreferences.
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSettingsKey, _settings.toJsonString());
    } catch (e) {
      _error = 'Fehler beim Speichern der Einstellungen: $e';
      debugPrint('SettingsProvider: Fehler beim Speichern: $e');
    }
  }

  // ===========================================================================
  // BUNDESLAND
  // ===========================================================================

  /// Setzt das ausgewählte Bundesland.
  ///
  /// [state] Der Name des Bundeslands (muss in [GermanStates.all] enthalten sein)
  void setState(String state) {
    // Validierung: Prüfe ob das Bundesland existiert
    if (!GermanStates.all.contains(state)) {
      debugPrint('SettingsProvider: Ungültiges Bundesland: $state');
      return;
    }

    _settings = _settings.copyWith(selectedState: state);
    saveSettings();
    notifyListeners();
  }

  // Kein Dark Mode: die Screens verwenden hart kodierte Light-Farben statt
  // Theme.of(context).colorScheme. Solange das so ist, waere ein umschaltbarer
  // Dark Mode nicht lesbar — siehe Kommentar in main.dart.

  // ===========================================================================
  // SPRACHE
  // ===========================================================================

  /// Setzt die App-Sprache.
  ///
  /// [lang] Der Locale-Code der Sprache (z.B. 'de', 'en', 'tr')
  void setLanguage(String lang) {
    final language = AppLanguage.values.firstWhere(
      (l) => l.localeCode == lang,
      orElse: () => AppLanguage.de,
    );

    _settings = _settings.copyWith(language: language);
    saveSettings();
    notifyListeners();
  }

  /// Setzt die Sprache über die AppLanguage Enum.
  ///
  /// [language] Die zu setzende Sprache
  void setLanguageEnum(AppLanguage language) {
    _settings = _settings.copyWith(language: language);
    saveSettings();
    notifyListeners();
  }

  // ===========================================================================
  // BENACHRICHTIGUNGEN
  // ===========================================================================

  /// Toggelt Benachrichtigungen für Lern-Erinnerungen.
  void toggleNotifications() {
    _settings = _settings.copyWith(
      notificationsEnabled: !_settings.notificationsEnabled,
    );
    saveSettings();
    notifyListeners();
  }

  /// Setzt das tägliche Lernziel.
  ///
  /// [goal] Anzahl der Fragen pro Tag (1-50)
  void setDailyGoal(int goal) {
    // Validierung
    final clamped = goal.clamp(1, 50);
    _settings = _settings.copyWith(dailyGoal: clamped);
    saveSettings();
    notifyListeners();
  }

  // ===========================================================================
  // SOUND & TIMER
  // ===========================================================================

  /// Toggelt Sound-Effekte.
  void toggleSound() {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    saveSettings();
    notifyListeners();
  }

  /// Toggelt die Timer-Anzeige im Quiz.
  void toggleShowTimer() {
    _settings = _settings.copyWith(showTimer: !_settings.showTimer);
    saveSettings();
    notifyListeners();
  }

  /// Toggelt den Timer-Warnsound.
  void toggleTimerWarningSound() {
    _settings = _settings.copyWith(
      timerWarningSound: !_settings.timerWarningSound,
    );
    saveSettings();
    notifyListeners();
  }

  // ===========================================================================
  // ALLGEMEINE EINSTELLUNGEN
  // ===========================================================================

  /// Aktualisiert mehrere Einstellungen auf einmal.
  ///
  /// [newSettings] Die neuen Einstellungen
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await saveSettings();
    notifyListeners();
  }

  /// Setzt alle Einstellungen auf die Standardwerte zurück.
  Future<void> resetToDefaults() async {
    _settings = AppSettings.defaults();
    await saveSettings();
    notifyListeners();
  }

  // ===========================================================================
  // PROGRESS RESET
  // ===========================================================================

  /// Setzt die Einstellungen auf die Standardwerte zurück und persistiert sie.
  ///
  /// Achtung: Diese Aktion kann nicht rückgängig gemacht werden!
  ///
  /// Lernfortschritt, Bookmarks und Statistiken gehören dem [LearningProvider]
  /// bzw. dem [StatisticsProvider] — diese müssen ihre eigenen `clear*`-Methoden
  /// aufrufen. Würden die Schlüssel hier direkt aus den SharedPreferences
  /// gelöscht, blieben die Daten im Speicher der anderen Provider stehen und die
  /// App zeigte den alten Stand bis zum Neustart.
  Future<void> resetProgress() async {
    try {
      _settings = AppSettings.defaults();
      await saveSettings();
      notifyListeners();
    } catch (e) {
      _error = 'Fehler beim Zurücksetzen der Daten: $e';
      debugPrint('SettingsProvider: Fehler beim Reset: $e');
      notifyListeners();
    }
  }

  // ===========================================================================
  // HILFSMETHODEN
  // ===========================================================================

  /// Gibt den Anzeigenamen für ein Bundesland zurück.
  ///
  /// [state] Der Name des Bundeslands
  /// Returns: Der formatierte Name
  String getStateDisplayName(String state) => state;

  /// Gibt den Anzeigenamen für eine Sprache zurück.
  ///
  /// [lang] Der Locale-Code
  /// Returns: Der native Name der Sprache
  String getLanguageDisplayName(String lang) {
    final language = AppLanguage.values.firstWhere(
      (l) => l.localeCode == lang,
      orElse: () => AppLanguage.de,
    );
    return language.displayName;
  }

  @override
  String toString() => 'SettingsProvider(${_settings.toString()})';
}
