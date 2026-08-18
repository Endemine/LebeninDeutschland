// Prueft, dass die Fragen-Uebersetzungen vollstaendig sind.
//
// Hintergrund: `Question.questionFor()` und `answersFor()` fallen still auf den
// deutschen Text zurueck, wenn eine Uebersetzung fehlt. Waehlt jemand im
// Lernmodus oder in den Einstellungen EN/AR, bekaeme er dann kommentarlos
// deutsche Fragen zu sehen. Dieser Test macht solche Luecken sichtbar.
//
// Die Fragen kommen ueber echte Async-I/O aus dem Asset-Bundle, deshalb
// `tester.runAsync` — ein direktes `await` wuerde in der FakeAsync-Zone haengen.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:einbuergerungstest/providers/learning_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Alle Fragen liegen auf EN und AR vor', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lp = LearningProvider();
    await tester.runAsync(lp.loadQuestions);

    expect(lp.allQuestions, hasLength(460));
    expect(lp.viewLanguage, 'de');

    final ohneEn = <int>[];
    final ohneAr = <int>[];
    for (final q in lp.allQuestions) {
      if (q.questionFor('en') == q.text || identical(q.answersFor('en'), q.answers)) {
        ohneEn.add(q.id);
      }
      if (q.questionFor('ar') == q.text || identical(q.answersFor('ar'), q.answers)) {
        ohneAr.add(q.id);
      }
    }

    expect(ohneEn, isEmpty, reason: 'Fragen ohne EN-Uebersetzung: $ohneEn');
    expect(ohneAr, isEmpty, reason: 'Fragen ohne AR-Uebersetzung: $ohneAr');
  });

  testWidgets('Anzeige-Sprache laesst sich auf DE/EN/AR schalten', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lp = LearningProvider();
    await tester.runAsync(lp.loadQuestions);

    for (final code in ['en', 'ar', 'de']) {
      lp.setViewLanguage(code);
      expect(lp.viewLanguage, code);
    }
  });
}
