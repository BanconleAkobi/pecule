import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/computed.dart';

void main() {
  test('deux résultats disponibles de même valeur sont égaux', () {
    expect(const Available(0.2), const Available(0.2));
  });

  test(
    'deux résultats disponibles de valeurs différentes ne sont pas égaux',
    () {
      expect(const Available(0.2), isNot(const Available(0.3)));
    },
  );

  test('deux résultats indisponibles pour la même raison sont égaux', () {
    expect(
      const Unavailable<double>(UnavailableReason.nothingInvested),
      const Unavailable<double>(UnavailableReason.nothingInvested),
    );
  });

  test('deux résultats indisponibles pour des raisons différentes ne sont pas égaux', () {
    expect(
      const Unavailable<double>(UnavailableReason.nothingInvested),
      isNot(const Unavailable<double>(UnavailableReason.emptyPortfolio)),
    );
  });
}
