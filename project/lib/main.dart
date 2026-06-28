import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'providers/quiz_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/settings_provider.dart';
import 'models/quiz_result.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/quiz_result_screen.dart';
import 'screens/learning_screen.dart';

import 'screens/quiz_setup_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/bookmarks_screen.dart';

const String _screenshotScene = String.fromEnvironment('SHOT_SCENE', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Edge-to-edge: App läuft unter Status-Bar UND System-Nav-Bar.
  // SafeArea in den Screens berücksichtigt die System-Bars.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
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
        themeMode: ThemeMode.light,
        locale: settings.locale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('de'), Locale('en'), Locale('tr'), Locale('ar')],
        home: _screenshotScene.isEmpty
            ? const _AppShell()
            : ScreenshotSceneHost(scene: _screenshotScene),
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/quiz':
            return MaterialPageRoute(builder: (_) => const QuizScreen());
          case '/quiz/setup':
            return MaterialPageRoute(builder: (_) => const QuizSetupScreen());
          case '/quiz/result':
            return MaterialPageRoute(builder: (_) => const QuizResultScreen());
          case '/learning':
            return MaterialPageRoute(builder: (_) => const LearningScreen());
          case '/statistics':
            return MaterialPageRoute(builder: (_) => const StatisticsScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case '/bookmarks':
            return MaterialPageRoute(builder: (_) => const BookmarksScreen());
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      },
    );
  }
}

class ScreenshotSceneHost extends StatefulWidget {
  final String scene;
  const ScreenshotSceneHost({super.key, required this.scene});

  @override
  State<ScreenshotSceneHost> createState() => _ScreenshotSceneHostState();
}

class _ScreenshotSceneHostState extends State<ScreenshotSceneHost> {
  bool _prepared = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prepareScene();
      if (mounted) setState(() => _prepared = true);
    });
  }

  Future<void> _prepareScene() async {
    final learning = context.read<LearningProvider>();
    final quiz = context.read<QuizProvider>();
    final stats = context.read<StatisticsProvider>();
    final settings = context.read<SettingsProvider>();

    if (widget.scene == 'quiz') {
      quiz.reset();
      quiz.startQuiz(state: settings.selectedState, allQuestions: learning.allQuestions);
      for (var i = 0; i < quiz.totalQuestions && i < 8; i++) {
        quiz.goToQuestion(i);
        final correct = quiz.currentQuestion.correctAnswerIndex;
        final answer = i.isEven ? correct : (correct + 1) % 4;
        quiz.answerQuestion(answer);
      }
      quiz.goToQuestion(6);
    } else if (widget.scene == 'result') {
      quiz.reset();
      quiz.startQuiz(state: settings.selectedState, allQuestions: learning.allQuestions);
      for (var i = 0; i < quiz.totalQuestions; i++) {
        quiz.goToQuestion(i);
        final correct = quiz.currentQuestion.correctAnswerIndex;
        final answer = i < 18 ? correct : (correct + 1) % 4;
        quiz.answerQuestion(answer);
      }
      quiz.finishQuiz();
      final result = quiz.lastResult;
      if (result != null) {
        await stats.addQuizResult(result);
      }
    } else if (widget.scene == 'statistics') {
      quiz.reset();
      quiz.startQuiz(state: settings.selectedState, allQuestions: learning.allQuestions);
      for (var i = 0; i < quiz.totalQuestions; i++) {
        quiz.goToQuestion(i);
        final correct = quiz.currentQuestion.correctAnswerIndex;
        final answer = i % 3 == 0 ? correct : (correct + 1) % 4;
        quiz.answerQuestion(answer);
      }
      quiz.finishQuiz();
      final result = quiz.lastResult;
      if (result != null) {
        await stats.addQuizResult(result);
      }

      for (final id in [1, 7, 12, 18, 24, 33, 41, 55, 68, 81]) {
        learning.markAsLearned(id);
      }
      for (final id in [2, 8, 19, 26, 42]) {
        learning.toggleBookmark(id);
      }
    } else if (widget.scene == 'setup') {
      quiz.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_prepared) {
      return const ColoredBox(color: Colors.white);
    }

    switch (widget.scene) {
      case 'setup':
        return const QuizSetupScreen(screenshotMode: true);
      case 'quiz':
        return const QuizScreen();
      case 'result':
        return const QuizResultScreen();
      case 'statistics':
        return const StatisticsScreen();
      default:
        return const HomeScreen();
    }
  }
}
