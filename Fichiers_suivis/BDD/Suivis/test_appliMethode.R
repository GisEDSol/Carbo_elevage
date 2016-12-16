
required = c('rgdal', 'rgeos','sp','raster','maptools','ggplot2') 
installed = required %in% installed.packages()[, 'Package']
if (length(required[!installed]) >=1) {
  install.packages(required[!installed])
}

library(rgdal)
library(rgeos)
library(sp)
library(raster)
library(maptools)
library(ggplot2)
# Fonction très pratique pour remplacer une suite de charactères par une autre
gsub2 <- function(pattern, replacement, x, ...) {
  for(i in 1:length(pattern))
    x <- gsub(pattern[i], replacement[i], x, ...)
  x
}

rep_shapefiles <- "X:/SOCLE/Travaux/Litho_QES_France/trunk/shapefiles/029/"
# Lecture des différents fichiers nécessaire
finistere <- readOGR(paste(rep_shapefiles,"GEO050K_HARM_029_S_FGEOL_CGH_2154.shp",sep=""), layer="GEO050K_HARM_029_S_FGEOL_CGH_2154",encoding = "LATIN1")

# Sélection des colonnes d'intérêt en lien avec la lithologie
attribut_litho <- c("DESCR","LITHOLOGIE","LITHOTEC","LITHO_COM","AGE_DEB")
crit <- c("DESCR","LITHOLOGIE","LITHOTEC","LITHO_COM","AGE_DEB")

geol_litho <- data.frame(lapply(finistere@data[,attribut_litho], function(v) tolower(as.character((v)))))


# Création des classes (en expression régulière) selon Robert Wyns
list_litho <- c("leptynites","amphibolite","quartzites","porphyroïdes","paragneiss","micaschiste","orthogneiss","diorite","granite","granodiorite","olivine")

# Création de plusieurs colonnes
for(i in list_litho){
  temp <- subset(geol_litho, grepl(i, DESCR))
  geol_litho[geol_litho$FID %in% temp$FID,i] <- i
}

# Regroupement dans une même colonne
df2 <- apply(geol_litho[,list_litho],1,function(x) x[!is.na(x)])
df3 <- data.frame(t(df2))
colnames(df3) <- colnames(df)[1:ncol(df3)]






###Nouveaux tests avec la table de robert (cf. courriel du 13/11/15)
rep_shapefiles <- "X:/SOCLE/Travaux/Litho_QES_France/trunk/tab/"
tab_geol <- read.csv(paste(rep_shapefiles,"formation_geologique_FINAL.csv",sep=""),header=TRUE,sep=";",encoding="LATIN1",stringsAsFactors = FALSE,dec=",")
colnames(tab_geol) <- c("MI_PRINX","CARTE","NOTATION","DESCRIPTION","DESCRIPTION_MINERALO","COMMENTAIRE","DESCRIPTION_PCD","ALTERABILITE")

# Conversion en minuscule de toutes les colonnes
tab_geol$DESCRIPTION <- as.character(tab_geol$DESCRIPTION)
tab_geol$DESCRIPTION_MINERALO <- as.character(tab_geol$DESCRIPTION_MINERALO)
tab_geol$COMMENTAIRE <- as.character(tab_geol$COMMENTAIRE)
tab_geol$DESCRIPTION_PCD <- as.character(tab_geol$DESCRIPTION_PCD)
tab_geol$ALTERABILITE <- as.numeric(tab_geol$ALTERABILITE)

tab_geol <- data.frame(lapply(tab_geol, function(v) {
  if (is.character(v)) return(tolower(v))
  else return(v)
}))

# Création des classes (en expression régulière) selon Robert Wyns
list_litho <- c("leptynites","amphibolite","quartzites","porphyroïdes","paragneiss","micaschiste","orthogneiss","diorite","granite","granodiorite","olivine")

class1 <- c("rhyolites","microgranites")
class2 <- c("amphibolites","amphibolites","metabasaltes","metabasaltes","corneennes","epimetamorphiques")%muscovite seule
class3 <- c("granites","micaschistes","gneiss a deux micas")
class4 <- c("gneiss a biotite","monzogranites a biotite","granites a biotite")
class5 <- c("diorites","diorites quartziques","diorites granodiorites","gabbros a pyroxene","gabbros")

# Création de plusieurs colonnes
for(i in list_litho){
  temp <- subset(geol_litho, grepl(i, DESCR))
  geol_litho[geol_litho$FID %in% temp$FID,i] <- i
}

# Regroupement dans une même colonne
df2 <- apply(geol_litho[,list_litho],1,function(x) x[!is.na(x)])
df3 <- data.frame(t(df2))
colnames(df3) <- colnames(df)[1:ncol(df3)]


cbind.data.frame(a=geol_litho$test, mycol = rowSums(geol_litho[,list_litho], na.rm = TRUE))

Formation sédimentaire post-silurienne et formation filonienne
Leptynites
Amphibolite
Quartzites
Porphyroïdes
Formation gréso-pélitique
Formation schisto-carbonatée
Formation schisto-gréseuse
Formations schisto-gréso-carbonatées
Formations schisto-argileuse
Paragneiss
Micaschiste
Orthogneiss
Diorite 
Granite
Granodiorite
Formation Carbonatée ante-Silurienne (altération karstique)


# Lecture de la table attributaire du shapefiles
BV_geol <- read.dbf(paste(rep_shapefiles,"BV_geol.dbf",sep=""))



BV_geol <- readOGR(paste(rep_shapefiles,"BV_geol.shp",sep=""),layer="BV_geol")#Long! enregistrer une RData pour gagner du temps
save(BV_geol)



bv_qes <- readOGR(paste(rep_shapefiles,"BV_sj_qes.shp",sep=""),layer="BV_sj_qes")
plot(bv_qes)


for(i in depunique){
  print(i)
  nom_carte <- paste("GEO050K_HARM_0",i,"_S_FGEOL_CGH_2154",sep="")
  rep_carte <- paste("T:/GEOLOGIE/FR/050K/HARM/0",i,"/VECTEURS/ARCGIS/EPSG_2154/",sep="")
  geolvar <- paste("geol_",i,sep="")
  
  test_lecture <- try(readOGR(dsn=paste(rep_carte,nom_carte,".shp",sep=""),layer=nom_carte),silent = TRUE)
  
  if(class(test_lecture)[1] == "try-error"){
    print("problème")
    next
  }
  #assign(geolvar,readOGR(dsn=paste(rep_carte,nom_carte,".shp",sep=""),layer=nom_carte))
  #geol_temp <- get(geolvar)
  
  # Création d'une variable temporaire geol_temp (la couche géol)
  geol_temp <- readOGR(dsn=paste(rep_carte,nom_carte,".shp",sep=""),layer=nom_carte)
  
  from <- levels(geol_temp@data$LITHOLOGIE)
  to <- 1:length(from)
  
  class_convertion <- as.data.frame(cbind(gsub2(from, to, geol_temp@data$LITHOLOGIE),geol_temp@data$MI_PRINX))
  names(class_convertion) <- c("Lithologie_class","MI_PRINX")
  
  geol_temp <- merge(geol_temp,class_convertion, by.x="MI_PRINX", by.y="MI_PRINX",all.x=TRUE,all.y=TRUE)
  
  # Conversion du vecteur en rasteur pour plusieurs attribut
  #geolattribut <- "LITHOLOGIE_class"
  
  r <- raster(extent(geol_temp))
  res(r)=500
  r <- rasterize(geol_temp,field="Lithologie_class",r)
  
  # Extract raster values to polygons                             
  v <- extract(r, BV_LBmerge)
  
  # Get class counts for each polygon
  v.counts <- lapply(v,table)
  
  # Calculate class percentages for each polygon
  v.pct <- lapply(v.counts, FUN=function(x){(x/sum(x))*100} )
  
  # Create a data.frame where missing classes are NA
  class.df <- as.data.frame(t(sapply(v.pct,'[',1:length(unique(r)))))
  
  # Replace NA's with 0 and add names
  class.df[is.na(class.df)] <- 0  
  names(class.df) <- paste(gsub2(to,from,unique(r)),sep="")
  
  # Add back to polygon data
  BV_LBmerge@data <- data.frame(BV_LBmerge@data, class.df)
  
  # Suppression...
  rm(r,v,test_lecture,geol_temp)
  gc()
}
