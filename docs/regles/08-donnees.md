# Données, API et cache

## Clients API

- Un client par fournisseur : Twelve Data (actions, ETF), CoinGecko (cryptos), Frankfurter (EUR/USD).
- Un client envoie la requête, vérifie le statut et parse son JSON en DTO. Rien d'autre.
- Les DTO ont un `fromJson` testé sur une réponse réelle. Ils ne sortent pas de `data/` : le repository les convertit en modèles du domaine.
- Toute requête Twelve Data passe par une file d'attente unique qui respecte le quota (8 crédits par minute, 800 par jour). Une erreur de quota devient une `RateLimitException`, pas un plantage.
- Les historiques ne sont jamais téléchargés en bloc. On les charge à la demande : fiche ouverte, simulation lancée, actif ajouté au portefeuille (cahier section 5.3).
- Le catalogue des trente actifs est une constante du code, pas une donnée téléchargée.
- La recherche et les filtres de l'Explorer travaillent en local. Aucun appel réseau à la frappe.
- Ce qui est marqué « à vérifier » dans la section 5 du cahier (URL, profondeur d'historique, cours ajustés) se vérifie dans la doc officielle avant d'écrire le client.

## Clés API

- Jamais dans le code, jamais commitées.
- Injectées avec `--dart-define-from-file=env.json`, lues avec `String.fromEnvironment`.
- `env.json` est dans `.gitignore`. `env.example.json`, sans valeurs, est versionné.

## Base de données

Le modèle complet, ses règles de gestion et le passage aux tables sont dans `docs/mcd.md`.

Deux familles de tables, qui ne se mélangent pas.

| Données utilisateur | Données de cache |
| --- | --- |
| `user_profile`, `lesson_progress`, `favorite`, `paper_transaction`, `saved_simulation`, `preference` | `price_bar`, `fx_rate`, `sync_state` |
| Jamais supprimées automatiquement | Reconstructibles, vidables à tout moment |

- « Vider le cache » ne touche que les trois tables de cache.
- Une transaction fige le cours et le taux utilisés au moment de l'achat. Sa valeur historique ne change jamais.
- Une simulation enregistrée ne garde que ses paramètres. Le résultat est recalculé à l'ouverture.
- Toute modification de schéma passe par une migration, et demande mon accord.

## Décision cache ou réseau

C'est le repository qui décide, dans cet ordre (cahier section 7.2) :

1. Renvoyer tout de suite ce qui est en base, s'il y a quelque chose.
2. Si `last_fetched_at` a moins de six heures, s'arrêter.
3. Calculer le dernier jour de cotation attendu : la veille ou le jour même selon l'heure, en sautant les week-ends pour les actions et ETF, tous les jours pour les cryptos et le change. Si `last_data_day` y est déjà, mettre à jour `last_fetched_at` et s'arrêter.
4. Sinon, ne demander que les jours manquants, les insérer, mettre à jour `sync_state`.
5. En cas d'échec, garder les données en base, les marquer comme anciennes, remonter l'erreur comme information.

Tirer pour actualiser ignore le délai de six heures mais reste incrémental. Pour les cryptos, seule la journée en cours est réécrite.

Les repositories renvoient un `CachedData` : la valeur, la date de mise à jour, et l'indication qu'elle est peut-être ancienne.

## Dates et montants

- La date du jour vient d'une horloge injectée. Jamais `DateTime.now()` directement dans le code métier.
- Un jour de cotation est une date sans heure : un `DateTime` à minuit UTC (`DateTime.utc(2026, 10, 3)`), pour éviter les décalages d'heure d'été.
- Jour sans cotation ou sans taux : on prend la dernière valeur disponible avant cette date.
- Calculs en `double`, arrondi uniquement à l'affichage.
- Un prix en euros vaut le prix en dollars divisé par le taux Frankfurter (base EUR).
