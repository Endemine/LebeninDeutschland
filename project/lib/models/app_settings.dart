import 'dart:convert';

// =============================================================================
// AppLanguage Enum
// =============================================================================

/// Unterstützte Sprachen der App.
enum AppLanguage {
  /// Deutsch
  de,

  /// Englisch
  en,

  /// Türkisch
  tr,

  /// Arabisch
  ar;

  /// Der Locale-Code für die Sprache.
  String get localeCode {
    switch (this) {
      case AppLanguage.de:
        return 'de';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.tr:
        return 'tr';
      case AppLanguage.ar:
        return 'ar';
    }
  }

  /// Der Anzeigename der Sprache im Native-Format.
  String get displayName {
    switch (this) {
      case AppLanguage.de:
        return 'Deutsch';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.tr:
        return 'Türkçe';
      case AppLanguage.ar:
        return 'العربية';
    }
  }
}

// =============================================================================
// GermanStates
// =============================================================================

/// Hält die Liste aller deutschen Bundesländer.
class GermanStates {
  /// Alle 16 deutschen Bundesländer.
  static const List<String> all = [
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
  ];

  GermanStates._(); // Privater Konstruktor
}

/// Repräsentiert die App-Einstellungen des Benutzers.
///
/// Speichert alle benutzerdefinierbaren Einstellungen der App:
/// - Ausgewähltes Bundesland für bundeslandspezifische Fragen
/// - Darstellungsmodus (hell/dunkel)
/// - Sprache der App-Oberfläche
/// - Sound-Einstellungen
/// - Benachrichtigungseinstellungen
///
/// Wird mit [StorageService] persistiert und bei App-Start geladen.
class AppSettings {
  // ==========================================================================
  // Konstanten
  // ==========================================================================

  /// Standard-Bundesland (noch nicht ausgewählt).
  static const String defaultState = 'Bayern';

  /// Standard-Sprache (Deutsch).
  static const String defaultLanguage = 'de';

  /// Liste der unterstützten Sprachen mit ihren Anzeigenamen.
  ///
  /// - `de`: Deutsch
  /// - `en`: Englisch
  /// - `tr`: Türkisch
  /// - `ar`: Arabisch
  static const Map<String, String> supportedLanguages = {
    'de': 'Deutsch',
    'en': 'English',
    'tr': 'Türkçe',
    'ar': 'العربية',
  };

  /// Liste der 16 deutschen Bundesländer.
  static const List<String> germanStates = [
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
  ];

  // ==========================================================================
  // Felder
  // ==========================================================================

  /// Das vom Benutzer ausgewählte Bundesland.
  ///
  /// Bestimmt welche 3 bundeslandspezifischen Fragen im Test
  /// angezeigt werden. Muss eines der 16 Bundesländer sein.
  final String selectedState;

  /// Gibt an, ob der Dunkelmodus aktiviert ist.
  ///
  /// - `false`: Helles Theme (Standard)
  /// - `true`: Dunkles Theme
  final bool darkMode;

  /// Die ausgewählte Sprache der App-Oberfläche.
  ///
  /// Standard ist [AppLanguage.de] (Deutsch).
  final AppLanguage language;

  /// Gibt an, ob Soundeffekte aktiviert sind.
  ///
  /// - `true`: Soundeffekte bei richtiger/falscher Antwort abspielen
  /// - `false`: Keine Soundeffekte
  final bool soundEnabled;

  /// Gibt an, ob Push-Benachrichtigungen aktiviert sind.
  ///
  /// - `true`: Erinnerungsbenachrichtigungen für Lernziele
  /// - `false`: Keine Benachrichtigungen
  final bool notificationsEnabled;

  /// Tägliches Lernziel (Anzahl der Fragen pro Tag).
  ///
  /// Standard ist 10 Fragen pro Tag.
  final int dailyGoal;

  /// Gibt an, ob der Quiz-Timer angezeigt werden soll.
  ///
  /// - `true`: Timer wird im Quiz angezeigt (Standard)
  /// - `false`: Timer ist ausgeblendet
  final bool showTimer;

  /// Gibt an, ob ein Warnsound bei ablaufender Zeit abgespielt wird.
  ///
  /// - `true`: Warnsound wenn weniger als 5 Minuten übrig
  /// - `false`: Kein Warnsound
  final bool timerWarningSound;

  // ==========================================================================
  // Konstruktor
  // ==========================================================================

  /// Erstellt neue App-Einstellungen.
  ///
  /// Alle Parameter haben sinnvolle Standardwerte.
  const AppSettings({
    this.selectedState = defaultState,
    this.darkMode = false,
    this.language = AppLanguage.de,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.dailyGoal = 10,
    this.showTimer = true,
    this.timerWarningSound = true,
  });

  /// Erstellt die Standard-Einstellungen beim ersten App-Start.
  factory AppSettings.defaults() => const AppSettings();

  // ==========================================================================
  // Hilfsgetter
  // ==========================================================================

  /// Gibt den Anzeigenamen der aktuellen Sprache zurück.
  String get languageName => language.displayName;

  /// Gibt an, ob die aktuelle Sprache RTL (right-to-left) ist.
  ///
  /// Aktuell nur Arabisch ('ar') ist eine RTL-Sprache.
  bool get isRtl => language == AppLanguage.ar;

  /// Gibt an, ob das gewählte Bundesland gültig ist.
  bool get isValidState => germanStates.contains(selectedState);

  /// Der Locale-Code für die aktuelle Sprache (z.B. 'de', 'en', 'tr', 'ar').
  String get localeCode => language.localeCode;

  // ==========================================================================
  // Copy-With
  // ==========================================================================

  /// Erzeugt eine Kopie mit aktualisierten Werten.
  ///
  /// Beispiel:
  /// ```dart
  /// final newSettings = settings.copyWith(darkMode: true);
  /// ```
  AppSettings copyWith({
    String? selectedState,
    bool? darkMode,
    AppLanguage? language,
    bool? soundEnabled,
    bool? notificationsEnabled,
    int? dailyGoal,
    bool? showTimer,
    bool? timerWarningSound,
  }) {
    return AppSettings(
      selectedState: selectedState ?? this.selectedState,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      showTimer: showTimer ?? this.showTimer,
      timerWarningSound: timerWarningSound ?? this.timerWarningSound,
    );
  }

  // ==========================================================================
  // JSON-Serialisierung
  // ==========================================================================

  /// Konvertiert die Einstellungen in ein JSON-Objekt.
  Map<String, dynamic> toJson() {
    return {
      'selectedState': selectedState,
      'darkMode': darkMode,
      'language': language.name,
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
      'dailyGoal': dailyGoal,
      'showTimer': showTimer,
      'timerWarningSound': timerWarningSound,
    };
  }

  /// Konvertiert die Einstellungen in einen JSON-String.
  String toJsonString() => jsonEncode(toJson());

  /// Erstellt [AppSettings] aus einem JSON-Objekt.
  ///
  /// Ungültige Werte werden durch Standardwerte ersetzt.
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    // Validiere das Bundesland
    String state = json['selectedState'] as String? ?? defaultState;
    if (!germanStates.contains(state)) {
      state = defaultState;
    }

    // Validiere die Sprache
    final langString = json['language'] as String? ?? defaultLanguage;
    AppLanguage lang = AppLanguage.values.firstWhere(
      (l) => l.name == langString,
      orElse: () => AppLanguage.de,
    );

    return AppSettings(
      selectedState: state,
      darkMode: json['darkMode'] as bool? ?? false,
      language: lang,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyGoal: json['dailyGoal'] as int? ?? 10,
      showTimer: json['showTimer'] as bool? ?? true,
      timerWarningSound: json['timerWarningSound'] as bool? ?? true,
    );
  }

  /// Erstellt [AppSettings] aus einem JSON-String.
  factory AppSettings.fromJsonString(String json) {
    return AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'AppSettings(state: $selectedState, language: $language, '
        'darkMode: $darkMode, sound: $soundEnabled, notifications: $notificationsEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.selectedState == selectedState &&
        other.darkMode == darkMode &&
        other.language == language &&
        other.soundEnabled == soundEnabled &&
        other.notificationsEnabled == notificationsEnabled &&
        other.dailyGoal == dailyGoal &&
        other.showTimer == showTimer &&
        other.timerWarningSound == timerWarningSound;
  }

  @override
  int get hashCode => Object.hash(
        selectedState,
        darkMode,
        language,
        soundEnabled,
        notificationsEnabled,
        dailyGoal,
        showTimer,
        timerWarningSound,
      );
}
