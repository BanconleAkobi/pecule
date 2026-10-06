# Journal des décisions

Une ligne par décision technique, au moment où elle est prise. À recopier dans la section 17 du cahier des charges et dans la partie « choix techniques » du rapport.

| Date | Décision | Alternatives écartées | Raison |
| --- | --- | --- | --- |
| 05/10/2026 | Riverpod pour les états | setState, Provider, Bloc | `AsyncValue` natif, injection testable, état hors des widgets |
| 05/10/2026 | SQLite pour toute la persistance | shared_preferences, Hive | Requêtes sur des historiques datés, séparation nette entre utilisateur et cache |
| 05/10/2026 | Catalogue coté en dollars | Mélange euros et dollars | Effet de change visible partout, moins d'incertitude sur le plan gratuit |
| 05/10/2026 | La maquette fait référence pour le visuel et les textes | Charte section 13.1 du cahier (violet, Inter) | Plus récente et plus aboutie |
| 06/10/2026 | Navigator natif et `IndexedStack` pour les onglets | go_router | Aucune dépendance, pas besoin de liens profonds, plus simple à expliquer |
| 06/10/2026 | Polices embarquées dans `assets/fonts/` | Paquet google_fonts | Fonctionne hors connexion dès le premier lancement, aucune dépendance |
| 06/10/2026 | Conserver toutes les plateformes générées | Ne garder qu'android et ios | Choix personnel ; elles sont exclues de l'analyse |
| 06/10/2026 | Ajouter chaque dépendance au sprint qui l'utilise | Tout installer en S0 | Pas de code ni de paquet « au cas où » |
| 06/10/2026 | Lints stricts (`strict-casts`, `strict-inference`, `strict-raw-types` et règles complémentaires) | Lints par défaut | Erreurs de type détectées à l'analyse plutôt qu'à l'exécution |
| 06/10/2026 | Noms dans le code en anglais, commentaires en français | Tout en anglais | Commentaires lus et relus par moi, en soutenance comprise |
| 06/10/2026 | Calcul impossible : type générique `Computed<T>` (`Available` ou `Unavailable` avec une raison) | Une classe scellée par calcul, `null`, `0` par défaut | Un seul motif pour tous les calculs ; le `switch` exhaustif oblige chaque écran à traiter le cas indisponible |
| 06/10/2026 | Égalité des modèles écrite à la main | equatable, freezed | Aucune dépendance ni génération de code pour une dizaine de modèles |
| 06/10/2026 | sqflite pour SQLite | drift | Vu en cours ; SQL écrit à la main, sans génération de code. Tests de repositories sur une base en mémoire avec `sqflite_common_ffi` |
| 06/10/2026 | Explorer : cache d'abord, puis remplissage progressif des historiques par la file d'attente | Cache seul, téléchargement en bloc | Respecte le quota de 8 crédits par minute ; chaque historique n'est téléchargé qu'une fois puis complété |
| 06/10/2026 | Hors connexion déduit des échecs réseau | connectivity_plus | Aucune dépendance ; une interface active ne garantit pas que l'API répond |
| 06/10/2026 | Simulateur : date de début libre et validée, 30 actifs proposés | Liste de janviers et 6 actifs de la maquette | Validation de date exigée par le formulaire, aucun actif exclu |
| 06/10/2026 | Confirmation avant de réinitialiser le portefeuille | Suppression directe (maquette) | Action irréversible |
