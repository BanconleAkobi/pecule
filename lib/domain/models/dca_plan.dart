enum DcaFrequency { weekly, monthly }

class DcaPlan {
  const DcaPlan({
    required this.periodicAmountEur,
    required this.frequency,
    required this.startDate,
  });

  final double periodicAmountEur;
  final DcaFrequency frequency;
  final DateTime startDate;
}
