import 'package:flutter/material.dart';

import '../services/speech_service.dart';

/// Lautsprecher-Button: liest [text] in [lang] vor, nochmal tippen stoppt.
/// Mit `key: ValueKey(frageId)` verwenden, damit beim Fragenwechsel automatisch
/// gestoppt wird.
class SpeakButton extends StatefulWidget {
  final String text;
  final String lang;
  const SpeakButton({super.key, required this.text, this.lang = 'de'});

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<SpeakButton> {
  static const Color _primary = Color(0xFFFF6B00);
  static const Color _textTertiary = Color(0xFFC7C7CC);
  bool _started = false;

  @override
  void dispose() {
    if (_started) SpeechService.instance.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    final service = SpeechService.instance;
    if (service.speaking.value) {
      await service.stop();
      return;
    }
    final ok = await service.speak(widget.text, widget.lang);
    _started = ok;
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Sprachausgabe für diese Sprache ist auf dem Gerät nicht installiert '
            '(Einstellungen > Sprachausgabe).'),
        duration: Duration(seconds: 4),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SpeechService.instance.speaking,
      builder: (context, speaking, _) {
        final active = speaking && _started;
        return GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 4),
            child: Icon(
              active ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
              color: active ? _primary : _textTertiary,
              size: 21,
            ),
          ),
        );
      },
    );
  }
}
