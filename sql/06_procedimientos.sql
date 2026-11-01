-- =====================================================================
-- 06_procedimientos.sql
-- Procedimientos almacenados. Modelo de datos, paso 3.7.
-- Los dos se ejecutan con los permisos de su dueño (SQL SECURITY
-- DEFINER): el rol que los usa no necesita permisos directos de borrado.
-- =====================================================================

SET NAMES utf8mb4;

DELIMITER //

-- ---------------------------------------------------------------------
-- sp_suprimir_egresado
-- Atiende una solicitud de revocatoria o supresión ya registrada
-- (Ley 1581, art. 8 lit. e; Decreto 1377, art. 9), en una sola
-- transacción: o se hace todo o no se hace nada.
--
--   1. Comprueba que lleguen tantas huellas como documentos, perfiles
--      aceptados y correos tiene la persona. Las huellas HMAC las calcula
--      el programa que tiene la clave; la base nunca ve la clave.
--   2. Marca la solicitud como atendida y guarda las huellas: es la lista
--      de no contactar.
--   3. Borra los perfiles aceptados de la persona (un perfil no depende
--      de un egresado, así que la cascada no lo alcanza).
--   4. Borra el egresado: todo lo demás, en las dos bases, cae en
--      cascada. Lo borrado en cascada no activa disparadores (prueba T10),
--      así que no queda copia en las bitácoras.
--
-- p_huellas es un arreglo JSON:
--   [{"tipo": "DOCUMENTO", "huella": "<64 hex>"}, {"tipo": "URL", ...}]
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost'
PROCEDURE egresados_identidad.sp_suprimir_egresado(
  IN p_id_solicitud_supresion INT UNSIGNED,
  IN p_id_egresado            INT UNSIGNED,
  IN p_id_responsable         INT UNSIGNED,
  IN p_huellas                LONGTEXT)
SQL SECURITY DEFINER
BEGIN
  DECLARE v_documentos INT;
  DECLARE v_perfiles INT;
  DECLARE v_correos INT;
  DECLARE v_h_documentos INT;
  DECLARE v_h_urls INT;
  DECLARE v_h_correos INT;
  DECLARE v_h_invalidas INT;
  DECLARE v_id_perfil INT UNSIGNED;
  DECLARE v_motivo_anterior VARCHAR(1000);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET @motivo = v_motivo_anterior;
    RESIGNAL;
  END;

  SET v_motivo_anterior = @motivo;

  IF NOT EXISTS (SELECT 1 FROM egresados_identidad.solicitud_supresion
                  WHERE id_solicitud_supresion = p_id_solicitud_supresion
                    AND fecha_hora_atencion IS NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'supresión: la solicitud no existe o ya fue atendida';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM egresados_identidad.identidad WHERE id_egresado = p_id_egresado) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'supresión: el egresado no existe';
  END IF;

  IF p_huellas IS NULL OR JSON_VALID(p_huellas) = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'supresión: las huellas deben llegar como un arreglo JSON válido';
  END IF;

  -- Lo que tiene la persona
  SET v_documentos = (SELECT COUNT(*) FROM egresados_identidad.documento_identidad
                       WHERE id_egresado = p_id_egresado);
  SET v_perfiles = (SELECT COUNT(*) FROM egresados_identidad.coincidencia
                     WHERE id_egresado = p_id_egresado AND estado = 'ACEPTADA');
  SET v_correos = (SELECT (correo_personal IS NOT NULL) + (correo_institucional IS NOT NULL)
                     FROM egresados_identidad.identidad WHERE id_egresado = p_id_egresado);

  -- Lo que llegó
  SELECT COALESCE(SUM(h.tipo = 'DOCUMENTO'), 0),
         COALESCE(SUM(h.tipo = 'URL'), 0),
         COALESCE(SUM(h.tipo = 'CORREO'), 0),
         COALESCE(SUM(h.tipo IS NULL OR h.tipo NOT IN ('DOCUMENTO', 'URL', 'CORREO')
                      OR h.huella IS NULL OR h.huella NOT REGEXP '(?-i)^[0-9a-f]{64}$'), 0)
    INTO v_h_documentos, v_h_urls, v_h_correos, v_h_invalidas
    FROM JSON_TABLE(p_huellas, '$[*]' COLUMNS (
           tipo   VARCHAR(9) PATH '$.tipo',
           huella VARCHAR(64) PATH '$.huella')) AS h;

  IF v_h_invalidas > 0
     OR v_h_documentos <> v_documentos
     OR v_h_urls <> v_perfiles
     OR v_h_correos <> v_correos THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'supresión: las huellas no corresponden a los documentos, perfiles aceptados y correos de la persona';
  END IF;

  SET v_id_perfil = (SELECT id_perfil FROM egresados_identidad.coincidencia
                      WHERE id_egresado = p_id_egresado AND estado = 'ACEPTADA');

  -- La bitácora exige un motivo para los cambios que no hace un proceso automático
  SET @motivo = CONCAT('Atención de la solicitud de supresión ', p_id_solicitud_supresion);

  START TRANSACTION;

    UPDATE egresados_identidad.solicitud_supresion
       SET fecha_hora_atencion = NOW(), id_responsable = p_id_responsable
     WHERE id_solicitud_supresion = p_id_solicitud_supresion;

    INSERT INTO egresados_identidad.huella_no_contactar (id_solicitud_supresion, tipo_huella, huella)
    SELECT p_id_solicitud_supresion, h.tipo, h.huella
      FROM JSON_TABLE(p_huellas, '$[*]' COLUMNS (
             tipo   VARCHAR(9) PATH '$.tipo',
             huella VARCHAR(64) PATH '$.huella')) AS h;

    IF v_id_perfil IS NOT NULL THEN
      DELETE FROM egresados_identidad.perfil WHERE id_perfil = v_id_perfil;
    END IF;

    DELETE FROM egresados.egresado WHERE id_egresado = p_id_egresado;

  COMMIT;

  SET @motivo = v_motivo_anterior;
END//

-- ---------------------------------------------------------------------
-- sp_fusionar_organizaciones
-- Une dos organizaciones duplicadas: reasigna a la que se conserva todas
-- las experiencias, estudios y alias de la duplicada, y luego borra la
-- duplicada. Es la única excepción a "los catálogos no se borran".
-- Quien lo ejecuta fija antes @motivo, que la bitácora exige.
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost'
PROCEDURE egresados.sp_fusionar_organizaciones(
  IN p_id_conservar INT UNSIGNED,
  IN p_id_eliminar  INT UNSIGNED)
SQL SECURITY DEFINER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF p_id_conservar = p_id_eliminar THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'fusión: la organización que se conserva y la que se elimina son la misma';
  END IF;

  IF (SELECT COUNT(*) FROM egresados.cat_organizacion
       WHERE id_organizacion IN (p_id_conservar, p_id_eliminar)) <> 2 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'fusión: alguna de las dos organizaciones no existe';
  END IF;

  START TRANSACTION;

    UPDATE egresados.experiencia SET id_organizacion = p_id_conservar
     WHERE id_organizacion = p_id_eliminar;
    UPDATE egresados.experiencia SET id_organizacion_propuesto = p_id_conservar
     WHERE id_organizacion_propuesto = p_id_eliminar;
    UPDATE egresados.estudio_declarado SET id_organizacion = p_id_conservar
     WHERE id_organizacion = p_id_eliminar;
    UPDATE egresados.estudio_declarado SET id_organizacion_propuesto = p_id_conservar
     WHERE id_organizacion_propuesto = p_id_eliminar;
    UPDATE egresados.organizacion_alias SET id_organizacion = p_id_conservar
     WHERE id_organizacion = p_id_eliminar;
    DELETE FROM egresados.cat_organizacion WHERE id_organizacion = p_id_eliminar;

  COMMIT;
END//

DELIMITER ;
