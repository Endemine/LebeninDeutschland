import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_card.dart';

/// Detail-Ansicht einer einzelnen Frage im Lernmodus.
///
/// Zeigt die Frage, Antwort-Buttons mit sofortigem Feedback,
/// Erklaerung und Navigation zu vorheriger/naechster Frage.
class LearningDetailScreen extends StatefulWidget {
  const LearningDetailScreen({super.key});

  @override
  State<LearningDetailScreen> createState() => _LearningDetailScreenState();
}

class _LearningDetailScreenState extends State<LearningDetailScreen> {
  int? _selectedAnswer;
  bool _showResult = false;
  bool _learned = false;
  bool _bookmarked = false;

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);

  // Demo-Daten
  final String _question = 'Was ist die Hauptstadt von Deutschland?';
  final List<String> _answers = [
    'Muenchen',
    'Hamburg',
    'Berlin',
    'Koeln',
  ];
  final int _correctAnswer = 2;
  final String _explanation =
      'Berlin ist seit der Wiedervereinigung 1990 die Hauptstadt Deutschlands. '
      'Vor der Wiedervereinigung war Bonn Hauptstadt der Bundesrepublik Deutschland.';
  final String _category = 'Staat';
  final int _currentIndex = 1;
  final int _totalQuestions = 300;

  void _selectAnswer(int index) {
    if (_showResult) return;
    setState(() {
      _selectedAnswer = index;
      _showResult = true;
    });
  }

  Color _getAnswerBgColor(int index) {
    if (!_showResult) {
      return _selectedAnswer == index
          ? _primary.withOpacity(0.08)
          : _surface;
    }
    if (index == _correctAnswer) {
      return _success.withOpacity(0.1);
    }
    if (index == _selectedAnswer && index != _correctAnswer) {
      return _error.withOpacity(0.1);
    }
    return _surface;
  }

  Color _getAnswerBorderColor(int index) {
    if (!_showResult) {
      return _selectedAnswer == index ? _primary : const Color(0xFFE5E5EA);
    }
    if (index == _correctAnswer) {
      return _success;
    }
    if (index == _selectedAnswer && index != _correctAnswer) {
      return _error;
    }
    return const Color(0xFFE5E5EA);
  }

  IconData? _getAnswerIcon(int index) {
    if (!_showResult) return null;
    if (index == _correctAnswer) return Icons.check_circle;
    if (index == _selectedAnswer && index != _correctAnswer) {
      return Icons.cancel;
    }
    return null;
  }

  Color? _getAnswerIconColor(int index) {
    if (!_showResult) return null;
    if (index == _correctAnswer) return _success;
    if (index == _selectedAnswer && index != _correctAnswer) return _error;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Frage $_currentIndex / $_totalQuestions',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          // Bookmark
          IconButton(
            onPressed: () {
              setState(() {
                _bookmarked = !_bookmarked;
              });
            },
            icon: Icon(
              _bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _bookmarked ? _primary : _textTertiary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Fortschrittsbalken
            LinearProgressIndicator(
              value: _currentIndex / _totalQuestions,
              minHeight: 3,
              backgroundColor: _surface,
              valueColor: const AlwaysStoppedAnimation<Color>(_primary),
            ),

            // Frage und Antworten
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategorie-Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _category,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fragetext
                    Text(
                      _question,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Antwort-Buttons
                    ...List.generate(_answers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => _selectAnswer(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: _getAnswerBgColor(index),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getAnswerBorderColor(index),
                                width: _selectedAnswer == index ||
                                        (_showResult &&
                                            (index == _correctAnswer ||
                                                index == _selectedAnswer))
                                    ? 2
                                    : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _getAnswerIconColor(index)
                                            ?.withOpacity(0.15) ??
                                        _surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: _getAnswerIcon(index) != null
                                        ? Icon(
                                            _getAnswerIcon(index),
                                            color: _getAnswerIconColor(index),
                                            size: 18,
                                          )
                                        : Text(
                                            String.fromCharCode(65 + index),
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: _textSecondary,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _answers[index],
                                    style: GoogleFonts.roboto(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: _showResult &&
                                              index == _correctAnswer
                                          ? _success
                                          : _showResult &&
                                                  index == _selectedAnswer
                                              ? _error
                                              : _textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // Erklaerung (nach Antwort)
                    if (_showResult) ...[
                      const SizedBox(height: 20),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFFFFF8F0),
                        borderColor: _primary.withOpacity(0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: _primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Erklaerung',
                                  style: GoogleFonts.roboto(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _explanation,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: _textSecondary,
                                height: 1.5,
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

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: _surface, width: 1),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vorherige / Naechste
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Vorherige Frage
                            },
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text('Vorherige'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _textSecondary,
                              side: const BorderSide(color: Color(0xFFE5E5EA)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Naechste Frage
                            },
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text('Naechste'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Als gelernt markieren
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _learned = !_learned;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _learned
                              ? _success.withOpacity(0.1)
                              : _surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _learned ? Icons.check_circle : Icons.check_circle_outline,
                              color: _learned ? _success : _textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _learned
                                  ? 'Als gelernt markiert'
                                  : 'Als gelernt markieren',
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _learned ? _success : _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
