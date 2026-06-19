import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

/// Splash-Screen mit App-Logo, Name und Lade-Animation.
///
/// Navigiert nach 2 Sekunden mit einer Fade-Transition zum HomeScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const Color _primary = Color(0xFFFF6B00);
  static const Color _white = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Navigation nach 2 Sekunden
    Future.delayed(const Duration(seconds: 2), () {
      _fadeController.forward().then((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: FadeTransition(
        opacity: ReverseAnimation(_fadeAnimation),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App-Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    '🇩🇪',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App-Name
              Text(
                'Einbuergerungstest Pro',
                style: GoogleFonts.roboto(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Leben in Deutschland',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 48),
              // Lade-Animation mit Shimmer
              Shimmer.fromColors(
                baseColor: _primary.withOpacity(0.3),
                highlightColor: _primary,
                period: const Duration(milliseconds: 1500),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(_primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
