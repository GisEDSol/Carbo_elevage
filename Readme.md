# Le sol et l'élevage

> Ce projet regroupe l'ensemble des scripts développés pour la création d'une base de données sur les sols et l'élevage et les différents traitements statistiques associés. Il est organisé selon l'arborescence suivante :

* **[Fichiers_suivis](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis)** Répertoire de stockage des fichiers de suivis associés à la création de la base de données et aux traitements statistiques des données. Ce répertoire est constitué des sous-répertoires suivants :
      * [BDD](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/BDD) Répertoire de stockage des fichiers de suivis liés à la création de la base de données. Le répertoire est constitué du [script](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/BDD/FS_bdd_brute.Rmd) de création de la bdd brute et de plusieurs fichiers décrivant la création de données élaborées, directement exploitables pour les traitements, les analyses et la cartographie.
      * [Traitements](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/Traitements) Répertoire regroupant l'ensemble des traitements de données associés aux données climatiques, d'occupation du sol (notamment agreste) et des données sols. 
      * [Shiny](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/Shiny) Répertoire test pour la création d'une application Shiny. Ce travail sera réalisé dans un second temps,

* **[Fonctions](https://github.com/Rosalien/GISEDSol/tree/master/Fonctions)** Regroupe des fonctions communes, utilisées dans plusieurs traitements.
* **[Documentation](https://github.com/Rosalien/GISEDSol/tree/master/Documentation)** Regroupe l'ensemble de la documentation associée au projet (description du workflow général, de la base de données et des principaux traitements). Ce répertoire est constitué de métadonnées présentant :
	* une description des schéma de la base de données,
	* une description des tables et des champs présents dans les tables,
	* une présentation de la nomenclature de certaines variables.
Il est également composé de plusieurs modes opératoires pour prendre en le projet, avec notamment :
	* un mode opératoire décrivant l'arborescence du projet et de son dépôt sur GitHub,
	* un mode opératoire sur la base de données (présentation et connexion avec R et QGIS),
	* un mode opératoire pour la rédaction des fichiers de suivis et des fonctions R,
	* un mode opératoire présentant les logiciels utilisés et la configuration nécessaire pour reprendre le projet.

----

### Document de travail en cours

Pour une lecture aisée des traitements et résultats en cours sur l'analyse des teneurs en carbone organique, le lecteur intéressé peut consulter cette [page](https://github.com/Rosalien/GISEDSol/blob/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_bdat.md) et cette [page](https://github.com/Rosalien/GISEDSol/blob/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_bdatdiff.md) qui traite de l'évolution des teneurs en carbone. 

----