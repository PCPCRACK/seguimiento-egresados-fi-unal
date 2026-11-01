-- =====================================================================
-- 03_tablas.sql
-- Las 39 tablas del modelo, en orden de dependencias.
-- Detalle de cada columna: docs/03_diccionario_datos.md
-- Decisiones de tipos y restricciones: docs/02_modelo_datos.md, paso 3
-- =====================================================================
--
-- Convenciones que se repiten en todo el archivo:
--   * Códigos, listas, huellas, URL y documentos: CHARACTER SET ascii
--     COLLATE ascii_bin (comparación exacta, distingue mayúsculas).
--   * Correos y usuarios: utf8mb4_bin (exactos, con cualquier carácter).
--   * Nombres y textos: la intercalación en español de la base.
--   * Textos: no vacíos y sin espacios al inicio ni al final. Se valida
--     comparando longitudes, porque con PAD SPACE 'abc ' = 'abc'.
--   * Un CHECK que da NULL se considera cumplido. Por eso las reglas
--     sobre columnas opcionales dicen "IS NOT NULL" de forma explícita.
--   * Nombres de restricciones: pk_, fk_, uq_, ck_, idx_ + tabla.

SET NAMES utf8mb4;

-- =====================================================================
-- Base egresados: catálogos sin dependencias
-- =====================================================================

CREATE TABLE egresados.cat_nivel_formacion (
  codigo_nivel VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  nombre       VARCHAR(300) NOT NULL,
  orden        INT NULL,
  CONSTRAINT pk_cat_nivel_formacion PRIMARY KEY (codigo_nivel),
  CONSTRAINT uq_cat_nivel_formacion_nombre UNIQUE (nombre),
  CONSTRAINT uq_cat_nivel_formacion_orden UNIQUE (orden),
  CONSTRAINT ck_cat_nivel_formacion_codigo CHECK (codigo_nivel REGEXP '^[A-Z0-9_]{1,30}$'),
  CONSTRAINT ck_cat_nivel_formacion_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  CONSTRAINT ck_cat_nivel_formacion_orden CHECK (orden >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.cat_fuente (
  codigo_fuente VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  nombre        VARCHAR(300) NOT NULL,
  base_legal    VARCHAR(22) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  norma         VARCHAR(300) NULL,
  es_individual TINYINT NOT NULL,
  CONSTRAINT pk_cat_fuente PRIMARY KEY (codigo_fuente),
  CONSTRAINT uq_cat_fuente_nombre UNIQUE (nombre),
  CONSTRAINT ck_cat_fuente_codigo CHECK (codigo_fuente REGEXP '^[A-Z0-9_]{1,30}$'),
  CONSTRAINT ck_cat_fuente_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  CONSTRAINT ck_cat_fuente_base_legal CHECK (base_legal IN ('AUTORIZACION', 'DATO_PUBLICO', 'REGISTRO_INSTITUCIONAL', 'SIN_DATOS_PERSONALES')),
  CONSTRAINT ck_cat_fuente_norma CHECK (norma <> '' AND CHAR_LENGTH(norma) = CHAR_LENGTH(TRIM(norma))),
  CONSTRAINT ck_cat_fuente_es_individual CHECK (es_individual IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.cat_tipo_incidencia (
  codigo_tipo_incidencia VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  nombre                 VARCHAR(300) NOT NULL,
  dimension              VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  severidad              VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  bloquea_captura        TINYINT NOT NULL,
  CONSTRAINT pk_cat_tipo_incidencia PRIMARY KEY (codigo_tipo_incidencia),
  CONSTRAINT uq_cat_tipo_incidencia_nombre UNIQUE (nombre),
  CONSTRAINT ck_cat_tipo_incidencia_codigo CHECK (codigo_tipo_incidencia REGEXP '^[A-Z0-9_]{1,30}$'),
  CONSTRAINT ck_cat_tipo_incidencia_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  -- Dimensiones del principio de veracidad o calidad (Ley 1581, art. 4 lit. d)
  CONSTRAINT ck_cat_tipo_incidencia_dimension CHECK (dimension IN ('VERAZ', 'COMPLETA', 'EXACTA', 'ACTUALIZADA', 'COMPROBABLE', 'COMPRENSIBLE')),
  CONSTRAINT ck_cat_tipo_incidencia_severidad CHECK (severidad IN ('ALTA', 'MEDIA', 'BAJA')),
  CONSTRAINT ck_cat_tipo_incidencia_bloquea CHECK (bloquea_captura IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.cat_momento_seguimiento (
  codigo_momento    VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  anios_desde_grado INT NOT NULL,
  es_activo         TINYINT NOT NULL,
  CONSTRAINT pk_cat_momento_seguimiento PRIMARY KEY (codigo_momento),
  CONSTRAINT uq_cat_momento_seguimiento_anios UNIQUE (anios_desde_grado),
  CONSTRAINT ck_cat_momento_seguimiento_codigo CHECK (codigo_momento REGEXP '^[A-Z0-9_]{1,30}$'),
  CONSTRAINT ck_cat_momento_seguimiento_anios CHECK (anios_desde_grado >= 0),
  CONSTRAINT ck_cat_momento_seguimiento_activo CHECK (es_activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.cat_area_desempeno (
  codigo_area VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  nombre      VARCHAR(300) NOT NULL,
  criterio    VARCHAR(1000) NOT NULL,
  CONSTRAINT pk_cat_area_desempeno PRIMARY KEY (codigo_area),
  CONSTRAINT uq_cat_area_desempeno_nombre UNIQUE (nombre),
  CONSTRAINT ck_cat_area_desempeno_codigo CHECK (codigo_area REGEXP '^[A-Z0-9_]{1,30}$'),
  CONSTRAINT ck_cat_area_desempeno_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  CONSTRAINT ck_cat_area_desempeno_criterio CHECK (criterio <> '')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Ocupaciones (CUOC). El nivel no se guarda: se calcula por la longitud
-- del código. El padre es el código sin su último dígito.
CREATE TABLE egresados.cat_ocupacion (
  codigo_ocupacion VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  nombre           VARCHAR(300) NOT NULL,
  codigo_padre     VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NULL,
  nivel            VARCHAR(18) CHARACTER SET ascii COLLATE ascii_bin AS (
                     CASE CHAR_LENGTH(codigo_ocupacion)
                       WHEN 1 THEN 'GRAN_GRUPO'
                       WHEN 2 THEN 'SUBGRUPO_PRINCIPAL'
                       WHEN 3 THEN 'SUBGRUPO'
                       WHEN 4 THEN 'GRUPO_PRIMARIO'
                       ELSE 'OCUPACION' END) VIRTUAL,
  es_vigente       TINYINT NOT NULL,
  CONSTRAINT pk_cat_ocupacion PRIMARY KEY (codigo_ocupacion),
  CONSTRAINT fk_cat_ocupacion_padre FOREIGN KEY (codigo_padre)
    REFERENCES egresados.cat_ocupacion (codigo_ocupacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_cat_ocupacion_codigo CHECK (codigo_ocupacion REGEXP '^[0-9]{1,5}$'),
  CONSTRAINT ck_cat_ocupacion_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  CONSTRAINT ck_cat_ocupacion_padre CHECK (
    (CHAR_LENGTH(codigo_ocupacion) = 1 AND codigo_padre IS NULL)
    OR (CHAR_LENGTH(codigo_ocupacion) > 1 AND codigo_padre IS NOT NULL
        AND codigo_padre = LEFT(codigo_ocupacion, CHAR_LENGTH(codigo_ocupacion) - 1))),
  CONSTRAINT ck_cat_ocupacion_vigente CHECK (es_vigente IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Actividades económicas (CIIU Rev. 4 A.C.). Una división apunta a su
-- sección (una letra); un grupo o una clase, a su código sin el último dígito.
CREATE TABLE egresados.cat_actividad_economica (
  codigo_actividad VARCHAR(4) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  nombre           VARCHAR(300) NOT NULL,
  codigo_padre     VARCHAR(4) CHARACTER SET ascii COLLATE ascii_bin NULL,
  nivel            VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin AS (
                     CASE
                       WHEN codigo_actividad REGEXP '^[A-U]$' THEN 'SECCION'
                       WHEN CHAR_LENGTH(codigo_actividad) = 2 THEN 'DIVISION'
                       WHEN CHAR_LENGTH(codigo_actividad) = 3 THEN 'GRUPO'
                       ELSE 'CLASE' END) VIRTUAL,
  es_vigente       TINYINT NOT NULL,
  CONSTRAINT pk_cat_actividad_economica PRIMARY KEY (codigo_actividad),
  CONSTRAINT fk_cat_actividad_economica_padre FOREIGN KEY (codigo_padre)
    REFERENCES egresados.cat_actividad_economica (codigo_actividad) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_cat_actividad_economica_codigo CHECK (codigo_actividad REGEXP '^([A-U]|[0-9]{2,4})$'),
  CONSTRAINT ck_cat_actividad_economica_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  CONSTRAINT ck_cat_actividad_economica_padre CHECK (
    (codigo_actividad REGEXP '^[A-U]$' AND codigo_padre IS NULL)
    OR (codigo_actividad REGEXP '^[0-9]{2}$' AND codigo_padre IS NOT NULL AND codigo_padre REGEXP '^[A-U]$')
    OR (codigo_actividad REGEXP '^[0-9]{3,4}$' AND codigo_padre IS NOT NULL
        AND codigo_padre = LEFT(codigo_actividad, CHAR_LENGTH(codigo_actividad) - 1))),
  CONSTRAINT ck_cat_actividad_economica_vigente CHECK (es_vigente IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Ubicaciones: país (ISO 3166-1, dos letras) -> departamento (DIVIPOLA,
-- dos dígitos) -> municipio (DIVIPOLA, cinco dígitos).
CREATE TABLE egresados.cat_ubicacion (
  codigo_ubicacion VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  nombre           VARCHAR(300) NOT NULL,
  codigo_padre     VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NULL,
  nivel            VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin AS (
                     CASE
                       WHEN codigo_ubicacion REGEXP '^[A-Z]{2}$' THEN 'PAIS'
                       WHEN CHAR_LENGTH(codigo_ubicacion) = 2 THEN 'DEPARTAMENTO'
                       ELSE 'MUNICIPIO' END) VIRTUAL,
  es_vigente       TINYINT NOT NULL,
  CONSTRAINT pk_cat_ubicacion PRIMARY KEY (codigo_ubicacion),
  CONSTRAINT fk_cat_ubicacion_padre FOREIGN KEY (codigo_padre)
    REFERENCES egresados.cat_ubicacion (codigo_ubicacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_cat_ubicacion_codigo CHECK (codigo_ubicacion REGEXP '^([A-Z]{2}|[0-9]{2}|[0-9]{5})$'),
  CONSTRAINT ck_cat_ubicacion_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  CONSTRAINT ck_cat_ubicacion_padre CHECK (
    (codigo_ubicacion REGEXP '^[A-Z]{2}$' AND codigo_padre IS NULL)
    OR (codigo_ubicacion REGEXP '^[0-9]{2}$' AND codigo_padre IS NOT NULL AND codigo_padre = 'CO')
    OR (codigo_ubicacion REGEXP '^[0-9]{5}$' AND codigo_padre IS NOT NULL AND codigo_padre = LEFT(codigo_ubicacion, 2))),
  CONSTRAINT ck_cat_ubicacion_vigente CHECK (es_vigente IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- =====================================================================
-- Base egresados: responsables y ejecuciones (trazabilidad)
-- =====================================================================

-- Todo usuario que escribe en las bases debe estar aquí: la bitácora
-- tiene una llave foránea hacia usuario_bd.
CREATE TABLE egresados.responsable (
  id_responsable INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_bd     VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  nombre         VARCHAR(300) NOT NULL,
  tipo           VARCHAR(7) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  fecha_alta     DATE NOT NULL,
  fecha_baja     DATE NULL,
  CONSTRAINT pk_responsable PRIMARY KEY (id_responsable),
  CONSTRAINT uq_responsable_usuario_bd UNIQUE (usuario_bd),
  CONSTRAINT ck_responsable_usuario_bd CHECK (usuario_bd <> ''),
  CONSTRAINT ck_responsable_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  CONSTRAINT ck_responsable_tipo CHECK (tipo IN ('PERSONA', 'BOT')),
  CONSTRAINT ck_responsable_fechas CHECK (fecha_baja >= fecha_alta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.ejecucion (
  id_ejecucion         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo_proceso         VARCHAR(17) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_responsable       INT UNSIGNED NOT NULL,
  version_programa     VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  modelo_ia            VARCHAR(300) NULL,
  digest_modelo_ia     CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL,
  parametros           JSON NULL,
  fecha_hora_inicio    DATETIME NOT NULL,
  fecha_hora_fin       DATETIME NULL,
  resultado            VARCHAR(11) CHARACTER SET ascii COLLATE ascii_bin NULL,
  registros_procesados INT NULL,
  CONSTRAINT pk_ejecucion PRIMARY KEY (id_ejecucion),
  CONSTRAINT fk_ejecucion_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_ejecucion_tipo CHECK (tipo_proceso IN ('CARGA_OFICIAL', 'CARGA_CATALOGO', 'BOT_CONSOLIDACION',
    'BOT_VERIFICACION', 'CLASIFICACION', 'ENVIO_SOLICITUDES', 'MUESTREO', 'DEPURACION')),
  CONSTRAINT ck_ejecucion_version CHECK (version_programa REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+$'),
  CONSTRAINT ck_ejecucion_modelo CHECK (modelo_ia <> '' AND CHAR_LENGTH(modelo_ia) = CHAR_LENGTH(TRIM(modelo_ia))),
  CONSTRAINT ck_ejecucion_digest CHECK (digest_modelo_ia REGEXP '^[0-9a-f]{64}$'),
  CONSTRAINT ck_ejecucion_modelo_y_digest CHECK ((modelo_ia IS NULL) = (digest_modelo_ia IS NULL)),
  CONSTRAINT ck_ejecucion_fechas CHECK (fecha_hora_fin >= fecha_hora_inicio),
  CONSTRAINT ck_ejecucion_resultado CHECK (resultado IN ('EXITOSA', 'CON_ERRORES', 'FALLIDA')),
  CONSTRAINT ck_ejecucion_registros CHECK (registros_procesados >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- =====================================================================
-- Base egresados: programas, organizaciones y diccionarios
-- =====================================================================

CREATE TABLE egresados.cat_programa (
  id_programa       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre            VARCHAR(300) NOT NULL,
  codigo_nivel      VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  codigo_snies      VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
  codigo_sia        VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
  semestres_minimos INT NOT NULL,
  es_vigente        TINYINT NOT NULL,
  CONSTRAINT pk_cat_programa PRIMARY KEY (id_programa),
  CONSTRAINT uq_cat_programa_nombre UNIQUE (nombre),
  CONSTRAINT uq_cat_programa_snies UNIQUE (codigo_snies),
  CONSTRAINT uq_cat_programa_sia UNIQUE (codigo_sia),
  CONSTRAINT fk_cat_programa_nivel FOREIGN KEY (codigo_nivel)
    REFERENCES egresados.cat_nivel_formacion (codigo_nivel) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_cat_programa_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  CONSTRAINT ck_cat_programa_snies CHECK (codigo_snies REGEXP '^[A-Z0-9_]{1,30}$'),
  CONSTRAINT ck_cat_programa_sia CHECK (codigo_sia REGEXP '^[A-Z0-9_]{1,30}$'),
  CONSTRAINT ck_cat_programa_semestres CHECK (semestres_minimos > 0),
  CONSTRAINT ck_cat_programa_vigente CHECK (es_vigente IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Organizaciones: empresas e instituciones en un solo catálogo.
-- La actividad económica sigue el patrón de clasificación:
-- propuesta + método + confianza + valor final.
CREATE TABLE egresados.cat_organizacion (
  id_organizacion            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre                     VARCHAR(300) NOT NULL,
  codigo_pais                VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NULL,
  nit                        VARCHAR(10) CHARACTER SET ascii COLLATE ascii_bin NULL,
  codigo_actividad_propuesto VARCHAR(4) CHARACTER SET ascii COLLATE ascii_bin NULL,
  metodo_actividad           VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NULL,
  confianza_actividad        DECIMAL(4,3) NULL,
  codigo_actividad           VARCHAR(4) CHARACTER SET ascii COLLATE ascii_bin NULL,
  id_ejecucion_clasificacion INT UNSIGNED NULL,
  CONSTRAINT pk_cat_organizacion PRIMARY KEY (id_organizacion),
  CONSTRAINT uq_cat_organizacion_nombre_pais UNIQUE (nombre, codigo_pais),
  CONSTRAINT uq_cat_organizacion_nit UNIQUE (nit),
  CONSTRAINT fk_cat_organizacion_pais FOREIGN KEY (codigo_pais)
    REFERENCES egresados.cat_ubicacion (codigo_ubicacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_cat_organizacion_actividad_propuesta FOREIGN KEY (codigo_actividad_propuesto)
    REFERENCES egresados.cat_actividad_economica (codigo_actividad) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_cat_organizacion_actividad FOREIGN KEY (codigo_actividad)
    REFERENCES egresados.cat_actividad_economica (codigo_actividad) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_cat_organizacion_ejecucion FOREIGN KEY (id_ejecucion_clasificacion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_cat_organizacion_nombre CHECK (nombre <> '' AND CHAR_LENGTH(nombre) = CHAR_LENGTH(TRIM(nombre))),
  -- El país es de nivel país: dos letras. Se valida por el formato, sin consultar otra tabla.
  CONSTRAINT ck_cat_organizacion_pais CHECK (codigo_pais REGEXP '^[A-Z]{2}$'),
  CONSTRAINT ck_cat_organizacion_nit CHECK (nit REGEXP '^[0-9]{6,10}$'),
  CONSTRAINT ck_cat_organizacion_metodo CHECK (metodo_actividad IN ('REGISTRO', 'IA')),
  CONSTRAINT ck_cat_organizacion_confianza CHECK (confianza_actividad BETWEEN 0 AND 1),
  CONSTRAINT ck_cat_organizacion_propuesta CHECK (
    (codigo_actividad_propuesto IS NULL) = (metodo_actividad IS NULL)
    AND (metodo_actividad IS NULL) = (confianza_actividad IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Diccionarios de equivalencias: las cuatro tablas tienen la misma
-- estructura; solo cambia el destino. El texto normalizado va en
-- minúsculas, sin tildes (conserva la ñ), sin puntuación y con un solo
-- espacio entre palabras. (?-i) hace que el REGEXP distinga mayúsculas.

CREATE TABLE egresados.programa_alias (
  id_programa_alias     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  texto_normalizado     VARCHAR(300) NOT NULL,
  id_programa           INT UNSIGNED NOT NULL,
  origen                VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_responsable        INT UNSIGNED NOT NULL,
  fecha_hora_validacion DATETIME NOT NULL,
  CONSTRAINT pk_programa_alias PRIMARY KEY (id_programa_alias),
  CONSTRAINT uq_programa_alias_texto UNIQUE (texto_normalizado),
  CONSTRAINT fk_programa_alias_programa FOREIGN KEY (id_programa)
    REFERENCES egresados.cat_programa (id_programa) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_programa_alias_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_programa_alias_texto CHECK (texto_normalizado REGEXP '(?-i)^[a-z0-9ñ]+( [a-z0-9ñ]+)*$'),
  CONSTRAINT ck_programa_alias_origen CHECK (origen IN ('OFICIAL', 'VALIDADO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.organizacion_alias (
  id_organizacion_alias INT UNSIGNED NOT NULL AUTO_INCREMENT,
  texto_normalizado     VARCHAR(300) NOT NULL,
  id_organizacion       INT UNSIGNED NOT NULL,
  origen                VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_responsable        INT UNSIGNED NOT NULL,
  fecha_hora_validacion DATETIME NOT NULL,
  CONSTRAINT pk_organizacion_alias PRIMARY KEY (id_organizacion_alias),
  CONSTRAINT uq_organizacion_alias_texto UNIQUE (texto_normalizado),
  CONSTRAINT fk_organizacion_alias_organizacion FOREIGN KEY (id_organizacion)
    REFERENCES egresados.cat_organizacion (id_organizacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_organizacion_alias_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_organizacion_alias_texto CHECK (texto_normalizado REGEXP '(?-i)^[a-z0-9ñ]+( [a-z0-9ñ]+)*$'),
  CONSTRAINT ck_organizacion_alias_origen CHECK (origen IN ('OFICIAL', 'VALIDADO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- El catálogo de cargos que pide el enunciado: cargo escrito -> ocupación.
CREATE TABLE egresados.cargo_alias (
  id_cargo_alias        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  texto_normalizado     VARCHAR(300) NOT NULL,
  codigo_ocupacion      VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  origen                VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_responsable        INT UNSIGNED NOT NULL,
  fecha_hora_validacion DATETIME NOT NULL,
  CONSTRAINT pk_cargo_alias PRIMARY KEY (id_cargo_alias),
  CONSTRAINT uq_cargo_alias_texto UNIQUE (texto_normalizado),
  CONSTRAINT fk_cargo_alias_ocupacion FOREIGN KEY (codigo_ocupacion)
    REFERENCES egresados.cat_ocupacion (codigo_ocupacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_cargo_alias_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_cargo_alias_texto CHECK (texto_normalizado REGEXP '(?-i)^[a-z0-9ñ]+( [a-z0-9ñ]+)*$'),
  CONSTRAINT ck_cargo_alias_origen CHECK (origen IN ('OFICIAL', 'VALIDADO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.ubicacion_alias (
  id_ubicacion_alias    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  texto_normalizado     VARCHAR(300) NOT NULL,
  codigo_ubicacion      VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  origen                VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_responsable        INT UNSIGNED NOT NULL,
  fecha_hora_validacion DATETIME NOT NULL,
  CONSTRAINT pk_ubicacion_alias PRIMARY KEY (id_ubicacion_alias),
  CONSTRAINT uq_ubicacion_alias_texto UNIQUE (texto_normalizado),
  CONSTRAINT fk_ubicacion_alias_ubicacion FOREIGN KEY (codigo_ubicacion)
    REFERENCES egresados.cat_ubicacion (codigo_ubicacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_ubicacion_alias_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_ubicacion_alias_texto CHECK (texto_normalizado REGEXP '(?-i)^[a-z0-9ñ]+( [a-z0-9ñ]+)*$'),
  CONSTRAINT ck_ubicacion_alias_origen CHECK (origen IN ('OFICIAL', 'VALIDADO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Qué ocupaciones son pertinentes para cada programa. Un código cubre sus
-- niveles inferiores: si se marca 25, toda ocupación que empiece por 25 es afín.
CREATE TABLE egresados.afinidad_programa_ocupacion (
  id_programa      INT UNSIGNED NOT NULL,
  codigo_ocupacion VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  soporte          VARCHAR(300) NOT NULL,
  id_responsable   INT UNSIGNED NOT NULL,
  CONSTRAINT pk_afinidad_programa_ocupacion PRIMARY KEY (id_programa, codigo_ocupacion),
  CONSTRAINT fk_afinidad_programa FOREIGN KEY (id_programa)
    REFERENCES egresados.cat_programa (id_programa) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_afinidad_ocupacion FOREIGN KEY (codigo_ocupacion)
    REFERENCES egresados.cat_ocupacion (codigo_ocupacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_afinidad_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_afinidad_soporte CHECK (soporte <> '' AND CHAR_LENGTH(soporte) = CHAR_LENGTH(TRIM(soporte)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- =====================================================================
-- Base egresados: la persona, sus grados y el muestreo
-- =====================================================================

-- La carga inicial inserta a los egresados en orden aleatorio, para que
-- el número no conserve el orden del archivo fuente.
CREATE TABLE egresados.egresado (
  id_egresado  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sexo         VARCHAR(1) CHARACTER SET ascii COLLATE ascii_bin NULL,
  id_ejecucion INT UNSIGNED NOT NULL,
  CONSTRAINT pk_egresado PRIMARY KEY (id_egresado),
  CONSTRAINT fk_egresado_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_egresado_sexo CHECK (sexo IN ('F', 'M', 'O'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.grado (
  id_grado         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_egresado      INT UNSIGNED NOT NULL,
  id_programa      INT UNSIGNED NOT NULL,
  anio_ingreso     SMALLINT NULL,
  semestre_ingreso TINYINT NULL,
  fecha_grado      DATE NULL,
  estado           VARCHAR(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_ejecucion     INT UNSIGNED NOT NULL,
  CONSTRAINT pk_grado PRIMARY KEY (id_grado),
  CONSTRAINT uq_grado_egresado_programa UNIQUE (id_egresado, id_programa),
  CONSTRAINT fk_grado_egresado FOREIGN KEY (id_egresado)
    REFERENCES egresados.egresado (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_grado_programa FOREIGN KEY (id_programa)
    REFERENCES egresados.cat_programa (id_programa) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_grado_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_grado_anio_ingreso CHECK (anio_ingreso BETWEEN 1940 AND 2100),
  CONSTRAINT ck_grado_semestre_ingreso CHECK (semestre_ingreso IN (1, 2)),
  CONSTRAINT ck_grado_semestre_con_anio CHECK (semestre_ingreso IS NULL OR anio_ingreso IS NOT NULL),
  CONSTRAINT ck_grado_estado CHECK (estado IN ('EN_TRAMITE', 'OTORGADO', 'CANCELADO')),
  CONSTRAINT ck_grado_fecha_segun_estado CHECK (
    (estado = 'OTORGADO' AND fecha_grado IS NOT NULL) OR (estado <> 'OTORGADO' AND fecha_grado IS NULL)),
  CONSTRAINT ck_grado_ingreso_antes_del_grado CHECK (
    fecha_grado IS NULL OR anio_ingreso IS NULL OR YEAR(fecha_grado) >= anio_ingreso)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE INDEX idx_grado_programa_estado_fecha ON egresados.grado (id_programa, estado, fecha_grado);

CREATE TABLE egresados.muestra (
  id_muestra          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  poblacion           VARCHAR(1000) NOT NULL,
  margen_error        DECIMAL(4,3) NOT NULL,
  nivel_confianza     DECIMAL(4,3) NOT NULL,
  proporcion_supuesta DECIMAL(4,3) NOT NULL,
  semilla             INT NOT NULL,
  id_ejecucion        INT UNSIGNED NOT NULL,
  CONSTRAINT pk_muestra PRIMARY KEY (id_muestra),
  CONSTRAINT fk_muestra_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_muestra_poblacion CHECK (poblacion <> ''),
  CONSTRAINT ck_muestra_margen CHECK (margen_error > 0 AND margen_error <= 1),
  CONSTRAINT ck_muestra_confianza CHECK (nivel_confianza > 0 AND nivel_confianza < 1),
  CONSTRAINT ck_muestra_proporcion CHECK (proporcion_supuesta BETWEEN 0 AND 1),
  CONSTRAINT ck_muestra_semilla CHECK (semilla >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.muestra_egresado (
  id_muestra  INT UNSIGNED NOT NULL,
  id_egresado INT UNSIGNED NOT NULL,
  estrato     VARCHAR(300) NOT NULL,
  peso        DECIMAL(12,4) NOT NULL,
  CONSTRAINT pk_muestra_egresado PRIMARY KEY (id_muestra, id_egresado),
  CONSTRAINT fk_muestra_egresado_muestra FOREIGN KEY (id_muestra)
    REFERENCES egresados.muestra (id_muestra) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_muestra_egresado_egresado FOREIGN KEY (id_egresado)
    REFERENCES egresados.egresado (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT ck_muestra_egresado_estrato CHECK (estrato <> '' AND CHAR_LENGTH(estrato) = CHAR_LENGTH(TRIM(estrato))),
  CONSTRAINT ck_muestra_egresado_peso CHECK (peso >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Búsquedas manuales del canal C, también las que no encuentran a nadie.
-- La llave compuesta garantiza que una búsqueda hecha dentro de una muestra
-- sea de un egresado seleccionado en ella; si id_muestra está vacío, no se aplica.
CREATE TABLE egresados.busqueda (
  id_busqueda       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_egresado       INT UNSIGNED NOT NULL,
  id_muestra        INT UNSIGNED NULL,
  id_responsable    INT UNSIGNED NOT NULL,
  fecha_hora        DATETIME NOT NULL,
  version_protocolo VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  resultado         VARCHAR(17) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  CONSTRAINT pk_busqueda PRIMARY KEY (id_busqueda),
  CONSTRAINT fk_busqueda_egresado FOREIGN KEY (id_egresado)
    REFERENCES egresados.egresado (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_busqueda_muestra_egresado FOREIGN KEY (id_muestra, id_egresado)
    REFERENCES egresados.muestra_egresado (id_muestra, id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_busqueda_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_busqueda_version CHECK (version_protocolo REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+$'),
  CONSTRAINT ck_busqueda_resultado CHECK (resultado IN ('ENCONTRADO', 'VARIOS_CANDIDATOS', 'NO_ENCONTRADO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.indicador_externo (
  id_indicador_externo INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo_fuente        VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_programa          INT UNSIGNED NULL,
  nombre_indicador     VARCHAR(300) NOT NULL,
  anio_cohorte         SMALLINT NULL,
  anio_medicion        SMALLINT NOT NULL,
  valor                DECIMAL(18,4) NOT NULL,
  unidad               VARCHAR(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  referencia           VARCHAR(300) NOT NULL,
  fecha_consulta       DATE NOT NULL,
  CONSTRAINT pk_indicador_externo PRIMARY KEY (id_indicador_externo),
  CONSTRAINT uq_indicador_externo UNIQUE (codigo_fuente, id_programa, nombre_indicador, anio_cohorte, anio_medicion),
  CONSTRAINT fk_indicador_externo_fuente FOREIGN KEY (codigo_fuente)
    REFERENCES egresados.cat_fuente (codigo_fuente) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_indicador_externo_programa FOREIGN KEY (id_programa)
    REFERENCES egresados.cat_programa (id_programa) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_indicador_externo_nombre CHECK (nombre_indicador <> '' AND CHAR_LENGTH(nombre_indicador) = CHAR_LENGTH(TRIM(nombre_indicador))),
  CONSTRAINT ck_indicador_externo_anio_cohorte CHECK (anio_cohorte BETWEEN 1940 AND 2100),
  CONSTRAINT ck_indicador_externo_anio_medicion CHECK (anio_medicion BETWEEN 1940 AND 2100),
  CONSTRAINT ck_indicador_externo_unidad CHECK (unidad IN ('PORCENTAJE', 'PESOS', 'PERSONAS')),
  CONSTRAINT ck_indicador_externo_referencia CHECK (referencia <> '' AND CHAR_LENGTH(referencia) = CHAR_LENGTH(TRIM(referencia)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- =====================================================================
-- Base egresados_identidad
-- =====================================================================

-- Relación 1 a 1 con egresado: la llave primaria es también la foránea.
-- Es la única unión entre la identidad y la persona de la base de análisis.
CREATE TABLE egresados_identidad.identidad (
  id_egresado          INT UNSIGNED NOT NULL,
  nombres              VARCHAR(300) NOT NULL,
  primer_apellido      VARCHAR(300) NOT NULL,
  segundo_apellido     VARCHAR(300) NULL,
  correo_personal      VARCHAR(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  correo_institucional VARCHAR(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  CONSTRAINT pk_identidad PRIMARY KEY (id_egresado),
  CONSTRAINT fk_identidad_egresado FOREIGN KEY (id_egresado)
    REFERENCES egresados.egresado (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT ck_identidad_nombres CHECK (nombres <> '' AND CHAR_LENGTH(nombres) = CHAR_LENGTH(TRIM(nombres))),
  CONSTRAINT ck_identidad_primer_apellido CHECK (primer_apellido <> '' AND CHAR_LENGTH(primer_apellido) = CHAR_LENGTH(TRIM(primer_apellido))),
  CONSTRAINT ck_identidad_segundo_apellido CHECK (segundo_apellido <> '' AND CHAR_LENGTH(segundo_apellido) = CHAR_LENGTH(TRIM(segundo_apellido))),
  CONSTRAINT ck_identidad_correo_personal CHECK (
    correo_personal REGEXP '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$' AND correo_personal = LOWER(correo_personal)),
  CONSTRAINT ck_identidad_correo_institucional CHECK (
    correo_institucional REGEXP '^[^@[:space:]]+@unal\\.edu\\.co$' AND correo_institucional = LOWER(correo_institucional))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados_identidad.documento_identidad (
  id_documento     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_egresado      INT UNSIGNED NOT NULL,
  tipo_documento   VARCHAR(4) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  numero_documento VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  CONSTRAINT pk_documento_identidad PRIMARY KEY (id_documento),
  CONSTRAINT uq_documento_identidad_tipo_numero UNIQUE (tipo_documento, numero_documento),
  CONSTRAINT fk_documento_identidad_identidad FOREIGN KEY (id_egresado)
    REFERENCES egresados_identidad.identidad (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT ck_documento_identidad_tipo CHECK (tipo_documento IN ('CC', 'TI', 'CE', 'PA', 'PPT', 'OTRO')),
  CONSTRAINT ck_documento_identidad_numero CHECK (numero_documento REGEXP '^[A-Z0-9]{3,20}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Versiones del texto de autorización. marca_vigente vale 1 en la versión
-- vigente y está vacía en las demás; como UNIQUE admite varios vacíos,
-- solo puede haber una versión vigente.
CREATE TABLE egresados_identidad.texto_autorizacion (
  id_texto_autorizacion INT UNSIGNED NOT NULL AUTO_INCREMENT,
  version               VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  texto                 TEXT NOT NULL,
  fecha_inicio_vigencia DATE NOT NULL,
  fecha_fin_vigencia    DATE NULL,
  marca_vigente         TINYINT AS (IF(fecha_fin_vigencia IS NULL, 1, NULL)) VIRTUAL,
  CONSTRAINT pk_texto_autorizacion PRIMARY KEY (id_texto_autorizacion),
  CONSTRAINT uq_texto_autorizacion_version UNIQUE (version),
  CONSTRAINT uq_texto_autorizacion_vigente UNIQUE (marca_vigente),
  CONSTRAINT ck_texto_autorizacion_version CHECK (version REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+$'),
  CONSTRAINT ck_texto_autorizacion_texto CHECK (texto <> '' AND CHAR_LENGTH(texto) <= 20000),
  CONSTRAINT ck_texto_autorizacion_fechas CHECK (fecha_fin_vigencia >= fecha_inicio_vigencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Prueba de la autorización (Decreto 1377, art. 8). La llave única
-- (id_autorizacion, id_egresado) permite que captura compruebe, con una
-- llave compuesta, que la autorización es del mismo egresado.
CREATE TABLE egresados_identidad.autorizacion (
  id_autorizacion       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_egresado           INT UNSIGNED NOT NULL,
  id_texto_autorizacion INT UNSIGNED NOT NULL,
  codigo_fuente         VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  fecha_hora            DATETIME NOT NULL,
  evidencia             VARCHAR(300) NOT NULL,
  CONSTRAINT pk_autorizacion PRIMARY KEY (id_autorizacion),
  CONSTRAINT uq_autorizacion_egresado UNIQUE (id_autorizacion, id_egresado),
  CONSTRAINT fk_autorizacion_identidad FOREIGN KEY (id_egresado)
    REFERENCES egresados_identidad.identidad (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_autorizacion_texto FOREIGN KEY (id_texto_autorizacion)
    REFERENCES egresados_identidad.texto_autorizacion (id_texto_autorizacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_autorizacion_fuente FOREIGN KEY (codigo_fuente)
    REFERENCES egresados.cat_fuente (codigo_fuente) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_autorizacion_fuente CHECK (codigo_fuente IN ('CANAL_A', 'CANAL_B')),
  CONSTRAINT ck_autorizacion_evidencia CHECK (evidencia <> '' AND CHAR_LENGTH(evidencia) = CHAR_LENGTH(TRIM(evidencia)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Perfiles de LinkedIn, aceptados o candidatos. La huella HMAC la calcula
-- el programa que tiene la clave; la base nunca ve la clave.
CREATE TABLE egresados_identidad.perfil (
  id_perfil              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  url                    VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NULL,
  huella_url             CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  fecha_hora_borrado_url DATETIME NULL,
  CONSTRAINT pk_perfil PRIMARY KEY (id_perfil),
  CONSTRAINT uq_perfil_url UNIQUE (url),
  CONSTRAINT uq_perfil_huella_url UNIQUE (huella_url),
  CONSTRAINT ck_perfil_url CHECK (url REGEXP '^https://www\\.linkedin\\.com/in/[a-z0-9%_-]{3,100}$'),
  CONSTRAINT ck_perfil_huella_url CHECK (huella_url REGEXP '^[0-9a-f]{64}$'),
  CONSTRAINT ck_perfil_url_borrada CHECK ((url IS NULL) = (fecha_hora_borrado_url IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Comparación entre un egresado y un perfil. perfil_aceptado y
-- egresado_aceptado tienen valor solo si la coincidencia está aceptada;
-- sus restricciones UNIQUE garantizan un perfil por egresado y un
-- egresado por perfil (prueba T3 del paso 3).
CREATE TABLE egresados_identidad.coincidencia (
  id_coincidencia               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_egresado                   INT UNSIGNED NOT NULL,
  id_perfil                     INT UNSIGNED NOT NULL,
  id_busqueda                   INT UNSIGNED NULL,
  id_ejecucion                  INT UNSIGNED NOT NULL,
  nombre_observado              VARCHAR(300) NULL,
  programa_observado            VARCHAR(300) NULL,
  anio_inicio_observado         SMALLINT NULL,
  anio_fin_observado            SMALLINT NULL,
  ciudad_observada              VARCHAR(300) NULL,
  puntaje_nombre                DECIMAL(4,3) NOT NULL,
  puntaje_programa              DECIMAL(4,3) NULL,
  puntaje_anio                  DECIMAL(4,3) NULL,
  puntaje_ciudad                DECIMAL(4,3) NULL,
  puntaje_total                 DECIMAL(4,3) NOT NULL,
  nivel                         VARCHAR(9) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  motivo_nivel                  VARCHAR(1000) NULL,
  estado                        VARCHAR(9) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'PENDIENTE',
  fecha_hora_borrado_observados DATETIME NULL,
  perfil_aceptado               INT UNSIGNED AS (IF(estado = 'ACEPTADA', id_perfil, NULL)) VIRTUAL,
  egresado_aceptado             INT UNSIGNED AS (IF(estado = 'ACEPTADA', id_egresado, NULL)) VIRTUAL,
  CONSTRAINT pk_coincidencia PRIMARY KEY (id_coincidencia),
  CONSTRAINT uq_coincidencia_egresado_perfil UNIQUE (id_egresado, id_perfil),
  CONSTRAINT uq_coincidencia_perfil_aceptado UNIQUE (perfil_aceptado),
  CONSTRAINT uq_coincidencia_egresado_aceptado UNIQUE (egresado_aceptado),
  CONSTRAINT fk_coincidencia_identidad FOREIGN KEY (id_egresado)
    REFERENCES egresados_identidad.identidad (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_coincidencia_perfil FOREIGN KEY (id_perfil)
    REFERENCES egresados_identidad.perfil (id_perfil) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_coincidencia_busqueda FOREIGN KEY (id_busqueda)
    REFERENCES egresados.busqueda (id_busqueda) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_coincidencia_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_coincidencia_nombre_observado CHECK (nombre_observado <> '' AND CHAR_LENGTH(nombre_observado) = CHAR_LENGTH(TRIM(nombre_observado))),
  CONSTRAINT ck_coincidencia_programa_observado CHECK (programa_observado <> '' AND CHAR_LENGTH(programa_observado) = CHAR_LENGTH(TRIM(programa_observado))),
  CONSTRAINT ck_coincidencia_ciudad_observada CHECK (ciudad_observada <> '' AND CHAR_LENGTH(ciudad_observada) = CHAR_LENGTH(TRIM(ciudad_observada))),
  CONSTRAINT ck_coincidencia_anio_inicio_observado CHECK (anio_inicio_observado BETWEEN 1940 AND 2100),
  CONSTRAINT ck_coincidencia_anio_fin_observado CHECK (anio_fin_observado BETWEEN 1940 AND 2100),
  CONSTRAINT ck_coincidencia_puntajes CHECK (
    puntaje_nombre BETWEEN 0 AND 1 AND puntaje_total BETWEEN 0 AND 1),
  CONSTRAINT ck_coincidencia_puntaje_programa CHECK (puntaje_programa BETWEEN 0 AND 1),
  CONSTRAINT ck_coincidencia_puntaje_anio CHECK (puntaje_anio BETWEEN 0 AND 1),
  CONSTRAINT ck_coincidencia_puntaje_ciudad CHECK (puntaje_ciudad BETWEEN 0 AND 1),
  CONSTRAINT ck_coincidencia_nivel CHECK (nivel IN ('ALTO', 'MEDIO', 'BAJO', 'IMPOSIBLE')),
  CONSTRAINT ck_coincidencia_motivo_imposible CHECK (nivel <> 'IMPOSIBLE' OR motivo_nivel IS NOT NULL),
  CONSTRAINT ck_coincidencia_motivo CHECK (motivo_nivel <> ''),
  CONSTRAINT ck_coincidencia_estado CHECK (estado IN ('PENDIENTE', 'ACEPTADA', 'RECHAZADA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE INDEX idx_coincidencia_estado ON egresados_identidad.coincidencia (estado);

-- Cada decisión, aparte: automática (de una ejecución), de revisión o de
-- auditoría (de una persona). Así se puede comparar el bot con las personas.
CREATE TABLE egresados_identidad.decision_coincidencia (
  id_decision     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_coincidencia INT UNSIGNED NOT NULL,
  tipo_decision   VARCHAR(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  resultado       VARCHAR(17) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_ejecucion    INT UNSIGNED NULL,
  id_responsable  INT UNSIGNED NULL,
  motivo          VARCHAR(1000) NULL,
  fecha_hora      DATETIME NOT NULL,
  CONSTRAINT pk_decision_coincidencia PRIMARY KEY (id_decision),
  CONSTRAINT fk_decision_coincidencia_coincidencia FOREIGN KEY (id_coincidencia)
    REFERENCES egresados_identidad.coincidencia (id_coincidencia) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_decision_coincidencia_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_decision_coincidencia_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_decision_coincidencia_tipo CHECK (tipo_decision IN ('AUTOMATICA', 'REVISION', 'AUDITORIA')),
  CONSTRAINT ck_decision_coincidencia_resultado CHECK (resultado IN ('ACEPTAR', 'RECHAZAR', 'ENVIAR_A_REVISION')),
  CONSTRAINT ck_decision_coincidencia_autor CHECK (
    (tipo_decision = 'AUTOMATICA' AND id_ejecucion IS NOT NULL AND id_responsable IS NULL)
    OR (tipo_decision <> 'AUTOMATICA' AND id_ejecucion IS NULL AND id_responsable IS NOT NULL)),
  CONSTRAINT ck_decision_coincidencia_revision CHECK (resultado <> 'ENVIAR_A_REVISION' OR tipo_decision = 'AUTOMATICA'),
  CONSTRAINT ck_decision_coincidencia_motivo_rechazo CHECK (resultado <> 'RECHAZAR' OR motivo IS NOT NULL),
  CONSTRAINT ck_decision_coincidencia_motivo CHECK (motivo <> '')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Constancia de una revocatoria o supresión. No tiene llave hacia la
-- persona, a propósito: debe sobrevivir al borrado.
CREATE TABLE egresados_identidad.solicitud_supresion (
  id_solicitud_supresion INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo_solicitud         VARCHAR(11) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  canal_solicitud        VARCHAR(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  fecha_hora_solicitud   DATETIME NOT NULL,
  fecha_hora_atencion    DATETIME NULL,
  id_responsable         INT UNSIGNED NULL,
  observacion            VARCHAR(1000) NULL,
  CONSTRAINT pk_solicitud_supresion PRIMARY KEY (id_solicitud_supresion),
  CONSTRAINT fk_solicitud_supresion_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_solicitud_supresion_tipo CHECK (tipo_solicitud IN ('REVOCATORIA', 'SUPRESION')),
  CONSTRAINT ck_solicitud_supresion_canal CHECK (canal_solicitud IN ('CORREO', 'FORMULARIO', 'ESCRITO', 'OTRO')),
  CONSTRAINT ck_solicitud_supresion_fechas CHECK (fecha_hora_atencion >= fecha_hora_solicitud),
  CONSTRAINT ck_solicitud_supresion_responsable CHECK (fecha_hora_atencion IS NULL OR id_responsable IS NOT NULL),
  CONSTRAINT ck_solicitud_supresion_observacion CHECK (observacion <> '')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- Lista de no contactar. La huella no es única: una persona puede revocar
-- más de una vez. Se consulta por (tipo_huella, huella).
CREATE TABLE egresados_identidad.huella_no_contactar (
  id_huella              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_solicitud_supresion INT UNSIGNED NOT NULL,
  tipo_huella            VARCHAR(9) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  huella                 CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  CONSTRAINT pk_huella_no_contactar PRIMARY KEY (id_huella),
  CONSTRAINT fk_huella_no_contactar_solicitud FOREIGN KEY (id_solicitud_supresion)
    REFERENCES egresados_identidad.solicitud_supresion (id_solicitud_supresion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_huella_no_contactar_tipo CHECK (tipo_huella IN ('DOCUMENTO', 'URL', 'CORREO')),
  CONSTRAINT ck_huella_no_contactar_huella CHECK (huella REGEXP '^[0-9a-f]{64}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE INDEX idx_huella_no_contactar_tipo_huella ON egresados_identidad.huella_no_contactar (tipo_huella, huella);

-- =====================================================================
-- Base egresados: capturas y su contenido
-- =====================================================================

-- Una foto del perfil. Las llaves compuestas garantizan, sin código, que:
--   * el perfil se comparó con ese mismo egresado (fk_captura_coincidencia);
--   * la autorización es de ese mismo egresado (fk_captura_autorizacion).
-- El PDF temporal se guarda con id_captura como nombre: su ruta no se almacena.
CREATE TABLE egresados.captura (
  id_captura                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_egresado                INT UNSIGNED NOT NULL,
  id_perfil                  INT UNSIGNED NULL,
  codigo_fuente              VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_autorizacion            INT UNSIGNED NULL,
  id_ejecucion               INT UNSIGNED NULL,
  id_responsable             INT UNSIGNED NULL,
  fecha_hora_captura         DATETIME NOT NULL,
  estado                     VARCHAR(11) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  situacion_declarada        VARCHAR(15) CHARACTER SET ascii COLLATE ascii_bin NULL,
  huella_archivo             CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL,
  fecha_hora_borrado_archivo DATETIME NULL,
  CONSTRAINT pk_captura PRIMARY KEY (id_captura),
  CONSTRAINT uq_captura_egresado UNIQUE (id_captura, id_egresado),
  CONSTRAINT uq_captura_huella_archivo UNIQUE (huella_archivo),
  CONSTRAINT fk_captura_egresado FOREIGN KEY (id_egresado)
    REFERENCES egresados.egresado (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_captura_coincidencia FOREIGN KEY (id_egresado, id_perfil)
    REFERENCES egresados_identidad.coincidencia (id_egresado, id_perfil) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_captura_fuente FOREIGN KEY (codigo_fuente)
    REFERENCES egresados.cat_fuente (codigo_fuente) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_captura_autorizacion FOREIGN KEY (id_autorizacion, id_egresado)
    REFERENCES egresados_identidad.autorizacion (id_autorizacion, id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_captura_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_captura_responsable FOREIGN KEY (id_responsable)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_captura_autor CHECK ((id_ejecucion IS NULL) <> (id_responsable IS NULL)),
  CONSTRAINT ck_captura_estado CHECK (estado IN ('RECIBIDA', 'EN_REVISION', 'VERIFICADA', 'RECHAZADA')),
  CONSTRAINT ck_captura_situacion CHECK (situacion_declarada IN ('EMPLEADO', 'INDEPENDIENTE', 'ESTUDIANDO', 'BUSCANDO_EMPLEO', 'OTRA')),
  CONSTRAINT ck_captura_huella_archivo CHECK (huella_archivo REGEXP '^[0-9a-f]{64}$'),
  CONSTRAINT ck_captura_borrado_archivo CHECK (fecha_hora_borrado_archivo IS NULL OR huella_archivo IS NOT NULL),
  CONSTRAINT ck_captura_fecha_borrado CHECK (fecha_hora_borrado_archivo >= fecha_hora_captura)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE INDEX idx_captura_egresado_estado_fecha ON egresados.captura (id_egresado, estado, fecha_hora_captura);

-- Un cargo dentro de una captura. Cuatro clasificaciones con el mismo
-- patrón: <x>_propuesto, metodo_<x>, confianza_<x> y el valor final <x>.
-- es_actual no se guarda: es 1 cuando anio_fin está vacío ("Present").
CREATE TABLE egresados.experiencia (
  id_experiencia             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_captura                 INT UNSIGNED NOT NULL,
  cargo_original             VARCHAR(300) NOT NULL,
  organizacion_original      VARCHAR(300) NULL,
  ubicacion_original         VARCHAR(300) NULL,
  anio_inicio                SMALLINT NOT NULL,
  mes_inicio                 TINYINT NULL,
  anio_fin                   SMALLINT NULL,
  mes_fin                    TINYINT NULL,
  es_actual                  TINYINT AS (anio_fin IS NULL) VIRTUAL,
  tipo_vinculo               VARCHAR(13) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_organizacion_propuesto  INT UNSIGNED NULL,
  metodo_organizacion        VARCHAR(11) CHARACTER SET ascii COLLATE ascii_bin NULL,
  confianza_organizacion     DECIMAL(4,3) NULL,
  id_organizacion            INT UNSIGNED NULL,
  codigo_ocupacion_propuesto VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NULL,
  metodo_ocupacion           VARCHAR(11) CHARACTER SET ascii COLLATE ascii_bin NULL,
  confianza_ocupacion        DECIMAL(4,3) NULL,
  codigo_ocupacion           VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NULL,
  codigo_ubicacion_propuesto VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NULL,
  metodo_ubicacion           VARCHAR(11) CHARACTER SET ascii COLLATE ascii_bin NULL,
  confianza_ubicacion        DECIMAL(4,3) NULL,
  codigo_ubicacion           VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NULL,
  codigo_area_propuesto      VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
  metodo_area                VARCHAR(11) CHARACTER SET ascii COLLATE ascii_bin NULL,
  confianza_area             DECIMAL(4,3) NULL,
  codigo_area                VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
  id_ejecucion_clasificacion INT UNSIGNED NULL,
  CONSTRAINT pk_experiencia PRIMARY KEY (id_experiencia),
  CONSTRAINT fk_experiencia_captura FOREIGN KEY (id_captura)
    REFERENCES egresados.captura (id_captura) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_experiencia_organizacion_propuesta FOREIGN KEY (id_organizacion_propuesto)
    REFERENCES egresados.cat_organizacion (id_organizacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_experiencia_organizacion FOREIGN KEY (id_organizacion)
    REFERENCES egresados.cat_organizacion (id_organizacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_experiencia_ocupacion_propuesta FOREIGN KEY (codigo_ocupacion_propuesto)
    REFERENCES egresados.cat_ocupacion (codigo_ocupacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_experiencia_ocupacion FOREIGN KEY (codigo_ocupacion)
    REFERENCES egresados.cat_ocupacion (codigo_ocupacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_experiencia_ubicacion_propuesta FOREIGN KEY (codigo_ubicacion_propuesto)
    REFERENCES egresados.cat_ubicacion (codigo_ubicacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_experiencia_ubicacion FOREIGN KEY (codigo_ubicacion)
    REFERENCES egresados.cat_ubicacion (codigo_ubicacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_experiencia_area_propuesta FOREIGN KEY (codigo_area_propuesto)
    REFERENCES egresados.cat_area_desempeno (codigo_area) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_experiencia_area FOREIGN KEY (codigo_area)
    REFERENCES egresados.cat_area_desempeno (codigo_area) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_experiencia_ejecucion FOREIGN KEY (id_ejecucion_clasificacion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_experiencia_cargo CHECK (cargo_original <> '' AND CHAR_LENGTH(cargo_original) = CHAR_LENGTH(TRIM(cargo_original))),
  CONSTRAINT ck_experiencia_organizacion_original CHECK (organizacion_original <> '' AND CHAR_LENGTH(organizacion_original) = CHAR_LENGTH(TRIM(organizacion_original))),
  CONSTRAINT ck_experiencia_ubicacion_original CHECK (ubicacion_original <> '' AND CHAR_LENGTH(ubicacion_original) = CHAR_LENGTH(TRIM(ubicacion_original))),
  CONSTRAINT ck_experiencia_anio_inicio CHECK (anio_inicio BETWEEN 1940 AND 2100),
  CONSTRAINT ck_experiencia_anio_fin CHECK (anio_fin BETWEEN 1940 AND 2100),
  CONSTRAINT ck_experiencia_mes_inicio CHECK (mes_inicio BETWEEN 1 AND 12),
  CONSTRAINT ck_experiencia_mes_fin CHECK (mes_fin BETWEEN 1 AND 12),
  CONSTRAINT ck_experiencia_fin_despues_inicio CHECK (anio_fin IS NULL OR anio_fin >= anio_inicio),
  CONSTRAINT ck_experiencia_mes_fin_con_anio CHECK (mes_fin IS NULL OR anio_fin IS NOT NULL),
  CONSTRAINT ck_experiencia_meses CHECK (
    anio_fin IS NULL OR anio_fin > anio_inicio OR mes_inicio IS NULL OR mes_fin IS NULL OR mes_fin >= mes_inicio),
  CONSTRAINT ck_experiencia_tipo_vinculo CHECK (tipo_vinculo IN ('EMPLEO', 'PRACTICA', 'INDEPENDIENTE', 'VOLUNTARIADO')),
  CONSTRAINT ck_experiencia_metodo_organizacion CHECK (metodo_organizacion IN ('DICCIONARIO', 'IA')),
  CONSTRAINT ck_experiencia_metodo_ocupacion CHECK (metodo_ocupacion IN ('DICCIONARIO', 'IA')),
  CONSTRAINT ck_experiencia_metodo_ubicacion CHECK (metodo_ubicacion IN ('DICCIONARIO', 'IA')),
  CONSTRAINT ck_experiencia_metodo_area CHECK (metodo_area IN ('IA')),
  CONSTRAINT ck_experiencia_confianza_organizacion CHECK (confianza_organizacion BETWEEN 0 AND 1),
  CONSTRAINT ck_experiencia_confianza_ocupacion CHECK (confianza_ocupacion BETWEEN 0 AND 1),
  CONSTRAINT ck_experiencia_confianza_ubicacion CHECK (confianza_ubicacion BETWEEN 0 AND 1),
  CONSTRAINT ck_experiencia_confianza_area CHECK (confianza_area BETWEEN 0 AND 1),
  -- La propuesta, su método y su confianza van juntos
  CONSTRAINT ck_experiencia_propuesta_organizacion CHECK (
    (id_organizacion_propuesto IS NULL) = (metodo_organizacion IS NULL) AND (metodo_organizacion IS NULL) = (confianza_organizacion IS NULL)),
  CONSTRAINT ck_experiencia_propuesta_ocupacion CHECK (
    (codigo_ocupacion_propuesto IS NULL) = (metodo_ocupacion IS NULL) AND (metodo_ocupacion IS NULL) = (confianza_ocupacion IS NULL)),
  CONSTRAINT ck_experiencia_propuesta_ubicacion CHECK (
    (codigo_ubicacion_propuesto IS NULL) = (metodo_ubicacion IS NULL) AND (metodo_ubicacion IS NULL) = (confianza_ubicacion IS NULL)),
  CONSTRAINT ck_experiencia_propuesta_area CHECK (
    (codigo_area_propuesto IS NULL) = (metodo_area IS NULL) AND (metodo_area IS NULL) = (confianza_area IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE TABLE egresados.estudio_declarado (
  id_estudio                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_captura                 INT UNSIGNED NOT NULL,
  institucion_original       VARCHAR(300) NOT NULL,
  programa_original          VARCHAR(300) NULL,
  anio_inicio                SMALLINT NULL,
  anio_fin                   SMALLINT NULL,
  codigo_nivel               VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_programa                INT UNSIGNED NULL,
  id_organizacion_propuesto  INT UNSIGNED NULL,
  metodo_organizacion        VARCHAR(11) CHARACTER SET ascii COLLATE ascii_bin NULL,
  confianza_organizacion     DECIMAL(4,3) NULL,
  id_organizacion            INT UNSIGNED NULL,
  id_ejecucion_clasificacion INT UNSIGNED NULL,
  CONSTRAINT pk_estudio_declarado PRIMARY KEY (id_estudio),
  CONSTRAINT fk_estudio_declarado_captura FOREIGN KEY (id_captura)
    REFERENCES egresados.captura (id_captura) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_estudio_declarado_nivel FOREIGN KEY (codigo_nivel)
    REFERENCES egresados.cat_nivel_formacion (codigo_nivel) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_estudio_declarado_programa FOREIGN KEY (id_programa)
    REFERENCES egresados.cat_programa (id_programa) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_estudio_declarado_organizacion_propuesta FOREIGN KEY (id_organizacion_propuesto)
    REFERENCES egresados.cat_organizacion (id_organizacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_estudio_declarado_organizacion FOREIGN KEY (id_organizacion)
    REFERENCES egresados.cat_organizacion (id_organizacion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_estudio_declarado_ejecucion FOREIGN KEY (id_ejecucion_clasificacion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_estudio_declarado_institucion CHECK (institucion_original <> '' AND CHAR_LENGTH(institucion_original) = CHAR_LENGTH(TRIM(institucion_original))),
  CONSTRAINT ck_estudio_declarado_programa CHECK (programa_original <> '' AND CHAR_LENGTH(programa_original) = CHAR_LENGTH(TRIM(programa_original))),
  CONSTRAINT ck_estudio_declarado_anio_inicio CHECK (anio_inicio BETWEEN 1940 AND 2100),
  CONSTRAINT ck_estudio_declarado_anio_fin CHECK (anio_fin BETWEEN 1940 AND 2100),
  CONSTRAINT ck_estudio_declarado_anios CHECK (anio_fin IS NULL OR anio_inicio IS NULL OR anio_fin >= anio_inicio),
  CONSTRAINT ck_estudio_declarado_metodo CHECK (metodo_organizacion IN ('DICCIONARIO', 'IA')),
  CONSTRAINT ck_estudio_declarado_confianza CHECK (confianza_organizacion BETWEEN 0 AND 1),
  CONSTRAINT ck_estudio_declarado_propuesta CHECK (
    (id_organizacion_propuesto IS NULL) = (metodo_organizacion IS NULL) AND (metodo_organizacion IS NULL) = (confianza_organizacion IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

-- =====================================================================
-- Base egresados: seguimiento, calidad y bitácora
-- =====================================================================

-- La llave compuesta (id_captura, id_egresado) garantiza que la captura
-- que responde la solicitud sea del mismo egresado.
CREATE TABLE egresados.solicitud_actualizacion (
  id_solicitud         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_egresado          INT UNSIGNED NOT NULL,
  codigo_momento       VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_ejecucion         INT UNSIGNED NOT NULL,
  fecha_hora_envio     DATETIME NOT NULL,
  numero_recordatorios INT NOT NULL DEFAULT 0,
  estado_envio         VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  huella_token         CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  fecha_vencimiento    DATE NOT NULL,
  respuesta            VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NULL,
  fecha_hora_respuesta DATETIME NULL,
  id_captura           INT UNSIGNED NULL,
  CONSTRAINT pk_solicitud_actualizacion PRIMARY KEY (id_solicitud),
  CONSTRAINT uq_solicitud_actualizacion_egresado_momento UNIQUE (id_egresado, codigo_momento),
  CONSTRAINT uq_solicitud_actualizacion_token UNIQUE (huella_token),
  CONSTRAINT fk_solicitud_actualizacion_egresado FOREIGN KEY (id_egresado)
    REFERENCES egresados.egresado (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_solicitud_actualizacion_momento FOREIGN KEY (codigo_momento)
    REFERENCES egresados.cat_momento_seguimiento (codigo_momento) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_solicitud_actualizacion_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_solicitud_actualizacion_captura FOREIGN KEY (id_captura, id_egresado)
    REFERENCES egresados.captura (id_captura, id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT ck_solicitud_actualizacion_recordatorios CHECK (numero_recordatorios >= 0),
  CONSTRAINT ck_solicitud_actualizacion_estado_envio CHECK (estado_envio IN ('ENVIADA', 'REBOTADA')),
  CONSTRAINT ck_solicitud_actualizacion_token CHECK (huella_token REGEXP '^[0-9a-f]{64}$'),
  CONSTRAINT ck_solicitud_actualizacion_vencimiento CHECK (fecha_vencimiento > DATE(fecha_hora_envio)),
  CONSTRAINT ck_solicitud_actualizacion_respuesta_valor CHECK (respuesta IN ('CONFIRMO_SIN_CAMBIOS', 'ACTUALIZO')),
  CONSTRAINT ck_solicitud_actualizacion_respuesta CHECK (
    (respuesta IS NULL AND fecha_hora_respuesta IS NULL AND id_captura IS NULL)
    OR (respuesta IS NOT NULL AND fecha_hora_respuesta IS NOT NULL AND id_captura IS NOT NULL)),
  CONSTRAINT ck_solicitud_actualizacion_respuesta_fechas CHECK (
    fecha_hora_respuesta IS NULL
    OR (fecha_hora_respuesta >= fecha_hora_envio AND DATE(fecha_hora_respuesta) <= fecha_vencimiento))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE INDEX idx_solicitud_actualizacion_momento_respuesta ON egresados.solicitud_actualizacion (codigo_momento, respuesta);

CREATE TABLE egresados.incidencia (
  id_incidencia           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo_tipo_incidencia  VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_egresado             INT UNSIGNED NOT NULL,
  id_captura              INT UNSIGNED NULL,
  campo_afectado          VARCHAR(300) NULL,
  descripcion             VARCHAR(1000) NOT NULL,
  estado                  VARCHAR(11) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_ejecucion            INT UNSIGNED NULL,
  id_responsable_apertura INT UNSIGNED NULL,
  id_responsable_asignado INT UNSIGNED NULL,
  fecha_hora_apertura     DATETIME NOT NULL,
  fecha_hora_cierre       DATETIME NULL,
  solucion                VARCHAR(1000) NULL,
  CONSTRAINT pk_incidencia PRIMARY KEY (id_incidencia),
  CONSTRAINT fk_incidencia_tipo FOREIGN KEY (codigo_tipo_incidencia)
    REFERENCES egresados.cat_tipo_incidencia (codigo_tipo_incidencia) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_incidencia_egresado FOREIGN KEY (id_egresado)
    REFERENCES egresados.egresado (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_incidencia_captura FOREIGN KEY (id_captura, id_egresado)
    REFERENCES egresados.captura (id_captura, id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_incidencia_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_incidencia_responsable_apertura FOREIGN KEY (id_responsable_apertura)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_incidencia_responsable_asignado FOREIGN KEY (id_responsable_asignado)
    REFERENCES egresados.responsable (id_responsable) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_incidencia_campo CHECK (campo_afectado <> '' AND CHAR_LENGTH(campo_afectado) = CHAR_LENGTH(TRIM(campo_afectado))),
  CONSTRAINT ck_incidencia_descripcion CHECK (descripcion <> ''),
  CONSTRAINT ck_incidencia_estado CHECK (estado IN ('ABIERTA', 'EN_REVISION', 'RESUELTA', 'DESCARTADA')),
  CONSTRAINT ck_incidencia_autor CHECK ((id_ejecucion IS NULL) <> (id_responsable_apertura IS NULL)),
  CONSTRAINT ck_incidencia_cierre CHECK ((estado IN ('RESUELTA', 'DESCARTADA')) = (fecha_hora_cierre IS NOT NULL)),
  CONSTRAINT ck_incidencia_solucion CHECK (estado NOT IN ('RESUELTA', 'DESCARTADA') OR solucion IS NOT NULL),
  CONSTRAINT ck_incidencia_solucion_texto CHECK (solucion <> ''),
  CONSTRAINT ck_incidencia_fechas CHECK (fecha_hora_cierre >= fecha_hora_apertura)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE INDEX idx_incidencia_estado_tipo ON egresados.incidencia (estado, codigo_tipo_incidencia);

-- Bitácora de la base egresados. La llenan solo los disparadores (05_bitacora.sql).
-- Un cambio manual exige motivo; uno automático, la ejecución que lo hizo.
CREATE TABLE egresados.bitacora (
  id_bitacora        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tabla              VARCHAR(300) NOT NULL,
  id_registro        VARCHAR(300) NOT NULL,
  id_egresado        INT UNSIGNED NULL,
  operacion          VARCHAR(6) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  valores_anteriores JSON NULL,
  valores_nuevos     JSON NULL,
  usuario_bd         VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  id_ejecucion       INT UNSIGNED NULL,
  motivo             VARCHAR(1000) NULL,
  fecha_hora         DATETIME NOT NULL,
  CONSTRAINT pk_bitacora PRIMARY KEY (id_bitacora),
  CONSTRAINT fk_bitacora_egresado FOREIGN KEY (id_egresado)
    REFERENCES egresados.egresado (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_bitacora_usuario FOREIGN KEY (usuario_bd)
    REFERENCES egresados.responsable (usuario_bd) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_bitacora_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_bitacora_operacion CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE')),
  CONSTRAINT ck_bitacora_valores CHECK (
    (operacion = 'INSERT' AND valores_anteriores IS NULL AND valores_nuevos IS NOT NULL)
    OR (operacion = 'UPDATE' AND valores_anteriores IS NOT NULL AND valores_nuevos IS NOT NULL)
    OR (operacion = 'DELETE' AND valores_anteriores IS NOT NULL AND valores_nuevos IS NULL)),
  CONSTRAINT ck_bitacora_motivo CHECK (id_ejecucion IS NOT NULL OR motivo IS NOT NULL),
  CONSTRAINT ck_bitacora_motivo_texto CHECK (motivo <> '')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE INDEX idx_bitacora_tabla_registro ON egresados.bitacora (tabla, id_registro);
CREATE INDEX idx_bitacora_fecha ON egresados.bitacora (fecha_hora);

-- Bitácora de la base egresados_identidad: misma estructura, en su propia
-- base, para que los valores de identidad no pasen a la base de análisis.
CREATE TABLE egresados_identidad.bitacora_identidad (
  id_bitacora        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tabla              VARCHAR(300) NOT NULL,
  id_registro        VARCHAR(300) NOT NULL,
  id_egresado        INT UNSIGNED NULL,
  operacion          VARCHAR(6) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  valores_anteriores JSON NULL,
  valores_nuevos     JSON NULL,
  usuario_bd         VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  id_ejecucion       INT UNSIGNED NULL,
  motivo             VARCHAR(1000) NULL,
  fecha_hora         DATETIME NOT NULL,
  CONSTRAINT pk_bitacora_identidad PRIMARY KEY (id_bitacora),
  CONSTRAINT fk_bitacora_identidad_identidad FOREIGN KEY (id_egresado)
    REFERENCES egresados_identidad.identidad (id_egresado) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_bitacora_identidad_usuario FOREIGN KEY (usuario_bd)
    REFERENCES egresados.responsable (usuario_bd) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_bitacora_identidad_ejecucion FOREIGN KEY (id_ejecucion)
    REFERENCES egresados.ejecucion (id_ejecucion) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_bitacora_identidad_operacion CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE')),
  CONSTRAINT ck_bitacora_identidad_valores CHECK (
    (operacion = 'INSERT' AND valores_anteriores IS NULL AND valores_nuevos IS NOT NULL)
    OR (operacion = 'UPDATE' AND valores_anteriores IS NOT NULL AND valores_nuevos IS NOT NULL)
    OR (operacion = 'DELETE' AND valores_anteriores IS NOT NULL AND valores_nuevos IS NULL)),
  CONSTRAINT ck_bitacora_identidad_motivo CHECK (id_ejecucion IS NOT NULL OR motivo IS NOT NULL),
  CONSTRAINT ck_bitacora_identidad_motivo_texto CHECK (motivo <> '')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_spanish_ai_ci;

CREATE INDEX idx_bitacora_identidad_tabla_registro ON egresados_identidad.bitacora_identidad (tabla, id_registro);
CREATE INDEX idx_bitacora_identidad_fecha ON egresados_identidad.bitacora_identidad (fecha_hora);
