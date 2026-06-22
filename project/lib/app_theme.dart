// =============================================================================
// APP THEME
// =============================================================================
// Definiert das komplette Theme der App im Xiaomi-Design-Stil.
// Enthält Light Theme und Dark Theme mit allen Farben, Abständen und Formen.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Das AppTheme definiert das visuelle Erscheinungsbild der App.
///
/// Xiaomi-Design-Philosophie:
/// - Helle, aufgeräumte Oberflächen
/// - Oranges Akzent-Farbe (#FF6B00)
/// - Runde Ecken bei Cards (16px) und Buttons (12px)
/// - Subtile Schatten für Tiefe
/// - Klare Typografie-Hierarchie
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: settingsProvider.themeMode,
/// )
/// ```
class AppTheme {
  // ===========================================================================
  // FARBPALETTE (Xiaomi-Style)
  // ===========================================================================

  /// Primärfarbe - Xiaomi Orange
  static const Color primary = Color(0xFFFF6B00);

  /// Helle Variante der Primärfarbe (für Hintergründe, Badges)
  static const Color primaryLight = Color(0xFFFF8C3A);

  /// Sehr helle Variante der Primärfarbe (für schwache Hintergründe)
  static const Color primaryVeryLight = Color(0xFFFFF0E6);

  /// Dunkle Variante der Primärfarbe (für aktive Zustände)
  static const Color primaryDark = Color(0xFFE55F00);

  /// Erfolg - Grün (für bestandene Quizze, richtige Antworten)
  static const Color success = Color(0xFF34C759);

  /// Erfolg - Heller Hintergrund
  static const Color successLight = Color(0xFFE8F5E9);

  /// Fehler - Rot (für nicht bestandene Quizze, falsche Antworten)
  static const Color error = Color(0xFFFF3B30);

  /// Fehler - Heller Hintergrund
  static const Color errorLight = Color(0xFFFFEBEE);

  /// Warnung - Gelb/Orange
  static const Color warning = Color(0xFFFF9500);

  /// Info - Blau
  static const Color info = Color(0xFF007AFF);

  /// Hintergrundfarbe - Weiß (Light Mode)
  static const Color backgroundLight = Color(0xFFFFFFFF);

  /// Oberflächenfarbe - Hellgrau (Light Mode Cards)
  static const Color surfaceLight = Color(0xFFF5F5F5);

  /// Sekundäre Oberfläche - Etwas dunkleres Grau
  static const Color surfaceLightSecondary = Color(0xFFEBEBEB);

  /// Hintergrundfarbe - Dunkel (Dark Mode)
  static const Color backgroundDark = Color(0xFF121212);

  /// Oberflächenfarbe - Dunkelgrau (Dark Mode Cards)
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Sekundäre Oberfläche - Etwas helleres Dunkelgrau
  static const Color surfaceDarkSecondary = Color(0xFF2C2C2C);

  /// Textfarbe - Primär (sehr dunkles Grau statt Schwarz)
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Textfarbe - Sekundär (mittleres Grau)
  static const Color textSecondary = Color(0xFF8E8E93);

  /// Textfarbe - Terziär (helles Grau)
  static const Color textTertiary = Color(0xFFC7C7CC);

  /// Textfarbe - Dunkler Modus Primär
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Textfarbe - Dunkler Modus Sekundär
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  /// Textfarbe - Dunkler Modus Terziär
  static const Color textTertiaryDark = Color(0xFF636366);

  /// Rahmenfarbe (subtile Trennlinien)
  static const Color borderLight = Color(0xFFE5E5EA);

  /// Rahmenfarbe (Dark Mode)
  static const Color borderDark = Color(0xFF38383A);

  /// Divider-Farbe
  static const Color divider = Color(0xFFE5E5EA);

  /// Divider-Farbe (Dark Mode)
  static const Color dividerDark = Color(0xFF38383A);

  // ===========================================================================
  // ABSTÄNDE & GRÖSSEN
  // ===========================================================================

  /// Standard-Padding für Screens
  static const double screenPadding = 20.0;

  /// Padding für Cards
  static const double cardPadding = 16.0;

  /// Abstand zwischen Listenelementen
  static const double listItemSpacing = 12.0;

  /// Abstand zwischen Sektionen
  static const double sectionSpacing = 24.0;

  /// Kleiner Abstand
  static const double smallSpacing = 8.0;

  /// Sehr kleiner Abstand
  static const double tinySpacing = 4.0;

  // ===========================================================================
  // RADIUS (Formen)
  // ===========================================================================

  /// Radius für Cards (16px)
  static const double cardRadius = 16.0;

  /// Radius für Buttons (12px)
  static const double buttonRadius = 12.0;

  /// Radius für kleine Elemente (Chips, Badges)
  static const double smallRadius = 8.0;

  /// Radius für Input-Felder
  static const double inputRadius = 12.0;

  /// Radius für Dialoge
  static const double dialogRadius = 20.0;

  /// Vollständig abgerundet (Avatare, Icons)
  static const double fullRadius = 999.0;

  // ===========================================================================
  // SCHRIFTGRÖSSEN
  // ===========================================================================

  /// Sehr große Überschrift (App Titel)
  static const double fontDisplay = 32.0;

  /// Große Überschrift (Screen Titel)
  static const double fontHeadline = 24.0;

  /// Mittlere Überschrift (Sektionstitel)
  static const double fontTitle = 20.0;

  /// Kleine Überschrift (Card-Titel)
  static const double fontSubtitle = 17.0;

  /// Normaler Text
  static const double fontBody = 16.0;

  /// Kleiner Text (Beschreibungen)
  static const double fontBodySmall = 14.0;

  /// Sehr kleiner Text (Hinweise, Labels)
  static const double fontCaption = 12.0;

  // ===========================================================================
  // LIGHT THEME
  // ===========================================================================

  /// Das Light Theme der App im Xiaomi-Design-Stil.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),

      // === Farbschema ===
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryVeryLight,
        onPrimaryContainer: primaryDark,
        secondary: primaryLight,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surfaceLight,
        surfaceContainerHighest: surfaceLightSecondary,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: borderLight,
      ),

      // === Scaffold Hintergrund ===
      scaffoldBackgroundColor: backgroundLight,

      // === AppBar Theme ===
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: fontSubtitle,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),

      // === Card Theme ===
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      // === Elevated Button Theme ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 14.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: fontBody,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // === Outlined Button Theme ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 14.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: fontBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // === Text Button Theme ===
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          textStyle: const TextStyle(
            fontSize: fontBodySmall,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // === Floating Action Button Theme ===
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

      // === Input Decoration Theme ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontSize: fontBody,
          color: textSecondary,
        ),
        labelStyle: const TextStyle(
          fontSize: fontBodySmall,
          color: textSecondary,
        ),
      ),

      // === Bottom Navigation Bar Theme ===
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundLight,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: fontCaption,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: fontCaption,
          fontWeight: FontWeight.w400,
        ),
      ),

      // === Tab Bar Theme ===
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        labelStyle: TextStyle(
          fontSize: fontBodySmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: fontBodySmall,
          fontWeight: FontWeight.w400,
        ),
      ),

      // === Chip Theme ===
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLightSecondary,
        selectedColor: primaryVeryLight,
        labelStyle: const TextStyle(
          fontSize: fontCaption,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: fontCaption,
          fontWeight: FontWeight.w500,
          color: primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(smallRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide.none,
      ),

      // === Dialog Theme ===
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        titleTextStyle: const TextStyle(
          fontSize: fontTitle,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // === Divider Theme ===
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      // === Progress Indicator Theme ===
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: borderLight,
        circularTrackColor: borderLight,
      ),

      // === Slider Theme ===
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: borderLight,
        thumbColor: primary,
        overlayColor: primary.withOpacity( 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      // === Snackbar Theme ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          fontSize: fontBodySmall,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(smallRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
      ),

      // === Typography ===
      textTheme: const TextTheme(
        // Display
        displayLarge: TextStyle(
          fontSize: fontDisplay,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        // Headline
        headlineLarge: TextStyle(
          fontSize: fontHeadline,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        // Title
        titleLarge: TextStyle(
          fontSize: fontTitle,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: fontSubtitle,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        // Body
        bodyLarge: TextStyle(
          fontSize: fontBody,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: fontBodySmall,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        // Caption
        labelSmall: TextStyle(
          fontSize: fontCaption,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
    );
  }

  // ===========================================================================
  // DARK THEME
  // ===========================================================================

  /// Das Dark Theme der App.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),

      // === Farbschema ===
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryDark,
        onPrimaryContainer: primaryLight,
        secondary: primaryLight,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surfaceDark,
        surfaceContainerHighest: surfaceDarkSecondary,
        onSurface: textPrimaryDark,
        onSurfaceVariant: textSecondaryDark,
        outline: borderDark,
      ),

      // === Scaffold Hintergrund ===
      scaffoldBackgroundColor: backgroundDark,

      // === AppBar Theme ===
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: fontSubtitle,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: -0.5,
        ),
      ),

      // === Card Theme ===
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      // === Elevated Button Theme ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 14.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: fontBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // === Outlined Button Theme ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: const BorderSide(color: primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 14.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),

      // === Text Button Theme ===
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
        ),
      ),

      // === Floating Action Button Theme ===
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

      // === Input Decoration Theme ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDarkSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontSize: fontBody,
          color: textSecondaryDark,
        ),
      ),

      // === Bottom Navigation Bar Theme ===
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundDark,
        selectedItemColor: primary,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // === Tab Bar Theme ===
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondaryDark,
        indicatorColor: primary,
      ),

      // === Chip Theme ===
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDarkSecondary,
        selectedColor: primaryDark,
        labelStyle: const TextStyle(
          fontSize: fontCaption,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: fontCaption,
          fontWeight: FontWeight.w500,
          color: primaryLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(smallRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide.none,
      ),

      // === Dialog Theme ===
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
      ),

      // === Divider Theme ===
      dividerTheme: const DividerThemeData(
        color: dividerDark,
        thickness: 1,
        space: 1,
      ),

      // === Progress Indicator Theme ===
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: borderDark,
        circularTrackColor: borderDark,
      ),

      // === Snackbar Theme ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDarkSecondary,
        contentTextStyle: const TextStyle(
          fontSize: fontBodySmall,
          color: textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(smallRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
      ),

      // === Typography ===
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontDisplay,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: fontHeadline,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: fontTitle,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        titleMedium: TextStyle(
          fontSize: fontSubtitle,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        bodyLarge: TextStyle(
          fontSize: fontBody,
          fontWeight: FontWeight.w400,
          color: textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          fontSize: fontBodySmall,
          fontWeight: FontWeight.w400,
          color: textSecondaryDark,
        ),
        labelSmall: TextStyle(
          fontSize: fontCaption,
          fontWeight: FontWeight.w400,
          color: textSecondaryDark,
        ),
      ),
    );
  }

  // ===========================================================================
  // HILFSMETHODEN
  // ===========================================================================

  /// Gibt die passende Antwort-Farbe basierend auf Richtigkeit zurück.
  ///
  /// [isCorrect] true = richtige Antwort, false = falsche Antwort
  /// [isDark] Aktuelles Theme ist Dark Mode
  static Color answerColor(bool isCorrect, {bool isDark = false}) {
    if (isCorrect) return success;
    return error;
  }

  /// Gibt die passende Hintergrund-Farbe für eine Antwort zurück.
  ///
  /// [isCorrect] true = richtige Antwort, false = falsche Antwort
  static Color answerBackgroundColor(bool isCorrect) {
    if (isCorrect) return successLight;
    return errorLight;
  }

  /// Erzeugt einen sanften Schatten für Cards im Light Mode.
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity( 0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  /// Erzeugt einen stärkeren Schatten für hervorgehobene Elemente.
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity( 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  /// Leerer Konstruktor (Utility-Klasse)
  AppTheme._();
}
