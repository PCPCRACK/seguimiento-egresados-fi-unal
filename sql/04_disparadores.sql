-- =====================================================================
-- 04_disparadores.sql
-- Disparadores de validación: las reglas que un CHECK no puede expresar
-- porque miran la fecha actual u otras tablas.
-- Modelo de datos, paso 3.5. Los disparadores de bitácora van en
-- 05_bitacora.sql.
-- =====================================================================
--
-- Todos pertenecen a la cuenta bloqueada definidor_egresados, así que
-- se ejecutan con sus permisos y no con los de quien hace el cambio.
-- Cuando una regla se rompe, el disparador rechaza la operación con
-- SIGNAL SQLSTATE '45000' y un mensaje que explica la regla.

SET NAMES utf8mb4;

DELIMITER //

-- ---------------------------------------------------------------------
-- experiencia: los años no pueden ser posteriores al año actual.
-- Va en un disparador porque MariaDB no admite la fecha actual en un
-- CHECK (prueba T2 del paso 3).
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_experiencia_bi
BEFORE INSERT ON egresados.experiencia FOR EACH ROW
BEGIN
  IF NEW.anio_inicio > YEAR(CURDATE()) OR NEW.anio_fin > YEAR(CURDATE()) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'experiencia: el año de inicio y el de fin no pueden ser posteriores al año actual';
  END IF;
END//

CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_experiencia_bu
BEFORE UPDATE ON egresados.experiencia FOR EACH ROW
BEGIN
  IF NEW.anio_inicio > YEAR(CURDATE()) OR NEW.anio_fin > YEAR(CURDATE()) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'experiencia: el año de inicio y el de fin no pueden ser posteriores al año actual';
  END IF;
END//

-- ---------------------------------------------------------------------
-- coincidencia: toda coincidencia nace PENDIENTE. Su estado solo cambia
-- cuando se registra una decisión (trg_decision_coincidencia_ai).
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_coincidencia_bi
BEFORE INSERT ON egresados_identidad.coincidencia FOR EACH ROW
BEGIN
  SET NEW.estado = 'PENDIENTE';
END//

-- Los puntajes y el nivel son el resultado histórico de una ejecución:
-- no se modifican (excepción controlada a la 3FN, paso 2.7).
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_coincidencia_bu
BEFORE UPDATE ON egresados_identidad.coincidencia FOR EACH ROW
BEGIN
  IF NOT (NEW.puntaje_nombre <=> OLD.puntaje_nombre)
     OR NOT (NEW.puntaje_programa <=> OLD.puntaje_programa)
     OR NOT (NEW.puntaje_anio <=> OLD.puntaje_anio)
     OR NOT (NEW.puntaje_ciudad <=> OLD.puntaje_ciudad)
     OR NOT (NEW.puntaje_total <=> OLD.puntaje_total)
     OR NOT (NEW.nivel <=> OLD.nivel)
     OR NEW.id_egresado <> OLD.id_egresado
     OR NEW.id_perfil <> OLD.id_perfil THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'coincidencia: los puntajes, el nivel, el egresado y el perfil no se modifican';
  END IF;
END//

-- ---------------------------------------------------------------------
-- decision_coincidencia: el estado de la coincidencia sigue a su última
-- decisión. Si se rechaza una coincidencia que estaba aceptada (por
-- ejemplo, en una auditoría), sus capturas dejan de valer.
-- Si la aceptación rompe la regla "un perfil para un solo egresado",
-- la restricción UNIQUE rechaza la actualización y con ella la decisión.
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_decision_coincidencia_ai
AFTER INSERT ON egresados_identidad.decision_coincidencia FOR EACH ROW
BEGIN
  DECLARE v_estado_anterior VARCHAR(9);
  SET v_estado_anterior = (SELECT estado FROM egresados_identidad.coincidencia
                            WHERE id_coincidencia = NEW.id_coincidencia);

  UPDATE egresados_identidad.coincidencia
     SET estado = CASE NEW.resultado
                    WHEN 'ACEPTAR' THEN 'ACEPTADA'
                    WHEN 'RECHAZAR' THEN 'RECHAZADA'
                    ELSE 'PENDIENTE' END
   WHERE id_coincidencia = NEW.id_coincidencia;

  IF v_estado_anterior = 'ACEPTADA' AND NEW.resultado = 'RECHAZAR' THEN
    UPDATE egresados.captura c
      JOIN egresados_identidad.coincidencia co
        ON co.id_egresado = c.id_egresado AND co.id_perfil = c.id_perfil
       SET c.estado = 'RECHAZADA'
     WHERE co.id_coincidencia = NEW.id_coincidencia
       AND c.estado <> 'RECHAZADA';
  END IF;
END//

-- ---------------------------------------------------------------------
-- captura: reglas al crearla.
--   * Entra RECIBIDA o EN_REVISION: se verifica después, cuando ya tiene
--     su contenido, para que pase por las comprobaciones de verificación.
--   * Su fuente aporta datos individuales.
--   * Si la base legal de la fuente es la autorización, la exige.
--   * Si tiene perfil, la coincidencia con su egresado está ACEPTADA.
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_captura_bi
BEFORE INSERT ON egresados.captura FOR EACH ROW
BEGIN
  DECLARE v_individual TINYINT;
  DECLARE v_base_legal VARCHAR(22);
  DECLARE v_estado_coincidencia VARCHAR(9);

  IF NEW.estado NOT IN ('RECIBIDA', 'EN_REVISION') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'captura: una captura nueva entra como RECIBIDA o EN_REVISION y se verifica después';
  END IF;

  SET v_individual = (SELECT es_individual FROM egresados.cat_fuente WHERE codigo_fuente = NEW.codigo_fuente);
  SET v_base_legal = (SELECT base_legal FROM egresados.cat_fuente WHERE codigo_fuente = NEW.codigo_fuente);

  IF v_individual = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'captura: la fuente no aporta datos individuales; va en indicador_externo';
  END IF;

  IF v_base_legal = 'AUTORIZACION' AND NEW.id_autorizacion IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'captura: la base legal de esta fuente es la autorización y la captura no tiene una';
  END IF;

  IF NEW.id_perfil IS NOT NULL THEN
    SET v_estado_coincidencia = (SELECT estado FROM egresados_identidad.coincidencia
                                  WHERE id_egresado = NEW.id_egresado AND id_perfil = NEW.id_perfil);
    IF v_estado_coincidencia IS NULL OR v_estado_coincidencia <> 'ACEPTADA' THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'captura: el perfil no está aceptado para este egresado';
    END IF;
  END IF;
END//

-- ---------------------------------------------------------------------
-- captura: reglas al modificarla.
--   * El egresado y la fuente no cambian.
--   * Si se le asigna un perfil, la coincidencia debe estar ACEPTADA.
--   * Para pasar a VERIFICADA: ninguna incidencia bloqueante abierta y
--     ninguna clasificación pendiente en su contenido.
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_captura_bu
BEFORE UPDATE ON egresados.captura FOR EACH ROW
BEGIN
  DECLARE v_estado_coincidencia VARCHAR(9);
  DECLARE v_pendientes INT;

  IF NEW.id_egresado <> OLD.id_egresado OR NEW.codigo_fuente <> OLD.codigo_fuente THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'captura: el egresado y la fuente de una captura no cambian';
  END IF;

  IF NEW.id_perfil IS NOT NULL AND NOT (NEW.id_perfil <=> OLD.id_perfil) THEN
    SET v_estado_coincidencia = (SELECT estado FROM egresados_identidad.coincidencia
                                  WHERE id_egresado = NEW.id_egresado AND id_perfil = NEW.id_perfil);
    IF v_estado_coincidencia IS NULL OR v_estado_coincidencia <> 'ACEPTADA' THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'captura: el perfil no está aceptado para este egresado';
    END IF;
  END IF;

  IF NEW.estado = 'VERIFICADA' AND OLD.estado <> 'VERIFICADA' THEN
    SET v_pendientes = (
      SELECT COUNT(*)
        FROM egresados.incidencia i
        JOIN egresados.cat_tipo_incidencia t ON t.codigo_tipo_incidencia = i.codigo_tipo_incidencia
       WHERE i.id_captura = NEW.id_captura
         AND t.bloquea_captura = 1
         AND i.estado IN ('ABIERTA', 'EN_REVISION'));
    IF v_pendientes > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'captura: no se puede verificar; tiene incidencias bloqueantes abiertas';
    END IF;

    SET v_pendientes =
        (SELECT COUNT(*) FROM egresados.experiencia e
          WHERE e.id_captura = NEW.id_captura
            AND (e.codigo_ocupacion IS NULL
                 OR e.codigo_area IS NULL
                 OR (e.organizacion_original IS NOT NULL AND e.id_organizacion IS NULL)
                 OR (e.ubicacion_original IS NOT NULL AND e.codigo_ubicacion IS NULL)))
      + (SELECT COUNT(*) FROM egresados.estudio_declarado d
          WHERE d.id_captura = NEW.id_captura AND d.id_organizacion IS NULL);
    IF v_pendientes > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'captura: no se puede verificar; tiene clasificaciones pendientes';
    END IF;
  END IF;
END//

-- ---------------------------------------------------------------------
-- indicador_externo: solo de fuentes que no aportan datos individuales.
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_indicador_externo_bi
BEFORE INSERT ON egresados.indicador_externo FOR EACH ROW
BEGIN
  IF (SELECT es_individual FROM egresados.cat_fuente WHERE codigo_fuente = NEW.codigo_fuente) = 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'indicador_externo: la fuente aporta datos individuales; va en captura';
  END IF;
END//

CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_indicador_externo_bu
BEFORE UPDATE ON egresados.indicador_externo FOR EACH ROW
BEGIN
  IF (SELECT es_individual FROM egresados.cat_fuente WHERE codigo_fuente = NEW.codigo_fuente) = 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'indicador_externo: la fuente aporta datos individuales; va en captura';
  END IF;
END//

-- ---------------------------------------------------------------------
-- autorizacion: se otorga dentro de la vigencia del texto aceptado.
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_autorizacion_bi
BEFORE INSERT ON egresados_identidad.autorizacion FOR EACH ROW
BEGIN
  DECLARE v_inicio DATE;
  DECLARE v_fin DATE;
  SET v_inicio = (SELECT fecha_inicio_vigencia FROM egresados_identidad.texto_autorizacion
                   WHERE id_texto_autorizacion = NEW.id_texto_autorizacion);
  SET v_fin = (SELECT fecha_fin_vigencia FROM egresados_identidad.texto_autorizacion
                WHERE id_texto_autorizacion = NEW.id_texto_autorizacion);
  IF DATE(NEW.fecha_hora) < v_inicio OR DATE(NEW.fecha_hora) > v_fin THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'autorizacion: la fecha no está dentro de la vigencia del texto aceptado';
  END IF;
END//

-- ---------------------------------------------------------------------
-- texto_autorizacion: un texto publicado no cambia; solo se cierra su
-- vigencia. Un cambio en el texto es una versión nueva.
-- ---------------------------------------------------------------------
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_texto_autorizacion_bu
BEFORE UPDATE ON egresados_identidad.texto_autorizacion FOR EACH ROW
BEGIN
  IF NEW.texto <> OLD.texto
     OR NEW.version <> OLD.version
     OR NEW.fecha_inicio_vigencia <> OLD.fecha_inicio_vigencia THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'texto_autorizacion: un texto publicado no cambia; para modificarlo se publica una versión nueva';
  END IF;
END//

DELIMITER ;
