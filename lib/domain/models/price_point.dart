/// Un point de courbe : un jour et une valeur, déjà convertie en euros.
class PricePoint {
  const PricePoint({required this.day, required this.value});

  final DateTime day;
  final double value;
}
