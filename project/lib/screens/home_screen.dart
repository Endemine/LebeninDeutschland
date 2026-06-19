import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/learning_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/progress_ring.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _success = Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    final learningProvider = context.watch<LearningProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final statisticsProvider = context.watch<StatisticsProvider>();
    final screenSize = MediaQuery.of(context).size;
    final learnedCount = learningProvider.learnedCount;
    final totalQuestions = learningProvider.totalQuestionCount;
    final overallProgress = learningProvider.overallProgress;
    final bundeslaender = settingsProvider.availableStates;
    final selectedBundesland = settingsProvider.selectedState;
    final lastResult = statisticsProvider.recentResults.isNotEmpty ? statisticsProvider.recentResults.first : null;
    final hasLastTest = lastResult != null;
    final lastTestScore = lastResult?.correctAnswers ?? 0;
    final remainingQuestions = totalQuestions - learnedCount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Einbuergerungstest Pro', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w800, color: _textPrimary, letterSpacing: -0.3)),
                        Text('Leben in Deutschland', style: GoogleFonts.roboto(fontSize: 12, color: _textSecondary)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                      icon: const Icon(Icons.settings_outlined, color: _textSecondary, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            // Fortschritt-Karte
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      ProgressRing(percent: overallProgress,
                        centerText: '${(overallProgress * 100).toStringAsFixed(0)}%', subtitle: 'gelernt',
                        radius: screenSize.width * 0.12, lineWidth: 6),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lernfortschritt', style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                            const SizedBox(height: 2),
                            Text('$learnedCount von $totalQuestions Fragen', style: GoogleFonts.roboto(fontSize: 12, color: _textSecondary)),
                            const SizedBox(height: 2),
                            Text('Noch $remainingQuestions Fragen bis zum Ziel', style: GoogleFonts.roboto(fontSize: 11, color: _primary, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bundesland-Auswahl
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(width: 34, height: 34,
                        decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.location_on_outlined, color: _primary, size: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dein Bundesland', style: GoogleFonts.roboto(fontSize: 11, color: _textSecondary)),
                            const SizedBox(height: 1),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedBundesland, isExpanded: true, isDense: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: _textSecondary, size: 18),
                                style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
                                items: bundeslaender.map((String land) => DropdownMenuItem<String>(value: land, child: Text(land))).toList(),
                                onChanged: (String? value) { if (value != null) { settingsProvider.setState(value); } },
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
            // Aktions-Grid - KOMPAKT
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.7,
                  children: [
                    _ActionCard(icon: Icons.edit_note, iconColor: Colors.white, iconBgColor: _primary, title: 'Echter Test', subtitle: '33 Fragen - 60 Min', isPrimary: true, onTap: () => Navigator.pushNamed(context, '/quiz/setup')),
                    _ActionCard(icon: Icons.menu_book, iconColor: _primary, iconBgColor: _primary.withOpacity(0.1), title: 'Lernmodus', subtitle: 'Alle Fragen lernen', onTap: () => Navigator.pushNamed(context, '/learning')),
                    _ActionCard(icon: Icons.bar_chart, iconColor: _primary, iconBgColor: _primary.withOpacity(0.1), title: 'Statistiken', subtitle: 'Dein Fortschritt', onTap: () => Navigator.pushNamed(context, '/statistics')),
                    _ActionCard(icon: Icons.bookmark, iconColor: _primary, iconBgColor: _primary.withOpacity(0.1), title: 'Gemerkte', subtitle: 'Deine Bookmarks', onTap: () => Navigator.pushNamed(context, '/bookmarks')),
                  ],
                ),
              ),
            ),
            // Quick-Stat: Letzter Test
            if (hasLastTest)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: AppCard(padding: const EdgeInsets.all(12), onTap: () => Navigator.pushNamed(context, '/statistics'),
                    child: Row(
                      children: [
                        Container(width: 40, height: 40,
                          decoration: BoxDecoration(color: lastTestScore >= 17 ? _success.withOpacity(0.1) : const Color(0xFFFF3B30).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Icon(lastTestScore >= 17 ? Icons.check_circle : Icons.cancel, color: lastTestScore >= 17 ? _success : const Color(0xFFFF3B30), size: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Letzter Test', style: GoogleFonts.roboto(fontSize: 11, color: _textSecondary)),
                            Text('$lastTestScore / ${lastResult!.totalQuestions} richtig', style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                            Text(lastTestScore >= 17 ? 'Bestanden!' : 'Nicht bestanden', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: lastTestScore >= 17 ? _success : const Color(0xFFFF3B30))),
                          ]),
                        ),
                        const Icon(Icons.chevron_right, color: _textTertiary, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            if (!hasLastTest)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: AppCard(padding: const EdgeInsets.all(12), onTap: () => Navigator.pushNamed(context, '/quiz/setup'),
                    child: Row(
                      children: [
                        Container(width: 40, height: 40,
                          decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.edit_note, color: _primary, size: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Letzter Test', style: GoogleFonts.roboto(fontSize: 11, color: _textSecondary)),
                            Text('Noch kein Test', style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                            Text('Starte deinen ersten Test!', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: _primary)),
                          ]),
                        ),
                        const Icon(Icons.chevron_right, color: _textTertiary, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            // Motivation
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Center(child: Text('Du schaffst das! 🇩🇪', style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600, color: _primary))),
              ),
            ),
            // Unsere Apps
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async { final uri = Uri.parse('https://endenews.de'); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); },
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(width: 28, height: 28, decoration: BoxDecoration(color: Color(0xFFFF6B00).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Center(child: Text('EN', style: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFFF6B00))))),
                                const SizedBox(width: 6),
                                Text('endenews.de', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                              ]),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async { final uri = Uri.parse('https://tcgrail.org'); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); },
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(width: 28, height: 28, decoration: BoxDecoration(color: Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Center(child: Text('TCG', style: GoogleFonts.roboto(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF6366F1))))),
                                const SizedBox(width: 6),
                                Text('tcgrail.org', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async { final uri = Uri.parse('https://instagram.com/tommygsx'); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); },
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFFE4405F).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.camera_alt, color: Color(0xFFE4405F), size: 14)),
                          const SizedBox(width: 6),
                          Text('@tommygsx', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                        ]),
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBgColor;
  final String title, subtitle;
  final bool isPrimary;
  final VoidCallback? onTap;
  const _ActionCard({required this.icon, required this.iconColor, required this.iconBgColor, required this.title, required this.subtitle, this.isPrimary = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFF6B00) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPrimary
              ? [BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 18)),
            const SizedBox(height: 6),
            Text(title, style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w700, color: isPrimary ? Colors.white : const Color(0xFF1A1A1A))),
            Text(subtitle, style: GoogleFonts.roboto(fontSize: 10, color: isPrimary ? Colors.white.withOpacity(0.8) : const Color(0xFF8E8E93))),
          ],
        ),
      ),
    );
  }
}
