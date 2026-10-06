import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/chart_period.dart';
import 'package:pecule/domain/models/currency_effect.dart';
import 'package:pecule/features/asset_detail/asset_detail_texts.dart';

const unit = ' ';

CurrencyEffect effect({
  required double usd,
  required double eur,
  required double from,
  required double to,
}) => CurrencyEffect(
  performanceUsd: usd,
  performanceEur: eur,
  rateAtStart: from,
  rateAtEnd: to,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('période', () {
    test('légende la variation d\'un mois', () {
      expect(periodCaption(ChartPeriod.oneMonth), 'sur 1 mois');
    });

    test('légende la variation de tout l\'historique', () {
      expect(periodCaption(ChartPeriod.max), 'depuis le début');
    });
  });

  group('feuille « En clair »', () {
    test('traduit la variation de la période en euros concrets', () {
      expect(
        explainChangeText(
          assetName: 'Apple',
          change: 0.2,
          period: ChartPeriod.oneYear,
          isScrubbing: false,
        ),
        'Si tu avais mis 100 € dans Apple il y a un an, tu aurais '
        '120,00$unit€ aujourd\'hui.',
      );
    });

    test('s\'arrête au point touché pendant la lecture au doigt', () {
      expect(
        explainChangeText(
          assetName: 'Apple',
          change: -0.1,
          period: ChartPeriod.oneYear,
          isScrubbing: true,
        ),
        'Si tu avais mis 100 € dans Apple au début de la période, tu aurais '
        '90,00$unit€ à cette date.',
      );
    });

    test('titre la feuille avec la variation', () {
      expect(explainChangeTitle(0.161), '+16,1$unit%, en clair');
    });
  });

  group('dollar ou euro', () {
    test('explique la perte due à la hausse de l\'euro', () {
      final text = currencyEffectText(
        effect(usd: 0.18, eur: 0.1264, from: 1.05, to: 1.10),
      );

      expect(
        text,
        'Sur la période, l\'euro est passé de 1,05$unit\$ à 1,10$unit\$. '
        'Tes dollars valent donc moins d\'euros : 5,4 points de moins pour toi.',
      );
    });

    test('explique le gain dû à la baisse de l\'euro', () {
      final text = currencyEffectText(
        effect(usd: 0, eur: 0.1, from: 1.10, to: 1.00),
      );

      expect(text, contains('10 points de plus pour toi'));
    });

    test('dit quand le taux n\'a presque pas bougé', () {
      final text = currencyEffectText(
        effect(usd: 0.2, eur: 0.2, from: 1.10, to: 1.10),
      );

      expect(text, contains('presque pas bougé'));
    });
  });

  group('cartes « Ça veut dire quoi ? »', () {
    test('traduit la performance d\'un an en euros concrets', () {
      expect(
        performanceCardText(assetName: 'Apple', yearChange: 0.126),
        'Si tu avais mis 100 € dans Apple il y a un an, tu aurais '
        'aujourd\'hui 112,60$unit€.',
      );
    });

    test('qualifie de très calme une action peu volatile', () {
      expect(
        volatilityCardText(
          assetName: 'Coca-Cola',
          type: AssetType.stock,
          volatility: 0.15,
        ),
        'Sur un an, le cours de Coca-Cola s\'est éloigné de sa moyenne '
        'd\'environ 15$unit%. C\'est très calme pour une action.',
      );
    });

    test('qualifie de très agitée une crypto très volatile', () {
      expect(
        volatilityCardText(
          assetName: 'Dogecoin',
          type: AssetType.crypto,
          volatility: 0.95,
        ),
        endsWith('C\'est très agité pour une crypto.'),
      );
    });

    test('traduit la plus forte baisse', () {
      expect(
        drawdownCardText(maxDrawdown: -0.31),
        'Au pire moment de l\'année, quelqu\'un qui avait acheté au plus haut '
        'perdait 31$unit%.',
      );
    });
  });
}
