import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/learning_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/app_button.dart';

/// Lernmodus-Screen — Quiz-ähnlich: eine Frage nach der anderen.
///
/// Zeigt eine einzelne Frage mit 4 Antwort-Buttons. Nach Tippen auf eine
/// Antwort wird sofort gezeigt ob es richtig oder falsch war (showCorrectAnswer).
/// Navigation vor/zurück, Kategorie-Filter + Suche in einer kompakten Leiste,
/// plus Fortschrittsanzeige und Bookmark/Learned-Status.
class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  /// Zeigt die Such-/Filterleiste oder nicht
  bool _showFilters = false;

  /// Lokaler Search-Controller (damit Suchtext erhalten bleibt)
  final TextEditingController _searchController = TextEditingController();

  /// Map: questionId -> selectedAnswerIndex (behält Antwort über Navigation)
  final Map<int, int> _selectedAnswers = {};

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final filtered = learning.filteredQuestions;

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
          'Lernen',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        actions: [
          // Filter-Toggle
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: _showFilters ? _primary : _textSecondary,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: filtered.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // === Kompakte Fortschrittsanzeige ===
                _buildProgressBar(learning),

                // === Filter-Leiste (toggle) ===
                if (_showFilters) _buildFilterBar(learning),

                // === Buchmark-Status ===
                _buildQuestionMeta(context, learning, filtered),

                // === Frage + Antworten ===
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildQuestionCard(context, learning, filtered),
                  ),
                ),

                // === Navigation ===
                _buildNavigation(context, learning, filtered),
              ],
            ),
    );
  }

  Widget _buildProgressBar(LearningProvider learning) {
    final total = learning.totalQuestionCount;
    final learned = learning.learnedCount;
    final progress = total > 0 ? learned / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: _surface,
                valueColor: const AlwaysStoppedAnimation<Color>(_primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$learned / $total',
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(LearningProvider learning) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          // Suchfeld
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _searchController,
                onChanged: (v) => learning.setSearchQuery(v),
                decoration: InputDecoration(
                  hintText: 'Suchen...',
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 13, color: _textSecondary,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 18, color: _textSecondary),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: _surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Kategorie-Dropdown
          Expanded(
            flex: 2,
            child: _CategoryDropdown(
              learning: learning,
              primary: _primary,
              textPrimary: _textPrimary,
              textSecondary: _textSecondary,
              surface: _surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionMeta(
    BuildContext context,
    LearningProvider learning,
    List<Question> filtered,
  ) {
    final q = filtered[learning.currentIndex.clamp(0, filtered.length - 1)];
    final isBookmarked = learning.isBookmarked(q.id);
    final isLearned = learning.isLearned(q.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${learning.currentIndex + 1} / ${filtered.length} · ${q.category.displayName}',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
          ),
          // Gelernt-Toggle
          GestureDetector(
            onTap: () => learning.toggleLearned(q.id),
            child: Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: isLearned ? _success.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isLearned ? Icons.check_circle : Icons.check_circle_outline,
                color: isLearned ? _success : _textTertiary,
                size: 20,
              ),
            ),
          ),
          // Bookmark-Toggle
          GestureDetector(
            onTap: () => learning.toggleBookmark(q.id),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isBookmarked ? _primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? _primary : _textTertiary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    LearningProvider learning,
    List<Question> filtered,
  ) {
    final q = filtered[learning.currentIndex.clamp(0, filtered.length - 1)];

    return QuestionCard(
      questionNumber: learning.currentIndex + 1,
      totalQuestions: filtered.length,
      questionText: q.text,
      answers: q.answers,
      selectedAnswer: _selectedAnswers[q.id],
      correctAnswer: q.correctAnswerIndex,
      showCorrectAnswer: _selectedAnswers.containsKey(q.id),
      category: q.category.displayName,
      onAnswerSelected: (index) {
        setState(() {
          _selectedAnswers[q.id] = index;
        });
      },
    );
  }

  Widget _buildNavigation(
    BuildContext context,
    LearningProvider learning,
    List<Question> filtered,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _surface, width: 1)),
      ),
      child: Row(
        children: [
          // Zurück
          Expanded(
            child: AppButton(
              label: 'Zurück',
              isOutlined: true,
              isSmall: true,
              onPressed: learning.currentIndex > 0
                  ? () => learning.previousQuestion()
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Weiter / Zufall
          Expanded(
            child: AppButton(
              label: learning.currentIndex < filtered.length - 1
                  ? 'Weiter'
                  : '🔁 Zufall',
              isSmall: true,
              onPressed: () {
                if (learning.currentIndex < filtered.length - 1) {
                  learning.nextQuestion();
                } else {
                  learning.goToRandomQuestion();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: _textTertiary),
          const SizedBox(height: 16),
          Text(
            'Keine Fragen gefunden',
            style: GoogleFonts.roboto(
              fontSize: 16, fontWeight: FontWeight.w600, color: _textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Versuche es mit einer anderen Suche',
            style: GoogleFonts.roboto(fontSize: 13, color: _textTertiary),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Filter zurücksetzen',
            isOutlined: true,
            isSmall: true,
            onPressed: () {
              context.read<LearningProvider>().clearAllFilters();
              _searchController.clear();
            },
          ),
        ],
      ),
    );
  }
}

/// Kategorie-Dropdown
class _CategoryDropdown extends StatelessWidget {
  final LearningProvider learning;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;

  const _CategoryDropdown({
    required this.learning,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
  });

  String _currentLabel() {
    if (learning.filterCategory == null) return 'Alle';
    return learning.filterCategory!.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final items = <_CategoryItem>[
      const _CategoryItem(label: 'Alle', category: null),
      for (final cat in QuestionCategory.values)
        _CategoryItem(label: cat.displayName, category: cat),
    ];

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentLabel(),
          isDense: true,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF8E8E93), size: 18),
          style: GoogleFonts.roboto(
            fontSize: 12, color: const Color(0xFF1A1A1A),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item.label,
              child: Text(item.label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) {
            if (val == null) return;
            final matched = items.firstWhere(
              (i) => i.label == val,
              orElse: () => const _CategoryItem(label: 'Alle', category: null),
            );
            learning.setCategoryFilter(matched.category);
          },
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final QuestionCategory? category;
  const _CategoryItem({required this.label, required this.category});
}
