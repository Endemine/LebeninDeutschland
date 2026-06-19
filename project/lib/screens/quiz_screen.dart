import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/question_card.dart';
import '../widgets/timer_widget.dart';
import '../widgets/app_button.dart';

/// Haupt-Quiz-Interface.
///
/// Zeigt Fragen mit Timer, Fortschrittsbalken, Navigation
/// und einem Fragen-Grid fuer schnelles Springen.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  final int _totalQuestions = 33;
  final int _timeInSeconds = 60 * 60; // 60 Minuten
  int _remainingSeconds = 60 * 60;
  Timer? _timer;

  // Demo-Fragen
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Was ist die Hauptstadt von Deutschland?',
      'answers': ['Muenchen', 'Hamburg', 'Berlin', 'Koeln'],
      'correct': 2,
      'category': 'Staat',
    },
    {
      'question': 'Wie viele Bundeslaender hat die Bundesrepublik Deutschland?',
      'answers': ['14', '15', '16', '17'],
      'correct': 2,
      'category': 'Staat',
    },
    {
      'question': 'Welches ist das groesste Bundesland Deutschlands?',
      'answers': ['Bayern', 'Niedersachsen', 'Nordrhein-Westfalen', 'Baden-Wuerttemberg'],
      'correct': 0,
      'category': 'Staat',
    },
  ];

  // Antworten des Nutzers (null = nicht beantwortet)
  final List<int?> _userAnswers = List.filled(33, null);

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _finishQuiz();
        }
      });
    });
  }

  void _finishQuiz() {
    _timer?.cancel();
    Navigator.pushReplacementNamed(context, '/quiz/result');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToQuestion(int index) {
    if (index >= 0 && index < _totalQuestions) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _userAnswers[_currentIndex] = answerIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Aktuelle Frage
    final currentQ = _questions[_currentIndex % _questions.length];

    return Scaffold(
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
                    totalSeconds: _timeInSeconds,
                    remainingSeconds: _remainingSeconds,
                    onTimeUp: _finishQuiz,
                  ),
                  Text(
                    'Frage ${_currentIndex + 1} von $_totalQuestions',
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
                  value: (_currentIndex + 1) / _totalQuestions,
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
                  questionNumber: _currentIndex + 1,
                  totalQuestions: _totalQuestions,
                  questionText: currentQ['question'],
                  answers: List<String>.from(currentQ['answers']),
                  selectedAnswer: _userAnswers[_currentIndex],
                  correctAnswer: currentQ['correct'],
                  category: currentQ['category'],
                  onAnswerSelected: _selectAnswer,
                ),
              ),
            ),

            // Fragen-Grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
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
                          onPressed: _currentIndex > 0
                              ? () => _goToQuestion(_currentIndex - 1)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_currentIndex < _totalQuestions - 1)
                        Expanded(
                          child: AppButton(
                            label: 'Weiter',
                            isSmall: true,
                            onPressed: () => _goToQuestion(_currentIndex + 1),
                          ),
                        )
                      else
                        Expanded(
                          child: AppButton(
                            label: 'Test beenden',
                            isSmall: true,
                            icon: Icons.check,
                            onPressed: () => _showFinishDialog(),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 33 kleine Kreise
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _totalQuestions,
                      itemBuilder: (context, index) {
                        final isAnswered = _userAnswers[index] != null;
                        final isCurrent = index == _currentIndex;

                        return GestureDetector(
                          onTap: () => _goToQuestion(index),
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
    );
  }

  void _showFinishDialog() {
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
          'Du hast ${_userAnswers.where((a) => a == null).length} Fragen noch nicht beantwortet. Bist du sicher, dass du den Test beenden moechtest?',
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
              _finishQuiz();
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
