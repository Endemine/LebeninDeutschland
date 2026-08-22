import 'package:flutter/material.dart';

/// Zentrale Schriftdefinition der App.
///
/// Roboto ist als Variable Font unter `assets/fonts/Roboto.ttf` gebuendelt.
/// Frueher lief das ueber das Paket `google_fonts`, das die Schrift beim
/// ersten Start von Googles Servern nachgeladen und dabei die IP-Adresse des
/// Nutzers uebertragen hat. Fuer eine App mit deutscher Zielgruppe ist das der
/// Fall, den das LG Muenchen I (Urteil vom 20.01.2022, Az. 3 O 17493/20) als
/// DSGVO-Verstoss gewertet hat. Gebuendelt findet keine Uebertragung statt,
/// ausserdem funktioniert die Schrift offline und ohne Nachlade-Flackern.
///
/// [fontVariations] setzt die `wght`-Achse explizit: Bei Variable Fonts leitet
/// nicht jede Plattform das Gewicht zuverlaessig aus [fontWeight] ab.
TextStyle roboto({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
  double? letterSpacing,
  FontStyle? fontStyle,
  TextDecoration? decoration,
}) {
  final weight = fontWeight ?? FontWeight.w400;
  return TextStyle(
    fontFamily: 'Roboto',
    fontSize: fontSize,
    fontWeight: weight,
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
    decoration: decoration,
  );
}
