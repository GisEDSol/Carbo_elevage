Traitement des données topographiques
================
Jean-Baptiste Paroissien
26/01/2017

-   [Objectifs](#objectifs)
-   [Calcul de différentes statistiques jointes vers la table `dm_vecteurs.canton`](#calcul-de-differentes-statistiques-jointes-vers-la-table-dm_vecteurs.canton)
    -   [Aggrégation par la moyenne à l'échelle du canton](#aggregation-par-la-moyenne-a-lechelle-du-canton)

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

L'objectif de ce fichier de suivi est de stocker l'ensemble des traitements élaborés associés aux données topographiques. Ces traitements concernent pour le moment l'intégration des données [européenne](http://www.eea.europa.eu/data-and-maps/data/eu-dem) et touchent les points suivants :

-   Calcul de l'altitude moyenne par canton.

Calcul de différentes statistiques jointes vers la table `dm_vecteurs.canton`
=============================================================================

Aggrégation par la moyenne à l'échelle du canton
------------------------------------------------

``` r
reptopo <- "/media/sf_GIS_ED/Dev/Data/Topographie/dem_copernicus/" #répertoire contenant les rasters à assembler
Fr_demName <- paste(reptopo,"Fr_L93_90eudem.tif",sep="")

table_dm <- "dm_vecteurs.canton"
mapcanton <- readOGR(dsn = dsn,table_dm)

rasterdem1<-readGDAL(Fr_demName) 
r <- raster(rasterdem1,layer=1,values=TRUE)

r.vals <- extract(r, mapcanton, fun = mean, na.rm = TRUE,sp=TRUE)#fonctionne mais prend un certain temps...(l'extension 'Statistiques zones' est plus rapide)

# Jointure
tmp <- merge(mapcanton@data,r.vals, by.x="code_canton", by.y="code_canton",all.x=TRUE,all.y=TRUE)[,c("id_geofla.x","band1")]
vName <- "altimean"  #Nom du champs calculé
colnames(tmp) <- c("id_geofla2",vName)

# Création d'une table provisoire pour jointure
sqlQuery(loc,"drop table if exists dm_vecteurs.tmptopo")
sqlSave(loc,tmp,tablename="dm_vecteurs.tmptopo")

# Ajout de la colonne
sqlQuery(loc,paste("alter table ",table_dm,"
                    drop column if exists ",vName,";
                    alter table ",table_dm,"
                    add column ",vName," numeric",sep=""))                 
# Jointure 
sqlQuery(loc,paste("update ",table_dm,"
                    SET ",vName," = s1.",vName," from(
                    select ",vName,",id_geofla2
                    from dm_vecteurs.tmptopo) as s1
                    where ",table_dm,".id_geofla=s1.id_geofla2",sep=""))

# Ajout d'un commentaire sur la nouvelle colonne créée
print(sqlQuery(loc,paste("
COMMENT ON COLUMN ",table_dm,".",vName," IS \'Altitude moyenne (en m).\';",sep="")))
    
# Suppression de la table temporaire
sqlQuery(loc,"drop table if exists dm_vecteurs.tmptopo")

# Ci-dessous, une solution en postGIS (intéressant à exploiter)
#http://gis.stackexchange.com/questions/155974/calculate-mean-value-of-polygon-from-raster-in-postgis
```
