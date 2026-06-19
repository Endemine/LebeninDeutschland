import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Wiederverwendbarer Primary Button im Xiaomi-Stil.
///
/// Unterstuetzt normale und outlined Variante, verschiedene Groessen,
/// optionales Icon und einen Loading-State.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isSmall;
  final bool isFullWidth;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isSmall = false,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _primaryLight = Color(0xFFFF8533);
  static const Color _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = isSmall ? 12.0 : 20.0;
    final double verticalPadding = isSmall ? 12.0 : 16.0;
    final double fontSize = isSmall ? 14.0 : 16.0;
    final double iconSize = isSmall ? 16.0 : 20.0;

    final textWidget = isLoading
        ? SizedBox(
            width: fontSize * 1.5,
            height: fontSize * 1.5,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? _primary : _white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: isOutlined ? _primary : _white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? _primary : _white,
                ),
              ),
            ],
          );

    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary, width: 1.5),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 50) : null,
          )
        : ElevatedButton.styleFrom(
            foregroundColor: _white,
            backgroundColor: _primary,
            disabledBackgroundColor: _primaryLight.withOpacity(0.6),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: onPressed == null || isLoading ? 0 : 2,
            minimumSize: isFullWidth ? const Size(double.infinity, 50) : null,
          );

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: textWidget,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: textWidget,
          );
  }
}
