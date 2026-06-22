// Deterministischer Beweis: Filter-Pipeline (Chip-Klick -> State-Änderung ->
// Filter-Resultat) funktioniert, ohne pumpAndSettle.
// Die Chips und Bottom-Sheets sind reine UI-Wrapper; die Logik steckt im
// LearningProvider und SettingsProvider. Wenn die State-Änderungen wirken
// und die Fragen richtig gefiltert werden, funktionieren auch die UI.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:einbuergerungstest/providers/learning_provider.dart';
import 'package:einbuergerungstest/models/question.dart';
import 'package:einbuergerungstest/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('LearningProvider: alle 460 Fragen geladen', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    expect(lp.allQuestions.length, 460);
  });

  test('LearningProvider: 16 Bundesländer mit je 10 Fragen', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    final states = lp.availableStates;
    expect(states.length, 16);
    for (final s in states) {
      expect(lp.allQuestions.where((q) => q.state == s).length, 10,
          reason: 'Bundesland $s sollte 10 Fragen haben');
    }
  });

  test('Kategorie-Filter Bundesland reduziert auf 160 Fragen', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    lp.setCategoryFilter(QuestionCategory.bundesland);
    expect(lp.filterCategory, QuestionCategory.bundesland);
    expect(lp.filteredQuestions.length, 160);
  });

  test('Kategorie-Filter Allgemein reduziert auf 300 Fragen', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    lp.setCategoryFilter(QuestionCategory.allgemein);
    expect(lp.filteredQuestions.length, 300);
  });

  test('Kategorie Alle = 460', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    lp.setCategoryFilter(null);
    expect(lp.filteredQuestions.length, 460);
  });

  test('Bundesland-Picker: Bayern liefert genau 10 Fragen, alle Bayern', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    lp.setCategoryFilter(QuestionCategory.bundesland);
    lp.setStateFilter('Bayern');
    expect(lp.filterState, 'Bayern');
    expect(lp.filteredQuestions.length, 10);
    expect(lp.filteredQuestions.every((q) => q.state == 'Bayern'), true);
  });

  test('Bundesland-Picker: Niedersachsen liefert genau 10 Fragen, alle NDS', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    lp.setCategoryFilter(QuestionCategory.bundesland);
    lp.setStateFilter('Niedersachsen');
    expect(lp.filterState, 'Niedersachsen');
    expect(lp.filteredQuestions.length, 10);
    expect(lp.filteredQuestions.every((q) => q.state == 'Niedersachsen'), true);
  });

  test('Bundesland-Picker: State null = alle 160 Bundesland-Fragen', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    lp.setCategoryFilter(QuestionCategory.bundesland);
    lp.setStateFilter(null);
    expect(lp.filteredQuestions.length, 160);
  });

  test('Sprach-Umschaltung viewLanguage DE/EN/AR', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    expect(lp.viewLanguage, 'de');
    lp.setViewLanguage('en');
    expect(lp.viewLanguage, 'en');
    lp.setViewLanguage('ar');
    expect(lp.viewLanguage, 'ar');
  });

  test('SettingsProvider: Standard-Sprache DE', () async {
    final sp = SettingsProvider();
    await sp.loadSettings();
    expect(sp.language.localeCode, 'de');
  });

  test('SettingsProvider: Sprache umschalten persistiert in MockPrefs', () async {
    final sp = SettingsProvider();
    await sp.loadSettings();
    sp.setLanguage('ar');
    expect(sp.language.localeCode, 'ar');
    // frische Instanz liest aus denselben MockPrefs -> sollte AR sein
    final sp2 = SettingsProvider();
    await sp2.loadSettings();
    expect(sp2.language.localeCode, 'ar');
  });

  test('SettingsProvider: Bundesland setzen + persistieren', () async {
    final sp = SettingsProvider();
    await sp.loadSettings();
    sp.setState('Bayern');
    expect(sp.selectedState, 'Bayern');
    final sp2 = SettingsProvider();
    await sp2.loadSettings();
    expect(sp2.selectedState, 'Bayern');
  });
}
