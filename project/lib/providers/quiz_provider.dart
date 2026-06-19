// =============================================================================
// QUIZ PROVIDER
// =============================================================================
// Verwaltet den kompletten Zustand eines Quiz-Durchlaufs mit ChangeNotifier.
// Beinhaltet: Fragen-Logik, Timer (60 Minuten), Navigation, Ergebnisberechnung.
// =============================================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/quiz_state.dart';
import '../models/quiz_result.dart';

/// Der QuizProvider verwaltet den kompletten Lebenszyklus eines Quiz-Durchlaufs.
///
/// Funktionsumfang:
/// - Quiz starten mit 33 Fragen (30 allgemeine + 3 bundeslandspezifische)
/// - Timer-Management (60 Minuten Countdown)
/// - Navigation zwischen Fragen (vor/zurück/Sprung)
/// - Antwort-Selektion und Validierung
/// - Auto-Beenden bei abgelaufener Zeit
/// - Ergebnis-Berechnung mit Bestanden/Nicht-Bestanden
///
/// Usage:
/// ```dart
/// final quizProvider = context.read<QuizProvider>();
/// quizProvider.startQuiz(state: 'Bayern', allQuestions: questions);
/// ```
class QuizProvider extends ChangeNotifier {
  // ===========================================================================
  // INTERNER ZUSTAND
  // ===========================================================================

  /// Der aktuelle Quiz-Zustand (Fragen, Antworten, Timer, etc.)
  QuizState _state = QuizState.empty();

  /// Das Ergebnis des letzten abgeschlossenen Quiz
  QuizResult? _lastResult;

  /// Der Countdown-Timer für das Quiz (60 Minuten)
  Timer? _timer;

  /// Der Startzeitpunkt des aktuellen Quiz (für Zeitmessung)
  DateTime? _quizStartTime;

  /// Zufallsgenerator für Fragen-Mischung
  final Random _random = Random();

  // ===========================================================================
  // GETTER
  // ===========================================================================

  /// Aktueller Quiz-Zustand (für UI-Updates via Consumer/Selector)
  QuizState get state => _state;

  /// Ergebnis des letzten abgeschlossenen Quiz
  QuizResult? get lastResult => _lastResult;

  /// Gibt an ob ein Quiz aktiv läuft (gestartet aber nicht beendet)
  bool get isRunning => !_state.isFinished && _state.questions.isNotEmpty;

  /// Gibt an ob ein Quiz beendet wurde
  bool get isFinished => _state.isFinished;

  /// Die aktuell angezeigte Frage
  Question get currentQuestion => _state.currentQuestion;

  /// Die bereits gegebene Antwort für die aktuelle Frage (null = unbeantwortet)
  int? get currentAnswer => _state.currentAnswer;

  /// Der aktuelle Fragen-Index (0-basiert)
  int get currentIndex => _state.currentQuestionIndex;

  /// Gesamtanzahl der Fragen im Quiz
  int get totalQuestions => _state.questions.length;

  /// Anzahl der beantworteten Fragen
  int get answeredCount => _state.answeredCount;

  /// Anzahl der unbeantworteten Fragen
  int get unansweredCount => _state.unansweredCount;

  /// Fortschritt als Prozentwert (0.0 - 1.0)
  double get progressPercent => _state.progressPercent;

  /// Verbleibende Zeit als formatierter String (MM:SS)
  String get formattedTime => _state.formattedTime;

  /// Verbleibende Zeit in Sekunden
  int get remainingSeconds => _state.remainingSeconds;

  /// Das für das Quiz gewählte Bundesland
  String? get selectedState => _state.selectedState;

  // ===========================================================================
  // QUIZ LEBENSZYKLUS
  // ===========================================================================

  /// Startet ein neues Quiz mit 33 Fragen.
  ///
  /// Fragen-Zusammensetzung:
  /// - 30 zufällige allgemeine Fragen (ohne Bundesland)
  /// - 3 zufällige Fragen des gewählten Bundeslands
  ///
  /// [state] Das gewählte Bundesland (null = keine bundeslandspezifischen Fragen)
  /// [allQuestions] Die vollständige Liste aller verfügbaren Fragen
  void startQuiz({
    required String? state,
    required List<Question> allQuestions,
  }) {
    // Bestehenden Timer vorher aufräumen
    _stopTimer();

    // === Fragen filtern und aufteilen ===
    // Allgemeine Fragen (ohne Bundesland-Zuordnung)
    final generalQuestions = allQuestions
        .where((q) => !q.isStateSpecific)
        .toList();

    // Bundeslandspezifische Fragen (falls ein Bundesland gewählt wurde)
    List<Question> stateQuestions = [];
    if (state != null) {
      stateQuestions = allQuestions
          .where((q) => q.isStateSpecific && q.state == state)
          .toList();
    }

    // === Edge Case Handling ===
    // Falls nicht genug allgemeine Fragen vorhanden sind
    if (generalQuestions.isEmpty) {
      throw StateError(
        'Keine allgemeinen Fragen verfügbar. Bitte laden Sie die Fragen-Daten.',
      );
    }

    // === Zufällige Auswahl ===
    // Mische die allgemeinen Fragen und wähle 30 davon
    generalQuestions.shuffle(_random);
    final selectedGeneral = generalQuestions.sublist(
      0,
      min(30, generalQuestions.length),
    );

    // Mische die Bundeslands-Fragen und wähle 3 davon
    List<Question> selectedStateQuestions = [];
    if (stateQuestions.isNotEmpty) {
      stateQuestions.shuffle(_random);
      selectedStateQuestions = stateQuestions.sublist(
        0,
        min(3, stateQuestions.length),
      );
    }

    // === Quiz zusammenstellen ===
    // Kombiniere allgemeine und bundeslandspezifische Fragen
    final quizQuestions = [
      ...selectedGeneral,
      ...selectedStateQuestions,
    ];

    // Erneut mischen damit die Bundeslands-Fragen nicht immer am Ende sind
    quizQuestions.shuffle(_random);

    // === Zustand initialisieren ===
    _state = QuizState.start(
      questions: quizQuestions,
      selectedState: state,
    );

    _quizStartTime = DateTime.now();
    _lastResult = null;

    // === Timer starten ===
    _startTimer();

    notifyListeners();
  }

  /// Beendet das Quiz und berechnet das Ergebnis.
  ///
  /// Kann explizit vom Benutzer aufgerufen werden ("Quiz beenden" Button)
  /// oder automatisch beim Ablauf des Timers.
  void finishQuiz() {
    // Nur beenden wenn ein Quiz läuft
    if (!isRunning) return;

    _stopTimer();

    // Berechne verstrichene Zeit
    final timeTaken = _quizStartTime != null
        ? DateTime.now().difference(_quizStartTime!).inSeconds
        : 3600 - _state.remainingSeconds;

    // Ergebnis berechnen
    _lastResult = QuizResult.fromQuizState(
      answers: Map.unmodifiable(_state.answers),
      questions: _state.questions,
      timeTakenSeconds: timeTaken,
      selectedState: _state.selectedState,
    );

    // Zustand als beendet markieren
    _state = _state.copyWith(isFinished: true);

    notifyListeners();
  }

  // ===========================================================================
  // ANTWORT-MANAGEMENT
  // ===========================================================================

  /// Wählt eine Antwort für die aktuelle Frage aus.
  ///
  /// [answerIndex] Der Index der gewählten Antwort (0-3)
  /// Ignoriert Aufrufe wenn kein Quiz läuft oder das Quiz beendet ist.
  void answerQuestion(int answerIndex) {
    // Edge Case: Kein Quiz aktiv oder bereits beendet
    if (!isRunning) return;

    // Edge Case: Ungültiger Antwort-Index
    if (answerIndex < 0 || answerIndex > 3) return;

    // Kopie der Antworten-Map erstellen und aktualisieren
    final updatedAnswers = Map<int, int?>.from(_state.answers);
    updatedAnswers[_state.currentQuestionIndex] = answerIndex;

    _state = _state.copyWith(answers: updatedAnswers);

    notifyListeners();
  }

  /// Löscht die Antwort für die aktuelle Frage (zurücksetzen).
  void clearAnswer() {
    if (!isRunning) return;

    final updatedAnswers = Map<int, int?>.from(_state.answers);
    updatedAnswers[_state.currentQuestionIndex] = null;

    _state = _state.copyWith(answers: updatedAnswers);

    notifyListeners();
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  /// Springt zur nächsten Frage.
  /// Ignoriert den Aufruf wenn bereits bei der letzten Frage.
  void nextQuestion() {
    if (_state.currentQuestionIndex < _state.questions.length - 1) {
      _state = _state.copyWith(
        currentQuestionIndex: _state.currentQuestionIndex + 1,
      );
      notifyListeners();
    }
  }

  /// Springt zur vorherigen Frage.
  /// Ignoriert den Aufruf wenn bereits bei der ersten Frage.
  void previousQuestion() {
    if (_state.currentQuestionIndex > 0) {
      _state = _state.copyWith(
        currentQuestionIndex: _state.currentQuestionIndex - 1,
      );
      notifyListeners();
    }
  }

  /// Springt zu einer bestimmten Frage.
  ///
  /// [index] Der Ziel-Index (0-basiert)
  /// Ignoriert den Aufruf wenn der Index ungültig ist.
  void goToQuestion(int index) {
    if (index >= 0 && index < _state.questions.length) {
      _state = _state.copyWith(currentQuestionIndex: index);
      notifyListeners();
    }
  }

  // ===========================================================================
  // TIMER-MANAGEMENT
  // ===========================================================================

  /// Startet den 60-Minuten Countdown-Timer.
  ///
  /// Der Timer tickt jede Sekunde und aktualisiert die verbleibende Zeit.
  /// Bei Ablauf der Zeit wird das Quiz automatisch beendet.
  void _startTimer() {
    // Bestehenden Timer aufräumen
    _stopTimer();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      _onTimerTick,
    );
  }

  /// Timer-Tick Handler - wird jede Sekunde aufgerufen.
  void _onTimerTick(Timer timer) {
    // Reduziere verbleibende Zeit um 1 Sekunde
    final newRemaining = _state.remainingSeconds - 1;

    if (newRemaining <= 0) {
      // Zeit abgelaufen - Quiz automatisch beenden
      _state = _state.copyWith(remainingSeconds: 0);
      notifyListeners();
      _onTimeUp();
    } else {
      _state = _state.copyWith(remainingSeconds: newRemaining);
      notifyListeners();
    }
  }

  /// Wird aufgerufen wenn die 60 Minuten abgelaufen sind.
  ///
  /// Beendet das Quiz automatisch ohne dass der Benutzer etwas tun muss.
  /// Alle nicht beantworteten Fragen gelten als falsch.
  void _onTimeUp() {
    _stopTimer();

    // Berechne verstrichene Zeit
    final timeTaken = _quizStartTime != null
        ? DateTime.now().difference(_quizStartTime!).inSeconds
        : 3600;

    // Ergebnis berechnen (nicht beantwortete Fragen = falsch)
    _lastResult = QuizResult.fromQuizState(
      answers: Map.unmodifiable(_state.answers),
      questions: _state.questions,
      timeTakenSeconds: timeTaken,
      selectedState: _state.selectedState,
    );

    // Zustand als beendet markieren
    _state = _state.copyWith(isFinished: true);

    notifyListeners();
  }

  /// Stoppt den laufenden Timer.
  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  // ===========================================================================
  // HILFSMETHODEN
  // ===========================================================================

  /// Gibt die Antwort für eine bestimmte Frage zurück.
  ///
  /// [index] Der Fragen-Index (0-basiert)
  /// Returns: Der Antwort-Index (0-3) oder null wenn nicht beantwortet
  int? getAnswerForQuestion(int index) {
    if (index < 0 || index >= _state.questions.length) return null;
    return _state.answers[index];
  }

  /// Gibt an ob eine bestimmte Frage bereits beantwortet wurde.
  bool isQuestionAnswered(int index) {
    if (index < 0 || index >= _state.questions.length) return false;
    return _state.answers[index] != null;
  }

  /// Gibt den Status aller Fragen zurück (für Fortschrittsanzeige).
  ///
  /// Returns: Liste von Boolean-Werten - true = beantwortet, false = nicht beantwortet
  List<bool> get questionStatusList {
    return List.generate(
      _state.questions.length,
      (index) => _state.answers[index] != null,
    );
  }

  // ===========================================================================
  // CLEANUP
  // ===========================================================================

  /// Setzt den Provider-Zustand zurück (für Neustart).
  void reset() {
    _stopTimer();
    _state = QuizState.empty();
    _lastResult = null;
    _quizStartTime = null;
    notifyListeners();
  }

  /// Dispose - Timer aufräumen wenn der Provider zerstört wird.
  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
