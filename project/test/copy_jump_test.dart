// Tippt Kopieren-Button und "Springen" im Lernmodus wirklich an.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:einbuergerungstest/providers/learning_provider.dart';
import 'package:einbuergerungstest/providers/settings_provider.dart';
import 'package:einbuergerungstest/screens/learning_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<LearningProvider> pump(WidgetTester tester) async {
    final lp = LearningProvider();
    final sp = SettingsProvider();
    await tester.runAsync(() async {
      await lp.loadQuestions();
      await sp.loadSettings();
    });
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<LearningProvider>.value(value: lp),
        ChangeNotifierProvider<SettingsProvider>.value(value: sp),
      ],
      child: const MaterialApp(home: LearningScreen()),
    ));
    await tester.pumpAndSettle();
    return lp;
  }

  testWidgets('Kopieren-Button legt Frage und Antworten in die Zwischenablage', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    final lp = await pump(tester);
    final q = lp.filteredQuestions[lp.currentIndex];

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();

    expect(copied, isNotNull);
    expect(copied, startsWith(q.text));
    expect(copied, contains('\nA) ${q.answers[0]}'));
    expect(copied, contains('\nD) ${q.answers[3]}'));
    expect(find.text('Frage kopiert'), findsOneWidget);
  });

  testWidgets('Springen: Nummer eingeben öffnet genau diese Frage mit Bild', (tester) async {
    final lp = await pump(tester);

    await tester.tap(find.text(' Springen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '55');
    await tester.tap(find.text('Springen').last);
    await tester.pumpAndSettle();

    expect(lp.filteredQuestions[lp.currentIndex].id, 55);
    expect(find.text('Was zeigt dieses Bild?'), findsOneWidget);
    expect(find.text('© Deutscher Bundestag/Achim Melde'), findsOneWidget);
  });

  testWidgets('Springen: ungültige Nummer wird ignoriert', (tester) async {
    final lp = await pump(tester);
    await tester.tap(find.text(' Springen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '999');
    await tester.tap(find.text('Springen').last);
    await tester.pumpAndSettle();
    expect(lp.currentIndex, 0);
  });
}
