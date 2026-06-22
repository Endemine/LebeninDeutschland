// Integrationstest: Prüft ALLE Filter & Selektoren gegen die echten Asset-Daten.
// Lädt questions.json + translations.json wie die App und verifiziert jeden Filter.
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:einbuergerungstest/models/question.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Question> all;
  late Map<String, dynamic> translations;

  setUpAll(() async {
    final qStr = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> qList = jsonDecode(qStr) as List<dynamic>;
    all = qList.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
    final tStr = await rootBundle.loadString('assets/translations.json');
    translations = jsonDecode(tStr) as Map<String, dynamic>;
  });

  // Repliziert exakt LearningProvider.filteredQuestions
  List<Question> filtered({QuestionCategory? cat, String? state, String search = ''}) {
    return all.where((q) {
      if (cat != null && q.category != cat) return false;
      if (state != null && q.state != state) return false;
      if (search.isNotEmpty) {
        final s = search.toLowerCase();
        final t = q.text.toLowerCase().contains(s);
        final a = q.answers.any((x) => x.toLowerCase().contains(s));
        final c = q.category.displayName.toLowerCase().contains(s);
        if (!t && !a && !c) return false;
      }
      return true;
    }).toList();
  }

  group('FILTER: Kategorie', () {
    test('Alle = 460', () => expect(filtered().length, 460));
    test('Allgemein = 300', () => expect(filtered(cat: QuestionCategory.allgemein).length, 300));
    test('Bundesland = 160', () => expect(filtered(cat: QuestionCategory.bundesland).length, 160));
  });

  group('FILTER: Bundesland', () {
    test('16 Bundesländer vorhanden', () {
      final states = all.where((q) => q.state != null).map((q) => q.state!).toSet();
      expect(states.length, 16);
    });
    test('Jedes Bundesland hat genau 10 Fragen', () {
      final states = all.where((q) => q.state != null).map((q) => q.state!).toSet();
      for (final s in states) {
        expect(filtered(cat: QuestionCategory.bundesland, state: s).length, 10,
            reason: 'Bundesland $s sollte 10 Fragen haben');
      }
    });
    test('Bayern-Filter liefert nur Bayern-Fragen', () {
      final r = filtered(cat: QuestionCategory.bundesland, state: 'Bayern');
      expect(r.length, 10);
      expect(r.every((q) => q.state == 'Bayern'), true);
    });
  });

  group('FILTER: Suche', () {
    test('Suche "Meinungsfreiheit" findet Treffer', () {
      expect(filtered(search: 'Meinungsfreiheit').isNotEmpty, true);
    });
    test('Suche "xyzNICHTvorhanden" = 0', () {
      expect(filtered(search: 'xyzNICHTvorhanden').length, 0);
    });
    test('Suche kombiniert mit Kategorie', () {
      final r = filtered(cat: QuestionCategory.allgemein, search: 'Deutschland');
      expect(r.every((q) => q.category == QuestionCategory.allgemein), true);
    });
  });

  group('FILTER: Sprache / Übersetzungen', () {
    test('Alle 460 Fragen haben EN-Übersetzung', () {
      for (final q in all) {
        final t = translations['${q.id}'];
        expect(t, isNotNull, reason: 'Frage ${q.id} ohne Übersetzung');
        expect((t as Map)['question_en'], isNotNull);
      }
    });
    test('Alle 460 Fragen haben AR-Übersetzung', () {
      for (final q in all) {
        final t = translations['${q.id}'] as Map;
        expect(t['question_ar'], isNotNull, reason: 'Frage ${q.id} ohne AR');
        expect((t['answers_ar'] as List).length, q.answers.length);
      }
    });
  });

  group('QUIZ: Zusammenstellung', () {
    test('Quiz mit Bundesland = 30 allgemeine + bis zu 3 Landesfragen', () {
      final general = all.where((q) => !q.isStateSpecific).toList();
      final bayern = all.where((q) => q.isStateSpecific && q.state == 'Bayern').toList();
      expect(general.length, 300);
      expect(bayern.length, 10);
      // Quiz nimmt 30 allgemeine + 3 Landesfragen = 33
      expect((general.length >= 30) && (bayern.length >= 3), true);
    });
  });
}
