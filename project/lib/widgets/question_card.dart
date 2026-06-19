import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_card.dart';

/// Darstellung einer Frage mit 4 Antwort-Buttons.
///
/// Unterstuetzt Auswahl-Feedback im Quiz-Modus und
/// farbliche Markierung richtiger/falscher Antworten im Lernmodus.
class QuestionCard extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final String questionText;
  final List<String> answers;
  final int? selectedAnswer;
  final int? correctAnswer;
  final bool showCorrectAnswer;
  final Function(int)? onAnswerSelected;
  final String? category;
  final String? imageUrl;

  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.questionText,
    required this.answers,
    this.selectedAnswer,
    this.correctAnswer,
    this.showCorrectAnswer = false,
    this.onAnswerSelected,
    this.category,
    this.imageUrl,
  });

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _border = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fragenummer und Kategorie
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frage $questionNumber von $totalQuestions',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _textTertiary,
              ),
            ),
            if (category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category!,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Fragetext
        Text(
          questionText,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        // Bild (falls vorhanden)
        if (imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 20),
        ],
        // Antwort-Buttons
        ...List.generate(answers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AnswerButton(
              label: answers[index],
              index: index,
              isSelected: selectedAnswer == index,
              isCorrect: showCorrectAnswer && correctAnswer == index,
              isWrong: showCorrectAnswer &&
                  selectedAnswer == index &&
                  selectedAnswer != correctAnswer,
              showResult: showCorrectAnswer,
              onTap: onAnswerSelected != null ? () => onAnswerSelected!(index) : null,
            ),
          );
        }),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool showResult;
  final VoidCallback? onTap;

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _border = Color(0xFFE5E5EA);

  const _AnswerButton({
    required this.label,
    required this.index,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.showResult = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Bestimme die Farben basierend auf dem Zustand
    Color backgroundColor = _surface;
    Color borderColor = _border;
    Color textColor = _textPrimary;
    Widget? trailing;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = _success.withOpacity(0.1);
        borderColor = _success;
        textColor = _success;
        trailing = const Icon(Icons.check_circle, color: _success, size: 22);
      } else if (isWrong) {
        backgroundColor = _error.withOpacity(0.1);
        borderColor = _error;
        textColor = _error;
        trailing = const Icon(Icons.cancel, color: _error, size: 22);
      } else if (isSelected) {
        backgroundColor = _primary.withOpacity(0.05);
        borderColor = _primary;
      }
    } else if (isSelected) {
      backgroundColor = _primary.withOpacity(0.08);
      borderColor = _primary;
      textColor = _primary;
      trailing = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.check,
          size: 12,
          color: Colors.white,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected || isCorrect || isWrong ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Buchstabe A, B, C, D
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected || isCorrect || isWrong
                    ? borderColor.withOpacity(0.15)
                    : _surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected || isCorrect || isWrong ? borderColor : _textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Antworttext
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
            // Trailing Icon
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
