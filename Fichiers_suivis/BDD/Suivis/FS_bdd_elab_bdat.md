Traitement des données de la BDAT
================
Jean-Baptiste Paroissien

``` r
Sys.Date()
```

    ## [1] "2017-01-11"

``` r
sessionInfo()
```

    ## R version 3.3.2 (2016-10-31)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 16.04.1 LTS
    ## 
    ## locale:
    ##  [1] LC_CTYPE=fr_FR.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=fr_FR.UTF-8        LC_COLLATE=fr_FR.UTF-8    
    ##  [5] LC_MONETARY=fr_FR.UTF-8    LC_MESSAGES=fr_FR.UTF-8   
    ##  [7] LC_PAPER=fr_FR.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=fr_FR.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## attached base packages:
    ## [1] grid      stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ##  [1] plyr_1.8.4         caret_6.0-73       factoextra_1.0.3  
    ##  [4] GGally_1.3.0       pander_0.6.0       knitr_1.15.1      
    ##  [7] FactoMineR_1.34    wesanderson_0.3.2  mapproj_1.2-4     
    ## [10] gridExtra_2.2.1    Hmisc_4.0-0        Formula_1.2-1     
    ## [13] survival_2.40-1    lattice_0.20-34    reshape2_1.4.2    
    ## [16] devtools_1.12.0    classInt_0.1-23    RColorBrewer_1.1-2
    ## [19] maptools_0.8-40    rgdal_1.2-4        sp_1.2-3          
    ## [22] ggplot2_2.2.0      stringr_1.1.0      fields_8.4-1      
    ## [25] maps_3.1.1         spam_1.4-0         gdata_2.17.0      
    ## [28] RODBC_1.3-14      
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] ggrepel_0.6.5        Rcpp_0.12.7          class_7.3-14        
    ##  [4] gtools_3.5.0         assertthat_0.1       rprojroot_1.1       
    ##  [7] digest_0.6.10        foreach_1.4.3        MatrixModels_0.4-1  
    ## [10] backports_1.0.4      acepack_1.4.1        stats4_3.3.2        
    ## [13] evaluate_0.10        e1071_1.6-7          lazyeval_0.2.0      
    ## [16] SparseM_1.74         minqa_1.2.4          data.table_1.10.0   
    ## [19] nloptr_1.0.4         car_2.1-4            rpart_4.1-10        
    ## [22] Matrix_1.2-7.1       rmarkdown_1.3        splines_3.3.2       
    ## [25] lme4_1.1-12          foreign_0.8-67       munsell_0.4.3       
    ## [28] mgcv_1.8-16          htmltools_0.3.5      nnet_7.3-12         
    ## [31] flashClust_1.01-2    tibble_1.2           htmlTable_1.7       
    ## [34] codetools_0.2-15     reshape_0.8.6        withr_1.0.2         
    ## [37] MASS_7.3-45          leaps_2.9            ModelMetrics_1.1.0  
    ## [40] nlme_3.1-128         gtable_0.2.0         magrittr_1.5        
    ## [43] scales_0.4.1         stringi_1.1.2        scatterplot3d_0.3-37
    ## [46] latticeExtra_0.6-28  iterators_1.0.8      tools_3.3.2         
    ## [49] parallel_3.3.2       pbkrtest_0.4-6       yaml_2.1.14         
    ## [52] colorspace_1.2-7     cluster_2.0.5        memoise_1.0.0       
    ## [55] quantreg_5.29

Objectifs
=========

Ce fichier permet de créer les tables de données de la BDAT utilisables pour le traitement statistique. Deux étapes sont réalisées :

-   Les teneurs en carbone organique et les calculs d'évolution de ces teneurs sont jointes dans la table de travail `dm_vecteurs.canton` pour faciliter la cartographie et l'analyse spatiale des données,
-   Une table de travail appelée \`\` est également créée pour les différents travaux demandand un format de table "long".

Intégration des données de la BDAT vers la table `dm_vecteurs.canton`
=====================================================================

Intégration de la médiane des teneurs en carbone organique par canton
---------------------------------------------------------------------

``` r
# Paramètres
dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'" # Configuration de la connexion vers le PostGIS
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)
period <- c("9094","9599","0004","0509","1014")
schema <- "bdat"

for(i in period){
  var_variable <- paste("corgox_medequi",i,sep="")
  tableBDAT <- paste("bdat_canton_corgequiv",i,sep="")
  
  sqlQuery(loc,paste("alter table ",table_dm,"
                      drop column if exists ",var_variable,sep=""))
  
  sqlQuery(loc,paste("alter table ",table_dm,"
                      add column ",var_variable," numeric;
                      update ",table_dm,"
                      SET ",var_variable," = s1.med from(
                      select med,canton
                      from ",schema,".",tableBDAT,") as s1
                      where ",table_dm,".code_canton=s1.canton::text",sep=""))
  
  # Ajout d'un commentaire sur la nouvelle colonne crée
  print(sqlQuery(loc,paste("
  COMMENT ON COLUMN ",table_dm,".",var_variable," IS \'Médiane des teneurs en carbone organique après ré-échantillonnage pour la période ",i,".\';",sep="")))
}
```

Intégration des résultats des tests statistiques des différences de teneur en carbone organique
-----------------------------------------------------------------------------------------------

``` r
dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'" # Configuration de la connexion vers le PostGIS
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)
period <- c("12","13","14","15","23","24","25","34","35","45")
schema <- "bdat"

for(i in period){
  for(v in c("diff","diffmedian")){
  
  var_variable <- paste(v,i,sep="")
  
  tableBDAT <- paste("bdat_canton_corgequiv_comp_",i,sep="")
  
  sqlQuery(loc,paste("alter table ",table_dm,"
                      drop column if exists ",var_variable,sep=""))
  
  if(v=="diff"){
  sqlQuery(loc,paste("alter table ",table_dm,"
                      add column ",var_variable," text;
                      update ",table_dm,"
                      SET ",var_variable," = s1.diff from(
                      select diff,canton
                      from ",schema,".",tableBDAT,") as s1
                      where ",table_dm,".code_canton=s1.canton::text",sep=""))
    
      # Ajout d'un commentaire sur la nouvelle colonne crée
      print(sqlQuery(loc,paste("
      COMMENT ON COLUMN ",table_dm,".",var_variable," IS \'Résultat du test de significacité de la différence de la médiane des teneurs en carbone organique au niveau du canton.\';",sep="")))
    
  }else{
    sqlQuery(loc,paste("alter table ",table_dm,"
                      add column ",var_variable," numeric;
                      update ",table_dm,"
                      SET ",var_variable," = s1.",var_variable," from(
                      select ",var_variable,",canton
                      from ",schema,".",tableBDAT,") as s1
                      where ",table_dm,".code_canton=s1.canton::text",sep=""))
    
      # Ajout d'un commentaire sur la nouvelle colonne crée
      print(sqlQuery(loc,paste("
      COMMENT ON COLUMN ",table_dm,".",var_variable," IS \'Pourcentage d évolution de la médiane des teneurs en carbone organique par canton ((medA-medB)/medB))*100 avec B une période antérieure à A.\';",sep="")))
    }
  }
}
```

Création des tables de travail au format "long"
===============================================

Les données de la BDAT sont ré-organisées pour faciliter les traitements statistiques et la production de graphiques. La fonction `melt` est utilisée pour transformer les données d'un format "large" à un format "long". Deux tables sont créées :

-   `dm_traitements.melted.bdat` : table des valeurs des médianes teneurs en carbone organique
-   `dm_traitements.melted.bdat` : table des valeurs de différences des teneurs en carbone organique entre plusieurs périodes.

**Important :** La création de ces tables nécessite le lancement de plusieurs scripts au préalable : `FS_bdd_brute.Rmd`,`FS_bdd_elab_climat.Rmd` et `FS_bdd_elab_ra.Rmd`.

``` r
# Paramètres
dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'" # Configuration de la connexion vers le PostGIS
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)
varia <- c("corgox_medequi") # Variable à analyser 
period <- c("9094","9599","0004","0509","1014")
mapcanton <- readOGR(dsn = dsn, "dm_vecteurs.canton")
id <- c("code_canton","code_reg","nom_region","typo_clim","zonage_simple","zonage_cplt") #Nom de l'identifiant

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
  colnames(stats.canton)[(length(id)+1):(length(id)+2)] <- c("annees",i) #revoir la sélection de ces colonnes
    
  if(cpt==1){
    # Construction de la première table
    melt.canton <- stats.canton
  }else{
    # Ajout à chaque itération de la variable (i)
    melt.canton <- merge(melt.canton,stats.canton, by.x=c(id,"annees"), by.y=c(id,"annees"),all.x=TRUE,all.y=TRUE)
  }
}

# Création finale de la table
melted.bdat <- melt(data=melt.canton,id.vars=c(id,"annees"))
melted.bdat$annees <- as.character(melted.bdat$annees)
melted.bdat$typo_clim <- as.factor(melted.bdat$typo_clim)

# Enregistrement dans le schema dm_traitements
tablename <- paste("dm_traitements.","melted_bdat",sep="")
sqlQuery(loc,paste("drop table if exists ",tablename,sep=""))
sqlSave(loc,melted.bdat,tablename=tablename)
```

``` r
# Paramètres
dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'" # Configuration de la connexion vers le PostGIS
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)
varia <- c("diffmedian","diff") # Préfixe de la variable à intégrer (varia+period)
period <- c("12","13","14","15","23","24","25","34","35","45")
mapcanton <- readOGR(dsn = dsn, "dm_vecteurs.canton")
id <- c("code_canton","code_reg","nom_region","typo_clim","zonage_simple","zonage_cplt") #Nom des identifiants

# Boucle pour séparer les périodes analysées du nom de la variable étudiée
cpt <- 0
for(i in varia){
  print(i)
  cpt <- cpt + 1
  variaperiod <- paste(i,period,sep="")  
  stats.canton <- mapcanton[,c(id,variaperiod)]
 
   # Modification de la structure de la table
  stats.canton <- melt(data=stats.canton@data,id.vars=id)

  # Extraction de l'année et renommage des colonnes
  stats.canton[,"variable"] <- as.character(unlist(regmatches(stats.canton[,"variable"],gregexpr('[0-9]+.',stats.canton[,"variable"]))))
  colnames(stats.canton)[(length(id)+1):(length(id)+2)] <- c("period",i) #revoir la sélection de ces colonnes
    
  if(cpt==1){
    # Construction de la première table
    melt.canton <- stats.canton
  }else{
    # Ajout à chaque itération de la variable (i)
    melt.canton <- merge(melt.canton,stats.canton, by.x=c(id,"period"), by.y=c(id,"period"),all.x=TRUE,all.y=TRUE)
  }
}

# Création finale de la table
#melted.bdat_harmo <- melt(data=melt.canton,id.vars=c(id,"period"))
melted.bdatdiff<- melt.canton
melted.bdatdiff$typo_clim <- as.factor(melted.bdatdiff$typo_clim)

# Enregistrement dans le schema dm_traitements
tablename <- paste("dm_traitements.","melted_bdatdiff",sep="")
sqlQuery(loc,paste("drop table if exists ",tablename,sep=""))
sqlSave(loc,melted.bdatdiff,tablename=tablename)
```
