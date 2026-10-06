import 'package:pecule/domain/models/position.dart';

class ValuedPosition {
  const ValuedPosition({required this.position, required this.valueEur});

  final Position position;
  final double valueEur;
}

/// Portefeuille dont chaque ligne a une valeur strictement positive. On
/// l'obtient avec `valuePortfolio`, qui écarte les cas impossibles : les
/// calculs qui en partent n'ont plus à les gérer.
class ValuedPortfolio {
  ValuedPortfolio(this.lines) : assert(lines.isNotEmpty);

  final List<ValuedPosition> lines;

  double get totalValueEur =>
      lines.fold<double>(0, (sum, line) => sum + line.valueEur);

  double get investedEur =>
      lines.fold<double>(0, (sum, line) => sum + line.position.investedEur);

  double get gainEur => totalValueEur - investedEur;
}
