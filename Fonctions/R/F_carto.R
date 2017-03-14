#' @title carto
#'
#' @description Construit une carte d'une variable présente dans un vecteur postgis
#'
#' @param dsn Paramètre de connexion vers la base de données
#' @param tablecarto Nom de la table utilisée pour la cartographie (table postgis)
#' @param variablecarto Nom de la variable à cartographier
#' @param nclasse Nombre de classes de valeurs pour la classification des valeurs
#' @param style_classe Nom du type de classification (quantile, fixed, pretty, jenks)
#' @param couleur Nom de la palette couleur (selon RColorBrewer)display.brewer.all() pour connaître les différentes palettes
#' @param l_legend Nom pour la légende
#' @param repsortie Répertoire de sortie du fichier (XXX/XXX/)
#' @param nomfichier Nom du fichier en sortie (sans extension)
#' @param dept FALSE pour une cartographie france entière, dept <- "17|18" 
#' @param reg FALSE pour une cartographie france entière, reg <- "26|23|83|54|74|52|53|25|74"
#' @param nrowlayout nombre de rang pour la mise en page
#' @param ncollayout nombre de colonne pour la mise en page
#' @param position position de la légende ("right" ou "bottom")
#' @param ggsavewidth paramètre largeur pour la sortie de l'image
#' @param ggsaveheight paramètre hauteur pour la sortie de l'image
#'
#' @author Jean-Baptiste Paroissien
#' @keywords cartographie
#' @seealso 
#' @export
#' @examples
#' ## Ne fonctionne pas 
#tablecarto <- "dm_vecteurs.canton" 
#dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'" 
#variablecarto <- "typo_clim" #variable à spatialiser
#l_legend <- "Type de climat"#label de la variable
#nclasse <- 8 #Nombre de classes de valeurs pour la cartographie
#style_classe <- "fixed" #"pretty"#"jenks","fixed"
#couleur <- "Paired"#nom de la palette couleur (selon RColorBrewer)display.brewer.all() pour connaître les différentes palettes
#nomfichier <- "typo_clim"
#carto(dsn,tablecarto,variablecarto,nclasse,style_classe,couleur,l_legend=l_legend,repsortie,nomfichier,dept=FALSE,reg=FALSE,nrowlayout=1,ncollayout=1,position="bottom",ggsaveheight=7,ggsavewidth=10)  

carto <- function(
       dsn,
       tablecarto,
       variablecarto,
       nclasse,
       style_classe,
       couleur,
       l_legend,
       repsortie,
       nomfichier,
       dept,
       reg,
       nrowlayout,
       ncollayout,
       position,
       ggsavewidth,
       ggsaveheight
       )
{

library(rgdal);library(ggplot2);library(maptools);library(reshape2);library(classInt);
library(gridExtra);library(RPostgreSQL);library(stringr);library(rgeos)

##############################
# Lecture du postgis selon plusieurs conditions
id <- "id_geofla"

schema <- "dm_vecteurs"
table <- gsub2(".*\\.", "", unlist(tablecarto))

if((is.character(dept)==FALSE) & (is.character(reg)==FALSE)){
  map <- dbReadSpatial(con, schemaname=schema, tablename=table, geomcol="geom")
  dep <- dbReadSpatial(con, schemaname=schema, tablename="departement", geomcol="geom")
  }else{}

if(is.character(dept)==TRUE){
  # Sélection de la zone d'étude
  variablecartobis <- paste(variablecarto,collapse=",")
  strSQL <- paste("SELECT ",id,",",variablecartobis,",ST_AsText(geom) AS geom from ",tablecarto," where code_dept similar to '",dept,"'",sep="")
  rs = dbSendQuery(con,strSQL)
  df = fetch(rs,n=-1)
  dfTemp = dbGetQuery(con,strSQL)
  row.names(dfTemp) = dfTemp[,id]

for(i in seq(nrow(dfTemp))){
  if(i == 1){
    spTemp <- readWKT(dfTemp$geom[i], dfTemp$id_geofla[i])
  }else{
    spTemp <- rbind(spTemp, readWKT(dfTemp$geom[i], dfTemp$id_geofla[i]))
    }
  }

  map <- SpatialPolygonsDataFrame(spTemp, dfTemp[-(length(variablecarto)+2)])
  variablecartobis <- paste(variablecarto,collapse=",")
  strSQL <- paste("SELECT ",id,",ST_AsText(geom) AS geom
                   from dm_vecteurs.departement where code_reg similar to '",reg,"'",sep="")
  rs = dbSendQuery(con,strSQL)
  df = fetch(rs,n=-1)
  dfTemp = dbGetQuery(con,strSQL)
  row.names(dfTemp) = dfTemp[,id]

  for(i in seq(nrow(dfTemp))){
    if(i == 1){
      spTemp <- readWKT(dfTemp$geom[i], dfTemp$id_geofla[i])
    }
  else{
    spTemp <- rbind(spTemp, readWKT(dfTemp$geom[i], dfTemp$id_geofla[i]))
    }
  }
  
  dep <- SpatialPolygonsDataFrame(spTemp, dfTemp[-2])
  }else{}
  
if(reg!=FALSE){# Sélection de la zone d'étude
  
  variablecartobis <- paste(variablecarto,collapse=",")
  strSQL <- paste("SELECT ",id,",",variablecartobis,",ST_AsText(geom) AS geom
                   from ",tablecarto," where code_reg similar to '",reg,"'",sep="")
  rs = dbSendQuery(con,strSQL)
  df = fetch(rs,n=-1)
  dfTemp = dbGetQuery(con,strSQL)
  row.names(dfTemp) = dfTemp[,id]

  for(i in seq(nrow(dfTemp))){
    if(i == 1){
      spTemp <- readWKT(dfTemp$geom[i], dfTemp$id_geofla[i])
    }
  else{
    spTemp <- rbind(spTemp, readWKT(dfTemp$geom[i], dfTemp$id_geofla[i]))
    }
  }
  
  map <- SpatialPolygonsDataFrame(spTemp, dfTemp[-(length(variablecarto)+2)])
  strSQL <- paste("SELECT ",id,",ST_AsText(geom) AS geom
                   from dm_vecteurs.departement where code_reg similar to '",reg,"'",sep="")
  rs = dbSendQuery(con,strSQL)
  df = fetch(rs,n=-1)
  dfTemp = dbGetQuery(con,strSQL)
  row.names(dfTemp) = dfTemp[,id]

  for(i in seq(nrow(dfTemp))){
    if(i == 1){
      spTemp <- readWKT(dfTemp$geom[i], dfTemp$id_geofla[i])
    }
  else{
    spTemp <- rbind(spTemp, readWKT(dfTemp$geom[i], dfTemp$id_geofla[i]))
    }
  }
  
  dep <- SpatialPolygonsDataFrame(spTemp, dfTemp[-2])
  }else{}
  
# Conversion des spatialdataframe pour la cartographie sous ggpplot2
gpclibPermit()
cartodep <- fortify(dep,region=id)
cartofor <- fortify(map,region=id)

# Représentation cartographique

if(length(variablecarto)==1){
  # Extraction de toutes les valeurs à cartographier pour établir des classes de valeurs à cartographier
  melt.map <- melt(map@data[,variablecarto])[,1]

  if(style_classe=="fixed"){
    # Jointure et changement de nom
  	carto <- merge(cartofor, map@data[,c(id,variablecarto)], by.x="id", by.y=id)
  	colnames(carto)[8] <- "fill"
  	carto$fill <- as.factor(carto$fill)
    }else{
      classe_valeur <- classIntervals(melt.map,n=nclasse,style=style_classe,digits=2,na.rm=TRUE)[[2]]
      # Jointure et changement de nom
      carto <- merge(cartofor, map@data[,c(id,variablecarto)], by.x="id", by.y=id)
      colnames(carto)[8] <- "fill"
      carto[,"fill"] <- cut(carto[,"fill"] ,breaks = data.frame(classe_valeur)[,1],include.lowest=T)  
    }

	tt <- ggplot(carto, aes(x=long, y=lat)) +
    	                geom_polygon(data=carto, aes(group=group, fill=fill),size=0.1) +
                     	geom_path(data=carto, aes(x=long,y=lat,group=group),color="white",size=0.1)+# Représenter les cantons
                     	geom_path(data=cartodep, aes(x=long,y=lat,group=group),color="black",size=0.1)+# Représenter les contours des départements
                     	scale_fill_brewer(type=qual,palette = couleur,name=l_legend,guide = guide_legend(reverse=FALSE,nrow=2))+theme(legend.position="bottom")+
                     	theme(plot.title = element_text(size=12,face="bold"),
                           	text = element_text(size=12),
                           	axis.text =element_blank(),# change the theme options
                           	axis.title =element_blank(),# remove axis titles
                           	axis.ticks =element_blank())+
                     	#guides(fill=FALSE)+
                     	coord_equal()
	# Sortie du fichier
  ggsave(tt, file = paste(repsortie,nomfichier,".png",sep=""), width = 7, height = 7)  
}else{}

if(length(variablecarto)>1){

# Extraction de toutes les valeurs à cartographier pour établir des classes de valeurs à cartographier
melt.map <- melt(map@data[,variablecarto])[,2]
 
cpt <- 0
p <- list()

for(i in variablecarto){
  cpt <- cpt + 1
 
  if(style_classe=="fixed"){
    niveaux <- levels(factor(melt.map))
    carto <- merge(cartofor, map@data[,c("id_geofla",i)], by.x="id", by.y="id_geofla")
  	colnames(carto)[8] <- "fill"
  	carto$fill <- as.factor(carto$fill)

    # Définition de la couleur
    myColors <- brewer.pal(length(niveaux),couleur)
    names(myColors) <- levels(factor(melt.map))
    colScale <- scale_fill_manual(name=l_legend,values = myColors)

    }else{
      # Classement
      classe_valeur <- round(classIntervals(melt.map,n=nclasse,style=style_classe,digits=2,na.rm=TRUE)[[2]],1)
  
      # Jointure et changement de nom
      carto <- merge(cartofor, map@data[,c("id_geofla",i)], by.x="id", by.y="id_geofla")
      colnames(carto)[8] <- "fill"
      carto[,"fill"] <- cut(carto[,"fill"] ,breaks = data.frame(classe_valeur)[,1],include.lowest=T)

      # Définition de la couleur
      colScale <- scale_fill_brewer(palette = couleur,name=l_legend)
      }

    # Création de la carte
    p[[i]] <- ggplot(carto, aes(x=long, y=lat)) +
              geom_polygon(data=carto, aes(group=group, fill=fill),size=0.1) +
              geom_path(data=carto, aes(x=long,y=lat,group=group),color="white",size=0.1)+# Représente les cantons
              geom_path(data=cartodep, aes(x=long,y=lat,group=group),color="black",size=0.1)+# Représente les contours des départements
              colScale+
              theme(plot.title = element_text(size=10,face="bold"),
                    text = element_text(size=10),
                    axis.text =element_blank(),# change the theme options
                    axis.title =element_blank(),# remove axis titles
                    axis.ticks =element_blank())+
              coord_equal()+
              labs(title=i)
	}#fin boucle 

tt <- do.call(grid_arrange_shared_legend,c(p,list(nrow=nrowlayout,ncol=ncollayout,position=position)))
#save(tt,file="tt.RData")

ggsave(tt, file = paste(repsortie,nomfichier,".png",sep=""),width = ggsavewidth, height = ggsaveheight)  

}else{}

}#Fin de la fonction
