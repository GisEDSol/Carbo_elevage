#!/bin/bash
# /**
# *
# * @title rtomosaicgeoserver()
# * @author Jean-Baptiste Paroissien
# * @description Fonction pour convertir la base de données PostgreSQL vers PostGIS
# * @params $EPSG Code EPSG (pour lambert 93, 2154)
# * @params $workspace Nom du workspace (si il n'existe pas, il sera créé)
# * @keywords PostGis,
# * @examples
# * @return 0 if successfull.
# * This is a test.
# */

# Configuration
sudo apt-get update 
sudo apt-get install libsqlite3-dev libproj-dev libgeos-dev

# Client pour sqlite
sudo add-apt-repository -y ppa:linuxgndu/sqlitebrowser
sudo apt-get update
sudo apt-get install sqlitebrowser

# Vérification (selon http://gis.stackexchange.com/questions/168819/fixing-ogr2ogr-without-spatialite-support)
ogrinfo --formats sqlite | grep 'spatialite' -i
ogrinfo --format sqlite | grep 'spatialite' -i

# Ok, fonctionne mais avec des problèmes sur le nom des schéma. Il n'y a pas non plus les commentaires sur les champs. Bof bof pour une
# exploitation optimale. Il faudra également regarder comment connecter la base avec R.

#
ogr2ogr --config PG_LIST_ALL_TABLES YES --config PG_SKIP_VIEWS YES -f "SQLite" mydb.sqlite -progress PG:"dbname='sol_elevage' \
host='localhost' port='5432' user='jb' password='170284'" -lco LAUNDER=yes \
  -dsco SPATIALITE=yes -lco SPATIAL_INDEX=yes -gt 65536

# Voir une procédure pgdump et importation d'une base vers un serveur local...?

