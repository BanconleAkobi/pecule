import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_fonts.dart';

/// La feuille « En clair » : un chiffre traduit en phrase simple, avec des
/// montants concrets. S'ouvre au toucher d'un chiffre souligné en pointillés.
Future<void> showExplainSheet(
  BuildContext context, {
  required String title,
  required String text,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ExplainSheet(title: title, text: text),
  );
}

class _ExplainSheet extends StatelessWidget {
  const _ExplainSheet({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPollen = colorScheme.onPrimary;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'EN CLAIR',
              style: TextStyle(
                fontFamily: PeculeFonts.mono,
                fontSize: 11,
                letterSpacing: 0.9,
                color: onPollen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: PeculeFonts.serif,
                fontSize: 34,
                height: 1.05,
                color: onPollen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: TextStyle(fontSize: 15.5, height: 1.5, color: onPollen),
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: onPollen,
                foregroundColor: colorScheme.primary,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Compris'),
            ),
          ],
        ),
      ),
    );
  }
}
