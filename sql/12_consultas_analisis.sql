-- =====================================================================
-- 12_consultas_analisis.sql
-- Indicadores que la Facultad podría responder (metodología, sección 6).
-- Usan solo las vistas de análisis: las puede ejecutar el rol analista.
-- =====================================================================
--
-- Regla de celda mínima: ningún indicador se calcula sobre menos de
-- @celda_minima personas, porque un porcentaje sobre muy pocas personas
-- las identifica (metodología, sección 6). Con los 10 egresados de
-- prueba casi todo queda por debajo de 5: así se ve la regla funcionando.
-- Para ver los resultados de prueba, bajar el umbral a 1.
--
-- Meses: para comparar fechas se usa un "índice de mes" = año * 12 + mes.
-- Si el mes no se declaró, se toma enero para un inicio y diciembre para
-- un fin, y el indicador lo marca como de menor precisión.

SET NAMES utf8mb4;

SET @celda_minima = 5;
-- SET @celda_minima = 1;

-- ---------------------------------------------------------------------
-- 1. Cobertura: egresados con grado otorgado y con captura vigente.
-- ---------------------------------------------------------------------
SELECT g.programa,
       COUNT(DISTINCT g.id_egresado) AS egresados,
       COUNT(DISTINCT cv.id_egresado) AS con_captura_vigente,
       ROUND(100 * COUNT(DISTINCT cv.id_egresado) / COUNT(DISTINCT g.id_egresado), 1) AS pct_cobertura
  FROM egresados.v_grado g
  LEFT JOIN egresados.v_captura_vigente cv ON cv.id_egresado = g.id_egresado
 GROUP BY g.programa
HAVING COUNT(DISTINCT g.id_egresado) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 2. Vinculación actual: tiene un empleo o una actividad independiente
--    vigente, o así lo declaró. Se excluyen prácticas y voluntariados.
-- ---------------------------------------------------------------------
WITH estado_actual AS (
  SELECT cv.id_egresado,
         (EXISTS (SELECT 1 FROM egresados.v_experiencia e
                   WHERE e.id_egresado = cv.id_egresado AND e.es_actual = 1
                     AND e.tipo_vinculo IN ('EMPLEO', 'INDEPENDIENTE'))
          OR cv.situacion_declarada IN ('EMPLEADO', 'INDEPENDIENTE')) AS vinculado
    FROM egresados.v_captura_vigente cv
)
SELECT g.programa,
       COUNT(DISTINCT ea.id_egresado) AS con_datos,
       SUM(ea.vinculado) AS vinculados,
       ROUND(100 * SUM(ea.vinculado) / COUNT(DISTINCT ea.id_egresado), 1) AS pct_vinculacion
  FROM estado_actual ea
  JOIN (SELECT id_egresado, MIN(programa) AS programa FROM egresados.v_grado
         WHERE nivel = 'PREGRADO' GROUP BY id_egresado) g ON g.id_egresado = ea.id_egresado
 GROUP BY g.programa
HAVING COUNT(DISTINCT ea.id_egresado) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 3. Vinculación un año después del grado (momento M1): tenía un empleo
--    o actividad independiente activa en ese mes. Solo egresados que ya
--    cumplieron el año.
-- ---------------------------------------------------------------------
WITH objetivo AS (
  SELECT g.id_egresado, g.programa,
         YEAR(DATE_ADD(g.fecha_grado, INTERVAL 1 YEAR)) * 12 + MONTH(DATE_ADD(g.fecha_grado, INTERVAL 1 YEAR)) AS mes_objetivo
    FROM egresados.v_grado g
   WHERE g.nivel = 'PREGRADO'
     AND DATE_ADD(g.fecha_grado, INTERVAL 1 YEAR) <= CURDATE()
),
vinculo AS (
  SELECT o.id_egresado, o.programa,
         EXISTS (SELECT 1 FROM egresados.v_experiencia e
                  WHERE e.id_egresado = o.id_egresado
                    AND e.tipo_vinculo IN ('EMPLEO', 'INDEPENDIENTE')
                    AND e.anio_inicio * 12 + COALESCE(e.mes_inicio, 1) <= o.mes_objetivo
                    AND (e.anio_fin IS NULL OR e.anio_fin * 12 + COALESCE(e.mes_fin, 12) >= o.mes_objetivo)) AS vinculado_m1
    FROM objetivo o
    JOIN egresados.v_captura_vigente cv ON cv.id_egresado = o.id_egresado
)
SELECT programa,
       COUNT(*) AS con_datos,
       SUM(vinculado_m1) AS vinculados_al_anio,
       ROUND(100 * SUM(vinculado_m1) / COUNT(*), 1) AS pct_vinculacion_m1
  FROM vinculo
 GROUP BY programa
HAVING COUNT(*) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 4. Sectores (sección de la CIIU) de los empleos actuales.
-- ---------------------------------------------------------------------
SELECT e.seccion_actividad,
       a.nombre AS sector,
       COUNT(DISTINCT e.id_egresado) AS egresados
  FROM egresados.v_experiencia e
  JOIN egresados.cat_actividad_economica a ON a.codigo_actividad = e.seccion_actividad
 WHERE e.es_actual = 1 AND e.tipo_vinculo IN ('EMPLEO', 'INDEPENDIENTE')
 GROUP BY e.seccion_actividad, a.nombre
HAVING COUNT(DISTINCT e.id_egresado) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 5. Ocupaciones (gran grupo de la CUOC) de los empleos actuales.
-- ---------------------------------------------------------------------
SELECT e.gran_grupo_ocupacion,
       o.nombre AS gran_grupo,
       COUNT(DISTINCT e.id_egresado) AS egresados
  FROM egresados.v_experiencia e
  JOIN egresados.cat_ocupacion o ON o.codigo_ocupacion = e.gran_grupo_ocupacion
 WHERE e.es_actual = 1 AND e.tipo_vinculo IN ('EMPLEO', 'INDEPENDIENTE')
 GROUP BY e.gran_grupo_ocupacion, o.nombre
HAVING COUNT(DISTINCT e.id_egresado) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 6. Tiempo hasta el primer empleo después del grado de pregrado, en
--    meses. Si ya trabajaba al graduarse, cuenta 0. Las prácticas no
--    cuentan. Se informa cuántos casos se calcularon sin el mes.
-- ---------------------------------------------------------------------
WITH grado_pregrado AS (
  SELECT id_egresado, programa, YEAR(fecha_grado) * 12 + MONTH(fecha_grado) AS mes_grado
    FROM egresados.v_grado
   WHERE nivel = 'PREGRADO'
),
primer_empleo AS (
  SELECT gp.id_egresado, gp.programa,
         MIN(GREATEST(0, e.anio_inicio * 12 + COALESCE(e.mes_inicio, 1) - gp.mes_grado)) AS meses,
         MAX(e.mes_inicio IS NULL) AS sin_mes
    FROM grado_pregrado gp
    JOIN egresados.v_experiencia e ON e.id_egresado = gp.id_egresado
   WHERE e.tipo_vinculo IN ('EMPLEO', 'INDEPENDIENTE')
     AND (e.anio_fin IS NULL OR e.anio_fin * 12 + COALESCE(e.mes_fin, 12) >= gp.mes_grado)
   GROUP BY gp.id_egresado, gp.programa
)
SELECT programa,
       COUNT(*) AS egresados,
       ROUND(AVG(meses), 1) AS meses_promedio,
       MIN(meses) AS minimo,
       MAX(meses) AS maximo,
       SUM(sin_mes) AS calculados_sin_mes
  FROM primer_empleo
 GROUP BY programa
HAVING COUNT(*) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 7. Pertinencia: empleos actuales en una ocupación afín al programa,
--    según la lista que define cada comité. Un código afín cubre sus
--    niveles inferiores (comparación por prefijo).
-- ---------------------------------------------------------------------
WITH empleo_actual AS (
  SELECT g.id_egresado, g.id_programa, g.programa, e.codigo_ocupacion
    FROM egresados.v_grado g
    JOIN egresados.v_experiencia e ON e.id_egresado = g.id_egresado
   WHERE e.es_actual = 1 AND e.tipo_vinculo IN ('EMPLEO', 'INDEPENDIENTE')
)
SELECT ea.programa,
       COUNT(DISTINCT ea.id_egresado) AS con_empleo,
       COUNT(DISTINCT CASE WHEN EXISTS (
               SELECT 1 FROM egresados.afinidad_programa_ocupacion a
                WHERE a.id_programa = ea.id_programa
                  AND ea.codigo_ocupacion LIKE CONCAT(a.codigo_ocupacion, '%'))
             THEN ea.id_egresado END) AS en_ocupacion_afin
  FROM empleo_actual ea
 GROUP BY ea.programa
HAVING COUNT(DISTINCT ea.id_egresado) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 8. Movilidad geográfica de los empleos actuales.
-- ---------------------------------------------------------------------
SELECT CASE
         WHEN e.pais IS NULL THEN 'No declarada'
         WHEN e.pais <> 'CO' THEN 'Exterior'
         WHEN e.departamento = '11' THEN 'Bogotá'
         ELSE 'Otra ciudad de Colombia'
       END AS lugar,
       COUNT(DISTINCT e.id_egresado) AS egresados
  FROM egresados.v_experiencia e
 WHERE e.es_actual = 1 AND e.tipo_vinculo IN ('EMPLEO', 'INDEPENDIENTE')
 GROUP BY 1
HAVING COUNT(DISTINCT e.id_egresado) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 9. Formación de posgrado: declarada en el perfil (en cualquier
--    institución) o como grado de posgrado de la Facultad.
-- ---------------------------------------------------------------------
WITH pregrado AS (
  SELECT DISTINCT id_egresado, programa FROM egresados.v_grado WHERE nivel = 'PREGRADO'
),
con_posgrado AS (
  SELECT DISTINCT p.id_egresado
    FROM pregrado p
   WHERE EXISTS (SELECT 1 FROM egresados.v_estudio s
                  WHERE s.id_egresado = p.id_egresado AND s.orden_nivel > 3)
      OR EXISTS (SELECT 1 FROM egresados.v_grado g
                  WHERE g.id_egresado = p.id_egresado AND g.nivel IN ('ESPECIALIZACION', 'MAESTRIA', 'DOCTORADO'))
)
SELECT p.programa,
       COUNT(DISTINCT p.id_egresado) AS egresados,
       COUNT(DISTINCT cp.id_egresado) AS con_posgrado
  FROM pregrado p
  LEFT JOIN con_posgrado cp ON cp.id_egresado = p.id_egresado
 GROUP BY p.programa
HAVING COUNT(DISTINCT p.id_egresado) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 10. Evolución de la trayectoria: llegada a cargos directivos (gran
--     grupo 1 de la CUOC, "directores y gerentes"), según los años desde
--     el grado.
-- ---------------------------------------------------------------------
WITH trayectoria AS (
  SELECT g.id_egresado,
         TIMESTAMPDIFF(YEAR, g.fecha_grado, CURDATE()) AS anios_desde_grado,
         EXISTS (SELECT 1 FROM egresados.v_experiencia e
                  WHERE e.id_egresado = g.id_egresado AND e.gran_grupo_ocupacion = '1') AS llego_a_directivo
    FROM egresados.v_grado g
    JOIN egresados.v_captura_vigente cv ON cv.id_egresado = g.id_egresado
   WHERE g.nivel = 'PREGRADO'
)
SELECT CASE WHEN anios_desde_grado < 5 THEN 'Menos de 5 años'
            WHEN anios_desde_grado < 10 THEN 'De 5 a 9 años'
            ELSE '10 años o más' END AS desde_el_grado,
       COUNT(*) AS egresados,
       SUM(llego_a_directivo) AS en_cargo_directivo
  FROM trayectoria
 GROUP BY 1
HAVING COUNT(*) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 11. Brecha por sexo en la vinculación actual.
-- ---------------------------------------------------------------------
WITH estado_actual AS (
  SELECT cv.id_egresado,
         (EXISTS (SELECT 1 FROM egresados.v_experiencia e
                   WHERE e.id_egresado = cv.id_egresado AND e.es_actual = 1
                     AND e.tipo_vinculo IN ('EMPLEO', 'INDEPENDIENTE'))
          OR cv.situacion_declarada IN ('EMPLEADO', 'INDEPENDIENTE')) AS vinculado
    FROM egresados.v_captura_vigente cv
)
SELECT COALESCE(g.sexo, 'No registrado') AS sexo,
       COUNT(DISTINCT ea.id_egresado) AS con_datos,
       SUM(ea.vinculado) AS vinculados
  FROM estado_actual ea
  JOIN (SELECT id_egresado, MIN(sexo) AS sexo FROM egresados.v_grado GROUP BY id_egresado) g
    ON g.id_egresado = ea.id_egresado
 GROUP BY COALESCE(g.sexo, 'No registrado')
HAVING COUNT(DISTINCT ea.id_egresado) >= @celda_minima;

-- ---------------------------------------------------------------------
-- 12. Contraste con una fuente oficial: la vinculación al año medida con
--     LinkedIn frente al indicador agregado publicado (aquí, ficticio).
--     La diferencia estima el sesgo de medir con LinkedIn.
-- ---------------------------------------------------------------------
SELECT p.nombre AS programa,
       ie.nombre_indicador,
       ie.anio_cohorte,
       ie.valor AS valor_fuente_oficial,
       ie.referencia
  FROM egresados.indicador_externo ie
  JOIN egresados.cat_programa p ON p.id_programa = ie.id_programa;

-- ---------------------------------------------------------------------
-- 13. Calidad del cruce, sin datos de identidad: decisiones por nivel.
-- ---------------------------------------------------------------------
SELECT nivel, tipo_decision, resultado, decisiones
  FROM egresados.v_resumen_decisiones
 ORDER BY FIELD(nivel, 'ALTO', 'MEDIO', 'BAJO', 'IMPOSIBLE'), tipo_decision, resultado;
