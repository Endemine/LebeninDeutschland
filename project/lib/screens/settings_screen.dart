import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../widgets/app_card.dart';
import '../providers/settings_provider.dart';

/// Einstellungs-Screen.
///
/// Bietet Optionen fuer Bundesland, Dark Mode, Sprache,
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
  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _error = Color(0xFFFF3B30);

  String _selectedBundesland = 'Baden-Wuerttemberg';
  String _selectedLanguage = 'Deutsch';

  final List<String> _bundeslaender = const [
    'Baden-Wuerttemberg',
    'Bayern',
    'Berlin',
    'Brandenburg',
    'Bremen',
    'Hamburg',
    'Hessen',
    'Mecklenburg-Vorpommern',
    'Niedersachsen',
    'Nordrhein-Westfalen',
    'Rheinland-Pfalz',
    'Saarland',
    'Sachsen',
    'Sachsen-Anhalt',
    'Schleswig-Holstein',
    'Thueringen',
  ];

  final Map<String, String> _languages = const {
    'Deutsch': 'de',
    'English': 'en',
    'Tuerkce': 'tr',
    'Arabisch': 'ar',
  };

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Fortschritt zuruecksetzen?',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        content: Text(
          'Bist du sicher, dass du deinen gesamten Lernfortschritt und alle Statistiken zuruecksetzen moechtest? Diese Aktion kann nicht rueckgaengig gemacht werden.',
          style: GoogleFonts.roboto(
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
              style: GoogleFonts.roboto(
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Fortschritt zuruecksetzen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fortschritt wurde zurueckgesetzt'),
                  backgroundColor: _error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Zuruecksetzen',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
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
          style: GoogleFonts.roboto(
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
            _SettingsSectionTitle(title: 'Allgemein'),
            _SettingsDropdownCard(
              icon: Icons.location_on,
              iconColor: _primary,
              title: 'Bundesland',
              subtitle: _selectedBundesland,
              value: _selectedBundesland,
              items: _bundeslaender,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedBundesland = value);
                }
              },
            ),

            const SizedBox(height: 8),

            // Erscheinungsbild
            _SettingsSectionTitle(title: 'Erscheinungsbild'),
            _SettingsToggleCard(
              icon: Icons.dark_mode,
              iconColor: _textSecondary,
              title: 'Dark Mode',
              subtitle: 'Dunkles Design verwenden',
              value: settings.darkMode,
              onChanged: (_) => settings.toggleDarkMode(),
            ),

            const SizedBox(height: 8),

            // Sprache
            _SettingsSectionTitle(title: 'Sprache'),
            _SettingsDropdownCard(
              icon: Icons.language,
              iconColor: _primary,
              title: 'Sprache',
              subtitle: _selectedLanguage,
              value: _selectedLanguage,
              items: _languages.keys.toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                }
              },
            ),

            const SizedBox(height: 8),

            // Daten
            _SettingsSectionTitle(title: 'Daten'),
            _SettingsActionCard(
              icon: Icons.delete_forever,
              iconColor: _error,
              title: 'Fortschritt zuruecksetzen',
              subtitle: 'Alle Lernfortschritte loeschen',
              onTap: _showResetDialog,
              isDestructive: true,
            ),

            const SizedBox(height: 8),

            // Info
            _SettingsSectionTitle(title: 'Info'),
            _SettingsActionCard(
              icon: Icons.info,
              iconColor: _primary,
              title: 'Ueber die App',
              subtitle: 'Version und Credits',
              onTap: () => _showAboutDialog(),
            ),
            _SettingsActionCard(
              icon: Icons.privacy_tip,
              iconColor: _primary,
              title: 'Datenschutz',
              subtitle: 'Datenschutzerklaerung',
              onTap: () {
                // TODO: Datenschutz oeffnen
              },
            ),
            _SettingsActionCard(
              icon: Icons.description,
              iconColor: _primary,
              title: 'Impressum',
              subtitle: 'Rechtliche Hinweise',
              onTap: () {
                // TODO: Impressum oeffnen
              },
            ),

            // App-Version
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Einbuergerungstest Pro v1.0.0',
                style: GoogleFonts.roboto(
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
          'Ueber die App',
          style: GoogleFonts.roboto(
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
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '🇩🇪',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Einbuergerungstest Pro',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Diese App hilft dir bei der Vorbereitung auf den Einbuergerungstest in Deutschland. '
              'Alle Fragen basieren auf dem offiziellen Fragenkatalog des BAMF.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
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
              'Schliessen',
              style: GoogleFonts.roboto(
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
        style: GoogleFonts.roboto(
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

  static const Color _surface = Color(0xFFF5F5F5);
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
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.keyboard_arrow_right,
                  color: _textSecondary, size: 20),
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: _textPrimary,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Einstellungs-Karte mit Toggle.
class _SettingsToggleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  static const Color _surface = Color(0xFFF5F5F5);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _primary = Color(0xFFFF6B00);

  const _SettingsToggleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _primary,
            activeTrackColor: _primary.withOpacity(0.3),
          ),
        ],
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

  static const Color _surface = Color(0xFFF5F5F5);
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
              color: iconColor.withOpacity(0.1),
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
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? _error : _textPrimary,
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
