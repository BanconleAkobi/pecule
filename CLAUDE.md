# Pécule

Application Flutter pour apprendre l'investissement avec un portefeuille fictif basé sur des cours réels. Aucune transaction réelle, aucun compte, tout reste sur le téléphone. Projet individuel, FISA 5, INSA Hauts-de-France, 2026-2027.

- Référence fonctionnelle : `Externesfiles/Pecule_Cahier_des_charges.docx`
- Référence visuelle et textes affichés : `Externesfiles/Pecule.dc.html` (maquette interactive, iPhone 390 × 844). Elle prime sur la charte §13.1 du cahier.
- Plan de travail : `docs/plan-evolution.md` (sprints, décisions ouvertes, écarts maquette et cahier)

## Contexte

- Stack : Flutter (Dart), Riverpod, SQLite (drift ou sqflite, à trancher avant S2), http
- Tests : `flutter test`
- Analyse et format : `flutter analyze && dart format .`
- Build : `flutter build apk --dart-define-from-file=env.json`
- Langue : noms dans le code en anglais ; commentaires, descriptions de tests et textes affichés en français, tutoiement
- Chaque demande porte sur une seule fonctionnalité et cite son identifiant (F-XXX-00) et sa section du cahier des charges

## L'essentiel

1. Réfléchir avant d'agir. Lire les sources concernées en entier. En cas de doute, demander plutôt que deviner.
2. Petits pas, testés. Pas de logique métier sans un test qui a d'abord échoué.
3. Peu de commentaires, et seulement pour dire pourquoi. Jamais de paraphrase, jamais de ton « IA ».
4. `domain/` n'importe ni Flutter, ni Riverpod, ni la base, ni http. `build()` ne fait qu'afficher.
5. Aucune dépendance, couche ou abstraction nouvelle sans mon accord.
6. Rien dans le dépôt que je ne saurais pas expliquer en soutenance.

## Règles détaillées

@docs/regles/01-methode.md
@docs/regles/02-code-propre.md
@docs/regles/03-commentaires.md
@docs/regles/04-erreurs.md
@docs/regles/05-tests.md
@docs/regles/06-architecture.md
@docs/regles/07-flutter.md
@docs/regles/08-donnees.md
@docs/regles/09-interface.md
@docs/regles/10-git.md
