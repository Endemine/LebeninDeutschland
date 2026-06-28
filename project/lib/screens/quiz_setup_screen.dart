import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../providers/quiz_provider.dart';
import '../providers/learning_provider.dart';
import '../providers/settings_provider.dart';

/// Screen zur Auswahl des Quiz-Modus vor dem Start.
///
/// Bietet die Wahl zwischen "Echter Test" und "Schnelltest".
class QuizSetupScreen extends StatefulWidget {
  final bool screenshotMode;

  const QuizSetupScreen({super.key, this.screenshotMode = false});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int _selectedMode = 0; // 0 = Echter Test, 1 = Schnelltest
  bool _hasResetProvider = false;

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasResetProvider && !widget.screenshotMode) {
      context.read<QuizProvider>().reset();
      _hasResetProvider = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final selectedBundesland = settings.selectedState;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Test starten',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modus-Auswahl
              Text(
                'Waehle deinen Modus',
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Wie moechtest du heute ueben?',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Echter Test Card
              _ModeCard(
                title: 'Echter Test',
                subtitle: '33 Fragen in 60 Minuten',
                icon: Icons.fact_check,
                details: const [
                  'Wie im echten Einbuergerungstest',
                  '30 allgemeine Fragen + 3 Bundesland-Fragen',
                  '60 Minuten Zeit',
                ],
                isSelected: _selectedMode == 0,
                onTap: () => setState(() => _selectedMode = 0),
              ),
              const SizedBox(height: 12),

              // Schnelltest Card
              _ModeCard(
                title: 'Schnelltest',
                subtitle: '10 Fragen in 15 Minuten',
                icon: Icons.bolt,
                details: const [
                  'Schnelle Uebung zwischendurch',
                  'Zufaellige Fragen aus allen Kategorien',
                  '15 Minuten Zeit',
                ],
                isSelected: _selectedMode == 1,
                onTap: () => setState(() => _selectedMode = 1),
              ),

              const SizedBox(height: 24),

              // Bundesland-Bestaetigung
              Text(
                'Dein Bundesland',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: _primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedBundesland,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    _BundeslandPicker(
                      current: selectedBundesland,
                      states: settings.availableStates,
                      onSelected: (s) => settings.setState(s),
                      primary: _primary,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Hinweis
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _primary.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _primary.withOpacity(0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Im echten Test benoetigst du 17 von 33 richtige Antworten.',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: _textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Starten Button
              AppButton(
                label: 'Test starten',
                isFullWidth: true,
                icon: Icons.play_arrow,
                onPressed: () {
                  final learning = context.read<LearningProvider>();
                  final quiz = context.read<QuizProvider>();
                  quiz.reset();
                  // Echter Test (Modus 0) = mit Bundesland-Fragen,
                  // Schnelltest (Modus 1) = nur allgemeine Fragen.
                  quiz.startQuiz(
                    state: _selectedMode == 0 ? selectedBundesland : null,
                    allQuestions: learning.allQuestions,
                  );
                  Navigator.pushReplacementNamed(context, '/quiz');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Karte zur Auswahl eines Quiz-Modus.
class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> details;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _border = Color(0xFFE5E5EA);

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.details,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.05) : _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primary : _border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _primary.withOpacity(0.15)
                        : _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
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
                        title,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio-Indikator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _primary : _border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              ...details.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          decoration: const BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            detail,
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: _textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bundesland-Auswahl per Popup-Menü ("Ändern"-Button im Setup).
class _BundeslandPicker extends StatelessWidget {
  final String current;
  final List<String> states;
  final ValueChanged<String> onSelected;
  final Color primary;
  const _BundeslandPicker({
    required this.current,
    required this.states,
    required this.onSelected,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final s in states)
                  ListTile(
                    leading: Icon(s == current ? Icons.check : null, color: primary, size: 20),
                    title: Text(s),
                    onTap: () { onSelected(s); Navigator.pop(ctx); },
                  ),
              ],
            ),
          ),
        );
      },
      child: Text(
        'Ändern',
        style: GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
    );
  }
}
