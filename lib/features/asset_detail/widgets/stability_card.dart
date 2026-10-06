import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_colors.dart';
import 'package:pecule/app/theme/pecule_fonts.dart';
import 'package:pecule/core/formatters.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/stability_score.dart';
import 'package:pecule/features/asset_detail/asset_detail_texts.dart';

/// Le score de stabilité, sa jauge et, au toucher, d'où il vient : les deux
/// notes, leurs valeurs brutes et la formule en mots simples (cahier des
/// charges, section 8.5).
class StabilityCard extends StatefulWidget {
  const StabilityCard({super.key, required this.stability});

  final Computed<StabilityScore> stability;

  @override
  State<StabilityCard> createState() => _StabilityCardState();
}

class _StabilityCardState extends State<StabilityCard> {
  var _isDetailOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Score de stabilité', style: theme.textTheme.headlineSmall),
              Text('1 AN', style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 18),
          switch (widget.stability) {
            Available(value: final score) => _ScoreContent(
              score: score,
              isDetailOpen: _isDetailOpen,
              onToggleDetail: () =>
                  setState(() => _isDetailOpen = !_isDetailOpen),
            ),
            Unavailable() => Text(
              notEnoughHistory,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          },
          const SizedBox(height: 14),
          Text(
            pastDisclaimer,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

class _ScoreContent extends StatelessWidget {
  const _ScoreContent({
    required this.score,
    required this.isDetailOpen,
    required this.onToggleDetail,
  });

  final StabilityScore score;
  final bool isDetailOpen;
  final VoidCallback onToggleDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _levelColor(context, score.level);

    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 124,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: const Size(220, 124),
                painter: _GaugePainter(
                  share: score.value / 100,
                  color: color,
                  trackColor: theme.colorScheme.surfaceContainerHigh,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '${score.value}',
                      style: const TextStyle(
                        fontFamily: PeculeFonts.serif,
                        fontSize: 50,
                        height: 1,
                      ),
                      children: [
                        TextSpan(
                          text: '/100',
                          style: TextStyle(
                            fontSize: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    stabilityLevelLabel(score.level),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onToggleDetail,
          child: Text(
            isDetailOpen ? 'Masquer le détail ↑' : 'Comprendre ce score ↓',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (isDetailOpen) _ScoreDetail(score: score),
      ],
    );
  }

  Color _levelColor(BuildContext context, StabilityLevel level) {
    final colors = context.peculeColors;
    return switch (level) {
      StabilityLevel.stable => colors.gain,
      StabilityLevel.moderate => Theme.of(context).colorScheme.primary,
      StabilityLevel.agitated => colors.loss,
    };
  }
}

class _ScoreDetail extends StatelessWidget {
  const _ScoreDetail({required this.score});

  final StabilityScore score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          _SubScore(
            label: 'Volatilité',
            rawValue: formatRoundPercent(score.volatility),
            note: score.volatilityNote,
          ),
          const SizedBox(height: 14),
          _SubScore(
            label: 'Plus forte baisse',
            rawValue: '−${formatRoundPercent(score.maxDrawdown)}',
            note: score.drawdownNote,
          ),
          const SizedBox(height: 14),
          Text(
            stabilityExplanation,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13.5,
              color: context.peculeColors.textReading,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubScore extends StatelessWidget {
  const _SubScore({
    required this.label,
    required this.rawValue,
    required this.note,
  });

  final String label;
  final String rawValue;
  final double note;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: label,
                style: const TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: ' · $rawValue',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              '${note.round()}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: note / 100,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHigh,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Demi-cercle de la jauge : le fond, puis la part remplie selon le score.
class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.share,
    required this.color,
    required this.trackColor,
  });

  static const _strokeWidth = 16.0;

  final double share;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - _strokeWidth;
    final center = Offset(size.width / 2, size.height - _strokeWidth / 2);
    final bounds = Rect.fromCircle(center: center, radius: radius);
    Paint stroke(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawArc(bounds, math.pi, math.pi, false, stroke(trackColor))
      ..drawArc(bounds, math.pi, math.pi * share, false, stroke(color));
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.share != share || oldDelegate.color != color;
}
