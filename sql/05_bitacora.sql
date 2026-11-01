-- =====================================================================
-- 05_bitacora.sql
-- GENERADO por sql/generar_bitacora.sql. No editar a mano: si cambia una
-- tabla, se vuelve a generar. Disparadores de bitacora: 109.
-- =====================================================================

SET NAMES utf8mb4;


DROP TRIGGER IF EXISTS egresados.trg_afinidad_programa_ocupacion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_afinidad_programa_ocupacion_bitacora_ai
AFTER INSERT ON egresados.afinidad_programa_ocupacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('afinidad_programa_ocupacion', CONCAT_WS(',', NEW.id_programa, NEW.codigo_ocupacion), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_programa', NEW.id_programa, 'codigo_ocupacion', NEW.codigo_ocupacion, 'soporte', NEW.soporte, 'id_responsable', NEW.id_responsable),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_afinidad_programa_ocupacion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_afinidad_programa_ocupacion_bitacora_au
AFTER UPDATE ON egresados.afinidad_programa_ocupacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('afinidad_programa_ocupacion', CONCAT_WS(',', NEW.id_programa, NEW.codigo_ocupacion), NULL, 'UPDATE',
  JSON_OBJECT('id_programa', OLD.id_programa, 'codigo_ocupacion', OLD.codigo_ocupacion, 'soporte', OLD.soporte, 'id_responsable', OLD.id_responsable),
  JSON_OBJECT('id_programa', NEW.id_programa, 'codigo_ocupacion', NEW.codigo_ocupacion, 'soporte', NEW.soporte, 'id_responsable', NEW.id_responsable),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_afinidad_programa_ocupacion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_afinidad_programa_ocupacion_bitacora_ad
AFTER DELETE ON egresados.afinidad_programa_ocupacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('afinidad_programa_ocupacion', CONCAT_WS(',', OLD.id_programa, OLD.codigo_ocupacion), NULL, 'DELETE',
  JSON_OBJECT('id_programa', OLD.id_programa, 'codigo_ocupacion', OLD.codigo_ocupacion, 'soporte', OLD.soporte, 'id_responsable', OLD.id_responsable),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_busqueda_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_busqueda_bitacora_ai
AFTER INSERT ON egresados.busqueda FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('busqueda', CONCAT_WS(',', NEW.id_busqueda), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_busqueda', NEW.id_busqueda, 'id_egresado', NEW.id_egresado, 'id_muestra', NEW.id_muestra, 'id_responsable', NEW.id_responsable, 'fecha_hora', NEW.fecha_hora, 'version_protocolo', NEW.version_protocolo, 'resultado', NEW.resultado),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_busqueda_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_busqueda_bitacora_au
AFTER UPDATE ON egresados.busqueda FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('busqueda', CONCAT_WS(',', NEW.id_busqueda), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_busqueda', OLD.id_busqueda, 'id_egresado', OLD.id_egresado, 'id_muestra', OLD.id_muestra, 'id_responsable', OLD.id_responsable, 'fecha_hora', OLD.fecha_hora, 'version_protocolo', OLD.version_protocolo, 'resultado', OLD.resultado),
  JSON_OBJECT('id_busqueda', NEW.id_busqueda, 'id_egresado', NEW.id_egresado, 'id_muestra', NEW.id_muestra, 'id_responsable', NEW.id_responsable, 'fecha_hora', NEW.fecha_hora, 'version_protocolo', NEW.version_protocolo, 'resultado', NEW.resultado),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_busqueda_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_busqueda_bitacora_ad
AFTER DELETE ON egresados.busqueda FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('busqueda', CONCAT_WS(',', OLD.id_busqueda), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_busqueda', OLD.id_busqueda, 'id_egresado', OLD.id_egresado, 'id_muestra', OLD.id_muestra, 'id_responsable', OLD.id_responsable, 'fecha_hora', OLD.fecha_hora, 'version_protocolo', OLD.version_protocolo, 'resultado', OLD.resultado),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_captura_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_captura_bitacora_ai
AFTER INSERT ON egresados.captura FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('captura', CONCAT_WS(',', NEW.id_captura), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_captura', NEW.id_captura, 'id_egresado', NEW.id_egresado, 'id_perfil', NEW.id_perfil, 'codigo_fuente', NEW.codigo_fuente, 'id_autorizacion', NEW.id_autorizacion, 'id_ejecucion', NEW.id_ejecucion, 'id_responsable', NEW.id_responsable, 'fecha_hora_captura', NEW.fecha_hora_captura, 'estado', NEW.estado, 'situacion_declarada', NEW.situacion_declarada, 'huella_archivo', NEW.huella_archivo, 'fecha_hora_borrado_archivo', NEW.fecha_hora_borrado_archivo),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_captura_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_captura_bitacora_au
AFTER UPDATE ON egresados.captura FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('captura', CONCAT_WS(',', NEW.id_captura), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_captura', OLD.id_captura, 'id_egresado', OLD.id_egresado, 'id_perfil', OLD.id_perfil, 'codigo_fuente', OLD.codigo_fuente, 'id_autorizacion', OLD.id_autorizacion, 'id_ejecucion', OLD.id_ejecucion, 'id_responsable', OLD.id_responsable, 'fecha_hora_captura', OLD.fecha_hora_captura, 'estado', OLD.estado, 'situacion_declarada', OLD.situacion_declarada, 'huella_archivo', OLD.huella_archivo, 'fecha_hora_borrado_archivo', OLD.fecha_hora_borrado_archivo),
  JSON_OBJECT('id_captura', NEW.id_captura, 'id_egresado', NEW.id_egresado, 'id_perfil', NEW.id_perfil, 'codigo_fuente', NEW.codigo_fuente, 'id_autorizacion', NEW.id_autorizacion, 'id_ejecucion', NEW.id_ejecucion, 'id_responsable', NEW.id_responsable, 'fecha_hora_captura', NEW.fecha_hora_captura, 'estado', NEW.estado, 'situacion_declarada', NEW.situacion_declarada, 'huella_archivo', NEW.huella_archivo, 'fecha_hora_borrado_archivo', NEW.fecha_hora_borrado_archivo),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_captura_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_captura_bitacora_ad
AFTER DELETE ON egresados.captura FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('captura', CONCAT_WS(',', OLD.id_captura), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_captura', OLD.id_captura, 'id_egresado', OLD.id_egresado, 'id_perfil', OLD.id_perfil, 'codigo_fuente', OLD.codigo_fuente, 'id_autorizacion', OLD.id_autorizacion, 'id_ejecucion', OLD.id_ejecucion, 'id_responsable', OLD.id_responsable, 'fecha_hora_captura', OLD.fecha_hora_captura, 'estado', OLD.estado, 'situacion_declarada', OLD.situacion_declarada, 'huella_archivo', OLD.huella_archivo, 'fecha_hora_borrado_archivo', OLD.fecha_hora_borrado_archivo),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cargo_alias_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cargo_alias_bitacora_ai
AFTER INSERT ON egresados.cargo_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cargo_alias', CONCAT_WS(',', NEW.id_cargo_alias), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_cargo_alias', NEW.id_cargo_alias, 'texto_normalizado', NEW.texto_normalizado, 'codigo_ocupacion', NEW.codigo_ocupacion, 'origen', NEW.origen, 'id_responsable', NEW.id_responsable, 'fecha_hora_validacion', NEW.fecha_hora_validacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cargo_alias_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cargo_alias_bitacora_au
AFTER UPDATE ON egresados.cargo_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cargo_alias', CONCAT_WS(',', NEW.id_cargo_alias), NULL, 'UPDATE',
  JSON_OBJECT('id_cargo_alias', OLD.id_cargo_alias, 'texto_normalizado', OLD.texto_normalizado, 'codigo_ocupacion', OLD.codigo_ocupacion, 'origen', OLD.origen, 'id_responsable', OLD.id_responsable, 'fecha_hora_validacion', OLD.fecha_hora_validacion),
  JSON_OBJECT('id_cargo_alias', NEW.id_cargo_alias, 'texto_normalizado', NEW.texto_normalizado, 'codigo_ocupacion', NEW.codigo_ocupacion, 'origen', NEW.origen, 'id_responsable', NEW.id_responsable, 'fecha_hora_validacion', NEW.fecha_hora_validacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cargo_alias_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cargo_alias_bitacora_ad
AFTER DELETE ON egresados.cargo_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cargo_alias', CONCAT_WS(',', OLD.id_cargo_alias), NULL, 'DELETE',
  JSON_OBJECT('id_cargo_alias', OLD.id_cargo_alias, 'texto_normalizado', OLD.texto_normalizado, 'codigo_ocupacion', OLD.codigo_ocupacion, 'origen', OLD.origen, 'id_responsable', OLD.id_responsable, 'fecha_hora_validacion', OLD.fecha_hora_validacion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_actividad_economica_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_actividad_economica_bitacora_ai
AFTER INSERT ON egresados.cat_actividad_economica FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_actividad_economica', CONCAT_WS(',', NEW.codigo_actividad), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('codigo_actividad', NEW.codigo_actividad, 'nombre', NEW.nombre, 'codigo_padre', NEW.codigo_padre, 'es_vigente', NEW.es_vigente),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_actividad_economica_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_actividad_economica_bitacora_au
AFTER UPDATE ON egresados.cat_actividad_economica FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_actividad_economica', CONCAT_WS(',', NEW.codigo_actividad), NULL, 'UPDATE',
  JSON_OBJECT('codigo_actividad', OLD.codigo_actividad, 'nombre', OLD.nombre, 'codigo_padre', OLD.codigo_padre, 'es_vigente', OLD.es_vigente),
  JSON_OBJECT('codigo_actividad', NEW.codigo_actividad, 'nombre', NEW.nombre, 'codigo_padre', NEW.codigo_padre, 'es_vigente', NEW.es_vigente),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_actividad_economica_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_actividad_economica_bitacora_ad
AFTER DELETE ON egresados.cat_actividad_economica FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_actividad_economica', CONCAT_WS(',', OLD.codigo_actividad), NULL, 'DELETE',
  JSON_OBJECT('codigo_actividad', OLD.codigo_actividad, 'nombre', OLD.nombre, 'codigo_padre', OLD.codigo_padre, 'es_vigente', OLD.es_vigente),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_area_desempeno_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_area_desempeno_bitacora_ai
AFTER INSERT ON egresados.cat_area_desempeno FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_area_desempeno', CONCAT_WS(',', NEW.codigo_area), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('codigo_area', NEW.codigo_area, 'nombre', NEW.nombre, 'criterio', NEW.criterio),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_area_desempeno_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_area_desempeno_bitacora_au
AFTER UPDATE ON egresados.cat_area_desempeno FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_area_desempeno', CONCAT_WS(',', NEW.codigo_area), NULL, 'UPDATE',
  JSON_OBJECT('codigo_area', OLD.codigo_area, 'nombre', OLD.nombre, 'criterio', OLD.criterio),
  JSON_OBJECT('codigo_area', NEW.codigo_area, 'nombre', NEW.nombre, 'criterio', NEW.criterio),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_area_desempeno_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_area_desempeno_bitacora_ad
AFTER DELETE ON egresados.cat_area_desempeno FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_area_desempeno', CONCAT_WS(',', OLD.codigo_area), NULL, 'DELETE',
  JSON_OBJECT('codigo_area', OLD.codigo_area, 'nombre', OLD.nombre, 'criterio', OLD.criterio),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_fuente_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_fuente_bitacora_ai
AFTER INSERT ON egresados.cat_fuente FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_fuente', CONCAT_WS(',', NEW.codigo_fuente), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('codigo_fuente', NEW.codigo_fuente, 'nombre', NEW.nombre, 'base_legal', NEW.base_legal, 'norma', NEW.norma, 'es_individual', NEW.es_individual),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_fuente_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_fuente_bitacora_au
AFTER UPDATE ON egresados.cat_fuente FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_fuente', CONCAT_WS(',', NEW.codigo_fuente), NULL, 'UPDATE',
  JSON_OBJECT('codigo_fuente', OLD.codigo_fuente, 'nombre', OLD.nombre, 'base_legal', OLD.base_legal, 'norma', OLD.norma, 'es_individual', OLD.es_individual),
  JSON_OBJECT('codigo_fuente', NEW.codigo_fuente, 'nombre', NEW.nombre, 'base_legal', NEW.base_legal, 'norma', NEW.norma, 'es_individual', NEW.es_individual),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_fuente_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_fuente_bitacora_ad
AFTER DELETE ON egresados.cat_fuente FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_fuente', CONCAT_WS(',', OLD.codigo_fuente), NULL, 'DELETE',
  JSON_OBJECT('codigo_fuente', OLD.codigo_fuente, 'nombre', OLD.nombre, 'base_legal', OLD.base_legal, 'norma', OLD.norma, 'es_individual', OLD.es_individual),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_momento_seguimiento_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_momento_seguimiento_bitacora_ai
AFTER INSERT ON egresados.cat_momento_seguimiento FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_momento_seguimiento', CONCAT_WS(',', NEW.codigo_momento), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('codigo_momento', NEW.codigo_momento, 'anios_desde_grado', NEW.anios_desde_grado, 'es_activo', NEW.es_activo),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_momento_seguimiento_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_momento_seguimiento_bitacora_au
AFTER UPDATE ON egresados.cat_momento_seguimiento FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_momento_seguimiento', CONCAT_WS(',', NEW.codigo_momento), NULL, 'UPDATE',
  JSON_OBJECT('codigo_momento', OLD.codigo_momento, 'anios_desde_grado', OLD.anios_desde_grado, 'es_activo', OLD.es_activo),
  JSON_OBJECT('codigo_momento', NEW.codigo_momento, 'anios_desde_grado', NEW.anios_desde_grado, 'es_activo', NEW.es_activo),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_momento_seguimiento_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_momento_seguimiento_bitacora_ad
AFTER DELETE ON egresados.cat_momento_seguimiento FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_momento_seguimiento', CONCAT_WS(',', OLD.codigo_momento), NULL, 'DELETE',
  JSON_OBJECT('codigo_momento', OLD.codigo_momento, 'anios_desde_grado', OLD.anios_desde_grado, 'es_activo', OLD.es_activo),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_nivel_formacion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_nivel_formacion_bitacora_ai
AFTER INSERT ON egresados.cat_nivel_formacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_nivel_formacion', CONCAT_WS(',', NEW.codigo_nivel), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('codigo_nivel', NEW.codigo_nivel, 'nombre', NEW.nombre, 'orden', NEW.orden),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_nivel_formacion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_nivel_formacion_bitacora_au
AFTER UPDATE ON egresados.cat_nivel_formacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_nivel_formacion', CONCAT_WS(',', NEW.codigo_nivel), NULL, 'UPDATE',
  JSON_OBJECT('codigo_nivel', OLD.codigo_nivel, 'nombre', OLD.nombre, 'orden', OLD.orden),
  JSON_OBJECT('codigo_nivel', NEW.codigo_nivel, 'nombre', NEW.nombre, 'orden', NEW.orden),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_nivel_formacion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_nivel_formacion_bitacora_ad
AFTER DELETE ON egresados.cat_nivel_formacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_nivel_formacion', CONCAT_WS(',', OLD.codigo_nivel), NULL, 'DELETE',
  JSON_OBJECT('codigo_nivel', OLD.codigo_nivel, 'nombre', OLD.nombre, 'orden', OLD.orden),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_ocupacion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_ocupacion_bitacora_ai
AFTER INSERT ON egresados.cat_ocupacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_ocupacion', CONCAT_WS(',', NEW.codigo_ocupacion), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('codigo_ocupacion', NEW.codigo_ocupacion, 'nombre', NEW.nombre, 'codigo_padre', NEW.codigo_padre, 'es_vigente', NEW.es_vigente),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_ocupacion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_ocupacion_bitacora_au
AFTER UPDATE ON egresados.cat_ocupacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_ocupacion', CONCAT_WS(',', NEW.codigo_ocupacion), NULL, 'UPDATE',
  JSON_OBJECT('codigo_ocupacion', OLD.codigo_ocupacion, 'nombre', OLD.nombre, 'codigo_padre', OLD.codigo_padre, 'es_vigente', OLD.es_vigente),
  JSON_OBJECT('codigo_ocupacion', NEW.codigo_ocupacion, 'nombre', NEW.nombre, 'codigo_padre', NEW.codigo_padre, 'es_vigente', NEW.es_vigente),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_ocupacion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_ocupacion_bitacora_ad
AFTER DELETE ON egresados.cat_ocupacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_ocupacion', CONCAT_WS(',', OLD.codigo_ocupacion), NULL, 'DELETE',
  JSON_OBJECT('codigo_ocupacion', OLD.codigo_ocupacion, 'nombre', OLD.nombre, 'codigo_padre', OLD.codigo_padre, 'es_vigente', OLD.es_vigente),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_organizacion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_organizacion_bitacora_ai
AFTER INSERT ON egresados.cat_organizacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_organizacion', CONCAT_WS(',', NEW.id_organizacion), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_organizacion', NEW.id_organizacion, 'nombre', NEW.nombre, 'codigo_pais', NEW.codigo_pais, 'nit', NEW.nit, 'codigo_actividad_propuesto', NEW.codigo_actividad_propuesto, 'metodo_actividad', NEW.metodo_actividad, 'confianza_actividad', NEW.confianza_actividad, 'codigo_actividad', NEW.codigo_actividad, 'id_ejecucion_clasificacion', NEW.id_ejecucion_clasificacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_organizacion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_organizacion_bitacora_au
AFTER UPDATE ON egresados.cat_organizacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_organizacion', CONCAT_WS(',', NEW.id_organizacion), NULL, 'UPDATE',
  JSON_OBJECT('id_organizacion', OLD.id_organizacion, 'nombre', OLD.nombre, 'codigo_pais', OLD.codigo_pais, 'nit', OLD.nit, 'codigo_actividad_propuesto', OLD.codigo_actividad_propuesto, 'metodo_actividad', OLD.metodo_actividad, 'confianza_actividad', OLD.confianza_actividad, 'codigo_actividad', OLD.codigo_actividad, 'id_ejecucion_clasificacion', OLD.id_ejecucion_clasificacion),
  JSON_OBJECT('id_organizacion', NEW.id_organizacion, 'nombre', NEW.nombre, 'codigo_pais', NEW.codigo_pais, 'nit', NEW.nit, 'codigo_actividad_propuesto', NEW.codigo_actividad_propuesto, 'metodo_actividad', NEW.metodo_actividad, 'confianza_actividad', NEW.confianza_actividad, 'codigo_actividad', NEW.codigo_actividad, 'id_ejecucion_clasificacion', NEW.id_ejecucion_clasificacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_organizacion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_organizacion_bitacora_ad
AFTER DELETE ON egresados.cat_organizacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_organizacion', CONCAT_WS(',', OLD.id_organizacion), NULL, 'DELETE',
  JSON_OBJECT('id_organizacion', OLD.id_organizacion, 'nombre', OLD.nombre, 'codigo_pais', OLD.codigo_pais, 'nit', OLD.nit, 'codigo_actividad_propuesto', OLD.codigo_actividad_propuesto, 'metodo_actividad', OLD.metodo_actividad, 'confianza_actividad', OLD.confianza_actividad, 'codigo_actividad', OLD.codigo_actividad, 'id_ejecucion_clasificacion', OLD.id_ejecucion_clasificacion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_programa_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_programa_bitacora_ai
AFTER INSERT ON egresados.cat_programa FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_programa', CONCAT_WS(',', NEW.id_programa), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_programa', NEW.id_programa, 'nombre', NEW.nombre, 'codigo_nivel', NEW.codigo_nivel, 'codigo_snies', NEW.codigo_snies, 'codigo_sia', NEW.codigo_sia, 'semestres_minimos', NEW.semestres_minimos, 'es_vigente', NEW.es_vigente),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_programa_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_programa_bitacora_au
AFTER UPDATE ON egresados.cat_programa FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_programa', CONCAT_WS(',', NEW.id_programa), NULL, 'UPDATE',
  JSON_OBJECT('id_programa', OLD.id_programa, 'nombre', OLD.nombre, 'codigo_nivel', OLD.codigo_nivel, 'codigo_snies', OLD.codigo_snies, 'codigo_sia', OLD.codigo_sia, 'semestres_minimos', OLD.semestres_minimos, 'es_vigente', OLD.es_vigente),
  JSON_OBJECT('id_programa', NEW.id_programa, 'nombre', NEW.nombre, 'codigo_nivel', NEW.codigo_nivel, 'codigo_snies', NEW.codigo_snies, 'codigo_sia', NEW.codigo_sia, 'semestres_minimos', NEW.semestres_minimos, 'es_vigente', NEW.es_vigente),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_programa_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_programa_bitacora_ad
AFTER DELETE ON egresados.cat_programa FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_programa', CONCAT_WS(',', OLD.id_programa), NULL, 'DELETE',
  JSON_OBJECT('id_programa', OLD.id_programa, 'nombre', OLD.nombre, 'codigo_nivel', OLD.codigo_nivel, 'codigo_snies', OLD.codigo_snies, 'codigo_sia', OLD.codigo_sia, 'semestres_minimos', OLD.semestres_minimos, 'es_vigente', OLD.es_vigente),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_tipo_incidencia_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_tipo_incidencia_bitacora_ai
AFTER INSERT ON egresados.cat_tipo_incidencia FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_tipo_incidencia', CONCAT_WS(',', NEW.codigo_tipo_incidencia), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('codigo_tipo_incidencia', NEW.codigo_tipo_incidencia, 'nombre', NEW.nombre, 'dimension', NEW.dimension, 'severidad', NEW.severidad, 'bloquea_captura', NEW.bloquea_captura),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_tipo_incidencia_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_tipo_incidencia_bitacora_au
AFTER UPDATE ON egresados.cat_tipo_incidencia FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_tipo_incidencia', CONCAT_WS(',', NEW.codigo_tipo_incidencia), NULL, 'UPDATE',
  JSON_OBJECT('codigo_tipo_incidencia', OLD.codigo_tipo_incidencia, 'nombre', OLD.nombre, 'dimension', OLD.dimension, 'severidad', OLD.severidad, 'bloquea_captura', OLD.bloquea_captura),
  JSON_OBJECT('codigo_tipo_incidencia', NEW.codigo_tipo_incidencia, 'nombre', NEW.nombre, 'dimension', NEW.dimension, 'severidad', NEW.severidad, 'bloquea_captura', NEW.bloquea_captura),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_tipo_incidencia_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_tipo_incidencia_bitacora_ad
AFTER DELETE ON egresados.cat_tipo_incidencia FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_tipo_incidencia', CONCAT_WS(',', OLD.codigo_tipo_incidencia), NULL, 'DELETE',
  JSON_OBJECT('codigo_tipo_incidencia', OLD.codigo_tipo_incidencia, 'nombre', OLD.nombre, 'dimension', OLD.dimension, 'severidad', OLD.severidad, 'bloquea_captura', OLD.bloquea_captura),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_ubicacion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_ubicacion_bitacora_ai
AFTER INSERT ON egresados.cat_ubicacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_ubicacion', CONCAT_WS(',', NEW.codigo_ubicacion), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('codigo_ubicacion', NEW.codigo_ubicacion, 'nombre', NEW.nombre, 'codigo_padre', NEW.codigo_padre, 'es_vigente', NEW.es_vigente),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_ubicacion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_ubicacion_bitacora_au
AFTER UPDATE ON egresados.cat_ubicacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_ubicacion', CONCAT_WS(',', NEW.codigo_ubicacion), NULL, 'UPDATE',
  JSON_OBJECT('codigo_ubicacion', OLD.codigo_ubicacion, 'nombre', OLD.nombre, 'codigo_padre', OLD.codigo_padre, 'es_vigente', OLD.es_vigente),
  JSON_OBJECT('codigo_ubicacion', NEW.codigo_ubicacion, 'nombre', NEW.nombre, 'codigo_padre', NEW.codigo_padre, 'es_vigente', NEW.es_vigente),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_cat_ubicacion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_cat_ubicacion_bitacora_ad
AFTER DELETE ON egresados.cat_ubicacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('cat_ubicacion', CONCAT_WS(',', OLD.codigo_ubicacion), NULL, 'DELETE',
  JSON_OBJECT('codigo_ubicacion', OLD.codigo_ubicacion, 'nombre', OLD.nombre, 'codigo_padre', OLD.codigo_padre, 'es_vigente', OLD.es_vigente),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_egresado_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_egresado_bitacora_ai
AFTER INSERT ON egresados.egresado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('egresado', CONCAT_WS(',', NEW.id_egresado), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_egresado', NEW.id_egresado, 'sexo', NEW.sexo, 'id_ejecucion', NEW.id_ejecucion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_egresado_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_egresado_bitacora_au
AFTER UPDATE ON egresados.egresado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('egresado', CONCAT_WS(',', NEW.id_egresado), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_egresado', OLD.id_egresado, 'sexo', OLD.sexo, 'id_ejecucion', OLD.id_ejecucion),
  JSON_OBJECT('id_egresado', NEW.id_egresado, 'sexo', NEW.sexo, 'id_ejecucion', NEW.id_ejecucion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_ejecucion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_ejecucion_bitacora_ai
AFTER INSERT ON egresados.ejecucion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('ejecucion', CONCAT_WS(',', NEW.id_ejecucion), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_ejecucion', NEW.id_ejecucion, 'tipo_proceso', NEW.tipo_proceso, 'id_responsable', NEW.id_responsable, 'version_programa', NEW.version_programa, 'modelo_ia', NEW.modelo_ia, 'digest_modelo_ia', NEW.digest_modelo_ia, 'parametros', NEW.parametros, 'fecha_hora_inicio', NEW.fecha_hora_inicio, 'fecha_hora_fin', NEW.fecha_hora_fin, 'resultado', NEW.resultado, 'registros_procesados', NEW.registros_procesados),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), NEW.id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_ejecucion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_ejecucion_bitacora_au
AFTER UPDATE ON egresados.ejecucion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('ejecucion', CONCAT_WS(',', NEW.id_ejecucion), NULL, 'UPDATE',
  JSON_OBJECT('id_ejecucion', OLD.id_ejecucion, 'tipo_proceso', OLD.tipo_proceso, 'id_responsable', OLD.id_responsable, 'version_programa', OLD.version_programa, 'modelo_ia', OLD.modelo_ia, 'digest_modelo_ia', OLD.digest_modelo_ia, 'parametros', OLD.parametros, 'fecha_hora_inicio', OLD.fecha_hora_inicio, 'fecha_hora_fin', OLD.fecha_hora_fin, 'resultado', OLD.resultado, 'registros_procesados', OLD.registros_procesados),
  JSON_OBJECT('id_ejecucion', NEW.id_ejecucion, 'tipo_proceso', NEW.tipo_proceso, 'id_responsable', NEW.id_responsable, 'version_programa', NEW.version_programa, 'modelo_ia', NEW.modelo_ia, 'digest_modelo_ia', NEW.digest_modelo_ia, 'parametros', NEW.parametros, 'fecha_hora_inicio', NEW.fecha_hora_inicio, 'fecha_hora_fin', NEW.fecha_hora_fin, 'resultado', NEW.resultado, 'registros_procesados', NEW.registros_procesados),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), NEW.id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_ejecucion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_ejecucion_bitacora_ad
AFTER DELETE ON egresados.ejecucion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('ejecucion', CONCAT_WS(',', OLD.id_ejecucion), NULL, 'DELETE',
  JSON_OBJECT('id_ejecucion', OLD.id_ejecucion, 'tipo_proceso', OLD.tipo_proceso, 'id_responsable', OLD.id_responsable, 'version_programa', OLD.version_programa, 'modelo_ia', OLD.modelo_ia, 'digest_modelo_ia', OLD.digest_modelo_ia, 'parametros', OLD.parametros, 'fecha_hora_inicio', OLD.fecha_hora_inicio, 'fecha_hora_fin', OLD.fecha_hora_fin, 'resultado', OLD.resultado, 'registros_procesados', OLD.registros_procesados),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), OLD.id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_estudio_declarado_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_estudio_declarado_bitacora_ai
AFTER INSERT ON egresados.estudio_declarado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('estudio_declarado', CONCAT_WS(',', NEW.id_estudio), (SELECT x.id_egresado FROM egresados.captura x WHERE x.id_captura = NEW.id_captura), 'INSERT',
  NULL,
  JSON_OBJECT('id_estudio', NEW.id_estudio, 'id_captura', NEW.id_captura, 'institucion_original', NEW.institucion_original, 'programa_original', NEW.programa_original, 'anio_inicio', NEW.anio_inicio, 'anio_fin', NEW.anio_fin, 'codigo_nivel', NEW.codigo_nivel, 'id_programa', NEW.id_programa, 'id_organizacion_propuesto', NEW.id_organizacion_propuesto, 'metodo_organizacion', NEW.metodo_organizacion, 'confianza_organizacion', NEW.confianza_organizacion, 'id_organizacion', NEW.id_organizacion, 'id_ejecucion_clasificacion', NEW.id_ejecucion_clasificacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_estudio_declarado_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_estudio_declarado_bitacora_au
AFTER UPDATE ON egresados.estudio_declarado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('estudio_declarado', CONCAT_WS(',', NEW.id_estudio), (SELECT x.id_egresado FROM egresados.captura x WHERE x.id_captura = NEW.id_captura), 'UPDATE',
  JSON_OBJECT('id_estudio', OLD.id_estudio, 'id_captura', OLD.id_captura, 'institucion_original', OLD.institucion_original, 'programa_original', OLD.programa_original, 'anio_inicio', OLD.anio_inicio, 'anio_fin', OLD.anio_fin, 'codigo_nivel', OLD.codigo_nivel, 'id_programa', OLD.id_programa, 'id_organizacion_propuesto', OLD.id_organizacion_propuesto, 'metodo_organizacion', OLD.metodo_organizacion, 'confianza_organizacion', OLD.confianza_organizacion, 'id_organizacion', OLD.id_organizacion, 'id_ejecucion_clasificacion', OLD.id_ejecucion_clasificacion),
  JSON_OBJECT('id_estudio', NEW.id_estudio, 'id_captura', NEW.id_captura, 'institucion_original', NEW.institucion_original, 'programa_original', NEW.programa_original, 'anio_inicio', NEW.anio_inicio, 'anio_fin', NEW.anio_fin, 'codigo_nivel', NEW.codigo_nivel, 'id_programa', NEW.id_programa, 'id_organizacion_propuesto', NEW.id_organizacion_propuesto, 'metodo_organizacion', NEW.metodo_organizacion, 'confianza_organizacion', NEW.confianza_organizacion, 'id_organizacion', NEW.id_organizacion, 'id_ejecucion_clasificacion', NEW.id_ejecucion_clasificacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_estudio_declarado_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_estudio_declarado_bitacora_ad
AFTER DELETE ON egresados.estudio_declarado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('estudio_declarado', CONCAT_WS(',', OLD.id_estudio), (SELECT x.id_egresado FROM egresados.captura x WHERE x.id_captura = OLD.id_captura), 'DELETE',
  JSON_OBJECT('id_estudio', OLD.id_estudio, 'id_captura', OLD.id_captura, 'institucion_original', OLD.institucion_original, 'programa_original', OLD.programa_original, 'anio_inicio', OLD.anio_inicio, 'anio_fin', OLD.anio_fin, 'codigo_nivel', OLD.codigo_nivel, 'id_programa', OLD.id_programa, 'id_organizacion_propuesto', OLD.id_organizacion_propuesto, 'metodo_organizacion', OLD.metodo_organizacion, 'confianza_organizacion', OLD.confianza_organizacion, 'id_organizacion', OLD.id_organizacion, 'id_ejecucion_clasificacion', OLD.id_ejecucion_clasificacion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_experiencia_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_experiencia_bitacora_ai
AFTER INSERT ON egresados.experiencia FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('experiencia', CONCAT_WS(',', NEW.id_experiencia), (SELECT x.id_egresado FROM egresados.captura x WHERE x.id_captura = NEW.id_captura), 'INSERT',
  NULL,
  JSON_OBJECT('id_experiencia', NEW.id_experiencia, 'id_captura', NEW.id_captura, 'cargo_original', NEW.cargo_original, 'organizacion_original', NEW.organizacion_original, 'ubicacion_original', NEW.ubicacion_original, 'anio_inicio', NEW.anio_inicio, 'mes_inicio', NEW.mes_inicio, 'anio_fin', NEW.anio_fin, 'mes_fin', NEW.mes_fin, 'tipo_vinculo', NEW.tipo_vinculo, 'id_organizacion_propuesto', NEW.id_organizacion_propuesto, 'metodo_organizacion', NEW.metodo_organizacion, 'confianza_organizacion', NEW.confianza_organizacion, 'id_organizacion', NEW.id_organizacion, 'codigo_ocupacion_propuesto', NEW.codigo_ocupacion_propuesto, 'metodo_ocupacion', NEW.metodo_ocupacion, 'confianza_ocupacion', NEW.confianza_ocupacion, 'codigo_ocupacion', NEW.codigo_ocupacion, 'codigo_ubicacion_propuesto', NEW.codigo_ubicacion_propuesto, 'metodo_ubicacion', NEW.metodo_ubicacion, 'confianza_ubicacion', NEW.confianza_ubicacion, 'codigo_ubicacion', NEW.codigo_ubicacion, 'codigo_area_propuesto', NEW.codigo_area_propuesto, 'metodo_area', NEW.metodo_area, 'confianza_area', NEW.confianza_area, 'codigo_area', NEW.codigo_area, 'id_ejecucion_clasificacion', NEW.id_ejecucion_clasificacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_experiencia_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_experiencia_bitacora_au
AFTER UPDATE ON egresados.experiencia FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('experiencia', CONCAT_WS(',', NEW.id_experiencia), (SELECT x.id_egresado FROM egresados.captura x WHERE x.id_captura = NEW.id_captura), 'UPDATE',
  JSON_OBJECT('id_experiencia', OLD.id_experiencia, 'id_captura', OLD.id_captura, 'cargo_original', OLD.cargo_original, 'organizacion_original', OLD.organizacion_original, 'ubicacion_original', OLD.ubicacion_original, 'anio_inicio', OLD.anio_inicio, 'mes_inicio', OLD.mes_inicio, 'anio_fin', OLD.anio_fin, 'mes_fin', OLD.mes_fin, 'tipo_vinculo', OLD.tipo_vinculo, 'id_organizacion_propuesto', OLD.id_organizacion_propuesto, 'metodo_organizacion', OLD.metodo_organizacion, 'confianza_organizacion', OLD.confianza_organizacion, 'id_organizacion', OLD.id_organizacion, 'codigo_ocupacion_propuesto', OLD.codigo_ocupacion_propuesto, 'metodo_ocupacion', OLD.metodo_ocupacion, 'confianza_ocupacion', OLD.confianza_ocupacion, 'codigo_ocupacion', OLD.codigo_ocupacion, 'codigo_ubicacion_propuesto', OLD.codigo_ubicacion_propuesto, 'metodo_ubicacion', OLD.metodo_ubicacion, 'confianza_ubicacion', OLD.confianza_ubicacion, 'codigo_ubicacion', OLD.codigo_ubicacion, 'codigo_area_propuesto', OLD.codigo_area_propuesto, 'metodo_area', OLD.metodo_area, 'confianza_area', OLD.confianza_area, 'codigo_area', OLD.codigo_area, 'id_ejecucion_clasificacion', OLD.id_ejecucion_clasificacion),
  JSON_OBJECT('id_experiencia', NEW.id_experiencia, 'id_captura', NEW.id_captura, 'cargo_original', NEW.cargo_original, 'organizacion_original', NEW.organizacion_original, 'ubicacion_original', NEW.ubicacion_original, 'anio_inicio', NEW.anio_inicio, 'mes_inicio', NEW.mes_inicio, 'anio_fin', NEW.anio_fin, 'mes_fin', NEW.mes_fin, 'tipo_vinculo', NEW.tipo_vinculo, 'id_organizacion_propuesto', NEW.id_organizacion_propuesto, 'metodo_organizacion', NEW.metodo_organizacion, 'confianza_organizacion', NEW.confianza_organizacion, 'id_organizacion', NEW.id_organizacion, 'codigo_ocupacion_propuesto', NEW.codigo_ocupacion_propuesto, 'metodo_ocupacion', NEW.metodo_ocupacion, 'confianza_ocupacion', NEW.confianza_ocupacion, 'codigo_ocupacion', NEW.codigo_ocupacion, 'codigo_ubicacion_propuesto', NEW.codigo_ubicacion_propuesto, 'metodo_ubicacion', NEW.metodo_ubicacion, 'confianza_ubicacion', NEW.confianza_ubicacion, 'codigo_ubicacion', NEW.codigo_ubicacion, 'codigo_area_propuesto', NEW.codigo_area_propuesto, 'metodo_area', NEW.metodo_area, 'confianza_area', NEW.confianza_area, 'codigo_area', NEW.codigo_area, 'id_ejecucion_clasificacion', NEW.id_ejecucion_clasificacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_experiencia_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_experiencia_bitacora_ad
AFTER DELETE ON egresados.experiencia FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('experiencia', CONCAT_WS(',', OLD.id_experiencia), (SELECT x.id_egresado FROM egresados.captura x WHERE x.id_captura = OLD.id_captura), 'DELETE',
  JSON_OBJECT('id_experiencia', OLD.id_experiencia, 'id_captura', OLD.id_captura, 'cargo_original', OLD.cargo_original, 'organizacion_original', OLD.organizacion_original, 'ubicacion_original', OLD.ubicacion_original, 'anio_inicio', OLD.anio_inicio, 'mes_inicio', OLD.mes_inicio, 'anio_fin', OLD.anio_fin, 'mes_fin', OLD.mes_fin, 'tipo_vinculo', OLD.tipo_vinculo, 'id_organizacion_propuesto', OLD.id_organizacion_propuesto, 'metodo_organizacion', OLD.metodo_organizacion, 'confianza_organizacion', OLD.confianza_organizacion, 'id_organizacion', OLD.id_organizacion, 'codigo_ocupacion_propuesto', OLD.codigo_ocupacion_propuesto, 'metodo_ocupacion', OLD.metodo_ocupacion, 'confianza_ocupacion', OLD.confianza_ocupacion, 'codigo_ocupacion', OLD.codigo_ocupacion, 'codigo_ubicacion_propuesto', OLD.codigo_ubicacion_propuesto, 'metodo_ubicacion', OLD.metodo_ubicacion, 'confianza_ubicacion', OLD.confianza_ubicacion, 'codigo_ubicacion', OLD.codigo_ubicacion, 'codigo_area_propuesto', OLD.codigo_area_propuesto, 'metodo_area', OLD.metodo_area, 'confianza_area', OLD.confianza_area, 'codigo_area', OLD.codigo_area, 'id_ejecucion_clasificacion', OLD.id_ejecucion_clasificacion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_grado_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_grado_bitacora_ai
AFTER INSERT ON egresados.grado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('grado', CONCAT_WS(',', NEW.id_grado), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_grado', NEW.id_grado, 'id_egresado', NEW.id_egresado, 'id_programa', NEW.id_programa, 'anio_ingreso', NEW.anio_ingreso, 'semestre_ingreso', NEW.semestre_ingreso, 'fecha_grado', NEW.fecha_grado, 'estado', NEW.estado, 'id_ejecucion', NEW.id_ejecucion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_grado_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_grado_bitacora_au
AFTER UPDATE ON egresados.grado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('grado', CONCAT_WS(',', NEW.id_grado), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_grado', OLD.id_grado, 'id_egresado', OLD.id_egresado, 'id_programa', OLD.id_programa, 'anio_ingreso', OLD.anio_ingreso, 'semestre_ingreso', OLD.semestre_ingreso, 'fecha_grado', OLD.fecha_grado, 'estado', OLD.estado, 'id_ejecucion', OLD.id_ejecucion),
  JSON_OBJECT('id_grado', NEW.id_grado, 'id_egresado', NEW.id_egresado, 'id_programa', NEW.id_programa, 'anio_ingreso', NEW.anio_ingreso, 'semestre_ingreso', NEW.semestre_ingreso, 'fecha_grado', NEW.fecha_grado, 'estado', NEW.estado, 'id_ejecucion', NEW.id_ejecucion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_grado_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_grado_bitacora_ad
AFTER DELETE ON egresados.grado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('grado', CONCAT_WS(',', OLD.id_grado), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_grado', OLD.id_grado, 'id_egresado', OLD.id_egresado, 'id_programa', OLD.id_programa, 'anio_ingreso', OLD.anio_ingreso, 'semestre_ingreso', OLD.semestre_ingreso, 'fecha_grado', OLD.fecha_grado, 'estado', OLD.estado, 'id_ejecucion', OLD.id_ejecucion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_incidencia_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_incidencia_bitacora_ai
AFTER INSERT ON egresados.incidencia FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('incidencia', CONCAT_WS(',', NEW.id_incidencia), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_incidencia', NEW.id_incidencia, 'codigo_tipo_incidencia', NEW.codigo_tipo_incidencia, 'id_egresado', NEW.id_egresado, 'id_captura', NEW.id_captura, 'campo_afectado', NEW.campo_afectado, 'descripcion', NEW.descripcion, 'estado', NEW.estado, 'id_ejecucion', NEW.id_ejecucion, 'id_responsable_apertura', NEW.id_responsable_apertura, 'id_responsable_asignado', NEW.id_responsable_asignado, 'fecha_hora_apertura', NEW.fecha_hora_apertura, 'fecha_hora_cierre', NEW.fecha_hora_cierre, 'solucion', NEW.solucion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_incidencia_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_incidencia_bitacora_au
AFTER UPDATE ON egresados.incidencia FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('incidencia', CONCAT_WS(',', NEW.id_incidencia), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_incidencia', OLD.id_incidencia, 'codigo_tipo_incidencia', OLD.codigo_tipo_incidencia, 'id_egresado', OLD.id_egresado, 'id_captura', OLD.id_captura, 'campo_afectado', OLD.campo_afectado, 'descripcion', OLD.descripcion, 'estado', OLD.estado, 'id_ejecucion', OLD.id_ejecucion, 'id_responsable_apertura', OLD.id_responsable_apertura, 'id_responsable_asignado', OLD.id_responsable_asignado, 'fecha_hora_apertura', OLD.fecha_hora_apertura, 'fecha_hora_cierre', OLD.fecha_hora_cierre, 'solucion', OLD.solucion),
  JSON_OBJECT('id_incidencia', NEW.id_incidencia, 'codigo_tipo_incidencia', NEW.codigo_tipo_incidencia, 'id_egresado', NEW.id_egresado, 'id_captura', NEW.id_captura, 'campo_afectado', NEW.campo_afectado, 'descripcion', NEW.descripcion, 'estado', NEW.estado, 'id_ejecucion', NEW.id_ejecucion, 'id_responsable_apertura', NEW.id_responsable_apertura, 'id_responsable_asignado', NEW.id_responsable_asignado, 'fecha_hora_apertura', NEW.fecha_hora_apertura, 'fecha_hora_cierre', NEW.fecha_hora_cierre, 'solucion', NEW.solucion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_incidencia_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_incidencia_bitacora_ad
AFTER DELETE ON egresados.incidencia FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('incidencia', CONCAT_WS(',', OLD.id_incidencia), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_incidencia', OLD.id_incidencia, 'codigo_tipo_incidencia', OLD.codigo_tipo_incidencia, 'id_egresado', OLD.id_egresado, 'id_captura', OLD.id_captura, 'campo_afectado', OLD.campo_afectado, 'descripcion', OLD.descripcion, 'estado', OLD.estado, 'id_ejecucion', OLD.id_ejecucion, 'id_responsable_apertura', OLD.id_responsable_apertura, 'id_responsable_asignado', OLD.id_responsable_asignado, 'fecha_hora_apertura', OLD.fecha_hora_apertura, 'fecha_hora_cierre', OLD.fecha_hora_cierre, 'solucion', OLD.solucion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_indicador_externo_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_indicador_externo_bitacora_ai
AFTER INSERT ON egresados.indicador_externo FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('indicador_externo', CONCAT_WS(',', NEW.id_indicador_externo), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_indicador_externo', NEW.id_indicador_externo, 'codigo_fuente', NEW.codigo_fuente, 'id_programa', NEW.id_programa, 'nombre_indicador', NEW.nombre_indicador, 'anio_cohorte', NEW.anio_cohorte, 'anio_medicion', NEW.anio_medicion, 'valor', NEW.valor, 'unidad', NEW.unidad, 'referencia', NEW.referencia, 'fecha_consulta', NEW.fecha_consulta),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_indicador_externo_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_indicador_externo_bitacora_au
AFTER UPDATE ON egresados.indicador_externo FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('indicador_externo', CONCAT_WS(',', NEW.id_indicador_externo), NULL, 'UPDATE',
  JSON_OBJECT('id_indicador_externo', OLD.id_indicador_externo, 'codigo_fuente', OLD.codigo_fuente, 'id_programa', OLD.id_programa, 'nombre_indicador', OLD.nombre_indicador, 'anio_cohorte', OLD.anio_cohorte, 'anio_medicion', OLD.anio_medicion, 'valor', OLD.valor, 'unidad', OLD.unidad, 'referencia', OLD.referencia, 'fecha_consulta', OLD.fecha_consulta),
  JSON_OBJECT('id_indicador_externo', NEW.id_indicador_externo, 'codigo_fuente', NEW.codigo_fuente, 'id_programa', NEW.id_programa, 'nombre_indicador', NEW.nombre_indicador, 'anio_cohorte', NEW.anio_cohorte, 'anio_medicion', NEW.anio_medicion, 'valor', NEW.valor, 'unidad', NEW.unidad, 'referencia', NEW.referencia, 'fecha_consulta', NEW.fecha_consulta),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_indicador_externo_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_indicador_externo_bitacora_ad
AFTER DELETE ON egresados.indicador_externo FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('indicador_externo', CONCAT_WS(',', OLD.id_indicador_externo), NULL, 'DELETE',
  JSON_OBJECT('id_indicador_externo', OLD.id_indicador_externo, 'codigo_fuente', OLD.codigo_fuente, 'id_programa', OLD.id_programa, 'nombre_indicador', OLD.nombre_indicador, 'anio_cohorte', OLD.anio_cohorte, 'anio_medicion', OLD.anio_medicion, 'valor', OLD.valor, 'unidad', OLD.unidad, 'referencia', OLD.referencia, 'fecha_consulta', OLD.fecha_consulta),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_muestra_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_muestra_bitacora_ai
AFTER INSERT ON egresados.muestra FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('muestra', CONCAT_WS(',', NEW.id_muestra), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_muestra', NEW.id_muestra, 'poblacion', NEW.poblacion, 'margen_error', NEW.margen_error, 'nivel_confianza', NEW.nivel_confianza, 'proporcion_supuesta', NEW.proporcion_supuesta, 'semilla', NEW.semilla, 'id_ejecucion', NEW.id_ejecucion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_muestra_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_muestra_bitacora_au
AFTER UPDATE ON egresados.muestra FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('muestra', CONCAT_WS(',', NEW.id_muestra), NULL, 'UPDATE',
  JSON_OBJECT('id_muestra', OLD.id_muestra, 'poblacion', OLD.poblacion, 'margen_error', OLD.margen_error, 'nivel_confianza', OLD.nivel_confianza, 'proporcion_supuesta', OLD.proporcion_supuesta, 'semilla', OLD.semilla, 'id_ejecucion', OLD.id_ejecucion),
  JSON_OBJECT('id_muestra', NEW.id_muestra, 'poblacion', NEW.poblacion, 'margen_error', NEW.margen_error, 'nivel_confianza', NEW.nivel_confianza, 'proporcion_supuesta', NEW.proporcion_supuesta, 'semilla', NEW.semilla, 'id_ejecucion', NEW.id_ejecucion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_muestra_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_muestra_bitacora_ad
AFTER DELETE ON egresados.muestra FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('muestra', CONCAT_WS(',', OLD.id_muestra), NULL, 'DELETE',
  JSON_OBJECT('id_muestra', OLD.id_muestra, 'poblacion', OLD.poblacion, 'margen_error', OLD.margen_error, 'nivel_confianza', OLD.nivel_confianza, 'proporcion_supuesta', OLD.proporcion_supuesta, 'semilla', OLD.semilla, 'id_ejecucion', OLD.id_ejecucion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_muestra_egresado_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_muestra_egresado_bitacora_ai
AFTER INSERT ON egresados.muestra_egresado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('muestra_egresado', CONCAT_WS(',', NEW.id_muestra, NEW.id_egresado), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_muestra', NEW.id_muestra, 'id_egresado', NEW.id_egresado, 'estrato', NEW.estrato, 'peso', NEW.peso),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_muestra_egresado_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_muestra_egresado_bitacora_au
AFTER UPDATE ON egresados.muestra_egresado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('muestra_egresado', CONCAT_WS(',', NEW.id_muestra, NEW.id_egresado), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_muestra', OLD.id_muestra, 'id_egresado', OLD.id_egresado, 'estrato', OLD.estrato, 'peso', OLD.peso),
  JSON_OBJECT('id_muestra', NEW.id_muestra, 'id_egresado', NEW.id_egresado, 'estrato', NEW.estrato, 'peso', NEW.peso),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_muestra_egresado_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_muestra_egresado_bitacora_ad
AFTER DELETE ON egresados.muestra_egresado FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('muestra_egresado', CONCAT_WS(',', OLD.id_muestra, OLD.id_egresado), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_muestra', OLD.id_muestra, 'id_egresado', OLD.id_egresado, 'estrato', OLD.estrato, 'peso', OLD.peso),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_organizacion_alias_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_organizacion_alias_bitacora_ai
AFTER INSERT ON egresados.organizacion_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('organizacion_alias', CONCAT_WS(',', NEW.id_organizacion_alias), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_organizacion_alias', NEW.id_organizacion_alias, 'texto_normalizado', NEW.texto_normalizado, 'id_organizacion', NEW.id_organizacion, 'origen', NEW.origen, 'id_responsable', NEW.id_responsable, 'fecha_hora_validacion', NEW.fecha_hora_validacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_organizacion_alias_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_organizacion_alias_bitacora_au
AFTER UPDATE ON egresados.organizacion_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('organizacion_alias', CONCAT_WS(',', NEW.id_organizacion_alias), NULL, 'UPDATE',
  JSON_OBJECT('id_organizacion_alias', OLD.id_organizacion_alias, 'texto_normalizado', OLD.texto_normalizado, 'id_organizacion', OLD.id_organizacion, 'origen', OLD.origen, 'id_responsable', OLD.id_responsable, 'fecha_hora_validacion', OLD.fecha_hora_validacion),
  JSON_OBJECT('id_organizacion_alias', NEW.id_organizacion_alias, 'texto_normalizado', NEW.texto_normalizado, 'id_organizacion', NEW.id_organizacion, 'origen', NEW.origen, 'id_responsable', NEW.id_responsable, 'fecha_hora_validacion', NEW.fecha_hora_validacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_organizacion_alias_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_organizacion_alias_bitacora_ad
AFTER DELETE ON egresados.organizacion_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('organizacion_alias', CONCAT_WS(',', OLD.id_organizacion_alias), NULL, 'DELETE',
  JSON_OBJECT('id_organizacion_alias', OLD.id_organizacion_alias, 'texto_normalizado', OLD.texto_normalizado, 'id_organizacion', OLD.id_organizacion, 'origen', OLD.origen, 'id_responsable', OLD.id_responsable, 'fecha_hora_validacion', OLD.fecha_hora_validacion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_programa_alias_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_programa_alias_bitacora_ai
AFTER INSERT ON egresados.programa_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('programa_alias', CONCAT_WS(',', NEW.id_programa_alias), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_programa_alias', NEW.id_programa_alias, 'texto_normalizado', NEW.texto_normalizado, 'id_programa', NEW.id_programa, 'origen', NEW.origen, 'id_responsable', NEW.id_responsable, 'fecha_hora_validacion', NEW.fecha_hora_validacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_programa_alias_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_programa_alias_bitacora_au
AFTER UPDATE ON egresados.programa_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('programa_alias', CONCAT_WS(',', NEW.id_programa_alias), NULL, 'UPDATE',
  JSON_OBJECT('id_programa_alias', OLD.id_programa_alias, 'texto_normalizado', OLD.texto_normalizado, 'id_programa', OLD.id_programa, 'origen', OLD.origen, 'id_responsable', OLD.id_responsable, 'fecha_hora_validacion', OLD.fecha_hora_validacion),
  JSON_OBJECT('id_programa_alias', NEW.id_programa_alias, 'texto_normalizado', NEW.texto_normalizado, 'id_programa', NEW.id_programa, 'origen', NEW.origen, 'id_responsable', NEW.id_responsable, 'fecha_hora_validacion', NEW.fecha_hora_validacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_programa_alias_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_programa_alias_bitacora_ad
AFTER DELETE ON egresados.programa_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('programa_alias', CONCAT_WS(',', OLD.id_programa_alias), NULL, 'DELETE',
  JSON_OBJECT('id_programa_alias', OLD.id_programa_alias, 'texto_normalizado', OLD.texto_normalizado, 'id_programa', OLD.id_programa, 'origen', OLD.origen, 'id_responsable', OLD.id_responsable, 'fecha_hora_validacion', OLD.fecha_hora_validacion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_responsable_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_responsable_bitacora_ai
AFTER INSERT ON egresados.responsable FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('responsable', CONCAT_WS(',', NEW.id_responsable), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_responsable', NEW.id_responsable, 'usuario_bd', NEW.usuario_bd, 'nombre', NEW.nombre, 'tipo', NEW.tipo, 'fecha_alta', NEW.fecha_alta, 'fecha_baja', NEW.fecha_baja),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_responsable_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_responsable_bitacora_au
AFTER UPDATE ON egresados.responsable FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('responsable', CONCAT_WS(',', NEW.id_responsable), NULL, 'UPDATE',
  JSON_OBJECT('id_responsable', OLD.id_responsable, 'usuario_bd', OLD.usuario_bd, 'nombre', OLD.nombre, 'tipo', OLD.tipo, 'fecha_alta', OLD.fecha_alta, 'fecha_baja', OLD.fecha_baja),
  JSON_OBJECT('id_responsable', NEW.id_responsable, 'usuario_bd', NEW.usuario_bd, 'nombre', NEW.nombre, 'tipo', NEW.tipo, 'fecha_alta', NEW.fecha_alta, 'fecha_baja', NEW.fecha_baja),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_responsable_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_responsable_bitacora_ad
AFTER DELETE ON egresados.responsable FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('responsable', CONCAT_WS(',', OLD.id_responsable), NULL, 'DELETE',
  JSON_OBJECT('id_responsable', OLD.id_responsable, 'usuario_bd', OLD.usuario_bd, 'nombre', OLD.nombre, 'tipo', OLD.tipo, 'fecha_alta', OLD.fecha_alta, 'fecha_baja', OLD.fecha_baja),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_solicitud_actualizacion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_solicitud_actualizacion_bitacora_ai
AFTER INSERT ON egresados.solicitud_actualizacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('solicitud_actualizacion', CONCAT_WS(',', NEW.id_solicitud), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_solicitud', NEW.id_solicitud, 'id_egresado', NEW.id_egresado, 'codigo_momento', NEW.codigo_momento, 'id_ejecucion', NEW.id_ejecucion, 'fecha_hora_envio', NEW.fecha_hora_envio, 'numero_recordatorios', NEW.numero_recordatorios, 'estado_envio', NEW.estado_envio, 'huella_token', NEW.huella_token, 'fecha_vencimiento', NEW.fecha_vencimiento, 'respuesta', NEW.respuesta, 'fecha_hora_respuesta', NEW.fecha_hora_respuesta, 'id_captura', NEW.id_captura),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_solicitud_actualizacion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_solicitud_actualizacion_bitacora_au
AFTER UPDATE ON egresados.solicitud_actualizacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('solicitud_actualizacion', CONCAT_WS(',', NEW.id_solicitud), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_solicitud', OLD.id_solicitud, 'id_egresado', OLD.id_egresado, 'codigo_momento', OLD.codigo_momento, 'id_ejecucion', OLD.id_ejecucion, 'fecha_hora_envio', OLD.fecha_hora_envio, 'numero_recordatorios', OLD.numero_recordatorios, 'estado_envio', OLD.estado_envio, 'huella_token', OLD.huella_token, 'fecha_vencimiento', OLD.fecha_vencimiento, 'respuesta', OLD.respuesta, 'fecha_hora_respuesta', OLD.fecha_hora_respuesta, 'id_captura', OLD.id_captura),
  JSON_OBJECT('id_solicitud', NEW.id_solicitud, 'id_egresado', NEW.id_egresado, 'codigo_momento', NEW.codigo_momento, 'id_ejecucion', NEW.id_ejecucion, 'fecha_hora_envio', NEW.fecha_hora_envio, 'numero_recordatorios', NEW.numero_recordatorios, 'estado_envio', NEW.estado_envio, 'huella_token', NEW.huella_token, 'fecha_vencimiento', NEW.fecha_vencimiento, 'respuesta', NEW.respuesta, 'fecha_hora_respuesta', NEW.fecha_hora_respuesta, 'id_captura', NEW.id_captura),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_solicitud_actualizacion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_solicitud_actualizacion_bitacora_ad
AFTER DELETE ON egresados.solicitud_actualizacion FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('solicitud_actualizacion', CONCAT_WS(',', OLD.id_solicitud), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_solicitud', OLD.id_solicitud, 'id_egresado', OLD.id_egresado, 'codigo_momento', OLD.codigo_momento, 'id_ejecucion', OLD.id_ejecucion, 'fecha_hora_envio', OLD.fecha_hora_envio, 'numero_recordatorios', OLD.numero_recordatorios, 'estado_envio', OLD.estado_envio, 'huella_token', OLD.huella_token, 'fecha_vencimiento', OLD.fecha_vencimiento, 'respuesta', OLD.respuesta, 'fecha_hora_respuesta', OLD.fecha_hora_respuesta, 'id_captura', OLD.id_captura),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_ubicacion_alias_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_ubicacion_alias_bitacora_ai
AFTER INSERT ON egresados.ubicacion_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('ubicacion_alias', CONCAT_WS(',', NEW.id_ubicacion_alias), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_ubicacion_alias', NEW.id_ubicacion_alias, 'texto_normalizado', NEW.texto_normalizado, 'codigo_ubicacion', NEW.codigo_ubicacion, 'origen', NEW.origen, 'id_responsable', NEW.id_responsable, 'fecha_hora_validacion', NEW.fecha_hora_validacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_ubicacion_alias_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_ubicacion_alias_bitacora_au
AFTER UPDATE ON egresados.ubicacion_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('ubicacion_alias', CONCAT_WS(',', NEW.id_ubicacion_alias), NULL, 'UPDATE',
  JSON_OBJECT('id_ubicacion_alias', OLD.id_ubicacion_alias, 'texto_normalizado', OLD.texto_normalizado, 'codigo_ubicacion', OLD.codigo_ubicacion, 'origen', OLD.origen, 'id_responsable', OLD.id_responsable, 'fecha_hora_validacion', OLD.fecha_hora_validacion),
  JSON_OBJECT('id_ubicacion_alias', NEW.id_ubicacion_alias, 'texto_normalizado', NEW.texto_normalizado, 'codigo_ubicacion', NEW.codigo_ubicacion, 'origen', NEW.origen, 'id_responsable', NEW.id_responsable, 'fecha_hora_validacion', NEW.fecha_hora_validacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados.trg_ubicacion_alias_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados.trg_ubicacion_alias_bitacora_ad
AFTER DELETE ON egresados.ubicacion_alias FOR EACH ROW
INSERT INTO egresados.bitacora (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('ubicacion_alias', CONCAT_WS(',', OLD.id_ubicacion_alias), NULL, 'DELETE',
  JSON_OBJECT('id_ubicacion_alias', OLD.id_ubicacion_alias, 'texto_normalizado', OLD.texto_normalizado, 'codigo_ubicacion', OLD.codigo_ubicacion, 'origen', OLD.origen, 'id_responsable', OLD.id_responsable, 'fecha_hora_validacion', OLD.fecha_hora_validacion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_autorizacion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_autorizacion_bitacora_ai
AFTER INSERT ON egresados_identidad.autorizacion FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('autorizacion', CONCAT_WS(',', NEW.id_autorizacion), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_autorizacion', NEW.id_autorizacion, 'id_egresado', NEW.id_egresado, 'id_texto_autorizacion', NEW.id_texto_autorizacion, 'codigo_fuente', NEW.codigo_fuente, 'fecha_hora', NEW.fecha_hora, 'evidencia', NEW.evidencia),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_autorizacion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_autorizacion_bitacora_au
AFTER UPDATE ON egresados_identidad.autorizacion FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('autorizacion', CONCAT_WS(',', NEW.id_autorizacion), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_autorizacion', OLD.id_autorizacion, 'id_egresado', OLD.id_egresado, 'id_texto_autorizacion', OLD.id_texto_autorizacion, 'codigo_fuente', OLD.codigo_fuente, 'fecha_hora', OLD.fecha_hora, 'evidencia', OLD.evidencia),
  JSON_OBJECT('id_autorizacion', NEW.id_autorizacion, 'id_egresado', NEW.id_egresado, 'id_texto_autorizacion', NEW.id_texto_autorizacion, 'codigo_fuente', NEW.codigo_fuente, 'fecha_hora', NEW.fecha_hora, 'evidencia', NEW.evidencia),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_autorizacion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_autorizacion_bitacora_ad
AFTER DELETE ON egresados_identidad.autorizacion FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('autorizacion', CONCAT_WS(',', OLD.id_autorizacion), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_autorizacion', OLD.id_autorizacion, 'id_egresado', OLD.id_egresado, 'id_texto_autorizacion', OLD.id_texto_autorizacion, 'codigo_fuente', OLD.codigo_fuente, 'fecha_hora', OLD.fecha_hora, 'evidencia', OLD.evidencia),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_coincidencia_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_coincidencia_bitacora_ai
AFTER INSERT ON egresados_identidad.coincidencia FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('coincidencia', CONCAT_WS(',', NEW.id_coincidencia), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_coincidencia', NEW.id_coincidencia, 'id_egresado', NEW.id_egresado, 'id_perfil', NEW.id_perfil, 'id_busqueda', NEW.id_busqueda, 'id_ejecucion', NEW.id_ejecucion, 'nombre_observado', IF(NEW.nombre_observado IS NULL, NULL, '[omitido]'), 'programa_observado', IF(NEW.programa_observado IS NULL, NULL, '[omitido]'), 'anio_inicio_observado', IF(NEW.anio_inicio_observado IS NULL, NULL, '[omitido]'), 'anio_fin_observado', IF(NEW.anio_fin_observado IS NULL, NULL, '[omitido]'), 'ciudad_observada', IF(NEW.ciudad_observada IS NULL, NULL, '[omitido]'), 'puntaje_nombre', NEW.puntaje_nombre, 'puntaje_programa', NEW.puntaje_programa, 'puntaje_anio', NEW.puntaje_anio, 'puntaje_ciudad', NEW.puntaje_ciudad, 'puntaje_total', NEW.puntaje_total, 'nivel', NEW.nivel, 'motivo_nivel', NEW.motivo_nivel, 'estado', NEW.estado, 'fecha_hora_borrado_observados', NEW.fecha_hora_borrado_observados),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_coincidencia_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_coincidencia_bitacora_au
AFTER UPDATE ON egresados_identidad.coincidencia FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('coincidencia', CONCAT_WS(',', NEW.id_coincidencia), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_coincidencia', OLD.id_coincidencia, 'id_egresado', OLD.id_egresado, 'id_perfil', OLD.id_perfil, 'id_busqueda', OLD.id_busqueda, 'id_ejecucion', OLD.id_ejecucion, 'nombre_observado', IF(OLD.nombre_observado IS NULL, NULL, '[omitido]'), 'programa_observado', IF(OLD.programa_observado IS NULL, NULL, '[omitido]'), 'anio_inicio_observado', IF(OLD.anio_inicio_observado IS NULL, NULL, '[omitido]'), 'anio_fin_observado', IF(OLD.anio_fin_observado IS NULL, NULL, '[omitido]'), 'ciudad_observada', IF(OLD.ciudad_observada IS NULL, NULL, '[omitido]'), 'puntaje_nombre', OLD.puntaje_nombre, 'puntaje_programa', OLD.puntaje_programa, 'puntaje_anio', OLD.puntaje_anio, 'puntaje_ciudad', OLD.puntaje_ciudad, 'puntaje_total', OLD.puntaje_total, 'nivel', OLD.nivel, 'motivo_nivel', OLD.motivo_nivel, 'estado', OLD.estado, 'fecha_hora_borrado_observados', OLD.fecha_hora_borrado_observados),
  JSON_OBJECT('id_coincidencia', NEW.id_coincidencia, 'id_egresado', NEW.id_egresado, 'id_perfil', NEW.id_perfil, 'id_busqueda', NEW.id_busqueda, 'id_ejecucion', NEW.id_ejecucion, 'nombre_observado', IF(NEW.nombre_observado IS NULL, NULL, '[omitido]'), 'programa_observado', IF(NEW.programa_observado IS NULL, NULL, '[omitido]'), 'anio_inicio_observado', IF(NEW.anio_inicio_observado IS NULL, NULL, '[omitido]'), 'anio_fin_observado', IF(NEW.anio_fin_observado IS NULL, NULL, '[omitido]'), 'ciudad_observada', IF(NEW.ciudad_observada IS NULL, NULL, '[omitido]'), 'puntaje_nombre', NEW.puntaje_nombre, 'puntaje_programa', NEW.puntaje_programa, 'puntaje_anio', NEW.puntaje_anio, 'puntaje_ciudad', NEW.puntaje_ciudad, 'puntaje_total', NEW.puntaje_total, 'nivel', NEW.nivel, 'motivo_nivel', NEW.motivo_nivel, 'estado', NEW.estado, 'fecha_hora_borrado_observados', NEW.fecha_hora_borrado_observados),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_coincidencia_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_coincidencia_bitacora_ad
AFTER DELETE ON egresados_identidad.coincidencia FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('coincidencia', CONCAT_WS(',', OLD.id_coincidencia), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_coincidencia', OLD.id_coincidencia, 'id_egresado', OLD.id_egresado, 'id_perfil', OLD.id_perfil, 'id_busqueda', OLD.id_busqueda, 'id_ejecucion', OLD.id_ejecucion, 'nombre_observado', IF(OLD.nombre_observado IS NULL, NULL, '[omitido]'), 'programa_observado', IF(OLD.programa_observado IS NULL, NULL, '[omitido]'), 'anio_inicio_observado', IF(OLD.anio_inicio_observado IS NULL, NULL, '[omitido]'), 'anio_fin_observado', IF(OLD.anio_fin_observado IS NULL, NULL, '[omitido]'), 'ciudad_observada', IF(OLD.ciudad_observada IS NULL, NULL, '[omitido]'), 'puntaje_nombre', OLD.puntaje_nombre, 'puntaje_programa', OLD.puntaje_programa, 'puntaje_anio', OLD.puntaje_anio, 'puntaje_ciudad', OLD.puntaje_ciudad, 'puntaje_total', OLD.puntaje_total, 'nivel', OLD.nivel, 'motivo_nivel', OLD.motivo_nivel, 'estado', OLD.estado, 'fecha_hora_borrado_observados', OLD.fecha_hora_borrado_observados),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_decision_coincidencia_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_decision_coincidencia_bitacora_ai
AFTER INSERT ON egresados_identidad.decision_coincidencia FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('decision_coincidencia', CONCAT_WS(',', NEW.id_decision), (SELECT x.id_egresado FROM egresados_identidad.coincidencia x WHERE x.id_coincidencia = NEW.id_coincidencia), 'INSERT',
  NULL,
  JSON_OBJECT('id_decision', NEW.id_decision, 'id_coincidencia', NEW.id_coincidencia, 'tipo_decision', NEW.tipo_decision, 'resultado', NEW.resultado, 'id_ejecucion', NEW.id_ejecucion, 'id_responsable', NEW.id_responsable, 'motivo', NEW.motivo, 'fecha_hora', NEW.fecha_hora),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_decision_coincidencia_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_decision_coincidencia_bitacora_au
AFTER UPDATE ON egresados_identidad.decision_coincidencia FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('decision_coincidencia', CONCAT_WS(',', NEW.id_decision), (SELECT x.id_egresado FROM egresados_identidad.coincidencia x WHERE x.id_coincidencia = NEW.id_coincidencia), 'UPDATE',
  JSON_OBJECT('id_decision', OLD.id_decision, 'id_coincidencia', OLD.id_coincidencia, 'tipo_decision', OLD.tipo_decision, 'resultado', OLD.resultado, 'id_ejecucion', OLD.id_ejecucion, 'id_responsable', OLD.id_responsable, 'motivo', OLD.motivo, 'fecha_hora', OLD.fecha_hora),
  JSON_OBJECT('id_decision', NEW.id_decision, 'id_coincidencia', NEW.id_coincidencia, 'tipo_decision', NEW.tipo_decision, 'resultado', NEW.resultado, 'id_ejecucion', NEW.id_ejecucion, 'id_responsable', NEW.id_responsable, 'motivo', NEW.motivo, 'fecha_hora', NEW.fecha_hora),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_decision_coincidencia_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_decision_coincidencia_bitacora_ad
AFTER DELETE ON egresados_identidad.decision_coincidencia FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('decision_coincidencia', CONCAT_WS(',', OLD.id_decision), (SELECT x.id_egresado FROM egresados_identidad.coincidencia x WHERE x.id_coincidencia = OLD.id_coincidencia), 'DELETE',
  JSON_OBJECT('id_decision', OLD.id_decision, 'id_coincidencia', OLD.id_coincidencia, 'tipo_decision', OLD.tipo_decision, 'resultado', OLD.resultado, 'id_ejecucion', OLD.id_ejecucion, 'id_responsable', OLD.id_responsable, 'motivo', OLD.motivo, 'fecha_hora', OLD.fecha_hora),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_documento_identidad_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_documento_identidad_bitacora_ai
AFTER INSERT ON egresados_identidad.documento_identidad FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('documento_identidad', CONCAT_WS(',', NEW.id_documento), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_documento', NEW.id_documento, 'id_egresado', NEW.id_egresado, 'tipo_documento', NEW.tipo_documento, 'numero_documento', NEW.numero_documento),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_documento_identidad_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_documento_identidad_bitacora_au
AFTER UPDATE ON egresados_identidad.documento_identidad FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('documento_identidad', CONCAT_WS(',', NEW.id_documento), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_documento', OLD.id_documento, 'id_egresado', OLD.id_egresado, 'tipo_documento', OLD.tipo_documento, 'numero_documento', OLD.numero_documento),
  JSON_OBJECT('id_documento', NEW.id_documento, 'id_egresado', NEW.id_egresado, 'tipo_documento', NEW.tipo_documento, 'numero_documento', NEW.numero_documento),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_documento_identidad_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_documento_identidad_bitacora_ad
AFTER DELETE ON egresados_identidad.documento_identidad FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('documento_identidad', CONCAT_WS(',', OLD.id_documento), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_documento', OLD.id_documento, 'id_egresado', OLD.id_egresado, 'tipo_documento', OLD.tipo_documento, 'numero_documento', OLD.numero_documento),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_huella_no_contactar_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_huella_no_contactar_bitacora_ai
AFTER INSERT ON egresados_identidad.huella_no_contactar FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('huella_no_contactar', CONCAT_WS(',', NEW.id_huella), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_huella', NEW.id_huella, 'id_solicitud_supresion', NEW.id_solicitud_supresion, 'tipo_huella', NEW.tipo_huella, 'huella', NEW.huella),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_huella_no_contactar_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_huella_no_contactar_bitacora_au
AFTER UPDATE ON egresados_identidad.huella_no_contactar FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('huella_no_contactar', CONCAT_WS(',', NEW.id_huella), NULL, 'UPDATE',
  JSON_OBJECT('id_huella', OLD.id_huella, 'id_solicitud_supresion', OLD.id_solicitud_supresion, 'tipo_huella', OLD.tipo_huella, 'huella', OLD.huella),
  JSON_OBJECT('id_huella', NEW.id_huella, 'id_solicitud_supresion', NEW.id_solicitud_supresion, 'tipo_huella', NEW.tipo_huella, 'huella', NEW.huella),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_huella_no_contactar_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_huella_no_contactar_bitacora_ad
AFTER DELETE ON egresados_identidad.huella_no_contactar FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('huella_no_contactar', CONCAT_WS(',', OLD.id_huella), NULL, 'DELETE',
  JSON_OBJECT('id_huella', OLD.id_huella, 'id_solicitud_supresion', OLD.id_solicitud_supresion, 'tipo_huella', OLD.tipo_huella, 'huella', OLD.huella),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_identidad_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_identidad_bitacora_ai
AFTER INSERT ON egresados_identidad.identidad FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('identidad', CONCAT_WS(',', NEW.id_egresado), NEW.id_egresado, 'INSERT',
  NULL,
  JSON_OBJECT('id_egresado', NEW.id_egresado, 'nombres', NEW.nombres, 'primer_apellido', NEW.primer_apellido, 'segundo_apellido', NEW.segundo_apellido, 'correo_personal', NEW.correo_personal, 'correo_institucional', NEW.correo_institucional),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_identidad_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_identidad_bitacora_au
AFTER UPDATE ON egresados_identidad.identidad FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('identidad', CONCAT_WS(',', NEW.id_egresado), NEW.id_egresado, 'UPDATE',
  JSON_OBJECT('id_egresado', OLD.id_egresado, 'nombres', OLD.nombres, 'primer_apellido', OLD.primer_apellido, 'segundo_apellido', OLD.segundo_apellido, 'correo_personal', OLD.correo_personal, 'correo_institucional', OLD.correo_institucional),
  JSON_OBJECT('id_egresado', NEW.id_egresado, 'nombres', NEW.nombres, 'primer_apellido', NEW.primer_apellido, 'segundo_apellido', NEW.segundo_apellido, 'correo_personal', NEW.correo_personal, 'correo_institucional', NEW.correo_institucional),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_identidad_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_identidad_bitacora_ad
AFTER DELETE ON egresados_identidad.identidad FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('identidad', CONCAT_WS(',', OLD.id_egresado), OLD.id_egresado, 'DELETE',
  JSON_OBJECT('id_egresado', OLD.id_egresado, 'nombres', OLD.nombres, 'primer_apellido', OLD.primer_apellido, 'segundo_apellido', OLD.segundo_apellido, 'correo_personal', OLD.correo_personal, 'correo_institucional', OLD.correo_institucional),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_perfil_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_perfil_bitacora_ai
AFTER INSERT ON egresados_identidad.perfil FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('perfil', CONCAT_WS(',', NEW.id_perfil), (SELECT x.id_egresado FROM egresados_identidad.coincidencia x WHERE x.id_perfil = NEW.id_perfil AND x.estado = 'ACEPTADA'), 'INSERT',
  NULL,
  JSON_OBJECT('id_perfil', NEW.id_perfil, 'url', IF(NEW.url IS NULL, NULL, '[omitido]'), 'huella_url', NEW.huella_url, 'fecha_hora_borrado_url', NEW.fecha_hora_borrado_url),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_perfil_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_perfil_bitacora_au
AFTER UPDATE ON egresados_identidad.perfil FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('perfil', CONCAT_WS(',', NEW.id_perfil), (SELECT x.id_egresado FROM egresados_identidad.coincidencia x WHERE x.id_perfil = NEW.id_perfil AND x.estado = 'ACEPTADA'), 'UPDATE',
  JSON_OBJECT('id_perfil', OLD.id_perfil, 'url', IF(OLD.url IS NULL, NULL, '[omitido]'), 'huella_url', OLD.huella_url, 'fecha_hora_borrado_url', OLD.fecha_hora_borrado_url),
  JSON_OBJECT('id_perfil', NEW.id_perfil, 'url', IF(NEW.url IS NULL, NULL, '[omitido]'), 'huella_url', NEW.huella_url, 'fecha_hora_borrado_url', NEW.fecha_hora_borrado_url),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_solicitud_supresion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_solicitud_supresion_bitacora_ai
AFTER INSERT ON egresados_identidad.solicitud_supresion FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('solicitud_supresion', CONCAT_WS(',', NEW.id_solicitud_supresion), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_solicitud_supresion', NEW.id_solicitud_supresion, 'tipo_solicitud', NEW.tipo_solicitud, 'canal_solicitud', NEW.canal_solicitud, 'fecha_hora_solicitud', NEW.fecha_hora_solicitud, 'fecha_hora_atencion', NEW.fecha_hora_atencion, 'id_responsable', NEW.id_responsable, 'observacion', NEW.observacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_solicitud_supresion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_solicitud_supresion_bitacora_au
AFTER UPDATE ON egresados_identidad.solicitud_supresion FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('solicitud_supresion', CONCAT_WS(',', NEW.id_solicitud_supresion), NULL, 'UPDATE',
  JSON_OBJECT('id_solicitud_supresion', OLD.id_solicitud_supresion, 'tipo_solicitud', OLD.tipo_solicitud, 'canal_solicitud', OLD.canal_solicitud, 'fecha_hora_solicitud', OLD.fecha_hora_solicitud, 'fecha_hora_atencion', OLD.fecha_hora_atencion, 'id_responsable', OLD.id_responsable, 'observacion', OLD.observacion),
  JSON_OBJECT('id_solicitud_supresion', NEW.id_solicitud_supresion, 'tipo_solicitud', NEW.tipo_solicitud, 'canal_solicitud', NEW.canal_solicitud, 'fecha_hora_solicitud', NEW.fecha_hora_solicitud, 'fecha_hora_atencion', NEW.fecha_hora_atencion, 'id_responsable', NEW.id_responsable, 'observacion', NEW.observacion),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_solicitud_supresion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_solicitud_supresion_bitacora_ad
AFTER DELETE ON egresados_identidad.solicitud_supresion FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('solicitud_supresion', CONCAT_WS(',', OLD.id_solicitud_supresion), NULL, 'DELETE',
  JSON_OBJECT('id_solicitud_supresion', OLD.id_solicitud_supresion, 'tipo_solicitud', OLD.tipo_solicitud, 'canal_solicitud', OLD.canal_solicitud, 'fecha_hora_solicitud', OLD.fecha_hora_solicitud, 'fecha_hora_atencion', OLD.fecha_hora_atencion, 'id_responsable', OLD.id_responsable, 'observacion', OLD.observacion),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_texto_autorizacion_bitacora_ai;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_texto_autorizacion_bitacora_ai
AFTER INSERT ON egresados_identidad.texto_autorizacion FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('texto_autorizacion', CONCAT_WS(',', NEW.id_texto_autorizacion), NULL, 'INSERT',
  NULL,
  JSON_OBJECT('id_texto_autorizacion', NEW.id_texto_autorizacion, 'version', NEW.version, 'texto', NEW.texto, 'fecha_inicio_vigencia', NEW.fecha_inicio_vigencia, 'fecha_fin_vigencia', NEW.fecha_fin_vigencia),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_texto_autorizacion_bitacora_au;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_texto_autorizacion_bitacora_au
AFTER UPDATE ON egresados_identidad.texto_autorizacion FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('texto_autorizacion', CONCAT_WS(',', NEW.id_texto_autorizacion), NULL, 'UPDATE',
  JSON_OBJECT('id_texto_autorizacion', OLD.id_texto_autorizacion, 'version', OLD.version, 'texto', OLD.texto, 'fecha_inicio_vigencia', OLD.fecha_inicio_vigencia, 'fecha_fin_vigencia', OLD.fecha_fin_vigencia),
  JSON_OBJECT('id_texto_autorizacion', NEW.id_texto_autorizacion, 'version', NEW.version, 'texto', NEW.texto, 'fecha_inicio_vigencia', NEW.fecha_inicio_vigencia, 'fecha_fin_vigencia', NEW.fecha_fin_vigencia),
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());

DROP TRIGGER IF EXISTS egresados_identidad.trg_texto_autorizacion_bitacora_ad;
CREATE DEFINER = 'definidor_egresados'@'localhost' TRIGGER egresados_identidad.trg_texto_autorizacion_bitacora_ad
AFTER DELETE ON egresados_identidad.texto_autorizacion FOR EACH ROW
INSERT INTO egresados_identidad.bitacora_identidad (tabla, id_registro, id_egresado, operacion, valores_anteriores, valores_nuevos, usuario_bd, id_ejecucion, motivo, fecha_hora)
VALUES ('texto_autorizacion', CONCAT_WS(',', OLD.id_texto_autorizacion), NULL, 'DELETE',
  JSON_OBJECT('id_texto_autorizacion', OLD.id_texto_autorizacion, 'version', OLD.version, 'texto', OLD.texto, 'fecha_inicio_vigencia', OLD.fecha_inicio_vigencia, 'fecha_fin_vigencia', OLD.fecha_fin_vigencia),
  NULL,
  SUBSTRING_INDEX(SESSION_USER(), '@', 1), @id_ejecucion, @motivo, NOW());
