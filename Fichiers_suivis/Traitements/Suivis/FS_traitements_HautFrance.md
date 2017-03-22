Evolution des teneurs en carbone organique en Picardie et Nord-Pas-De-Calais
================
Jean-Baptiste Paroissien
27/01/2017

-   [Objectifs](#objectifs)
-   [Cartographie des évolutions en teneurs en carbone organique](#cartographie-des-evolutions-en-teneurs-en-carbone-organique)
    -   [Analyse de la distribution pour les différentes périodes](#analyse-de-la-distribution-pour-les-differentes-periodes)
    -   [Analyses des facteurs explicatifs](#analyses-des-facteurs-explicatifs)
    -   [Analyses des variables sélectionnées pour la 14 (1990-1994 2005-2009)](#analyses-des-variables-selectionnees-pour-la-14-1990-1994-2005-2009)
    -   [Relation linéaire](#relation-lineaire)
-   [BROUILLONS](#brouillons)
    -   [Cartographie des facteurs explicatifs](#cartographie-des-facteurs-explicatifs)
    -   [Analyses des variables sélectionnées pour la période 35](#analyses-des-variables-selectionnees-pour-la-periode-35)
    -   [Analyses des variables sélectionnées pour la période 24](#analyses-des-variables-selectionnees-pour-la-periode-24)

Objectifs
=========

Cartographie des évolutions en teneurs en carbone organique
===========================================================

Analyse de la distribution pour les différentes périodes
--------------------------------------------------------

<figure style="text-align:center;">
<a name="cdf_picardieNPC"></a><img src="FS_traitements_HautFrance_files/figure-markdown_github/cdf_npcpicardie-1.png">
<figcaption>
</figcaption>
</figure>
<figure style="text-align:center;">
<a name="boxplot_picardieNPC"></a><img src="FS_traitements_HautFrance_files/figure-markdown_github/boxplot_npcpicardie-1.png">
<figcaption>
</figcaption>
</figure>
    ## 
    ##  Pairwise comparisons using Wilcoxon rank sum test 
    ## 
    ## data:  melted_focus[, "value"] and melted_focus[, "annees"] 
    ## 
    ##      9094    9599    0004    0509   
    ## 9599 0.00019 -       -       -      
    ## 0004 < 2e-16 1.5e-08 -       -      
    ## 0509 < 2e-16 9.9e-06 0.08451 -      
    ## 1014 6.0e-12 0.01651 0.00046 0.03854
    ## 
    ## P value adjustment method: holm

<table style="width:83%;">
<caption>Statistiques descriptives des teneurs en carbone organique par périodes</caption>
<colgroup>
<col width="15%" />
<col width="9%" />
<col width="13%" />
<col width="12%" />
<col width="9%" />
<col width="13%" />
<col width="8%" />
</colgroup>
<thead>
<tr class="header">
<th align="center"> </th>
<th align="center">Min.</th>
<th align="center">1st Qu.</th>
<th align="center">Median</th>
<th align="center">Mean</th>
<th align="center">3rd Qu.</th>
<th align="center">Max.</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center"><strong>9094</strong></td>
<td align="center">8.13</td>
<td align="center">11.95</td>
<td align="center">13</td>
<td align="center">13.74</td>
<td align="center">14.4</td>
<td align="center">30.95</td>
</tr>
<tr class="even">
<td align="center"><strong>9599</strong></td>
<td align="center">8.11</td>
<td align="center">11.02</td>
<td align="center">12.24</td>
<td align="center">12.79</td>
<td align="center">13.44</td>
<td align="center">26.54</td>
</tr>
<tr class="odd">
<td align="center"><strong>0004</strong></td>
<td align="center">7.91</td>
<td align="center">10</td>
<td align="center">11</td>
<td align="center">11.62</td>
<td align="center">12</td>
<td align="center">22</td>
</tr>
<tr class="even">
<td align="center"><strong>0509</strong></td>
<td align="center">8.68</td>
<td align="center">10.59</td>
<td align="center">11.4</td>
<td align="center">11.92</td>
<td align="center">12.27</td>
<td align="center">29.57</td>
</tr>
<tr class="odd">
<td align="center"><strong>1014</strong></td>
<td align="center">8.1</td>
<td align="center">10.78</td>
<td align="center">11.6</td>
<td align="center">12.14</td>
<td align="center">12.85</td>
<td align="center">31.18</td>
</tr>
</tbody>
</table>

Analyses des facteurs explicatifs
---------------------------------

Dans un premier temps, l'ensemble des variables potentiellement explicatives est écrémé à travers une ACP et une modélisation avec un arbre de régression boosté. Ce dernier permet d'identifier les principaux facteurs explicatifs. Dans un deuxième temps, ces facteurs sont analysés dans le détail.

### Cubist

<table style="width:26%;">
<caption>Indicateur de qualité de la validation croisée de la modélisation de l'évolution des teneurs en CO les 1990-1994 et 2005-2009.</caption>
<colgroup>
<col width="9%" />
<col width="8%" />
<col width="8%" />
</colgroup>
<thead>
<tr class="header">
<th align="center">R2</th>
<th align="center">MSE</th>
<th align="center">RMSE</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">0.2186</td>
<td align="center">73.38</td>
<td align="center">8.464</td>
</tr>
</tbody>
</table>

<figure style="text-align:center;">
<a name="cubist_picardiNPC"></a><img src="FS_traitements_HautFrance_files/figure-markdown_github/unnamed-chunk-6-1.png">
<figcaption>
</figcaption>
</figure>
**En conclusion** de ce travail exploratoire, l'ordre d'importance des variables explicatives varie en fonction des variations étudiées. Dans plusieurs cas, la distinction de l'importance entre les variables est délicat.

Analyses des variables sélectionnées pour la 14 (1990-1994 2005-2009)
---------------------------------------------------------------------

<figure style="text-align:center;">
<a name="boxplot_occup"></a><img src="FS_traitements_HautFrance_files/figure-markdown_github/unnamed-chunk-7-1.png">
<figcaption>
</figcaption>
</figure>
Relation linéaire
-----------------

Ci-dessous, régression linéaire avec la variable la plus importante en sortie de modélisation cubist.

    ## Warning: Removed 116 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 130 rows containing missing values (geom_point).

<figure style="text-align:center;">
<a name="Graphs_correl_NPC_picardie"></a><img src="FS_traitements_HautFrance_files/figure-markdown_github/unnamed-chunk-8-1.png">
<figcaption>
</figcaption>
</figure>
    ## Warning: In lm.fit(x, y, offset = offset, singular.ok = singular.ok, ...) :
    ##  extra argument 'na.rm' will be disregarded

BROUILLONS
==========

    ## Warning: Removed 116 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 130 rows containing missing values (geom_point).

    ## Warning: Removed 116 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 130 rows containing missing values (geom_point).

    ## Warning: Removed 116 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 130 rows containing missing values (geom_point).

    ## Warning: Removed 81 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 108 rows containing missing values (geom_point).

    ## Warning: Removed 81 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 108 rows containing missing values (geom_point).

    ## Warning: Removed 81 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 108 rows containing missing values (geom_point).

<figure style="text-align:center;">
<a name="Graphs_correl_NPC_picardie2"></a><img src="FS_traitements_HautFrance_files/figure-markdown_github/unnamed-chunk-11-1.png">
<figcaption>
</figcaption>
</figure>
    ## TableGrob (2 x 1) "arrange": 2 grobs
    ##   z     cells    name              grob
    ## 1 1 (1-1,1-1) arrange   gtable[arrange]
    ## 2 2 (2-2,1-1) arrange gtable[guide-box]

Cartographie des facteurs explicatifs
-------------------------------------

Analyses des variables sélectionnées pour la période 35
-------------------------------------------------------

Analyses des variables sélectionnées pour la période 24
-------------------------------------------------------
