import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_colors.dart';
import 'package:pecule/core/formatters.dart';

/// Bandeau discret affiché hors connexion, avec la date des données montrées
/// (cahier des charges, section 7.4). C'est l'écran qui décide de l'afficher.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.dataUpdatedAt});

  final DateTime? dataUpdatedAt;

  String get message {
    final updatedAt = dataUpdatedAt;
    if (updatedAt == null) return 'Hors connexion';
    return 'Hors connexion · données du ${formatDayAndTime(updatedAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.peculeColors.loss,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
