# Git et suivi

## Commits

- Un commit, une intention. Pas de commit fourre-tout.
- Avant chaque commit : `flutter test`, `flutter analyze`, `dart format .`, tous propres.
- Message en anglais, à l'impératif, court, avec l'identifiant de la fonctionnalité quand il y en a un :

```
F-FIC-02: compute stability score from volatility and drawdown
```

- Le corps du message, s'il existe, explique pourquoi. Le quoi se lit dans le diff.
- Pas de commit ni de push sans que je l'aie demandé.
- Jamais de ligne `Co-Authored-By` ni de mention d'un outil d'IA dans un commit ou une PR.

## Ne jamais commiter

- `env.json` ou toute clé API.
- Du code commenté, des `print`, des fichiers de débogage.
- Du code que je n'ai pas relu et compris.

## Fin de sprint

- Un commit propre qui ferme le sprint.
- Une ligne dans le journal des décisions (section 17 du cahier) pour chaque choix technique pris.
- Les cases correspondantes du tableau de traçabilité (section 2) cochées.
