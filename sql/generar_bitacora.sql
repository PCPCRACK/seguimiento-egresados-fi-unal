-- =====================================================================
-- generar_bitacora.sql
-- Genera 05_bitacora.sql: los disparadores que registran en la bitácora
-- cada inserción, modificación y borrado de las 37 tablas que no son
-- bitácoras. Modelo de datos, paso 3.6.
-- =====================================================================
--
-- Por qué generarlos: son 109 disparadores casi iguales. Escritos a mano
-- es fácil olvidar una columna, y si una tabla cambia basta con volver a
-- generarlos. La consulta lee el catálogo de columnas de MariaDB
-- (information_schema), así que las tablas deben existir.
--
-- Uso, desde la carpeta del repositorio (PowerShell):
--   & "C:\Program Files\MariaDB 12.3\bin\mariadb.exe" -u root -p -N -r -B `
--     -e "source sql/generar_bitacora.sql" | Out-File -Encoding ascii sql/05_bitacora.sql
--
-- Reglas que aplica (paso 3.6):
--   * Usuario: SESSION_USER() sin el equipo. No CURRENT_USER(), que dentro
--     de un disparador devuelve la cuenta dueña del disparador.
--   * Ejecución y motivo: los copia de @id_ejecucion y @motivo. La fila
--     de una ejecución se registra a nombre de sí misma: cuando un proceso
--     empieza, todavía no hay otra ejecución que lo respalde.
--   * No copia el valor de perfil.url ni de los datos observados de
--     coincidencia: escribe '[omitido]'. Esos datos se borran por
--     conservación limitada; si la bitácora los copiara, no se borrarían.
--   * egresado y perfil no tienen disparador de borrado: solo se borran
--     en la supresión, cuya constancia es la solicitud de supresión.
--   * id_egresado: se toma de la fila, o de su captura o coincidencia,
--     para que la supresión borre también este rastro.

SET SESSION group_concat_max_len = 1048576;

WITH
tablas AS (
  SELECT t.TABLE_SCHEMA AS esquema, t.TABLE_NAME AS tabla
    FROM information_schema.TABLES t
   WHERE t.TABLE_SCHEMA IN ('egresados', 'egresados_identidad')
     AND t.TABLE_TYPE = 'BASE TABLE'
     AND t.TABLE_NAME NOT IN ('bitacora', 'bitacora_identidad')
),
columnas AS (
  SELECT c.TABLE_SCHEMA AS esquema, c.TABLE_NAME AS tabla,
         GROUP_CONCAT(
           CONCAT('''', c.COLUMN_NAME, ''', ',
                  IF(CONCAT(c.TABLE_NAME, '.', c.COLUMN_NAME) IN (
                       'perfil.url',
                       'coincidencia.nombre_observado', 'coincidencia.programa_observado',
                       'coincidencia.anio_inicio_observado', 'coincidencia.anio_fin_observado',
                       'coincidencia.ciudad_observada'),
                     CONCAT('IF({R}.', c.COLUMN_NAME, ' IS NULL, NULL, ''[omitido]'')'),
                     CONCAT('{R}.', c.COLUMN_NAME)))
           ORDER BY c.ORDINAL_POSITION SEPARATOR ', ') AS pares,
         MAX(c.COLUMN_NAME = 'id_egresado') AS tiene_egresado,
         MAX(c.COLUMN_NAME = 'id_captura') AS tiene_captura,
         MAX(c.COLUMN_NAME = 'id_coincidencia') AS tiene_coincidencia
    FROM information_schema.COLUMNS c
    JOIN tablas t ON t.esquema = c.TABLE_SCHEMA AND t.tabla = c.TABLE_NAME
   WHERE c.IS_GENERATED = 'NEVER'
   GROUP BY c.TABLE_SCHEMA, c.TABLE_NAME
),
llaves AS (
  SELECT s.TABLE_SCHEMA AS esquema, s.TABLE_NAME AS tabla,
         GROUP_CONCAT(CONCAT('{R}.', s.COLUMN_NAME) ORDER BY s.SEQ_IN_INDEX SEPARATOR ', ') AS pk
    FROM information_schema.STATISTICS s
    JOIN tablas t ON t.esquema = s.TABLE_SCHEMA AND t.tabla = s.TABLE_NAME
   WHERE s.INDEX_NAME = 'PRIMARY'
   GROUP BY s.TABLE_SCHEMA, s.TABLE_NAME
),
operaciones AS (
  SELECT 1 AS n, 'INSERT' AS op, 'ai' AS suf, 'NEW' AS fila
  UNION ALL SELECT 2, 'UPDATE', 'au', 'NEW'
  UNION ALL SELECT 3, 'DELETE', 'ad', 'OLD'
),
definiciones AS (
  SELECT c.esquema, c.tabla, o.n, o.op, o.suf, o.fila, c.pares, l.pk,
         CASE
           WHEN c.tiene_egresado = 1 THEN '{R}.id_egresado'
           WHEN c.tiene_captura = 1 THEN
             '(SELECT x.id_egresado FROM egresados.captura x WHERE x.id_captura = {R}.id_captura)'
           WHEN c.tiene_coincidencia = 1 THEN
             '(SELECT x.id_egresado FROM egresados_identidad.coincidencia x WHERE x.id_coincidencia = {R}.id_coincidencia)'
           WHEN c.tabla = 'perfil' THEN
             '(SELECT x.id_egresado FROM egresados_identidad.coincidencia x WHERE x.id_perfil = {R}.id_perfil AND x.estado = ''ACEPTADA'')'
           ELSE 'NULL'
         END AS expr_egresado,
         IF(c.esquema = 'egresados', 'egresados.bitacora', 'egresados_identidad.bitacora_identidad') AS destino
    FROM columnas c
    JOIN llaves l ON l.esquema = c.esquema AND l.tabla = c.tabla
   CROSS JOIN operaciones o
   WHERE NOT (o.op = 'DELETE' AND c.tabla IN ('egresado', 'perfil'))
)
SELECT texto FROM (
  SELECT '' AS esquema, '' AS tabla, 0 AS n, 0 AS paso,
         CONCAT('-- =====================================================================\n',
                '-- 05_bitacora.sql\n',
                '-- GENERADO por sql/generar_bitacora.sql. No editar a mano: si cambia una\n',
                '-- tabla, se vuelve a generar. Disparadores de bitacora: ', COUNT(*), '.\n',
                '-- =====================================================================\n\n',
                'SET NAMES utf8mb4;\n') AS texto
    FROM definiciones
  UNION ALL
  SELECT esquema, tabla, n, 1,
         CONCAT('\nDROP TRIGGER IF EXISTS ', esquema, '.trg_', tabla, '_bitacora_', suf, ';')
    FROM definiciones
  UNION ALL
  SELECT esquema, tabla, n, 2,
         CONCAT('CREATE DEFINER = ''definidor_egresados''@''localhost'' TRIGGER ',
                esquema, '.trg_', tabla, '_bitacora_', suf, '\n',
                'AFTER ', op, ' ON ', esquema, '.', tabla, ' FOR EACH ROW\n',
                'INSERT INTO ', destino,
                ' (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)\n',
                'VALUES (''', tabla, ''', CONCAT_WS('','', ', REPLACE(pk, '{R}', fila), '), ',
                REPLACE(expr_egresado, '{R}', fila), ', ''', op, ''',\n',
                '  ', IF(op = 'INSERT', 'NULL', CONCAT('JSON_OBJECT(', REPLACE(pares, '{R}', 'OLD'), ')')), ',\n',
                '  ', IF(op = 'DELETE', 'NULL', CONCAT('JSON_OBJECT(', REPLACE(pares, '{R}', 'NEW'), ')')), ',\n',
                '  SUBSTRING_INDEX(SESSION_USER(), ''@'', 1), ',
                IF(tabla = 'ejecucion', CONCAT(fila, '.id_ejecucion'), '@id_ejecucion'),
                ', @motivo, NOW());')
    FROM definiciones
) x
ORDER BY esquema, tabla, n, paso;
