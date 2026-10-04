// =============================================================================
// QUIZ PROVIDER
// =============================================================================
// Verwaltet den kompletten Zustand eines Quiz-Durchlaufs mit ChangeNotifier.
// Beinhaltet: Fragen-Logik, Timer (60 Minuten), Navigation, Ergebnisberechnung.
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Das Zeitlimit des aktuellen Quiz in Sekunden (3600 = Echter Test, 900 = Schnelltest)
  int _totalSeconds = 3600;

  /// Gespeicherter, noch nicht abgeschlossener Test (für "Test fortsetzen")
  Map<String, dynamic>? _saved;

  static const String _kActiveQuizKey = 'active_quiz';

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

  /// Zeitlimit des aktuellen Tests in Sekunden
  int get totalSeconds => _totalSeconds;

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
  /// [generalQuestionCount] Anzahl allgemeiner Fragen (33-Echter-Test-Modus: 30)
  /// [stateQuestionCount] Anzahl Bundesland-Fragen (Echter Test: 3, Schnelltest: 0)
  /// [timeLimitSeconds] Zeitlimit in Sekunden (Echter Test: 3600, Schnelltest: 900)
  /// [topic] Nur allgemeine Fragen dieses Themenblocks (null = alle Themen)
  void startQuiz({
    required String? state,
    required List<Question> allQuestions,
    int generalQuestionCount = 30,
    int stateQuestionCount = 3,
    int timeLimitSeconds = 3600,
    String? topic,
  }) {
    // Bestehenden Timer vorher aufräumen
    _stopTimer();

    // === Fragen filtern und aufteilen ===
    // Allgemeine Fragen (ohne Bundesland-Zuordnung)
    final generalQuestions = allQuestions
        .where((q) => !q.isStateSpecific && (topic == null || q.topic == topic))
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
    // Mische die allgemeinen Fragen und wähle die gewünschte Anzahl davon
    generalQuestions.shuffle(_random);
    final selectedGeneral = generalQuestions.sublist(
      0,
      min(generalQuestionCount, generalQuestions.length),
    );

    // Mische die Bundeslands-Fragen und wähle die gewünschte Anzahl davon
    List<Question> selectedStateQuestions = [];
    if (stateQuestions.isNotEmpty && stateQuestionCount > 0) {
      stateQuestions.shuffle(_random);
      selectedStateQuestions = stateQuestions.sublist(
        0,
        min(stateQuestionCount, stateQuestions.length),
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
    _totalSeconds = timeLimitSeconds;
    _state = QuizState.start(
      questions: quizQuestions,
      selectedState: state,
      totalSeconds: timeLimitSeconds,
    );

    _quizStartTime = DateTime.now();
    _lastResult = null;

    // === Timer starten ===
    _startTimer();
    _persistQuiz();

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
    _clearSavedQuiz();

    // Berechne verstrichene Zeit
    final timeTaken = _quizStartTime != null
        ? DateTime.now().difference(_quizStartTime!).inSeconds
        : _totalSeconds - _state.remainingSeconds;

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
    _persistQuiz();

    notifyListeners();
  }

  /// Löscht die Antwort für die aktuelle Frage (zurücksetzen).
  void clearAnswer() {
    if (!isRunning) return;

    final updatedAnswers = Map<int, int?>.from(_state.answers);
    updatedAnswers[_state.currentQuestionIndex] = null;

    _state = _state.copyWith(answers: updatedAnswers);
    _persistQuiz();

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
      _persistQuiz();
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
      _persistQuiz();
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
      _persistQuiz();
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
    // Verbleibende Zeit aus der Wanduhr berechnen (bleibt auch korrekt, wenn
    // die App im Hintergrund war und der Timer pausiert hat).
    final elapsed = _quizStartTime != null
        ? DateTime.now().difference(_quizStartTime!).inSeconds
        : _totalSeconds - _state.remainingSeconds + 1;
    final newRemaining = _totalSeconds - elapsed;

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
    _clearSavedQuiz();

    // Berechne verstrichene Zeit
    final timeTaken = _quizStartTime != null
        ? DateTime.now().difference(_quizStartTime!).inSeconds
        : _totalSeconds;

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
  // TEST FORTSETZEN (Persistenz)
  // ===========================================================================

  /// Ob ein unterbrochener Test mit Restzeit zum Fortsetzen bereitsteht.
  bool get hasResumableQuiz => !isRunning && _savedRemainingSeconds() > 0;

  /// Kurzbeschreibung des gespeicherten Tests, z. B. "Frage 12 von 33 · noch 41:20".
  String get resumableSummary {
    final saved = _saved;
    if (saved == null) return '';
    final total = (saved['questionIds'] as List).length;
    final index = (saved['currentIndex'] as int) + 1;
    final left = _savedRemainingSeconds();
    final mm = (left ~/ 60).toString().padLeft(2, '0');
    final ss = (left % 60).toString().padLeft(2, '0');
    return 'Frage $index von $total · noch $mm:$ss';
  }

  int _savedRemainingSeconds() {
    final saved = _saved;
    if (saved == null) return 0;
    final start = DateTime.fromMillisecondsSinceEpoch(saved['startMs'] as int);
    final elapsed = DateTime.now().difference(start).inSeconds;
    return (saved['totalSeconds'] as int) - elapsed;
  }

  /// Liest einen eventuell gespeicherten, unterbrochenen Test (beim App-Start).
  Future<void> loadSavedQuiz() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kActiveQuizKey);
      _saved = raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
      if (_saved != null && _savedRemainingSeconds() <= 0) {
        _saved = null;
        await prefs.remove(_kActiveQuizKey);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Fehler beim Laden des gespeicherten Tests: $e');
      _saved = null;
    }
  }

  /// Stellt den gespeicherten Test wieder her. Gibt false zurück, wenn das
  /// nicht möglich ist (abgelaufen, Fragen nicht mehr vorhanden).
  bool resumeSavedQuiz(List<Question> allQuestions) {
    final saved = _saved;
    if (saved == null || _savedRemainingSeconds() <= 0) return false;

    final byId = {for (final q in allQuestions) q.id: q};
    final questions = <Question>[];
    for (final id in (saved['questionIds'] as List).cast<int>()) {
      final q = byId[id];
      if (q == null) return false;
      questions.add(q);
    }

    _stopTimer();
    final answers = <int, int?>{
      for (var i = 0; i < questions.length; i++) i: null,
    };
    (saved['answers'] as Map<String, dynamic>).forEach((k, v) {
      answers[int.parse(k)] = v as int?;
    });

    _totalSeconds = saved['totalSeconds'] as int;
    _quizStartTime = DateTime.fromMillisecondsSinceEpoch(saved['startMs'] as int);
    _state = QuizState.start(
      questions: questions,
      selectedState: saved['state'] as String?,
      totalSeconds: _savedRemainingSeconds(),
    ).copyWith(
      answers: answers,
      currentQuestionIndex:
          (saved['currentIndex'] as int).clamp(0, questions.length - 1),
    );
    _lastResult = null;
    _startTimer();
    notifyListeners();
    return true;
  }

  Future<void> _persistQuiz() async {
    if (!isRunning || _quizStartTime == null) return;
    try {
      final data = <String, dynamic>{
        'questionIds': _state.questions.map((q) => q.id).toList(),
        'answers': _state.answers.map((k, v) => MapEntry(k.toString(), v)),
        'currentIndex': _state.currentQuestionIndex,
        'startMs': _quizStartTime!.millisecondsSinceEpoch,
        'totalSeconds': _totalSeconds,
        'state': _state.selectedState,
      };
      _saved = data;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kActiveQuizKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Fehler beim Speichern des Tests: $e');
    }
  }

  /// Verwirft einen gespeicherten, unterbrochenen Test (z. B. beim Zurücksetzen).
  Future<void> discardSavedQuiz() async {
    await _clearSavedQuiz();
    notifyListeners();
  }

  Future<void> _clearSavedQuiz() async {
    _saved = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kActiveQuizKey);
    } catch (e) {
      debugPrint('Fehler beim Löschen des gespeicherten Tests: $e');
    }
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
