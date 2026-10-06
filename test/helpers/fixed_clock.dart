import 'package:pecule/core/clock.dart';

class FixedClock implements Clock {
  FixedClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}
