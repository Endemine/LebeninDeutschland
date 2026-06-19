import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../widgets/result_summary.dart';
import '../widgets/app_button.dart';

/// Screen zur Anzeige der Quiz-Ergebnisse.
///
/// Zeigt Bestanden/Nicht bestanden Status, Score-Details
/// und eine Liste aller Fragen mit richtig/falsch Indikatoren.
/// Bezieht die Daten aus [QuizProvider.lastResult].
class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final result = quizProvider.lastResult;

    // Kein Ergebnis verfuegbar
    if (result == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: _textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'Kein Ergebnis verfügbar',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Starte ein Quiz um dein Ergebnis zu sehen.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: _textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Zur Startseite',
                    isFullWidth: true,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header mit Back-Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      ),
                      icon: const Icon(Icons.close, color: _textPrimary),
                    ),
                  ],
                ),
              ),
            ),

            // ResultSummary Widget
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ResultSummary(
                  correctAnswers: result.correctAnswers,
                  totalQuestions: result.totalQuestions,
                  wrongAnswers: result.wrongAnswers,
                  unanswered: result.unanswered,
                  elapsedTime: Duration(seconds: result.durationSeconds),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Detail-Liste
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Fragen im Detail',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${result.questionAnswers.length} angezeigt',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Fragen-Liste
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final qa = result.questionAnswers[index];
                  return _QuestionResultTile(
                    index: index + 1,
                    question: qa.question.text,
                    isCorrect: qa.isCorrect,
                    isAnswered: qa.isAnswered,
                    userAnswerText: qa.userAnswerText,
                    correctAnswer: qa.question.correctAnswer,
                  );
                ],
                childCount: result.questionAnswers.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Aktionen
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Nochmal versuchen',
                      isFullWidth: true,
                      icon: Icons.refresh,
                      onPressed: () {
                        quizProvider.reset();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/quiz',
                          (route) => false,
                        );
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Zurück zur Startseite',
                      isFullWidth: true,
                      isOutlined: true,
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Ergebnis teilen',
                      isFullWidth: true,
                      isOutlined: true,
                      icon: Icons.share,
                      onPressed: () {
                        // TODO: Share-Funktionalitaet
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

/// Einzelne Frage-Ergebnis-Kachel.
class _QuestionResultTile extends StatefulWidget {
  final int index;
  final String question;
  final bool isCorrect;
  final bool isAnswered;
  final String userAnswerText;
  final String correctAnswer;

  const _QuestionResultTile({
    required this.index,
    required this.question,
    required this.isCorrect,
    required this.isAnswered,
    required this.userAnswerText,
    required this.correctAnswer,
  });

  @override
  State<_QuestionResultTile> createState() => _QuestionResultTileState();
}

class _QuestionResultTileState extends State<_QuestionResultTile> {
  bool _expanded = false;

  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);

  String get _status {
    if (!widget.isAnswered) return 'unanswered';
    return widget.isCorrect ? 'correct' : 'wrong';
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'correct':
        return Icons.check_circle;
      case 'wrong':
        return Icons.cancel;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  Color get _statusColor {
    switch (_status) {
      case 'correct':
        return _success;
      case 'wrong':
        return _error;
      default:
        return _textTertiary;
    }
  }

  String get _answerDetailText {
    if (!widget.isAnswered) {
      return 'Richtige Antwort: ${widget.correctAnswer}';
    }
    if (widget.isCorrect) {
      return 'Deine Antwort: ${widget.userAnswerText} ✓';
    }
    return 'Deine Antwort: ${widget.userAnswerText} ✗ — Richtig: ${widget.correctAnswer}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _statusColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _statusIcon,
                        color: _statusColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${widget.index}. ${widget.question}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                      maxLines: _expanded ? null : 1,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: _textTertiary,
                    size: 20,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.isCorrect ? Icons.check_circle : Icons.info_outline,
                        color: widget.isCorrect ? _success : _textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _answerDetailText,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
