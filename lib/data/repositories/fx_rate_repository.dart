import 'package:pecule/core/cached_data.dart';
import 'package:pecule/data/local/fx_rate_dao.dart';
import 'package:pecule/data/remote/dto/frankfurter_dto.dart';
import 'package:pecule/data/remote/frankfurter_client.dart';
import 'package:pecule/data/repositories/incremental_sync.dart';
import 'package:pecule/domain/calculations/trading_calendar.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/fx_rate.dart';

class FxRateRepository {
  FxRateRepository({
    required this._fxRates,
    required this._frankfurter,
    required this._sync,
  });

  static final historyStart = DateTime.utc(2020, 1, 1);

  final FxRateDao _fxRates;
  final FrankfurterClient _frankfurter;
  final IncrementalSync _sync;

  /// Taux EUR/USD : dollars pour un euro.
  Stream<CachedData<List<FxRate>>> watchEurUsdRates({
    bool forceRefresh = false,
  }) {
    return _sync.watch(
      _EurUsdRates(fxRates: _fxRates, frankfurter: _frankfurter),
      forceRefresh: forceRefresh,
    );
  }
}

class _EurUsdRates implements SyncedSeries<FxRate> {
  _EurUsdRates({required this.fxRates, required this.frankfurter});

  final FxRateDao fxRates;
  final FrankfurterClient frankfurter;

  @override
  String get resourceKey => 'fx:EUR:USD';

  @override
  PublicationSchedule get schedule => fxRatesSchedule;

  @override
  bool get rewritesLastDay => false;

  @override
  DateTime firstDownloadStart(DateTime now) => FxRateRepository.historyStart;

  @override
  DateTime dayOf(FxRate item) => item.day;

  @override
  Future<List<FxRate>> readCached() =>
      fxRates.findRates(base: Currency.eur, quote: Currency.usd);

  @override
  Future<List<FxRate>> download({required DateTime since}) async {
    final rates = await frankfurter.fetchEurUsdRates(from: since);
    return rates.map(_toFxRate).toList();
  }

  @override
  Future<void> save(List<FxRate> items) => fxRates.saveRates(items);

  FxRate _toFxRate(FrankfurterRateDto rate) => FxRate(
    day: rate.day,
    base: Currency.fromCode(rate.base),
    quote: Currency.fromCode(rate.quote),
    rate: rate.rate,
  );
}
