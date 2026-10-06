# Méthode de travail

On réfléchit d'abord, on code ensuite. Un changement qu'on ne sait pas expliquer n'a rien à faire dans le dépôt.

## Avant d'écrire du code

- Lire le code existant autour de la zone touchée, et la section du cahier des charges concernée.
- Dire en une ou deux phrases ce qui va changer et ce qui ne change pas.
- Si la demande est floue ou contredit le cahier des charges, poser la question. Ne pas deviner.
- Pour une tâche qui touche plus de trois ou quatre fichiers, proposer un plan court et attendre mon accord.

## Pendant

- Une fonctionnalité à la fois. Pas de modification « tant qu'on y est » hors du périmètre demandé.
- Petits pas : un test, le code qui le fait passer, un nettoyage. Puis le suivant.
- Suivre le style du code déjà en place plutôt qu'imposer le sien.
- Ne jamais supprimer ou réécrire en masse sans l'avoir annoncé.
- Préférer la solution simple et lisible à la solution astucieuse.

## Ce qui demande mon accord

- Lancer une commande (tests, analyse, git, appels réseau, flutter). Claude la lance lui-même, avec une description claire, et je la valide dans la demande d'autorisation. On regroupe les commandes liées.
- Ajouter une dépendance. Elle doit aussi être ajoutée au tableau 11.4 du cahier des charges avec sa raison.
- Ajouter une couche, un patron de conception ou une abstraction « pour plus tard ».
- Modifier le schéma de la base.
- Revenir sur une décision déjà prise (journal des décisions, section 17).

## Après

Un compte rendu court et honnête :

- ce qui a été fait ;
- la sortie de `flutter test` et de `flutter analyze` ;
- ce qui n'a pas été fait, ou ce qui reste incertain, dit clairement.

Pas de « tout fonctionne » sans preuve. Si un test échoue, on le montre.

## Écrire comme un humain

Valable pour le code, les commentaires, les messages de commit et les comptes rendus :

- phrases courtes, mots simples, information utile seulement ;
- pas d'emojis, pas de points d'exclamation, pas de formules creuses (« robuste », « élégant », « seamless », « Voici… ») ;
- pas de résumé de ce qui vient d'être dit ;
- jamais le signe « § » (on écrit « section 8.1 ») ni le tiret cadratin « — ».
