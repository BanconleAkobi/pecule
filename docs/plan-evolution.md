# Plan d'évolution

Tiré du cahier des charges (v1.0 du 5 octobre 2026) et de la maquette interactive. Pour la maquette, on se réfère au visuel et aux textes. Pour le cahier, on se réfère au fonctionnel, aux calculs et aux données.

60 heures de code réparties en neuf sprints. Le domaine et les données passent avant les écrans, pour que chaque écran repose sur des fondations déjà testées.

On coche au fil de l'eau. Chaque sprint se termine par un commit propre et une ligne dans le journal des décisions (section 17 du cahier).

**Règle de pilotage.** Si un sprint dépasse son budget de plus de 30 %, on retire d'abord une fonctionnalité Bonus, puis une Importante, jamais une Indispensable.

| Sprint | Contenu | Heures |
| --- | --- | --- |
| S0 | Fondations | 4 |
| S1 | Domaine | 8 |
| S2 | Données | 12 |
| S3 | Explorer et fiche actif | 10 |
| S4 | Portefeuille | 8 |
| S5 | Simulateur | 6 |
| S6 | Onboarding et Apprendre | 5 |
| S7 | Animations et finitions | 5 |
| S8 | Recette | 2 |

---

## Avant de commencer

- [x] Ajouter l'énoncé du module dans `Externesfiles/`.
- [x] Créer les comptes Twelve Data et CoinGecko Demo, clés dans `env.json`.
- [ ] Compléter l'environnement avant S2 : `cmdline-tools` Android, `flutter doctor --android-licenses`, CocoaPods.

## Décisions

| Décision | Choix | Pourquoi | Source |
| --- | --- | --- | --- |
| Navigation | Navigator natif et `IndexedStack` | Aucune dépendance, pas besoin de liens profonds | section 11.4 |
| Polices | Fichiers embarqués | Hors connexion dès le premier lancement | Maquette |
| Plateformes | On garde tout | Choix personnel, exclues de l'analyse | section 15 |
| Résultat indisponible | Type générique `Computed<T>` : `Available` ou `Unavailable` avec une raison | Un seul motif pour tous les calculs, `switch` exhaustif à l'écran | section 8.1 |
| Accès à la base | sqflite | Vu en cours, SQL écrit à la main donc entièrement maîtrisé, aucune génération de code. Les repositories sont testés sur une base en mémoire avec `sqflite_common_ffi` | section 6.1 |
| Cours de l'Explorer | Cache d'abord, puis remplissage progressif des historiques par la file d'attente Twelve Data, la fiche ouverte passant en priorité. Cryptos en un seul appel CoinGecko | Chaque historique n'est téléchargé qu'une fois puis complété au jour le jour, ce que demande l'énoncé (section 5). Premier remplissage d'environ 3 minutes, puis 20 crédits par jour sur 800 | section 4.3, section 5.3 |
| Détection hors connexion | Déduite des échecs réseau | Aucune dépendance. Un paquet de connectivité dit seulement si une interface est active, pas si l'API répond : il faudrait gérer les échecs de toute façon | section 7.4 |
| Anneau de répartition | À trancher en S4 : fl_chart ou CustomPainter | | section 10 |
| Double courbe du simulateur | À trancher en S5 : fl_chart ou CustomPainter | | section 11.4 |

## Écarts entre la maquette et le cahier

| Sujet | Cahier | Maquette | Proposition |
| --- | --- | --- | --- |
| Charte graphique | Violet `#8B7CFF`, Inter | Pollen `#E2F24B`, Instrument Serif, Schibsted Grotesk, JetBrains Mono | Maquette (validé). Mettre à jour section 13.1 |
| Barre d'onglets | Icônes fines (prompt section 13) | Libellés texte seuls, trait pollen sur l'onglet actif | Maquette |
| Réglages | Point d'entrée non précisé | Bouton « Réglages » en haut de Patrimoine, feuille du bas | Maquette |
| Variation dans l'Explorer | « Sur la période choisie », sans sélecteur de période prévu | Toujours sur 1 an | Maquette : 1 an |
| Date de début du simulateur | Date libre, validée | Liste de janvier 2022 à janvier 2026 | Cahier : sélecteur de date dans le champ de la maquette. La validation de la date fait partie du formulaire évalué |
| Actifs du simulateur | Tout le catalogue | Six actifs en puces (Bitcoin, S&P 500, Apple, Ethereum, Nasdaq 100, Tesla) | Les 30 actifs en puces défilantes, comme la maquette : favoris d'abord, puis les six de la maquette, puis le reste |
| Feuille « En clair » | Absente | Chiffres soulignés en pointillés qui s'ouvrent en phrase simple | La garder, rattachée à F-FIC-04 et à la promesse section 1.4 |
| Onboarding, écran de fin | Niveau et explication | En plus : trois leçons « À lire en premier » avec leur durée | Maquette |
| Réinitialiser le portefeuille | Non détaillé | Aucune confirmation avant suppression | Une confirmation : l'action est irréversible |
| Catalogue | 30 instruments, cryptos identifiées par leur id CoinGecko | 14 actifs de démonstration, cryptos affichées par symbole (BTC, ETH) | Cahier pour la liste. L'id CoinGecko reste interne, on affiche le symbole (BTC) |

## Incohérences internes au cahier

- La section 2 renvoie à « l'explicabilité du score (section 8.4) ». Le score est en section 8.5, la section 8.4 traite de l'effet de change.
- La section 12.9 indique « drift (SQLite) » dans la stack, alors que la section 6.1 laisse le choix ouvert. Tranché : sqflite, à corriger dans le rapport.
- Section 1.5 (version .docx seulement) : le nom « Semis » est encore présent dans la proposition. À harmoniser en « Pécule » dans le rapport.

---

## S0. Fondations (4 h)

- [x] Initialiser le dépôt git (le dossier n'en est pas un) et compléter `.gitignore` : `env.json`, `.claude/`.
- [x] Nettoyer le projet généré : `lib/main.dart` (compteur et commentaires du modèle), `test/widget_test.dart`, description de `pubspec.yaml`, `README.md`.
- [x] Lints stricts dans `analysis_options.yaml` (`strict-casts`, `strict-inference`, `strict-raw-types` et règles complémentaires).
- [x] Arborescence de section 11.2 : `app/` et `features/` pour l'instant. `core/`, `domain/` et `data/` sont créés avec leur premier fichier (S1, S2).
- [x] Dépendances : `flutter_localizations` seulement, `cupertino_icons` retiré. Riverpod, intl, http et mocktail arrivent au sprint qui les utilise.
- [x] Polices embarquées dans `assets/fonts/`, licences OFL enregistrées.
- [x] Thème sombre selon `docs/regles/09-interface.md` : couleurs, extension `PeculeColors`, typographie. Les thèmes de composants (boutons, champs, puces) arrivent avec leur premier usage.
- [x] Locale française (délégués de localisation). Les formats de nombres et de dates viennent en S1.
- [x] Navigation : quatre onglets vides (Patrimoine, Explorer, Apprendre, Simulateur) avec la barre de la maquette, état et défilement conservés par onglet.
- [x] `CLAUDE.md` à la racine.
- [x] Clés API hors dépôt : `env.example.json` versionné sans valeurs, `env.json` ignoré. La lecture par `String.fromEnvironment` vient en S2.
- [x] Journal : `docs/journal-decisions.md`, avec les décisions déjà prises et celles de S0.

**Terminé quand** l'application se lance avec ses quatre onglets et que `flutter analyze` ne remonte rien.

## S1. Domaine (8 h)

Tout en TDD, dans `domain/` sans import Flutter. Chaque cas limite listé est un test.

### Socle

- [x] Formateurs dans `core/formatters.dart`, testés : montant (2 décimales, 3 sous 1 €, arrondi à l'euro pour la simulation), pourcentage signé avec `−` et flèche, quantité (4 décimales et symbole), taux (4 décimales), dates (`4 oct. 2026`, `Mis à jour le 4 oct. à 18:02`, `Cours du vendredi 3 janvier utilisé`).
- [x] Type « résultat indisponible » : `Computed<T>` dans `lib/domain/computed.dart`.
- L'horloge injectable passe en S2 : les calculs reçoivent la date du jour en paramètre, seuls les repositories en ont besoin.

### Modèles immuables

- [x] `Asset` : identifiant, nom, symbole affiché, type, devise. Le fournisseur reste dans le catalogue de `data/`, pour que le domaine ignore les API.
- [x] `AssetType` : action, ETF, crypto, avec les jours de cotation par an.
- [x] `Currency` : EUR, USD.
- [x] `PriceBar` : jour, ouverture, plus haut, plus bas, clôture, volume, capitalisation (cryptos).
- [x] `FxRate` : jour, base, devise cotée, taux.
- [x] `PaperTransaction` : actif, date d'exécution, montant en euros, cours unitaire, devise du cours, taux EUR/USD, quantité.
- [ ] Paramètres et résultat de simulation.
- [ ] Niveau utilisateur : Découverte, Initié, À l'aise.

### Conventions (section 8.1)

- [x] Conversion : prix en euros = prix en dollars / r (r = dollars pour un euro). `calculations/currency.dart`.
- [x] Valeur au plus tard à une date : dernier cours ou dernier taux disponible avant cette date. `calculations/dated_lookup.dart`.

### Portefeuille (section 8.2)

| Calcul | Formule | Cas limites |
| --- | --- | --- |
| Quantité achetée | montant_eur × r_achat / cours_achat | Montant nul, cours nul, actif coté en euros (r = 1) |
| Valeur d'une ligne | quantité × cours_actuel / r_actuel | Cours actuel manquant |
| Valeur totale | Σ valeurs des lignes | Portefeuille vide |
| Gain ou perte | valeur totale − montant investi | Gain négatif |
| Performance | gain / montant investi | Montant investi nul |
| Répartition | valeur d'un type / valeur totale | Un seul type, somme des poids égale à 1 |
| Concentration | alerte si une ligne pèse plus de 50 % | Exactement 50 %, une seule ligne |

- [x] Tous les calculs du tableau et leurs cas limites, dans `calculations/portfolio.dart`. En plus : regroupement des achats par actif, taux de change nul, cours nul.

### Simulation DCA (section 8.3)

- [x] Dates prévues entre le début et aujourd'hui selon la fréquence (semaine ou mois).
- [x] Pour chaque date : premier cours de clôture disponible à partir de cette date, converti au taux du jour, quantité = montant / cours en euros.
- [x] Sorties : capital investi (achats × montant), valeur finale (Σ quantités × cours final en euros), performance (valeur finale / capital − 1), prix moyen (capital / Σ quantités), série jour par jour (capital cumulé, valeur des quantités cumulées).
- [x] Cas limites : début dans le futur, aucun cours après le début, historique avec des trous, montant nul, une seule période, dernier achat tombant aujourd'hui.
- Choix faits dans `calculations/dca.dart` : un achat prévu aujourd'hui sans cours publié n'est pas compté ; deux achats tombés dans un trou utilisent le même cours ; le 31 d'un mois devient le dernier jour des mois plus courts.

### Effet de change (section 8.4)

- [x] perf_eur = (1 + perf_usd) × r_début / r_fin − 1. L'effet de change est l'écart entre les deux, en points.
- [x] Test : +18 % en dollars, euro de 1,05 à 1,10, donne +12,6 % en euros.
- [x] En plus, variation entre deux cours (énoncé, section 8), dans `calculations/variation.dart` : pour l'en-tête de la fiche et l'Explorer.

### Risque et score de stabilité (section 8.5)

| Indicateur | Définition | Cas limites |
| --- | --- | --- |
| Rendements quotidiens | r_t = cours_t / cours_(t−1) − 1 | Moins de deux cours |
| Volatilité annualisée | écart-type des rendements × √N, N = 252 (actions, ETF) ou 365 (cryptos) | Moins de deux rendements, série constante |
| Plus forte baisse | min(cours / plus haut précédent − 1) | Série croissante (0 %), annexe A.2 : 100, 110, 125, 115, 90, 105 donnent −28 % |

- [x] Les trois indicateurs du tableau et leurs cas limites, dans `calculations/risk.dart`. Écart-type d'échantillon (division par n − 1). En plus : cours nul refusé.
- [x] Note de volatilité = 100 × (1 − min(volatilité, 0,80) / 0,80).
- [x] Note de baisse = 100 × (1 − min(|baisse|, 0,80) / 0,80).
- [x] Score = arrondi(0,5 × note de volatilité + 0,5 × note de baisse). Le découpage sur un an glissant se fera en S3, quand la fiche actif fournira les cours datés.
- [x] Libellé : 0 à 39 Agité, 40 à 69 Modéré, 70 à 100 Stable.
- [x] Test : volatilité 20 % et baisse 25 % donnent 75 et 68,75, score 72, « Stable ».

### Intérêts composés (section 8.6)

- [x] Capital final = capital × (1 + taux)^années. Test : 1 000 € à 5 % sur 10 ans donnent 1 628,89 €.

### Niveau de l'onboarding (section 4.2)

- [x] Un point par bonne réponse. 0 à 1 Découverte, 2 à 3 Initié, 4 à 5 À l'aise. Questionnaire passé : Découverte.
- [x] Chaque erreur renvoie à sa leçon associée.
- Le contenu des cinq questions (textes de la maquette) arrive en S6 avec les écrans de l'onboarding.

**Terminé quand** tous les calculs et leurs cas limites sont testés et verts.

## S2. Données (12 h)

### Vérifications préalables (section 5.1)

- [x] Twelve Data : 8 crédits par minute et 800 par jour, actions et ETF américains inclus, 1 crédit par `time_series`. Cours ajustés des divisions par défaut (`adjust=splits`), pas des dividendes : à écrire dans le rapport (annexe A.5). Prix en texte. `end_date` est exclue de la réponse. Sans cours sur la période, l'API répond par une erreur 400 « No data is available », traduite en liste vide.
- [x] CoinGecko Demo : clé en en-tête `x-cg-demo-api-key`. **Historique limité aux 365 derniers jours** : le simulateur crypto sera borné et l'écran l'expliquera. `interval=daily` accepté, un point à minuit UTC. `coins/markets` donne cours actuel et variation sur un an en un appel.
- [x] Frankfurter : `https://api.frankfurter.dev/v2/rates`, base EUR, sans clé ni quota. Une date de début seule renvoie tout jusqu'au dernier taux. **Des taux existent aussi le week-end** ; la recherche de la dernière valeur connue reste utile pour les jours fériés.
- [x] Trancher la question des cours de l'Explorer : remplissage progressif par la file d'attente (voir Décisions).

### Clients

- [x] Horloge injectable dans `core/clock.dart`, figée dans les tests (`test/helpers/fixed_clock.dart`).
- [ ] Lecture des clés API par `String.fromEnvironment`, lancement avec `--dart-define-from-file=env.json`.
- [x] Une vraie réponse par endpoint dans `test/fixtures/` et un test d'apprentissage pour chacune. Enregistrées par `tool/fetch_fixtures.sh`.
- [x] `TwelveDataClient`, `CoinGeckoClient`, `FrankfurterClient` : requête, statut, parsing en DTO. Requête commune dans `data/remote/http_json.dart`.
- [x] DTO et `fromJson` testés.
- [ ] Conversion des DTO en modèles du domaine (dans les repositories).
- [x] Exceptions typées des API : `NetworkException`, `RateLimitException`, `ApiErrorException`, `UnexpectedResponseException`.
- [ ] `MissingPriceException`, avec les repositories.
- [ ] File d'attente unique pour Twelve Data, au débit autorisé. Une erreur de quota devient un message clair.
- [ ] Catalogue de 30 instruments en constante (section 5.2) : identifiant, nom, symbole, symbole d'affichage, type, fournisseur, devise.

### Base

- [x] Schéma complet des 9 tables dans `data/local/database_schema.dart`, version 1. Jours en texte, horodatages en millisecondes UTC.
- [x] Données utilisateur, avec leurs DAO (favoris, achats, simulations, profil, leçons vues, préférences) :
  - `user_profile` (id, level, quiz_mistakes, onboarding_done, created_at)
  - `lesson_progress` (lesson_id, seen_at)
  - `favorite` (asset_id, added_at)
  - `paper_transaction` (id, asset_id, executed_on, amount_eur, unit_price, price_currency, eur_usd_rate, quantity, created_at)
  - `saved_simulation` (id, asset_id, periodic_amount_eur, frequency, start_date, created_at)
  - `preference` (key, value)
- [x] Données de cache, avec leurs DAO et `clearCache` :
  - `price_bar` (asset_id, day, open, high, low, close, volume, market_cap), clé (asset_id, day). Ouverture, plus haut et plus bas facultatifs : CoinGecko ne les fournit pas.
  - `fx_rate` (day, base, quote, rate), clé (day, base, quote)
  - `sync_state` (resource_key, last_data_day, last_fetched_at)
- [x] DAO des données utilisateur. `quiz_mistakes` stocké en JSON (liste des leçons liées aux erreurs).
- [ ] DAO appelés uniquement par les repositories.

### Repositories et cache (section 7)

- [x] `CachedData` dans `core/cached_data.dart` : valeur, date de mise à jour, erreur de la dernière actualisation (« peut-être ancienne »).
- [x] Dernier jour de cotation attendu, dans `domain/calculations/trading_calendar.dart` : actions et ETF du lundi au vendredi à partir de 22 h UTC, cryptos tous les jours dès minuit UTC, taux tous les jours à partir de 16 h UTC. Jours fériés non connus (limite à citer dans le rapport).
- [x] Historique des cours, dans `data/repositories/price_history_repository.dart`, dans l'ordre :
  1. renvoyer tout de suite ce qui est en base ;
  2. s'arrêter si `last_fetched_at` a moins de six heures ;
  3. si `last_data_day` est déjà le dernier jour attendu, mettre à jour `last_fetched_at` et s'arrêter ;
  4. sinon ne demander que les jours manquants depuis `last_data_day` + 1, insérer, mettre à jour `sync_state` ;
  5. en cas d'échec, garder la base, marquer les données comme anciennes, remonter l'erreur comme information.
  Premier téléchargement : depuis le 1er janvier 2020 pour une action ou un ETF, 364 jours pour une crypto. Le repository ne lève jamais d'erreur réseau : elle accompagne les données dans `CachedData`, même vides.
- [x] Source des cours `data/remote/price_source.dart` : Twelve Data ou CoinGecko selon le type d'actif, conversion en `PriceBar`.
- [ ] Taux de change, même logique.
- [x] Tirer pour actualiser : ignore les six heures, reste incrémental (`forceRefresh`).
- [x] Cryptos : seule la journée en cours est réécrite (le dernier jour reçu est redemandé).
- [x] Vider le cache : les trois tables de cache, rien d'autre (`clearCache`).
- [ ] Repositories utilisateur : favoris, transactions, profil, leçons vues, simulations, préférences.
- [x] Journal de débogage des jours téléchargés (`dart:developer`, nom `pecule.cache`).
- [ ] Détection hors connexion.
- [ ] Providers des repositories et de l'horloge.

### Tests

- [x] Données fraîches : aucun appel réseau.
- [x] Données anciennes : seuls les jours manquants sont demandés.
- [x] Échec réseau ou quota : données conservées et marquées anciennes.
- [x] Vider le cache : données utilisateur intactes.
- [x] Crypto : seule la dernière journée est réécrite.

**Terminé quand** un historique se télécharge, se met en cache, se complète et se lit hors connexion, le tout testé.

## S3. Explorer et fiche actif (10 h)

F-EXP-01, F-EXP-02, F-EXP-03, F-FIC-01, F-FIC-02, F-FIC-03, F-FIC-04, F-FIC-05 (le bouton, le formulaire vient en S4), F-GEN-01.

### Widgets communs

- [ ] État d'erreur avec « Réessayer », squelettes, toast, bandeau hors connexion, feuille « En clair », pastille d'actif, ligne de variation signée et fléchée.

### Explorer (section 4.3)

- [ ] Titre, recherche « Nom ou symbole » filtrée à la frappe, bouton d'effacement.
- [ ] Puces : Tous, Actions, ETF, Cryptos, ♥ Favoris.
- [ ] Ligne de métadonnées : « 30 ACTIFS · VARIATION SUR 1 AN », hors connexion « DERNIERS COURS CONNUS (4 OCT.) », en chargement « CHARGEMENT DES COURS… ».
- [ ] Ligne d'actif : pastille, nom, symbole · type, cours en euros, variation, cœur.
- [ ] Cœur : ajout ou retrait du favori, animation, toast « Ajouté à tes favoris » ou « Retiré de tes favoris ».
- [ ] États : squelettes, données, données anciennes avec date, « Aucun résultat » avec « Rien ne correspond à « … ». » et « Effacer la recherche », « Pas encore de favori ».
- [ ] Acceptation : la recherche ne déclenche aucun appel réseau ; un favori ajouté apparaît tout de suite dans le filtre et survit à un redémarrage ; la liste reste utilisable hors connexion avec les derniers cours connus.

### Fiche actif (section 4.4)

- [ ] En-tête : retour, « SYMBOLE · Type », cœur. Nom, cours en euros, variation sur la période (chiffre traduisible).
- [ ] Courbe : périodes 1M, 6M, 1A (par défaut), 3A, Max. Lecture au doigt : trait vertical, point, bulle « date · cours ». L'en-tête affiche alors la variation entre le début de la période et ce point, avec « au 4 janv. 2026 ».
- [ ] Bloc « Dollar ou euro ? » : « En dollars » et « Pour toi, en euros » côte à côte, phrase qui explique l'écart. Masqué pour un actif coté en euros.
- [ ] Sélection des cours de la dernière année (un an glissant) avant d'appeler `assessStability`, en fonction pure testée dans `domain/`.
- [ ] Score de stabilité : jauge en arc, « 72/100 », libellé coloré, « Comprendre ce score ↓ » et « Masquer le détail ↑ ». Le détail montre les deux sous-scores avec leur valeur brute, leur note et une barre, puis la formule en mots simples. Mention « Basé sur le passé, ce n'est pas une prédiction. »
- [ ] Cartes « Ça veut dire quoi ? » : Performance sur 1 an, Volatilité, Plus forte baisse, rédigées avec les chiffres de l'actif.
- [ ] Bouton fixe « Ajouter à mon portefeuille ».
- [ ] Historique chargé à l'ouverture si absent.
- [ ] Acceptation : ouverture instantanée si l'historique est en cache ; sinon le chargement occupe la place de la courbe sans bloquer le reste ; un échec réseau affiche une erreur avec « Réessayer », et le cache reste visible s'il existe.

**Terminé quand** F-EXP et F-FIC sont terminées avec tous leurs états.

## S4. Portefeuille (8 h)

F-ACH-01, F-FIC-05, F-PAT-01, F-PAT-02, F-PAT-03, F-PAT-04.

### Achat fictif (section 4.5)

- [ ] Feuille « Achat fictif : Apple » avec « Fermer » : grand champ de montant, date d'achat.
- [ ] Récapitulatif mis à jour à la saisie : cours à cette date, taux EUR/USD, quantité obtenue. Note si la date tombe un jour sans cotation.
- [ ] « Aucun argent réel n'est utilisé. »
- [ ] Règles de validation en fonctions pures testées :

| Champ | Règle | Message |
| --- | --- | --- |
| Montant | Vide, nul ou négatif | « Indique un montant supérieur à 0 € » |
| Montant | Plus de 1 000 000 | « Le montant maximum est 1 000 000 € » |
| Montant | Plus de deux décimales | « Deux décimales maximum » |
| Date | Absente | « Choisis une date » |
| Date | Dans le futur | « La date ne peut pas être dans le futur » |
| Date | Avant le premier cours | « Pas de cours disponible à cette date » |
| Date | Jour sans cotation | Acceptée, cours précédent : « Cours du vendredi 3 janvier utilisé » |

- [ ] « Valider l'achat » grisé tant que le formulaire est invalide.
- [ ] La transaction fige le cours et le taux utilisés. Toast « 150,00 € de Apple ajoutés ».

### Patrimoine (section 4.6)

- [ ] En-tête : logo « pécule » et bouton « Réglages ».
- [ ] « TON PATRIMOINE FICTIF », valeur totale, gain en euros et en pourcentage (chiffre traduisible), « Mis à jour le … · touche le chiffre pour le traduire ».
- [ ] Anneau de répartition ETF, Actions, Cryptos, avec légende en pourcentages.
- [ ] Carte de conseil : « Ton patrimoine est bien réparti entre 3 types d'actifs. », ou, si une ligne dépasse 50 %, « Ton patrimoine dépend à 68 % de Bitcoin. » et « Voir la leçon sur la diversification → ».
- [ ] « Mes positions » et « 5 LIGNES » : une ligne par actif (achats cumulés), triées par valeur décroissante, avec pastille, nom, quantité, valeur, performance. Le toucher ouvre la fiche.
- [ ] « Acheter un autre actif » vers l'Explorer.
- [ ] Portefeuille vide : cercle « 0,00 € », « Ton patrimoine commence ici. », « Choisis un premier actif et achète-le avec de l'argent fictif. », « Explorer les actifs ».
- [ ] Valeurs calculées sur des cours anciens : date affichée sous le total.

**Terminé quand** on peut acheter, voir son patrimoine évoluer et redémarrer sans rien perdre.

## S5. Simulateur (6 h)

F-SIM-01, F-SIM-02, F-SIM-03. F-SIM-04 en bonus.

### Formulaire (section 4.7)

- [ ] « Et si j'avais investi… ? ».
- [ ] Actif, montant à chaque fois, fréquence (« Chaque semaine », « Chaque mois »), date de début.
- [ ] Validation : actif obligatoire (« Choisis un actif ») ; montant de 1 € à 10 000 € (« Entre 1 € et 10 000 € ») ; date de début antérieure d'au moins une période à aujourd'hui et postérieure au premier cours disponible.
- [ ] « Lancer la simulation ». Historique chargé à la demande.

### Résultat

- [ ] « ← Modifier » et ligne de rappel : « 50 € chaque mois · Bitcoin · depuis janv. 2022 ».
- [ ] « Tu aurais investi », « Ça vaudrait aujourd'hui », performance et « 52 achats · prix moyen … ».
- [ ] Double courbe : capital investi en escalier, valeur du portefeuille simulé avec une aire légère, légende.
- [ ] « Modifier » et « Enregistrer », qui devient « Enregistrée ✓ ». Toast « Simulation enregistrée ».
- [ ] « Calculé sur les cours passés. Ça ne dit rien de l'avenir. »

### Simulations enregistrées

- [ ] Liste « Mes simulations » sous le formulaire : « 50 € / mois · Bitcoin », « DEPUIS JANV. 2022 », performance.
- [ ] Seuls les paramètres sont stockés, le résultat est recalculé à l'ouverture.

### Bonus

- [ ] F-SIM-04 : comparaison avec un investissement en une seule fois.

**Terminé quand** F-SIM-01 à 03 sont terminées, avec les états non configurée, configurée, calculée et enregistrée.

## S6. Onboarding, Apprendre et Réglages (5 h)

F-ONB-01, F-ONB-02, F-APP-01, F-APP-02, F-APP-03, F-GEN-02. Le cahier ne place F-GEN-02 dans aucun sprint, elle va ici parce qu'elle dépend de l'onboarding.

### Onboarding (section 4.2)

- [ ] Accueil : logo, « Ton premier patrimoine, sans risque. », « Des cours réels, de l'argent fictif. Tu apprends en essayant. », « C'est parti », « Passer ».
- [ ] Cinq questions à quatre réponses (textes de la maquette), barre de progression, retour, « QUESTION 2 SUR 5 », « Passer ». « Suivant » grisé tant que rien n'est choisi ; la dernière question affiche « Voir mon point de départ ».
- [ ] Résultat : « TON POINT DE DÉPART », niveau, « 3 bonnes réponses sur 5 », « Ce n'est pas une note. Ça sert juste à choisir tes premières leçons. », trois leçons « À LIRE EN PREMIER », « Découvrir Pécule ».
- [ ] Acceptation : apparaît une seule fois ; passé, il applique le niveau Découverte ; niveau et erreurs enregistrés en base ; peut être refait depuis les Réglages.

### Leçons (section 4.8)

- [ ] Fichier JSON embarqué : huit leçons avec numéro, titre, niveau, durée, paragraphes, illustration et appel à l'action.

| Leçon | Niveau | Illustration et action |
| --- | --- | --- |
| Actions, ETF et cryptos | Découverte | Comparer Apple, le S&P 500 et le Bitcoin |
| Rendement et performance | Découverte | « +18 % sur un an » sur un actif réel |
| Les intérêts composés | Découverte | 1 000 € à 5 %, curseur de 1 à 30 ans |
| Le DCA | Découverte | Simulation préremplie : 50 € par mois depuis 2022 |
| La diversification | Initié | Lien vers son propre anneau |
| La volatilité | Initié | Coca-Cola calme contre Tesla agitée sur un an, puis score de Tesla |
| La plus forte baisse | Initié | Repérer le sommet et le creux sur une courbe (Ethereum) |
| L'effet de change | À l'aise | Apple en dollars et en euros |

### Apprendre

- [ ] « Ton parcours », badge du niveau, barre « 3 LEÇONS SUR 8 ».
- [ ] « POUR TOI » : deux leçons mises en avant selon le niveau. Découverte : leçons de base pas encore vues. Initié : leçons liées aux erreurs. À l'aise : effet de change et plus forte baisse en premier.
- [ ] « TOUTES LES LEÇONS » : numéro, titre, niveau, durée, coche si vue.
- [ ] Détail : « LEÇON 06 · 3 MIN · INITIÉ », titre, paragraphes, illustration, bouton fixe d'appel à l'action. Une leçon ouverte est marquée comme vue.
- [ ] Brancher le lien de la carte de concentration du Patrimoine vers la leçon sur la diversification.

### Réglages (F-GEN-02)

- [ ] « Refaire le questionnaire » : « Ton niveau et tes leçons conseillées seront recalculés. »
- [ ] « Vider le cache » : « Les cours seront retéléchargés. Tes données restent. » Toast « Cache vidé ».
- [ ] « Réinitialiser le portefeuille », en rouge : « Supprime tous tes achats fictifs. » Toast « Portefeuille réinitialisé ».

**Terminé quand** un nouvel utilisateur suit le parcours complet.

## S7. Animations et finitions (5 h)

### Animations codées (section 10)

- [ ] Total du patrimoine qui compte jusqu'à sa valeur : `AnimationController` et `Tween<double>`, chiffres à chasse fixe.
- [ ] Courbe qui se dessine de gauche à droite : `CustomPainter` et extraction progressive du tracé (`PathMetric`).
- [ ] Jauge du score qui se remplit : `AnimationController` et `CurvedAnimation`.
- [ ] Résultat de simulation révélé en trois temps : un seul controller, plusieurs `Interval`.

### Micro-animations

- [ ] Vérifier à l'écran que les chiffres du total ne sautent pas pendant qu'il compte. Instrument Serif n'a pas de chiffres tabulaires optionnels (`tnum`), contrairement à Schibsted Grotesk.
- [ ] Cœur des favoris, transitions d'écran et de feuille, squelettes, anneau, indicateur d'onglet, toasts.
- [ ] Durées et courbes de `docs/regles/09-interface.md`.

### Finitions

- [ ] Chaque controller est créé dans `initState` et libéré dans `dispose`.
- [ ] Une animation ne repart que si sa valeur cible change, jamais à la reconstruction ni à la rotation.
- [ ] Passage écran par écran face à la maquette.

**Terminé quand** les animations sont fluides et libérées correctement.

## S8. Recette (2 h)

Sur un vrai téléphone, application installée en mode release (section 15).

| Scénario | Résultat attendu | OK |
| --- | --- | --- |
| Premier lancement | L'onboarding apparaît une seule fois | ☐ |
| Ouvrir trois fiches, couper le réseau, redémarrer | Fiches affichées avec leur date de mise à jour et le bandeau hors connexion | ☐ |
| Ouvrir hors connexion une fiche jamais vue | État vide explicite, aucun plantage | ☐ |
| Acheter un actif à une date de week-end | Cours du dernier jour de cotation utilisé et affiché | ☐ |
| Saisir un montant de 0 € | Message d'erreur, bouton désactivé | ☐ |
| Simuler depuis une date dans le futur | Validation refusée | ☐ |
| Rouvrir l'application le lendemain | Seuls les jours manquants sont téléchargés (journal de débogage) | ☐ |
| Mettre 70 % du portefeuille sur un seul actif | Alerte de concentration avec lien vers la leçon | ☐ |
| Vider le cache | Portefeuille, favoris et simulations intacts | ☐ |
| Faire tourner l'écran, revenir sur un onglet | Aucune perte d'état, aucune animation rejouée à tort | ☐ |
| `flutter test` et `flutter analyze` | Tout est vert, aucun avertissement | ☐ |

- [ ] Scénario de soutenance : ouvrir plusieurs fiches et le portefeuille, fermer complètement l'application, couper le réseau, rouvrir, parcourir les quatre onglets.
- [ ] Revue des cas limites, nettoyage du code (TODO, code mort, `print`).
- [ ] Captures pour le rapport.

**Terminé quand** toute la recette est cochée.

---

## Traçabilité des exigences de l'énoncé

| Exigence | Réponse dans Pécule | Sprint |
| --- | --- | --- |
| Au moins 3 écrans et navigation | Onboarding, 4 onglets, fiche, achat, leçon | S0, S3 à S6 |
| Formulaire avec validation | Achat fictif, simulation DCA | S4, S5 |
| Liste dynamique | Explorer (recherche, filtres, favoris), positions | S3, S4 |
| API REST et JSON vers Dart | Twelve Data, CoinGecko, Frankfurter, DTO testés | S2 |
| Persistance métier | SQLite : profil, leçons, favoris, transactions, simulations, préférences | S2 |
| Cache local d'API | Historiques et taux en base, incrémental | S2 |
| Hors connexion partiel | Tout consultable avec la date, bandeau | S2, S3, S8 |
| États chargement, données, erreur | `AsyncValue` et `CachedData` | S2 à S6 |
| Visualisation graphique | Courbe interactive, anneau, double courbe | S3, S4, S5 |
| Au moins deux calculs métier | Portefeuille, DCA, change, volatilité, baisse, score, concentration, intérêts composés | S1 |
| Trois animations dont deux codées | Quatre codées, plus des micro-animations | S7 |
| Tests unitaires du métier | Toute la couche domain, cas limites compris | S1, puis chaque sprint |

Évalués à part : l'architecture (section 11), la stratégie de cache justifiée (section 7), l'explicabilité du score (section 8.5).

## Risques et parades (section 16)

| Risque | Parade | Sprint |
| --- | --- | --- |
| Quota Twelve Data atteint | Chargement à la demande, file d'attente, cache préchauffé avant la soutenance | S2, S8 |
| Historique crypto limité sur le plan Demo | Vérifier tôt, borner la date de début, l'expliquer | S2, S5 |
| Cours non ajustés | Vérifier l'option d'ajustement, sinon documenter la limite (annexe A.5) | S2, rapport |
| Dépassement du temps | Priorités strictes, règle de pilotage | Tous |
| Code généré mal compris | Relecture systématique, `CLAUDE.md`, petites demandes ciblées | Tous |
| Fuite de clé API | Clés hors dépôt, fichier d'exemple, vérification avant chaque push | S0, tous |

## Hors périmètre (section 16.1)

Comptes utilisateurs et synchronisation, notifications, ventes fictives, frais de courtage simulés, actifs cotés en euros, mode clair, comparaison DCA contre investissement unique (F-SIM-04, sauf s'il reste du temps).

---

## Après le développement

### Rapport

- [ ] Repartir du cahier des charges et compléter avec ce qui a réellement été fait.
- [ ] Choix techniques à partir du journal des décisions.
- [ ] Stratégie de cache justifiée (section 7) et explicabilité du score (section 8.5).
- [ ] Limites : clé embarquée extractible (section 5.4), cours bruts éventuels (annexe A.5), bornes de l'historique crypto.
- [ ] Tests : ce qui est couvert, comment.
- [ ] Difficultés rencontrées et améliorations possibles.
- [ ] Harmoniser « Semis » en « Pécule ».
- [ ] Captures et schémas :
  - [ ] schéma de navigation
  - [ ] onboarding, question et écran de résultat
  - [ ] Explorer : liste, recherche, filtre favoris
  - [ ] fiche actif, haut de page avec courbe
  - [ ] fiche actif, score détaillé et cartes explicatives
  - [ ] formulaire d'achat, état valide et état en erreur
  - [ ] Patrimoine, portefeuille rempli
  - [ ] Patrimoine, portefeuille vide
  - [ ] Simulateur, formulaire
  - [ ] Simulateur, résultat et double courbe
  - [ ] Apprendre, liste et détail d'une leçon
  - [ ] planche des états transverses
  - [ ] schéma de la base de données
  - [ ] schéma des composants et des classes principales

### Soutenance

- [ ] Démonstration, cache préchauffé, scénario hors connexion répété.
- [ ] Réponses prêtes aux questions de section 11.3 : où est l'état, qui choisit entre cache et réseau, où sont les calculs, qui gère la persistance, comment remontent erreurs et chargements, ce qui se passe à la reconstruction d'un widget.
- [ ] Savoir modifier le code en direct : rien dans le dépôt qu'on ne sache expliquer.
