import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _licensePathByFamily = {
  'Instrument Serif': 'assets/fonts/instrument_serif/OFL.txt',
  'Schibsted Grotesk': 'assets/fonts/schibsted_grotesk/OFL.txt',
  'JetBrains Mono': 'assets/fonts/jetbrains_mono/OFL.txt',
};

void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: family, value: path)
        in _licensePathByFamily.entries) {
      final license = await rootBundle.loadString(path);
      yield LicenseEntryWithLineBreaks([family], license);
    }
  });
}
