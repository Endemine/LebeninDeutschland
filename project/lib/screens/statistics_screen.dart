import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../widgets/app_card.dart';

/// Statistik-Screen.
///
/// Zeigt Lernfortschritt, Quiz-Historie, Kategorie-Statistiken
/// und Erfolgstrends an.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);

  // Demo-Daten
  final int _learnedQuestions = 225;
  final int _totalQuestions = 300;
  final List<Map<String, dynamic>> _recentTests = const [
    {'score': 28, 'total': 33, 'date': '15.01.2025', 'passed': true},
    {'score': 24, 'total': 33, 'date': '12.01.2025', 'passed': true},
    {'score': 16, 'total': 33, 'date': '08.01.2025', 'passed': false},
    {'score': 30, 'total': 33, 'date': '05.01.2025', 'passed': true},
  ];
  final List<Map<String, dynamic>> _categoryStats = const [
    {'category': 'Staat', 'learned': 45, 'total': 60},
    {'category': 'Recht', 'learned': 38, 'total': 50},
    {'category': 'Geschichte', 'learned': 52, 'total': 70},
    {'category': 'Kultur', 'learned': 50, 'total': 65},
    {'category': 'Wirtschaft', 'learned': 40, 'total': 55},
  ];
  final List<int> _weeklyScores = const [16, 24, 20, 28, 30, 26, 28];

  String get _weakestCategory {
    final sorted = [..._categoryStats]
      ..sort((a, b) =>
          (a['learned'] / a['total']).compareTo(b['learned'] / b['total']));
    return sorted.first['category'];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final overallProgress = _learnedQuestions / _totalQuestions;

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
          'Statistiken',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Gesamtfortschritt
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: screenWidth * 0.14,
                        lineWidth: 8,
                        percent: overallProgress.clamp(0.0, 1.0),
                        center: Text(
                          '${(overallProgress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                          ),
                        ),
                        progressColor: _primary,
                        backgroundColor: _surface,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        animationDuration: 1000,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gesamtfortschritt',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_learnedQuestions von $_totalQuestions Fragen gelernt',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: _textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Noch ${300 - _learnedQuestions} Fragen',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: _primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Letzte Tests
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                child: Text(
                  'Letzte Tests',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final test = _recentTests[index];
                  return _TestHistoryTile(
                    score: test['score'],
                    total: test['total'],
                    date: test['date'],
                    passed: test['passed'],
                  );
                },
                childCount: _recentTests.length,
              ),
            ),

            // Kategorie-Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 24, bottom: 8),
                child: Text(
                  'Kategorien',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = _categoryStats[index];
                  return _CategoryStatBar(
                    category: cat['category'],
                    learned: cat['learned'],
                    total: cat['total'],
                  );
                },
                childCount: _categoryStats.length,
              ),
            ),

            // Erfolgs-Trend (einfache Balken)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 24, bottom: 8),
                child: Text(
                  'Erfolgstrend (letzte 7 Tests)',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _weeklyScores.map((score) {
                        final percent = score / 33;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$score',
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: score >= 17 ? _success : _error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 24,
                              height: percent * 80,
                              decoration: BoxDecoration(
                                color: score >= 17 ? _success : _error,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_weeklyScores.indexOf(score) + 1}',
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            // Schwächen
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: _primary.withOpacity(0.05),
                  borderColor: _primary.withOpacity(0.15),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: _primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipp',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Du solltest mehr ueben: $_weakestCategory',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

/// Kachel fuer einen vergangenen Test.
class _TestHistoryTile extends StatelessWidget {
  final int score;
  final int total;
  final String date;
  final bool passed;

  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _surface = Color(0xFFF5F5F5);

  const _TestHistoryTile({
    required this.score,
    required this.total,
    required this.date,
    required this.passed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: passed
                    ? _success.withOpacity(0.1)
                    : _error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                passed ? Icons.check : Icons.close,
                color: passed ? _success : _error,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$score / $total richtig',
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    date,
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: passed
                    ? _success.withOpacity(0.1)
                    : _error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                passed ? 'Bestanden' : 'Nicht bestanden',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: passed ? _success : _error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontale Fortschrittsbalken fuer eine Kategorie.
class _CategoryStatBar extends StatelessWidget {
  final String category;
  final int learned;
  final int total;

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _surface = Color(0xFFF5F5F5);

  const _CategoryStatBar({
    required this.category,
    required this.learned,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = learned / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              Text(
                '$learned / $total',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: _surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 0.7 ? const Color(0xFF34C759) : _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
