import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// Animierte Kreis-Fortschrittsanzeige fuer den Home-Screen.
///
/// Zeigt den Lernfortschritt als Prozentwert in der Mitte des Rings.
class ProgressRing extends StatelessWidget {
  final double percent;
  final String centerText;
  final String? subtitle;
  final double radius;
  final double lineWidth;
  final Color progressColor;
  final Color backgroundColor;
  final Duration animationDuration;

  const ProgressRing({
    super.key,
    required this.percent,
    required this.centerText,
    this.subtitle,
    this.radius = 80,
    this.lineWidth = 8,
    this.progressColor = const Color(0xFFFF6B00),
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: radius,
          lineWidth: lineWidth,
          percent: percent.clamp(0.0, 1.0),
          center: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerText,
                style: GoogleFonts.roboto(
                  fontSize: radius * 0.35,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.roboto(
                    fontSize: radius * 0.15,
                    fontWeight: FontWeight.w400,
                    color: _textSecondary,
                  ),
                ),
            ],
          ),
          progressColor: progressColor,
          backgroundColor: backgroundColor,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: animationDuration.inMilliseconds,
          curve: Curves.easeOutCubic,
        ),
      ],
    );
  }
}
