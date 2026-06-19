import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/learning_provider.dart';
import '../models/question.dart';

/// Screen fuer gemerkte (bookmarkte) Fragen.
///
/// Zeigt alle bookmarkten Fragen an und ermoeglicht das
/// Entfernen von Bookmarks per Swipe oder Icon.
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);

  void _removeBookmark(int questionId) {
    final learningProvider = context.read<LearningProvider>();
    learningProvider.toggleBookmark(questionId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark entfernt'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final learningProvider = context.watch<LearningProvider>();
    final bookmarkedQuestions = learningProvider.bookmarkedQuestions;

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
          'Gemerkte Fragen',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (bookmarkedQuestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${bookmarkedQuestions.length}',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: bookmarkedQuestions.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: bookmarkedQuestions.length,
                itemBuilder: (context, index) {
                  final q = bookmarkedQuestions[index];
                  final learned = learningProvider.isLearned(q.id);
                  return _BookmarkedQuestionTile(
                    question: q.text,
                    category: q.category.displayName,
                    learned: learned,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/learning/detail',
                        arguments: {'questionId': q.id},
                      );
                    },
                    onRemove: () => _removeBookmark(q.id),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.bookmark_border,
              size: 40,
              color: _textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Noch keine Fragen gemerkt',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tippe auf das Lesezeichen-Icon beim Lernen, um Fragen hier zu speichern.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/learning');
            },
            icon: const Icon(Icons.menu_book, size: 18),
            label: const Text('Zum Lernmodus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Einzelne bookmarkte Fragen-Kachel mit Swipe-to-Delete.
class _BookmarkedQuestionTile extends StatelessWidget {
  final String question;
  final String category;
  final bool learned;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);

  const _BookmarkedQuestionTile({
    required this.question,
    required this.category,
    required this.learned,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(question),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: _error,
          size: 24,
        ),
      ),
      child: GestureDetector(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
              // Remove Bookmark Button
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: _primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
