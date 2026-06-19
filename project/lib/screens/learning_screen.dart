import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/learning_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_card.dart';

/// Lernmodus-Screen.
///
/// Zeigt filterbare und durchsuchbare Fragen-Liste mit
/// Bookmarks und Lernfortschritt.
class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();

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
          'Lernmodus',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Fortschritt
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lernfortschritt',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        Text(
                          '${learning.learnedCount} / ${learning.totalQuestionCount} Fragen',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: learning.totalQuestionCount > 0
                            ? learning.learnedCount / learning.totalQuestionCount
                            : 0,
                        minHeight: 8,
                        backgroundColor: _surface,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter-Bar: Suchfeld + Kategorie-Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  // Suchfeld
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        onChanged: (value) =>
                            learning.setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: 'Suchen...',
                          hintStyle: GoogleFonts.roboto(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                          prefixIcon: const Icon(Icons.search,
                              color: _textSecondary, size: 20),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Kategorie-Dropdown
                  Expanded(
                    child: _CategoryDropdown(learning: learning),
                  ),
                ],
              ),
            ),

            // Fragen-Liste
            Expanded(
              child: learning.filteredQuestions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: learning.filteredQuestions.length,
                      itemBuilder: (context, index) {
                        final q = learning.filteredQuestions[index];
                        return _QuestionTile(
                          question: q,
                          isLearned: learning.isLearned(q.id),
                          isBookmarked: learning.isBookmarked(q.id),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/learning/detail',
                              arguments: {'questionId': q.id},
                            );
                          },
                          onBookmarkToggle: () =>
                              learning.toggleBookmark(q.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 56,
            color: _textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Fragen gefunden',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Versuche es mit einer anderen Suche',
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: _textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kategorie-Dropdown, das alle [QuestionCategory]-Werte + "Alle" anbietet.
class _CategoryDropdown extends StatelessWidget {
  final LearningProvider learning;

  const _CategoryDropdown({required this.learning});

  /// Ermittelt den aktuell im Dropdown anzuzeigenden String.
  String _currentLabel() {
    if (learning.filterCategory == null) return 'Alle';
    return learning.filterCategory!.displayName;
  }

  @override
  Widget build(BuildContext context) {
    // Alle Kategorien + "Alle"
    final items = <_CategoryItem>[
      const _CategoryItem(label: 'Alle', category: null),
      for (final cat in QuestionCategory.values)
        _CategoryItem(label: cat.displayName, category: cat),
    ];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentLabel(),
          isDense: true,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: LearningScreen._textSecondary, size: 18),
          style: GoogleFonts.roboto(
            fontSize: 13,
            color: LearningScreen._textPrimary,
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

/// Hilfsklasse für Dropdown-Einträge.
class _CategoryItem {
  final String label;
  final QuestionCategory? category;
  const _CategoryItem({required this.label, required this.category});
}

/// Einzelne Fragen-Kachel in der Lernliste.
class _QuestionTile extends StatelessWidget {
  final Question question;
  final bool isLearned;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);

  const _QuestionTile({
    required this.question,
    required this.isLearned,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final categoryLabel = question.category.displayName;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gelernt-Check (Learned-Toggle on tap)
            GestureDetector(
              onTap: () {
                context.read<LearningProvider>().toggleLearned(question.id);
              },
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isLearned ? _success.withOpacity(0.1) : _surface,
                  borderRadius: BorderRadius.circular(8),
                  border: isLearned
                      ? null
                      : Border.all(color: _textTertiary, width: 1.5),
                ),
                child: isLearned
                    ? const Icon(Icons.check, color: _success, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Fragentext und Kategorie
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoryLabel,
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bookmark
            GestureDetector(
              onTap: onBookmarkToggle,
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: isBookmarked
                      ? _primary.withOpacity(0.1)
                      : Colors.transparent,
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
      ),
    );
  }
}
