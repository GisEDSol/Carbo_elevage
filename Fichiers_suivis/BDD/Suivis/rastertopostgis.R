#' @title rastertopostgis
#'
#' @description Constuit un raster pyramidal et importe les pyramides dans une base de données PostGis. La fonction crée  les fichiers de configuration permettant d'assurer la connexion entre un Geoserver et la base de données PostGis.
#'
#' @param nomraster Nom du raster à importer dans PostGis. Pour le moment, la fonction utilise uniquement des extension .tif a vector of non-negative numerical quantities.
#' @param repertoire Chemin du répertoire de travail où se situe le raster à importer. Format : "/XXX/XXX/"
#' @param paramconnexion Paramètres de connexion pour JDBC. Le nom de l'utilisateur, le mot de passe, le serveur, le port et la base de données (bd) doivent être renseignés selon le format suivant :
#'	c("utilisateur","motdepasse","serveur:port/","bd")
#' @param nom_couverture Nom de la couverture pour Geoserver
#' @param nomtable Nom de la table à créer
#' @param EPSG Code EPSG (pour lambert 93, 2154)
#'
#' @author Jean-Baptiste Paroissien
#' @keywords PostGis,
#' @seealso \code{\link{pie}} 
#' @export
#' @examples
#' ## Ne fonctionne pas 
#' rastertopostgis("test.tif","/home/user/data",c("user","toto","localhost:5432","gis"),cover,test,5432) 

rastertopostgis <- function(nomraster,
			 repertoire,
			 paramconnexion,
			 nomcouverture,
			 nomtable,
			 EPSG
			 )
{

# Configuration du répertoire
setwd(repertoire)

# Info sur le raster
inforaster <- system(paste("gdalinfo ",nomraster,".tif",sep=""),intern=T)

# Extraction des caractéristiques du raster
sizepixel <- regmatches(inforaster[3],gregexpr('[0-9]+',inforaster[3]))[[1]]
nbrpyra <- round(log(as.numeric(sizepixel[1]))/log(2) - log(512)/log(2))

# Création du répertoire de travail bmpyramid
system("mkdir bmpyramid")

# Création du fichier wld 
origin <- as.numeric(regmatches(inforaster[13],gregexpr('[0-9]+.[0-9]+',inforaster[13]))[[1]])
pixelsize <- as.numeric(regmatches(inforaster[14],gregexpr('[0-9]+.[0-9]+',inforaster[14]))[[1]])
# Création du wld
system(paste("echo \'",pixelsize[1],"
0.00000000
0.00000000
",pixelsize[2],"
",origin[1],"
",origin[2],"
\' >> ",nomraster,".wld",sep=""))

# Création des pyramides
system(paste("gdal_retile.py -co \"WORLDFILE=YES\" -r bilinear -ps 512 512 -of tif -levels ",nbrpyra," -targetDir bmpyramid ",nomraster,".tif",sep=""))

# Préparation des fichiers de configurations
system("mkdir configpostgis")

# Configuration de la connexion
system(paste("echo \'<connect>
  <!-- value DBCP or JNDI -->
  <dstype value=\"DBCP\"/>
  <!--   <jndiReferenceName value=\"\"/>  -->
  <username value=\"",paramconnexion[1],"\" />
  <password value=\"",paramconnexion[2],"\" />
  <jdbcUrl value=\"jdbc:postgresql://",paramconnexion[3],paramconnexion[4],"\" />
  <driverClassName value=\"org.postgresql.Driver\"/>
  <maxActive value=\"10\"/>
  <maxIdle value=\"0\"/>
</connect>\' >> ",repertoire,"configpostgis/connect.postgis.xml.inc",sep=""))


# Configuration du masterraster

system(paste("echo \'<!-- possible values: universal,postgis,db2,mysql,oracle -->
<spatialExtension name=\"postgis\"/>
<mapping>
    <masterTable name=\"",nomtable,"\" >
      <coverageNameAttribute name=\"name\"/>
      <maxXAttribute name=\"maxX\"/>
      <maxYAttribute name=\"maxY\"/>
      <minXAttribute name=\"minX\"/>
      <minYAttribute name=\"minY\"/>
      <resXAttribute name=\"resX\"/>
      <resYAttribute name=\"resY\"/>
      <tileTableNameAtribute  name=\"TileTable\" />
      <spatialTableNameAtribute name=\"SpatialTable\" />
    </masterTable>
    <tileTable>
      <blobAttributeName name=\"data\" />
      <keyAttributeName name=\"location\" />
    </tileTable>
    <spatialTable>
      <keyAttributeName name=\"location\" />
      <geomAttributeName name=\"geom\" />
      <tileMaxXAttribute name=\"maxX\"/>
      <tileMaxYAttribute name=\"maxY\"/>
      <tileMinXAttribute name=\"minX\"/>
      <tileMinYAttribute name=\"minY\"/>
    </spatialTable>
</mapping>\' >> ",repertoire,"configpostgis/mapping.postgis.xml.inc",sep=""))

# Configuration fichier final
system(paste("echo \'<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<!DOCTYPE ImageMosaicJDBCConfig [
  <!ENTITY mapping PUBLIC \"mapping\"  \"mapping.postgis.xml.inc\">
  <!ENTITY connect PUBLIC \"connect\"  \"connect.postgis.xml.inc\">]>
<config version=\"1.0\">
  <coverageName name=\"",nomcouverture,"\"/>
  <coordsys name=\"EPSG:",EPSG,"\"/>
  <!-- interpolation 1 = nearest neighbour, 2 = bilinear, 3 = bicubic -->
  <scaleop  interpolation=\"1\"/>
  <verify cardinality=\"false\"/>
  &mapping;
  &connect;
</config>\' >> ",repertoire,"configpostgis/osm.postgis.xml",sep=""))

# Création des scripts d'intégration
system("mkdir sqlscripts")
system(paste("java -jar /usr/share/opengeo/geoserver/WEB-INF/lib/gt-imagemosaic-jdbc-10.3.jar ddl -config ",repertoire,"configpostgis/osm.postgis.xml -spatialTNPrefix tilefire -pyramids ",nbrpyra," -statementDelim \";\" -srs ",EPSG," -targetDir sqlscripts",sep=""))

# Exécution des scripts sql
system(paste("psql -U ",paramconnexion[1]," -d ",paramconnexion[4],"  -f ",repertoire,"createmeta.sql",sep=""))
system(paste("psql -U ",paramconnexion[1]," -d ",paramconnexion[4],"  -f ",repertoire,"sqlscripts/add_",nomcouverture,".sql",sep=""))

# Importation 
system(paste("java -jar /usr/share/opengeo/geoserver/WEB-INF/lib/gt-imagemosaic-jdbc-10.3.jar import -config ",repertoire,"/configpostgis/osm.postgis.xml -spatialTNPrefix tile",nomcouverture," -tileTNPrefix tile",nomcouverture," -dir bmpyramid -ext tif",sep=""))
}



