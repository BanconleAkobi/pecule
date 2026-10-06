# Tests

## TDD

Rouge, vert, refactor : un test qui échoue pour la bonne raison, le code minimal qui le fait passer, puis un nettoyage sans changer le comportement.

- Aucune logique métier sans un test qui a d'abord échoué.
- Un bug se corrige en deux temps : un test qui le reproduit, puis la correction.
- On ne désactive jamais un test, on ne l'affaiblit jamais pour faire passer la suite.
- Avant d'écrire un client API, un test d'apprentissage sur une vraie réponse JSON enregistrée dans `test/fixtures/`.

## F.I.R.S.T.

- **Rapide** : toute la suite tourne en quelques secondes.
- **Indépendant** : aucun test ne dépend d'un autre ni de l'ordre d'exécution.
- **Reproductible** : pas de réseau, pas d'horloge réelle, pas de hasard. La date du jour est injectée.
- **Auto-validant** : il passe ou il échoue, sans lire de logs.
- **Au bon moment** : écrit juste avant le code.

## Forme

- Préparer, agir, vérifier, séparés par une ligne vide. Pas de commentaires `// Arrange`.
- Un seul comportement par test. La description dit ce qui est attendu, en français. Le code du test reste en anglais.
- `closeTo` pour comparer des `double`.

```dart
test('renvoie une baisse nulle pour une série toujours croissante', () {
  final closes = [100.0, 110.0, 120.0];

  final drawdown = computeMaxDrawdown(closes);

  expect(drawdown, closeTo(0, 1e-9));
});
```

## Quoi tester

| Couche | Comment | Objectif |
| --- | --- | --- |
| `domain/` | Tests unitaires purs | Tout, avec chaque cas limite de la section 8 du cahier |
| DTO | `fromJson` sur les fixtures réelles | Chaque champ utilisé |
| Repositories | Base en mémoire, clients simulés avec mocktail | Toutes les règles de cache de la section 7 |
| Écrans | Quelques tests de widgets | Les états chargement, données, erreur, vide |

## Organisation

- `test/` reproduit l'arborescence de `lib/`.
- Les fixtures JSON sont de vraies réponses, anonymisées si besoin, jamais inventées.
- Les exemples chiffrés du cahier (score de 72, effet de change de 12,6 %, intérêts composés 1 628,89 €) deviennent des tests tels quels.
