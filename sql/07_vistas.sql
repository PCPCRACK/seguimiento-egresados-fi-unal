-- =====================================================================
-- 07_vistas.sql
-- Vistas de análisis: lo único que lee el rol de analista.
-- Modelo de datos, paso 3.9.
-- =====================================================================
--
-- Por qué vistas: el analista solo ve datos verificados y ya
-- clasificados, sin tener que saber filtrarlos. Las vistas se ejecutan
-- con los permisos de su dueño (SQL SECURITY DEFINER), así que el
-- analista no necesita permisos sobre las tablas, ni ninguno sobre la
-- base de identidad.

SET NAMES utf8mb4;

-- Grados otorgados, con el programa, su nivel y el sexo del egresado.
CREATE OR REPLACE DEFINER = 'definidor_egresados'@'localhost' SQL SECURITY DEFINER
VIEW egresados.v_grado AS
SELECT g.id_grado,
       g.id_egresado,
       e.sexo,
       g.id_programa,
       p.nombre AS programa,
       p.codigo_nivel AS nivel,
       g.anio_ingreso,
       g.semestre_ingreso,
       g.fecha_grado,
       YEAR(g.fecha_grado) AS anio_grado
  FROM egresados.grado g
  JOIN egresados.egresado e ON e.id_egresado = g.id_egresado
  JOIN egresados.cat_programa p ON p.id_programa = g.id_programa
 WHERE g.estado = 'OTORGADO';

-- La captura vigente de cada egresado: su última captura verificada.
-- fecha_ultima_verificacion incluye los "sigo igual" sobre esa captura.
CREATE OR REPLACE DEFINER = 'definidor_egresados'@'localhost' SQL SECURITY DEFINER
VIEW egresados.v_captura_vigente AS
SELECT c.id_captura,
       c.id_egresado,
       c.codigo_fuente,
       c.fecha_hora_captura,
       c.situacion_declarada,
       GREATEST(c.fecha_hora_captura,
                COALESCE((SELECT MAX(s.fecha_hora_respuesta)
                            FROM egresados.solicitud_actualizacion s
                           WHERE s.id_captura = c.id_captura
                             AND s.respuesta = 'CONFIRMO_SIN_CAMBIOS'),
                         c.fecha_hora_captura)) AS fecha_ultima_verificacion
  FROM (SELECT x.*,
               ROW_NUMBER() OVER (PARTITION BY x.id_egresado
                                  ORDER BY x.fecha_hora_captura DESC, x.id_captura DESC) AS orden
          FROM egresados.captura x
         WHERE x.estado = 'VERIFICADA') c
 WHERE c.orden = 1;

-- Experiencias de las capturas vigentes, con las clasificaciones finales
-- y los niveles superiores ya resueltos: sección de la CIIU (el sector),
-- gran grupo de la ocupación, y país y departamento de la ubicación.
CREATE OR REPLACE DEFINER = 'definidor_egresados'@'localhost' SQL SECURITY DEFINER
VIEW egresados.v_experiencia AS
SELECT ex.id_experiencia,
       cv.id_egresado,
       ex.id_captura,
       ex.anio_inicio,
       ex.mes_inicio,
       ex.anio_fin,
       ex.mes_fin,
       ex.es_actual,
       ex.tipo_vinculo,
       ex.id_organizacion,
       o.nombre AS organizacion,
       o.codigo_actividad,
       CASE
         WHEN o.codigo_actividad REGEXP '^[A-U]$' THEN o.codigo_actividad
         ELSE dv.codigo_padre
       END AS seccion_actividad,
       ex.codigo_ocupacion,
       LEFT(ex.codigo_ocupacion, 1) AS gran_grupo_ocupacion,
       ex.codigo_ubicacion,
       CASE
         WHEN ex.codigo_ubicacion IS NULL THEN NULL
         WHEN ex.codigo_ubicacion REGEXP '^[A-Z]{2}$' THEN ex.codigo_ubicacion
         ELSE 'CO'
       END AS pais,
       CASE
         WHEN ex.codigo_ubicacion REGEXP '^[0-9]' THEN LEFT(ex.codigo_ubicacion, 2)
       END AS departamento,
       ex.codigo_area
  FROM egresados.v_captura_vigente cv
  JOIN egresados.experiencia ex ON ex.id_captura = cv.id_captura
  LEFT JOIN egresados.cat_organizacion o ON o.id_organizacion = ex.id_organizacion
  LEFT JOIN egresados.cat_actividad_economica dv
         ON o.codigo_actividad REGEXP '^[0-9]' AND dv.codigo_actividad = LEFT(o.codigo_actividad, 2);

-- Estudios declarados de las capturas vigentes, con el orden del nivel.
CREATE OR REPLACE DEFINER = 'definidor_egresados'@'localhost' SQL SECURITY DEFINER
VIEW egresados.v_estudio AS
SELECT d.id_estudio,
       cv.id_egresado,
       d.id_captura,
       d.anio_inicio,
       d.anio_fin,
       d.codigo_nivel,
       n.orden AS orden_nivel,
       d.id_programa,
       d.id_organizacion,
       o.nombre AS institucion,
       o.codigo_pais AS pais_institucion
  FROM egresados.v_captura_vigente cv
  JOIN egresados.estudio_declarado d ON d.id_captura = cv.id_captura
  JOIN egresados.cat_nivel_formacion n ON n.codigo_nivel = d.codigo_nivel
  LEFT JOIN egresados.cat_organizacion o ON o.id_organizacion = d.id_organizacion;

-- Resumen de las decisiones sobre coincidencias, sin ningún dato de
-- identidad: permite al analista medir la calidad del cruce (por ejemplo,
-- cuántas veces la auditoría contradice al nivel alto).
CREATE OR REPLACE DEFINER = 'definidor_egresados'@'localhost' SQL SECURITY DEFINER
VIEW egresados.v_resumen_decisiones AS
SELECT c.nivel,
       d.tipo_decision,
       d.resultado,
       COUNT(*) AS decisiones
  FROM egresados_identidad.decision_coincidencia d
  JOIN egresados_identidad.coincidencia c ON c.id_coincidencia = d.id_coincidencia
 GROUP BY c.nivel, d.tipo_decision, d.resultado;
