import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

/// Ergebnis-Zusammenfassung nach einem Quiz.
///
/// Zeigt eine grosse Animation (Bestanden = Confetti, Nicht bestanden = trauriges Icon),
/// den Score-Balken und Detailinformationen wie richtige, falsche und unbeantwortete Fragen.
class ResultSummary extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int wrongAnswers;
  final int unanswered;
  final Duration? elapsedTime;

  const ResultSummary({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.wrongAnswers,
    required this.unanswered,
    this.elapsedTime,
  });

  bool get isPassed => correctAnswers >= 17;
  double get percent => (correctAnswers / totalQuestions);

  @override
  State<ResultSummary> createState() => _ResultSummaryState();
}

class _ResultSummaryState extends State<ResultSummary>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _surface = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    // Starte Animationen
    Future.delayed(const Duration(milliseconds: 300), () {
      _animController.forward();
      if (widget.isPassed) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String get _timeText {
    if (widget.elapsedTime == null) return '';
    final minutes = widget.elapsedTime!.inMinutes;
    final seconds = widget.elapsedTime!.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            // Icon / Status
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: widget.isPassed
                      ? _success.withOpacity(0.1)
                      : _error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 56,
                  color: widget.isPassed ? _success : _error,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Status Text
            Text(
              widget.isPassed ? 'Bestanden!' : 'Nicht bestanden',
              style: GoogleFonts.roboto(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: widget.isPassed ? _success : _error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isPassed
                  ? 'Herzlichen Glueckwunsch!'
                  : 'Nicht aufgeben, ueben macht den Meister!',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Score Karte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // X/33 in gross
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${widget.correctAnswers}',
                          style: GoogleFonts.roboto(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: widget.isPassed ? _success : _error,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${widget.totalQuestions}',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Prozent
                  Text(
                    '${(widget.percent * 100).toStringAsFixed(0)}% richtig',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  if (widget.elapsedTime != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 16, color: _textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _timeText,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Score Balken
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: widget.percent.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isPassed ? _success : _error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Benotigt: 17 / ${widget.totalQuestions} zum Bestehen',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Details
            Row(
              children: [
                _DetailItem(
                  icon: Icons.check_circle,
                  color: _success,
                  label: 'Richtig',
                  value: '${widget.correctAnswers}',
                ),
                const SizedBox(width: 12),
                _DetailItem(
                  icon: Icons.cancel,
                  color: _error,
                  label: 'Falsch',
                  value: '${widget.wrongAnswers}',
                ),
                const SizedBox(width: 12),
                _DetailItem(
                  icon: Icons.help_outline,
                  color: _textSecondary,
                  label: 'Offen',
                  value: '${widget.unanswered}',
                ),
              ],
            ),
          ],
        ),
        // Confetti Overlay
        if (widget.isPassed)
          Positioned(
            top: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
              colors: const [
                _primary,
                _success,
                Colors.yellow,
                Colors.blue,
                Colors.purple,
              ],
            ),
          ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
