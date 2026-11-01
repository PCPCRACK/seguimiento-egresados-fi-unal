-- =====================================================================
-- 00_pruebas_motor.sql
-- Pruebas del comportamiento de MariaDB que decidieron el modelo físico
-- (docs/02_modelo_datos.md, paso 3.1). Ejecutadas el 29 de octubre de 2026
-- en MariaDB 12.3.3. No forma parte de la instalación.
--
--   & "C:\Program Files\MariaDB 12.3\bin\mariadb.exe" -u root -p --table --force -e "source sql/00_pruebas_motor.sql"
--
-- Crea dos bases temporales (p3_a y p3_b), hace las pruebas y las borra.
-- Varias pruebas DEBEN dar ERROR: eso es lo que se quiere comprobar.
-- =====================================================================

SET NAMES utf8mb4;
-- p3_b se borra primero porque sus tablas apuntan a p3_a
DROP DATABASE IF EXISTS p3_b;
DROP DATABASE IF EXISTS p3_a;
CREATE DATABASE p3_a CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_spanish_ai_ci;
CREATE DATABASE p3_b CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_spanish_ai_ci;

SELECT 'T0 Zona horaria y usuario de la sesion' AS prueba;
SELECT @@global.time_zone AS zona_global, @@system_time_zone AS zona_sistema,
       NOW() AS ahora, UTC_TIMESTAMP() AS utc,
       SESSION_USER() AS usuario_sesion, SUBSTRING_INDEX(SESSION_USER(), '@', 1) AS solo_usuario;

-- T1: llave foranea entre dos bases, con borrado en cascada
SELECT 'T1 Llave foranea entre bases con cascada (esperado: 1 antes, 0 despues)' AS prueba;
CREATE TABLE p3_a.padre (id INT UNSIGNED PRIMARY KEY) ENGINE=InnoDB;
CREATE TABLE p3_b.hijo (
  id INT UNSIGNED PRIMARY KEY,
  id_padre INT UNSIGNED NOT NULL,
  CONSTRAINT fk_hijo_padre FOREIGN KEY (id_padre) REFERENCES p3_a.padre (id) ON DELETE CASCADE
) ENGINE=InnoDB;
INSERT INTO p3_a.padre VALUES (1);
INSERT INTO p3_b.hijo VALUES (10, 1);
SELECT COUNT(*) AS hijos_antes FROM p3_b.hijo;
DELETE FROM p3_a.padre WHERE id = 1;
SELECT COUNT(*) AS hijos_despues FROM p3_b.hijo;

SELECT 'T1b Hijo sin padre entre bases (esperado: ERROR de llave foranea)' AS prueba;
INSERT INTO p3_b.hijo VALUES (11, 99);

-- T2: CHECK que usa la fecha actual
SELECT 'T2 CHECK con la fecha actual (esperado: ERROR al crear la tabla, o ERROR al insertar 2999)' AS prueba;
CREATE TABLE p3_a.t_fecha (
  anio SMALLINT NOT NULL,
  CONSTRAINT ck_anio_no_futuro CHECK (anio <= YEAR(CURDATE()))
) ENGINE=InnoDB;
INSERT INTO p3_a.t_fecha VALUES (2020);
INSERT INTO p3_a.t_fecha VALUES (2999);
SELECT * FROM p3_a.t_fecha;

-- T3: UNIQUE sobre una columna calculada (un perfil aceptado una sola vez)
SELECT 'T3 UNIQUE sobre columna calculada (esperado: ERROR de duplicado solo en el tercer INSERT)' AS prueba;
CREATE TABLE p3_a.t_coincidencia (
  id INT UNSIGNED PRIMARY KEY,
  id_perfil INT UNSIGNED NOT NULL,
  estado VARCHAR(10) NOT NULL,
  perfil_aceptado INT UNSIGNED AS (IF(estado = 'ACEPTADA', id_perfil, NULL)) VIRTUAL,
  CONSTRAINT uq_perfil_aceptado UNIQUE (perfil_aceptado)
) ENGINE=InnoDB;
INSERT INTO p3_a.t_coincidencia (id, id_perfil, estado) VALUES (1, 5, 'ACEPTADA');
INSERT INTO p3_a.t_coincidencia (id, id_perfil, estado) VALUES (2, 5, 'PENDIENTE');
INSERT INTO p3_a.t_coincidencia (id, id_perfil, estado) VALUES (3, 5, 'ACEPTADA');
SELECT * FROM p3_a.t_coincidencia;

-- T4: REGEXP y mayusculas
SELECT 'T4 REGEXP y mayusculas (esperado: ci_acepta 1, con_flag 0)' AS prueba;
SELECT 'canal_c' REGEXP '^[A-Z_]+$' AS ci_acepta,
       'canal_c' REGEXP '(?-i)^[A-Z_]+$' AS con_flag;

SELECT 'T4b Codigo en ascii_bin con CHECK (esperado: CANAL_C entra, canal_c da ERROR)' AS prueba;
CREATE TABLE p3_a.t_codigo (
  codigo VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL PRIMARY KEY,
  CONSTRAINT ck_codigo CHECK (codigo REGEXP '^[A-Z0-9_]{1,30}$')
) ENGINE=InnoDB;
INSERT INTO p3_a.t_codigo VALUES ('CANAL_C');
INSERT INTO p3_a.t_codigo VALUES ('canal_c');
SELECT * FROM p3_a.t_codigo;

-- T5: JSON
SELECT 'T5 JSON (esperado: ERROR en el segundo INSERT)' AS prueba;
CREATE TABLE p3_a.t_json (j JSON) ENGINE=InnoDB;
INSERT INTO p3_a.t_json VALUES ('{"peso_nombre": 0.5}');
INSERT INTO p3_a.t_json VALUES ('{esto no es json');
SHOW CREATE TABLE p3_a.t_json;

-- T6: BOOLEAN
SELECT 'T6 BOOLEAN acepta un 7 (muestra por que hace falta un CHECK)' AS prueba;
CREATE TABLE p3_a.t_bool (b BOOLEAN) ENGINE=InnoDB;
INSERT INTO p3_a.t_bool VALUES (7);
SELECT b FROM p3_a.t_bool;

-- T7: YEAR
SELECT 'T7 YEAR convierte 25 en 2025 sin avisar' AS prueba;
CREATE TABLE p3_a.t_year (y YEAR) ENGINE=InnoDB;
INSERT INTO p3_a.t_year VALUES (25);
SELECT y FROM p3_a.t_year;

-- T8: resta de enteros sin signo
SELECT 'T8 Resta de UNSIGNED que da negativo (esperado: ERROR fuera de rango)' AS prueba;
SELECT CAST(2020 AS UNSIGNED) - CAST(2021 AS UNSIGNED) AS resta;
SELECT 'T8b La misma resta con signo (esperado: -1)' AS prueba;
SELECT CAST(2020 AS SIGNED) - CAST(2021 AS SIGNED) AS resta;

-- T9: FLOAT frente a DECIMAL en un umbral
SELECT 'T9 FLOAT frente a DECIMAL con umbral 0.7 (esperado: float_pasa 0, decimal_pasa 1)' AS prueba;
CREATE TABLE p3_a.t_num (f FLOAT, d DECIMAL(4,3)) ENGINE=InnoDB;
INSERT INTO p3_a.t_num VALUES (0.7, 0.7);
SELECT f, d, f >= 0.7 AS float_pasa, d >= 0.7 AS decimal_pasa FROM p3_a.t_num;

-- T10: disparadores y borrado en cascada
SELECT 'T10 Disparador en tabla hija y borrado en cascada (esperado: 0 filas en el registro)' AS prueba;
CREATE TABLE p3_a.registro (texto VARCHAR(50)) ENGINE=InnoDB;
CREATE TABLE p3_a.padre2 (id INT UNSIGNED PRIMARY KEY) ENGINE=InnoDB;
CREATE TABLE p3_a.hijo2 (
  id INT UNSIGNED PRIMARY KEY,
  id_padre INT UNSIGNED NOT NULL,
  FOREIGN KEY (id_padre) REFERENCES p3_a.padre2 (id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TRIGGER p3_a.trg_hijo2_ad AFTER DELETE ON p3_a.hijo2 FOR EACH ROW
  INSERT INTO p3_a.registro VALUES (CONCAT('borrado hijo ', OLD.id));
INSERT INTO p3_a.padre2 VALUES (1);
INSERT INTO p3_a.hijo2 VALUES (10, 1);
DELETE FROM p3_a.padre2 WHERE id = 1;
SELECT COUNT(*) AS filas_en_registro FROM p3_a.registro;

-- T11: llave foranea compuesta con un vacio
SELECT 'T11 Llave foranea compuesta (esperado: la primera busqueda entra, la segunda da ERROR)' AS prueba;
CREATE TABLE p3_a.muestra_egresado (
  id_muestra INT UNSIGNED NOT NULL,
  id_egresado INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_muestra, id_egresado)
) ENGINE=InnoDB;
CREATE TABLE p3_a.busqueda (
  id INT UNSIGNED PRIMARY KEY,
  id_egresado INT UNSIGNED NOT NULL,
  id_muestra INT UNSIGNED NULL,
  CONSTRAINT fk_busqueda_muestra FOREIGN KEY (id_muestra, id_egresado)
    REFERENCES p3_a.muestra_egresado (id_muestra, id_egresado)
) ENGINE=InnoDB;
INSERT INTO p3_a.busqueda VALUES (1, 7, NULL);
INSERT INTO p3_a.busqueda VALUES (2, 7, 3);

-- T12: UNIQUE con la intercalacion en espanol
SELECT 'T12 UNIQUE con intercalacion en espanol (esperado: Pena entra, JOSE da ERROR)' AS prueba;
CREATE TABLE p3_a.t_nombre (
  nombre VARCHAR(50) NOT NULL,
  CONSTRAINT uq_nombre UNIQUE (nombre)
) ENGINE=InnoDB;
INSERT INTO p3_a.t_nombre VALUES ('Peña');
INSERT INTO p3_a.t_nombre VALUES ('Pena');
INSERT INTO p3_a.t_nombre VALUES ('José');
INSERT INTO p3_a.t_nombre VALUES ('JOSE');
SELECT COUNT(*) AS nombres_guardados FROM p3_a.t_nombre;

-- T13: columna calculada por el formato del codigo
SELECT 'T13 Nivel calculado por el formato del codigo (esperado: PAIS, DEPARTAMENTO, MUNICIPIO)' AS prueba;
CREATE TABLE p3_a.t_ubicacion (
  codigo VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  nivel VARCHAR(12) AS (CASE
    WHEN codigo REGEXP '^[A-Z]{2}$' THEN 'PAIS'
    WHEN CHAR_LENGTH(codigo) = 2 THEN 'DEPARTAMENTO'
    ELSE 'MUNICIPIO' END) VIRTUAL
) ENGINE=InnoDB;
INSERT INTO p3_a.t_ubicacion (codigo) VALUES ('CO'), ('11'), ('11001');
SELECT * FROM p3_a.t_ubicacion;

-- T14: exactamente uno de dos
SELECT 'T14 Exactamente uno de dos (esperado: el primero entra, los otros dos dan ERROR)' AS prueba;
CREATE TABLE p3_a.t_autor (
  id INT PRIMARY KEY,
  id_ejecucion INT NULL,
  id_responsable INT NULL,
  CONSTRAINT ck_un_autor CHECK ((id_ejecucion IS NULL) <> (id_responsable IS NULL))
) ENGINE=InnoDB;
INSERT INTO p3_a.t_autor VALUES (1, 5, NULL);
INSERT INTO p3_a.t_autor VALUES (2, NULL, NULL);
INSERT INTO p3_a.t_autor VALUES (3, 5, 8);

-- T15: TIMESTAMP frente a DATETIME al cambiar la zona de la sesion
SELECT 'T15 TIMESTAMP cambia con la zona de la sesion; DATETIME no (esperado: ts 13:00, dt 08:00)' AS prueba;
CREATE TABLE p3_a.t_tiempo (ts TIMESTAMP NULL, dt DATETIME NULL) ENGINE=InnoDB;
SET time_zone = '-05:00';
INSERT INTO p3_a.t_tiempo VALUES ('2026-10-29 08:00:00', '2026-10-29 08:00:00');
SET time_zone = '+00:00';
SELECT ts, dt FROM p3_a.t_tiempo;
SET time_zone = DEFAULT;

-- Limpieza: p3_b primero, porque sus tablas apuntan a p3_a
DROP DATABASE p3_b;
DROP DATABASE p3_a;
SELECT 'Fin: bases de prueba borradas' AS prueba;
