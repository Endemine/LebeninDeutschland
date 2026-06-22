// Beweist die Verdrahtung des Quiz-Setup-Flows:
// - startQuiz(state: null) -> 30 allgemeine Fragen
// - startQuiz(state: 'Bayern') -> 30 allgemeine + 3 Bayern = 33 Fragen
// - startQuiz(state: 'Ungültig') -> 30 allgemeine, keine BL-Fragen
// - Die Auswahl-Logik verteilt Fragen korrekt
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:einbuergerungstest/providers/learning_provider.dart';
import 'package:einbuergerungstest/providers/quiz_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<({LearningProvider lp, QuizProvider qp})> setup() async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    final qp = QuizProvider();
    return (lp: lp, qp: qp);
  }

  test('startQuiz ohne Bundesland: genau 30 allgemeine Fragen', () async {
    final s = await setup();
    s.qp.startQuiz(state: null, allQuestions: s.lp.allQuestions);
    expect(s.qp.totalQuestions, 30);
    expect(s.qp.state.questions.every((q) => !q.isStateSpecific), true);
  });

  test('startQuiz mit Bayern: 30 allgemeine + 3 Bayern = 33 Fragen', () async {
    final s = await setup();
    s.qp.startQuiz(state: 'Bayern', allQuestions: s.lp.allQuestions);
    expect(s.qp.totalQuestions, 33);
    final bavarian = s.qp.state.questions.where((q) => q.state == 'Bayern');
    expect(bavarian.length, 3);
  });

  test('startQuiz mit ungültigem Bundesland: Fallback auf 30 allgemeine', () async {
    final s = await setup();
    s.qp.startQuiz(state: 'Narnia', allQuestions: s.lp.allQuestions);
    expect(s.qp.totalQuestions, 30);
    expect(s.qp.state.questions.every((q) => !q.isStateSpecific), true);
  });

  test('startQuiz Niedersachsen: 3 NDS-Fragen dabei', () async {
    final s = await setup();
    s.qp.startQuiz(state: 'Niedersachsen', allQuestions: s.lp.allQuestions);
    expect(s.qp.totalQuestions, 33);
    final nds = s.qp.state.questions.where((q) => q.state == 'Niedersachsen');
    expect(nds.length, 3);
  });

  test('startQuiz wirft StateError bei leerer Fragenliste', () async {
    final qp = QuizProvider();
    expect(
      () => qp.startQuiz(state: null, allQuestions: const []),
      throwsA(isA<StateError>()),
    );
  });
}
