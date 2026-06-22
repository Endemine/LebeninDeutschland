import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/learning_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass.dart';
import '../widgets/state_dropdown.dart';

/// Helle, moderne Landing Page (Xiaomi-Style).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _success = Color(0xFF34C759);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF6B6B6B);
  static const Gradient _brandGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF3B6B)],
  );

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final settings = context.watch<SettingsProvider>();
    final stats = context.watch<StatisticsProvider>();

    final learnedCount = learning.learnedCount;
    final totalQuestions = learning.totalQuestionCount;
    final overallProgress = learning.overallProgress;

    final bundeslaender = settings.availableStates;
    final selectedBundesland = settings.selectedState;
    final lastResult = stats.recentResults.isNotEmpty ? stats.recentResults.first : null;
    final hasLastTest = lastResult != null;
    final lastTestScore = lastResult?.correctAnswers ?? 0;
    final remaining = totalQuestions - learnedCount;

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              // === Header ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GradientText(
                        'Einbürgerungstest',
                        gradient: _brandGradient,
                        style: GoogleFonts.roboto(
                          fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5,
                        ),
                      ),
                      Text('Leben in Deutschland',
                        style: GoogleFonts.roboto(fontSize: 12, color: _textSecondary)),
                    ],
                  ),
                  GlassCard(
                    padding: const EdgeInsets.all(10),
                    radius: 14,
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    child: const Icon(Icons.settings_outlined, color: _textSecondary, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // === Fortschritt Hero-Card ===
              GlassCard(
                padding: const EdgeInsets.all(20),
                radius: 24,
                child: Row(
                  children: [
                    _ProgressRing(progress: overallProgress),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lernfortschritt',
                            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary)),
                          const SizedBox(height: 4),
                          Text('$learnedCount von $totalQuestions Fragen',
                            style: GoogleFonts.roboto(fontSize: 13, color: _textSecondary)),
                          const SizedBox(height: 4),
                          Text('Noch $remaining bis zum Ziel',
                            style: GoogleFonts.roboto(fontSize: 12, color: _primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // === Bundesland (echter Dropdown) ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: _brandGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dein Bundesland',
                            style: GoogleFonts.roboto(fontSize: 11, color: _textSecondary)),
                          const SizedBox(height: 4),
                          StateDropdown(
                            options: bundeslaender,
                            selected: selectedBundesland,
                            placeholder: 'Bitte wählen',
                            leadingIcon: null,
                            onSelected: (s) => settings.setState(s),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // === Aktionen Grid ===
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _ActionTile(icon: Icons.bolt, title: 'Echter Test', subtitle: '33 Fragen · 60 Min', isPrimary: true,
                    onTap: () => Navigator.pushNamed(context, '/quiz/setup')),
                  _ActionTile(icon: Icons.auto_stories, title: 'Lernmodus', subtitle: 'DE · EN · عربي',
                    onTap: () => Navigator.pushNamed(context, '/learning')),
                  _ActionTile(icon: Icons.insights, title: 'Statistiken', subtitle: 'Dein Fortschritt',
                    onTap: () => Navigator.pushNamed(context, '/statistics')),
                  _ActionTile(icon: Icons.bookmark_outline, title: 'Gemerkte', subtitle: 'Deine Bookmarks',
                    onTap: () => Navigator.pushNamed(context, '/bookmarks')),
                ],
              ),
              const SizedBox(height: 16),

              // === Letzter Test ===
              GlassCard(
                padding: const EdgeInsets.all(14),
                onTap: () => Navigator.pushNamed(context, hasLastTest ? '/statistics' : '/quiz/setup'),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: (hasLastTest && lastTestScore >= 17 ? _success : _primary).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        !hasLastTest ? Icons.rocket_launch : (lastTestScore >= 17 ? Icons.verified : Icons.replay),
                        color: hasLastTest && lastTestScore >= 17 ? _success : _primary, size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Letzter Test',
                            style: GoogleFonts.roboto(fontSize: 11, color: _textSecondary)),
                          Text(
                            hasLastTest ? '$lastTestScore / ${lastResult!.totalQuestions} richtig' : 'Noch kein Test',
                            style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
                          Text(
                            !hasLastTest ? 'Starte deinen ersten Test!' : (lastTestScore >= 17 ? 'Bestanden! 🎉' : 'Nicht bestanden'),
                            style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500,
                              color: hasLastTest && lastTestScore >= 17 ? _success : _primary)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: _textSecondary.withOpacity(0.5), size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // === Motivation ===
              Center(
                child: GradientText('Du schaffst das! 🇩🇪',
                  gradient: _brandGradient,
                  style: GoogleFonts.roboto(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),

              // === Unsere Apps ===
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text('UNSERE APPS', style: GoogleFonts.roboto(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: _textSecondary)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PromoChip(label: 'endenews.de', tag: 'EN', color: const Color(0xFFFF6B00), url: 'https://endenews.de'),
                        _PromoChip(label: 'tcgrail.org', tag: 'TCG', color: const Color(0xFF7C3AED), url: 'https://tcgrail.org'),
                        _PromoChip(label: '@tommygsx', tag: 'IG', color: const Color(0xFFEC4899), url: 'https://instagram.com/tommygsx'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom-Sheet zur Bundesland-Auswahl. (Deprecated — HomeScreen nutzt jetzt StateDropdown.)
  // ignore: unused_element
  void _showStatePickerLegacy(
    BuildContext context,
    SettingsProvider settings,
    List<String> bundeslaender,
    String? selectedBundesland,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text('Bundesland wählen',
                    style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary)),
              ),
              for (final s in bundeslaender)
                ListTile(
                  leading: Icon(selectedBundesland == s ? Icons.check : null, color: _primary, size: 20),
                  title: Text(s, style: GoogleFonts.roboto(fontSize: 14, color: _textPrimary)),
                  onTap: () {
                    settings.setState(s);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Gradient Progress-Ring.
class _ProgressRing extends StatelessWidget {
  final double progress;
  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76, height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 76, height: 76,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 7,
              backgroundColor: const Color(0xFFFF6B00).withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(progress * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A1A))),
              Text('gelernt', style: GoogleFonts.roboto(fontSize: 9, color: const Color(0xFF6B6B6B))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Aktions-Kachel.
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool isPrimary;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, this.isPrimary = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Primäre Kachel: oranger Hintergrund, weißer Text.
    // Sekundäre Kachel: weißer Hintergrund, dunkler Text.
    final Color titleColor = isPrimary ? Colors.white : const Color(0xFF1A1A1A);
    final Color subColor = isPrimary ? Colors.white.withOpacity(0.85) : const Color(0xFF6B6B6B);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      radius: 20,
      tint: isPrimary ? const Color(0xFFFF6B00) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: isPrimary
                  ? const LinearGradient(colors: [Colors.white24, Colors.white10])
                  : const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFFF3B6B)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w700, color: titleColor)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.roboto(fontSize: 11, color: subColor)),
        ],
      ),
    );
  }
}

/// Promo-Chip für externe Apps.
class _PromoChip extends StatelessWidget {
  final String label, tag, url;
  final Color color;
  const _PromoChip({required this.label, required this.tag, required this.color, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(tag, style: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w800, color: color))),
          ),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6B6B6B))),
        ],
      ),
    );
  }
}
