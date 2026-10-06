import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/remote/dto/twelve_data_dto.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('série de cours', () {
    final series = TwelveDataTimeSeriesDto.fromJson(
      readJsonObjectFixture('twelve_data_time_series_aapl.json'),
    );

    test('lit le symbole et la devise', () {
      expect(series.symbol, 'AAPL');
      expect(series.currency, 'USD');
    });

    test('lit un cours par jour de cotation, dans l\'ordre demandé', () {
      expect(series.bars, hasLength(9));
      expect(series.bars.first.day, DateTime.utc(2026, 9, 21));
      expect(series.bars.last.day, DateTime.utc(2026, 10, 1));
    });

    test('convertit en nombres les prix que l\'API donne en texte', () {
      final firstBar = series.bars.first;

      expect(firstBar.open, 335.28);
      expect(firstBar.high, 339.64001);
      expect(firstBar.low, 333.049988);
      expect(firstBar.close, 338.98001);
      expect(firstBar.volume, 34999200);
    });
  });

  group('erreur', () {
    final json = readJsonObjectFixture('twelve_data_error_unknown_symbol.json');

    test('reconnaît une réponse en erreur', () {
      expect(TwelveDataErrorDto.isError(json), isTrue);
    });

    test('ne prend pas une série de cours pour une erreur', () {
      final series = readJsonObjectFixture('twelve_data_time_series_aapl.json');

      expect(TwelveDataErrorDto.isError(series), isFalse);
    });

    test('lit le code et le message d\'une erreur', () {
      final error = TwelveDataErrorDto.fromJson(json);

      expect(error.code, 404);
      expect(error.message, contains('symbol'));
    });

    test('reconnaît l\'erreur « aucun cours sur ces dates »', () {
      final error = TwelveDataErrorDto.fromJson(
        readJsonObjectFixture('twelve_data_no_data.json'),
      );

      expect(error.isNoDataForDates, isTrue);
    });

    test('ne confond pas une autre erreur avec l\'absence de cours', () {
      expect(TwelveDataErrorDto.fromJson(json).isNoDataForDates, isFalse);
    });
  });
}
