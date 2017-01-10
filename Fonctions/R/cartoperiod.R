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

#'cartoperiod(dsn,tablecarto,period,variable,nclasse=5,couleur="YlGnBu",l_legend,repsortie,nomfichier,dept=FALSE,reg=FALSE)

cartoperiod <- function(
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
       reg
       )
{

library(rgdal);library(ggplot2);library(maptools);library(reshape2);library(classInt);
library(gridExtra);library(RPostgreSQL);library(stringr)

# Fonction pour gérer la légende 
g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))# + theme(legend.position="bottom")
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
return(legend)
}

# Fonction pour effectuer une requête sql avant d'importer un postgis (https://geospatial.commons.gc.cuny.edu/2013/12/31/subsetting-in-readogr/)
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
  strCreateView = paste("CREATE VIEW vw_tmp_read_ogr AS", sql)
  dbSendQuery(conn, strCreateView)
  temp = readOGR(dsn = dsn, layer = "vw_tmp_read_ogr", ...)
  dbSendQuery(conn, "DROP VIEW vw_tmp_read_ogr;")
  dbDisconnect(conn)
  return(temp)
}

##############################
# Lecture du postgis selon plusieurs conditions

if((is.character(dept)==FALSE) & (is.character(reg)==FALSE)){
  map <- readOGR(dsn = dsn, tablecarto)
  #map <- map[complete.cases(map@data[variablecarto]),]
  dep <- readOGR(dsn = dsn, "dm_vecteurs.departement")
  }else{}

if(is.character(dept)==TRUE){
  # Sélection de la zone d'étude
  #print(paste("Sélection département(s) ",dept,sep=""))

  strSQL <- paste("select * 
                   from ",tablecarto,"
                   where code_dept similar to '",dept,"'",sep="")

  map <- readOgrSql(dsn, strSQL, stringsAsFactors=FALSE)
  #map <- map[complete.cases(map@data[variablecarto]),]

  depSQL <- paste("select * 
                   from dm_vecteurs.departement
                   where code_dept similar to '",dept,"'",sep="")
  dep <- readOgrSql(dsn, depSQL, stringsAsFactors=FALSE)
  }else{}
  
if(reg!=FALSE){# Sélection de la zone d'étude
  #print(paste("Sélection région(s) ",reg,sep=""))

  strSQL <- paste("select * 
                   from ",tablecarto,"
                   where code_reg similar to '",reg,"'",sep="")

  map <- readOgrSql(dsn, strSQL, stringsAsFactors=FALSE)
  #map <- map[complete.cases(map@data[variablecarto]),]

  regSQL <- paste("select * 
                   from dm_vecteurs.departement
                   where code_reg similar to '",reg,"'",sep="")
  dep <- readOgrSql(dsn, regSQL, stringsAsFactors=FALSE)
  }else{}
  
# Conversion des spatialdataframe pour la cartographie sous ggpplot2
gpclibPermit()
cartodep <- fortify(dep,region="id_geofla")
cartofor <- fortify(map, region="id_geofla")

# Représentation cartographique

if(length(variablecarto)==1){
  # Extraction de toutes les valeurs à cartographier pour établir des classes de valeurs à cartographier
  melt.map <- melt(map@data[,variablecarto])[,1]

  if(style_classe=="fixed"){
  	#print(paste("Classe par ",style_classe,sep=""))
	# Jointure et changement de nom
  	carto <- merge(cartofor, map@data[,c("id_geofla",variablecarto)], by.x="id", by.y="id_geofla")
  	colnames(carto)[8] <- "fill"
  	carto$fill <- as.factor(carto$fill)

	tt <- ggplot(carto, aes(x=long, y=lat)) +
    	                geom_polygon(data=carto, aes(group=group, fill=fill),size=0.1) +
                      	geom_path(data=carto, aes(x=long,y=lat,group=group),color="white",size=0.1)+# Représenter les cantons
                      	geom_path(data=cartodep, aes(x=long,y=lat,group=group),color="black",size=0.1)+# Représenter les contours des départements
                    	scale_fill_brewer(type=qual,palette = couleur,name=l_legend,guide = guide_legend(reverse=TRUE,nrow=1))+theme(legend.position="bottom")+
                      	theme(plot.title = element_text(size=14,face="bold"),
                            	text = element_text(size=12),
                            	axis.text =element_blank(),# change the theme options
                            	axis.title =element_blank(),# remove axis titles
                            	axis.ticks =element_blank())+
                      	#guides(fill=FALSE)+
                      	coord_equal()
	}else{

	#	print(paste("Classe par ",style_classe,sep=""))
		classe_valeur <- classIntervals(melt.map,n=nclasse,style=style_classe,digits=2,na.rm=TRUE)[[2]]

		# Jointure et changement de nom
  		carto <- merge(cartofor, map@data[,c("id_geofla",variablecarto)], by.x="id", by.y="id_geofla")
  		colnames(carto)[8] <- "fill"

  		carto[,"fill"] <- cut(carto[,"fill"] ,breaks = data.frame(classe_valeur)[,1],include.lowest=T)  

  		tt <- ggplot(carto, aes(x=long, y=lat)) +
                     geom_polygon(data=carto, aes(group=group, fill=fill),size=0.1) +
                     geom_path(data=carto, aes(x=long,y=lat,group=group),color="white",size=0.1)+# Représenter les cantons
                     geom_path(data=cartodep, aes(x=long,y=lat,group=group),color="black",size=0.1)+# Représenter les contours des départements
                     scale_fill_brewer(palette = couleur,name=l_legend,guide = guide_legend(reverse=TRUE,nrow=1))+theme(legend.position="bottom")+
                     theme(plot.title = element_text(size=14,face="bold"),
                           text = element_text(size=12),
                           axis.text =element_blank(),# change the theme options
                           axis.title =element_blank(),# remove axis titles
                           axis.ticks =element_blank())+
                     #guides(fill=FALSE)+
                     coord_equal()
    }
  
  # Sortie du fichier
  ggsave(tt, file = paste(repsortie,nomfichier,".png",sep=""), width = 7, height = 7)  
}else{}

# Voir pour cartographier en fonction du nombre de carte?
if(length(variablecarto)>1){

# Extraction de toutes les valeurs à cartographier pour établir des classes de valeurs à cartographier
melt.map <- melt(map@data[,variablecarto])[,2]

# Classement (voir pour round)
classe_valeur <- classIntervals(melt.map,n=nclasse,style=style_classe,digits=2,na.rm=TRUE)[[2]]

cpt <- 0
p <- list()
for(i in variablecarto){#CHANGER CETTE VARIABLE
  cpt <- cpt + 1
 
  # Jointure et changement de nom
  carto <- merge(cartofor, map@data[,c("id_geofla",i)], by.x="id", by.y="id_geofla")
  colnames(carto)[8] <- "fill"

    if(cpt==1){
      # Extraction de la légende (en horizontal)
      carto[,"fill"] <- cut(carto[,"fill"] ,breaks = data.frame(classe_valeur)[,1],include.lowest=T)  
      p1 <- ggplot(carto, aes(x=long, y=lat)) +  geom_polygon(data=carto, aes(group=group, fill=fill)) + scale_fill_brewer(palette = couleur,name=l_legend,guide = guide_legend(reverse=FALSE,nrow=1))+theme(legend.position="bottom")#+guides(colour = guide_legend(nrow = 1))
      plotLegend = g_legend(p1)  
    }else{
      carto[,"fill"] <- cut(carto[,"fill"] ,breaks = data.frame(classe_valeur)[,1],include.lowest=T)  
    }

    # Création de la carte
    p[[i]] <- ggplot(carto, aes(x=long, y=lat)) +
              geom_polygon(data=carto, aes(group=group, fill=fill),size=0.1) +
              geom_path(data=carto, aes(x=long,y=lat,group=group),color="white",size=0.1)+# Représenter les cantons
              geom_path(data=cartodep, aes(x=long,y=lat,group=group),color="black",size=0.1)+# Représenter les contours des départements
              scale_fill_brewer(palette = couleur,name=l_legend,guide = guide_legend(reverse=FALSE))+
              theme(plot.title = element_text(size=14,face="bold"),
                    text = element_text(size=12),
                    axis.text =element_blank(),# change the theme options
                    axis.title =element_blank(),# remove axis titles
                    axis.ticks =element_blank())+
              guides(fill=FALSE)+
              coord_equal()+
              labs(title=i)
}

lwidth = sum(plotLegend$width)

if(length(variablecarto)=="4"){
  combinedPlots <- arrangeGrob(p[[1]],p[[2]],p[[3]],p[[4]],nrow=2)
  tt <- grid.arrange(combinedPlots,plotLegend,nrow=2,heights=c(10, 1))
  }else{}

if(length(variablecarto)=="5"){

  combinedPlots <- arrangeGrob(p[[1]],p[[2]],p[[3]],p[[4]],p[[5]],nrow=3)
  tt <- grid.arrange(combinedPlots,plotLegend,ncol=1,heights=c(10, 1))

  }else{}
res <- 10
ggsave(tt, file = paste(repsortie,nomfichier,".png",sep=""), width = res, height = res)  

}else{}

return(tt)

}#Fin
