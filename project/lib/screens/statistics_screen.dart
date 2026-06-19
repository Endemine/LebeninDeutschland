import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../widgets/app_card.dart';
import '../providers/statistics_provider.dart';
import '../providers/learning_provider.dart';
import '../models/quiz_result.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);
  static const Color _error = Color(0xFFFF3B30);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final statsProvider = context.watch<StatisticsProvider>();
    final learningProvider = context.watch<LearningProvider>();

    final learnedQuestions = learningProvider.learnedCount;
    final totalQuestions = learningProvider.totalQuestionCount;
    final overallProgress = totalQuestions > 0
        ? learnedQuestions / totalQuestions
        : 0.0;

    final recentTests = statsProvider.recentResults;
    final scoreTrend = statsProvider.scoreTrend;
    final categoryStatsMap = statsProvider.categoryStats;

    final categoryStatsList = categoryStatsMap.entries.map((entry) {
      final cs = entry.value;
      return {
        'category': cs.category,
        'learned': cs.totalCorrect,
        'total': cs.totalQuestions,
      };
    }).toList();

    final weeklyScores = scoreTrend
        .map((s) => s.y.round())
        .toList()
        .reversed
        .take(7)
        .toList()
        .reversed
        .toList();

    String weakestCategory = '';
    double weakestRate = 100.0;
    for (final entry in categoryStatsMap.entries) {
      final rate = entry.value.successRate;
      if (entry.value.totalAsked >= 5 && rate < weakestRate) {
        weakestRate = rate;
        weakestCategory = entry.value.category;
      }
    }
    if (weakestCategory.isEmpty && categoryStatsMap.isNotEmpty) {
      double minRate = 100.0;
      for (final entry in categoryStatsMap.entries) {
        if (entry.value.successRate < minRate) {
          minRate = entry.value.successRate;
          weakestCategory = entry.value.category;
        }
      }
    }

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
                              '$learnedQuestions von $totalQuestions Fragen gelernt',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: _textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Noch ${totalQuestions - learnedQuestions} Fragen',
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
            if (recentTests.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    'Noch keine Tests durchgefuehrt.',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final test = recentTests[index];
                    final dateStr = '${test.completedAt.day.toString().padLeft(2, '0')}.'
                        '${test.completedAt.month.toString().padLeft(2, '0')}.'
                        '${test.completedAt.year}';
                    return _TestHistoryTile(
                      score: test.correctAnswers,
                      total: test.totalQuestions,
                      date: dateStr,
                      passed: test.isPassed,
                    );
                  },
                  childCount: recentTests.length,
                ),
              ),

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
            if (categoryStatsList.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    'Keine Quiz-Daten vorhanden.',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = categoryStatsList[index];
                    return _CategoryStatBar(
                      category: cat['category'] as String,
                      learned: cat['learned'] as int,
                      total: cat['total'] as int,
                    );
                  },
                  childCount: categoryStatsList.length,
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 24, bottom: 8),
                child: Text(
                  'Erfolgstrend (letzte Tests)',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
            if (weeklyScores.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          'Noch keine Trend-Daten.',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
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
                        children: weeklyScores.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final score = entry.value;
                          final maxTotal = recentTests.isNotEmpty
                              ? recentTests.first.totalQuestions
                              : 33;
                          final percent = maxTotal > 0 ? score / maxTotal : 0.0;
                          final passingThreshold = (maxTotal * 0.515).round();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$score',
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: score >= passingThreshold ? _success : _error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 24,
                                height: percent * 80,
                                decoration: BoxDecoration(
                                  color: score >= passingThreshold ? _success : _error,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${idx + 1}',
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

            if (weakestCategory.isNotEmpty)
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
                                'Du solltest mehr ueben: $weakestCategory',
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
                color: passed ? _success.withOpacity(0.1) : _error.withOpacity(0.1),
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
                color: passed ? _success.withOpacity(0.1) : _error.withOpacity(0.1),
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
    final percent = total > 0 ? learned / total : 0.0;

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
