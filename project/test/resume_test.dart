// Beweist: Lernposition und laufender Test überleben einen App-Neustart.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:einbuergerungstest/providers/learning_provider.dart';
import 'package:einbuergerungstest/providers/quiz_provider.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Lernmodus merkt sich die zuletzt angesehene Frage', () async {
    final first = LearningProvider();
    await first.loadQuestions();
    first.goToQuestion(54);
    final id = first.filteredQuestions[first.currentIndex].id;
    await settle();

    final second = LearningProvider();
    await second.loadQuestions();
    expect(second.filteredQuestions[second.currentIndex].id, id);
    expect(second.currentIndex, 54);
  });

  test('Laufender Test wird nach Neustart fortgesetzt', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();

    final a = QuizProvider();
    a.startQuiz(state: 'Bayern', allQuestions: lp.allQuestions);
    a.answerQuestion(2);
    a.nextQuestion();
    a.nextQuestion();
    a.answerQuestion(1);
    final ids = a.state.questions.map((q) => q.id).toList();
    await settle();
    a.reset();

    final b = QuizProvider();
    await b.loadSavedQuiz();
    expect(b.hasResumableQuiz, true);
    expect(b.resumableSummary, startsWith('Frage 3 von 33'));
    expect(b.resumeSavedQuiz(lp.allQuestions), true);
    expect(b.state.questions.map((q) => q.id).toList(), ids);
    expect(b.currentIndex, 2);
    expect(b.state.answers[0], 2);
    expect(b.state.answers[2], 1);
    expect(b.remainingSeconds, greaterThan(3590));
    b.reset();
  });

  test('Abgeschlossener Test wird nicht mehr zum Fortsetzen angeboten', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    final a = QuizProvider();
    a.startQuiz(state: null, allQuestions: lp.allQuestions);
    await settle();
    a.finishQuiz();
    await settle();

    final b = QuizProvider();
    await b.loadSavedQuiz();
    expect(b.hasResumableQuiz, false);
  });
}
