# Commentaires

Un commentaire compense un code qui n'arrive pas à dire seul ce qu'il fait. Avant d'en écrire un, essayer dans l'ordre : renommer, extraire une fonction, introduire une variable qui explique.

Le test : si on supprime le commentaire, le lecteur perd-il une information ? Non, alors on le supprime.

## Autorisé

- Le pourquoi d'une décision qui ne se voit pas dans le code.
- L'avertissement d'une conséquence.
- Une contrainte venue de l'extérieur : format d'une API, quota, comportement d'un fournisseur.
- La doc `///` d'un élément public réutilisé, quand le nom ne suffit pas.

## Interdit

- Paraphraser le code.
- Raconter l'historique (« modifié pour… », « nouvelle version », « fix »). Git s'en charge.
- Laisser du code commenté.
- Bannières, séparateurs, auteur, date.
- Une doc `///` qui répète la signature.
- Les `// Arrange`, `// Act`, `// Assert` dans les tests : une ligne vide suffit.
- Un `TODO` sans identifiant. Toléré seulement sous la forme `// TODO(F-SIM-04): …`, et à retirer avant la soutenance.
- Le ton « IA » : « Ici, nous allons… », « Cette fonction gère élégamment… », emojis, majuscules d'insistance.
- Commenter un fichier évident : une palette de couleurs, une liste de constantes ou un écran simple se lisent sans aide.

## Forme

En français, une phrase ou deux, au présent, sans point d'exclamation. Placé juste au-dessus de la ligne concernée. Les noms dans le code restent en anglais.

## Exemples

```dart
// Non : répète le code
// Récupère le dernier taux avant le jour
final rate = rates.lastOnOrBefore(day);

// Oui : explique ce qui ne se voit pas
// Frankfurter ne publie aucun taux le week-end ni les jours fériés.
final rate = rates.lastOnOrBefore(day);
```

```dart
// Non
/// Cette méthode calcule la volatilité annualisée.
/// Elle prend une liste de prix et renvoie un double.
double computeAnnualizedVolatility(List<double> prices, int periodsPerYear)

// Oui : le nom suffit, la doc n'ajoute que ce qui manque
/// [periodsPerYear] vaut 252 pour les actions et ETF, 365 pour les cryptos.
double computeAnnualizedVolatility(List<double> prices, int periodsPerYear)
```

```dart
// Non : un commentaire pour expliquer une condition
// vérifie si la ligne pèse trop lourd
if (value / total > 0.5) { ... }

// Oui : une variable qui porte le sens
final isConcentrated = value / total > concentrationThreshold;
if (isConcentrated) { ... }
```

La même exigence vaut pour les messages de commit et les comptes rendus.
