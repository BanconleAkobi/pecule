import 'package:pecule/domain/computed.dart';

/// Variation entre deux cours : +0,18 pour une hausse de 18 %.
Computed<double> computeVariation({
  required double start,
  required double end,
}) {
  if (start <= 0) return const Unavailable(UnavailableReason.invalidPrice);
  return Available(end / start - 1);
}
