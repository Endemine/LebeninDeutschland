// =============================================================================
// STATE DROPDOWN
// =============================================================================
// Echte Dropdown-UI mit Flutter's MenuAnchor (Material 3).
// Klappt inline unter dem Trigger auf (KEIN Modal, KEIN Bottom-Sheet).
// Robuster auf Android/Web als showModalBottomSheet.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ein Dropdown-Widget für die Bundesland-Auswahl.
///
/// Wichtig: Verwendet `MenuAnchor` (Material 3) statt `showModalBottomSheet`,
/// damit das Menü garantiert unter dem Trigger aufklappt — auch wenn ein
/// TextField den Fokus hat oder der Layout-Container begrenzt ist.
class StateDropdown extends StatefulWidget {
  /// Liste der anzuzeigenden Optionen.
  final List<String> options;

  /// Aktuell ausgewählte Option (oder null).
  final String? selected;

  /// Label, das angezeigt wird, wenn nichts ausgewählt ist.
  final String placeholder;

  /// Callback bei Auswahl.
  final ValueChanged<String> onSelected;

  /// Optionales Icon links.
  final IconData? leadingIcon;

  /// Höhe des Triggers (Standard: 48px = Material-Standard für Touch-Targets).
  final double height;

  const StateDropdown({
    super.key,
    required this.options,
    required this.selected,
    required this.placeholder,
    required this.onSelected,
    this.leadingIcon,
    this.height = 48,
  });

  @override
  State<StateDropdown> createState() => _StateDropdownState();
}

class _StateDropdownState extends State<StateDropdown> {
  late final MenuController _menuController;

  static const _primary = Color(0xFFFF6B00);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSecondary = Color(0xFF6B6B6B);
  static const _surface = Color(0xFFF5F6F8);
  static const _border = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _menuController = MenuController();
  }

  void _openMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.white),
        elevation: const WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _border),
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
        maximumSize: const WidgetStatePropertyAll(Size(280, 400)),
      ),
      menuChildren: [
        for (final opt in widget.options)
          MenuItemButton(
            onPressed: () {
              widget.onSelected(opt);
              _menuController.close();
            },
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
              alignment: Alignment.centerLeft,
              backgroundColor: WidgetStatePropertyAll(
                widget.selected == opt ? _primary.withValues(alpha: 0.08) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: widget.selected == opt
                      ? const Icon(Icons.check, size: 18, color: _primary)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    opt,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: widget.selected == opt ? FontWeight.w600 : FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      child: InkWell(
        onTap: _openMenu,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border, width: 1),
          ),
          child: Row(
            children: [
              if (widget.leadingIcon != null) ...[
                Icon(widget.leadingIcon, size: 18, color: _primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  widget.selected ?? widget.placeholder,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.selected == null ? _textSecondary : _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 20, color: _textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
