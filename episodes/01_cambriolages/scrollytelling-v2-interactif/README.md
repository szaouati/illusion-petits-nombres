# Scrollytelling v2 — version interactive D3

Version expérimentale de la page de l'épisode 1.
La v1 (dans `../scrollytelling/`) reste la version de référence.

## Différences avec la v1

| Aspect              | v1 (scrollytelling)             | v2 (cette page)                   |
|---------------------|---------------------------------|-----------------------------------|
| Graphiques          | 10 SVG statiques pré-générés    | 1 SVG dynamique côté client       |
| Transitions         | Fondus enchaînés (CSS opacity)  | D3 transitions (couleur, taille, position) |
| Interaction         | Aucune                          | Tooltip au survol, données live   |
| Source des données  | Données figées dans les SVG     | Lecture du CSV au runtime         |
| Poids               | ~1,1 MB de SVG                  | ~425 KB de CSV + ~80 KB de D3     |
| Indexabilité (SEO)  | Bonne                           | Faible (rendu JS)                 |
| Accessibilité       | Bonne (alt sur SVG)             | Plus délicate                     |

## Architecture

Tout est dans `index.html`. Pas de build, pas de bundler.

1. Au chargement, D3 lit `../cambriolages_2024.csv` (10 951 lignes).
2. Un seul SVG est construit, avec :
   - Axes log + linéaire
   - Une grille
   - Un `<rect>` pour la bande des grandes communes (initialement caché)
   - Une `<line>` pour le seuil 10 000 (initialement caché)
   - Un `<g>` qui contient les 10 951 cercles
3. Scrollama détecte l'entrée de chaque `.scrolly-step`.
4. Une fonction `applyState(state, data)` met à jour les attributs des
   cercles avec une transition de 600 ms. Pas de re-rendu, juste un
   changement de styling.

## Pistes d'extension

Toutes faisables sans changement d'architecture lourd :

- **Animation de position.** Aujourd'hui les points ne bougent pas, ils
  changent juste de couleur et de taille. On pourrait, à l'étape 5
  (seuil), faire glisser les communes < 10 000 hab. vers le bas et
  l'opacité 0, puis recentrer les axes sur les 1 116 restantes.

- **Slider sur n.** Pour la simulation Poisson, un slider qui contrôle
  le nombre de logements (n entre 50 et 100 000). Les 1 000 points se
  retirent et se rejouent en temps réel à chaque changement. Niveau
  pédagogique inégalable.

- **Hover groupé.** Au survol d'un point, mettre en évidence aussi les
  autres communes du même département.

- **Lien sortant.** Au clic sur un point, ouvrir la page de la commune
  sur Wikipedia ou la carte SSMSI correspondante.

- **Brush/zoom.** Permettre au lecteur de sélectionner une zone du
  scatter pour zoomer dessus.

- **Annotations contextuelles.** Quand le lecteur entre dans l'étape 4,
  faire apparaître des labels animés sur Paris/Marseille/Lyon plutôt
  que de les laisser dans le carton de texte.

## Pour la simulation Poisson

Pas encore implémentée dans cette v2. Idée : un canvas plutôt qu'un SVG
(performance), avec re-tirage en JS via une approximation Poisson.
Pour le moment, la v1 (SVG statique de matplotlib) reste la voie la
plus rigoureuse.

## Tests

Pour servir localement (le navigateur n'autorise pas `file://` à lire
des CSV par fetch) :

```sh
cd episodes/01_cambriolages
python3 -m http.server 8000
# puis ouvrir http://localhost:8000/scrollytelling-v2-interactif/
```

GitHub Pages servira la page sans difficulté.

## Décision : v1 ou v2 ?

Pour la publication immédiate de l'épisode 1, partir sur la v1 :
- Plus stable, plus accessible, plus lisible sur tous les terminaux.
- Indexable par les moteurs de recherche.
- Le fond mathématique passe.

Pour les épisodes suivants où la dataviz devient le sujet (ép. 5
maternités, ép. 7 médecins Google, ép. 9 PMA), tester la v2 et voir si
l'interactivité ajoute vraiment quelque chose à la démonstration.

L'architecture est posée — il suffit de copier ce dossier et de
remplacer le state machine de `applyState()`.
