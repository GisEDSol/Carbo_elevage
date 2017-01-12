Préparation des données du Recencement Agricole
================
Jean-Baptiste Paroissien

Objectifs
=========

L'objectif de ce fichier est de réaliser l'ensemble des traitements associés à la préparation des données du recencement agricole (RA). La préparation des données du RA comprend essentiellement le développement de tables directement exploitables pour de la cartographie ou des analyses statistiques, à savoir :

-   le calcul de statistiques simples et des jointures vers une table postGIS,
-   la préparation d'une table au format large pour différents graphiques réalisés avec les fonctions du paquet `ggplot2`.

*En sortie* de ce script, plusieurs champs (statistiques élaborés du RA) sont ajoutés dans la table `dm_vecteurs.canton` et la table `dm_traitements.melted_RA` est créée. Le traitement et l'analyse des champs créés dans les commandes qui suivent sont consultables dans le fichier [FS\_traitements\_ra.Rmd](https://github.com/Rosalien/GISEDSol/tree/master/Fichiers_suivis/Traitements/Suivis/FS_traitements_ra.Rmd). Pour une description des champs créés, consultez les métadonnées de la table `dm_vecteurs.canton` (voir à la fin du document).

Calcul de différentes statistiques et jointures vers la table `dm_vecteurs.canton`
==================================================================================

Calcul de la proportion d'occupation du sol par SAU
---------------------------------------------------

Le code suivant détermine la proportion de la surface d'occupation du sol par rapport à la surface agricole utile pour les différentes périodes de temps étudiées (1970,1979,1988,2000,2010). Les occupations du sol pris en compte sont les suivantes :

-   Superficie Toujours en Herbe (STH),
-   Surface Fourragère Princiaple (SFP),
-   Maïs Fourrage Ensilage (MFE),
-   Céréales.

A chaque itération, un commentaire est ajouté dans la base de données pour décrire le champs nouvellement créé. Ces commentaires sont accessibles dans la vue suivante :

``` r
#Paramètres
period <- c("1970","1979","1988","2000","2010") #périodes de temps analysées 
dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'" #paramètre de la base de données (en local)
SAU <- "superficieagricoleutilisée1"#Nom du champs de la SAU
variable <- cbind("superficietoujoursenherbesth","fourragesetsuperficiestoujoursenherbe","maïsfourrageetensilage","céréales") #Nom du champs des tables brutes extaites de disar
p_variable <- cbind("p_sth","p_sfp","p_mf","p_c") #Nom du champs nouvellement calculé (pourcentage de XX dans la SAU)
signification <- cbind("surface toujours en herbe","surface fourragère principale","maîs fourrage ensilage","céréales") #variable descriptive pour la construction de la métadonnée
type_RA <- "S_cultures_canton"
schema <- "ra"
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)

# Calcul de la proportion de suraface dans la SAU pour chaque période et type d'occupation du sol
cpt <- 0
for(v in variable){
  cpt <- cpt + 1
  variableRA <- v
  print(variableRA)
  sign_varia <- signification[cpt]
  
  for(i in period){

    p_variableRA <- paste(p_variable[cpt],i,sep="")
    print(p_variableRA)
    tableRA <- paste(type_RA,i,sep="")
    
    # Suppression de la colonne si déjà existante
    sqlQuery(loc,paste("alter table ",table_dm,"
                        drop column if exists ",p_variableRA,sep=""))
  
    # Création de la colonne et calcul du ratio occup/SAU
    sqlQuery(loc,paste("alter table ",table_dm,"
                        add column ",p_variableRA," numeric;
                        update ",table_dm,"
                        SET ",p_variableRA," = s1.",p_variableRA," from(
                        select (",variableRA,"/",SAU,")*100 as ",p_variableRA,",num_canton
                        from ",schema,".",tableRA,") as s1
                        where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
    
      # Ajout d'un commentaire sur la nouvelle colonne créée
        print(sqlQuery(loc,paste("
        COMMENT ON COLUMN ",table_dm,".",p_variableRA," IS \'Pourcentage de ",sign_varia," par rapport à la SAU pour ",i,".\';",sep="")))
  }
}
```

Calcul de la surface des prairies et de la part d'occupation dans la SAU
------------------------------------------------------------------------

Le type d'occupation nommé `prairie` correspond à la somme des surfaces toujours en herbe et de la surface des prairies temporaires et artificielles. Le code ci-dessous calcul la proportion de prairie pour les 5 périodes du recencement agricole.

``` r
# Calcul de statistiques pour les prairies (prairies artificielles, prairies temporaires)

p_variable <- "p_prairie"
type_RA <- "S_cultures_canton"
SAU <- "superficieagricoleutilisée1"
period <- c("1970","1979","1988","2000","2010")
schema <- "ra"
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)

for(i in period){
    
    p_variableRA <- paste(p_variable,i,sep="")
    print(p_variableRA)
    tableRA <- paste(type_RA,i,sep="")
    sqlQuery(loc,paste("alter table ",table_dm,"
                        drop column if exists ",p_variableRA,sep=""))
  
    if(i=="1970"){
      sqlQuery(loc,paste("alter table ",table_dm,"
                        add column ",p_variableRA," numeric;
                        update ",table_dm,"
                        SET ",p_variableRA," = s1.",p_variableRA," from(
                        select ((COALESCE(prairiestemporaires,0) + COALESCE(superficietoujoursenherbesth,0))/",SAU,")*100 as ",p_variableRA,",num_canton
                        from ",schema,".",tableRA,") as s1
                        where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
      
      print(sqlQuery(loc,paste("
          COMMENT ON COLUMN ",table_dm,".",p_variableRA," IS \'Pourcentage des prairies (sommes des prairies temporaires et des surfaces toujours en herbe) en fonction de la SAU pour ",i,".\';",sep="")))
      
    }else{
    sqlQuery(loc,paste("alter table ",table_dm,"
                        add column ",p_variableRA," numeric;
                        update ",table_dm,"
                        SET ",p_variableRA," = s1.",p_variableRA," from(
                        select ((COALESCE(prairiesartificielles,0) + COALESCE(prairiestemporaires,0) + COALESCE(superficietoujoursenherbesth,0))/",SAU,")*100 as ",p_variableRA,",num_canton
                        from ",schema,".",tableRA,"
                        where ",SAU," > 0) as s1
                        where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
      
      print(sqlQuery(loc,paste("
        COMMENT ON COLUMN ",table_dm,".",p_variableRA," IS \'Pourcentage des prairies (sommes des prairies temporaires, artificielles et des surfaces toujours en herbe) en fonction de la SAU pour ",i,".\';",sep="")))
    }
}
```

Orientation technico-économiques des exploitation
-------------------------------------------------

``` r
# Calcul de statistiques pour les OTEX
variable <- cbind("polyculturepolyélevageautresotex6173838490","grandesculturesotex1516","elevageshorssolotex51525374")
p_variable <- cbind("polyelevage","grdcultures","elevagehorsol")
type_RA <- "otex_canton"
period <- c("1988","2000","2010")
signification <- cbind("polyculture-elevage (otex 61,73,83,84,90)","grandes cultures (otex 15,16)","elevage hors sol (otex 51,52,53,74)")
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)

# Calcul du pourcentage des otex des exploitations pour l'ensemble des exploitations d'un canton
cpt <- 0
for(v in variable){
  cpt <- cpt + 1
  variableRA <- paste(variable[cpt],sep="")
  print(variableRA)
  sign_varia <- signification[cpt]

  for(i in period){
    
    p_variableRA <- paste(p_variable[cpt],i,sep="")
    print(p_variableRA)
    tableRA <- paste(type_RA,i,sep="")
    sqlQuery(loc,paste("alter table ",table_dm,"
                        drop column if exists ",p_variableRA,sep=""))
  
    sqlQuery(loc,paste("alter table ",table_dm,"
                        add column ",p_variableRA," numeric;
                        update ",table_dm,"
                        SET ",p_variableRA," = s1.",p_variableRA," from(
                        select (",variableRA,"/ensemble)*100 as ",p_variableRA,",num_canton
                        from ",schema,".",tableRA,") as s1
                        where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
    
    print(sqlQuery(loc,paste("
        COMMENT ON COLUMN ",table_dm,".",p_variableRA," IS \'Pourcentage exploitation ayant une orientation technico-economique de type ",sign_varia," en ",i,".\';",sep="")))
    
    }
}

# Calcul de l'ensemble du pourcentage d'OTEX elevage pour l'ensemble des exploitations d'un canton
p_variable <- "elevage"
type_RA <- "otex_canton"

cpt <- 0
for(i in period){
    
    p_variableRA <- paste(p_variable,i,sep="")
    print(p_variableRA)
    tableRA <- paste(type_RA,i,sep="")
    sqlQuery(loc,paste("alter table ",table_dm,"
                        drop column if exists ",p_variableRA,sep=""))
  
    sqlQuery(loc,paste("alter table ",table_dm,"
                        add column ",p_variableRA," numeric;
                        update ",table_dm,"
                        SET ",p_variableRA," = s1.",p_variableRA," from(
                        select ((COALESCE(bovinslaitotex45,0) + COALESCE(bovinsviandeotex46,0) + COALESCE(ovinscaprinsetautresherbivoresotex48,0) + COALESCE(bovinsmixteotex47,0))/ensemble)*100 as ",p_variableRA,",num_canton
                        from ",schema,".",tableRA,") as s1
                        where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
    
    print(sqlQuery(loc,paste("
        COMMENT ON COLUMN ",table_dm,".",p_variableRA," IS \'Pourcentage de la somme des OTEX de type elevage (otex 45,46,47,48) pour ",i,".\';",sep="")))
}
```

Données associées aux UGB
-------------------------

Les données des UGB proviennent de la table accessible à cette [adresse](http://agreste.agriculture.gouv.fr/IMG/xls/Donnees_principales__canton_departement_.xls). A noter qu'il sagit uniquement des UGB tous aliments et que les données sont uniquement accessibles pour 1988, 2000 et 2010. Cette section présente le calcul de la densité d'UGB tous aliments (UGBTA/SAU) pour les 3 périodes de temps disponibles.

``` r
# Paramètres
SAU <- "sau"
UGB  <- "ugbta"
tableRA <- "ugbta_canton880010"
periodUGB <- c("1988","2000","2010")
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)

# Calcul chargement
for(i in periodUGB){
    
    UGBperiod <- paste(UGB,i,sep="")
    SAUperiod <- paste(SAU,i,sep="")
    
    sqlQuery(loc,paste("alter table ",table_dm,"
                        drop column if exists ",UGBperiod,sep=""))

    #Vérifier la jointure et l'unité de la SAU (m2 ou ha?)
    sqlQuery(loc,paste("alter table ",table_dm,"
                        add column ",UGBperiod," numeric;
                        update ",table_dm,"
                        SET ",UGBperiod," = s1.",UGBperiod," from(
                        select (",UGBperiod,"/",SAUperiod,") as ",UGBperiod,",num_canton
                        from ",schema,".",tableRA,") as s1
                        where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
    
    print(sqlQuery(loc,paste("
        COMMENT ON COLUMN ",table_dm,".",UGBperiod," IS \'Densité UGBTA/SAU pour ",i,".\';",sep="")))
}

# Calcul densité des autres UGB
variableUGB <- "ensembledesexploitations"
p_variable <- c("ugbh_sau","ugbgrani_sau")
table_RA <- c("ugbherbi_canton","ugbgrani_canton")
period <- c("2000","2010")
SAU <- "superficieagricoleutilisée1"

signification <- cbind("herbivores","granivores")

cpt <- 0
for(v in table_RA){
  cpt <- cpt + 1
  print(v)
  sign_varia <- signification[cpt]
  
  for(i in periodUGB){
    
      p_variableRA <- paste(p_variable[cpt],i,sep="")
      print(p_variableRA)
      tableRA <- paste(v,i,sep="")
      sqlQuery(loc,paste("alter table ",table_dm,"
                          drop column if exists ",p_variableRA,sep=""))

      #Vérifier la jointure et l'unité de la SAU (m2 ou ha?)
      sqlQuery(loc,paste("alter table ",table_dm,"
                          add column ",p_variableRA," numeric;
                          update ",table_dm,"
                          SET ",p_variableRA," = s1.",p_variableRA," from(
                          select (",variableUGB,"/cc.",SAU,") as ",p_variableRA,",cc.num_canton
                          from ",schema,".",tableRA,"
                          right join ",schema,".S_cultures_canton2000 as cc on cc.num_canton=",tableRA,".num_canton::text) as s1
                          where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
      
      print(sqlQuery(loc,paste("
        COMMENT ON COLUMN ",table_dm,".",p_variableRA," IS \'Pourcentage des UGB ",sign_varia," en fonction de la surface agricole utile en ",i,".\';",sep="")))
  }
}
```

Calcul des évolutions et jointure vers la table `dm_vecteurs.canton`
====================================================================

Les évolutions d'occupation du sol et de la densité d'UGB sont calculées entre 1970-1979; 1970-2010 et 1979-2010. Le calcul de l'évolution se base sur la relation suivante : (OccupA - OccupB)/(SAU B) avec A l'année la plus récente et B l'année la plus ancienne.

Evolution de la superficie d'occupation du sol
----------------------------------------------

``` r
# Calcul de l'évolution des superficies pour 1979-2010

# Paramètres
SAU <- "superficieagricoleutilisée1"
p_variable <- c("var_sth7910","var_cereale7910","var_sfp7910","var_mf7910")
variable <- c("superficietoujoursenherbesth","céréales","fourragesetsuperficiestoujoursenherbe","maïsfourrageetensilage")
signification <- cbind("de la surface toujours en herbe","de la surface en céréales"," de la surface fourragère principale","de la surface en maîs fourrage ensilage")
type_RA <- "s_cultures_canton"
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)

# Calcul de statistiques pour les cultures
cpt <- 0
for(v in variable){
  cpt <- cpt + 1
  #sign_varia <- signification[cpt]
  p_variableRA <- p_variable[cpt]
  
  sqlQuery(loc,paste("alter table ",table_dm,"
                      drop column if exists ",p_variableRA,sep=""))
  
  sqlQuery(loc,paste("alter table ",table_dm,"
                      add column ",p_variableRA," numeric;
                      update ",table_dm,"
                      SET ",p_variableRA," = s1.",p_variableRA," from(
                      select ((cc.",v," - tt.",v,")/tt.",SAU,")*100 as ",p_variableRA,",tt.num_canton
                      from ",schema,".",type_RA,"1979 as tt
                      right join ",schema,".",type_RA,"2010 as cc on cc.num_canton=tt.num_canton::text) as s1
                      where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
    
  # Ajout d'un commentaire sur la nouvelle colonne crée
    print(sqlQuery(loc,paste("
    COMMENT ON COLUMN ",table_dm,".",p_variableRA," IS \'Evolution ",signification[cpt]," entre 2010 et 1979 par rapport à la SAU de 1979.\';",sep="")))
}

## Evolution pour 1970-1979
p_variable <- c("var_sth7079","var_cereale7079","var_sfp7079","var_mf7079")
variable <- c("superficietoujoursenherbesth","céréales","fourragesetsuperficiestoujoursenherbe","maïsfourrageetensilage")
signification <- cbind("de la surface toujours en herbe","de la surface en céréales"," de la surface fourragère principale","de la surface en maîs fourrage ensilage")
type_RA <- "s_cultures_canton"

# Calcul de statistiques pour les cultures
cpt <- 0
for(v in variable){
  cpt <- cpt + 1
  #sign_varia <- signification[cpt]
  p_variableRA <- p_variable[cpt]
  
  sqlQuery(loc,paste("alter table ",table_dm,"
                      drop column if exists ",p_variableRA,sep=""))
  
  sqlQuery(loc,paste("alter table ",table_dm,"
                      add column ",p_variableRA," numeric;
                      update ",table_dm,"
                      SET ",p_variableRA," = s1.",p_variableRA," from(
                      select ((cc.",v," - tt.",v,")/tt.",SAU,")*100 as ",p_variableRA,",tt.num_canton
                      from ",schema,".",type_RA,"1970 as tt
                      right join ",schema,".",type_RA,"1979 as cc on cc.num_canton=tt.num_canton::text) as s1
                      where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
    
  # Ajout d'un commentaire sur la nouvelle colonne crée
    print(sqlQuery(loc,paste("
    COMMENT ON COLUMN ",table_dm,".",p_variableRA," IS \'Evolution ",signification[cpt]," entre 1979 et 1970 par rapport à la SAU de 1979.\';",sep="")))
}
```

Evolution des UGB tous aliments pour 1988-2010
----------------------------------------------

``` r
# Paramètres
SAU <- "sau"
variable <- "var_ugb8810"
tableRA <- "ugbta_canton880010"
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)

sqlQuery(loc,paste("alter table ",table_dm,"
                    drop column if exists ",variable,sep=""))
  
sqlQuery(loc,paste("alter table ",table_dm,"
                      add column ",variable," numeric;
                      update ",table_dm,"
                      SET ",variable," = s1.",variable," from(
                      select ((ugbta2010- ugbta1988)/",SAU,"1988)*100 as ",variable,",num_canton
                      from ",schema,".",tableRA,") as s1
                      where ",table_dm,".code_canton=s1.num_canton::text",sep=""))
    
  # Ajout d'un commentaire sur la nouvelle colonne crée
    print(sqlQuery(loc,paste("
    COMMENT ON COLUMN ",table_dm,".",variable," IS \'Evolution des UGB tous aliment entre 2010 et 1988 par rapport à la SAU de 1988 (%).\';",sep="")))
```

Préparation des données et statistiques
---------------------------------------

Les données du recencement (pourcentage de prairie par SAU par exemple) sont ré-organisées pour faciliter les traitements statistiques et la production de graphique. La fonction `melt` est utilisée pour transformer les données d'un format "large" à un format "long".

``` r
# Paramètres
dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'" # Configuration de la connexion vers le PostGIS
varia <- c("p_sth","p_sfp","p_prairie") # Variable à analyser 
period <- c("1970","1979","1988","2000","2010") #Période de temps
id <- c("code_canton","code_reg","nom_region") #Nom de l'identifiant

# Lecture du postgis
mapcanton <- readOGR(dsn = dsn, "dm_vecteurs.canton")
```

    ## OGR data source with driver: PostgreSQL 
    ## Source: "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'", layer: "dm_vecteurs.canton"
    ## with 3708 features
    ## It has 117 fields

``` r
# Boucle pour séparer l'année du nom de la variable étudiée
cpt <- 0
for(i in varia){
  print(i)
  cpt <- cpt + 1
  variaperiod <- paste(i,period,sep="")  
  
  stats.canton <- mapcanton[,c(id,variaperiod)]
  # Modification de la structure de la table
  stats.canton <- melt(data=stats.canton@data,id.vars=id)
  # Extraction de l'année et renommage des colonnes
  stats.canton[,"variable"] <- as.character(unlist(regmatches(stats.canton[,"variable"],gregexpr('[0-9]+.[0-9]+',stats.canton[,"variable"]))))
  colnames(stats.canton)[4:5] <- c("annees",i) #revoir la sélection de ces colonnes
    
  if(cpt==1){
    # Construction de la première table
    melt.canton <- stats.canton
  }else{
    # Ajout à chaque itération de la variable (i)
    melt.canton <- merge(melt.canton,stats.canton, by.x=c(id,"annees"), by.y=c(id,"annees"),all.x=TRUE,all.y=TRUE)
  }
}
```

    ## [1] "p_sth"
    ## [1] "p_sfp"
    ## [1] "p_prairie"

``` r
# Création finale de la table
melted.RA <- melt(data=melt.canton,id.vars=c(id,"annees"))

# Enregistrement dans le schema RA
tablename <- paste("dm_traitements.","melted_RA",sep="")
sqlQuery(loc,paste("drop table if exists ",tablename,sep=""))
```

    ## character(0)

``` r
sqlSave(loc,melted.RA,tablename=tablename)
```

A la suite de ce traitement, la table de travail est stockée sous le nom de dm\_traitements.melted\_RA.

Création des métadonnées
========================

Les commentaires ajoutés lors du processus de création des statistiques peuvent être regroupés au sein du même table pour faciliter la compréhension du nom des champs présent dans les tables. La table ci-dessous présente les métadonnées de la table `dm_vecteurs.canton`.

``` r
# Sélection de la vue metadata
tablecomment <- sqlQuery(loc,paste("select column_name,comment from public.metadata where schema_name='dm_vecteurs' and table_name='canton' and comment is not null",sep=""))
knitr::kable(tablecomment, caption = "Description des champs de la table dm_vecteurs.canton",format="markdown")
```

<table>
<colgroup>
<col width="6%" />
<col width="93%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">column_name</th>
<th align="left">comment</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">ampli_t_juil_janv</td>
<td align="left">Amplitude thermique (°C) (juillet-janvier)</td>
</tr>
<tr class="even">
<td align="left">chgt2000</td>
<td align="left">Chargement (UGBTA/surface de SFP) pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">chgt2010</td>
<td align="left">Chargement (UGBTA/surface de SFP) pour 2010.</td>
</tr>
<tr class="even">
<td align="left">corgox_medequi0004</td>
<td align="left">Médiane des teneurs en carbone organique après ré-échantillonnage pour la période 0004.</td>
</tr>
<tr class="odd">
<td align="left">corgox_medequi0509</td>
<td align="left">Médiane des teneurs en carbone organique après ré-échantillonnage pour la période 0509.</td>
</tr>
<tr class="even">
<td align="left">corgox_medequi1014</td>
<td align="left">Médiane des teneurs en carbone organique après ré-échantillonnage pour la période 1014.</td>
</tr>
<tr class="odd">
<td align="left">corgox_medequi9094</td>
<td align="left">Médiane des teneurs en carbone organique après ré-échantillonnage pour la période 9094.</td>
</tr>
<tr class="even">
<td align="left">corgox_medequi9599</td>
<td align="left">Médiane des teneurs en carbone organique après ré-échantillonnage pour la période 9599.</td>
</tr>
<tr class="odd">
<td align="left">diff12</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff13</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diff14</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff15</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diff23</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff24</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diff25</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff34</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diff35</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="even">
<td align="left">diff45</td>
<td align="left">Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian12</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian13</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian14</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian15</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian23</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian24</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian25</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian34</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">diffmedian35</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="even">
<td align="left">diffmedian45</td>
<td align="left">Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.</td>
</tr>
<tr class="odd">
<td align="left">elevage1988</td>
<td align="left">Pourcentage de la somme des OTEX de type elevage (otex 45,46,47,48) pour 1988.</td>
</tr>
<tr class="even">
<td align="left">elevage2000</td>
<td align="left">Pourcentage de la somme des OTEX de type elevage (otex 45,46,47,48) pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">elevage2010</td>
<td align="left">Pourcentage de la somme des OTEX de type elevage (otex 45,46,47,48) pour 2010.</td>
</tr>
<tr class="even">
<td align="left">elevagehorsol1988</td>
<td align="left">Pourcentage exploitation ayant une orientation technico-economique de type elevage hors sol (otex 51,52,53,74) en 1988.</td>
</tr>
<tr class="odd">
<td align="left">elevagehorsol2000</td>
<td align="left">Pourcentage exploitation ayant une orientation technico-economique de type elevage hors sol (otex 51,52,53,74) en 2000.</td>
</tr>
<tr class="even">
<td align="left">elevagehorsol2010</td>
<td align="left">Pourcentage exploitation ayant une orientation technico-economique de type elevage hors sol (otex 51,52,53,74) en 2010.</td>
</tr>
<tr class="odd">
<td align="left">grdcultures1988</td>
<td align="left">Pourcentage exploitation ayant une orientation technico-economique de type grandes cultures (otex 15,16) en 1988.</td>
</tr>
<tr class="even">
<td align="left">grdcultures2000</td>
<td align="left">Pourcentage exploitation ayant une orientation technico-economique de type grandes cultures (otex 15,16) en 2000.</td>
</tr>
<tr class="odd">
<td align="left">grdcultures2010</td>
<td align="left">Pourcentage exploitation ayant une orientation technico-economique de type grandes cultures (otex 15,16) en 2010.</td>
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
<td align="left">Pourcentage de céréales par rapport à la SAU pour 1970.</td>
</tr>
<tr class="even">
<td align="left">p_c1979</td>
<td align="left">Pourcentage de céréales par rapport à la SAU pour 1979.</td>
</tr>
<tr class="odd">
<td align="left">p_c1988</td>
<td align="left">Pourcentage de céréales par rapport à la SAU pour 1988.</td>
</tr>
<tr class="even">
<td align="left">p_c2000</td>
<td align="left">Pourcentage de céréales par rapport à la SAU pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">p_c2010</td>
<td align="left">Pourcentage de céréales par rapport à la SAU pour 2010.</td>
</tr>
<tr class="even">
<td align="left">p_mf1970</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport à la SAU pour 1970.</td>
</tr>
<tr class="odd">
<td align="left">p_mf1979</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport à la SAU pour 1979.</td>
</tr>
<tr class="even">
<td align="left">p_mf1988</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport à la SAU pour 1988.</td>
</tr>
<tr class="odd">
<td align="left">p_mf2000</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport à la SAU pour 2000.</td>
</tr>
<tr class="even">
<td align="left">p_mf2010</td>
<td align="left">Pourcentage de maîs fourrage ensilage par rapport à la SAU pour 2010.</td>
</tr>
<tr class="odd">
<td align="left">p_prairie1970</td>
<td align="left">Pourcentage des prairies (sommes des prairies temporaires et des surfaces toujours en herbe) en fonction de la SAU pour 1970.</td>
</tr>
<tr class="even">
<td align="left">p_prairie1979</td>
<td align="left">Pourcentage des prairies (sommes des prairies temporaires, artificielles et des surfaces toujours en herbe) en fonction de la SAU pour 1979.</td>
</tr>
<tr class="odd">
<td align="left">p_prairie1988</td>
<td align="left">Pourcentage des prairies (sommes des prairies temporaires, artificielles et des surfaces toujours en herbe) en fonction de la SAU pour 1988.</td>
</tr>
<tr class="even">
<td align="left">p_prairie2000</td>
<td align="left">Pourcentage des prairies (sommes des prairies temporaires, artificielles et des surfaces toujours en herbe) en fonction de la SAU pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">p_prairie2010</td>
<td align="left">Pourcentage des prairies (sommes des prairies temporaires, artificielles et des surfaces toujours en herbe) en fonction de la SAU pour 2010.</td>
</tr>
<tr class="even">
<td align="left">p_sfp1970</td>
<td align="left">Pourcentage de surface fourragère principale par rapport à la SAU pour 1970.</td>
</tr>
<tr class="odd">
<td align="left">p_sfp1979</td>
<td align="left">Pourcentage de surface fourragère principale par rapport à la SAU pour 1979.</td>
</tr>
<tr class="even">
<td align="left">p_sfp1988</td>
<td align="left">Pourcentage de surface fourragère principale par rapport à la SAU pour 1988.</td>
</tr>
<tr class="odd">
<td align="left">p_sfp2000</td>
<td align="left">Pourcentage de surface fourragère principale par rapport à la SAU pour 2000.</td>
</tr>
<tr class="even">
<td align="left">p_sfp2010</td>
<td align="left">Pourcentage de surface fourragère principale par rapport à la SAU pour 2010.</td>
</tr>
<tr class="odd">
<td align="left">p_sth1970</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport à la SAU pour 1970.</td>
</tr>
<tr class="even">
<td align="left">p_sth1979</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport à la SAU pour 1979.</td>
</tr>
<tr class="odd">
<td align="left">p_sth1988</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport à la SAU pour 1988.</td>
</tr>
<tr class="even">
<td align="left">p_sth2000</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport à la SAU pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">p_sth2010</td>
<td align="left">Pourcentage de surface toujours en herbe par rapport à la SAU pour 2010.</td>
</tr>
<tr class="even">
<td align="left">pluie0910_juil</td>
<td align="left">NA</td>
</tr>
<tr class="odd">
<td align="left">pluie_ecart_janv</td>
<td align="left">Ecart à la moyenne en janvier (mm)</td>
</tr>
<tr class="even">
<td align="left">pluie_ecart_juil</td>
<td align="left">Ecart à la moyenne en juillet (mm)</td>
</tr>
<tr class="odd">
<td align="left">polyelevage1988</td>
<td align="left">Pourcentage de la somme des OTEX de type elevage (otex 45,46,47,48) pour 1988.</td>
</tr>
<tr class="even">
<td align="left">polyelevage2000</td>
<td align="left">Pourcentage de la somme des OTEX de type elevage (otex 45,46,47,48) pour 2000.</td>
</tr>
<tr class="odd">
<td align="left">polyelevage2010</td>
<td align="left">Pourcentage de la somme des OTEX de type elevage (otex 45,46,47,48) pour 2010.</td>
</tr>
<tr class="even">
<td align="left">std_pluie_janv</td>
<td align="left">Variabilité 1971-2000 en janvier (mm)</td>
</tr>
<tr class="odd">
<td align="left">std_pluie_juil</td>
<td align="left">Variabilité 1971-2000 en juillet (mm)</td>
</tr>
<tr class="even">
<td align="left">std_temp_janv</td>
<td align="left">Variabilité 1971-2000 en janvier (°C)</td>
</tr>
<tr class="odd">
<td align="left">std_temp_juil</td>
<td align="left">Variabilité 1971-2000 en juillet (°C)</td>
</tr>
<tr class="even">
<td align="left">ttemp_an</td>
<td align="left">Température moyenne annuelle</td>
</tr>
<tr class="odd">
<td align="left">typo_clim</td>
<td align="left">Type de climat</td>
</tr>
<tr class="even">
<td align="left">ugbgrani_sau2000</td>
<td align="left">Pourcentage des UGB granivores en fonction de la surface agricole utile en 2000.</td>
</tr>
<tr class="odd">
<td align="left">ugbgrani_sau2010</td>
<td align="left">Pourcentage des UGB granivores en fonction de la surface agricole utile en 2010.</td>
</tr>
<tr class="even">
<td align="left">ugbh_sau2000</td>
<td align="left">Pourcentage des UGB herbivores en fonction de la surface agricole utile en 2000.</td>
</tr>
<tr class="odd">
<td align="left">ugbh_sau2010</td>
<td align="left">Pourcentage des UGB herbivores en fonction de la surface agricole utile en 2010.</td>
</tr>
<tr class="even">
<td align="left">ugbta1988</td>
<td align="left">Densité UGBTA/SAU pour 1988.</td>
</tr>
<tr class="odd">
<td align="left">ugbta2000</td>
<td align="left">Densité UGBTA/SAU pour 2000.</td>
</tr>
<tr class="even">
<td align="left">ugbta2010</td>
<td align="left">Densité UGBTA/SAU pour 2010.</td>
</tr>
<tr class="odd">
<td align="left">var_cereale7079</td>
<td align="left">Evolution de la surface en céréales entre 1979 et 1970 par rapport à la SAU de 1979.</td>
</tr>
<tr class="even">
<td align="left">var_cereale7910</td>
<td align="left">Evolution de la surface en céréales entre 2010 et 1979 par rapport à la SAU de 1979.</td>
</tr>
<tr class="odd">
<td align="left">var_mf7079</td>
<td align="left">Evolution de la surface en maîs fourrage ensilage entre 1979 et 1970 par rapport à la SAU de 1979.</td>
</tr>
<tr class="even">
<td align="left">var_mf7910</td>
<td align="left">Evolution de la surface en maîs fourrage ensilage entre 2010 et 1979 par rapport à la SAU de 1979.</td>
</tr>
<tr class="odd">
<td align="left">var_sfp7079</td>
<td align="left">Evolution de la surface fourragère principale entre 1979 et 1970 par rapport à la SAU de 1979.</td>
</tr>
<tr class="even">
<td align="left">var_sfp7910</td>
<td align="left">Evolution de la surface fourragère principale entre 2010 et 1979 par rapport à la SAU de 1979.</td>
</tr>
<tr class="odd">
<td align="left">var_sth7079</td>
<td align="left">Evolution de la surface toujours en herbe entre 1979 et 1970 par rapport à la SAU de 1979.</td>
</tr>
<tr class="even">
<td align="left">var_sth7910</td>
<td align="left">Evolution de la surface toujours en herbe entre 2010 et 1979 par rapport à la SAU de 1979.</td>
</tr>
<tr class="odd">
<td align="left">var_ugb8810</td>
<td align="left">Evolution des UGB tous aliment entre 2010 et 1988 par rapport à la SAU de 1988 (%).</td>
</tr>
<tr class="even">
<td align="left">zonage_cplt</td>
<td align="left">zonage_cplt des principales régions d élevage par canton. La valeur est issue des données communales (public.regelevage) et représente la valeur majoritaire par canton. La table public.regelevage présente la signification des codes utilisés pour le zonage. Source DG AGRI RICA UE 2012 - traitement IDELE</td>
</tr>
<tr class="odd">
<td align="left">zonage_simple</td>
<td align="left">zonage_simple des principales régions d élevage par canton. La valeur est issue des données communales (public.regelevage) et représente la valeur majoritaire par canton. La table public.regelevage présente la signification des codes utilisés pour le zonage. Source DG AGRI RICA UE 2012 - traitement IDELE</td>
</tr>
</tbody>
</table>
