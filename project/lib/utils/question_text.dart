import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/question.dart';

/// Frage mit Antworten als Text (A) ..., B) ...), z. B. zum Googeln.
String formatQuestionForCopy(Question q, {String lang = 'de'}) {
  final answers = q.answersFor(lang);
  final buf = StringBuffer(q.questionFor(lang));
  for (var i = 0; i < answers.length; i++) {
    buf.write('\n${String.fromCharCode(65 + i)}) ${answers[i]}');
  }
  return buf.toString();
}

/// Frage mit Antworten als Fließtext fürs Vorlesen (Punkte erzeugen Pausen).
String formatQuestionForSpeech(Question q, {String lang = 'de'}) {
  final answers = q.answersFor(lang);
  final buf = StringBuffer('${q.questionFor(lang)}\n');
  for (var i = 0; i < answers.length; i++) {
    buf.write('${String.fromCharCode(65 + i)}. ${answers[i]}.\n');
  }
  return buf.toString();
}

/// Kopiert die Frage in die Zwischenablage und bestätigt per Hinweis.
void copyQuestion(BuildContext context, Question q, {String lang = 'de'}) {
  Clipboard.setData(ClipboardData(text: formatQuestionForCopy(q, lang: lang)));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Frage kopiert'), duration: Duration(seconds: 2)),
  );
}
