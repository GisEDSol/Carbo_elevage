#' @title cartoperiod
#'
#' @description Construit une cartographie d'une variable d'un postgis vecteur
#'
#' @param dsn Paramètre de connexion vers la base de données
#' @param tablecarto Nom de la table utilisée pour la cartographie (table postgis)
#' @param variablecarto Nom de la variable à cartographier
#' @param nclasse Nombre de classes de valeurs pour la cartographie
#' @param style_classe 
#' @param couleur Nom de la palette couleur (selon RColorBrewer)display.brewer.all() pour connaître les différentes palettes
#' @param l_legend Nom pour la légende
#' @param repsortie
#' @param nomfichier Répertoire de sortie pour le fichier (XXX/XXX/)
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
tablecarto <- "dm_vecteurs.canton" 
dsn <- "PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'" 
period <- c("9094","9599","0004","0509") #
variable <- "corgox_med"
couleur <- "YlGnBu" 
l_legend <- "Teneur en carbone organique (g/kg)" #label de la variable
nomfichier <- "test"
repsortie <- "/media/sf_GIS_ED/Dev/Scripts/master/Fichiers_suivis/Traitements/Fichiers/"

#'carto(dsn,tablecarto,period,variable,nclasse=5,couleur="YlGnBu",l_legend,repsortie,nomfichier,dept=FALSE,reg=FALSE,nrowlayout=2,ncollayout=3,position="right")

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

# Fonction pour partager une même légende pour plusieurs plots (https://github.com/tidyverse/ggplot2/wiki/Share-a-legend-between-two-ggplot2-graphs)
# http://stackoverflow.com/questions/13649473/add-a-common-legend-for-combined-ggplots
grid_arrange_shared_legend <- function(..., nrow = 1, ncol = length(list(...)), position = c("bottom", "right")) {

  plots <- list(...)
  position <- match.arg(position)
  g <- ggplotGrob(plots[[1]] + theme(legend.position = position))$grobs
  legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
  lheight <- sum(legend$height)
  lwidth <- sum(legend$width)
  gl <- lapply(plots, function(x) x + theme(legend.position = "none"))
  gl <- c(gl, nrow = nrow, ncol = ncol)

  combined <- switch(position,
                     "bottom" = arrangeGrob(do.call(arrangeGrob, gl),
                                            legend,
                                            ncol = 1,
                                            heights = unit.c(unit(1, "npc") - lheight, lheight)),
                     "right" = arrangeGrob(do.call(arrangeGrob, gl),
                                           legend,
                                           ncol = 2,
                                           widths = unit.c(unit(1, "npc") - lwidth, lwidth)))
  grid.newpage()
  grid.draw(combined)
  return(combined)
}

# Fonction pour effectuer une requête sql avant d'importer un postgis (selon https://geospatial.commons.gc.cuny.edu/2013/12/31/subsetting-in-readogr/)
readOgrSql = function (dsn, sql, ...) {
   # check dsn starts "PG:" and strip
  if (str_sub(dsn, 1, 3) != "PG:") {
    stop("readOgrSql only works with PostgreSQL DSNs")
  }
  dsnParamList = str_trim(str_split(dsn, ":")[[1]][2])

  # Build dbConnect expression, quote DSN parameter values 
  # if not already quoted
  if (str_count(dsnParamList, "=") 
      == str_count(dsnParamList, "='[[:alnum:]]+'")) {
    strExpression = str_c(
      "dbConnect(dbDriver('PostgreSQL'), ", 
      str_replace_all(dsnParamList, " ", ", "), 
      ")"
      )
  }
  else {
    dsnArgs = word(str_split(dsnParamList, " ")[[1]], 1, sep="=")
    dsnVals = sapply(
      word(str_split(dsnParamList, " ")[[1]], 2, sep="="), 
      function(x) str_c("'", str_replace_all(x, "'", ""), "'")
      )
    strExpression = str_c(
      "dbConnect(dbDriver('PostgreSQL'), ", 
      str_c(dsnArgs, "=", dsnVals, collapse=", "), 
      ")"
      )
  }

  # Connect, create spatial view, read spatial view, drop spatial view
  conn = eval(parse(text=strExpression))
  print(dbSendQuery(conn, "DROP VIEW if exists vw_tmp_read_ogr;"))
  strCreateView = paste("CREATE VIEW vw_tmp_read_ogr AS", sql)
  dbSendQuery(conn, strCreateView)
  temp = readOGR(dsn = dsn, layer = "vw_tmp_read_ogr", ...)
  print(dbDisconnect(conn))
  return(temp)
}

##############################
# Lecture du postgis selon plusieurs conditions
id <- "id_geofla"

if((is.character(dept)==FALSE) & (is.character(reg)==FALSE)){
 # map <- readOGR(dsn = dsn, tablecarto)
 # dep <- readOGR(dsn = dsn, "dm_vecteurs.departement")

#save(map,file=paste(repsortie,"map.RData",sep=""))
#save(dep,file=paste(repsortie,"dep.RData",sep=""))

load(paste(repsortie,"map.RData",sep=""))
load(paste(repsortie,"dep.RData",sep=""))

#  variablecartobis <- paste(variablecarto,collapse=",")
  #strSQL <- paste("SELECT ",id,",",variablecartobis,",ST_AsText(geom) AS geom from ",tablecarto,sep="")
  #rs = dbSendQuery(con,strSQL)
  #df = fetch(rs,n=-1)
  #dfTemp = dbGetQuery(con,strSQL)
  #row.names(dfTemp) = dfTemp[,id]

#for(i in seq(nrow(dfTemp))){
  #print(i)
  #if(i == 1){
  #  spTemp <- readWKT(dfTemp$geom[i], dfTemp$id_geofla[i])
  #}else{
    #spTemp <- rbind(spTemp, readWKT(dfTemp$geom[i], dfTemp$id_geofla[i]))
    #}
  #}

  #map <- SpatialPolygonsDataFrame(spTemp, dfTemp[-(length(variablecarto)+2)])

#  variablecartobis <- paste(variablecarto,collapse=",")
 # strSQL <- paste("SELECT ",id,",ST_AsText(geom) AS geom",sep="")
#  rs = dbSendQuery(con,strSQL)
#  df = fetch(rs,n=-1)
  #dfTemp = dbGetQuery(con,strSQL)
  #row.names(dfTemp) = dfTemp[,id]

#  for(i in seq(nrow(dfTemp))){
    #if(i == 1){
    #  spTemp <- readWKT(dfTemp$geom[i], dfTemp$id_geofla[i])
    #}
  #else{
    #spTemp <- rbind(spTemp, readWKT(dfTemp$geom[i], dfTemp$id_geofla[i]))
    #}
  #}
  
  #dep <- SpatialPolygonsDataFrame(spTemp, dfTemp[-2])
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
  #map <- readOgrSql(dsn, strSQL, stringsAsFactors=FALSE)
  #map <- map[complete.cases(map@data[variablecarto]),]

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

  #depSQL <- paste("select * 
                   #from dm_vecteurs.departement
                   #where code_dept similar to '",dept,"'",sep="")
  #dep <- readOgrSql(dsn, depSQL, stringsAsFactors=FALSE)
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
# strSQL <- paste("select * 
 #                  from ",tablecarto,"
  #                 where code_reg similar to '",reg,"'",sep="")

  #map <- readOgrSql(dsn, strSQL, stringsAsFactors=FALSE)
  #map <- map[complete.cases(map@data[variablecarto]),]

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
  #regSQL <- paste("select * 
                   #from dm_vecteurs.departement
                   #where code_reg similar to '",reg,"'",sep="")
#  dep <- readOgrSql(dsn, regSQL, stringsAsFactors=FALSE)
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

#return(tt)

}#Fin
