import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Liest Fragen mit der Sprachausgabe des Geräts vor (offline, ohne Konto/Key).
class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<bool> speaking = ValueNotifier<bool>(false);
  bool _ready = false;

  static const Map<String, String> _locales = {
    'de': 'de-DE',
    'en': 'en-US',
    'ar': 'ar',
  };

  Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    _tts.setStartHandler(() => speaking.value = true);
    _tts.setCompletionHandler(() => speaking.value = false);
    _tts.setCancelHandler(() => speaking.value = false);
    _tts.setErrorHandler((_) => speaking.value = false);
    await _tts.setSpeechRate(0.45);
  }

  /// Startet das Vorlesen. Gibt false zurück, wenn die Sprache auf dem Gerät
  /// nicht verfügbar ist.
  Future<bool> speak(String text, String lang) async {
    try {
      await _init();
      final locale = _locales[lang] ?? 'de-DE';
      final available = await _tts.isLanguageAvailable(locale);
      if (available != true && available != 1) return false;
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _tts.speak(text);
      return true;
    } catch (e) {
      debugPrint('Sprachausgabe fehlgeschlagen: $e');
      speaking.value = false;
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('Sprachausgabe stoppen fehlgeschlagen: $e');
    }
    speaking.value = false;
  }
}
