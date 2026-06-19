import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_card.dart';

/// Lernmodus-Screen.
///
/// Zeigt filterbare und durchsuchbare Fragen-Liste mit
/// Bookmarks und Lernfortschritt.
class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);

  String _searchQuery = '';
  String _selectedCategory = 'Alle';
  String _selectedBundesland = 'Alle';

  final List<String> _categories = [
    'Alle',
    'Staat',
    'Recht',
    'Geschichte',
    'Kultur',
    'Wirtschaft',
  ];

  // Demo-Fragen
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'question': 'Was ist die Hauptstadt von Deutschland?',
      'category': 'Staat',
      'learned': true,
      'bookmarked': false,
    },
    {
      'id': 2,
      'question': 'Wie viele Bundeslaender hat die Bundesrepublik Deutschland?',
      'category': 'Staat',
      'learned': true,
      'bookmarked': true,
    },
    {
      'id': 3,
      'question': 'Welches ist das groesste Bundesland Deutschlands?',
      'category': 'Staat',
      'learned': false,
      'bookmarked': false,
    },
    {
      'id': 4,
      'question': 'Wer war der erste Bundeskanzler der Bundesrepublik Deutschland?',
      'category': 'Geschichte',
      'learned': false,
      'bookmarked': true,
    },
    {
      'id': 5,
      'question': 'Was bedeutet das Grundgesetz?',
      'category': 'Recht',
      'learned': true,
      'bookmarked': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredQuestions {
    return _questions.where((q) {
      final matchesSearch = _searchQuery.isEmpty ||
          q['question'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Alle' || q['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get _learnedCount => _questions.where((q) => q['learned'] == true).length;
  int get _totalCount => _questions.length;

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
                          '$_learnedCount / $_totalCount Fragen',
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
                        value: _totalCount > 0 ? _learnedCount / _totalCount : 0,
                        minHeight: 8,
                        backgroundColor: _surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter-Bar
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
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Suchen...',
                          hintStyle: GoogleFonts.roboto(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                          prefixIcon: const Icon(Icons.search,
                              color: _textSecondary, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Kategorie-Dropdown
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isDense: true,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: _textSecondary, size: 18),
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: _textPrimary,
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fragen-Liste
            Expanded(
              child: _filteredQuestions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredQuestions.length,
                      itemBuilder: (context, index) {
                        final q = _filteredQuestions[index];
                        return _QuestionTile(
                          question: q['question'],
                          category: q['category'],
                          learned: q['learned'],
                          bookmarked: q['bookmarked'],
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/learning/detail',
                              arguments: {'questionId': q['id']},
                            );
                          },
                          onBookmarkToggle: () {
                            setState(() {
                              q['bookmarked'] = !q['bookmarked'];
                            });
                          },
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

/// Einzelne Fragen-Kachel in der Lernliste.
class _QuestionTile extends StatelessWidget {
  final String question;
  final String category;
  final bool learned;
  final bool bookmarked;
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
    required this.category,
    required this.learned,
    required this.bookmarked,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
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
            // Gelernt-Check
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: learned ? _success.withOpacity(0.1) : _surface,
                borderRadius: BorderRadius.circular(8),
                border: learned
                    ? null
                    : Border.all(color: _textTertiary, width: 1.5),
              ),
              child: learned
                  ? const Icon(Icons.check, color: _success, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            // Fragentext und Kategorie
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
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
                      category,
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
                  color: bookmarked
                      ? _primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: bookmarked ? _primary : _textTertiary,
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
