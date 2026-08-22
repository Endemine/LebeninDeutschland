// Regressionstest: Der Tap auf ein Lesezeichen muss die gemerkte Frage oeffnen.
//
// Frueher zeigte er auf die Route '/learning/detail', die der Navigator in
// main.dart nicht kennt -- der Nutzer landete kommentarlos auf der Startseite.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:einbuergerungstest/providers/learning_provider.dart';
import 'package:einbuergerungstest/screens/bookmarks_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tap auf Lesezeichen oeffnet den Lernmodus bei der Frage',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lp = LearningProvider();
    await tester.runAsync(lp.loadQuestions);

    // Eine Frage weit hinten merken, damit ein falscher Index auffiele.
    final target = lp.allQuestions[123];
    lp.toggleBookmark(target.id);

    final routes = <String>[];
    await tester.pumpWidget(
      ChangeNotifierProvider<LearningProvider>.value(
        value: lp,
        child: MaterialApp(
          home: const BookmarksScreen(),
          onGenerateRoute: (settings) {
            routes.add(settings.name ?? '');
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Lernmodus')),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(target.text.substring(0, 20)));
    await tester.pumpAndSettle();

    expect(routes, contains('/learning'),
        reason: 'muss in den Lernmodus fuehren, nicht auf eine tote Route');
    expect(lp.currentQuestion.id, target.id,
        reason: 'der Lernmodus muss bei der gemerkten Frage stehen');
  });
}
