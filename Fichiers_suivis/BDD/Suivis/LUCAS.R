# Importation des données LUCAS
require(xtable)
require(ggplot2)
require(RColorBrewer)
require(gridExtra)
require(caret)
require(pander)
require(gbm)
require(plyr)
require(raster)
require(foreign)
require(gdata)
require(spatstat)	
require(spdep)
#
options(digits = 2)
require(spgrass6)
initGRASS(gisBase = "/usr/lib/grass64", home = tempdir(), 
          gisDbase = "/home/jb/InfoSol/Data/DataSig",
          location = "France", mapset = "Centre",
          override = TRUE)

# Lecture du fichier
lucastable <- read.csv("/home/jb/InfoSol/Data/Spatiale/Lucas/LUCAS_TOPSOIL_v1.csv",sep=";")
sqlSave(loc,lucastable)

#Création d'un id
sqlQuery(loc,paste("
alter table lucastable
add id integer;
create sequence bdatgeoref_seq;
update lucastable set id = nextval('bdatgeoref_seq');
drop sequence bdatgeoref_seq",sep=""))

#Intégration dans Grass:

#Configuration
require(spgrass6)
require(fields)
require(geoR)
initGRASS(gisBase = "/usr/lib/grass64", home = tempdir(), 
             gisDbase = "/home/jb/InfoSol/Data/DataSig",
             location = "WGS84", mapset = "Centre",
             override = TRUE)

#Géoréférencement
system("v.in.db table=lucastable x=GPS_LONG y=GPS_LAT output=lucasref key=id --overwrite")
sqlQuery(loc,"drop table lucas")

initGRASS(gisBase = "/usr/lib/grass64", home = tempdir(), 
          gisDbase = "/home/jb/InfoSol/Data/DataSig",
          location = "France", mapset = "Centre",
          override = TRUE)


system("v.proj --overwrite input=lucasref2 location=WGS84 mapset=Centre output=lucas")
system("v.select --overwrite ainput=lucas_france atype=point binput=communes_centre output=lucas_centre")
# Ajout des coordonnées géographique
system("v.db.addcol map=lucas_centre columns=\"x double precision, y double precision\"")
system("v.to.db map=lucas_centre opt=coor columns=\"x,y\"")


system("g.remove vect=lucasref2")



################################################
#Pour l'ajout des données CAPRI
################################################
#Téléchargement de la donnée
system("wget -c http://epp.eurostat.ec.europa.eu/portal/page/portal/lucas/documents/FR_p.CSV")
#Déplacement
system("mv FR_p.CSV /home/jb/InfoSol/Data/Spatiale/Lucas/FR_p.csv")
tablecaprilucas <- read.table("/home/jb/InfoSol/Data/Spatiale/Lucas/FR_p.csv",sep=",",header=TRUE)
sqlSave(loc,tablecaprilucas)

#Création d'un id
sqlQuery(loc,"
alter table tablecaprilucas
add id integer;
create sequence bdatgeoref_seq;
update tablecaprilucas set id = nextval('bdatgeoref_seq');
drop sequence bdatgeoref_seq
"
)

#Configuration
require(spgrass6)
require(fields)
require(geoR)
initGRASS(gisBase = "/usr/lib/grass64", home = tempdir(), 
             gisDbase = "/home/jb/InfoSol/Data/DataSig",
             location = "Europe", mapset = "France",
             override = TRUE)

#Géoréférencement
system("v.in.db table=caprilucas x=x_laea y=y_laea output=caprilucasref key=id --overwrite")

initGRASS(gisBase = "/usr/lib/grass64", home = tempdir(), 
             gisDbase = "/home/jb/InfoSol/Data/DataSig",
             location = "France", mapset = "Centre",
             override = TRUE)

system("v.proj --overwrite input=caprilucasref location=Europe mapset=France output=caprilucas")

# Jointure pour l'attribution des classes d'occupation du sol

columnname <- c("lc1","lu1")
keycol <- "point_id"
updatetable <- "lucas_france"
tableref <- "caprilucas"

for(i in columnname){
	print(i)

	print(sqlQuery(loc,paste("alter table ",updatetable,"
			   drop column if exists ",i,sep="")))
	
	print(sqlQuery(loc,paste("alter table ",updatetable,"
			   add ",i," character varying",sep="")))

	print(sqlQuery(loc,paste("update ",updatetable,"
			   set ",i," = bibi.",i," from(
					select ",tableref,".",i,",",tableref,".",keycol,"
					from ",tableref,") as bibi
					where ",updatetable,".",keycol,"::numeric=bibi.",keycol,"::numeric",sep="")))
}

# Modification de la nomenclature des classes d'occupation du sol (plus de détails, consulter l'annexe 2 et 3
#http://epp.eurostat.ec.europa.eu/portal/page/portal/lucas/documents/

#sqlQuery(loc,paste("alter table ",updatetable,"
#		   drop column if exists occ1;
#		   alter table ",updatetable,"
#		   add occ1 integer;
#		   update ",updatetable," set occ1=2 --arable land
#		   where lc1 like 'B1%'
#		   or lc1 like 'B2%'
#		   or lc1 like 'B3%'
#		   or lc1 like 'B4%'
#		   or lc1 like 'B5%'
#		   or lc1 like 'B6%'
#		   or lc1 like 'F00';",sep=""))

#sqlQuery(loc,paste("update ",updatetable," set occ1=3 --permanent crop
#		   where lc1 like 'B7%'
#		   or lc1 like 'B8%'",sep=""))

#sqlQuery(loc,paste("update ",updatetable," set occ1=4 --grassland
#		   where lc1 like 'D%'
#		   or lc1 like 'E%';",sep=""))

#sqlQuery(loc,paste("update ",updatetable," set occ1=5 --woodland
#		   where lc1 like 'C%'",sep=""))



