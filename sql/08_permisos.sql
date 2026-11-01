-- =====================================================================
-- 08_permisos.sql
-- Permisos de cada rol. Modelo de datos, pasos 0.4 y 3.9.
-- =====================================================================
--
-- Mínimo privilegio: cada rol tiene solo lo que su función necesita.
-- Varias reglas se cumplen porque ningún rol tiene el permiso:
--   * Nadie escribe en las bitácoras: solo los disparadores, que se
--     ejecutan con los permisos de la cuenta dueña.
--   * Nadie modifica el estado, los puntajes ni el nivel de una
--     coincidencia (el estado lo cambia su disparador).
--   * Nadie modifica un texto de autorización publicado.
--   * Nadie borra egresados ni perfiles directamente: solo el
--     procedimiento de supresión.

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- rol_admin: estructura y mantenimiento de las dos bases
-- ---------------------------------------------------------------------
GRANT ALL PRIVILEGES ON egresados.* TO rol_admin;
GRANT ALL PRIVILEGES ON egresados_identidad.* TO rol_admin;

-- ---------------------------------------------------------------------
-- rol_analista: solo las vistas de análisis y los catálogos.
-- Ningún permiso sobre egresados_identidad.
-- ---------------------------------------------------------------------
GRANT SELECT ON egresados.v_grado TO rol_analista;
GRANT SELECT ON egresados.v_captura_vigente TO rol_analista;
GRANT SELECT ON egresados.v_experiencia TO rol_analista;
GRANT SELECT ON egresados.v_estudio TO rol_analista;
GRANT SELECT ON egresados.v_resumen_decisiones TO rol_analista;
GRANT SELECT ON egresados.cat_nivel_formacion TO rol_analista;
GRANT SELECT ON egresados.cat_fuente TO rol_analista;
GRANT SELECT ON egresados.cat_momento_seguimiento TO rol_analista;
GRANT SELECT ON egresados.cat_area_desempeno TO rol_analista;
GRANT SELECT ON egresados.cat_ocupacion TO rol_analista;
GRANT SELECT ON egresados.cat_actividad_economica TO rol_analista;
GRANT SELECT ON egresados.cat_ubicacion TO rol_analista;
GRANT SELECT ON egresados.cat_programa TO rol_analista;
GRANT SELECT ON egresados.cat_organizacion TO rol_analista;
GRANT SELECT ON egresados.afinidad_programa_ocupacion TO rol_analista;
GRANT SELECT ON egresados.indicador_externo TO rol_analista;

-- ---------------------------------------------------------------------
-- rol_bot: lo que producen los procesos automáticos
-- ---------------------------------------------------------------------
-- Lee todas las tablas de egresados, menos la bitácora
GRANT SELECT ON egresados.cat_nivel_formacion TO rol_bot;
GRANT SELECT ON egresados.cat_fuente TO rol_bot;
GRANT SELECT ON egresados.cat_tipo_incidencia TO rol_bot;
GRANT SELECT ON egresados.cat_momento_seguimiento TO rol_bot;
GRANT SELECT ON egresados.cat_area_desempeno TO rol_bot;
GRANT SELECT ON egresados.cat_ocupacion TO rol_bot;
GRANT SELECT ON egresados.cat_actividad_economica TO rol_bot;
GRANT SELECT ON egresados.cat_ubicacion TO rol_bot;
GRANT SELECT ON egresados.responsable TO rol_bot;
GRANT SELECT ON egresados.ejecucion TO rol_bot;
GRANT SELECT ON egresados.cat_programa TO rol_bot;
GRANT SELECT ON egresados.cat_organizacion TO rol_bot;
GRANT SELECT ON egresados.programa_alias TO rol_bot;
GRANT SELECT ON egresados.organizacion_alias TO rol_bot;
GRANT SELECT ON egresados.cargo_alias TO rol_bot;
GRANT SELECT ON egresados.ubicacion_alias TO rol_bot;
GRANT SELECT ON egresados.afinidad_programa_ocupacion TO rol_bot;
GRANT SELECT ON egresados.egresado TO rol_bot;
GRANT SELECT ON egresados.grado TO rol_bot;
GRANT SELECT ON egresados.muestra TO rol_bot;
GRANT SELECT ON egresados.muestra_egresado TO rol_bot;
GRANT SELECT ON egresados.busqueda TO rol_bot;
GRANT SELECT ON egresados.indicador_externo TO rol_bot;
GRANT SELECT ON egresados.captura TO rol_bot;
GRANT SELECT ON egresados.experiencia TO rol_bot;
GRANT SELECT ON egresados.estudio_declarado TO rol_bot;
GRANT SELECT ON egresados.solicitud_actualizacion TO rol_bot;
GRANT SELECT ON egresados.incidencia TO rol_bot;

-- Inserta lo que producen los procesos
GRANT INSERT ON egresados.ejecucion TO rol_bot;
GRANT INSERT ON egresados.egresado TO rol_bot;
GRANT INSERT ON egresados.grado TO rol_bot;
GRANT INSERT ON egresados.captura TO rol_bot;
GRANT INSERT ON egresados.experiencia TO rol_bot;
GRANT INSERT ON egresados.estudio_declarado TO rol_bot;
GRANT INSERT ON egresados.cat_organizacion TO rol_bot;
GRANT INSERT ON egresados.incidencia TO rol_bot;
GRANT INSERT ON egresados.solicitud_actualizacion TO rol_bot;
GRANT INSERT ON egresados.muestra TO rol_bot;
GRANT INSERT ON egresados.muestra_egresado TO rol_bot;

-- Modifica solo las columnas que sus procesos actualizan
GRANT UPDATE (fecha_hora_fin, resultado, registros_procesados) ON egresados.ejecucion TO rol_bot;
GRANT UPDATE (sexo) ON egresados.egresado TO rol_bot;
GRANT UPDATE (anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion) ON egresados.grado TO rol_bot;
GRANT UPDATE (id_perfil, estado, fecha_hora_borrado_archivo) ON egresados.captura TO rol_bot;
GRANT UPDATE (tipo_vinculo,
              id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
              codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
              codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
              codigo_area_propuesto, metodo_area, confianza_area, codigo_area,
              id_ejecucion_clasificacion) ON egresados.experiencia TO rol_bot;
GRANT UPDATE (codigo_nivel, id_programa,
              id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
              id_ejecucion_clasificacion) ON egresados.estudio_declarado TO rol_bot;
GRANT UPDATE (codigo_actividad_propuesto, metodo_actividad, confianza_actividad, codigo_actividad,
              id_ejecucion_clasificacion) ON egresados.cat_organizacion TO rol_bot;
GRANT UPDATE (estado_envio, numero_recordatorios, respuesta, fecha_hora_respuesta, id_captura)
  ON egresados.solicitud_actualizacion TO rol_bot;

-- En la base de identidad: lo necesario para el cruce y la carga oficial
GRANT SELECT ON egresados_identidad.identidad TO rol_bot;
GRANT SELECT ON egresados_identidad.documento_identidad TO rol_bot;
GRANT SELECT ON egresados_identidad.texto_autorizacion TO rol_bot;
GRANT SELECT ON egresados_identidad.autorizacion TO rol_bot;
GRANT SELECT ON egresados_identidad.perfil TO rol_bot;
GRANT SELECT ON egresados_identidad.coincidencia TO rol_bot;
GRANT SELECT ON egresados_identidad.decision_coincidencia TO rol_bot;
GRANT SELECT ON egresados_identidad.huella_no_contactar TO rol_bot;
GRANT INSERT ON egresados_identidad.identidad TO rol_bot;
GRANT INSERT ON egresados_identidad.documento_identidad TO rol_bot;
GRANT INSERT ON egresados_identidad.autorizacion TO rol_bot;
GRANT INSERT ON egresados_identidad.perfil TO rol_bot;
GRANT INSERT ON egresados_identidad.coincidencia TO rol_bot;
GRANT INSERT ON egresados_identidad.decision_coincidencia TO rol_bot;
GRANT UPDATE (nombres, primer_apellido, segundo_apellido, correo_personal, correo_institucional)
  ON egresados_identidad.identidad TO rol_bot;
-- La depuración borra la URL de los candidatos descartados y los datos observados
GRANT UPDATE (url, fecha_hora_borrado_url) ON egresados_identidad.perfil TO rol_bot;
GRANT UPDATE (nombre_observado, programa_observado, anio_inicio_observado, anio_fin_observado,
              ciudad_observada, fecha_hora_borrado_observados) ON egresados_identidad.coincidencia TO rol_bot;

-- ---------------------------------------------------------------------
-- rol_revisor: el auxiliar. Lee todo, decide y corrige.
-- ---------------------------------------------------------------------
GRANT SELECT ON egresados.* TO rol_revisor;
GRANT SELECT ON egresados_identidad.* TO rol_revisor;

GRANT INSERT ON egresados.busqueda TO rol_revisor;
GRANT INSERT ON egresados.captura TO rol_revisor;
GRANT INSERT ON egresados.experiencia TO rol_revisor;
GRANT INSERT ON egresados.estudio_declarado TO rol_revisor;
GRANT INSERT ON egresados.incidencia TO rol_revisor;
GRANT INSERT ON egresados.cat_organizacion TO rol_revisor;
GRANT INSERT ON egresados.programa_alias TO rol_revisor;
GRANT INSERT ON egresados.organizacion_alias TO rol_revisor;
GRANT INSERT ON egresados.cargo_alias TO rol_revisor;
GRANT INSERT ON egresados.ubicacion_alias TO rol_revisor;
GRANT INSERT ON egresados.afinidad_programa_ocupacion TO rol_revisor;

-- Para corregir lo que el lector del PDF leyó mal (por ejemplo, una experiencia repetida)
GRANT DELETE ON egresados.experiencia TO rol_revisor;
GRANT DELETE ON egresados.estudio_declarado TO rol_revisor;

GRANT UPDATE (id_perfil, estado) ON egresados.captura TO rol_revisor;
GRANT UPDATE (cargo_original, organizacion_original, ubicacion_original,
              anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
              id_organizacion, codigo_ocupacion, codigo_ubicacion, codigo_area) ON egresados.experiencia TO rol_revisor;
GRANT UPDATE (institucion_original, programa_original, anio_inicio, anio_fin,
              codigo_nivel, id_programa, id_organizacion) ON egresados.estudio_declarado TO rol_revisor;
GRANT UPDATE (estado, id_responsable_asignado, fecha_hora_cierre, solucion) ON egresados.incidencia TO rol_revisor;
GRANT UPDATE (nombre, codigo_pais, nit, codigo_actividad) ON egresados.cat_organizacion TO rol_revisor;
GRANT EXECUTE ON PROCEDURE egresados.sp_fusionar_organizaciones TO rol_revisor;

GRANT INSERT ON egresados_identidad.decision_coincidencia TO rol_revisor;
-- Si el egresado cambió su URL personalizada, el revisor actualiza el perfil
GRANT UPDATE (url, huella_url) ON egresados_identidad.perfil TO rol_revisor;

-- ---------------------------------------------------------------------
-- rol_titulares: atiende las solicitudes de los titulares
-- ---------------------------------------------------------------------
GRANT SELECT ON egresados_identidad.identidad TO rol_titulares;
GRANT SELECT ON egresados_identidad.documento_identidad TO rol_titulares;
GRANT SELECT ON egresados_identidad.perfil TO rol_titulares;
GRANT SELECT ON egresados_identidad.coincidencia TO rol_titulares;
GRANT SELECT ON egresados_identidad.solicitud_supresion TO rol_titulares;
GRANT SELECT ON egresados_identidad.huella_no_contactar TO rol_titulares;
GRANT INSERT ON egresados_identidad.solicitud_supresion TO rol_titulares;
GRANT UPDATE (observacion) ON egresados_identidad.solicitud_supresion TO rol_titulares;
GRANT EXECUTE ON PROCEDURE egresados_identidad.sp_suprimir_egresado TO rol_titulares;
-- Para indicar quién atiende la solicitud
GRANT SELECT ON egresados.responsable TO rol_titulares;

-- ---------------------------------------------------------------------
-- Cómo se crea un usuario para una persona o un bot (ejemplo; la
-- contraseña la define quien administra la base, no va en este archivo):
--
--   CREATE USER 'aux_revisor'@'localhost' IDENTIFIED BY '<contraseña>';
--   GRANT rol_revisor TO 'aux_revisor'@'localhost';
--   SET DEFAULT ROLE rol_revisor FOR 'aux_revisor'@'localhost';
--
-- Y se registra como responsable, porque la bitácora exige que todo
-- usuario que escribe exista en egresados.responsable:
--
--   INSERT INTO egresados.responsable (usuario_bd, nombre, tipo, fecha_alta)
--   VALUES ('aux_revisor', 'Nombre de la persona', 'PERSONA', CURDATE());
-- ---------------------------------------------------------------------
