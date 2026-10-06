# Erreurs et cas impossibles

Le traitement des erreurs est une responsabilité à part. Il ne doit pas noyer la logique principale.

## Règles

- Exceptions typées, définies par nous, qui portent leur contexte : `NetworkException`, `RateLimitException`, `MissingPriceException`. Jamais `throw Exception('error')`.
- Les exceptions de `http`, `drift` ou de tout autre paquet ne sortent pas de `data/`. Elles y sont traduites en exceptions à nous.
- On n'attrape que ce qu'on sait traiter. Pas de `catch (e) {}` vide, pas de `catch` qui avale tout pour faire taire un problème.
- Un échec réseau ou de quota n'est jamais un plantage : les données en cache restent affichées et l'erreur remonte comme information (cahier §7.2).
- L'opérateur `!` seulement quand on peut prouver que la valeur existe. Sinon, on traite le cas.

## Calcul impossible

Portefeuille vide, historique trop court, montant investi nul : le calcul ne renvoie ni `0` par défaut, ni `null`. Il renvoie un résultat explicitement indisponible, que l'interface sait afficher (cahier §8.1).

Forme proposée, à confirmer au sprint S1 : une classe scellée, traitée par un `switch` exhaustif.

```dart
sealed class Performance {}

final class KnownPerformance extends Performance {
  KnownPerformance(this.ratio);
  final double ratio;
}

final class UnavailablePerformance extends Performance {}
```

Le compilateur oblige alors chaque écran à prévoir le cas indisponible.

## Côté utilisateur

- Message en français, simple, sans jargon technique ni code d'erreur.
- Toujours une action possible : « Réessayer », ou la date des données en cache.
- Un seul widget d'erreur commun, réutilisé partout.
