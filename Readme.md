# Le projet "Carbo_elevage"

> Ce projet regroupe l'ensemble des scripts développés pour la création d'une base de données sur les sols et l'élevage et les différents traitements statistiques associés. Il est organisé selon l'arborescence suivante :

* **[Fichiers_suivis](https://github.com/GisEDSol/Carbo_elevage/tree/master/Fichiers_suivis)** Répertoire de stockage des fichiers de suivis associés à la création de la base de données et aux traitements statistiques des données. Ce répertoire est constitué des sous-répertoires suivants :
      * [BDD](https://github.com/GisEDSol/Carbo_elevage/tree/master/Fichiers_suivis/BDD) Répertoire de stockage des fichiers de suivis liés à la création de la base de données. Le répertoire est constitué du [script](https://github.com/GisEDSol/Carbo_elevage/tree/master/Fichiers_suivis/BDD/FS_bdd_brute.Rmd) de création de la bdd brute et de plusieurs fichiers décrivant la création de données élaborées, directement exploitables pour les traitements, les analyses et la cartographie.
      * [Traitements](https://github.com/GisEDSol/Carbo_elevage/tree/master/Fichiers_suivis/Traitements) Répertoire regroupant l'ensemble des traitements de données des analyses de sol et des facteurs explicatifs potentiels.
      * [Shiny](https://github.com/GisEDSol/Carbo_elevage/tree/master/Fichiers_suivis/Shiny) Répertoire test pour la création d'une application Shiny. Ce travail sera réalisé dans un second temps.

* **[Fonctions](https://github.com/GisEDSol/Carbo_elevage/tree/master/Fonctions)** Regroupe des fonctions communes, utilisées dans plusieurs traitements. 

* **[Documentation](https://github.com/GisEDSol/Carbo_elevage/tree/master/Documentation)** Regroupe l'ensemble de la documentation associée au projet (description du workflow général, de la base de données et des principaux traitements). Ce répertoire est constitué de métadonnées présentant :
	* une description des schéma de la base de données,
	* une description des tables et des champs présents dans les tables,
	* une présentation de la nomenclature de certaines variables.
Il est également composé de plusieurs modes opératoires, dont notamment :

* un [mode opératoire](https://rawgit.com/GisEDSol/Carbo_elevage/master/Documentation/Modes_operatoires/MO_priseenmain.html) pour prendre en main le projet (importation du projet, importation de la base de données et paramètres de connexion),
* un [mode opératoire](https://rawgit.com/GisEDSol/Carbo_elevage/master/Documentation/Modes_operatoires/MO_bdd.html) sur la base de données (organisation des données et métadonnées),
* un mode opératoire pour la rédaction des fichiers de suivis et des fonctions R,
* un mode opératoire présentant les logiciels utilisés et la configuration nécessaire pour reprendre le projet.


----

### Document de travail en cours

Pour une lecture aisée des traitements et résultats en cours sur l'analyse des teneurs en carbone organique, le lecteur intéressé peut consulter :

* **[l'analyse de l'évolution de l'occupation du sol et des OTEX](https://rawgit.com/GisEDSol/Carbo_elevage/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_ra.html)**
* **[l'analyse des teneurs en carbone organique pour différentes périodes](https://rawgit.com/GisEDSol/Carbo_elevage/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_bdat.html)**
* **[l'analyse de l'évolution des teneurs en carbone organique](https://rawgit.com/GisEDSol/Carbo_elevage/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_bdatdiff.html)**

Pour aller plus loin, plusieurs documents détaillent l'analyse à l'échelle régionale :
* **[Nord Pas de Calais et la Picardie](https://rawgit.com/GisEDSol/Carbo_elevage/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_NPCPicardie.html)**
* **[Bretagne](https://rawgit.com/GisEDSol/Carbo_elevage/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_Bretagne.html)**
* **[Région Centre](https://rawgit.com/GisEDSol/Carbo_elevage/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_Centre.html)**

----