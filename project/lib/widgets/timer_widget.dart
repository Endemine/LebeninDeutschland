import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Countdown-Timer fuer das Quiz.
///
/// Zeigt die verbleibende Zeit im MM:SS Format an.
/// Wechselt bei < 5 Minuten auf Warnfarbe (Orange)
/// und bei < 1 Minute auf kritisch (Rot) mit Puls-Animation.
class TimerWidget extends StatefulWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final VoidCallback? onTimeUp;

  const TimerWidget({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.onTimeUp,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _warning = Color(0xFFFF9500);
  static const Color _critical = Color(0xFFFF3B30);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.remainingSeconds < 60) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remainingSeconds < 60 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.remainingSeconds >= 60 && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (widget.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (widget.remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color get _timerColor {
    if (widget.remainingSeconds < 60) return _critical;
    if (widget.remainingSeconds < 300) return _warning;
    return _textPrimary;
  }

  IconData get _timerIcon {
    if (widget.remainingSeconds < 60) return Icons.timer_off;
    if (widget.remainingSeconds < 300) return Icons.timer;
    return Icons.timer_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final isCritical = widget.remainingSeconds < 60;
        final scale = isCritical ? 1.0 + (_pulseController.value * 0.05) : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _timerColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _timerColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _timerIcon,
                  size: 18,
                  color: _timerColor,
                ),
                const SizedBox(width: 6),
                Text(
                  _formattedTime,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _timerColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
