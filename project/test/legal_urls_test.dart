// Die Rechtstext-URLs muessen erreichbar sein.
//
// Zuvor zeigten sie auf https://lebenindeutschland.de/privacy -- eine 404.
// Damit lief der Datenschutz-Button in der App ins Leere und Apple pruefte
// eine tote Datenschutz-URL (Guideline 5.1.1). Der Test prueft die Form, nicht
// die Erreichbarkeit: Unit-Tests duerfen nicht vom Netz abhaengen.
import 'package:flutter_test/flutter_test.dart';
import 'package:einbuergerungstest/app_info.dart';

void main() {
  test('Datenschutz- und Impressum-URL sind absolut und https', () {
    for (final url in [kPrivacyUrl, kImprintUrl]) {
      final uri = Uri.tryParse(url);
      expect(uri, isNotNull, reason: '$url ist keine gueltige URI');
      expect(uri!.isAbsolute, isTrue, reason: '$url ist nicht absolut');
      expect(uri.scheme, 'https', reason: '$url ist nicht https');
      expect(uri.host, isNotEmpty);
      expect(uri.path, isNot(anyOf('', '/')),
          reason: '$url zeigt auf die Wurzel statt auf die Rechtstextseite');
    }
  });

  test('Version stimmt mit dem Format aus pubspec ueberein', () {
    expect(RegExp(r'^\d+\.\d+\.\d+$').hasMatch(kAppVersion), isTrue,
        reason: 'kAppVersion muss x.y.z sein, ist "$kAppVersion"');
  });
}
