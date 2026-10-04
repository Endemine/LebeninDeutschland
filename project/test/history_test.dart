// Verlauf/Statistik: Ergebnisse werden gespeichert und nach "Neustart" korrekt geladen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:einbuergerungstest/models/question.dart';
import 'package:einbuergerungstest/providers/learning_provider.dart';
import 'package:einbuergerungstest/providers/quiz_provider.dart';
import 'package:einbuergerungstest/providers/statistics_provider.dart';
import 'package:einbuergerungstest/widgets/result_summary.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Schnelltest 6/10 gilt als bestanden und wird samt Details gespeichert', () async {
    final lp = LearningProvider();
    await lp.loadQuestions();
    final byId = {for (final q in lp.allQuestions) q.id: q};

    final qp = QuizProvider();
    qp.startQuiz(
      state: null,
      allQuestions: lp.allQuestions,
      generalQuestionCount: 10,
      stateQuestionCount: 0,
      timeLimitSeconds: 900,
    );
    for (var i = 0; i < 10; i++) {
      qp.goToQuestion(i);
      final correct = qp.state.questions[i].correctAnswerIndex;
      qp.answerQuestion(i < 6 ? correct : (correct + 1) % 4);
    }
    qp.finishQuiz();
    final result = qp.lastResult!;
    expect(result.correctAnswers, 6);
    expect(result.totalQuestions, 10);
    expect(result.passed, true);

    final sp = StatisticsProvider();
    await sp.addQuizResult(result);

    // "Neustart" mit Fragendetails: Kategorie-Auswertung bleibt erhalten
    final reloaded = StatisticsProvider();
    await reloaded.loadStatistics(questionsById: byId);
    expect(reloaded.recentResults.length, 1);
    final r = reloaded.recentResults.first;
    expect(r.correctAnswers, 6);
    expect(r.totalQuestions, 10);
    expect(r.isPassed, true);
    final cat = reloaded.categoryStats[QuestionCategory.allgemein]!;
    expect(cat.totalAsked, 10);
    expect(cat.totalCorrect, 6);

    // ohne Fragendetails bleibt wenigstens die Zusammenfassung
    final simple = StatisticsProvider();
    await simple.loadStatistics();
    expect(simple.recentResults.first.correctAnswers, 6);
    expect(simple.passedQuizzes, 1);
  });

  testWidgets('Ergebnis-Widget nennt die passende Bestehensgrenze', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ResultSummary(correctAnswers: 5, totalQuestions: 10, wrongAnswers: 5, unanswered: 0),
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Bestanden!'), findsOneWidget);
    expect(find.text('Benötigt: 5 / 10 zum Bestehen'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ResultSummary(correctAnswers: 16, totalQuestions: 33, wrongAnswers: 17, unanswered: 0),
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Nicht bestanden'), findsOneWidget);
    expect(find.text('Benötigt: 17 / 33 zum Bestehen'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
