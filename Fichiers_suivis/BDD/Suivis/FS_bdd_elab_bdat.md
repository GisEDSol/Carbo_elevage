Traitement des données de la BDAT
================
Jean-Baptiste Paroissien

-   [Objectifs](#objectifs)
-   [Intégration des données de la BDAT vers la table `dm_vecteurs.canton`](#integration-des-donnees-de-la-bdat-vers-la-table-dm_vecteurs.canton)
    -   [Intégration de la médiane des teneurs en carbone organique par canton](#integration-de-la-mediane-des-teneurs-en-carbone-organique-par-canton)
    -   [Intégration des résultats des tests statistiques des différences de teneur en carbone organique](#integration-des-resultats-des-tests-statistiques-des-differences-de-teneur-en-carbone-organique)
-   [Création des tables de travail au format "long"](#creation-des-tables-de-travail-au-format-long)
    -   [Evolution des teneurs en carbone organique](#evolution-des-teneurs-en-carbone-organique)

``` r
Sys.Date()
```

    ## [1] "2017-01-27"

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
    ## [1] parallel  grid      stats     graphics  grDevices utils     datasets 
    ## [8] methods   base     
    ## 
    ## other attached packages:
    ##  [1] raster_2.5-8       doMC_1.3.4         iterators_1.0.8   
    ##  [4] foreach_1.4.3      plyr_1.8.4         caret_6.0-73      
    ##  [7] factoextra_1.0.3   GGally_1.3.0       pander_0.6.0      
    ## [10] knitr_1.15.1       FactoMineR_1.34    wesanderson_0.3.2 
    ## [13] mapproj_1.2-4      gridExtra_2.2.1    Hmisc_4.0-0       
    ## [16] Formula_1.2-1      survival_2.40-1    lattice_0.20-34   
    ## [19] reshape2_1.4.2     devtools_1.12.0    classInt_0.1-23   
    ## [22] RColorBrewer_1.1-2 maptools_0.8-40    rgdal_1.2-4       
    ## [25] sp_1.2-3           ggplot2_2.2.0      stringr_1.1.0     
    ## [28] fields_8.4-1       maps_3.1.1         spam_1.4-0        
    ## [31] gdata_2.17.0       RODBC_1.3-14      
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] splines_3.3.2        gtools_3.5.0         assertthat_0.1      
    ##  [4] stats4_3.3.2         latticeExtra_0.6-28  yaml_2.1.14         
    ##  [7] ggrepel_0.6.5        backports_1.0.4      quantreg_5.29       
    ## [10] digest_0.6.10        minqa_1.2.4          colorspace_1.2-7    
    ## [13] htmltools_0.3.5      Matrix_1.2-7.1       SparseM_1.74        
    ## [16] scales_0.4.1         lme4_1.1-12          MatrixModels_0.4-1  
    ## [19] htmlTable_1.7        tibble_1.2           mgcv_1.8-16         
    ## [22] car_2.1-4            withr_1.0.2          nnet_7.3-12         
    ## [25] lazyeval_0.2.0       pbkrtest_0.4-6       magrittr_1.5        
    ## [28] memoise_1.0.0        evaluate_0.10        nlme_3.1-128        
    ## [31] MASS_7.3-45          foreign_0.8-67       class_7.3-14        
    ## [34] tools_3.3.2          data.table_1.10.0    munsell_0.4.3       
    ## [37] cluster_2.0.5        flashClust_1.01-2    e1071_1.6-7         
    ## [40] nloptr_1.0.4         leaps_2.9            rmarkdown_1.3       
    ## [43] gtable_0.2.0         ModelMetrics_1.1.0   codetools_0.2-15    
    ## [46] reshape_0.8.6        rprojroot_1.1        stringi_1.1.2       
    ## [49] Rcpp_0.12.7          rpart_4.1-10         acepack_1.4.1       
    ## [52] scatterplot3d_0.3-37

Objectifs
=========

Ce fichier permet de créer les tables de données de la BDAT utilisables pour le traitement statistique. Deux principaux points sont réalisés :

-   Les teneurs en carbone organique et les calculs d'évolution de ces teneurs sont jointes dans la table de travail `dm_vecteurs.canton` pour faciliter la cartographie et l'analyse spatiale des données,
-   Plusieurs autres tables sont générées pour les différents travaux demandant un format de table "long".

Intégration des données de la BDAT vers la table `dm_vecteurs.canton`
=====================================================================

Intégration de la médiane des teneurs en carbone organique par canton
---------------------------------------------------------------------

``` r
# Paramètres
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

**Important :** La création de ces tables nécessite le lancement de plusieurs scripts au préalable : `FS_bdd_brute.Rmd`,`FS_bdd_elab_climat.Rmd`,`FS_bdd_elab_ra.Rmd` et `FS_bdd_elab_clc.Rmd`.

``` r
# Paramètres
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)
varia <- "corgox_medequi" # Variable à analyser 
period <- c("9094","9599","0004","0509","1014")
variaoccup <- c("p_sth","p_sfp","p_prairie")
#id_class <- apply(expand.grid(varia,period), 1, paste, collapse="")
periodoccup <- c("1970","1979","1988","2000","2010")
id_class <- apply(expand.grid(variaoccup,periodoccup),1, function(x){paste("classe_",x[1],x[2],sep="")})
id <- c("code_canton","code_reg","nom_region","typo_clim","zonage_simple","zonage_cplt",id_class) #Nom des identifiants

# Lecture de la table dm_vecteurs.canton
mapcanton <- sqlQuery(loc,paste("select * from ",table_dm,sep=""))

# Boucle pour séparer l'année du nom de la variable étudiée


# revoir dans le détail la construction
cpt <- 0
for(i in varia){
  cpt <- cpt + 1
  variaperiod <- paste(i,period,sep="")  
  
  stats.canton <- mapcanton[,c(id,variaperiod)]

  # Modification de la structure de la table
  stats.canton <- melt(data=stats.canton,id.vars=id)
  
  # Extraction de l'année et renommage des colonnes
  stats.canton[,"variable"] <- as.character(unlist(regmatches(stats.canton[,"variable"],gregexpr('[0-9]+.[0-9]+',stats.canton[,"variable"]))))
  colnames(stats.canton)[(length(id)+1):(length(id)+2)] <- c("annees",i)
    
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

# Rajouter les commentaires
```

Evolution des teneurs en carbone organique
------------------------------------------

### Intégration des résultats dans une table au format long

``` r
# Paramètres
table_dm <- "dm_vecteurs.canton" # Nom de la table pour rassembler les calculs (vers le schéma dm_vecteurs)
varia <- c("diffmedian","diff") # Préfixe de la variable à intégrer (varia+period)
period <- c("12","13","14","15","23","24","25","34","35","45")
variaoccup <- c("sth","sfp","prairie")
periodra <- c("1970","1979","1988","2000","2010")
# Classes d'occupation du sol
id_class <- apply(expand.grid(variaoccup,periodra),1,function(x){paste("classe_p_",x[1],x[2],sep="")})
periodoccup <- c("1970_2010","1979_2010","1988_2010")
id_varclass <- apply(expand.grid(variaoccup,periodoccup),1, function(x){paste("classe_var_",x[1],x[2],sep="")})
id_diff <- apply(expand.grid(variaoccup,periodoccup),1, function(x){paste("diff_var_",x[1],x[2],sep="")})
id <- c("code_canton","code_reg","nom_region","typo_clim","zonage_simple","zonage_cplt",id_class,id_diff,id_varclass)

# Lecture de la table dm_vecteurs.canton
mapcanton <- sqlQuery(loc,paste("select * from ",table_dm,sep=""))

# Boucle pour séparer les périodes analysées du nom de la variable étudiée
cpt <- 0
for(i in varia){
  print(i)
  cpt <- cpt + 1
  variaperiod <- paste(i,period,sep="")  
  stats.canton <- mapcanton[,c(id,variaperiod)]
 
   # Modification de la structure de la table
  stats.canton <- melt(data=stats.canton,id.vars=id)

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
melted.bdatdiff <- melt.canton
melted.bdatdiff$typo_clim <- as.factor(melted.bdatdiff$typo_clim)

# Enregistrement dans le schéma dm_traitements
tablename <- paste("dm_traitements.","melted_bdatdiff2",sep="")
sqlQuery(loc,paste("drop table if exists ",tablename,sep=""))
sqlSave(loc,melted.bdatdiff,tablename=tablename)

# Rajouter les commentaires
```
