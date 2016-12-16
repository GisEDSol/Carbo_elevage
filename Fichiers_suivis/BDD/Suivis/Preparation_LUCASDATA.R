# Description: Script pour importer les données LUCAS à l'échelle de la France dans la base dela
# Version : The LUCAS Topsoil Database version 1.0
# O/S: any
# Date: 08/11/2013
# Auteur: Paroissien Jean-Baptiste

#### Création d'un shapefile et PostGis de la base LUCAS et reprojection vers du lambert2étendue et Lambert93 ####

# Intégration dans grass de la base LUCAS_TOPSOIL_v1.zip (source : http://eusoils.jrc.ec.europa.eu/projects/Lucas/data/index.cfm)

# Décompression de l'archive
system("unzip LUCAS_TOPSOIL_v1.zip -d.")

# Conversion vers un fichier csv
library(gdata)
installXLSXsupport()
Lucasdf <- read.xls("/home/jb/InfoSol/Data/Spatiale/Lucas/LUCAS_TOPSOIL_v1.xlsx",sheet="Sheet1")
Lucasdf <- Lucasdf[complete.cases(Lucasdf[,c("GPS_LAT","GPS_LONG")]),]
# Enregistrement dans une base locale
sqlSave(loc,Lucasdf)

#Création d'un id pour l'intégration dans GRASS
sqlQuery(loc,"
alter table lucasdf
add id integer;
create sequence _seq;
update lucasdf set id = nextval('_seq');
drop sequence _seq")

# Vers GRASS
require(spgrass6)
require(fields)
require(geoR)
initGRASS(gisBase = "/usr/lib/grass64", home = tempdir(), 
             gisDbase = "/home/jb/InfoSol/Data/DataSig",
             location = "WGS84", mapset = "Centre",
             override = TRUE)

system("v.in.db table=lucasdf x=GPS_LONG y=GPS_LAT output=lucasref key=id --overwrite")
sqlQuery(loc,"drop table Lucasdf")

# Reprojection vers L2E
#initGRASS(gisBase = "/usr/lib/grass64", home = tempdir(), 
 #            gisDbase = "/home/jb/InfoSol/Data/DataSig",
  #           location = "France", mapset = "Centre",
   #          override = TRUE)

#system("v.proj --overwrite input=lucasref location=WGS84 mapset=Centre output=lucasref_L2E")
# Sélection spatiale des points LUCAS en France
#system("v.select --overwrite ainput=lucasref_L2E atype=point binput=france output=lucasref_L2E_fr")

# Exportation vers un shapefile
#system("v.out.ogr input=lucasref_L2E_fr type=point dsn=lucasref_L2E_fr.shp")

# Exportation vers PostGis
#sqlQuery(databaracoa,"drop table if exists data.lucastopsoil_L2E_fr")
#system("shp2pgsql -c -s 27582 lucasref_L2E_fr.shp data.lucastopsoil_L2E_fr | psql -h baracoa.orleans.inra.fr -p 5434 -U jbparoissien jbparoissien")

# Reprojection vers Lambert93
initGRASS(gisBase = "/usr/lib/grass64", home = tempdir(), 
             gisDbase = "/home/jb/InfoSol/Data/DataSig",
             location = "FranceL93", mapset = "Centre",
             override = TRUE)

system("v.proj --overwrite input=lucasref location=WGS84 mapset=Centre output=lucasref_L93")
system("v.proj --overwrite input=france location=France mapset=Centre output=franceL93")

# Sélection spatiale des points LUCAS en France
system("v.select --overwrite ainput=lucasref_L93 atype=point binput=franceL93 output=lucasref_L93_fr")

# Exportation vers un shapefile
system("v.out.ogr input=lucasref_L93_fr type=point dsn=/home/jb/Bureau/PrLucas/")
# Exportation vers PostGis
sqlQuery(databaracoa,"drop table if exists data.lucastopsoil_fr")
system("shp2pgsql -c -s 2154 /home/jb/Bureau/PrLucas/lucasref_L93_fr.shp data.lucastopsoil_fr| psql -h baracoa.orleans.inra.fr -p 5434 -U jbparoissien jbparoissien")

# Préparation finale
#Ajout d'une colonne geom pour le système de coodonnées lambert2etendue

# Reprojection de la table en lambert9
# Ajout des colonnes

sqlQuery(databaracoa,paste("select addgeometrycolumn('data','lucastopsoil_fr', 'the_geom_l2e',27582,'POINT',2)",sep=""))
sqlQuery(databaracoa,paste("select addgeometrycolumn('data','lucastopsoil_fr', 'the_geom_l93',2154,'POINT',2)",sep=""))
sqlQuery(databaracoa,paste("update lucastopsoil_fr set the_geom_l93 = geom",sep=""))
sqlQuery(databaracoa,paste("select DropGeometryColumn('data','lucastopsoil_fr','geom')",sep=""))

# Reprojection
sqlQuery(databaracoa,paste("update lucastopsoil_fr set the_geom_l2e = st_setsrid(st_transform(st_setsrid(the_geom_l93,2154),27582),27582);",sep=""))

# Pour connaître les coordonnées géographiques
sqlQuery(databaracoa,"alter table lucastopsoil_fr
	 add column x_l93 double precision;
	 alter table lucastopsoil_fr
	 add column y_l93 double precision;
	 alter table lucastopsoil_fr
	 add column x_l2e double precision;
 	 alter table lucastopsoil_fr
	 add column y_l2e double precision;")


sqlQuery(databaracoa,"update lucastopsoil_fr set x_l93 = ST_X(ST_SetSRID(the_geom_l93, 2154));
	 update lucastopsoil_fr set y_l93 = ST_Y(ST_SetSRID(the_geom_l93, 2154));")

sqlQuery(databaracoa,"update lucastopsoil_fr set x_l2e = ST_X(ST_SetSRID(the_geom_l2e, 27582));
	 update lucastopsoil_fr set y_l2e = ST_Y(ST_SetSRID(the_geom_l2e, 27582));")

#########################################################################################################

#### Intégration données d'occupation du sol pour les points lucas ####

# Téléchargement
system("wget http://epp.eurostat.ec.europa.eu/portal/page/portal/lucas/documents/FR_2009.csv")

# Intégration dans une base de données locale
lulcdata <- read.table("FR_2009.csv",header=TRUE,sep=",")
sqlSave(databaracoa,lulcdata)

#
# Métadonnées pour la table LUCAS points >> LULCdata
#
LULCdata <- "lulcdata"

sqlQuery(databaracoa,"COMMENT on TABLE lulcdata IS \'Table présentant les données d''occupation du sol et autres descriptions des points lucas\'")
for(i in LULCdata){
	print(sqlQuery(databaracoa,paste("
	COMMENT ON COLUMN ",i,".POINT_ID IS \'Identifiant unique du point LUCAS.\';
	COMMENT ON COLUMN ",i,".X_LAEA IS \'Latitude du point théorique (LAEA).\';
	COMMENT ON COLUMN ",i,".Y_LAEA IS \'Longitude du point théorique (LAEA).\';
	COMMENT ON COLUMN ",i,".STRATA IS \'N° de la strate assignée par photointerprétation (1=Terre arable
2 Culture permanente 3 Prairie 4 Forêt et garrigues 5 Terrain nu 6 Zone artificiel 7 Eau).\';
	COMMENT ON COLUMN ",i,".NUTS0 IS \'Niveau 0 de la classification NUTS.\';
	COMMENT ON COLUMN ",i,".NUTS1 IS \'Niveau 1 de la classification NUTS.\';
	COMMENT ON COLUMN ",i,".NUTS2 IS \'Niveau 2 de la classification NUTS.\';
	COMMENT ON COLUMN ",i,".AREA2 IS \'Surface de NUTS2 (km2).\';
	comment on column ",i,".wh is \'Proportion de la strate (entre 0 et 1, la somme entre les 7 strates est égale à 1).\';
	comment on column ",i,".peso_f2 is \'Proportion de la seconde phase d''échantillonage (supérieur ou égale à 1).\';
	comment on column ",i,".surv_date is \'Date de l''enquête (jj/mm/aa).\';
	comment on column ",i,".observed is \'Observation du point (1=point observé; 2=point non visible; 3=point dans la mer; 4=point en dehors du territoire national).\';
	comment on column ",i,".obs_type is \'Type d''observation (1=sur site - point visible à une distance inférieur à 100m; 2=sur site - point visible à une distance supérieur à 100m; 3= photo interprétation depuis un point non visible; 4= point non interrogé; 5= photo interprétation dans le bureau).\';
	comment on column ",i,".gps_proj is \'Système de projection (wgs84).\';
	comment on column ",i,".gps_prec is \'Précision du gps (m).\';
	comment on column ",i,".gps_y_lat is \'Coordonnées latitudinales.\';
	comment on column ",i,".gps_ew is \'Est/ouest.\';
	comment on column ",i,".gps_x_long is \'Coordonnées longitudinales.\';
	comment on column ",i,".y_lat is \'Latitude théorique.\';
	comment on column ",i,".ew is \'Est/ouest théorique.\';
	comment on column ",i,".x_long is \'Longitude théorique.\';
	comment on column ",i,".obs_dist is \'Distance du point (m).\';
	comment on column ",i,".obs_direct is \'Direction de l''observation (1=sur le point; 2= direction vers le nord; 3= direction vers l''est; 8=non relevé).\';
	comment on column ",i,".lc1 is \'Couverture du sol 1 (voir table lucas_lc_code).\';
	comment on column ",i,".lc2 is \'Couverture du sol 2 (voir table lucas_lc_code).\';
	comment on column ",i,".obs_radius is \'Radius d''observation (1= 1.5m; 2=20m).\';
	comment on column ",i,".lu1 is \'Occupation du sol 1 (voir table lucas_lu_code).\';
	comment on column ",i,".lu2 is \'Occupation du sol 2 (voir table lucas_lu_code).\';
	comment on column ",i,".lc1_species is \'Espèce végétale lc1.\';
	comment on column ",i,".lc1_percent is \'Pourcentage de couverture de lc1 (1=moins de 10%; 2=entre 10% et 25%; 3=entre 25% et 50%; 4=entre 50% et 75%; 5=plus de 75%).\';
	comment on column ",i,".lc2_species is \'Espèce végétale lc2.\';
	comment on column ",i,".lc2_percent is \'Pourcentage de couverture de lc2 (1=moins de 10%; 2=entre 10% et 25%; 3=entre 25% et 50%; 4=entre 50% et 75%; 5=plus de 75%).\';
	comment on column ",i,".area_size is \'Surface du site (1=moins de 0.5ha; 2=entre 0.5 et 1ha; 3=entre 1 et 10ha; 4=plus de 10ha).\';
	comment on column ",i,".trees_height is \'Hauteur des arbres (1=moins de 5m; 2=plus de 5m).\';
	comment on column ",i,".features_width is \'Amplitude des arbres (1=moins de 20m;1=plus de 20m).\';
	comment on column ",i,".land_mngt is \'Gestion de la parcelle (1=paturage; 2=non paturage; 8=non observé).\';
	comment on column ",i,".wm_water_mngt is \'Gestion de l''eau (1=irrigation; 2=potentiel irrigation; 3=drainage; 4= irrigation et drainage; 5=non visible; 8=non observé).\';
	comment on column ",i,".wm_src_irrigation is \'Source de l''irrigation (1=source; 2=bassin/lac/réservoir; 3=ruisseau,canal,fossé; 4=lagon,eaux uséeswastewater; 5=autres; 8=non observé).\'",sep="")))
}


for(i in LULCdata){
	print(sqlQuery(databaracoa,paste("
	COMMENT ON COLUMN ",i,".wm_typ_irrigation IS \'Type d''irrigation (1=gravité; 2=pression: arrosage automatique; 3=pression: micro-irrigation; 4=gravité/pression; 5=autres; 8=non observé).\';
	COMMENT ON COLUMN ",i,".wm_delivery_syst IS \'Acheminement du système d''irrigation (1=canal; 2=fossé; 3=canalisation; 4=autres; 8=non observé).\';
	COMMENT ON COLUMN ",i,".soil_survey IS \'Présence d''un échantillon de sol (1=échantillon de sol prélevé; 2=échantillon de sol non prélevé; 3=point qui n''est pas dans l''échantillonage de sol).\';
	COMMENT ON COLUMN ",i,".soil_plough IS \'Signe de labour (1=oui; 2=non; 8=non observé).\';
	COMMENT ON COLUMN ",i,".soil_crop IS \'Pourcentage de résidus de cultures (1=moins de 10%; 2=entre 10 et 25%; 3=entre 25% et 50%; 4=plus de 50%; 8=non observé).\';
	COMMENT ON COLUMN ",i,".soil_stones IS \'Pourcentage d''éléments grossiers (1=moins de 10%; 2=entre 10 et 25%; 3=entre 25% et 50%; 4=plus de 50%; 8=non observé).\';
	COMMENT ON COLUMN ",i,".soil_label IS \'Numéro de l''étiquette, 9= point dans l''échantillon du sol mais remplacé.\';
	COMMENT ON COLUMN ",i,".photo_point IS \'Photo du point LUCAS.\';
	COMMENT ON COLUMN ",i,".photo_n IS \'Photo Nord 1=prise; 2=non prise; 8=pas pertinent.\';
	COMMENT ON COLUMN ",i,".photo_e IS \'Photo Nord 1=prise; 2=non prise; 8=pas pertinent.\';
	COMMENT ON COLUMN ",i,".photo_s IS \'Photo Nord 1=prise; 2=non prise; 8=pas pertinent.\';
	COMMENT ON COLUMN ",i,".photo_w IS \'Photo Nord 1=prise; 2=non prise; 8=pas pertinent.\'",sep="")))
}

# Jointure vers les donnée LUCAS
typecolumn <- sqlQuery(databaracoa,"select * from lulcdata")
columnselect <- c("observed","obs_type","lc1","lc2","lu1","lu2")
typecolumn <- typecolumn[columnselect]
typecolumn <- lapply(typecolumn,class)

#Jointure 
for(i in columnselect){
	print(sqlQuery(databaracoa,paste("alter table lucastopsoil_fr
			   drop if exists ",i,sep="")))
	
	type <- typecolumn[i][[1]]
	if(type=="character"){
		type <- "character varying"
	}else{}

	print(sqlQuery(databaracoa,paste("alter table lucastopsoil_fr
			   add column ",i," ",type,sep="")))

	print(sqlQuery(databaracoa,paste("update lucastopsoil_fr
			   set ",i,"= bibi.",i,"
			   from(select lulcdata.",i,",point_id
				from lulcdata) as bibi
			   where lucastopsoil_fr.point_id::numeric=bibi.point_id::numeric",sep="")))
}

# Modification de la nomenclature des classes d'occupation du sol (plus de détails, consulter l'annexe 2 et 3 #http://epp.eurostat.ec.europa.eu/portal/page/portal/lucas/documents/) vers une nomenclature plus simple

updatetable <- "lucastopsoil_fr"
sqlQuery(databaracoa,paste("alter table ",updatetable,"
		   drop column if exists occ1;
		   alter table ",updatetable,"
		   add occ1 integer;
		   update ",updatetable," set occ1=2 --arable land
		   where lc1 like 'B1%'
		   or lc1 like 'B2%'
		   or lc1 like 'B3%'
		   or lc1 like 'B4%'
		   or lc1 like 'B5%'
		   or lc1 like 'B6%'
		   or lc1 like 'F00';",sep=""))

sqlQuery(databaracoa,paste("update ",updatetable," set occ1=3 --permanent crop
		   where lc1 like 'B7%'
		   or lc1 like 'B8%'",sep=""))

sqlQuery(databaracoa,paste("update ",updatetable," set occ1=4 --grassland
		   where lc1 like 'D%'
		   or lc1 like 'E%';",sep=""))

sqlQuery(databaracoa,paste("update ",updatetable," set occ1=5 --woodland
		   where lc1 like 'C%'",sep=""))

sqlQuery(databaracoa,paste("update ",updatetable," set occ1=6 --Autre
		   where lc1 like 'A%'
		   or lc1 like 'G%'
   		   or lc1 like 'H%'
		   ",sep=""))

#
# Métadonnées pour la table LUCAS TopSoil Survey >> lucasref_L2E_fr ou lucasref_L93_fr
#

postgistable <- "lucastopsoil_fr"# c("data.lucastopsoil_L93_fr","data.lucastopsoil_L2E_fr")
sqlQuery(databaracoa,paste("COMMENT on TABLE ",postgistable," IS \'Table présentant les résultats d''analyses des échantillons de sols de l''échantillonage LUCAS en france\'",sep=""))

for(i in postgistable){
	print(sqlQuery(databaracoa,paste("	
	COMMENT ON COLUMN ",i,".rownames IS \'Numéro de la colonne.\';
	COMMENT ON COLUMN ",i,".point_id IS \'Identifiant unique du point LUCAS\';
	COMMENT ON COLUMN ",i,".coarse IS \'Pourcentage d''elements grossiers : ISO 11464. 2006 (%).\';
	COMMENT ON COLUMN ",i,".clay IS \'Pourcentage d''argile avec la méthode : ISO 11277. 1998 (%).\';
	COMMENT ON COLUMN ",i,".silt IS \'Pourcentage de limon avec la méthode: ISO 11277. 1998 (%).\';
	COMMENT ON COLUMN ",i,".sand IS \'Pourcentage de sable avec la méthode : ISO 11277. 1998 (%).\';
	COMMENT ON COLUMN ",i,".ph_in_h2o IS \'Résultat d''analyse du pH(eau) avec la méthode : ISO 10390. 1994 (-).\';
	COMMENT ON COLUMN ",i,".ph_in_cacl IS \'Résultat d''analyse du pH(CaCl2) avec la méthode : ISO 10390. 1994 (-).\';
	COMMENT ON COLUMN ",i,".oc IS \'Résultat d''analyse de la teneur en carbone organique avec la méthode : ISO 10694. 1995 (g/kg).\';
	COMMENT ON COLUMN ",i,".caco3 IS \'Résultat d''analyse du calcaire total avec la méthode : ISO 10693. 1994 (g/kg).\';
	COMMENT ON COLUMN ",i,".n IS \'Résultat d''analyse de l''azote total avec la méthode : ISO 11261. 1995 (g/kg).\';
	COMMENT ON COLUMN ",i,".p IS \'Résultat d''analyse du phosphore total avec la méthode : ISO 11263. 1994 (mg/kg).\';
	COMMENT ON COLUMN ",i,".k IS \'Résultat d''analyse du potassium extractible avec la méthode : USDA, 2004 (mg/kg).\';
	COMMENT ON COLUMN ",i,".cec IS \'Résultat d''analyse de la capacité d''échange cationique avec la méthode : ISO 11260. 1994 (cmol(+)/kg).\';
	COMMENT ON COLUMN ",i,".notes IS \'Observations supplémentaires.\';
	COMMENT ON COLUMN ",i,".sample_id IS \'Identifiant unique de l''échantillons de sol.\';
	COMMENT ON COLUMN ",i,".gps_lat IS \'Coordonnées Latitudinale de l''échantillon de sol (WGS84).\';
	COMMENT ON COLUMN ",i,".gps_long IS \'Coordonnées Longitudinale de l''échantillon de sol (WGS84).\';
	COMMENT ON COLUMN ",i,".id IS \'Identifiant pour l''importation dans GRASS GIS.\';
	COMMENT ON COLUMN ",i,".the_geom_l2e IS \'Géométrie de l''échantilons de sol en lambert 2 étendue.\';
	COMMENT ON COLUMN ",i,".the_geom_l93 IS \'Géométrie de l''échantilons de sol en lambert 93.\';
	COMMENT ON COLUMN ",i,".x_l93 IS \'Abscisse de l''échantillons de sol en Lambert 93.\';
	COMMENT ON COLUMN ",i,".y_l93 IS \'Ordonnée de l''échantillons de sol en Lambert 93.\';
	COMMENT ON COLUMN ",i,".x_l2e IS \'Abscisse de l''échantillons de sol en Lambert 2 étendue.\';
	COMMENT ON COLUMN ",i,".y_l2e IS \'Ordonnée de l''échantillons de sol en Lambert 2 étendue.\';
	COMMENT ON COLUMN ",i,".observed IS \'Observation du point (1=point observé; 2=point non visible; 3=point dans la mer; 4=point en dehors du territoire national).\';
	COMMENT ON COLUMN ",i,".obs_type IS \'Type d''observation (1=sur site - point visible à une distance inférieur à 100m; 2=sur site - point visible à une distance supérieur à 100m; 3= photo interprétation depuis un point non visible; 4= point non interrogé; 5= photo interprétation dans le bureau).\';
	COMMENT ON COLUMN ",i,".lc1 IS \'Couverture du sol 1 (voir table lucas_lc_code).\';
	COMMENT ON COLUMN ",i,".lc2 IS \'Couverture du sol 2 (voir table lucas_lc_code).\';
	COMMENT ON COLUMN ",i,".lu1 IS \'Occupation du sol 1 (voir table lucas_lu_code).\';
	COMMENT ON COLUMN ",i,".lU2 IS \'Occupation du sol 2 (voir table lucas_lu_code).\';
	COMMENT ON COLUMN ",i,".occ1 IS \'Couverture du sol simplifiée provenant de lc1 (2=terres arables; 3=vergers et vignes; 4=prairies; 5=Forêts; 6=Autres).\';
",sep="")))
}


# Création des tables annexes

# Couverture du sol (LC)
system("wget http://epp.eurostat.ec.europa.eu/portal/page/portal/lucas/documents/LUCAS2009_C1-Instructions-Annex2_20090310.xls")
# Le fichier est simplifié pour être introduit dans la base
lucas_lc_code <- read.table("/home/jb/Bureau/PrLucas/LUCAS2009_C1-Instructions-Annex2_20090310.csv",sep=",",header=TRUE)
sqlSave(databaracoa,lucas_lc_code)

sqlQuery(databaracoa,paste("COMMENT on TABLE lucas_lc_code IS \'Table listant les codes utilisés pour décrire la couverture du sol des sites LUCAS\'",sep=""))

i <- "lucas_lc_code"
print(sqlQuery(databaracoa,paste("	
	COMMENT ON COLUMN ",i,".code_lc1 IS \'Code couverture du sol de niveau 1.\';
	COMMENT ON COLUMN ",i,".description_lc1 IS \'Description de code_lc1\';
	COMMENT ON COLUMN ",i,".code_lc2 IS \'Code couverture du sol de niveau 2.\';
	COMMENT ON COLUMN ",i,".description_lc2 IS \'Description de code_lc2.\';
	COMMENT ON COLUMN ",i,".code_lc3 IS \'Code couverture du sol de niveau 2\';
	COMMENT ON COLUMN ",i,".description_lc3 IS \'Description de code_lc3.\'",sep="")))


# Occupation du sol (LU)

system("wget http://epp.eurostat.ec.europa.eu/portal/page/portal/lucas/documents/LUCAS2009_C1-Instructions-Annex3_20090310.xls")
# Le fichier est simplifié pour être introduit dans la base
lucas_lu_code <- read.table("/home/jb/Bureau/PrLucas/LUCAS2009_C1-Instructions-Annex3_20090310.csv",sep=",",header=TRUE)
sqlSave(databaracoa,lucas_lu_code)

sqlQuery(databaracoa,paste("COMMENT on TABLE lucas_lu_code IS \'Table listant les codes utilisés pour décrire l''occupation du sol des sites LUCAS\'",sep=""))
i <- "lucas_lu_code"
print(sqlQuery(databaracoa,paste("	
	COMMENT ON COLUMN ",i,".code_lu1 IS \'Code occupation du sol de niveau 1.\';
	COMMENT ON COLUMN ",i,".description_lu1 IS \'Description de code_lu1\';
	COMMENT ON COLUMN ",i,".code_lu2 IS \'Code occupation du sol de niveau 2.\';
	COMMENT ON COLUMN ",i,".description_lu2 IS \'Description de code_lu2.\';",sep="")))

# Export des tables postgis en shapefiles
# system coordonnées L2e
system("pgsql2shp -f lucastopsoil_fr_l2e -h baracoa.orleans.inra.fr -p 5434 -P ****** -u jbparoissien -g the_geom_l2e jbparoissien \"SELECT * FROM data.lucastopsoil_fr\"")

# system coordonnées Lambert 93
system("pgsql2shp -f lucastopsoil_fr_l93 -h baracoa.orleans.inra.fr -p 5434 -P ***** -u jbparoissien -g the_geom_l93 jbparoissien \"SELECT * FROM data.lucastopsoil_fr\"")


