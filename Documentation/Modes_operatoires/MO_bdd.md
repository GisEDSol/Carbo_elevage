Prise en main pour exploiter la base de données
================
Jean-Baptiste Paroissien
20/02/2017

-   [Objectif et domaine d'application](#objectif-et-domaine-dapplication)
-   [L'architecture et l'organisation de la base de données](#larchitecture-et-lorganisation-de-la-base-de-donnees)
    -   [Architecture technique](#architecture-technique)
    -   [Organisation de la base de données](#organisation-de-la-base-de-donnees)
-   [Les données brutes](#les-donnees-brutes-1)
    -   [Les tables de la BDAT](#les-tables-de-la-bdat)
    -   [Les tables du recensement agricole](#les-tables-du-recensement-agricole)
    -   [Les tables de Corine Land Cover](#les-tables-de-corine-land-cover)
-   [Les data\_mart](#les-data_mart)
    -   [La table dm\_vecteurs.canton et de ses filtres](#la-table-dm_vecteurs.canton-et-de-ses-filtres)
    -   [Les tables au format long (dm\_traitements.melted et autres)](#les-tables-au-format-long-dm_traitements.melted-et-autres)

Objectif et domaine d'application
=================================

L'objectif de ce document est de fournir les informations nécessaires pour pouvoir utiliser la base de données appelée `sol_elevage`. Le document présente l'organisation des données et les explications pour son exploitation.

L'architecture et l'organisation de la base de données
======================================================

Architecture technique
----------------------

L'ensemble des données est stocké dans une base de données type postgresql/postgis. Le serveur de la base est en local et des conversions seront réalisées régulièrement vers une base SQLite/Spatialite pour faciliter le partage des données. SQLite diffère de la plupart des systèmes de gestion de base de données par la gestion d'un fichier de base directement sur le disque dur. A la différence de postgresql/postgis, il ne nécessite pas la création d'un serveur, ce qui facilite les échanges. Plus d'infos, [ici](http://www.developpez.com/actu/94614/Un-developpeur-evoque-cinq-raisons-pour-vous-faire-utiliser-SQLite-en-2016-que-pensez-vous-de-ses-arguments/).

Organisation de la base de données
----------------------------------

Deux types de données sont intégrées dans la base : les données brutes et les données élaborées

### Les données brutes

<table>
<caption>Liste des schémas de la base de données</caption>
<colgroup>
<col width="11%" />
<col width="88%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Schéma</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">ra</td>
<td align="left">Schéma regroupant l’ensemble<br />
des tables brutes du<br />
recensement agricole</td>
</tr>
<tr class="even">
<td align="left">clc</td>
<td align="left">Schéma de stockage des tables<br />
brutes de Corine Land Cover.<br />
Correspond aux différentes<br />
feuilles excel du fichier<br />
stats_clc_commune_niveau_2.xls<br />
téléchargé à cette adresse :<br />
<a href="http://www.statistiques.developpement-durable.gouv.fr/clc/fichiers/" class="uri">http://www.statistiques.developpement-durable.gouv.fr/clc/fichiers/</a></td>
</tr>
<tr class="odd">
<td align="left">climat</td>
<td align="left">Schéma de stockage des tables<br />
en lien avec les données<br />
climatiques</td>
</tr>
<tr class="even">
<td align="left">bdat</td>
<td align="left">Schéma de stockage des données<br />
de la BDAT</td>
</tr>
<tr class="odd">
<td align="left">bdgsf</td>
<td align="left">Schéma de stockage de la base<br />
de données européenne des sols<br />
(emprise France)</td>
</tr>
</tbody>
</table>

### Les data marts

Les data marts (magasins de données) sont les données qui sont directement utilisables dans des traitements. Ces data marts se présentent sous la forme d'une ou plusieurs tables classées dans des schémas distincts. Le nom de ces schémas est préfixé par « dm\_». Le tableau suivant dresse la liste des data marts disponibles :

<table style="width:62%;">
<caption>Liste des schémas de la base de données</caption>
<colgroup>
<col width="20%" />
<col width="41%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Schéma</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">dm_rasters</td>
<td align="left">Schéma regroupant différentes<br />
couches rasters au format<br />
PostGIS</td>
</tr>
<tr class="even">
<td align="left">dm_vecteurs</td>
<td align="left">Schéma regroupant différentes<br />
couches vecteurs au format<br />
PostGIS</td>
</tr>
<tr class="odd">
<td align="left">dm_traitements</td>
<td align="left">Schéma pour stocker les tables<br />
finalisées prêtes pour des<br />
analyses statistiques</td>
</tr>
</tbody>
</table>

Les données brutes
==================

Description des principales tables présentent dans les schémas. L'ensemble de la description des tables est également accessible sur cette table.

*Pour plus de détails sur la construction de ces tables, le lecteur intéressé peut consulter le [fichier de suivi](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/BDD/Suivis/FS_bdd_Brute.Rmd).*

Les tables de la BDAT
---------------------

La description des tables brutes de la BDAT est décrit dans le tableau ci-dessous. Les `XXXX` correspondent aux périodes d'analyse suivantes :

-   1: 1990-1994
-   2: 1995-1999
-   3: 2000-2004
-   4: 2005-2009
-   5: 2010-2014

Les `XX` correspondent aux numéros des périodes comparées entre elles. Par exemple, **12** correspond à la comparaison des teneurs en carbone organique entre 1990-1994 et 1995-1999.

**Nota** les données provenant du datapaper sont téléchargeables à cette [adresse](http://www.gissol.fr/wp-content/uploads/2015/04/bdat.zip)

<table>
<caption>Liste des tables brutes de la BDAT</caption>
<colgroup>
<col width="37%" />
<col width="62%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Table</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">bdat_cantonXXXX</td>
<td align="left">Analyses cantonales de la BDAT provenant du<br />
datapaper</td>
</tr>
<tr class="even">
<td align="left">bdat_depart_XXXX</td>
<td align="left">Analyses départementales de la BDAT provenant du<br />
datapaper</td>
</tr>
<tr class="odd">
<td align="left">bdat_pra_XXXX</td>
<td align="left">Analyses par petites régions agricoles de la BDAT<br />
provenant du datapaper</td>
</tr>
<tr class="even">
<td align="left">bdat_region_XXXX</td>
<td align="left">Analyses régionales de la BDAT provenant du<br />
datapaper</td>
</tr>
<tr class="odd">
<td align="left">bdat_canton_corgco_XXXX</td>
<td align="left">Analyses après ré-échantillonnage des teneurs en<br />
carbone organique issues de la méthode combustion<br />
sèche (co)</td>
</tr>
<tr class="even">
<td align="left">bdat_canton_corgco_compXX</td>
<td align="left">Comparaison entre deux périodes de la médiane des<br />
teneurs en carbone organique après<br />
ré-échantillonnage pour la méthode combustion<br />
sèche (co)</td>
</tr>
<tr class="odd">
<td align="left">bdat_canton_corgequivXXXX</td>
<td align="left">Analyses après ré-échantillonnage des teneurs en<br />
carbone organique issues des deux méthodes (ox et<br />
co)</td>
</tr>
<tr class="even">
<td align="left">bdat_canton_corgequiv_comp_XX</td>
<td align="left">Comparaison entre deux périodes de la médiane des<br />
teneurs en carbone organique après<br />
ré-échantillonnage pour les deux méthodes (ox et<br />
co)</td>
</tr>
<tr class="odd">
<td align="left">bdat_canton_corgox_XXXX</td>
<td align="left">Analyses après ré-échantillonnage des teneurs en<br />
carbone organique issues de la méthode oxydation<br />
humide (ox)</td>
</tr>
<tr class="even">
<td align="left">bdat_canton_corgox_comp_XX</td>
<td align="left">Comparaison entre deux périodes de la médiane des<br />
teneurs en carbone organique après<br />
ré-échantillonnage pour la méthode oxydation<br />
humide (ox)</td>
</tr>
</tbody>
</table>

Les tables du recensement agricole
----------------------------------

<table>
<caption>Liste des tables brutes du recensement agricole</caption>
<colgroup>
<col width="32%" />
<col width="67%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Table</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">MethodeCulture_canton2010</td>
<td align="left">Méthodes de cultures en nombre d’exploitation par<br />
canton pour le ra 2010</td>
</tr>
<tr class="even">
<td align="left">Otex_canton1988</td>
<td align="left">Orientation technico-économique des exploitations par<br />
canton pour le ra 1988</td>
</tr>
<tr class="odd">
<td align="left">Otex_canton2000</td>
<td align="left">Orientation technico-économique des exploitations par<br />
canton pour le ra 2000</td>
</tr>
<tr class="even">
<td align="left">Otex_canton2010</td>
<td align="left">Orientation technico-économique des exploitations par<br />
canton pour le ra 2010</td>
</tr>
<tr class="odd">
<td align="left">Cultures_canton1979</td>
<td align="left">Nombre d’exploitation par canton classées par type de<br />
culture pour le ra 1979</td>
</tr>
<tr class="even">
<td align="left">Cultures_canton1988</td>
<td align="left">Nombre d’exploitation par canton classées par type de<br />
culture pour le ra 1988</td>
</tr>
<tr class="odd">
<td align="left">Cultures_canton2000</td>
<td align="left">Nombre d’exploitation par canton classées par type de<br />
culture pour le ra 2000</td>
</tr>
<tr class="even">
<td align="left">Cultures_canton2010</td>
<td align="left">Nombre d’exploitation par canton classées par type de<br />
culture pour le ra 2010</td>
</tr>
<tr class="odd">
<td align="left">S_cultures_canton1970</td>
<td align="left">Surfaces des cultures par canton pour le ra 1970</td>
</tr>
<tr class="even">
<td align="left">S_cultures_canton1979</td>
<td align="left">Surfaces des cultures par canton pour le ra 1979</td>
</tr>
<tr class="odd">
<td align="left">S_cultures_canton1988</td>
<td align="left">Surfaces des cultures par canton pour le ra 1988</td>
</tr>
<tr class="even">
<td align="left">S_cultures_canton2000</td>
<td align="left">Surfaces des cultures par canton pour le ra 2000</td>
</tr>
<tr class="odd">
<td align="left">S_cultures_canton2010</td>
<td align="left">Surfaces des cultures par canton pour le ra 2010</td>
</tr>
<tr class="even">
<td align="left">UGBGrani_canton2000</td>
<td align="left">Unité gros bétail tous aliments des granivores par<br />
canton pour le ra 2000</td>
</tr>
<tr class="odd">
<td align="left">UGBGrani_canton2010</td>
<td align="left">Unité gros bétail tous aliments des granivores par<br />
canton pour le ra 2010</td>
</tr>
<tr class="even">
<td align="left">UGBHerbi_canton2000</td>
<td align="left">Unité gros bétail tous aliments des herbivores par<br />
canton pour le ra 2000</td>
</tr>
<tr class="odd">
<td align="left">UGBHerbi_canton2010</td>
<td align="left">Unité gros bétail tous aliments des herbivores par<br />
canton pour le ra 2010</td>
</tr>
<tr class="even">
<td align="left">UGBTA_canton2000</td>
<td align="left">Unité gros bétail tous aliments par canton pour le ra<br />
2000</td>
</tr>
<tr class="odd">
<td align="left">UGBTA_canton2010</td>
<td align="left">Unité gros bétail tous aliments par canton pour le ra<br />
2010</td>
</tr>
<tr class="even">
<td align="left">UGBTA_canton880010</td>
<td align="left">Unité gros bétail tous aliments par canton pour les ra<br />
1988,2000,2010</td>
</tr>
</tbody>
</table>

Les tables de Corine Land Cover
-------------------------------

<table>
<caption>Liste des tables brutes de Corine Land Cover</caption>
<colgroup>
<col width="23%" />
<col width="76%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Table</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">changements00_06</td>
<td align="left">Superficies changements Corine Land Cover entre 2000 et<br />
2006 par poste initial (CODE_00) et final (CODE_06) et<br />
suivant le découpage géographique</td>
</tr>
<tr class="even">
<td align="left">changements06_12</td>
<td align="left">Superficies changements CORINE Land Cover entre 2006 et<br />
2012 par poste initial (CODE_06) et final (CODE_12) et<br />
suivant le découpage géographique</td>
</tr>
<tr class="odd">
<td align="left">changements90_00</td>
<td align="left">Superficies changements Corine Land Cover entre 1990 et<br />
2000 par poste initial (CODE_90) et final (CODE_00) et<br />
suivant le découpage géographique</td>
</tr>
<tr class="even">
<td align="left">clc00_revisee</td>
<td align="left">Superficies Corine Land Cover 2000 révisé par poste et<br />
suivant le découpage géographique</td>
</tr>
<tr class="odd">
<td align="left">clc06_revisee</td>
<td align="left">Superficies CORINE Land Cover 2006 révisée par poste<br />
et suivant le découpage géographique</td>
</tr>
<tr class="even">
<td align="left">clc12</td>
<td align="left">Superficies CORINE Land Cover 2012 par poste et suivant<br />
le découpage géographique</td>
</tr>
<tr class="odd">
<td align="left">clc90</td>
<td align="left">Superficies Corine Land Cover 1990 par poste et suivant<br />
le découpage géographique</td>
</tr>
</tbody>
</table>

Les data\_mart
==============

Les tables de travail utilisées sont stockées dans les `data_mart` et sont décrites dans le détail dans cette section. Pour plus de détails sur ces tables, l'ensemble des fichiers de suivi associés à leurs créations sont consultables dans ce [répertoire](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/BDD/Suivis/). Le nom des fichiers ont comme préfixe `FS_bdd_elab`.

La table dm\_vecteurs.canton et de ses filtres
----------------------------------------------

La table `dm_vecteurs.canton` centralise l'ensemble des données de travail à l'échelle du canton. C'est une table au format PostGis, elle contient une colonne géométrique (`geom`) permettant une visualisation dans un Système d'Information Géographique.
D'autres déclinaisons de cette table ont été créées pour répondre à des besoins d'analyses spécifiques. Il s'agit de filtres créés pour travailler sur des jeux de données homogènes en terme de données sur les sols. La création de ces filtres a été réalisée dans ce [fichier de suivi](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/BDD/Suivis/FS_bdd_elab_bdat.Rmd).

-   **dm\_vecteurs.canton\_9014 :** filtre de la table dm\_vecteurs.canton basée sur la disponibilité complète et homogène des teneurs en carbone organique sur la période 1990-2014.
-   **dm\_vecteurs.canton\_9514 :** filtre de la table dm\_vecteurs.canton basée sur la disponibilité homogène des teneurs en carbone organique sur la période 1995-2014 (exclusion de la période 1990-1994),

La description des champs de cette table est présentée ci-dessous.

<table>
<caption>Description des champs de la table dm_vecteurs.canton</caption>
<colgroup>
<col width="35%" />
<col width="65%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Colonne</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">altimean</td>
<td align="left">Altitude moyenne (en m).</td>
</tr>
<tr class="even">
<td align="left">ampli_t_juil_janv</td>
<td align="left">Amplitude thermique (°C) (juillet-janvier)</td>
</tr>
<tr class="odd">
<td align="left">argi_med</td>
<td align="left">Médiane du taux d'argile (g/kg) calculée sur<br />
1990-2009.</td>
</tr>
<tr class="even">
<td align="left">classe_altimean</td>
<td align="left">Classes des altitudes moyennes par canton avec la<br />
méthode quantile et établies sur la variable<br />
altimean.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_c1970</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_c1970.</td>
</tr>
<tr class="even">
<td align="left">classe_p_c1979</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_c1979.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_c1988</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_c1988.</td>
</tr>
<tr class="even">
<td align="left">classe_p_c2000</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_c2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_c2010</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_c2010.</td>
</tr>
<tr class="even">
<td align="left">classe_p_cop1970</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_cop1970.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_cop1979</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_cop1979.</td>
</tr>
<tr class="even">
<td align="left">classe_p_cop1988</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_cop1988.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_cop2000</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_cop2000.</td>
</tr>
<tr class="even">
<td align="left">classe_p_cop2010</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_cop2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_mf1970</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_mf1970.</td>
</tr>
<tr class="even">
<td align="left">classe_p_mf1979</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_mf1979.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_mf1988</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_mf1988.</td>
</tr>
<tr class="even">
<td align="left">classe_p_mf2000</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_mf2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_mf2010</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_mf2010.</td>
</tr>
<tr class="even">
<td align="left">classe_p_prairie1970</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_prairie1970.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_prairie1979</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_prairie1979.</td>
</tr>
<tr class="even">
<td align="left">classe_p_prairie1988</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_prairie1988.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_prairie2000</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_prairie2000.</td>
</tr>
<tr class="even">
<td align="left">classe_p_prairie2010</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_prairie2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_sfp1970</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sfp1970.</td>
</tr>
<tr class="even">
<td align="left">classe_p_sfp1979</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sfp1979.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_sfp1988</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sfp1988.</td>
</tr>
<tr class="even">
<td align="left">classe_p_sfp2000</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sfp2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_sfp2010</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sfp2010.</td>
</tr>
<tr class="even">
<td align="left">classe_p_sth1970</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sth1970.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_sth1979</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sth1979.</td>
</tr>
<tr class="even">
<td align="left">classe_p_sth1988</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sth1988.</td>
</tr>
<tr class="odd">
<td align="left">classe_p_sth2000</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sth2000.</td>
</tr>
<tr class="even">
<td align="left">classe_p_sth2010</td>
<td align="left">Classes d'occupation du sol calculées avec la<br />
méthode pretty et établies sur la variable<br />
p_sth2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_c1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_c1970_2000.</td>
</tr>
<tr class="even">
<td align="left">classe_var_c1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_c1970_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_c1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_c1979_2000.</td>
</tr>
<tr class="even">
<td align="left">classe_var_c1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_c1979_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_c1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_c1988_2000.</td>
</tr>
<tr class="even">
<td align="left">classe_var_c1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_c1988_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_c2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_c2000_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_cop1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_cop1970_2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_cop1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_cop1970_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_cop1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_cop1979_2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_cop1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_cop1979_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_cop1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_cop1988_2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_cop1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_cop1988_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_cop2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_cop2000_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_mf1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_mf1970_2000.</td>
</tr>
<tr class="even">
<td align="left">classe_var_mf1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_mf1970_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_mf1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_mf1979_2000.</td>
</tr>
<tr class="even">
<td align="left">classe_var_mf1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_mf1979_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_mf1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_mf1988_2000.</td>
</tr>
<tr class="even">
<td align="left">classe_var_mf1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_mf1988_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_mf2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_mf2000_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_prairie1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_prairie1970_2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_prairie1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_prairie1970_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_prairie1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_prairie1979_2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_prairie1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_prairie1979_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_prairie1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_prairie1988_2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_prairie1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_prairie1988_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_prairie2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_prairie2000_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_sfp1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sfp1970_2000.</td>
</tr>
<tr class="even">
<td align="left">classe_var_sfp1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sfp1970_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_sfp1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sfp1979_2000.</td>
</tr>
<tr class="even">
<td align="left">classe_var_sfp1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sfp1979_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_sfp1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sfp1988_2000.</td>
</tr>
<tr class="even">
<td align="left">classe_var_sfp1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sfp1988_2010.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_sfp2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sfp2000_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_sth1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sth1970_2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_sth1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sth1970_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_sth1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sth1979_2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_sth1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sth1979_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_sth1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sth1988_2000.</td>
</tr>
<tr class="odd">
<td align="left">classe_var_sth1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sth1988_2010.</td>
</tr>
<tr class="even">
<td align="left">classe_var_sth2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la méthode quantile pour le champ<br />
var_sth2000_2010.</td>
</tr>
<tr class="odd">
<td align="left">clc21_00</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 00 : Terres arables</td>
</tr>
<tr class="even">
<td align="left">clc21_06</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 06 : Terres arables</td>
</tr>
<tr class="odd">
<td align="left">clc21_12</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 12 : Terres arables</td>
</tr>
<tr class="even">
<td align="left">clc21_90</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 90 : Terres arables</td>
</tr>
<tr class="odd">
<td align="left">clc22_00</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 00 : Cultures permanentes</td>
</tr>
<tr class="even">
<td align="left">clc22_06</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 06 : Cultures permanentes</td>
</tr>
<tr class="odd">
<td align="left">clc22_12</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 12 : Cultures permanentes</td>
</tr>
<tr class="even">
<td align="left">clc22_90</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 90 : Cultures permanentes</td>
</tr>
<tr class="odd">
<td align="left">clc23_00</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 00 : Prairies</td>
</tr>
<tr class="even">
<td align="left">clc23_06</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 06 : Prairies</td>
</tr>
<tr class="odd">
<td align="left">clc23_12</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 12 : Prairies</td>
</tr>
<tr class="even">
<td align="left">clc23_90</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 90 : Prairies</td>
</tr>
<tr class="odd">
<td align="left">clc24_00</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 00 : Zones agricoles hétérogènes</td>
</tr>
<tr class="even">
<td align="left">clc24_06</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 06 : Zones agricoles hétérogènes</td>
</tr>
<tr class="odd">
<td align="left">clc24_12</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 12 : Zones agricoles hétérogènes</td>
</tr>
<tr class="even">
<td align="left">clc24_90</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 90 : Zones agricoles hétérogènes</td>
</tr>
<tr class="odd">
<td align="left">clc31_00</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 00 : Forêts</td>
</tr>
<tr class="even">
<td align="left">clc31_06</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 06 : Forêts</td>
</tr>
<tr class="odd">
<td align="left">clc31_12</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 12 : Forêts</td>
</tr>
<tr class="even">
<td align="left">clc31_90</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 90 : Forêts</td>
</tr>
<tr class="odd">
<td align="left">clc32_00</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 00 : Milieux à végétation arbustive<br />
et/ou herbacée</td>
</tr>
<tr class="even">
<td align="left">clc32_06</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 06 : Milieux à végétation arbustive<br />
et/ou herbacée</td>
</tr>
<tr class="odd">
<td align="left">clc32_12</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 12 : Milieux à végétation arbustive<br />
et/ou herbacée</td>
</tr>
<tr class="even">
<td align="left">clc32_90</td>
<td align="left">Surface d'occupation du sol en hectare du libellé<br />
CLC version 90 : Milieux à végétation arbustive<br />
et/ou herbacée</td>
</tr>
<tr class="odd">
<td align="left">corg_medequiv0004</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période (toutes<br />
méthodes confondues)0004.</td>
</tr>
<tr class="even">
<td align="left">corg_medequiv0509</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période (toutes<br />
méthodes confondues)0509.</td>
</tr>
<tr class="odd">
<td align="left">corg_medequiv1014</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période (toutes<br />
méthodes confondues)1014.</td>
</tr>
<tr class="even">
<td align="left">corg_medequiv9094</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période (toutes<br />
méthodes confondues)9094.</td>
</tr>
<tr class="odd">
<td align="left">corg_medequiv9599</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période (toutes<br />
méthodes confondues)9599.</td>
</tr>
<tr class="even">
<td align="left">corgco0004</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période0004 et pour la<br />
méthode Oxydation sèche.</td>
</tr>
<tr class="odd">
<td align="left">corgco0509</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période0509 et pour la<br />
méthode Oxydation sèche.</td>
</tr>
<tr class="even">
<td align="left">corgco1014</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période1014 et pour la<br />
méthode Oxydation sèche.</td>
</tr>
<tr class="odd">
<td align="left">corgco9599</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période9599 et pour la<br />
méthode Oxydation sèche.</td>
</tr>
<tr class="even">
<td align="left">corgox0004</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période0004 et pour la<br />
méthode Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">corgox0509</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période0509 et pour la<br />
méthode Oxydation humide.</td>
</tr>
<tr class="even">
<td align="left">corgox1014</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période1014 et pour la<br />
méthode Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">corgox9094</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période9094 et pour la<br />
méthode Oxydation humide.</td>
</tr>
<tr class="even">
<td align="left">corgox9599</td>
<td align="left">Médiane des teneurs en carbone organique après<br />
ré-échantillonnage pour la période9599 et pour la<br />
méthode Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">diff12</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff13</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diff14</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff15</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diff23</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff24</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diff25</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff34</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diff35</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff45</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diff_corgco23</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation sèche</td>
</tr>
<tr class="even">
<td align="left">diff_corgco24</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation sèche</td>
</tr>
<tr class="odd">
<td align="left">diff_corgco34</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation sèche</td>
</tr>
<tr class="even">
<td align="left">diff_corgco35</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation sèche</td>
</tr>
<tr class="odd">
<td align="left">diff_corgco45</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation sèche</td>
</tr>
<tr class="even">
<td align="left">diff_corgox12</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="odd">
<td align="left">diff_corgox13</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="even">
<td align="left">diff_corgox14</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="odd">
<td align="left">diff_corgox15</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="even">
<td align="left">diff_corgox23</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="odd">
<td align="left">diff_corgox24</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="even">
<td align="left">diff_corgox25</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="odd">
<td align="left">diff_corgox34</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="even">
<td align="left">diff_corgox35</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="odd">
<td align="left">diff_corgox45</td>
<td align="left">Résultat du test de significacité de la<br />
différence de la médiane des teneurs en carbone<br />
organique au niveau du canton pour la méthode<br />
Oxydation humide</td>
</tr>
<tr class="even">
<td align="left">diff_var_c1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_c1970_2000.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_c1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_c1970_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_c1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_c1979_2000.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_c1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_c1979_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_c1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_c1988_2000.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_c1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_c1988_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_c2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_c2000_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_cop1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_cop1970_2000.</td>
</tr>
<tr class="even">
<td align="left">diff_var_cop1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_cop1970_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_cop1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_cop1979_2000.</td>
</tr>
<tr class="even">
<td align="left">diff_var_cop1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_cop1979_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_cop1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_cop1988_2000.</td>
</tr>
<tr class="even">
<td align="left">diff_var_cop1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_cop1988_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_cop2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_cop2000_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_mf1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_mf1970_2000.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_mf1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_mf1970_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_mf1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_mf1979_2000.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_mf1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_mf1979_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_mf1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_mf1988_2000.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_mf1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_mf1988_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_mf2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_mf2000_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_prairie1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_prairie1970_2000.</td>
</tr>
<tr class="even">
<td align="left">diff_var_prairie1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_prairie1970_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_prairie1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_prairie1979_2000.</td>
</tr>
<tr class="even">
<td align="left">diff_var_prairie1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_prairie1979_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_prairie1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_prairie1988_2000.</td>
</tr>
<tr class="even">
<td align="left">diff_var_prairie1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_prairie1988_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_prairie2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_prairie2000_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_sfp1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sfp1970_2000.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_sfp1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sfp1970_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_sfp1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sfp1979_2000.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_sfp1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sfp1979_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_sfp1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sfp1988_2000.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_sfp1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sfp1988_2010.</td>
</tr>
<tr class="even">
<td align="left">diff_var_sfp2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sfp2000_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_sth1970_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sth1970_2000.</td>
</tr>
<tr class="even">
<td align="left">diff_var_sth1970_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sth1970_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_sth1979_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sth1979_2000.</td>
</tr>
<tr class="even">
<td align="left">diff_var_sth1979_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sth1979_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_sth1988_2000</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sth1988_2000.</td>
</tr>
<tr class="even">
<td align="left">diff_var_sth1988_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sth1988_2010.</td>
</tr>
<tr class="odd">
<td align="left">diff_var_sth2000_2010</td>
<td align="left">Classes de changement d'occupation du sol basées<br />
sur la règle : sup à 10% : Augmentation; inf à<br />
-10% : Diminution; entre 10 et -10% : pas<br />
d'évolution. Pour le champvar_sth2000_2010.</td>
</tr>
<tr class="even">
<td align="left">diffmedian12</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian13</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian14</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian15</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian23</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian24</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian25</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian34</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian35</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian45</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs<br />
en carbone organique par canton<br />
((medA-medB)/medB))*100 avec B une période<br />
antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian_corgco23</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation sèche.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian_corgco24</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation sèche.</td>
</tr>
<tr class="even">
<td align="left">diffmedian_corgco34</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation sèche.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian_corgco35</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation sèche.</td>
</tr>
<tr class="even">
<td align="left">diffmedian_corgco45</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation sèche.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian_corgox12</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="even">
<td align="left">diffmedian_corgox13</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian_corgox14</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="even">
<td align="left">diffmedian_corgox15</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian_corgox23</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="even">
<td align="left">diffmedian_corgox24</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian_corgox25</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="even">
<td align="left">diffmedian_corgox34</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian_corgox35</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="even">
<td align="left">diffmedian_corgox45</td>
<td align="left">Différence entre la période A et la période B<br />
(g/kg) pour la méthode de mesure Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">eff_coox0004</td>
<td align="left">Nombre d'effectif par canton (toutes méthodes<br />
confondues)0004.</td>
</tr>
<tr class="even">
<td align="left">eff_coox0509</td>
<td align="left">Nombre d'effectif par canton (toutes méthodes<br />
confondues)0509.</td>
</tr>
<tr class="odd">
<td align="left">eff_coox1014</td>
<td align="left">Nombre d'effectif par canton (toutes méthodes<br />
confondues)1014.</td>
</tr>
<tr class="even">
<td align="left">eff_coox9094</td>
<td align="left">Nombre d'effectif par canton (toutes méthodes<br />
confondues)9094.</td>
</tr>
<tr class="odd">
<td align="left">eff_coox9599</td>
<td align="left">Nombre d'effectif par canton (toutes méthodes<br />
confondues)9599.</td>
</tr>
<tr class="even">
<td align="left">eff_corgco0004</td>
<td align="left">Nombre d'effectif par canton pour la période0004 et<br />
pour la méthode Oxydation sèche.</td>
</tr>
<tr class="odd">
<td align="left">eff_corgco0509</td>
<td align="left">Nombre d'effectif par canton pour la période0509 et<br />
pour la méthode Oxydation sèche.</td>
</tr>
<tr class="even">
<td align="left">eff_corgco1014</td>
<td align="left">Nombre d'effectif par canton pour la période1014 et<br />
pour la méthode Oxydation sèche.</td>
</tr>
<tr class="odd">
<td align="left">eff_corgco9599</td>
<td align="left">Nombre d'effectif par canton pour la période9599 et<br />
pour la méthode Oxydation sèche.</td>
</tr>
<tr class="even">
<td align="left">eff_corgox0004</td>
<td align="left">Nombre d'effectif par canton pour la période0004 et<br />
pour la méthode Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">eff_corgox0509</td>
<td align="left">Nombre d'effectif par canton pour la période0509 et<br />
pour la méthode Oxydation humide.</td>
</tr>
<tr class="even">
<td align="left">eff_corgox1014</td>
<td align="left">Nombre d'effectif par canton pour la période1014 et<br />
pour la méthode Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">eff_corgox9094</td>
<td align="left">Nombre d'effectif par canton pour la période9094 et<br />
pour la méthode Oxydation humide.</td>
</tr>
<tr class="even">
<td align="left">eff_corgox9599</td>
<td align="left">Nombre d'effectif par canton pour la période9599 et<br />
pour la méthode Oxydation humide.</td>
</tr>
<tr class="odd">
<td align="left">elevage1988</td>
<td align="left">Pourcentage de la somme des OTEX de type elevage<br />
(otex 45,46,47,48) pour 1988.</td>
</tr>
<tr class="even">
<td align="left">elevage2000</td>
<td align="left">Pourcentage de la somme des OTEX de type elevage<br />
(otex 45,46,47,48) pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">elevage2010</td>
<td align="left">Pourcentage de la somme des OTEX de type elevage<br />
(otex 45,46,47,48) pour 2010.</td>
</tr>
<tr class="even">
<td align="left">elevagehorsol1988</td>
<td align="left">Pourcentage exploitation ayant une orientation<br />
technico-economique de type elevage hors sol (otex<br />
51,52,53,74) en 1988.</td>
</tr>
<tr class="odd">
<td align="left">elevagehorsol2000</td>
<td align="left">Pourcentage exploitation ayant une orientation<br />
technico-economique de type elevage hors sol (otex<br />
51,52,53,74) en 2000.</td>
</tr>
<tr class="even">
<td align="left">elevagehorsol2010</td>
<td align="left">Pourcentage exploitation ayant une orientation<br />
technico-economique de type elevage hors sol (otex<br />
51,52,53,74) en 2010.</td>
</tr>
<tr class="odd">
<td align="left">grdcultures1988</td>
<td align="left">Pourcentage exploitation ayant une orientation<br />
technico-economique de type grandes cultures (otex<br />
15,16) en 1988.</td>
</tr>
<tr class="even">
<td align="left">grdcultures2000</td>
<td align="left">Pourcentage exploitation ayant une orientation<br />
technico-economique de type grandes cultures (otex<br />
15,16) en 2000.</td>
</tr>
<tr class="odd">
<td align="left">grdcultures2010</td>
<td align="left">Pourcentage exploitation ayant une orientation<br />
technico-economique de type grandes cultures (otex<br />
15,16) en 2010.</td>
</tr>
<tr class="even">
<td align="left">hpluie_an</td>
<td align="left">Cumul annuel (mm)</td>
</tr>
<tr class="odd">
<td align="left">jchauds_an</td>
<td align="left">Jours/an de maximum supérieur à + 30°C</td>
</tr>
<tr class="even">
<td align="left">jfroids_an</td>
<td align="left">Jours/an de minimum inférieur à -5°C</td>
</tr>
<tr class="odd">
<td align="left">jpluie_janv</td>
<td align="left">Jours de précipitation en janvier</td>
</tr>
<tr class="even">
<td align="left">jpluie_juil</td>
<td align="left">Jours de précipitation en juillet</td>
</tr>
<tr class="odd">
<td align="left">p_c1970</td>
<td align="left">Pourcentage de céréales par rapport à la SAU pour<br />
1970.</td>
</tr>
<tr class="even">
<td align="left">p_c1979</td>
<td align="left">Pourcentage de céréales par rapport à la SAU pour<br />
1979.</td>
</tr>
<tr class="odd">
<td align="left">p_c1988</td>
<td align="left">Pourcentage de céréales par rapport à la SAU pour<br />
1988.</td>
</tr>
<tr class="even">
<td align="left">p_c2000</td>
<td align="left">Pourcentage de céréales par rapport à la SAU pour<br />
2000.</td>
</tr>
<tr class="odd">
<td align="left">p_c2010</td>
<td align="left">Pourcentage de céréales par rapport à la SAU pour<br />
2010.</td>
</tr>
<tr class="even">
<td align="left">p_cop1970</td>
<td align="left">Pourcentage des prairies (sommes des prairies<br />
temporaires et des surfaces toujours en herbe) en<br />
fonction de la SAU pour 1970.</td>
</tr>
<tr class="odd">
<td align="left">p_cop1979</td>
<td align="left">Pourcentage de la COP (sommes des cultures en<br />
céréales, oléagineux et protéagineux) en<br />
fonction de la SAU pour 1979.</td>
</tr>
<tr class="even">
<td align="left">p_cop1988</td>
<td align="left">Pourcentage de la COP (sommes des cultures en<br />
céréales, oléagineux et protéagineux) en<br />
fonction de la SAU pour 1988.</td>
</tr>
<tr class="odd">
<td align="left">p_cop2000</td>
<td align="left">Pourcentage de la COP (sommes des cultures en<br />
céréales, oléagineux et protéagineux) en<br />
fonction de la SAU pour 2000.</td>
</tr>
<tr class="even">
<td align="left">p_cop2010</td>
<td align="left">Pourcentage de la COP (sommes des cultures en<br />
céréales, oléagineux et protéagineux) en<br />
fonction de la SAU pour 2010.</td>
</tr>
<tr class="odd">
<td align="left">p_mf1970</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport<br />
à la SAU pour 1970.</td>
</tr>
<tr class="even">
<td align="left">p_mf1979</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport<br />
à la SAU pour 1979.</td>
</tr>
<tr class="odd">
<td align="left">p_mf1988</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport<br />
à la SAU pour 1988.</td>
</tr>
<tr class="even">
<td align="left">p_mf2000</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport<br />
à la SAU pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">p_mf2010</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport<br />
à la SAU pour 2010.</td>
</tr>
<tr class="even">
<td align="left">p_olea1970</td>
<td align="left">Pourcentage de oléagineux par rapport à la SAU<br />
pour 1970.</td>
</tr>
<tr class="odd">
<td align="left">p_olea1979</td>
<td align="left">Pourcentage de oléagineux par rapport à la SAU<br />
pour 1979.</td>
</tr>
<tr class="even">
<td align="left">p_olea1988</td>
<td align="left">Pourcentage de oléagineux par rapport à la SAU<br />
pour 1988.</td>
</tr>
<tr class="odd">
<td align="left">p_olea2000</td>
<td align="left">Pourcentage de oléagineux par rapport à la SAU<br />
pour 2000.</td>
</tr>
<tr class="even">
<td align="left">p_olea2010</td>
<td align="left">Pourcentage de oléagineux par rapport à la SAU<br />
pour 2010.</td>
</tr>
<tr class="odd">
<td align="left">p_prairie1970</td>
<td align="left">Pourcentage des prairies (sommes des prairies<br />
temporaires et des surfaces toujours en herbe) en<br />
fonction de la SAU pour 1970.</td>
</tr>
<tr class="even">
<td align="left">p_prairie1979</td>
<td align="left">Pourcentage des prairies (sommes des prairies<br />
temporaires, artificielles et des surfaces toujours<br />
en herbe) en fonction de la SAU pour 1979.</td>
</tr>
<tr class="odd">
<td align="left">p_prairie1988</td>
<td align="left">Pourcentage des prairies (sommes des prairies<br />
temporaires, artificielles et des surfaces toujours<br />
en herbe) en fonction de la SAU pour 1988.</td>
</tr>
<tr class="even">
<td align="left">p_prairie2000</td>
<td align="left">Pourcentage des prairies (sommes des prairies<br />
temporaires, artificielles et des surfaces toujours<br />
en herbe) en fonction de la SAU pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">p_prairie2010</td>
<td align="left">Pourcentage des prairies (sommes des prairies<br />
temporaires, artificielles et des surfaces toujours<br />
en herbe) en fonction de la SAU pour 2010.</td>
</tr>
<tr class="even">
<td align="left">p_protea1979</td>
<td align="left">Pourcentage de protéagineux par rapport à la SAU<br />
pour 1979.</td>
</tr>
<tr class="odd">
<td align="left">p_protea1988</td>
<td align="left">Pourcentage de protéagineux par rapport à la SAU<br />
pour 1988.</td>
</tr>
<tr class="even">
<td align="left">p_protea2000</td>
<td align="left">Pourcentage de protéagineux par rapport à la SAU<br />
pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">p_protea2010</td>
<td align="left">Pourcentage de protéagineux par rapport à la SAU<br />
pour 2010.</td>
</tr>
<tr class="even">
<td align="left">p_sfp1970</td>
<td align="left">Pourcentage de surface fourragère principale par<br />
rapport à la SAU pour 1970.</td>
</tr>
<tr class="odd">
<td align="left">p_sfp1979</td>
<td align="left">Pourcentage de surface fourragère principale par<br />
rapport à la SAU pour 1979.</td>
</tr>
<tr class="even">
<td align="left">p_sfp1988</td>
<td align="left">Pourcentage de surface fourragère principale par<br />
rapport à la SAU pour 1988.</td>
</tr>
<tr class="odd">
<td align="left">p_sfp2000</td>
<td align="left">Pourcentage de surface fourragère principale par<br />
rapport à la SAU pour 2000.</td>
</tr>
<tr class="even">
<td align="left">p_sfp2010</td>
<td align="left">Pourcentage de surface fourragère principale par<br />
rapport à la SAU pour 2010.</td>
</tr>
<tr class="odd">
<td align="left">p_sth1970</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport<br />
à la SAU pour 1970.</td>
</tr>
<tr class="even">
<td align="left">p_sth1979</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport<br />
à la SAU pour 1979.</td>
</tr>
<tr class="odd">
<td align="left">p_sth1988</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport<br />
à la SAU pour 1988.</td>
</tr>
<tr class="even">
<td align="left">p_sth2000</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport<br />
à la SAU pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">p_sth2010</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport<br />
à la SAU pour 2010.</td>
</tr>
<tr class="even">
<td align="left">pluie_ecart_janv</td>
<td align="left">Ecart à la moyenne en janvier (mm)</td>
</tr>
<tr class="odd">
<td align="left">pluie_ecart_juil</td>
<td align="left">Ecart à la moyenne en juillet (mm)</td>
</tr>
<tr class="even">
<td align="left">polyelevage1988</td>
<td align="left">Pourcentage exploitation ayant une orientation<br />
technico-economique de type polyculture-elevage<br />
(otex 61,73,83,84,90) en 1988.</td>
</tr>
<tr class="odd">
<td align="left">polyelevage2000</td>
<td align="left">Pourcentage exploitation ayant une orientation<br />
technico-economique de type polyculture-elevage<br />
(otex 61,73,83,84,90) en 2000.</td>
</tr>
<tr class="even">
<td align="left">polyelevage2010</td>
<td align="left">Pourcentage exploitation ayant une orientation<br />
technico-economique de type polyculture-elevage<br />
(otex 61,73,83,84,90) en 2010.</td>
</tr>
<tr class="odd">
<td align="left">std_pluie_janv</td>
<td align="left">Variabilité 1971-2000 en janvier (mm)</td>
</tr>
<tr class="even">
<td align="left">std_pluie_juil</td>
<td align="left">Variabilité 1971-2000 en juillet (mm)</td>
</tr>
<tr class="odd">
<td align="left">std_temp_janv</td>
<td align="left">Variabilité 1971-2000 en janvier (°C)</td>
</tr>
<tr class="even">
<td align="left">std_temp_juil</td>
<td align="left">Variabilité 1971-2000 en juillet (°C)</td>
</tr>
<tr class="odd">
<td align="left">ttemp_an</td>
<td align="left">Température moyenne annuelle</td>
</tr>
<tr class="even">
<td align="left">typo_clim</td>
<td align="left">Type de climat</td>
</tr>
<tr class="odd">
<td align="left">ugbgrani_sau2000</td>
<td align="left">Pourcentage des UGB granivores en fonction de la<br />
surface agricole utile en 2000.</td>
</tr>
<tr class="even">
<td align="left">ugbgrani_sau2010</td>
<td align="left">Pourcentage des UGB granivores en fonction de la<br />
surface agricole utile en 2010.</td>
</tr>
<tr class="odd">
<td align="left">ugbh_sau2000</td>
<td align="left">Pourcentage des UGB herbivores en fonction de la<br />
surface agricole utile en 2000.</td>
</tr>
<tr class="even">
<td align="left">ugbh_sau2010</td>
<td align="left">Pourcentage des UGB herbivores en fonction de la<br />
surface agricole utile en 2010.</td>
</tr>
<tr class="odd">
<td align="left">ugbta1988</td>
<td align="left">Densité UGBTA/SAU pour 1988.</td>
</tr>
<tr class="even">
<td align="left">ugbta2000</td>
<td align="left">Densité UGBTA/SAU pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">ugbta2010</td>
<td align="left">Densité UGBTA/SAU pour 2010.</td>
</tr>
<tr class="even">
<td align="left">var_c1970_2000</td>
<td align="left">Evolution de la surface en céréales entre 2000 et<br />
1970 par rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_c1970_2010</td>
<td align="left">Evolution de la surface en céréales entre 2010 et<br />
1970 par rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_c1979_2000</td>
<td align="left">Evolution de la surface en céréales entre 2000 et<br />
1979 par rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_c1979_2010</td>
<td align="left">Evolution de la surface en céréales entre 2010 et<br />
1979 par rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_c1988_2000</td>
<td align="left">Evolution de la surface en céréales entre 2000 et<br />
1988 par rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_c1988_2010</td>
<td align="left">Evolution de la surface en céréales entre 2010 et<br />
1988 par rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_c2000_2010</td>
<td align="left">Evolution de la surface en céréales entre 2010 et<br />
2000 par rapport à la SAU de 2000<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_cop1970_2000</td>
<td align="left">Evolution des surfaces en cop entre 2000 et 1970 par<br />
rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_cop1970_2010</td>
<td align="left">Evolution des surfaces en cop entre 2010 et 1970 par<br />
rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_cop1979_2000</td>
<td align="left">Evolution des surfaces en cop entre 2000 et 1979 par<br />
rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_cop1979_2010</td>
<td align="left">Evolution des surfaces en cop entre 2010 et 1979 par<br />
rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_cop1988_2000</td>
<td align="left">Evolution des surfaces en cop entre 2000 et 1988 par<br />
rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_cop1988_2010</td>
<td align="left">Evolution des surfaces en cop entre 2010 et 1988 par<br />
rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_cop2000_2010</td>
<td align="left">Evolution des surfaces en cop entre 2010 et 2000 par<br />
rapport à la SAU de 2000<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_elevage1988_2010</td>
<td align="left">Evolution du pourcentage d'OTEX en élevage entre<br />
2010 et 1988.</td>
</tr>
<tr class="odd">
<td align="left">var_elevagehorsol1988_2010</td>
<td align="left">Evolution du pourcentage d'OTEX en élevage hors sol<br />
entre 2010 et 1988.</td>
</tr>
<tr class="even">
<td align="left">var_grdcultures1988_2010</td>
<td align="left">Evolution du pourcentage d'OTEX en grandes cultures<br />
entre 2010 et 1988.</td>
</tr>
<tr class="odd">
<td align="left">var_mf1970_2000</td>
<td align="left">Evolution de la surface en maîs fourrage ensilage<br />
entre 2000 et 1970 par rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_mf1970_2010</td>
<td align="left">Evolution de la surface en maîs fourrage ensilage<br />
entre 2010 et 1970 par rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_mf1979_2000</td>
<td align="left">Evolution de la surface en maîs fourrage ensilage<br />
entre 2000 et 1979 par rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_mf1979_2010</td>
<td align="left">Evolution de la surface en maîs fourrage ensilage<br />
entre 2010 et 1979 par rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_mf1988_2000</td>
<td align="left">Evolution de la surface en maîs fourrage ensilage<br />
entre 2000 et 1988 par rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_mf1988_2010</td>
<td align="left">Evolution de la surface en maîs fourrage ensilage<br />
entre 2010 et 1988 par rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_mf2000_2010</td>
<td align="left">Evolution de la surface en maîs fourrage ensilage<br />
entre 2010 et 2000 par rapport à la SAU de 2000<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_polyelevage1988_2010</td>
<td align="left">Evolution du pourcentage d'OTEX en polyélevage<br />
entre 2010 et 1988.</td>
</tr>
<tr class="odd">
<td align="left">var_prairie1970_2000</td>
<td align="left">Evolution des prairies entre 2000 et 1970 par<br />
rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_prairie1970_2010</td>
<td align="left">Evolution des prairies entre 2010 et 1970 par<br />
rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_prairie1979_2000</td>
<td align="left">Evolution des prairies entre 2000 et 1979 par<br />
rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_prairie1979_2010</td>
<td align="left">Evolution des prairies entre 2010 et 1979 par<br />
rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_prairie1988_2000</td>
<td align="left">Evolution des prairies entre 2000 et 1988 par<br />
rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_prairie1988_2010</td>
<td align="left">Evolution des prairies entre 2010 et 1988 par<br />
rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_prairie2000_2010</td>
<td align="left">Evolution des prairies entre 2010 et 2000 par<br />
rapport à la SAU de 2000<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_sfp1970_2000</td>
<td align="left">Evolution de la surface fourragère principale<br />
entre 2000 et 1970 par rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_sfp1970_2010</td>
<td align="left">Evolution de la surface fourragère principale<br />
entre 2010 et 1970 par rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_sfp1979_2000</td>
<td align="left">Evolution de la surface fourragère principale<br />
entre 2000 et 1979 par rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_sfp1979_2010</td>
<td align="left">Evolution de la surface fourragère principale<br />
entre 2010 et 1979 par rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_sfp1988_2000</td>
<td align="left">Evolution de la surface fourragère principale<br />
entre 2000 et 1988 par rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_sfp1988_2010</td>
<td align="left">Evolution de la surface fourragère principale<br />
entre 2010 et 1988 par rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_sfp2000_2010</td>
<td align="left">Evolution de la surface fourragère principale<br />
entre 2010 et 2000 par rapport à la SAU de 2000<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_sth1970_2000</td>
<td align="left">Evolution de la surface toujours en herbe entre 2000<br />
et 1970 par rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_sth1970_2010</td>
<td align="left">Evolution de la surface toujours en herbe entre 2010<br />
et 1970 par rapport à la SAU de 1970<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_sth1979_2000</td>
<td align="left">Evolution de la surface toujours en herbe entre 2000<br />
et 1979 par rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_sth1979_2010</td>
<td align="left">Evolution de la surface toujours en herbe entre 2010<br />
et 1979 par rapport à la SAU de 1979<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_sth1988_2000</td>
<td align="left">Evolution de la surface toujours en herbe entre 2000<br />
et 1988 par rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_sth1988_2010</td>
<td align="left">Evolution de la surface toujours en herbe entre 2010<br />
et 1988 par rapport à la SAU de 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">var_sth2000_2010</td>
<td align="left">Evolution de la surface toujours en herbe entre 2010<br />
et 2000 par rapport à la SAU de 2000<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="even">
<td align="left">var_ugb1988_2010</td>
<td align="left">Evolution des UGB tous aliment entre 2010 et 1988<br />
(occupA/SAUA)-(occupB/SAUB).</td>
</tr>
<tr class="odd">
<td align="left">zonage_cplt</td>
<td align="left">zonage_cplt des principales régions d élevage par<br />
canton. La valeur est issue des données communales<br />
(public.regelevage) et représente la valeur<br />
majoritaire par canton. La table public.regelevage<br />
présente la signification des codes utilisés pour<br />
le zonage. Source DG AGRI RICA UE 2012 - traitement<br />
IDELE</td>
</tr>
<tr class="even">
<td align="left">zonage_simple</td>
<td align="left">zonage_simple des principales régions d élevage<br />
par canton. La valeur est issue des données<br />
communales (public.regelevage) et représente la<br />
valeur majoritaire par canton. La table<br />
public.regelevage présente la signification des<br />
codes utilisés pour le zonage. Source DG AGRI RICA<br />
UE 2012 - traitement IDELE</td>
</tr>
</tbody>
</table>

Les tables au format long (dm\_traitements.melted et autres)
------------------------------------------------------------

Ces tables sont au format long et servent aux différents traitements statistiques et aux scripts de création de cartes.

-   `dm_traitements.melted.bdat` : table de la médiane des teneurs en carbone organique et des effectifs pour différentes paramètres au format long.

De la même façon que `dm_vecteurs.canton`, la création de la table `dm_traitements.melted.bdat` est déclinée également pour les filtres `dm_vecteurs.canton_9514` et `dm_vecteurs.canton_9014`. Les tables portent des noms similaires :

-   **dm\_traitements.melted.bdat\_9014 :** table de la médiane des teneurs en carbone organique et des effectifs pour différentes paramètres au format long. Cette table est construite avec `dm_vecteurs.canton_9014`.
-   **dm\_traitements.melted.bdat\_9514 :** table de la médiane des teneurs en carbone organique et des effectifs pour différentes paramètres au format long. Cette table est construite avec `dm_vecteurs.canton_9514`.

<table>
<caption>Description des champs de la table dm_traitements.melted_bdat</caption>
<colgroup>
<col width="13%" />
<col width="86%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Colonne</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">annees</td>
<td align="left">Périodes d'analyse des teneurs en carbone organique.</td>
</tr>
<tr class="even">
<td align="left">value</td>
<td align="left">Médiane des teneurs en carbone organique et les effectifs après<br />
ré-échantillonnage sur l'ensemble des périodes et les<br />
différentes méthodes de mesure.</td>
</tr>
<tr class="odd">
<td align="left">variable</td>
<td align="left">Type de méthode de mesure des teneurs en carbone organique et les<br />
effectifs (corgox:oxydation humide; corgco:combustion sèche;<br />
corg_medequiv:corgox+corgco; eff_corgox:effectif pour la méthode<br />
corgox; eff_corgco:effectif pour la méthode corgco;<br />
eff_coox:effectif pour les méthodes méthodes corgox+corgco.</td>
</tr>
</tbody>
</table>

    ## Warning in pandoc.table.return(...): Split.tables is an infinite value, so
    ## split cells can't be suplied as relative value. Reverting to default

<table>
<caption>Description des régions d'élevage</caption>
<colgroup>
<col width="16%" />
<col width="14%" />
<col width="34%" />
<col width="34%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Code simple</th>
<th align="left">Code cplt</th>
<th align="left">Description simple</th>
<th align="left">Description cplt</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">A</td>
<td align="left">A</td>
<td align="left">Zones de grandes cultures ou<br />
sans élevage</td>
<td align="left">Zones de grandes cultures ou<br />
sans élevage</td>
</tr>
<tr class="even">
<td align="left">B</td>
<td align="left">B2</td>
<td align="left">Cultures + Elevages</td>
<td align="left">Zone de polyculture-élevage<br />
du Bassin Aquitain,<br />
Rhône-Alpes, Alsace<br />
(régression plus rapide de<br />
l'élevage)</td>
</tr>
<tr class="odd">
<td align="left">B</td>
<td align="left">B1</td>
<td align="left">Cultures + Elevages</td>
<td align="left">Zone de polyculture-élevage<br />
du Bassin Parisien</td>
</tr>
<tr class="even">
<td align="left">C</td>
<td align="left">C1</td>
<td align="left">Cultures fourragères</td>
<td align="left">Zone intensive du Grand Ouest<br />
(zone laitière avec<br />
alternatives à l’élevage)</td>
</tr>
<tr class="odd">
<td align="left">C</td>
<td align="left">C2</td>
<td align="left">Cultures fourragères</td>
<td align="left">Piémonts intensifs (zone à<br />
dominante viande avec peu<br />
d’alternatives)</td>
</tr>
<tr class="even">
<td align="left">D</td>
<td align="left">D</td>
<td align="left">Zone herbagère du Nord-Ouest</td>
<td align="left">Zone herbagère du Nord-Ouest</td>
</tr>
<tr class="odd">
<td align="left">E</td>
<td align="left">E1</td>
<td align="left">Zone herbagère du Centre et<br />
de l’Est</td>
<td align="left">Zone herbagère du Nord-Est<br />
(de tradition laitière)</td>
</tr>
<tr class="even">
<td align="left">E</td>
<td align="left">E2</td>
<td align="left">Zone herbagère du Centre et<br />
de l’Est</td>
<td align="left">Zone herbagère du Nord<br />
Massif-Central (de tradition<br />
allaitante)</td>
</tr>
<tr class="odd">
<td align="left">F</td>
<td align="left">F1</td>
<td align="left">Zones pastorales</td>
<td align="left">Causses et coteaux du<br />
Sud-Ouest</td>
</tr>
<tr class="even">
<td align="left">F</td>
<td align="left">F2</td>
<td align="left">Zones pastorales</td>
<td align="left">Zone pastorale<br />
méditerranéenne</td>
</tr>
<tr class="odd">
<td align="left">G</td>
<td align="left">G1</td>
<td align="left">Montagne humides</td>
<td align="left">Franche-comté + Vosges (forte<br />
spécialisation laitière)</td>
</tr>
<tr class="even">
<td align="left">G</td>
<td align="left">G2</td>
<td align="left">Montagne humides</td>
<td align="left">Auvergne (et Massif-Central)<br />
(mixité lait-viande)</td>
</tr>
<tr class="odd">
<td align="left">H</td>
<td align="left">H</td>
<td align="left">Haute-Montagne</td>
<td align="left">Haute-Montagne</td>
</tr>
</tbody>
</table>

<table style="width:71%;">
<caption>Description des types de climats</caption>
<colgroup>
<col width="9%" />
<col width="61%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Code</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">1</td>
<td align="left">Climats de montagne</td>
</tr>
<tr class="even">
<td align="left">2</td>
<td align="left">Climat semi-continental et climat des marges<br />
montagnard</td>
</tr>
<tr class="odd">
<td align="left">3</td>
<td align="left">Climat océanique dégradé des plaines du<br />
Centre et du Nord</td>
</tr>
<tr class="even">
<td align="left">4</td>
<td align="left">Climat océanique altéré</td>
</tr>
<tr class="odd">
<td align="left">5</td>
<td align="left">Climat océanique franc</td>
</tr>
<tr class="even">
<td align="left">6</td>
<td align="left">Climat méditerrannéen altéré</td>
</tr>
<tr class="odd">
<td align="left">7</td>
<td align="left">Climat du Bassin du Sud-Ouest</td>
</tr>
<tr class="even">
<td align="left">8</td>
<td align="left">Climat méditerranéen franc</td>
</tr>
</tbody>
</table>

La création des tables au format long a été également réalisée pour les données liées aux évolutions des teneurs en carbone organique. Une seule table a été générée : `dm_traitements.melted_bdatdiff`.
Le tableau ci-dessous décrit les champs de cette table.

<table>
<caption>Description des champs de la table dm_traitements.melted_bdatdiff</caption>
<colgroup>
<col width="24%" />
<col width="76%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Colonne</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">diff</td>
<td align="left">Résultat du test statistique de différence des teneurs en<br />
carbone organique entre deux périodes (test de Wilcoxon).<br />
Méthode de mesure oxydation humide (corgox).</td>
</tr>
<tr class="even">
<td align="left">diff_corgox</td>
<td align="left">Résultat du test statistique de différence des teneurs en<br />
carbone organique entre deux périodes (test de Wilcoxon).<br />
Méthode de mesure oxydation humide (corgox).</td>
</tr>
<tr class="odd">
<td align="left">diffmedian</td>
<td align="left">Différences des teneurs en carbone organique entre deux<br />
périodes. Toutes méthodes de mesure confondues<br />
(corgox+corgco).</td>
</tr>
<tr class="even">
<td align="left">diffmedian_corgox</td>
<td align="left">Différences des teneurs en carbone organique entre deux<br />
périodes. Méthode de mesure oxydation humide (corgox).</td>
</tr>
<tr class="odd">
<td align="left">period</td>
<td align="left">Périodes comparées des teneurs en carbone organique.</td>
</tr>
</tbody>
</table>
