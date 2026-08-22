// Stellt sicher, dass die Schrift aus dem Bundle kommt und nicht wieder
// zur Laufzeit von Googles Servern geladen wird (siehe lib/app_fonts.dart).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:einbuergerungstest/app_fonts.dart';

void main() {
  test('roboto() nutzt die gebuendelte Familie', () {
    final style = roboto(fontSize: 16, fontWeight: FontWeight.w700);
    expect(style.fontFamily, 'Roboto');
    expect(style.fontSize, 16);
    expect(style.fontWeight, FontWeight.w700);
  });

  test('Gewicht wird als wght-Achse gesetzt', () {
    // Variable Fonts leiten das Gewicht nicht auf jeder Plattform zuverlaessig
    // aus fontWeight ab -- die Achse muss explizit mitgegeben werden.
    for (final w in [FontWeight.w400, FontWeight.w500, FontWeight.w600,
                     FontWeight.w700, FontWeight.w800]) {
      final variations = roboto(fontWeight: w).fontVariations;
      expect(variations, isNotNull, reason: 'keine fontVariations fuer $w');
      expect(variations!.single.axis, 'wght');
      expect(variations.single.value, w.value.toDouble());
    }
  });

  test('ohne Angabe Regular (400)', () {
    expect(roboto().fontVariations!.single.value, 400.0);
  });
}
