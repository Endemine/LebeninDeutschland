// Prüft die Fragendaten auf Zuordnungsfehler.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bundesland-Label passt zum im Fragetext genannten Land', () {
    final qs = jsonDecode(File('assets/questions.json').readAsStringSync()) as List;
    const states = [
      'Baden-Württemberg', 'Bayern', 'Berlin', 'Brandenburg', 'Bremen', 'Hamburg',
      'Hessen', 'Mecklenburg-Vorpommern', 'Niedersachsen', 'Nordrhein-Westfalen',
      'Rheinland-Pfalz', 'Saarland', 'Sachsen-Anhalt', 'Sachsen',
      'Schleswig-Holstein', 'Thüringen',
    ];
    final wrong = <int>[];
    final perState = <String, int>{};
    for (final q in qs.cast<Map<String, dynamic>>()) {
      final label = q['state'] as String?;
      if (label == null) continue;
      perState[label] = (perState[label] ?? 0) + 1;
      var text = q['question'] as String;
      for (final s in states) {
        if (text.contains(s)) {
          if (s != label) wrong.add(q['id'] as int);
          break;
        }
      }
    }
    expect(wrong, isEmpty);
    expect(perState.length, 16);
    expect(perState.values.every((n) => n == 10), true);
  });

  test('Alle Bildpfade existieren und Bild-Fragen sind vollständig', () {
    final qs = (jsonDecode(File('assets/questions.json').readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    final missingFiles = <String>[];
    final imageNeeded = <int>[];
    for (final q in qs) {
      final paths = <String>[
        if (q['image'] is String) q['image'] as String,
        for (final a in (q['answerImages'] as List? ?? const []))
          if (a is String) a,
      ];
      for (final p in paths) {
        if (!File(p).existsSync()) missingFiles.add('${q['id']}: $p');
      }
      final answers = (q['answers'] as List).cast<String>().map((a) => a.trim()).toList();
      final numbered = answers.join(',') == '1,2,3,4' || answers.toSet().containsAll({'1', '2', '3', '4'});
      final text = q['question'] as String;
      final refersToPicture = numbered || text.contains('dieses Bild');
      if (refersToPicture) {
        final hasQuestionImage = q['image'] is String;
        final ai = q['answerImages'] as List?;
        final allAnswerImages = ai != null && ai.length == 4 && ai.every((e) => e is String);
        if (!hasQuestionImage && !allAnswerImages) imageNeeded.add(q['id'] as int);
      }
    }
    expect(missingFiles, isEmpty);
    expect(imageNeeded, isEmpty, reason: 'Fragen mit Bildbezug ohne Bild');
  });
}
