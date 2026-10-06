# Architecture

Les couches ne se connaissent que dans un sens : l'interface dépend de l'état, l'état des repositories et du domaine, les repositories des sources de données. Le domaine ne dépend de rien.

```
presentation  →  application  →  data  →  domain
      └───────────────┴─────────────────→  domain
```

## Couches

| Couche | Contient | N'a pas le droit de |
| --- | --- | --- |
| `domain/` | Modèles immuables, calculs purs | Importer Flutter, Riverpod, drift ou http |
| `data/` | Clients API, DTO, base, repositories | Contenir de la logique d'affichage |
| `application` (providers) | État de chaque écran, orchestration | Construire des widgets |
| `presentation` (écrans, widgets) | Affichage, gestes | Appeler une API, lire la base, faire un calcul métier |

## Arborescence

```
lib/
  main.dart
  app/            thème, routeur, configuration
  core/           formatage (€, %, dates), erreurs, horloge injectable
  domain/
    models/       Asset, PriceBar, PaperTransaction, Simulation…
    calculations/ portfolio, dca, currency, risk, stability_score
  data/
    remote/       twelve_data_client, coingecko_client, frankfurter_client, dto/
    local/        database, tables/, daos/
    repositories/ price_history_repository, portfolio_repository…
  features/
    onboarding/ patrimoine/ explorer/ asset_detail/ learn/ simulator/ settings/
      chacun : <name>_screen.dart, widgets/, providers
assets/lessons/   contenu des leçons en JSON
assets/fonts/     Instrument Serif, Schibsted Grotesk, JetBrains Mono
test/             même arborescence que lib/
```

Un dossier n'est créé que lorsqu'il reçoit son premier fichier.

## Qui fait quoi

| Question | Réponse |
| --- | --- |
| Où est l'état ? | Dans les providers Riverpod, hors des widgets |
| Qui choisit entre cache et réseau ? | Le repository de la ressource, jamais un widget |
| Où sont les calculs métier ? | Dans `domain/calculations`, en fonctions pures |
| Qui écrit en base ? | Les DAO, appelés uniquement par les repositories |
| Comment remontent les erreurs ? | Exceptions typées dans `data`, `AsyncValue` dans les providers, widgets d'état communs à l'écran |
| Que se passe-t-il quand un widget se reconstruit ? | Il relit l'état. Aucun appel réseau relancé, aucune animation rejouée |

## Dépendances

| Paquet | Usage | Statut |
| --- | --- | --- |
| flutter_riverpod | États | Retenu |
| http | REST | Retenu |
| intl | Formats français | Retenu |
| mocktail | Doublures de test (dev) | Retenu |
| drift + sqlite3_flutter_libs | SQLite typé | À valider avant S2 (alternative : sqflite) |
| go_router | Navigation à onglets | Écarté : Navigator natif et `IndexedStack` |
| flutter_localizations (SDK) | Textes Material en français | Retenu |
| fl_chart | Anneau, double courbe | Optionnel |

Tout paquet absent de ce tableau demande mon accord et une ligne de justification.
