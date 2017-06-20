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
#' @param title titre de la figure
#' @param caption sous titre de la figure (en bas de la légende)
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
       title,
       caption,
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
library(gridExtra);library(RPostgreSQL);library(stringr);library(rgeos);
#options(scipen=999)

###############################################################
# Ensembles des fonctions utiles à la construction des cartes. 
# Développé en partie par https://timogrossenbacher.ch/2016/12/beautiful-thematic-maps-with-ggplot2-only/
###############################################################

# Fonction pour l'échelle
scale_map <- function(...){
scale_fill_manual(
  name=l_legend,
  values = myColors,
  #na.value="black",  
  guide = guide_legend(
  direction = "horizontal",
  keyheight = unit(4, units = "mm"),
  keywidth = unit(10 / length(labels), units = "mm"),
  #title.position = 'top',
  # I shift the labels around, the should be placed 
  # exactly at the right end of each legend key
  title.hjust = 0.5, # 0.5 pour centrer
  label.hjust = 0.5, # 0.5 pour centrer
  nrow = nombrerow,
  byrow = T,
  # also the guide needs to be reversed
  reverse = F,
  label.position = "bottom"
   )
  )
}

# Fonction pour les titres
labs_map <- function(...){
  labs(x = NULL, 
       y = NULL, 
       title = title, 
       #subtitle = subtitle, 
       caption = caption)  
}

# Fonction pour le thème général
theme_map <- function(...) {
  theme_minimal() +
  theme(
    text = element_text(family = "Ubuntu Regular", color = "#22211d"),
    axis.line = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    # panel.grid.minor = element_line(color = "#ebebe5", size = 0.2),
    panel.grid.major = element_line(color = "#f5f5f2", size = 0),#Couleur de la grille. Initialement (#ebebe5)
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#f5f5f2", color = NA), 
    panel.background = element_rect(fill = "#f5f5f2", color = NA), 
    legend.background = element_rect(fill = "#f5f5f2", color = NA),
    panel.border = element_blank(),
    ...
  )
}

# Fonction complémentaire sur la position de la légende
theme_map3 <- function(...) {
    theme(
      legend.position = c(0.5, 0.03),
      legend.text.align = 0,
      legend.background = element_rect(fill = alpha('white', 0.0)),
      legend.text = element_text(size = 8, hjust = 0, color = "#4e4d47"),
      plot.title = element_text(hjust = 0.5, color = "#4e4d47"),
      plot.subtitle = element_text(hjust = 0.5, color = "#4e4d47", 
                                   margin = margin(b = 0, #-0.1
                                                   t = -0.1, 
                                                   l = 0,#2 
                                                   unit = "cm"), 
                                   debug = F),
      legend.title = element_text(size = 9),
      #plot.margin = unit(c(0,0,0,0), "cm"),#margin around entire plot (unit with the sizes of the top, right, bottom, and left margins) 
      #panel.spacing = unit(c(-.1,0.2,.2,0.2), "cm"),
      panel.border = element_blank(),
      plot.caption = element_text(size = 7, 
                                  hjust = 0.92, 
                                  margin = margin(t = 0.2, 
                                                  b = 0, 
                                                  unit = "cm"), 
                                  color = "#939184")
      )
}

# Fonction en cours...
extendLegendWithExtremes <- function(p){
  library(gtable)
  p_grob <- ggplotGrob(p)
  legend <- gtable_filter(p_grob, "guide-box")
  legend_grobs <- legend$grobs[[1]]$grobs[[1]]
  # grab the first key of legend
  legend_first_key <- gtable_filter(legend_grobs, "key-3-1-1")
  legend_first_key$widths <- unit(2, units = "cm")
  # modify its width and x properties to make it longer
  legend_first_key$grobs[[1]]$width <- unit(2, units = "cm")
  legend_first_key$grobs[[1]]$x <- unit(0.15, units = "cm")

  # last key of legend
  legend_last_key <- gtable_filter(legend_grobs, "key-3-6-1")
  legend_last_key$widths <- unit(2, units = "cm")
  # analogous
  legend_last_key$grobs[[1]]$width <- unit(2, units = "cm")
  legend_last_key$grobs[[1]]$x <- unit(1.02, units = "cm")

  # grab the last label so we can also shift its position
  legend_last_label <- gtable_filter(legend_grobs, "label-5-6")
  legend_last_label$grobs[[1]]$x <- unit(2, units = "cm")

  # Insert new color legend back into the combined legend
  legend_grobs$grobs[legend_grobs$layout$name == "key-3-1-1"][[1]] <- 
    legend_first_key$grobs[[1]]
  legend_grobs$grobs[legend_grobs$layout$name == "key-3-6-1"][[1]] <- 
    legend_last_key$grobs[[1]]
  legend_grobs$grobs[legend_grobs$layout$name == "label-5-6"][[1]] <- 
    legend_last_label$grobs[[1]]

  # finally, I need to create a new label for the minimum value 
  new_first_label <- legend_last_label$grobs[[1]]
  new_first_label$label <- round(min(map_data$avg_age_15, na.rm = T), 2)
  new_first_label$x <- unit(-0.15, units = "cm")
  new_first_label$hjust <- 1

  legend_grobs <- gtable_add_grob(legend_grobs, 
                                  new_first_label, 
                                  t = 6, 
                                  l = 2, 
                                  name = "label-5-0", 
                                  clip = "off")
  legend$grobs[[1]]$grobs[1][[1]] <- legend_grobs
  p_grob$grobs[p_grob$layout$name == "guide-box"][[1]] <- legend

  # the plot is now drawn using this grid function
  grid.newpage()
  grid.draw(p_grob)
}
##############################

# Lecture du postgis selon plusieurs conditions
id <- "id_geofla"

schema <- "dm_vecteurs"
table <- gsub2(".*\\.", "", unlist(tablecarto))

if((is.character(dept)==FALSE) & (is.character(reg)==FALSE)){
  map <- dbReadSpatial(con, schemaname=schema, tablename=table, geomcol="geom")
  dep <- dbReadSpatial(con, schemaname=schema, tablename="zonage_simple", geomcol="geom")
#  dep <- dbReadSpatial(con, schemaname=schema, tablename="departement", geomcol="geom")

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
#cartodep <- fortify(dep,region=id)
cartodep <- fortify(dep,region="zonage_simple")

# Représentation cartographique
if(length(variablecarto)==1){
  cartofor <- fortify(map[complete.cases(map@data[variablecarto]),],region=id)

  # Extraction de toutes les valeurs à cartographier pour établir des classes de valeurs à cartographier
  melt.map <- melt(map@data[,variablecarto])[,1]

if(style_classe=="fixed"){
    classe_valeur <- levels(factor(melt.map))
    carto <- merge(cartofor, map@data[,c(id,variablecarto)], by.x="id", by.y=id)    
    colnames(carto)[8] <- "fill"
    carto$fill <- as.factor(carto$fill)

    myColors <- couleur
    names(myColors) <- levels(factor(melt.map))
    
    }else{
      classe_valeur <- round(classIntervals(melt.map,n=nclasse,style=style_classe,digits=2,na.rm=TRUE)[[2]],1)
      #classe_valeur <- format(classe_valeur, scientific=FALSE)

      # Jointure et changement de nom
      carto <- merge(cartofor, map@data[,c(id,variablecarto)], by.x="id", by.y=id)
      colnames(carto)[8] <- "fill"
      carto[,"fill"] <- cut(carto[,"fill"] ,breaks = data.frame(classe_valeur)[,1],include.lowest=T,dig.lab=10)#dig.lab pour supprimer l'annotation scientifique

      myColors <- couleur
       }
  
  if(length(classe_valeur)<=6){
      nombrerow=1
      }else if(length(classe_valeur)>6 & length(classe_valeur)<10){
        nombrerow=2
        }else if(length(classe_valeur)>=10){
          nombrerow=3
        }

  colScale <- scale_map(l_legend,myColors,nombrerow)
  applilabs <- labs_map(title,caption)
	tt <- ggplot(carto, aes(x=long, y=lat)) +
    	                geom_polygon(data=carto, aes(group=group, fill=fill),size=0.1,na.rm=TRUE) +
                     	geom_path(data=carto, aes(x=long,y=lat,group=group),color="white",size=0.1)+# Représenter les cantons
                     	geom_path(data=cartodep, aes(x=long,y=lat,group=group),color="black",size=0.1)+# Représenter les contours des départements
                      colScale +
                      theme(legend.position="bottom")+
                     	theme_map() +
                      theme_map3() +
                      coord_equal() + 
                      applilabs

	# Sortie du fichier
  #tt <- extendLegendWithExtremes(tt)
  ggsave(tt, file = paste(repsortie,nomfichier,".png",sep=""), width = 7, height = 7)  
}else{}

if(length(variablecarto)>1){
cartofor <- fortify(map,region=id)

# Extraction de toutes les valeurs à cartographier pour établir des classes de valeurs à cartographier
melt.map <- melt(map@data[complete.cases(map@data[variablecarto]),variablecarto])[,2]
 
cpt <- 0
p <- list()

for(i in variablecarto){
  cpt <- cpt + 1
 
  if(style_classe=="fixed"){
    classe_valeur <- levels(factor(melt.map))
    carto <- merge(cartofor, map@data[,c("id_geofla",i)], by.x="id", by.y="id_geofla")
  	colnames(carto)[8] <- "fill"
  	carto$fill <- as.factor(carto$fill)

    myColors <- couleur
    names(myColors) <- levels(factor(melt.map))

    }else{
      # Classement
      classe_valeur <- round(classIntervals(melt.map,n=nclasse,style=style_classe,digits=2,na.rm=TRUE)[[2]],1)
     # classe_valeur <- format(classe_valeur, scientific=FALSE)

      # Jointure et changement de nom
      carto <- merge(cartofor, map@data[,c("id_geofla",i)], by.x="id", by.y="id_geofla")
      colnames(carto)[8] <- "fill"
      carto[,"fill"] <- cut(carto[,"fill"] ,breaks = data.frame(classe_valeur)[,1],include.lowest=T,dig.lab=10)
      }
      myColors <- couleur

    if(length(classe_valeur)<=6){
      nombrerow=1
      }else if(length(classe_valeur)>6 & length(classe_valeur)<10){
        nombrerow=2
        }else if(length(classe_valeur)>=10){
          nombrerow=3
    }

    colScale <- scale_map(l_legend,myColors,nombrerow)
    applilabs <- labs_map(title[cpt],caption)
    applilabs$title <- title[cpt]
    # Création de la carte
    p[[i]] <- ggplot(carto[complete.cases(carto$fill),], aes(x=long, y=lat)) +
              geom_polygon(data=carto[complete.cases(carto$fill),], aes(group=group, fill=fill),size=0.1,na.rm = TRUE) +
              geom_path(data=carto, aes(x=long,y=lat,group=group),color="white",size=0.1)+# Représente les cantons
              geom_path(data=cartodep, aes(x=long,y=lat,group=group),color="black",size=0.1)+# Représente les contours des départements
              colScale +
              theme(legend.position = "bottom") +
              theme_map() +
              theme_map3() +
              coord_equal()+
              applilabs
   # p[[i]] <- extendLegendWithExtremes(p)
	}#fin boucle 
tt <- do.call(grid_arrange_shared_legend,c(p,list(nrow=nrowlayout,ncol=ncollayout,position=position)))
#save(tt,file="tt.RData")

ggsave(tt, file = paste(repsortie,nomfichier,".png",sep=""),width = ggsavewidth, height = ggsaveheight)  

}else{}

}#Fin de la fonction
