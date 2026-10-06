# Code propre

D'après *Clean Code* (Robert C. Martin), adapté à Dart et à Pécule.

## Noms

- Un nom dit pourquoi la chose existe et ce qu'elle fait. S'il faut un commentaire pour l'expliquer, le nom est à revoir.
- Classes et variables : des noms (`PaperTransaction`, `stabilityScore`). Fonctions : des verbes (`computeMaxDrawdown`, `fetchDailyBars`).
- Booléens lisibles comme une question : `isOffline`, `hasPositions`, `canSubmit`.
- Pas d'abréviations (`txn`, `calcVol`, `amt`), pas de préfixes inutiles, pas de mots vides (`data`, `info`, `manager`, `helper`, `utils`).
- Un concept, un mot, partout : si un client dit `fetch`, aucun autre ne dit `get` ou `retrieve`. Proposition : les clients API font `fetch…`, les DAO `find…`, `insert…`, `delete…`, les repositories `get…` et `watch…`.
- L'unité est dans le nom quand elle compte : `amountEur`, `priceUsd`, `eurUsdRate`.
- Fichiers en `snake_case`, un fichier par classe publique importante.

## Fonctions

- Courtes, une seule chose, un seul niveau d'abstraction. Elles se lisent de haut en bas comme un paragraphe.
- Deux ou trois paramètres au plus. Au-delà, des paramètres nommés `required` ou un objet paramètre.
- Pas de paramètre booléen qui change le comportement : on écrit deux fonctions.
- Pas d'effet de bord caché. Une fonction qui calcule ne sauvegarde pas, une fonction qui lit n'écrit pas.
- Retour anticipé plutôt que des `if` imbriqués.

```dart
// Non
double computePerformance(double invested, double value, bool asPercent) { ... }

// Oui
Performance computePerformance({required double investedEur, required double valueEur}) { ... }
```

## Valeurs

- Pas de nombre magique. `252`, `365`, `0.80`, `0.5`, `Duration(hours: 6)` sont des constantes nommées.
- `final` par défaut, `const` dès que possible. Les modèles du domaine sont immuables.
- Types explicites sur tout ce qui est public. Pas de `dynamic` en dehors du parsing JSON.

## Principes de conception

| Principe | Dans Pécule |
| --- | --- |
| Responsabilité unique | Un client API ne parse que son JSON. Un repository ne décide que du cache. |
| DRY | Un seul formateur d'euros et de pourcentages, un seul widget d'erreur. |
| KISS | La solution la plus simple qui marche. Pas de couche ajoutée par principe. |
| YAGNI | Pas de multi-devises, pas de comptes, pas de code « au cas où ». |
| Injection | Les objets reçoivent leurs dépendances (repositories, horloge) au lieu de les créer. |
| Déméter | Pas de chaînes `a.b.c.d` dans les widgets. |
| Règle du scout | Laisser un peu plus propre ce qu'on touche, et seulement ce qu'on touche. |

En cas de conflit, l'ordre de Kent Beck : les tests passent, pas de duplication, l'intention est claire, le moins de classes et de fonctions possible.

## Signaux d'alerte

Repères personnels, pas des limites dures : un fichier de plus de 200 lignes, une fonction de plus de 25 lignes, un widget de plus d'un écran. Ce n'est pas interdit, mais il faut se demander s'il ne fait pas deux choses.
