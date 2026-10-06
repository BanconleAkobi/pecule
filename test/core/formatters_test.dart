import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pecule/core/formatters.dart';

// Espaces insécables : la fine entre les milliers, la normale avant l'unité.
// Elles empêchent un retour à la ligne au milieu d'un nombre ou avant « € ».
const thousands = ' ';
const unit = ' ';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('montants', () {
    test('affiche deux décimales et l\'euro après le nombre', () {
      expect(formatEur(1234.56), '1${thousands}234,56$unit€');
    });

    test('affiche zéro avec ses décimales', () {
      expect(formatEur(0), '0,00$unit€');
    });

    test('affiche trois décimales pour un cours inférieur à 1 €', () {
      expect(formatPriceEur(0.214), '0,214$unit€');
    });

    test('garde deux décimales pour un cours d\'au moins 1 €', () {
      expect(formatPriceEur(214.3), '214,30$unit€');
    });

    test('arrondit à l\'euro pour les montants de simulation', () {
      expect(formatEurRounded(2250.4), '2${thousands}250$unit€');
    });

    test('signe un gain avec +', () {
      expect(formatSignedEur(482.17), '+482,17$unit€');
    });

    test('signe une perte avec le vrai signe moins', () {
      expect(formatSignedEur(-50), '−50,00$unit€');
    });
  });

  group('pourcentages', () {
    test('affiche une hausse avec + et une décimale', () {
      expect(formatPercent(0.126), '+12,6$unit%');
    });

    test('affiche une baisse avec le vrai signe moins', () {
      expect(formatPercent(-0.084), '−8,4$unit%');
    });

    test('affiche zéro avec +', () {
      expect(formatPercent(0), '+0,0$unit%');
    });

    test('n\'affiche pas −0,0 % pour une baisse arrondie à zéro', () {
      expect(formatPercent(-0.0004), '+0,0$unit%');
    });

    test('sépare les milliers d\'un très grand pourcentage', () {
      expect(formatPercent(12.345), '+1${thousands}234,5$unit%');
    });

    test('ajoute une flèche montante à une hausse', () {
      expect(formatPercentWithArrow(0.126), '▲ +12,6$unit%');
    });

    test('ajoute une flèche descendante à une baisse', () {
      expect(formatPercentWithArrow(-0.084), '▼ −8,4$unit%');
    });
  });

  group('quantités et taux', () {
    test('affiche une petite quantité avec son symbole', () {
      expect(formatQuantity(0.0054, symbol: 'BTC'), '0,0054${unit}BTC');
    });

    test('n\'ajoute pas de zéros inutiles à une quantité', () {
      expect(formatQuantity(1.5, symbol: 'AAPL'), '1,5${unit}AAPL');
    });

    test('arrondit une quantité à quatre décimales', () {
      expect(formatQuantity(0.123456, symbol: 'ETH'), '0,1235${unit}ETH');
    });

    test('affiche un taux de change avec quatre décimales', () {
      expect(formatRate(1.1), '1,1000');
    });

    test('affiche la valeur d\'un euro en dollars pour une phrase', () {
      expect(formatUsdPerEuro(1.0952), '1,10$unit\$');
    });

    test('arrondit un pourcentage sans signe pour une phrase', () {
      expect(formatRoundPercent(-0.2149), '21$unit%');
    });

    test('affiche un écart de performance en points, sans signe', () {
      expect(formatPoints(-0.0536), '5,4');
    });
  });

  group('dates', () {
    test('affiche un jour au format court', () {
      expect(formatDay(DateTime.utc(2026, 10, 4)), '4 oct. 2026');
    });

    test('affiche un jour et une heure, pour le bandeau hors connexion', () {
      expect(formatDayAndTime(DateTime(2026, 10, 4, 18, 2)), '4 oct. à 18:02');
    });

    test('affiche la date et l\'heure de mise à jour', () {
      expect(
        formatUpdatedAt(DateTime(2026, 10, 4, 18, 2)),
        'Mis à jour le 4 oct. à 18:02',
      );
    });

    test('nomme le jour de cotation utilisé à la place d\'un jour fermé', () {
      expect(
        formatTradingDayUsed(DateTime.utc(2026, 1, 2)),
        'Cours du vendredi 2 janvier utilisé',
      );
    });
  });
}
