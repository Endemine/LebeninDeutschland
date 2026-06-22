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

  Future<Widget> buildApp(LearningProvider lp, SettingsProvider sp) async {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LearningProvider>.value(value: lp),
        ChangeNotifierProvider<SettingsProvider>.value(value: sp),
      ],
      child: const MaterialApp(home: LearningScreen()),
    );
  }

  testWidgets('Kategorie-Chips filtern Fragen', (tester) async {
    final lp = LearningProvider();
    final sp = SettingsProvider();
    await lp.loadQuestions();
    await sp.loadSettings();
    expect(lp.filteredQuestions.length, 460);

    await tester.pumpWidget(await buildApp(lp, sp));
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

  testWidgets('Bundesland-Picker (Bottom-Sheet) filtert auf ein Land', (tester) async {
    final lp = LearningProvider();
    final sp = SettingsProvider();
    await lp.loadQuestions();
    await sp.loadSettings();

    await tester.pumpWidget(await buildApp(lp, sp));
    await tester.pumpAndSettle();

    // Erst Kategorie Bundesland aktivieren (zeigt die State-Leiste)
    await tester.tap(find.text('Bundesland').first);
    await tester.pumpAndSettle();

    // State-Leiste "Alle Bundesländer" tippen -> Bottom-Sheet öffnet
    await tester.tap(find.text('Alle Bundesländer').first);
    await tester.pumpAndSettle();

    // Bottom-Sheet zeigt Überschrift + Länder
    expect(find.text('Bundesland wählen'), findsOneWidget);
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
    await lp.loadQuestions();
    await sp.loadSettings();

    await tester.pumpWidget(await buildApp(lp, sp));
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
