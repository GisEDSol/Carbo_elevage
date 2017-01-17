Préparation des données Corine Land Cover
================
Jean-Baptiste Paroissien

-   [Objectifs](#objectifs)
-   [Calcul de différentes statistiques et jointures vers la table `dm_vecteurs.canton`](#calcul-de-differentes-statistiques-et-jointures-vers-la-table-dm_vecteurs.canton)
    -   [Aggrégation par la moyenne à l'échelle du canton](#aggregation-par-la-moyenne-a-lechelle-du-canton)
    -   [Ajout des valeurs de changement](#ajout-des-valeurs-de-changement)

Objectifs
=========

Dans ce document, les tables brutes de Corine Land Cover importées dans le schéma `clc` (voir [fichier](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/BDD/Suivis/FS_bdd_brute.Rmd)) sont aggrégées à l'échelle du canton pour faciliter les traitements statistiques et la cartographie.

**En sortie** de ce script, plusieurs champs (statistiques élaborés du RA) sont ajoutés dans la table `dm_vecteurs.canton` et la table `dm_traitements.melted_RA` est créée. Le traitement et l'analyse des champs créés dans les commandes qui suivent sont consultables dans le fichier [FS\_traitements\_ra.Rmd](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_ra.Rmd).
Pour une description des champs créés, consultez les métadonnées de la table `dm_vecteurs.canton` (voir à la fin du document).

Calcul de différentes statistiques et jointures vers la table `dm_vecteurs.canton`
==================================================================================

Aggrégation par la moyenne à l'échelle du canton
------------------------------------------------

``` r
# Lecture des métadonnées

meta_clc <- read.csv(paste(repmetadonnees,"Nomenclature_clc.csv",sep=""),sep=";",header=TRUE)
variables <- c("21","22","23","24","31","32") # Nom des champs à type d'occupation du sol à importer
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)
versionclc <- c("90","00","06","12") # Nom des années clc pris en compte

## Calcul de la moyenne des surfaces d'occupation sur sol par canton

for(i in versionclc){
  cpt <- 0
  if(i=="00" | i=="06"){
    # Nom de la table à importer
    tableclc <- paste("clc.clc",i,"_revisee",sep="")
    print(tableclc)
  }else{
    # Nom de la table à importer
    tableclc <- paste("clc.clc",i,sep="")
    print(tableclc)
  }

  for(o in variables){
    cpt <- cpt + 1
    
    vName <- paste("clc",o,"_",i,sep="") # Nom du champs final dans table_dm
    vtableclc <- paste("x",o,sep="") #Nom du champs à joindre
    comment <- as.character(meta_clc[meta_clc$code_clc_niveau_2==o,"libelle"])
    
    # Suppression de la colonne si déjà existante
    sqlQuery(loc,paste("alter table ",table_dm,"
                        drop column if exists ",vName,sep=""))
    
    #Création de la colonne, aggrégation par canton et jointure vers la table canton 
    print(sqlQuery(loc,paste("alter table ",table_dm,"
                      add column ",vName," numeric;
                      update ",table_dm,"
                      SET ",vName," = s1.",vtableclc," from(
                      select AVG(",vtableclc,") as ",vtableclc,", (code_dept || code_cant) as num_canton
                      from ",tableclc," as clc
                      inner join dm_vecteurs.commune as c on c.insee_com=clc.num_com
                      group by code_dept || code_cant) as s1
                      where ",table_dm,".code_canton=s1.num_canton::text",sep="")))
    
    #Ajout d'un commentaire sur la nouvelle colonne créée
    print(sqlQuery(loc,paste("
            COMMENT ON COLUMN ",table_dm,".",vName," IS \'Surface d\''occupation du sol en hectare du libellé CLC version ",i," : ",comment,"\';",sep="")))
  }
}
```

Ajout des valeurs de changement
-------------------------------

Voir pour l'ajout des changemente calculés sur les données de corine land cover
Pour la représentation cartographique et l'analyse, on pourra calculer la somme des surfaces initiales en prairie "retournée" par canton.
voir <https://halshs.archives-ouvertes.fr/tel-00636846v2/file/soutenance_ppt_sparfel.pdf> pour le développement d'indicateur de changement d'occupation du sol

``` r
meta_clc <- read.csv(paste(repmetadonnees,"Nomenclature_clc.csv",sep=""),sep=";",header=TRUE)
variables <- c("21","22","23","24") # Nom des champs à type d'occupation du sol à importer
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)
versionclc <- c("90","00","06","12") # Nom des années clc pris en compte

## Calcul de la moyenne des surfaces d'occupation sur sol par canton

cpt0 <- 0
for(i in 1:3){
  cpt0 <- cpt0 + 1

  period_chgt <- c("90","00","06","12")
  period1 <- period_chgt[cpt0]
  period2 <- period_chgt[cpt0+1]
  tableclc <- paste("clc.changements",period1,"_",period2,sep="")
  print(tableclc)
  
  for(v in variables){
    
    vName <- paste("clc",v,"_",period1,"_",period2,sep="")
    
    # Suppression de la colonne si déjà existante
    sqlQuery(loc,paste("alter table ",table_dm,"
                        drop column if exists ",vName,sep=""))
    
    # Création de la colonne, aggrégation par canton et jointure vers la table canton 
    sqlQuery(loc,paste("alter table ",table_dm,"
                      add column ",vName," numeric;
                      update ",table_dm,"
                      SET ",vName," = s1.",vName," from(
                      select SUM(area_ha) as ",vName,",(code_dept || code_cant) as num_canton
                      from ",tableclc," as clc
                      inner join dm_vecteurs.commune as c on c.insee_com=clc.num_com
                      where code_",period1," = ",v,"
                      group by code_dept || code_cant) as s1
                      where ",table_dm,".code_canton=s1.num_canton::text",sep=""))

   # Ajout d'un commentaire sur la nouvelle colonne créée
    print(sqlQuery(loc,paste("
            COMMENT ON COLUMN ",table_dm,".",vName," IS \'Perte en ha de l\''occupation du sol ",v," entre l\''année ",period1," et l\''année ",period2,"\';",sep="")))
  }
}
```
