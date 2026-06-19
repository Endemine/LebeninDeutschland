import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'providers/quiz_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/quiz_result_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/learning_detail_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/bookmarks_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(EinbuergerungApp(sharedPreferences: prefs));
}

class EinbuergerungApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const EinbuergerungApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
        ChangeNotifierProvider<LearningProvider>(create: (_) => LearningProvider()),
        ChangeNotifierProvider<QuizProvider>(create: (_) => QuizProvider()),
        ChangeNotifierProvider<StatisticsProvider>(create: (_) => StatisticsProvider()),
      ],
      child: const _AppInitializer(),
    );
  }
}

class _AppInitializer extends StatefulWidget {
  const _AppInitializer();
  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _isReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await context.read<SettingsProvider>().loadSettings();
      await context.read<LearningProvider>().loadQuestions();
      await context.read<StatisticsProvider>().loadStatistics();
      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isReady = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.school_outlined, size: 48, color: Color(0xFFFF6B00)),
                ),
                const SizedBox(height: 24),
                const Text('Einbuergerungstest', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Deutschland', style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93))),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 32, height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00))),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => MaterialApp(
        title: 'Einbuergerungstest Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
        locale: settings.locale,
        supportedLocales: const [Locale('de'), Locale('en'), Locale('tr'), Locale('ar')],
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/quiz/result': (context) => const QuizResultScreen(),
          '/learning': (context) => const LearningScreen(),
          '/learning/detail': (context) => const LearningDetailScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/bookmarks': (context) => const BookmarksScreen(),
        },
      ),
    );
  }
}
