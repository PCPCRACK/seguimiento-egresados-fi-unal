-- =====================================================================
-- 11_consultas_calidad.sql
-- Consultas de control de calidad (enunciado, punto 3.2.5).
-- Solo leen. Las ejecuta el revisor o el administrador, porque varias
-- miran la base de identidad. Con los datos de prueba, el comentario de
-- cada consulta dice qué debería salir.
-- =====================================================================

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- 1. Cola de revisión: coincidencias pendientes y el motivo de la última
--    decisión. Esperado: la de Valentina (la URL del PDF no coincide).
-- ---------------------------------------------------------------------
SELECT c.id_coincidencia,
       c.id_egresado,
       c.nivel,
       c.puntaje_total,
       (SELECT d.motivo
          FROM egresados_identidad.decision_coincidencia d
         WHERE d.id_coincidencia = c.id_coincidencia
         ORDER BY d.fecha_hora DESC, d.id_decision DESC
         LIMIT 1) AS motivo_ultima_decision
  FROM egresados_identidad.coincidencia c
 WHERE c.estado = 'PENDIENTE';

-- ---------------------------------------------------------------------
-- 2. Capturas sin verificar y sus incidencias abiertas.
--    Esperado: Valentina (URL_DISTINTA) y Felipe (INCOMPLETA).
-- ---------------------------------------------------------------------
SELECT cap.id_captura,
       cap.id_egresado,
       cap.codigo_fuente,
       cap.estado AS estado_captura,
       i.codigo_tipo_incidencia,
       i.campo_afectado,
       i.estado AS estado_incidencia
  FROM egresados.captura cap
  LEFT JOIN egresados.incidencia i
         ON i.id_captura = cap.id_captura AND i.estado IN ('ABIERTA', 'EN_REVISION')
 WHERE cap.estado IN ('RECIBIDA', 'EN_REVISION');

-- ---------------------------------------------------------------------
-- 3. Incidencias por dimensión de calidad (Ley 1581, art. 4 lit. d),
--    tipo y estado.
-- ---------------------------------------------------------------------
SELECT t.dimension,
       i.codigo_tipo_incidencia,
       i.estado,
       COUNT(*) AS incidencias
  FROM egresados.incidencia i
  JOIN egresados.cat_tipo_incidencia t ON t.codigo_tipo_incidencia = i.codigo_tipo_incidencia
 GROUP BY t.dimension, i.codigo_tipo_incidencia, i.estado
 ORDER BY t.dimension, i.codigo_tipo_incidencia, i.estado;

-- ---------------------------------------------------------------------
-- 4. Posibles personas duplicadas en el registro oficial: mismo nombre,
--    mismo programa y mismo año de grado. La intercalación en español
--    ignora tildes y mayúsculas, así que "José" y "JOSE" se agrupan.
--    Esperado: vacío.
-- ---------------------------------------------------------------------
SELECT i.nombres,
       i.primer_apellido,
       g.id_programa,
       YEAR(g.fecha_grado) AS anio_grado,
       COUNT(DISTINCT i.id_egresado) AS personas,
       GROUP_CONCAT(DISTINCT i.id_egresado) AS ids
  FROM egresados_identidad.identidad i
  JOIN egresados.grado g ON g.id_egresado = i.id_egresado
 GROUP BY i.nombres, i.primer_apellido, g.id_programa, YEAR(g.fecha_grado)
HAVING COUNT(DISTINCT i.id_egresado) > 1;

-- ---------------------------------------------------------------------
-- 5. Egresados desactualizados: el último momento de seguimiento que ya
--    debió ocurrir (M1 en adelante) es posterior a su última verificación.
--    El M0 es la captura del grado, que se hace antes de la ceremonia.
--    Esperado: Laura (M5), Andrés (M3), Sebastián (M3; su M1 rebotó) y
--    Mariana (M1); y sin captura verificada: Valentina, Diana y Paula.
-- ---------------------------------------------------------------------
WITH ultimo_grado AS (
  SELECT id_egresado, MAX(fecha_grado) AS fecha_grado
    FROM egresados.grado
   WHERE estado = 'OTORGADO'
   GROUP BY id_egresado
),
momento_debido AS (
  SELECT ug.id_egresado,
         MAX(m.anios_desde_grado) AS anios,
         MAX(DATE_ADD(ug.fecha_grado, INTERVAL m.anios_desde_grado YEAR)) AS fecha_debida
    FROM ultimo_grado ug
    JOIN egresados.cat_momento_seguimiento m
      ON m.es_activo = 1
     AND m.anios_desde_grado >= 1
     AND DATE_ADD(ug.fecha_grado, INTERVAL m.anios_desde_grado YEAR) <= CURDATE()
   GROUP BY ug.id_egresado
)
SELECT md.id_egresado,
       CONCAT('M', md.anios) AS momento_debido,
       md.fecha_debida,
       cv.fecha_ultima_verificacion,
       CASE WHEN cv.id_captura IS NULL THEN 'Sin captura verificada'
            ELSE 'Verificación anterior al momento' END AS situacion
  FROM momento_debido md
  LEFT JOIN egresados.v_captura_vigente cv ON cv.id_egresado = md.id_egresado
 WHERE cv.fecha_ultima_verificacion IS NULL
    OR cv.fecha_ultima_verificacion < md.fecha_debida
 ORDER BY md.fecha_debida;

-- ---------------------------------------------------------------------
-- 6. Faltantes: completitud de las experiencias de las capturas vigentes.
--    Un vacío en un dato declarado no es un error: es "no declarado".
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS experiencias,
       SUM(mes_inicio IS NULL) AS sin_mes_de_inicio,
       SUM(id_organizacion IS NULL) AS sin_organizacion,
       SUM(codigo_ubicacion IS NULL) AS sin_ubicacion,
       ROUND(100 * SUM(mes_inicio IS NOT NULL) / COUNT(*), 1) AS pct_con_mes
  FROM egresados.v_experiencia;

-- Capturas vigentes sin situación laboral declarada, por fuente
-- (en el canal C no se pregunta).
SELECT codigo_fuente,
       COUNT(*) AS capturas,
       SUM(situacion_declarada IS NULL) AS sin_situacion_declarada
  FROM egresados.v_captura_vigente
 GROUP BY codigo_fuente;

-- ---------------------------------------------------------------------
-- 7. Grados con una duración menor que la mínima del programa: sería un
--    error del registro oficial. Esperado: vacío.
-- ---------------------------------------------------------------------
SELECT g.id_grado,
       g.id_egresado,
       p.nombre AS programa,
       (YEAR(g.fecha_grado) - g.anio_ingreso) * 2
         + (IF(MONTH(g.fecha_grado) <= 6, 1, 2) - g.semestre_ingreso) AS semestres_aproximados,
       p.semestres_minimos
  FROM egresados.grado g
  JOIN egresados.cat_programa p ON p.id_programa = g.id_programa
 WHERE g.estado = 'OTORGADO'
   AND g.anio_ingreso IS NOT NULL
   AND g.semestre_ingreso IS NOT NULL
   AND (YEAR(g.fecha_grado) - g.anio_ingreso) * 2
         + (IF(MONTH(g.fecha_grado) <= 6, 1, 2) - g.semestre_ingreso) < p.semestres_minimos;

-- ---------------------------------------------------------------------
-- 8. Calibración del cruce: de las aceptaciones automáticas de nivel alto
--    que se auditaron, cuántas confirmó la persona. Si la proporción baja,
--    el umbral alto debe subir (metodología, 1.4).
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS auditorias_de_nivel_alto,
       SUM(d.resultado = 'ACEPTAR') AS confirmadas,
       ROUND(100 * SUM(d.resultado = 'ACEPTAR') / COUNT(*), 1) AS pct_confirmadas
  FROM egresados_identidad.decision_coincidencia d
  JOIN egresados_identidad.coincidencia c ON c.id_coincidencia = d.id_coincidencia
 WHERE d.tipo_decision = 'AUDITORIA'
   AND c.nivel = 'ALTO';

-- ---------------------------------------------------------------------
-- 9. Precisión de la IA: de las propuestas hechas por IA que ya tienen
--    valor final, en cuántas la persona dejó la misma propuesta.
-- ---------------------------------------------------------------------
SELECT 'ocupacion' AS clasificacion,
       COUNT(*) AS propuestas_ia,
       SUM(codigo_ocupacion = codigo_ocupacion_propuesto) AS sin_cambio,
       ROUND(100 * SUM(codigo_ocupacion = codigo_ocupacion_propuesto) / COUNT(*), 1) AS pct_precision
  FROM egresados.experiencia
 WHERE metodo_ocupacion = 'IA' AND codigo_ocupacion IS NOT NULL
UNION ALL
SELECT 'area',
       COUNT(*),
       SUM(codigo_area = codigo_area_propuesto),
       ROUND(100 * SUM(codigo_area = codigo_area_propuesto) / COUNT(*), 1)
  FROM egresados.experiencia
 WHERE metodo_area = 'IA' AND codigo_area IS NOT NULL;

-- ---------------------------------------------------------------------
-- 10. Tasa de respuesta por momento de seguimiento: mide el cansancio del
--     egresado (metodología, 1.5).
-- ---------------------------------------------------------------------
SELECT codigo_momento,
       COUNT(*) AS solicitudes,
       SUM(estado_envio = 'REBOTADA') AS rebotadas,
       SUM(respuesta IS NOT NULL) AS respondidas,
       SUM(respuesta = 'CONFIRMO_SIN_CAMBIOS') AS sigo_igual,
       SUM(respuesta = 'ACTUALIZO') AS actualizaron,
       ROUND(100 * SUM(respuesta IS NOT NULL) / COUNT(*), 1) AS pct_respuesta
  FROM egresados.solicitud_actualizacion
 GROUP BY codigo_momento;

-- ---------------------------------------------------------------------
-- 11. Búsquedas del canal C por estrato y resultado: "no encontrado" mide
--     el sesgo de la muestra (metodología, 1.6).
-- ---------------------------------------------------------------------
SELECT COALESCE(me.estrato, 'Fuera de muestra') AS estrato,
       b.resultado,
       COUNT(*) AS busquedas
  FROM egresados.busqueda b
  LEFT JOIN egresados.muestra_egresado me
         ON me.id_muestra = b.id_muestra AND me.id_egresado = b.id_egresado
 GROUP BY COALESCE(me.estrato, 'Fuera de muestra'), b.resultado;

-- ---------------------------------------------------------------------
-- 12. Conservación limitada: lo que la depuración aún debe borrar.
--     Esperado: todo en 0, salvo el PDF de la captura de Valentina y el
--     de Felipe, que siguen en revisión.
-- ---------------------------------------------------------------------
SELECT 'PDF de capturas cerradas sin borrar' AS pendiente, COUNT(*) AS registros
  FROM egresados.captura
 WHERE estado IN ('VERIFICADA', 'RECHAZADA') AND huella_archivo IS NOT NULL AND fecha_hora_borrado_archivo IS NULL
UNION ALL
SELECT 'PDF de capturas en revisión (se conservan)', COUNT(*)
  FROM egresados.captura
 WHERE estado IN ('RECIBIDA', 'EN_REVISION') AND huella_archivo IS NOT NULL AND fecha_hora_borrado_archivo IS NULL
UNION ALL
SELECT 'Datos observados de coincidencias decididas', COUNT(*)
  FROM egresados_identidad.coincidencia
 WHERE estado IN ('ACEPTADA', 'RECHAZADA')
   AND (nombre_observado IS NOT NULL OR programa_observado IS NOT NULL OR ciudad_observada IS NOT NULL
        OR anio_inicio_observado IS NOT NULL OR anio_fin_observado IS NOT NULL)
UNION ALL
SELECT 'URL de perfiles descartados', COUNT(*)
  FROM egresados_identidad.perfil p
 WHERE p.url IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM egresados_identidad.coincidencia c
                    WHERE c.id_perfil = p.id_perfil AND c.estado IN ('ACEPTADA', 'PENDIENTE'));

-- La bitácora registró que la URL de los perfiles descartados se borró,
-- pero no guardó su valor: aparece como "[omitido]".
SELECT id_registro AS id_perfil,
       JSON_VALUE(valores_anteriores, '$.url') AS url_antes,
       JSON_VALUE(valores_nuevos, '$.url') AS url_despues,
       usuario_bd,
       id_ejecucion
  FROM egresados_identidad.bitacora_identidad
 WHERE tabla = 'perfil' AND operacion = 'UPDATE';

-- ---------------------------------------------------------------------
-- 13. Supresión: de la persona que revocó solo quedan la constancia y las
--     huellas. Si vuelve a preguntar, se calcula la huella de su documento
--     con la clave y se busca en la lista.
--     Esperado: la constancia atendida, 3 huellas y 0 personas con ese
--     documento.
-- ---------------------------------------------------------------------
SELECT s.id_solicitud_supresion,
       s.tipo_solicitud,
       s.fecha_hora_solicitud,
       s.fecha_hora_atencion,
       (SELECT COUNT(*) FROM egresados_identidad.huella_no_contactar h
         WHERE h.id_solicitud_supresion = s.id_solicitud_supresion) AS huellas
  FROM egresados_identidad.solicitud_supresion s;

SELECT COUNT(*) AS personas_con_el_documento_suprimido
  FROM egresados_identidad.documento_identidad
 WHERE tipo_documento = 'CC' AND numero_documento = '1000000011';

-- Huella HMAC del documento CC:1000000011 calculada con la clave de prueba
SELECT tipo_huella, 'en la lista de no contactar' AS resultado
  FROM egresados_identidad.huella_no_contactar
 WHERE tipo_huella = 'DOCUMENTO'
   AND huella = '9a3a489517da1bcc4919e2d43e3d64bd9f1c7c94ec24971a0541e8d7a9b13551';
