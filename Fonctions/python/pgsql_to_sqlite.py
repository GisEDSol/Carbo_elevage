#from https://www.jjude.com/pg-to-sqlite/

import sys
import psycopg2
import sqlite3

# create a sqlite db
sqliteConnection = sqlite3.connect("olai.db")
sqliteCursor = sqliteConnection.cursor()
# ref: http://hakanu.net/sql/2015/08/25/sqlite-unicode-string-problem/
sqliteConnection.text_factory = lambda x: unicode(x, 'utf-8', 'ignore')

# connect to postgresql
pgConnectString = "host='localhost' dbname='postgres' user='postgres' password=''"
pgConnection=psycopg2.connect(pgConnectString)
pgCursor = pgConnection.cursor()

# select from the table
pgCursor.execute("SELECT * from entry")
rows = pgCursor.fetchall()

# loop and insert into sqlite
for row in rows:
    sqliteCursor.execute("INSERT INTO ENTRY (id, title ) VALUES (:id, :title)", {"id": row[0], "title": row[1]})
    sqliteConnection.commit()

# close all connections
sqliteConnection.close()
pgConnection.close()
