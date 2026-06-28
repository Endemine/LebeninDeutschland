import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/timer_widget.dart';
import '../widgets/app_button.dart';

/// Haupt-Quiz-Interface.
///
/// Zeigt Fragen mit Timer, Fortschrittsbalken, Navigation
/// und einem Fragen-Grid fuer schnelles Springen.
///
/// Der Quiz-Zustand wird vollständig durch [QuizProvider] verwaltet.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);
  bool _isFinishing = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();

    // Aktuelle Frage aus dem Provider
    final currentQ = provider.currentQuestion;

    return PopScope(
      canPop: !provider.isRunning,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed(provider);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar: Timer und Fortschritt
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TimerWidget(
                      totalSeconds: 3600,
                      remainingSeconds: provider.remainingSeconds,
                      onTimeUp: () => _finishQuiz(
                        provider,
                        autoMessage:
                            'Die Zeit ist abgelaufen. Ergebnis wird jetzt angezeigt.',
                        isCriticalMessage: true,
                      ),
                    ),
                    Text(
                      'Frage ${provider.currentIndex + 1} von ${provider.totalQuestions}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            // Linearer Fortschrittsbalken
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (provider.currentIndex + 1) / provider.totalQuestions,
                  minHeight: 4,
                  backgroundColor: _surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Frage-Bereich
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: QuestionCard(
                  questionNumber: provider.currentIndex + 1,
                  totalQuestions: provider.totalQuestions,
                  questionText: currentQ.text,
                  answers: currentQ.answers,
                  answerImages: currentQ.answerImages,
                  selectedAnswer: provider.currentAnswer,
                  correctAnswer: currentQ.correctAnswerIndex,
                  category: currentQ.category.name,
                  onAnswerSelected: (index) =>
                      _onAnswerSelected(provider, index),
                ),
              ),
            ),

            // Fragen-Grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: _surface, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Navigation: Zurueck / Weiter
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Zurueck',
                          isOutlined: true,
                          isSmall: true,
                          onPressed: provider.currentIndex > 0
                              ? () => provider.previousQuestion()
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (provider.currentIndex < provider.totalQuestions - 1)
                        Expanded(
                          child: AppButton(
                            label: 'Weiter',
                            isSmall: true,
                            onPressed: () => provider.nextQuestion(),
                          ),
                        )
                      else
                        Expanded(
                          child: AppButton(
                            label: provider.unansweredCount == 0
                                ? 'Ergebnis anzeigen'
                                : 'Test beenden',
                            isSmall: true,
                            icon: provider.unansweredCount == 0
                                ? Icons.assignment_turned_in
                                : Icons.check,
                            onPressed: provider.unansweredCount == 0
                                ? () => _finishQuiz(provider)
                                : () => _showFinishDialog(provider),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Fragen-Kreise
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.totalQuestions,
                      itemBuilder: (context, index) {
                        final isAnswered =
                            provider.isQuestionAnswered(index);
                        final isCurrent = index == provider.currentIndex;

                        return GestureDetector(
                          onTap: () => provider.goToQuestion(index),
                          child: Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? _success
                                  : isAnswered
                                      ? _primary
                                      : _surface,
                              shape: BoxShape.circle,
                              border: isCurrent
                                  ? Border.all(color: _success, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrent || isAnswered
                                      ? Colors.white
                                      : _textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBackPressed(QuizProvider provider) {
    if (!_isFinishing && provider.isRunning) {
      _showExitDialog(provider).then((shouldFinish) {
        if (shouldFinish == true) {
          _finishQuiz(
            provider,
            autoMessage: 'Test abgebrochen. Ergebnis wird jetzt angezeigt.',
            isCriticalMessage: false,
          );
        }
      });
    }
  }

  void _finishQuiz(
    QuizProvider provider, {
    String? autoMessage,
    bool isCriticalMessage = false,
  }) {
    final existingResult = provider.lastResult;
    final shouldRun = provider.isRunning || existingResult != null;

    if (!shouldRun || _isFinishing) return;
    _isFinishing = true;

    if (provider.isRunning) {
      provider.finishQuiz();
    }

    final result = provider.lastResult ?? existingResult;
    if (result != null) {
      context.read<StatisticsProvider>().addQuizResult(result);
    }

    if (autoMessage == null) {
      Navigator.pushReplacementNamed(context, '/quiz/result');
      return;
    }

    _showAutoFinishHint(
      message: autoMessage,
      isCritical: isCriticalMessage,
    );
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted || !_isFinishing) return;
      Navigator.pushReplacementNamed(context, '/quiz/result');
    });
  }

  void _onAnswerSelected(QuizProvider provider, int index) {
    provider.answerQuestion(index);

    if (!provider.isRunning) return;

    if (provider.currentIndex == provider.totalQuestions - 1 &&
        provider.unansweredCount == 0) {
      _showAutoFinishHint();
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted && !_isFinishing && provider.isRunning) {
          _finishQuiz(provider);
        }
      });
    }
  }

  void _showAutoFinishHint({
    String message = 'Letzte Frage beantwortet — Ergebnis wird angezeigt.',
    bool isCritical = false,
  }) {
    if (!mounted) return;

    if (isCritical) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    } else {
      HapticFeedback.selectionClick();
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: isCritical
              ? const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
              : null,
        ),
        backgroundColor: isCritical ? _error : null,
        duration: Duration(milliseconds: isCritical ? 900 : 350),
      ),
    );
  }

  Future<bool> _showExitDialog(QuizProvider provider) async {
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Test beenden?',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        content: Text(
          'Wenn du den Test jetzt beendest, wird der aktuelle Stand als Ergebnis gespeichert.',
          style: GoogleFonts.roboto(
            fontSize: 15,
            color: _textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Weiter machen',
              style: GoogleFonts.roboto(
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Beenden',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return shouldFinish == true;
  }

  void _showFinishDialog(QuizProvider provider) {
    final unanswered = provider.unansweredCount;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Test beenden?',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        content: Text(
          '$unanswered Fragen noch nicht beantwortet. Bist du sicher, dass du den Test beenden moechtest?',
          style: GoogleFonts.roboto(
            fontSize: 15,
            color: _textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Weiter machen',
              style: GoogleFonts.roboto(
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishQuiz(provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Beenden',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
