import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_setup_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/quiz_result_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/learning_detail_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/bookmarks_screen.dart';

/// Zentraler Router der App.
///
/// Verwaltet alle Navigationen mit benannten Routen und
/// MaterialPageRoute-Transitionen.
class AppRouter {
  /// Generiert die entsprechende Route basierend auf [settings].
  ///
  /// Unterstuetzte Routen:
  /// - `/` -> HomeScreen
  /// - `/quiz/setup` -> QuizSetupScreen
  /// - `/quiz` -> QuizScreen
  /// - `/quiz/result` -> QuizResultScreen
  /// - `/learning` -> LearningScreen
  /// - `/learning/detail` -> LearningDetailScreen
  /// - `/statistics` -> StatisticsScreen
  /// - `/settings` -> SettingsScreen
  /// - `/bookmarks` -> BookmarksScreen
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case '/quiz/setup':
        return MaterialPageRoute(
          builder: (_) => const QuizSetupScreen(),
          settings: settings,
        );

      case '/quiz':
        return MaterialPageRoute(
          builder: (_) => const QuizScreen(),
          settings: settings,
        );

      case '/quiz/result':
        return MaterialPageRoute(
          builder: (_) => const QuizResultScreen(),
          settings: settings,
        );

      case '/learning':
        return MaterialPageRoute(
          builder: (_) => const LearningScreen(),
          settings: settings,
        );

      case '/learning/detail':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => const LearningDetailScreen(),
          settings: settings,
        );

      case '/statistics':
        return MaterialPageRoute(
          builder: (_) => const StatisticsScreen(),
          settings: settings,
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case '/bookmarks':
        return MaterialPageRoute(
          builder: (_) => const BookmarksScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFFF3B30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seite nicht gefunden',
                    style: Theme.of(_).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Route: ${settings.name}',
                    style: Theme.of(_).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8E8E93),
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(_).pushReplacementNamed('/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Zur Startseite'),
                  ),
                ],
              ),
            ),
          ),
          settings: settings,
        );
    }
  }

  /// Shortcut-Routen als statische Strings.
  static const String home = '/';
  static const String quizSetup = '/quiz/setup';
  static const String quiz = '/quiz';
  static const String quizResult = '/quiz/result';
  static const String learning = '/learning';
  static const String learningDetail = '/learning/detail';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String bookmarks = '/bookmarks';
}
