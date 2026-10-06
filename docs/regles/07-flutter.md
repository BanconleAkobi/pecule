# Flutter et Riverpod

## Widgets

- `build()` ne fait qu'afficher. Aucun appel réseau, aucun accès à la base, aucun calcul métier.
- Des petits widgets extraits en classes, pas en méthodes `_buildSomething()` qui renvoient un widget.
- `const` partout où c'est possible.
- Aucune couleur, taille de police ou rayon en dur dans un écran. Tout vient du thème (voir `09-interface.md`).
- Les nombres et dates affichés passent par les formateurs de `core/`, jamais par `toString()` ou `toStringAsFixed()` dans un widget.

## Cycle de vie

- Tout controller (animation, texte, défilement) est créé dans `initState` et libéré dans `dispose`.
- Une animation ne se rejoue pas à chaque reconstruction, seulement quand sa valeur cible change.
- Pas de `BuildContext` utilisé après un `await` sans vérifier `mounted`.

## Riverpod

- `ref.watch` dans `build`, `ref.read` dans les callbacks (`onPressed`, `onChanged`).
- Les providers d'écran sont libérés automatiquement quand l'écran disparaît.
- Les providers n'ont pas de `BuildContext` et ne construisent aucun widget.
- L'état exposé est immuable. On le remplace, on ne le modifie pas.
- Chaque `AsyncValue` affiché traite ses trois cas : chargement, données, erreur. Pas de `.value!`.
- Les repositories et l'horloge sont fournis par des providers, pour pouvoir être remplacés dans les tests.

## Animations prévues

| Animation | Technique |
| --- | --- |
| Total du patrimoine qui défile | `AnimationController` + `Tween<double>`, chiffres à chasse fixe |
| Courbe qui se dessine | `CustomPainter` + `PathMetric` |
| Jauge du score qui se remplit | `AnimationController` + `CurvedAnimation` |
| Résultat de simulation échelonné | Un seul controller, plusieurs `Interval` |
| Cœur des favoris | `AnimatedScale` ou `TweenAnimationBuilder` |

## Qualité

- `flutter analyze` sans aucun avertissement et `dart format .` avant chaque commit.
- Pas de `// ignore:` pour faire taire l'analyseur, sauf raison écrite sur la même ligne.
- Pas de `print`. Les logs de débogage passent par `debugPrint` ou `dart:developer` et ne contiennent jamais de clé API.
