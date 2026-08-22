import 'package:flutter/material.dart';
import '../app_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../widgets/app_card.dart';
import '../providers/learning_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/statistics_provider.dart';

/// Einstellungs-Screen.
///
/// Bietet Optionen fuer Bundesland, Sprache der Fragen,
/// Datenverwaltung und App-Informationen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  static const Color _error = Color(0xFFFF3B30);

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Fortschritt zurücksetzen?',
          style: roboto(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        content: Text(
          'Bist du sicher, dass du deinen gesamten Lernfortschritt und alle Statistiken zurücksetzen möchtest? Diese Aktion kann nicht rückgängig gemacht werden.',
          style: roboto(
            fontSize: 15,
            color: _textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Abbrechen',
              style: roboto(
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetEverything();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Zurücksetzen',
              style: roboto(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Setzt Einstellungen, Lernfortschritt, Bookmarks und Statistiken zurueck.
  ///
  /// Wichtig: Alle drei Provider muessen zurueckgesetzt werden. Wuerden nur die
  /// SharedPreferences geleert, blieben die geladenen Daten im Speicher stehen
  /// und die App zeigte den alten Fortschritt bis zum naechsten Neustart.
  Future<void> _resetEverything() async {
    final messenger = ScaffoldMessenger.of(context);
    final learning = context.read<LearningProvider>();
    final statistics = context.read<StatisticsProvider>();
    final settings = context.read<SettingsProvider>();

    await learning.clearLearnedProgress();
    await learning.clearBookmarks();
    await statistics.clearAll();
    await settings.resetProgress();

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Fortschritt wurde zurückgesetzt'),
        backgroundColor: _error,
      ),
    );
  }

  /// Oeffnet eine externe URL im Browser.
  Future<void> _openUrl(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text('Konnte $url nicht öffnen')),
      );
    }
  }

  /// Sprachen, fuer die in `assets/translations.json` Uebersetzungen vorliegen.
  ///
  /// Bewusst nur DE/EN/AR: fuer Tuerkisch existieren keine Uebersetzungsdaten.
  /// Die Auswahl steuert nur die Anzeige der Fragen, nicht die App-Oberflaeche —
  /// die ist durchgehend deutsch (siehe Kommentar in main.dart).
  static const Map<String, String> _questionLanguageNames = {
    'de': 'Deutsch',
    'en': 'English',
    'ar': 'العربية',
  };

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
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
          'Einstellungen',
          style: roboto(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // Bundesland
            const _SettingsSectionTitle(title: 'Allgemein'),
            _SettingsDropdownCard(
              icon: Icons.location_on,
              iconColor: _primary,
              title: 'Bundesland',
              subtitle: settings.selectedState,
              value: settings.selectedState,
              items: settings.availableStates,
              onChanged: (value) {
                if (value != null) {
                  settings.setState(value);
                }
              },
            ),

            const SizedBox(height: 8),

            // Sprache der Fragen
            const _SettingsSectionTitle(title: 'Sprache'),
            _SettingsDropdownCard(
              icon: Icons.translate,
              iconColor: _primary,
              title: 'Sprache der Fragen',
              subtitle: _questionLanguageNames[learning.viewLanguage] ??
                  _questionLanguageNames['de']!,
              value: _questionLanguageNames[learning.viewLanguage] ??
                  _questionLanguageNames['de']!,
              items: _questionLanguageNames.values.toList(),
              onChanged: (value) {
                if (value == null) return;
                final code = _questionLanguageNames.entries
                    .firstWhere((e) => e.value == value,
                        orElse: () => const MapEntry('de', 'Deutsch'))
                    .key;
                learning.setViewLanguage(code);
              },
            ),

            const SizedBox(height: 8),

            // Daten
            const _SettingsSectionTitle(title: 'Daten'),
            _SettingsActionCard(
              icon: Icons.delete_forever,
              iconColor: _error,
              title: 'Fortschritt zurücksetzen',
              subtitle: 'Alle Lernfortschritte löschen',
              onTap: _showResetDialog,
              isDestructive: true,
            ),

            const SizedBox(height: 8),

            // Info
            const _SettingsSectionTitle(title: 'Info'),
            _SettingsActionCard(
              icon: Icons.info,
              iconColor: _primary,
              title: 'Über die App',
              subtitle: 'Version und Credits',
              onTap: () => _showAboutDialog(),
            ),
            _SettingsActionCard(
              icon: Icons.privacy_tip,
              iconColor: _primary,
              title: 'Datenschutz',
              subtitle: 'Datenschutzerklärung',
              onTap: () => _openUrl(kPrivacyUrl),
            ),
            _SettingsActionCard(
              icon: Icons.description,
              iconColor: _primary,
              title: 'Impressum',
              subtitle: 'Rechtliche Hinweise',
              onTap: () => _openUrl(kImprintUrl),
            ),

            // App-Version
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Einbürgerungstest Pro v$kAppVersion',
                style: roboto(
                  fontSize: 13,
                  color: _textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Über die App',
          style: roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '\u{1F1E9}\u{1F1EA}',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Einbürgerungstest Pro',
              style: roboto(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version $kAppVersion',
              style: roboto(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Diese App hilft dir bei der Vorbereitung auf den Einbürgerungstest in Deutschland. '
              'Alle Fragen basieren auf dem offiziellen Fragenkatalog des BAMF.',
              textAlign: TextAlign.center,
              style: roboto(
                fontSize: 14,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Schließen',
              style: roboto(
                color: _primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Abschnitts-Titel in den Einstellungen.
class _SettingsSectionTitle extends StatelessWidget {
  final String title;

  static const Color _textSecondary = Color(0xFF8E8E93);

  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: roboto(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Einstellungs-Karte mit Dropdown.
class _SettingsDropdownCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);

  const _SettingsDropdownCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(title,
                      style: roboto(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary)),
                ),
                for (final item in items)
                  ListTile(
                    leading: Icon(item == value ? Icons.check : null, color: iconColor, size: 20),
                    title: Text(item, style: roboto(fontSize: 14, color: _textPrimary)),
                    onTap: () { onChanged(item); Navigator.pop(ctx); },
                  ),
              ],
            ),
          ),
        );
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: roboto(
                      fontSize: 13,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_right, color: _textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Einstellungs-Karte mit Tap-Action.
class _SettingsActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _error = Color(0xFFFF3B30);

  const _SettingsActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? _error : _textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: roboto(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: _textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
