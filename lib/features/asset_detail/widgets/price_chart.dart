import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_colors.dart';
import 'package:pecule/app/theme/pecule_fonts.dart';
import 'package:pecule/core/formatters.dart';
import 'package:pecule/domain/models/price_point.dart';

/// La courbe de la fiche, lisible au doigt : en glissant, un trait vertical,
/// un point et une bulle « date · cours » suivent le doigt (cahier des
/// charges, section 4.4).
class PriceChart extends StatelessWidget {
  const PriceChart({
    super.key,
    required this.points,
    required this.scrubIndex,
    required this.onScrub,
  });

  static const chartHeight = 200.0;
  static const _bubbleHeight = 26.0;

  final List<PricePoint> points;
  final int? scrubIndex;

  /// Le point touché, ou vide quand le doigt quitte la courbe.
  final ValueChanged<int?> onScrub;

  @override
  Widget build(BuildContext context) {
    final colors = context.peculeColors;
    final colorScheme = Theme.of(context).colorScheme;
    final isUp = points.length < 2 || points.last.value >= points.first.value;
    final lineColor = isUp ? colors.gain : colors.loss;
    final scrubIndex = this.scrubIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int indexAt(double dx) {
          if (points.length < 2) return 0;
          final fraction = (dx / width).clamp(0.0, 1.0);
          return (fraction * (points.length - 1)).round();
        }

        return Column(
          children: [
            SizedBox(
              height: _bubbleHeight,
              child: scrubIndex == null
                  ? null
                  : Align(
                      alignment: Alignment(_xFraction(scrubIndex) * 2 - 1, 0),
                      child: _ScrubBubble(point: points[scrubIndex]),
                    ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  onScrub(indexAt(details.localPosition.dx)),
              onTapUp: (_) => onScrub(null),
              onHorizontalDragStart: (details) =>
                  onScrub(indexAt(details.localPosition.dx)),
              onHorizontalDragUpdate: (details) =>
                  onScrub(indexAt(details.localPosition.dx)),
              onHorizontalDragEnd: (_) => onScrub(null),
              onHorizontalDragCancel: () => onScrub(null),
              child: CustomPaint(
                size: Size(width, chartHeight),
                painter: _PriceChartPainter(
                  points: points,
                  lineColor: lineColor,
                  scrubIndex: scrubIndex,
                  scrubLineColor: colors.trace,
                  scrubDotColor: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _xFraction(int index) =>
      points.length < 2 ? 0 : index / (points.length - 1);
}

class _ScrubBubble extends StatelessWidget {
  const _ScrubBubble({required this.point});

  final PricePoint point;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${formatDay(point.day)} · ${formatPriceEur(point.value)}',
        style: TextStyle(
          fontFamily: PeculeFonts.mono,
          fontSize: 11,
          color: colorScheme.surface,
        ),
      ),
    );
  }
}

class _PriceChartPainter extends CustomPainter {
  _PriceChartPainter({
    required this.points,
    required this.lineColor,
    required this.scrubIndex,
    required this.scrubLineColor,
    required this.scrubDotColor,
  });

  static const _verticalPadding = 10.0;
  static const _lineWidth = 2.2;
  static const _areaOpacity = 0.08;
  static const _dotRadius = 6.0;
  static const _haloRadius = 10.0;

  final List<PricePoint> points;
  final Color lineColor;
  final int? scrubIndex;
  final Color scrubLineColor;
  final Color scrubDotColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final offsets = _offsetsFor(size);
    final line = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      line.lineTo(offset.dx, offset.dy);
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas
      ..drawPath(
        area,
        Paint()..color = lineColor.withValues(alpha: _areaOpacity),
      )
      ..drawPath(
        line,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _lineWidth
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );

    final scrubIndex = this.scrubIndex;
    if (scrubIndex != null) _paintScrub(canvas, size, offsets[scrubIndex]);
  }

  void _paintScrub(Canvas canvas, Size size, Offset point) {
    canvas
      ..drawLine(
        Offset(point.dx, 0),
        Offset(point.dx, size.height),
        Paint()
          ..color = scrubLineColor
          ..strokeWidth = 1,
      )
      ..drawCircle(
        point,
        _haloRadius,
        Paint()..color = scrubDotColor.withValues(alpha: 0.18),
      )
      ..drawCircle(point, _dotRadius, Paint()..color = scrubDotColor);
  }

  // Le cours le plus bas en bas, le plus haut en haut, avec une marge pour
  // que le trait ne touche pas les bords.
  List<Offset> _offsetsFor(Size size) {
    final values = points.map((point) => point.value);
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    final range = high - low == 0 ? 1.0 : high - low;
    final drawableHeight = size.height - 2 * _verticalPadding;

    return [
      for (var index = 0; index < points.length; index++)
        Offset(
          index / (points.length - 1) * size.width,
          _verticalPadding +
              drawableHeight * (1 - (points[index].value - low) / range),
        ),
    ];
  }

  @override
  bool shouldRepaint(_PriceChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.scrubIndex != scrubIndex ||
      oldDelegate.lineColor != lineColor;
}
