# Pécule

Ton premier patrimoine, sans risque. Une application Flutter pour apprendre l'investissement avec un portefeuille fictif basé sur des cours réels. Aucune transaction réelle, aucun compte : tout reste sur le téléphone.

Projet individuel, FISA 5 Informatique, INSA Hauts-de-France, 2026-2027.

## Lancer l'application

1. Copier `env.example.json` en `env.json` et y mettre les clés Twelve Data et CoinGecko (Demo). `env.json` n'est jamais versionné.
2. Lancer :

```
flutter pub get
flutter run --dart-define-from-file=env.json
```

## Vérifier

```
flutter analyze
flutter test
dart format .
```

## Documentation

- `CLAUDE.md` : contexte et règles de travail
- `docs/regles/` : règles de code
- `docs/plan-evolution.md` : plan des sprints
- `docs/mcd.md` : modèle de données
- `docs/journal-decisions.md` : décisions techniques
- `Externesfiles/` : cahier des charges et maquette interactive
