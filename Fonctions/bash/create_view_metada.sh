#!/bin/bash

psql -U jb -d sol_elevage -c "
CREATE OR REPLACE VIEW metadata AS
SELECT
 schema_name,
 table_name,
 column_name,
 comment
FROM
(
         SELECT n.nspname AS schema_name,
            c.relname AS table_name,
            a.attname AS column_name,
            col_description(c.oid, a.attnum::integer) AS comment
           FROM pg_class c
      JOIN pg_attribute a ON a.attrelid = c.oid
   JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE NOT n.nspname ~~ 'pg\_%'::text AND NOT n.nspname =
'information_schema'::name AND NOT a.attisdropped AND a.attnum > 0 AND
c.relkind = 'r'::\"char\"
UNION ALL
         SELECT n.nspname AS schema_name,
            c.relname AS table_name,
            '<table>'::name AS column_name,
            obj_description(c.oid) AS comment
           FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE NOT n.nspname ~~ 'pg\_%'::text AND NOT n.nspname =
'information_schema'::name AND c.relkind = 'r'::\"char\"
  ORDER BY 1, 2, 3
) AS ss;"
