import 'package:flutter/material.dart';

class NoResult extends StatelessWidget {
  const NoResult({super.key, required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 56),
      child: Column(
        children: [
          Text('Aucun résultat', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'Rien ne correspond à « $query ».',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          OutlinedButton(
            onPressed: onClear,
            child: const Text('Effacer la recherche'),
          ),
        ],
      ),
    );
  }
}

class NoFavorite extends StatelessWidget {
  const NoFavorite({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 56),
      child: Column(
        children: [
          Text(
            '♡',
            style: TextStyle(fontSize: 40, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text('Pas encore de favori', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'Touche le cœur d\'un actif pour le retrouver ici.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
