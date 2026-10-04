// Themen-Filter, "Falsche Fragen", Schnelltest nach Thema, Zurücksetzen, Vorlese-Text.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:einbuergerungstest/models/question.dart';
import 'package:einbuergerungstest/providers/learning_provider.dart';
import 'package:einbuergerungstest/providers/quiz_provider.dart';
import 'package:einbuergerungstest/utils/question_text.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<LearningProvider> load() async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    return lp;
  }

  test('Themen-Filter: 4 Themen, Zahlen stimmen, Bundesland löscht das Thema', () async {
    final lp = await load();
    final counts = {'Staat & Demokratie': 150, 'Geschichte': 70, 'Europa': 20, 'Alltag & Gesellschaft': 60};
    for (final t in LearningProvider.topics) {
      lp.setTopicFilter(t);
      expect(lp.filteredQuestions.length, counts[t], reason: t);
      expect(lp.filteredQuestions.every((q) => q.topic == t && !q.isStateSpecific), true);
    }
    lp.setCategoryFilter(QuestionCategory.bundesland);
    expect(lp.filterTopic, isNull);
    expect(lp.filteredQuestions.length, 160);
  });

  test('Falsche Fragen: aufnehmen, Momentaufnahme, entfernen, speichern', () async {
    final lp = await load();
    lp.recordAnswer(5, false);
    lp.recordAnswer(9, false);
    expect(lp.wrongCount, 2);

    lp.setWrongOnly(true);
    expect(lp.filteredQuestions.map((q) => q.id).toSet(), {5, 9});

    // richtig beantwortet: Zähler sinkt, Frage bleibt aber in der laufenden Liste
    lp.recordAnswer(5, true);
    expect(lp.wrongCount, 1);
    expect(lp.filteredQuestions.map((q) => q.id).toSet(), {5, 9});

    // neu einschalten: aktualisierte Liste
    lp.setWrongOnly(false);
    lp.setWrongOnly(true);
    expect(lp.filteredQuestions.map((q) => q.id).toList(), [9]);
    await settle();

    final again = await load();
    expect(again.wrongCount, 1);
  });

  test('Testergebnis: falsch rein, richtig raus, Unbeantwortetes bleibt unberührt', () async {
    final lp = await load();
    lp.recordAnswer(1, false);
    lp.recordAnswer(2, false);
    lp.recordQuizAnswers([const MapEntry(1, true), const MapEntry(3, false)]);
    lp.setWrongOnly(true);
    expect(lp.filteredQuestions.map((q) => q.id).toSet(), {2, 3});
  });

  test('Schnelltest nach Thema liefert nur Fragen dieses Themas', () async {
    final lp = await load();
    final qp = QuizProvider();
    qp.startQuiz(
      state: null,
      allQuestions: lp.allQuestions,
      generalQuestionCount: 10,
      stateQuestionCount: 0,
      timeLimitSeconds: 900,
      topic: 'Europa',
    );
    expect(qp.totalQuestions, 10);
    expect(qp.state.questions.every((q) => q.topic == 'Europa'), true);
    qp.reset();
  });

  test('Zurücksetzen löscht falsche Fragen und gemerkte Position', () async {
    final lp = await load();
    lp.recordAnswer(7, false);
    lp.goToQuestion(100);
    await settle();
    await lp.clearLearnedProgress();
    expect(lp.wrongCount, 0);

    final again = await load();
    expect(again.currentIndex, 0);
    expect(again.wrongCount, 0);
  });

  test('Vorlese- und Kopiertext enthalten Frage und alle Antworten', () async {
    final lp = await load();
    final q = lp.allQuestions.first;
    final speech = formatQuestionForSpeech(q);
    expect(speech, contains(q.text));
    expect(speech, contains('A. ${q.answers[0]}.'));
    expect(speech, contains('D. ${q.answers[3]}.'));
    expect(formatQuestionForCopy(q), contains('C) ${q.answers[2]}'));
  });
}
