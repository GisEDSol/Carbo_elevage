#' @title importparametres
#'
#' @description Fonction pour charger les libraries, et les variables du projet
#'
#' @param dsn Paramètre de connexion vers la base de données
#' @param repmaster Chemin vers la copie du dépôt GitHub en local (XX/XX/)
#' @param repdata Chemin vers les données à intégrer dans la base (XX/XX/)
#'
#' @author Jean-Baptiste Paroissien
#' @keywords 
#' @seealso 
#' @export
#' @examples
#' ## Ne fonctionne pas 
# importparametres(repmaster="/media/sf_GIS_ED/Dev/Scripts/master/",repdata="/media/sf_GIS_ED/Dev/",dsn="PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'")


importparametres <- function(dsn,
						repmaster,
						repdata)
{

knitr::opts_chunk$set(echo = TRUE)

# Chargement des librairies
library(RODBC);library(gdata);library(fields);library(stringr);library(ggplot2);library(rgdal);library(maptools);library(RColorBrewer);library(classInt);library(devtools);library(reshape2)
library(Hmisc);library(gridExtra);library(mapproj);library(wesanderson);library(FactoMineR);library(knitr);library(wesanderson);library(pander);library(GGally);library(factoextra);library(caret);library(plyr)

# Définition des principaux répertoires de travail

##
assign("repmetadonnees",paste(repmaster,"Documentation/Metadonnees/",sep=""),.GlobalEnv)
assign("repfonctions",paste(repmaster,"Fonctions/",sep=""),.GlobalEnv)
#########################################

##
assign("repLucas",paste(repdata,"Sol/Lucas/",sep=""),.GlobalEnv)
assign("repCLC",paste(repdata,"Vegetation_Occup/CLC/",sep=""),.GlobalEnv)
assign("repBDAT",paste(repdata,"Sol/bdat/",sep=""),.GlobalEnv)
assign("repBase",paste(repdata,"Base/",sep=""),.GlobalEnv)
assign("repagreste",paste(repdata,"Vegetation_Occup/Agreste/Disar/",sep=""),.GlobalEnv)
#########################################

# Mise en place de la connexion ODBC
loc <- odbcConnect("solelevage",case="postgresql", believeNRows=FALSE)

# Paramètres de connexion de la BDD
dsn="PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'"

# Chargement des fonction
source(paste(repfonctions,"R/cartoperiod.R",sep=""))

# Fonction très pratique pour remplacer une suite de charact?res par une autre
gsub2 <- function(pattern, replacement, x, ...) {
  for(i in 1:length(pattern))
    x <- gsub(pattern[i], replacement[i], x, ...)
  x
}



#return(list(repLucas=repLucas))
}#Fin fonction