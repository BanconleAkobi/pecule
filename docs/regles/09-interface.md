# Interface

La maquette `Externesfiles/Pecule.dc.html` est la référence visuelle, y compris pour les textes affichés. Elle remplace la charte de la section 13.1 du cahier des charges (violet et Inter). Quand un écran est construit, on reprend sa mise en page, ses libellés et ses messages tels qu'ils sont dans la maquette.

Toutes les valeurs ci-dessous vivent dans le thème (`app/`), nulle part ailleurs.

## Couleurs

Mode sombre uniquement.

| Rôle | Valeur | Usage |
| --- | --- | --- |
| Fond | `#0E110D` | Écrans, barre d'onglets |
| Surface | `#171B16` | Cartes, champs, feuilles, boutons ronds |
| Surface haute | `#20251F` | Cartes dans une carte, séparateurs de liste, squelettes, fond des jauges |
| Bordure | `#2D332B` | Contours des boutons secondaires et des puces, poignée des feuilles |
| Trait discret | `#4A5245` | Curseur de la courbe, cercle pointillé du portefeuille vide |
| Texte | `#F3F1E7` | Texte principal, toast, puce ou période sélectionnée |
| Texte de lecture | `#C9CCBE` | Explications dans les cartes |
| Texte de leçon | `#DCDDD2` | Paragraphes des leçons |
| Texte secondaire | `#A3A898` | Libellés, métadonnées |
| Texte discret | `#6E7466` | Onglet inactif, bouton désactivé, cœur vide, courbe du capital investi |
| Pollen | `#E2F24B` | Actions principales et chiffre clé |
| Sur pollen | `#12160A` | Texte posé sur le pollen |
| Gain | `#6EE7A8` | Hausse, leçon vue, score « Stable » |
| Perte | `#FF8A73` | Baisse, erreur, action destructive, score « Agité » |
| Alerte | `#2A2418` | Fond de la carte de conseil de concentration |
| Actions | `#8EC5FF` | Type d'actif |
| ETF | `#E2F24B` | Type d'actif |
| Cryptos | `#F0A3D9` | Type d'actif |

- Le pollen est réservé aux actions principales et au chiffre clé. Jamais pour un gain ou une perte.
- Un gain ou une perte s'affiche toujours avec son signe et une flèche (▲ ▼), jamais avec la couleur seule.
- Pastille d'un actif : initiales (3 lettres au plus) dans la couleur de son type, sur un fond de cette couleur à 14 % d'opacité.
- Courbe d'une fiche : vert si la période finit plus haut qu'elle ne commence, rouge sinon, avec un remplissage à 8 % sous la courbe.
- Voile derrière une feuille : noir à 55 %.

## Typographie

| Police | Rôle |
| --- | --- |
| Instrument Serif | La voix « éditoriale » : gros chiffres, titres d'écran et de section, logo « pécule » en italique minuscule |
| Schibsted Grotesk | Interface : texte courant, boutons, listes. Chiffres tabulaires |
| JetBrains Mono | Dates, symboles, métadonnées, petits libellés en majuscules espacées (« QUESTION 2 SUR 5 », « 1 AN ») |

Les polices sont embarquées dans l'application, pour fonctionner hors connexion.

| Niveau | Taille | Exemples |
| --- | --- | --- |
| Affiche | 58 à 92 | Niveau du questionnaire, total du patrimoine (62), titre d'accueil, montant d'achat |
| Chiffre clé | 50 à 64 | Cours de la fiche (56), valeur finale de simulation (64), score (50) |
| Titre d'écran | 40 à 46 | « Explorer », « Ton parcours », question du quiz, titre de leçon |
| Titre de section | 26 à 30 | « Mes positions », « Dollar ou euro ? », « Score de stabilité » |
| Texte | 14 à 17 | Lignes de liste (15,5), paragraphes |
| Métadonnée | 11 à 12 | JetBrains Mono, souvent en majuscules |

Les chiffres qui changent (total, cours, compteurs animés) utilisent des chiffres à chasse fixe (`FontFeature.tabularFigures()`).

## Formes et espacements

- Marges d'écran : 20. Marges des cartes dans la fiche actif : 16.
- Bouton principal : pilule pollen, hauteur 56 à 58.
- Bouton secondaire : pilule transparente, contour de 1 en bordure, hauteur 50 à 52.
- Cartes : rayon 20. Cartes internes : 14. Champs : 14 à 16. Puces et périodes : hauteur 36, pilule.
- Feuilles du bas : rayon 28 en haut, poignée 40 × 5.
- Zones tactiles d'au moins 44 × 44.

## Composants communs

| Composant | Comportement |
| --- | --- |
| Barre d'onglets | 4 libellés texte, sans icône. Onglet actif : texte clair et trait pollen de 22 × 4 au-dessus. Inactif : texte discret |
| Chiffre traduisible | Chiffre souligné en pointillés. Au toucher, ouvre la feuille « En clair » |
| Feuille « En clair » | Fond pollen, libellé « EN CLAIR », titre « +16,1 %, en clair », phrase simple avec des montants concrets, bouton « Compris » |
| Toast | Pilule claire en bas, au-dessus des onglets, 2,2 s (« Ajouté à tes favoris », « Simulation enregistrée », « Cache vidé ») |
| Bandeau hors connexion | Sous la barre d'état, point rouge : « Hors connexion · données du 4 oct. à 18:02 » |
| Bouton fixe en bas | Sur la fiche et la leçon, avec un dégradé du fond vers le transparent au-dessus |
| Feuille du bas | Achat fictif et Réglages. Se ferme au toucher du voile |
| Squelettes | Formes surface haute à l'emplacement exact du contenu, pulsation de 1,4 s |

## Mouvement

| Élément | Durée et courbe |
| --- | --- |
| Écran par-dessus (fiche, leçon) | Glisse depuis la droite, 0,32 s, ease-out |
| Feuille du bas | Monte, 0,35 s, `Cubic(.2, .8, .2, 1)` |
| Fondu d'onglet ou de contenu | 0,3 s |
| Total du patrimoine | Compte jusqu'à la valeur, 1,3 s, ease-out cubique |
| Courbe d'une fiche | Se dessine en 1,2 s, `Cubic(.4, 0, .2, 1)` |
| Jauge du score | Démarre 0,45 s après l'ouverture, se remplit en 1,3 s, `Cubic(.3, .7, .2, 1)` |
| Résultat de simulation | Trois blocs révélés à 0,12 s, 0,8 s et 2 s ; la valeur finale compte en 1,1 s |
| Anneau de répartition | Segments animés en 0,9 s |
| Cœur des favoris | Grossit à 1,45 puis revient, 0,45 s |
| Indicateur d'onglet | 0,25 s |

## Formats

Tous via les formateurs de `core/`, en français :

- Montant : `1 234,56 €`. Trois décimales pour un cours inférieur à 1 € (`0,214 €`). Montants de simulation arrondis à l'euro (`2 250 €`).
- Pourcentage : signe toujours présent, vrai signe moins (`−`, U+2212), une décimale : `+12,6 %`, `−8,4 %`. Avec flèche : `▲ +12,6 %`.
- Quantité : au plus 4 décimales, suivie du symbole (`0,0054 BTC`).
- Taux de change : 4 décimales (`1,0952`).
- Dates : `4 oct. 2026`, `Mis à jour le 4 oct. à 18:02`, jour de cotation utilisé : `Cours du vendredi 3 janvier utilisé`.

## Ton

- Tutoiement, phrases courtes, jamais de jugement.
- Pas de jargon sans explication. Chaque indicateur a sa carte « Ça veut dire quoi ? », écrite avec les chiffres de l'actif concerné.
- Tout ce qui parle du passé le rappelle : « Basé sur le passé, ce n'est pas une prédiction. », « Calculé sur les cours passés. Ça ne dit rien de l'avenir. »
- Le fictif est toujours visible : « Ton patrimoine fictif », « Aucun argent réel n'est utilisé. »

## États à prévoir sur chaque écran

| État | Ce qu'on voit |
| --- | --- |
| Chargement sans données | Squelettes. Sur la fiche : bloc pulsant « Chargement de l'historique… » à la place de la courbe |
| Données | Contenu complet, avec la date de mise à jour si elles viennent du réseau |
| Actualisation | Contenu conservé, indicateur discret. Jamais d'écran vide |
| Erreur sans données | Message simple et bouton « Réessayer » |
| Erreur avec cache | Contenu en cache, date, bandeau d'information |
| Hors connexion | Bandeau, et métadonnées adaptées (« 30 ACTIFS · DERNIERS COURS CONNUS (4 OCT.) ») |
| Jamais téléchargé et hors connexion | État vide explicite, pas une erreur |
| Vide | Titre, phrase d'invitation, action (« Ton patrimoine commence ici. », « Pas encore de favori », « Aucun résultat ») |

## Navigation

- Premier lancement : accueil, questionnaire, résultat. Ensuite, quatre onglets : Patrimoine, Explorer, Apprendre, Simulateur.
- Fiche actif et détail de leçon s'ouvrent par-dessus l'onglet courant. Achat fictif et Réglages sont des feuilles du bas. Le retour ramène là où on était.
- Les Réglages s'ouvrent depuis le bouton « Réglages » en haut de Patrimoine.
- Chaque onglet garde sa position de défilement. Rien n'est perdu en changeant d'onglet ou en tournant l'écran.

## Formulaires

- Le message d'erreur apparaît sous le champ concerné, en rouge, et le contour du champ passe en rouge.
- Le bouton de validation reste grisé (fond bordure, texte discret) tant que le formulaire est invalide.
- Avant de valider un achat, on montre le cours à la date choisie, le taux EUR/USD et la quantité obtenue.
