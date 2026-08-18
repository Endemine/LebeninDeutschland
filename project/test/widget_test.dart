// Smoke-Test: Die App baut ohne Exception auf und zeigt den Ladebildschirm.
//
// Hinweis: Die eigentliche Initialisierung (_AppInitializer) lädt Assets und
// SharedPreferences über echte Async-I/O. In der FakeAsync-Zone von
// `testWidgets` werden diese Futures nie abgeschlossen, deshalb testet dieser
// Smoke-Test bewusst nur den Start bis zum Ladebildschirm. Die Screens dahinter
// sind in learning_screen_test.dart mit `tester.runAsync` abgedeckt.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:einbuergerungstest/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App startet ohne Exception und zeigt den Ladebildschirm',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await tester.runAsync(SharedPreferences.getInstance);

    await tester.pumpWidget(EinbuergerungApp(sharedPreferences: prefs!));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Einbuergerungstest'), findsOneWidget);
    expect(find.text('Deutschland'), findsOneWidget);
  });
}
