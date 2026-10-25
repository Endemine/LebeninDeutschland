// Prüfungsergebnis: Bei falschen Fragen steht neben der richtigen Antwort
// auch die selbst gewählte Antwort.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:einbuergerungstest/providers/learning_provider.dart';
import 'package:einbuergerungstest/providers/quiz_provider.dart';
import 'package:einbuergerungstest/screens/quiz_result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Falsche Frage zeigt Deine Antwort und Richtige Antwort', (tester) async {
    late QuizProvider qp;
    late String wrongText;
    late String rightText;
    await tester.runAsync(() async {
      final lp = LearningProvider();
      await lp.loadQuestions();
      qp = QuizProvider();
      qp.startQuiz(
        state: null,
        allQuestions: lp.allQuestions,
        generalQuestionCount: 3,
        stateQuestionCount: 0,
        timeLimitSeconds: 600,
      );
      final q = qp.state.questions[0];
      final wrong = (q.correctAnswerIndex + 1) % 4;
      wrongText = q.answers[wrong];
      rightText = q.answers[q.correctAnswerIndex];
      qp.goToQuestion(0);
      qp.answerQuestion(wrong);
      qp.goToQuestion(1);
      qp.answerQuestion(qp.state.questions[1].correctAnswerIndex);
      qp.finishQuiz();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<QuizProvider>.value(
        value: qp,
        child: ChangeNotifierProvider<LearningProvider>(
          create: (_) => LearningProvider(),
          child: const MaterialApp(home: QuizResultScreen()),
        ),
      ),
    );
    await tester.pump();

    // Erste (falsch beantwortete) Frage aufklappen
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Deine Antwort: $wrongText'), findsOneWidget);
    expect(find.text('Richtige Antwort: $rightText'), findsOneWidget);
  });
}
