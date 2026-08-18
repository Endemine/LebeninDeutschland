// Widget-Test: Tappt die Filter-Chips und den Bundesland-Picker im Lernmodus
// und verifiziert, dass die Interaktionen tatsächlich wirken.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:einbuergerungstest/providers/learning_provider.dart';
import 'package:einbuergerungstest/models/question.dart';
import 'package:einbuergerungstest/providers/settings_provider.dart';
import 'package:einbuergerungstest/screens/learning_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildApp(LearningProvider lp, SettingsProvider sp) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LearningProvider>.value(value: lp),
        ChangeNotifierProvider<SettingsProvider>.value(value: sp),
      ],
      child: const MaterialApp(home: LearningScreen()),
    );
  }

  /// Lädt Fragen und Einstellungen über echte Async-I/O.
  ///
  /// Wichtig: `loadQuestions()` liest `assets/questions.json` via rootBundle und
  /// `loadSettings()` greift auf SharedPreferences zu. Beides sind echte
  /// asynchrone Operationen, die in der FakeAsync-Zone von `testWidgets` nie
  /// abgeschlossen werden — ein direktes `await` blockiert den Test-Isolate
  /// dauerhaft (auch `--timeout` greift dann nicht mehr). Deshalb `runAsync`.
  Future<void> loadProviders(
    WidgetTester tester,
    LearningProvider lp,
    SettingsProvider sp,
  ) async {
    await tester.runAsync(() async {
      await lp.loadQuestions();
      await sp.loadSettings();
    });
  }

  testWidgets('Kategorie-Chips filtern Fragen', (tester) async {
    final lp = LearningProvider();
    final sp = SettingsProvider();
    await loadProviders(tester, lp, sp);
    expect(lp.filteredQuestions.length, 460);

    await tester.pumpWidget(buildApp(lp, sp));
    await tester.pumpAndSettle();

    // Chip "Bundesland" tippen
    await tester.tap(find.text('Bundesland').first);
    await tester.pumpAndSettle();
    expect(lp.filterCategory, QuestionCategory.bundesland);
    expect(lp.filteredQuestions.length, 160);

    // Chip "Allgemein" tippen
    await tester.tap(find.text('Allgemein').first);
    await tester.pumpAndSettle();
    expect(lp.filterCategory, QuestionCategory.allgemein);
    expect(lp.filteredQuestions.length, 300);

    // Chip "Alle" tippen
    await tester.tap(find.text('Alle').first);
    await tester.pumpAndSettle();
    expect(lp.filterCategory, isNull);
    expect(lp.filteredQuestions.length, 460);
  });

  testWidgets('Bundesland-Picker (Dropdown) filtert auf ein Land', (tester) async {
    final lp = LearningProvider();
    final sp = SettingsProvider();
    await loadProviders(tester, lp, sp);

    await tester.pumpWidget(buildApp(lp, sp));
    await tester.pumpAndSettle();

    // Erst Kategorie Bundesland aktivieren (zeigt die State-Leiste)
    await tester.tap(find.text('Bundesland').first);
    await tester.pumpAndSettle();

    // Dropdown-Trigger "Alle Bundesländer" tippen -> MenuAnchor klappt auf
    await tester.tap(find.text('Alle Bundesländer').first);
    await tester.pumpAndSettle();

    // Das Menü listet die Bundesländer
    expect(find.text('Bayern'), findsWidgets);

    // Bayern auswählen
    await tester.tap(find.text('Bayern').last);
    await tester.pumpAndSettle();
    expect(lp.filterState, 'Bayern');
    expect(lp.filteredQuestions.length, 10);
    expect(lp.filteredQuestions.every((q) => q.state == 'Bayern'), true);
  });

  testWidgets('Sprachleiste schaltet Anzeige-Sprache', (tester) async {
    final lp = LearningProvider();
    final sp = SettingsProvider();
    await loadProviders(tester, lp, sp);

    await tester.pumpWidget(buildApp(lp, sp));
    await tester.pumpAndSettle();

    expect(lp.viewLanguage, 'de');
    await tester.tap(find.text('EN').first);
    await tester.pumpAndSettle();
    expect(lp.viewLanguage, 'en');
    await tester.tap(find.text('عربي').first);
    await tester.pumpAndSettle();
    expect(lp.viewLanguage, 'ar');
  });
}
