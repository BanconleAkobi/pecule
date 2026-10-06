import 'package:intl/intl.dart';

// Espaces insécables : la fine entre les milliers, la normale avant l'unité.
const _thousandsSpace = ' ';
const _unitSpace = ' ';
const _minus = '−';
const _locale = 'fr_FR';

String formatEur(double amount) =>
    '${_signedNumber(amount, '#,##0.00')}$_unitSpace€';

/// Trois décimales sous 1 €, pour qu'un cours comme celui du Dogecoin reste
/// lisible.
String formatPriceEur(double price) {
  final pattern = price.abs() < 1 ? '#,##0.000' : '#,##0.00';
  return '${_signedNumber(price, pattern)}$_unitSpace€';
}

String formatEurRounded(double amount) =>
    '${_signedNumber(amount, '#,##0')}$_unitSpace€';

String formatSignedEur(double amount) =>
    '${_signedNumber(amount, '#,##0.00', showPlus: true)}$_unitSpace€';

/// [ratio] : 0,126 pour une hausse de 12,6 %.
String formatPercent(double ratio) =>
    '${_signedNumber(ratio * 100, '#,##0.0', showPlus: true)}$_unitSpace%';

// La flèche double la couleur : un gain ou une perte se lit sans elle.
String formatPercentWithArrow(double ratio) {
  final percent = formatPercent(ratio);
  final arrow = percent.startsWith(_minus) ? '▼' : '▲';
  return '$arrow $percent';
}

/// Ordre de grandeur sans signe, pour les phrases : « environ 22 % ».
String formatRoundPercent(double ratio) =>
    '${_digits((ratio * 100).abs().roundToDouble(), '#,##0')}$_unitSpace%';

/// Écart entre deux performances, en points, sans signe : « 5,4 ».
String formatPoints(double ratioDifference) =>
    _digits((ratioDifference * 100).abs(), '#,##0.#');

String formatQuantity(double quantity, {required String symbol}) =>
    '${_digits(quantity, '#,##0.####')}$_unitSpace$symbol';

String formatRate(double rate) => _digits(rate, '0.0000');

/// Valeur d'un euro en dollars, pour les phrases : « 1,05 $ ».
String formatUsdPerEuro(double rate) => '${_digits(rate, '0.00')}$_unitSpace\$';

/// [day] : jour de cotation à minuit UTC, affiché tel quel.
String formatDay(DateTime day) => DateFormat('d MMM y', _locale).format(day);

/// Moment d'une mise à jour, à l'heure du téléphone : « 4 oct. à 18:02 ».
String formatDayAndTime(DateTime moment) =>
    DateFormat("d MMM 'à' HH:mm", _locale).format(moment.toLocal());

String formatUpdatedAt(DateTime updatedAt) =>
    'Mis à jour le ${formatDayAndTime(updatedAt)}';

String formatTradingDayUsed(DateTime day) =>
    DateFormat("'Cours du' EEEE d MMMM 'utilisé'", _locale).format(day);

// Le signe vient de la valeur affichée, pas de la valeur brute : −0,0004
// s'arrondit à zéro et ne doit pas s'afficher « −0,0 % ».
String _signedNumber(double value, String pattern, {bool showPlus = false}) {
  final digits = _digits(value.abs(), pattern);
  final roundsToZero = !digits.contains(RegExp('[1-9]'));
  if (value < 0 && !roundsToZero) return '$_minus$digits';
  return showPlus ? '+$digits' : digits;
}

String _digits(double value, String pattern) {
  final formatted = NumberFormat(pattern, _locale).format(value);
  return formatted.replaceAll(RegExp('[   ]'), _thousandsSpace);
}
