-- =====================================================================
-- 10_datos_prueba.sql
-- Datos de prueba: 10 egresados FICTICIOS (enunciado, punto 3.2.6).
-- =====================================================================
--
-- Todas las personas, documentos, correos, URL y empresas son ficticios.
-- Los correos usan el dominio reservado example.com y las URL dicen
-- "prueba-uapa". Las huellas son reales: HMAC-SHA256 calculado con una
-- CLAVE DE PRUEBA ('clave-de-prueba-solo-para-datos-ficticios') y
-- SHA-256 de contenidos ficticios. En operación, la clave real vive
-- fuera de la base.
--
-- Cada caso muestra una parte del diseño:
--   1. Laura      Canal A y dos actualizaciones (B): historial de
--                 capturas, práctica antes del grado, ascenso a directiva
--                 y auditoría de una aceptación automática.
--   2. Andrés     Canal A con una experiencia repetida (incidencia
--                 DUPLICADA resuelta); "sigo igual" en M1; M3 sin respuesta.
--   3. Valentina  La URL del PDF no coincide: queda en revisión.
--   4. Carlos     Canal C, en muestra: puntaje medio, revisión humana y
--                 un cargo que la IA clasificó con poca confianza.
--   5. Diana      Canal C, en muestra: búsqueda sin resultado.
--   6. Jorge      Canal C, en muestra: dos candidatos, uno descartado.
--   7. Paula      Canal C, fuera de muestra: candidato imposible.
--   8. Sebastián  Doble titulación, tarjeta de identidad y cédula, correo
--                 que rebota.
--   9. Mariana    Sin LinkedIn: formulario directo, buscando empleo.
--  10. Felipe     Lista de espera (grado en trámite); dato faltante.
--  11. Natalia    Revoca su autorización: se ejecuta la supresión y de
--                 ella solo quedan la constancia y las huellas.
--
-- Cada bloque fija @id_ejecucion (proceso automático) o @motivo (cambio
-- manual), porque la bitácora exige uno de los dos.

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- Referencias a responsables, programas, organizaciones y texto
-- ---------------------------------------------------------------------
SET @r_carga         = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'bot_carga');
SET @r_consolidacion = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'bot_consolidacion');
SET @r_verificacion  = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'bot_verificacion');
SET @r_clasificacion = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'bot_clasificacion');
SET @r_envios        = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'bot_envios');
SET @r_muestreo      = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'bot_muestreo');
SET @r_depuracion    = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'bot_depuracion');
SET @r_revisor       = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'aux_revisor');
SET @r_titulares     = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'resp_titulares');

SET @p_agricola    = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Ingeniería Agrícola');
SET @p_civil       = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Ingeniería Civil');
SET @p_sistemas    = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Ingeniería de Sistemas y Computación');
SET @p_electrica   = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Ingeniería Eléctrica');
SET @p_electronica = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Ingeniería Electrónica');
SET @p_industrial  = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Ingeniería Industrial');
SET @p_mecanica    = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Ingeniería Mecánica');
SET @p_mecatronica = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Ingeniería Mecatrónica');
SET @p_quimica     = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Ingeniería Química');
SET @p_m_sistemas  = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Maestría en Ingeniería de Sistemas y Computación');

SET @o_unal    = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Universidad Nacional de Colombia');
SET @o_andes   = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Universidad de los Andes');
SET @o_andina  = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Andina Software S.A.S.');
SET @o_banco   = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Banco Cordillera S.A.');
SET @o_sabana  = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Consultores de Ingeniería Sabana Ltda.');
SET @o_vias    = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Vías del Llano S.A.S.');
SET @o_energia = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Energía Andina E.S.P.');
SET @o_agencia = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Agencia de Infraestructura Digital');

SET @texto = (SELECT id_texto_autorizacion FROM egresados_identidad.texto_autorizacion WHERE version = '1.0.0');

-- Parámetros vigentes de los procesos (quedan guardados en cada ejecución)
SET @param_cruce = '{"pesos": {"nombre": 0.50, "programa": 0.25, "anio": 0.15, "ciudad": 0.10}, "umbral_alto": 0.85, "umbral_medio": 0.60, "tolerancia_anios": 1, "componente_no_observado": 0}';
SET @param_clasificacion = '{"umbral_revision": 0.75, "orden": ["diccionario", "ia"], "clasificaciones": {"ocupacion": "CUOC 2025", "actividad": "CIIU Rev. 4 A.C. 2022", "ubicacion": "DIVIPOLA / ISO 3166-1"}}';
SET @digest_modelo = '3958a306664e8dfbfb51aaa1188f597206c20bce79868988152ad3dc64d32dfc';

-- =====================================================================
-- Carga inicial del registro oficial (1 de febrero de 2021)
-- Egresados de cohortes antiguas e inscritos al grado de 2021-1.
-- Se insertan sin orden alfabético, para que el número no lo conserve.
-- =====================================================================
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2021-02-01 08:00:00', '2021-02-01 08:03:00', 'EXITOSA', 6);
SET @ej_carga_2021 = LAST_INSERT_ID();
SET @id_ejecucion = @ej_carga_2021, @motivo = NULL;

-- Jorge (Mecánica, 2017)
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('M', @ej_carga_2021);
SET @e_jorge = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_jorge, 'Jorge Iván', 'Castillo', 'Mora', 'jorge.castillo.ficticio@example.com');
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_jorge, 'CC', '80000006');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_jorge, @p_mecanica, 2012, 2, '2017-09-22', 'OTORGADO', @ej_carga_2021);

-- Laura (Sistemas): inscrita al grado, todavía en trámite (lista de espera)
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('F', @ej_carga_2021);
SET @e_laura = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_laura, 'Laura Camila', 'Rojas', 'Peña', 'laura.rojas.ficticia@example.com');
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_laura, 'CC', '1000000001');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_laura, @p_sistemas, 2016, 1, NULL, 'EN_TRAMITE', @ej_carga_2021);
SET @g_laura = LAST_INSERT_ID();

-- Diana (Electrónica, 2016)
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('F', @ej_carga_2021);
SET @e_diana = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_diana, 'Diana Marcela', 'Herrera', 'Gil', NULL);
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_diana, 'CC', '52000005');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_diana, @p_electronica, 2011, 1, '2016-03-18', 'OTORGADO', @ej_carga_2021);

-- Sebastián (Eléctrica, 2019): ingresó con tarjeta de identidad y se graduó con cédula
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('M', @ej_carga_2021);
SET @e_sebastian = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_sebastian, 'Sebastián', 'Torres', 'León', 'sebastian.torres.ficticio@example.com');
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES
  (@e_sebastian, 'TI', '99000008'),
  (@e_sebastian, 'CC', '1000000008');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_sebastian, @p_electrica, 2014, 1, '2019-09-27', 'OTORGADO', @ej_carga_2021);

-- Paula (Química, 2018)
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('F', @ej_carga_2021);
SET @e_paula = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_paula, 'Paula Andrea', 'Ramírez', 'Soto', NULL);
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_paula, 'CC', '1000000007');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_paula, @p_quimica, 2013, 1, '2018-03-23', 'OTORGADO', @ej_carga_2021);

-- Carlos (Sistemas, 2015)
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('M', @ej_carga_2021);
SET @e_carlos = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_carlos, 'Carlos Andrés', 'Martínez', 'Díaz', NULL);
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_carlos, 'CC', '79000004');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_carlos, @p_sistemas, 2010, 1, '2015-09-25', 'OTORGADO', @ej_carga_2021);

-- =====================================================================
-- Caso 1. Laura: canal A, dos actualizaciones por el canal B y auditoría
-- =====================================================================

-- Canal A (10 de marzo de 2021): autoriza, deja su URL y sube el PDF
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', @param_cruce, '2021-03-10 10:00:00', '2021-03-10 10:01:00', 'EXITOSA', 1);
SET @ej = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2021-03-10 10:01:00', '2021-03-10 10:02:00', 'EXITOSA', 2);
SET @ej_clas = LAST_INSERT_ID();
SET @id_ejecucion = @ej;

INSERT INTO egresados_identidad.autorizacion (id_egresado, id_texto_autorizacion, codigo_fuente, fecha_hora, evidencia)
VALUES (@e_laura, @texto, 'CANAL_A', '2021-03-10 09:58:00', 'Formulario de inscripción a grado 2021-1, envío 000123');
SET @a_laura = LAST_INSERT_ID();
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/laura-rojas-prueba-uapa-01', 'b3d227e182978b1bfdcc20cd2e41cc1309664980ead88c9ef352cfb8d8d366b5');
SET @pf_laura = LAST_INSERT_ID();
-- En el canal A el puntaje no identifica a la persona (ya se identificó): comprueba coherencia
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_ejecucion, puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel)
VALUES (@e_laura, @pf_laura, @ej, 1.000, 1.000, 1.000, 1.000, 1.000, 'ALTO');
SET @c_laura = LAST_INSERT_ID();
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, fecha_hora)
VALUES (@c_laura, 'AUTOMATICA', 'ACEPTAR', @ej, '2021-03-10 10:00:20');

INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, situacion_declarada, huella_archivo)
VALUES (@e_laura, @pf_laura, 'CANAL_A', @a_laura, @ej, '2021-03-10 10:00:00', 'RECIBIDA', 'ESTUDIANDO',
        'b67e0a38aadb5fc906196ebcce111b35985552184cfda3f428f3a7f001e0fcfe');
SET @cap_laura_1 = LAST_INSERT_ID();
-- Práctica antes del grado: no cuenta como primer empleo
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES (@cap_laura_1, 'Practicante de desarrollo', 'Andina Software S.A.S.', 'Bogotá, Distrito Capital, Colombia', 2020, 7, 2020, 12, 'PRACTICA',
  @o_andina, 'DICCIONARIO', 1.000, @o_andina,
  '2512', 'IA', 0.810, '2512',
  '11001', 'DICCIONARIO', 1.000, '11001',
  'DESARROLLO', 'IA', 0.900, 'DESARROLLO', @ej_clas);
-- El programa se escribe "a su manera": el diccionario lo traduce al oficial
INSERT INTO egresados.estudio_declarado (id_captura, institucion_original, programa_original, anio_inicio, anio_fin, codigo_nivel, id_programa,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion, id_ejecucion_clasificacion)
VALUES (@cap_laura_1, 'Universidad Nacional de Colombia', 'Ingenieria en sistemas y computación', 2016, 2021, 'PREGRADO', @p_sistemas,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas);
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_laura_1;

-- Carga oficial posterior a la ceremonia: el grado pasa de en trámite a otorgado
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2021-04-05 08:00:00', '2021-04-05 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
UPDATE egresados.grado SET estado = 'OTORGADO', fecha_grado = '2021-03-26', id_ejecucion = @id_ejecucion WHERE id_grado = @g_laura;

-- M1 (marzo de 2022): solicitud de actualización. Responde con un PDF nuevo.
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('ENVIO_SOLICITUDES', @r_envios, '1.0.0', '2022-03-28 07:00:00', '2022-03-28 07:05:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
INSERT INTO egresados.solicitud_actualizacion (id_egresado, codigo_momento, id_ejecucion, fecha_hora_envio, estado_envio, huella_token, fecha_vencimiento)
VALUES (@e_laura, 'M1', @id_ejecucion, '2022-03-28 07:01:00', 'ENVIADA', '0d65ce78be729b5aeaa6ca2f721ea4f2cb176d655d1170a9d99db39c552fffa5', '2022-04-27');
SET @s_laura_m1 = LAST_INSERT_ID();

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', @param_cruce, '2022-04-05 19:20:00', '2022-04-05 19:21:00', 'EXITOSA', 1);
SET @ej = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2022-04-05 19:21:00', '2022-04-05 19:22:00', 'EXITOSA', 4);
SET @ej_clas = LAST_INSERT_ID();
SET @id_ejecucion = @ej;
-- Misma persona y mismo perfil: no se repite el cruce, solo se comprueba la URL
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, situacion_declarada, huella_archivo)
VALUES (@e_laura, @pf_laura, 'CANAL_B', @a_laura, @ej, '2022-04-05 19:20:00', 'RECIBIDA', 'EMPLEADO',
        'fc7b88527ce5cb3e6a26e705762cea83e22b7fbabd564c6527beb2c51ba07aef');
SET @cap_laura_2 = LAST_INSERT_ID();
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES
 (@cap_laura_2, 'Practicante de desarrollo', 'Andina Software S.A.S.', 'Bogotá, Distrito Capital, Colombia', 2020, 7, 2020, 12, 'PRACTICA',
  @o_andina, 'DICCIONARIO', 1.000, @o_andina, '2512', 'IA', 0.810, '2512', '11001', 'DICCIONARIO', 1.000, '11001', 'DESARROLLO', 'IA', 0.900, 'DESARROLLO', @ej_clas),
 (@cap_laura_2, 'Desarrolladora de software', 'Andina Software S.A.S.', 'Bogotá, Distrito Capital, Colombia', 2021, 5, NULL, NULL, 'EMPLEO',
  @o_andina, 'DICCIONARIO', 1.000, @o_andina, '2512', 'DICCIONARIO', 1.000, '2512', '11001', 'DICCIONARIO', 1.000, '11001', 'DESARROLLO', 'IA', 0.920, 'DESARROLLO', @ej_clas);
INSERT INTO egresados.estudio_declarado (id_captura, institucion_original, programa_original, anio_inicio, anio_fin, codigo_nivel, id_programa,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion, id_ejecucion_clasificacion)
VALUES
 (@cap_laura_2, 'Universidad Nacional de Colombia', 'Ingenieria en sistemas y computación', 2016, 2021, 'PREGRADO', @p_sistemas,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas),
 -- Maestría en OTRA universidad: aunque el nombre coincide con un programa de la
 -- Facultad, id_programa queda vacío, porque la institución no es la UNAL.
 (@cap_laura_2, 'Universidad de los Andes', 'Maestría en Ingeniería de Sistemas y Computación', 2022, NULL, 'MAESTRIA', NULL,
  @o_andes, 'DICCIONARIO', 1.000, @o_andes, @ej_clas);
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_laura_2;
UPDATE egresados.solicitud_actualizacion
   SET respuesta = 'ACTUALIZO', fecha_hora_respuesta = '2022-04-05 19:20:00', id_captura = @cap_laura_2
 WHERE id_solicitud = @s_laura_m1;

-- M3 (marzo de 2024): actualiza otra vez. Ahora es directora de tecnología.
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('ENVIO_SOLICITUDES', @r_envios, '1.0.0', '2024-03-26 07:00:00', '2024-03-26 07:05:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
INSERT INTO egresados.solicitud_actualizacion (id_egresado, codigo_momento, id_ejecucion, fecha_hora_envio, estado_envio, huella_token, fecha_vencimiento)
VALUES (@e_laura, 'M3', @id_ejecucion, '2024-03-26 07:01:00', 'ENVIADA', 'da6467cb632752ab485caaa49acd7f61ffae6b676f4853b25da42d398bdc3580', '2024-04-25');
SET @s_laura_m3 = LAST_INSERT_ID();

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', @param_cruce, '2024-04-02 20:10:00', '2024-04-02 20:11:00', 'EXITOSA', 1);
SET @ej = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2024-04-02 20:11:00', '2024-04-02 20:12:00', 'EXITOSA', 5);
SET @ej_clas = LAST_INSERT_ID();
SET @id_ejecucion = @ej;
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, situacion_declarada, huella_archivo)
VALUES (@e_laura, @pf_laura, 'CANAL_B', @a_laura, @ej, '2024-04-02 20:10:00', 'RECIBIDA', 'EMPLEADO',
        '747801b79ef27955f7f5b7bf3e6a40320fb9c90b9e89f1ad447c79cf20f743ef');
SET @cap_laura_3 = LAST_INSERT_ID();
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES
 (@cap_laura_3, 'Practicante de desarrollo', 'Andina Software S.A.S.', 'Bogotá, Distrito Capital, Colombia', 2020, 7, 2020, 12, 'PRACTICA',
  @o_andina, 'DICCIONARIO', 1.000, @o_andina, '2512', 'IA', 0.810, '2512', '11001', 'DICCIONARIO', 1.000, '11001', 'DESARROLLO', 'IA', 0.900, 'DESARROLLO', @ej_clas),
 (@cap_laura_3, 'Desarrolladora de software', 'Andina Software S.A.S.', 'Bogotá, Distrito Capital, Colombia', 2021, 5, 2023, 12, 'EMPLEO',
  @o_andina, 'DICCIONARIO', 1.000, @o_andina, '2512', 'DICCIONARIO', 1.000, '2512', '11001', 'DICCIONARIO', 1.000, '11001', 'DESARROLLO', 'IA', 0.920, 'DESARROLLO', @ej_clas),
 (@cap_laura_3, 'Directora de tecnología', 'Banco Cordillera S.A.', 'Bogotá, Distrito Capital, Colombia', 2024, 1, NULL, NULL, 'EMPLEO',
  @o_banco, 'DICCIONARIO', 1.000, @o_banco, '1330', 'DICCIONARIO', 1.000, '1330', '11001', 'DICCIONARIO', 1.000, '11001', 'GESTION', 'IA', 0.950, 'GESTION', @ej_clas);
INSERT INTO egresados.estudio_declarado (id_captura, institucion_original, programa_original, anio_inicio, anio_fin, codigo_nivel, id_programa,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion, id_ejecucion_clasificacion)
VALUES
 (@cap_laura_3, 'Universidad Nacional de Colombia', 'Ingenieria en sistemas y computación', 2016, 2021, 'PREGRADO', @p_sistemas,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas),
 (@cap_laura_3, 'Universidad de los Andes', 'Maestría en Ingeniería de Sistemas y Computación', 2022, 2024, 'MAESTRIA', NULL,
  @o_andes, 'DICCIONARIO', 1.000, @o_andes, @ej_clas);
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_laura_3;
UPDATE egresados.solicitud_actualizacion
   SET respuesta = 'ACTUALIZO', fecha_hora_respuesta = '2024-04-02 20:10:00', id_captura = @cap_laura_3
 WHERE id_solicitud = @s_laura_m3;

-- Auditoría por muestreo de una aceptación automática de nivel alto
SET @id_ejecucion = NULL, @motivo = 'Auditoría por muestreo de aceptaciones automáticas';
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_responsable, fecha_hora)
VALUES (@c_laura, 'AUDITORIA', 'ACEPTAR', @r_revisor, '2024-05-10 15:00:00');

-- =====================================================================
-- Caso 2. Andrés: canal A con una experiencia repetida; "sigo igual" en M1
-- =====================================================================
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2023-08-01 08:00:00', '2023-08-01 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID(), @motivo = NULL;
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('M', @id_ejecucion);
SET @e_andres = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_andres, 'Andrés Felipe', 'Gómez', 'Ruiz', 'andres.gomez.ficticio@example.com');
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_andres, 'CC', '1000000002');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_andres, @p_civil, 2017, 2, NULL, 'EN_TRAMITE', @id_ejecucion);
SET @g_andres = LAST_INSERT_ID();

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', @param_cruce, '2023-09-15 11:30:00', '2023-09-15 11:31:00', 'CON_ERRORES', 1);
SET @ej = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2023-09-15 11:31:00', '2023-09-15 11:32:00', 'EXITOSA', 3);
SET @ej_clas = LAST_INSERT_ID();
SET @id_ejecucion = @ej;
INSERT INTO egresados_identidad.autorizacion (id_egresado, id_texto_autorizacion, codigo_fuente, fecha_hora, evidencia)
VALUES (@e_andres, @texto, 'CANAL_A', '2023-09-15 11:28:00', 'Formulario de inscripción a grado 2023-2, envío 000871');
SET @a_andres = LAST_INSERT_ID();
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/andres-gomez-prueba-uapa-02', 'efd1ef5f29617f6efa55e2f18b08787c6a906f5b614373fb6f045f4a4d8f7369');
SET @pf_andres = LAST_INSERT_ID();
-- En LinkedIn usa un solo apellido: el nombre no coincide del todo
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_ejecucion, puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel)
VALUES (@e_andres, @pf_andres, @ej, 0.950, 1.000, 1.000, 1.000, 0.975, 'ALTO');
SET @c_andres = LAST_INSERT_ID();
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, fecha_hora)
VALUES (@c_andres, 'AUTOMATICA', 'ACEPTAR', @ej, '2023-09-15 11:30:20');
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, situacion_declarada, huella_archivo)
VALUES (@e_andres, @pf_andres, 'CANAL_A', @a_andres, @ej, '2023-09-15 11:30:00', 'RECIBIDA', 'EMPLEADO',
        'fb44915ea215b54801e9bc5432475cf6f0948f6ff1cc1a109adf75f145f62e4c');
SET @cap_andres = LAST_INSERT_ID();
-- El PDF trae la misma experiencia dos veces
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES
 (@cap_andres, 'Ingeniero civil residente', 'Vías del Llano S.A.S.', 'Bogotá D.C., Colombia', 2023, 2, NULL, NULL, 'EMPLEO',
  @o_vias, 'DICCIONARIO', 1.000, @o_vias, '2142', 'IA', 0.900, '2142', '11001', 'DICCIONARIO', 1.000, '11001', 'DESARROLLO', 'IA', 0.850, 'DESARROLLO', @ej_clas);
SET @x_andres_bien = LAST_INSERT_ID();
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES
 (@cap_andres, 'Ingeniero civil residente', 'Vías del Llano S.A.S.', 'Bogotá D.C., Colombia', 2023, 2, NULL, NULL, 'EMPLEO',
  @o_vias, 'DICCIONARIO', 1.000, @o_vias, '2142', 'IA', 0.900, '2142', '11001', 'DICCIONARIO', 1.000, '11001', 'DESARROLLO', 'IA', 0.850, 'DESARROLLO', @ej_clas);
SET @x_andres_repetida = LAST_INSERT_ID();
INSERT INTO egresados.estudio_declarado (id_captura, institucion_original, programa_original, anio_inicio, anio_fin, codigo_nivel, id_programa,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion, id_ejecucion_clasificacion)
VALUES (@cap_andres, 'Universidad Nacional', 'Ingeniería Civil', 2017, 2023, 'PREGRADO', @p_civil,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas);
-- El bot detecta la repetición y abre una incidencia (sin datos de identidad)
INSERT INTO egresados.incidencia (codigo_tipo_incidencia, id_egresado, id_captura, campo_afectado, descripcion, estado, id_ejecucion, id_responsable_asignado, fecha_hora_apertura)
VALUES ('DUPLICADA', @e_andres, @cap_andres, 'experiencia', 'La captura tiene dos experiencias con la misma organización, cargo y fecha de inicio.', 'ABIERTA', @ej, @r_revisor, '2023-09-15 11:31:00');
SET @i_andres = LAST_INSERT_ID();

-- El revisor quita la repetida y cierra la incidencia; después la captura se verifica
SET @id_ejecucion = NULL, @motivo = 'Corrección de una experiencia repetida en el PDF (incidencia DUPLICADA)';
DELETE FROM egresados.experiencia WHERE id_experiencia = @x_andres_repetida;
UPDATE egresados.incidencia
   SET estado = 'RESUELTA', fecha_hora_cierre = '2023-09-18 09:00:00', solucion = 'Se eliminó la experiencia repetida; la otra se conserva.'
 WHERE id_incidencia = @i_andres;
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_andres;

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2023-10-02 08:00:00', '2023-10-02 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID(), @motivo = NULL;
UPDATE egresados.grado SET estado = 'OTORGADO', fecha_grado = '2023-09-29', id_ejecucion = @id_ejecucion WHERE id_grado = @g_andres;

-- M1 (septiembre de 2024): un clic, "sigo igual". No se crea captura nueva.
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('ENVIO_SOLICITUDES', @r_envios, '1.0.0', '2024-09-30 07:00:00', '2024-09-30 07:05:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
INSERT INTO egresados.solicitud_actualizacion (id_egresado, codigo_momento, id_ejecucion, fecha_hora_envio, estado_envio, huella_token, fecha_vencimiento)
VALUES (@e_andres, 'M1', @id_ejecucion, '2024-09-30 07:01:00', 'ENVIADA', '277268e2b8818f97cc3662483ef9647d0cda8275806a5d006040bc205fb134ee', '2024-10-30');
SET @s_andres_m1 = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', '2024-10-03 21:40:00', '2024-10-03 21:40:05', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
UPDATE egresados.solicitud_actualizacion
   SET respuesta = 'CONFIRMO_SIN_CAMBIOS', fecha_hora_respuesta = '2024-10-03 21:40:00', id_captura = @cap_andres
 WHERE id_solicitud = @s_andres_m1;

-- M3 (octubre de 2026): enviada, todavía sin respuesta
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('ENVIO_SOLICITUDES', @r_envios, '1.0.0', '2026-10-01 07:00:00', '2026-10-01 07:05:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
INSERT INTO egresados.solicitud_actualizacion (id_egresado, codigo_momento, id_ejecucion, fecha_hora_envio, estado_envio, huella_token, fecha_vencimiento)
VALUES (@e_andres, 'M3', @id_ejecucion, '2026-10-01 07:01:00', 'ENVIADA', '967fdde00a07062ea76bbfe31eb218325cd8e1afa27bef9b3dbe67567d55cfb1', '2026-11-30');

-- =====================================================================
-- Caso 3. Valentina: la URL del PDF no coincide con la del formulario
-- =====================================================================
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2024-02-01 08:00:00', '2024-02-01 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID(), @motivo = NULL;
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('F', @id_ejecucion);
SET @e_valentina = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_valentina, 'Valentina', 'Peña', 'Ortiz', 'valentina.pena.ficticia@example.com');
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_valentina, 'CC', '1000000003');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_valentina, @p_industrial, 2018, 1, NULL, 'EN_TRAMITE', @id_ejecucion);
SET @g_valentina = LAST_INSERT_ID();

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', @param_cruce, '2024-03-05 16:45:00', '2024-03-05 16:46:00', 'CON_ERRORES', 1);
SET @ej = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2024-03-05 16:46:00', '2024-03-05 16:47:00', 'EXITOSA', 2);
SET @ej_clas = LAST_INSERT_ID();
SET @id_ejecucion = @ej;
INSERT INTO egresados_identidad.autorizacion (id_egresado, id_texto_autorizacion, codigo_fuente, fecha_hora, evidencia)
VALUES (@e_valentina, @texto, 'CANAL_A', '2024-03-05 16:43:00', 'Formulario de inscripción a grado 2024-1, envío 001204');
SET @a_valentina = LAST_INSERT_ID();
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/valentina-pena-prueba-uapa-03', '2f6f299a54e1a6e1d19ad907c09da8754dd34132b40e50d9f83b5b00860282df');
SET @pf_valentina = LAST_INSERT_ID();
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_ejecucion, puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel)
VALUES (@e_valentina, @pf_valentina, @ej, 1.000, 1.000, 1.000, 1.000, 1.000, 'ALTO');
SET @c_valentina = LAST_INSERT_ID();
-- Aunque el puntaje es alto, la URL del PDF no es la del formulario: va a revisión
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, motivo, fecha_hora)
VALUES (@c_valentina, 'AUTOMATICA', 'ENVIAR_A_REVISION', @ej,
        'La URL impresa en el PDF no coincide con la URL registrada en el formulario.', '2024-03-05 16:45:20');
-- La captura entra sin perfil: no puede apuntar a una coincidencia que no está aceptada
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, situacion_declarada, huella_archivo)
VALUES (@e_valentina, NULL, 'CANAL_A', @a_valentina, @ej, '2024-03-05 16:45:00', 'EN_REVISION', 'EMPLEADO',
        '697c7cbab4d0a098c615a1c4d65c5ac2560a2967554cd432f20dae7ac6605e6b');
SET @cap_valentina = LAST_INSERT_ID();
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES (@cap_valentina, 'Analista de procesos', 'Consultores de Ingeniería Sabana Ltda.', 'Bogotá, Distrito Capital, Colombia', 2023, 8, NULL, NULL, 'EMPLEO',
  @o_sabana, 'DICCIONARIO', 1.000, @o_sabana, '2421', 'DICCIONARIO', 1.000, '2421', '11001', 'DICCIONARIO', 1.000, '11001', 'CONSULTORIA', 'IA', 0.880, 'CONSULTORIA', @ej_clas);
INSERT INTO egresados.incidencia (codigo_tipo_incidencia, id_egresado, id_captura, campo_afectado, descripcion, estado, id_ejecucion, id_responsable_asignado, fecha_hora_apertura)
VALUES ('URL_DISTINTA', @e_valentina, @cap_valentina, 'captura.id_perfil',
        'La URL del PDF no coincide con la registrada en el formulario. Se confirma con la egresada antes de asociar el perfil.',
        'ABIERTA', @ej, @r_revisor, '2024-03-05 16:46:00');

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2024-04-01 08:00:00', '2024-04-01 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
UPDATE egresados.grado SET estado = 'OTORGADO', fecha_grado = '2024-03-22', id_ejecucion = @id_ejecucion WHERE id_grado = @g_valentina;

-- =====================================================================
-- Muestra del canal C (marzo de 2026): cohortes antiguas sin autorización
-- =====================================================================
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('MUESTREO', @r_muestreo, '1.0.0', '{"estratos": "programa x rango de cohortes", "formula": "n0 = z^2 p (1 - p) / e^2 con correccion por poblacion finita"}',
        '2026-03-02 09:00:00', '2026-03-02 09:01:00', 'EXITOSA', 3);
SET @id_ejecucion = LAST_INSERT_ID(), @motivo = NULL;
INSERT INTO egresados.muestra (poblacion, margen_error, nivel_confianza, proporcion_supuesta, semilla, id_ejecucion)
VALUES ('Pregrado, cohortes de grado 2015 a 2018, sin autorización registrada', 0.100, 0.950, 0.500, 20260302, @id_ejecucion);
SET @m_2026 = LAST_INSERT_ID();
-- Peso = egresados del estrato / seleccionados en él (valores de ejemplo)
INSERT INTO egresados.muestra_egresado (id_muestra, id_egresado, estrato, peso) VALUES
  (@m_2026, @e_carlos, 'Ingeniería de Sistemas y Computación, 2015-2018', 42.0000),
  (@m_2026, @e_diana,  'Ingeniería Electrónica, 2015-2018',               38.5000),
  (@m_2026, @e_jorge,  'Ingeniería Mecánica, 2015-2018',                  35.0000);

-- =====================================================================
-- Caso 4. Carlos: puntaje medio, revisión humana y un cargo nuevo para la IA
-- =====================================================================
SET @id_ejecucion = NULL, @motivo = 'Búsqueda manual del canal C según el protocolo 1.0.0';
INSERT INTO egresados.busqueda (id_egresado, id_muestra, id_responsable, fecha_hora, version_protocolo, resultado)
VALUES (@e_carlos, @m_2026, @r_revisor, '2026-03-10 09:00:00', '1.0.0', 'ENCONTRADO');
SET @b_carlos = LAST_INSERT_ID();

-- El bot 2 puntúa el candidato que registró el auxiliar. La ciudad no se observó.
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_VERIFICACION', @r_verificacion, '1.0.0', @param_cruce, '2026-03-10 09:05:00', '2026-03-10 09:05:10', 'EXITOSA', 1);
SET @ej = LAST_INSERT_ID();
SET @id_ejecucion = @ej, @motivo = NULL;
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/carlos-martinez-prueba-uapa-04', '3f121d077a76ecbcfca26de0b8a3482695d6a069058cddc72125522abe851ba2');
SET @pf_carlos = LAST_INSERT_ID();
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_busqueda, id_ejecucion,
  nombre_observado, programa_observado, anio_inicio_observado, anio_fin_observado, ciudad_observada,
  puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel)
VALUES (@e_carlos, @pf_carlos, @b_carlos, @ej,
  'Carlos Martínez', 'Ingeniería de Sistemas', 2010, 2014, NULL,
  0.900, 1.000, 0.500, NULL, 0.775, 'MEDIO');
SET @c_carlos = LAST_INSERT_ID();
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, fecha_hora)
VALUES (@c_carlos, 'AUTOMATICA', 'ENVIAR_A_REVISION', @ej, '2026-03-10 09:05:05');

-- Revisión humana: acepta
SET @id_ejecucion = NULL, @motivo = 'Revisión de coincidencia de nivel medio';
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_responsable, motivo, fecha_hora)
VALUES (@c_carlos, 'REVISION', 'ACEPTAR', @r_revisor,
        'El año de fin en el perfil (2014) es el de terminación de materias; el grado oficial es de 2015.', '2026-03-11 10:00:00');

-- Captura manual del canal C (base legal: dato público; no requiere autorización)
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2026-03-11 10:20:00', '2026-03-11 10:21:00', 'EXITOSA', 3);
SET @ej_clas = LAST_INSERT_ID();
SET @motivo = 'Registro de captura manual del canal C';
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_responsable, fecha_hora_captura, estado)
VALUES (@e_carlos, @pf_carlos, 'CANAL_C', NULL, @r_revisor, '2026-03-11 10:15:00', 'RECIBIDA');
SET @cap_carlos = LAST_INSERT_ID();
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES
 (@cap_carlos, 'Desarrollador de software', 'Andina Software', 'Bogotá', 2015, 11, 2019, 1, 'EMPLEO',
  @o_andina, 'DICCIONARIO', 1.000, @o_andina, '2512', 'DICCIONARIO', 1.000, '2512', '11001', 'DICCIONARIO', 1.000, '11001', 'DESARROLLO', 'IA', 0.900, 'DESARROLLO', @ej_clas);
-- "Arquitecto de software" no está en el diccionario: la IA propone con poca
-- confianza y queda pendiente (valor final vacío) hasta que una persona decida
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES
 (@cap_carlos, 'Arquitecto de software', 'Banco Cordillera', 'Bogotá', 2019, 2, NULL, NULL, 'EMPLEO',
  @o_banco, 'DICCIONARIO', 1.000, @o_banco, '2512', 'IA', 0.720, NULL, '11001', 'DICCIONARIO', 1.000, '11001', 'DESARROLLO', 'IA', 0.850, 'DESARROLLO', @ej_clas);
SET @x_carlos_arquitecto = LAST_INSERT_ID();
INSERT INTO egresados.estudio_declarado (id_captura, institucion_original, programa_original, anio_inicio, anio_fin, codigo_nivel, id_programa,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion, id_ejecucion_clasificacion)
VALUES (@cap_carlos, 'UNAL', 'Ingeniería de Sistemas', 2010, 2014, 'PREGRADO', @p_sistemas,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas);
-- La incidencia la abre el proceso de clasificación
SET @id_ejecucion = @ej_clas, @motivo = NULL;
INSERT INTO egresados.incidencia (codigo_tipo_incidencia, id_egresado, id_captura, campo_afectado, descripcion, estado, id_ejecucion, id_responsable_asignado, fecha_hora_apertura)
VALUES ('AMBIGUA', @e_carlos, @cap_carlos, 'experiencia.codigo_ocupacion',
        'La IA propuso la ocupación con confianza 0,72, por debajo del umbral de revisión (0,75).', 'ABIERTA', @ej_clas, @r_revisor, '2026-03-11 10:21:00');
SET @i_carlos = LAST_INSERT_ID();

-- Antes de resolver la incidencia, la verificación se rechaza: hay una
-- clasificación pendiente y una incidencia bloqueante abierta.
-- (Probarlo: UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_carlos;)

-- El revisor confirma la ocupación, agrega el cargo al diccionario y cierra la incidencia
SET @id_ejecucion = NULL, @motivo = 'Revisión de una clasificación de la IA con poca confianza';
UPDATE egresados.experiencia SET codigo_ocupacion = '2512' WHERE id_experiencia = @x_carlos_arquitecto;
INSERT INTO egresados.cargo_alias (texto_normalizado, codigo_ocupacion, origen, id_responsable, fecha_hora_validacion)
VALUES ('arquitecto de software', '2512', 'VALIDADO', @r_revisor, '2026-03-11 11:00:00');
UPDATE egresados.incidencia
   SET estado = 'RESUELTA', fecha_hora_cierre = '2026-03-11 11:00:00',
       solucion = 'Se confirmó la ocupación propuesta y el cargo se agregó al diccionario.'
 WHERE id_incidencia = @i_carlos;
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_carlos;

-- =====================================================================
-- Caso 5. Diana: se buscó y no se encontró
-- =====================================================================
SET @id_ejecucion = NULL, @motivo = 'Búsqueda manual del canal C según el protocolo 1.0.0';
INSERT INTO egresados.busqueda (id_egresado, id_muestra, id_responsable, fecha_hora, version_protocolo, resultado)
VALUES (@e_diana, @m_2026, @r_revisor, '2026-03-10 09:30:00', '1.0.0', 'NO_ENCONTRADO');

-- =====================================================================
-- Caso 6. Jorge: dos candidatos; uno se descarta y otro se acepta
-- =====================================================================
INSERT INTO egresados.busqueda (id_egresado, id_muestra, id_responsable, fecha_hora, version_protocolo, resultado)
VALUES (@e_jorge, @m_2026, @r_revisor, '2026-03-12 09:00:00', '1.0.0', 'VARIOS_CANDIDATOS');
SET @b_jorge = LAST_INSERT_ID();

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_VERIFICACION', @r_verificacion, '1.0.0', @param_cruce, '2026-03-12 09:10:00', '2026-03-12 09:10:20', 'EXITOSA', 2);
SET @ej = LAST_INSERT_ID();
SET @id_ejecucion = @ej, @motivo = NULL;
-- Candidato A: otra persona (estudió otro programa) -> bajo, se descarta
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/jorge-castillo-prueba-uapa-06a', '5635a44c7122fc022b6ef24176688433a9a34c1a663a55daa010b8cdd31bd22a');
SET @pf_jorge_a = LAST_INSERT_ID();
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_busqueda, id_ejecucion,
  nombre_observado, programa_observado, anio_inicio_observado, anio_fin_observado, ciudad_observada,
  puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel)
VALUES (@e_jorge, @pf_jorge_a, @b_jorge, @ej,
  'Jorge Castillo', 'Ingeniería de Sistemas', NULL, NULL, 'Medellín',
  0.700, 0.000, NULL, 1.000, 0.450, 'BAJO');
SET @c_jorge_a = LAST_INSERT_ID();
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, motivo, fecha_hora)
VALUES (@c_jorge_a, 'AUTOMATICA', 'RECHAZAR', @ej, 'Puntaje bajo: el programa declarado no corresponde al del registro oficial.', '2026-03-12 09:10:05');
-- Candidato B: alto, se acepta
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/jorge-castillo-prueba-uapa-06b', '7e5d462aef06d9854fe156a4ab27b4bbac551593c6d99a60e1d089c9ac8c0c3a');
SET @pf_jorge_b = LAST_INSERT_ID();
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_busqueda, id_ejecucion,
  nombre_observado, programa_observado, anio_inicio_observado, anio_fin_observado, ciudad_observada,
  puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel)
VALUES (@e_jorge, @pf_jorge_b, @b_jorge, @ej,
  'Jorge Iván Castillo Mora', 'Ingeniería Mecánica', 2012, 2017, NULL,
  1.000, 1.000, 1.000, NULL, 0.900, 'ALTO');
SET @c_jorge_b = LAST_INSERT_ID();
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, fecha_hora)
VALUES (@c_jorge_b, 'AUTOMATICA', 'ACEPTAR', @ej, '2026-03-12 09:10:10');

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2026-03-12 09:40:00', '2026-03-12 09:41:00', 'EXITOSA', 2);
SET @ej_clas = LAST_INSERT_ID();
SET @id_ejecucion = NULL, @motivo = 'Registro de captura manual del canal C';
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_responsable, fecha_hora_captura, estado)
VALUES (@e_jorge, @pf_jorge_b, 'CANAL_C', NULL, @r_revisor, '2026-03-12 09:30:00', 'RECIBIDA');
SET @cap_jorge = LAST_INSERT_ID();
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES (@cap_jorge, 'Ingeniero mecánico', 'Energía Andina E.S.P.', 'Medellín, Antioquia, Colombia', 2018, 3, NULL, NULL, 'EMPLEO',
  @o_energia, 'DICCIONARIO', 1.000, @o_energia, '2144', 'DICCIONARIO', 1.000, '2144', '05001', 'DICCIONARIO', 1.000, '05001', 'OPERACION', 'IA', 0.800, 'OPERACION', @ej_clas);
INSERT INTO egresados.estudio_declarado (id_captura, institucion_original, programa_original, anio_inicio, anio_fin, codigo_nivel, id_programa,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion, id_ejecucion_clasificacion)
VALUES (@cap_jorge, 'Universidad Nacional de Colombia', 'Ingeniería Mecánica', 2012, 2017, 'PREGRADO', @p_mecanica,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas);
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_jorge;

-- =====================================================================
-- Caso 7. Paula: búsqueda fuera de muestra y un candidato imposible
-- =====================================================================
SET @id_ejecucion = NULL, @motivo = 'Búsqueda manual del canal C según el protocolo 1.0.0';
INSERT INTO egresados.busqueda (id_egresado, id_muestra, id_responsable, fecha_hora, version_protocolo, resultado)
VALUES (@e_paula, NULL, @r_revisor, '2026-04-02 14:00:00', '1.0.0', 'ENCONTRADO');
SET @b_paula = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_VERIFICACION', @r_verificacion, '1.0.0', @param_cruce, '2026-04-02 14:05:00', '2026-04-02 14:05:05', 'EXITOSA', 1);
SET @ej = LAST_INSERT_ID();
SET @id_ejecucion = @ej, @motivo = NULL;
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/paula-ramirez-prueba-uapa-07', '0449ad54745b2e9705b7df1eea280e20a4e2e0a3821510e9a55572dbdff29589');
SET @pf_paula = LAST_INSERT_ID();
-- El puntaje es alto, pero dos años de carrera es menos que la duración mínima
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_busqueda, id_ejecucion,
  nombre_observado, programa_observado, anio_inicio_observado, anio_fin_observado, ciudad_observada,
  puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel, motivo_nivel)
VALUES (@e_paula, @pf_paula, @b_paula, @ej,
  'Paula Ramírez', 'Ingeniería Química', 2016, 2018, 'Bogotá',
  0.950, 1.000, 1.000, 1.000, 0.975, 'IMPOSIBLE',
  'La carrera declarada dura 2 años; la duración mínima del programa es de 8 semestres.');
SET @c_paula = LAST_INSERT_ID();
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, motivo, fecha_hora)
VALUES (@c_paula, 'AUTOMATICA', 'RECHAZAR', @ej, 'Caso imposible: duración menor que la mínima del programa.', '2026-04-02 14:05:02');

-- =====================================================================
-- Caso 8. Sebastián: maestría por el canal A; correo que rebota en M1
-- =====================================================================
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2023-02-01 08:00:00', '2023-02-01 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID(), @motivo = NULL;
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_sebastian, @p_m_sistemas, 2021, 1, NULL, 'EN_TRAMITE', @id_ejecucion);
SET @g_sebastian_m = LAST_INSERT_ID();

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', @param_cruce, '2023-03-10 08:15:00', '2023-03-10 08:16:00', 'EXITOSA', 1);
SET @ej = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2023-03-10 08:16:00', '2023-03-10 08:17:00', 'EXITOSA', 4);
SET @ej_clas = LAST_INSERT_ID();
SET @id_ejecucion = @ej;
INSERT INTO egresados_identidad.autorizacion (id_egresado, id_texto_autorizacion, codigo_fuente, fecha_hora, evidencia)
VALUES (@e_sebastian, @texto, 'CANAL_A', '2023-03-10 08:12:00', 'Formulario de inscripción a grado 2023-1, envío 000415');
SET @a_sebastian = LAST_INSERT_ID();
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/sebastian-torres-prueba-uapa-08', '8e64e958021eb8a8d69135d3c378b785766105714a1b56d9f36e7b946a1c4759');
SET @pf_sebastian = LAST_INSERT_ID();
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_ejecucion, puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel)
VALUES (@e_sebastian, @pf_sebastian, @ej, 1.000, 1.000, 1.000, 1.000, 1.000, 'ALTO');
SET @c_sebastian = LAST_INSERT_ID();
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, fecha_hora)
VALUES (@c_sebastian, 'AUTOMATICA', 'ACEPTAR', @ej, '2023-03-10 08:15:20');
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, situacion_declarada, huella_archivo)
VALUES (@e_sebastian, @pf_sebastian, 'CANAL_A', @a_sebastian, @ej, '2023-03-10 08:15:00', 'RECIBIDA', 'EMPLEADO',
        'a97efc512a6eb341a430a704b3cac7d7ed4008c4a3d5b562e403436fddbf4172');
SET @cap_sebastian = LAST_INSERT_ID();
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES
 (@cap_sebastian, 'Ingeniero electricista', 'Energía Andina E.S.P.', 'Bogotá, Distrito Capital, Colombia', 2019, 11, 2022, 12, 'EMPLEO',
  @o_energia, 'DICCIONARIO', 1.000, @o_energia, '2151', 'DICCIONARIO', 1.000, '2151', '11001', 'DICCIONARIO', 1.000, '11001', 'OPERACION', 'IA', 0.820, 'OPERACION', @ej_clas),
 (@cap_sebastian, 'Docente universitario', 'Universidad Nacional de Colombia', 'Bogotá, Distrito Capital, Colombia', 2023, 1, NULL, NULL, 'EMPLEO',
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, '2310', 'DICCIONARIO', 1.000, '2310', '11001', 'DICCIONARIO', 1.000, '11001', 'DOCENCIA', 'IA', 0.970, 'DOCENCIA', @ej_clas);
INSERT INTO egresados.estudio_declarado (id_captura, institucion_original, programa_original, anio_inicio, anio_fin, codigo_nivel, id_programa,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion, id_ejecucion_clasificacion)
VALUES
 (@cap_sebastian, 'Universidad Nacional de Colombia', 'Ingeniería Eléctrica', 2014, 2019, 'PREGRADO', @p_electrica,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas),
 (@cap_sebastian, 'Universidad Nacional de Colombia', 'Maestría en Ingeniería de Sistemas y Computación', 2021, 2023, 'MAESTRIA', @p_m_sistemas,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas);
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_sebastian;

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2023-04-03 08:00:00', '2023-04-03 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
UPDATE egresados.grado SET estado = 'OTORGADO', fecha_grado = '2023-03-24', id_ejecucion = @id_ejecucion WHERE id_grado = @g_sebastian_m;

-- M1 (marzo de 2024): el correo rebota; sin respuesta queda desactualizado
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('ENVIO_SOLICITUDES', @r_envios, '1.0.0', '2024-03-25 07:00:00', '2024-03-25 07:05:00', 'CON_ERRORES', 1);
SET @id_ejecucion = LAST_INSERT_ID();
INSERT INTO egresados.solicitud_actualizacion (id_egresado, codigo_momento, id_ejecucion, fecha_hora_envio, estado_envio, huella_token, fecha_vencimiento)
VALUES (@e_sebastian, 'M1', @id_ejecucion, '2024-03-25 07:01:00', 'REBOTADA', '3ebac313715ddb8f9c0371ef416f39ea0fdd40d47135f4406b3684b4fbbbac9a', '2024-04-24');
INSERT INTO egresados.incidencia (codigo_tipo_incidencia, id_egresado, id_captura, campo_afectado, descripcion, estado, id_ejecucion, id_responsable_asignado, fecha_hora_apertura)
VALUES ('DESACTUALIZADA', @e_sebastian, NULL, 'identidad.correo_personal',
        'El correo de contacto rebotó en la solicitud M1. Se debe actualizar desde el registro académico.', 'ABIERTA', @id_ejecucion, @r_revisor, '2024-03-25 07:05:00');

-- =====================================================================
-- Caso 9. Mariana: no tiene LinkedIn. Formulario directo; buscando empleo.
-- =====================================================================
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2025-08-01 08:00:00', '2025-08-01 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID(), @motivo = NULL;
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('F', @id_ejecucion);
SET @e_mariana = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_mariana, 'Mariana', 'López', 'Castro', 'mariana.lopez.ficticia@example.com');
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_mariana, 'CC', '1000000009');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_mariana, @p_mecatronica, 2020, 1, NULL, 'EN_TRAMITE', @id_ejecucion);
SET @g_mariana = LAST_INSERT_ID();

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', '2025-09-10 15:00:00', '2025-09-10 15:00:10', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
INSERT INTO egresados_identidad.autorizacion (id_egresado, id_texto_autorizacion, codigo_fuente, fecha_hora, evidencia)
VALUES (@e_mariana, @texto, 'CANAL_A', '2025-09-10 14:58:00', 'Formulario de inscripción a grado 2025-2, envío 002017');
SET @a_mariana = LAST_INSERT_ID();
-- "No tengo LinkedIn" es una respuesta válida: captura sin perfil ni PDF
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, situacion_declarada)
VALUES (@e_mariana, NULL, 'FORMULARIO_DIRECTO', @a_mariana, @id_ejecucion, '2025-09-10 15:00:00', 'RECIBIDA', 'BUSCANDO_EMPLEO');
SET @cap_mariana = LAST_INSERT_ID();
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_mariana;

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2025-10-01 08:00:00', '2025-10-01 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
UPDATE egresados.grado SET estado = 'OTORGADO', fecha_grado = '2025-09-26', id_ejecucion = @id_ejecucion WHERE id_grado = @g_mariana;

-- =====================================================================
-- Caso 10. Felipe: grado en trámite y un dato faltante en el PDF
-- =====================================================================
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2026-08-03 08:00:00', '2026-08-03 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID(), @motivo = NULL;
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('M', @id_ejecucion);
SET @e_felipe = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_felipe, 'Felipe', 'Vargas', 'Niño', 'felipe.vargas.ficticio@example.com');
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_felipe, 'CC', '1000000010');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_felipe, @p_agricola, 2021, 2, NULL, 'EN_TRAMITE', @id_ejecucion);

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', @param_cruce, '2026-10-20 18:00:00', '2026-10-20 18:01:00', 'CON_ERRORES', 1);
SET @ej = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2026-10-20 18:01:00', '2026-10-20 18:02:00', 'EXITOSA', 1);
SET @ej_clas = LAST_INSERT_ID();
SET @id_ejecucion = @ej;
INSERT INTO egresados_identidad.autorizacion (id_egresado, id_texto_autorizacion, codigo_fuente, fecha_hora, evidencia)
VALUES (@e_felipe, @texto, 'CANAL_A', '2026-10-20 17:58:00', 'Formulario de inscripción a grado 2026-2, envío 002533');
SET @a_felipe = LAST_INSERT_ID();
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/felipe-vargas-prueba-uapa-10', '0d51029600dff3507635bd7f5d05d514de15e245b3892c9087af390b6afbfdf9');
SET @pf_felipe = LAST_INSERT_ID();
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_ejecucion, puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel)
VALUES (@e_felipe, @pf_felipe, @ej, 1.000, 1.000, 1.000, 1.000, 1.000, 'ALTO');
SET @c_felipe = LAST_INSERT_ID();
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, fecha_hora)
VALUES (@c_felipe, 'AUTOMATICA', 'ACEPTAR', @ej, '2026-10-20 18:00:20');
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, situacion_declarada, huella_archivo)
VALUES (@e_felipe, @pf_felipe, 'CANAL_A', @a_felipe, @ej, '2026-10-20 18:00:00', 'EN_REVISION', 'EMPLEADO',
        'a7646bc41297ee9b4c64d969ff0d854ff538d0577653fbfc4517784d550e7c6b');
SET @cap_felipe = LAST_INSERT_ID();
INSERT INTO egresados.estudio_declarado (id_captura, institucion_original, programa_original, anio_inicio, anio_fin, codigo_nivel, id_programa,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion, id_ejecucion_clasificacion)
VALUES (@cap_felipe, 'Universidad Nacional de Colombia', 'Ingeniería Agrícola', 2021, 2026, 'PREGRADO', @p_agricola,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas);
-- El PDF trae una experiencia sin año de inicio: como el año es obligatorio,
-- la fila no entra; queda una incidencia y el revisor la completa con el PDF.
INSERT INTO egresados.incidencia (codigo_tipo_incidencia, id_egresado, id_captura, campo_afectado, descripcion, estado, id_ejecucion, id_responsable_asignado, fecha_hora_apertura)
VALUES ('INCOMPLETA', @e_felipe, @cap_felipe, 'experiencia.anio_inicio',
        'El PDF muestra una experiencia sin año de inicio. Se completa con el PDF antes de verificar la captura.',
        'ABIERTA', @ej, @r_revisor, '2026-10-20 18:01:00');

-- =====================================================================
-- Indicadores externos (VALORES FICTICIOS: el dato real se toma de la
-- publicación del Observatorio Laboral para la Educación)
-- =====================================================================
SET @id_ejecucion = NULL, @motivo = 'Registro de indicadores externos de ejemplo';
INSERT INTO egresados.indicador_externo (codigo_fuente, id_programa, nombre_indicador, anio_cohorte, anio_medicion, valor, unidad, referencia, fecha_consulta) VALUES
  ('OBSERVATORIO_LABORAL', @p_sistemas, 'Tasa de cotizantes al año del grado (valor ficticio)', 2021, 2022, 85.0000, 'PORCENTAJE',
   'Valor ficticio para la prueba técnica; el dato real se toma del Observatorio Laboral para la Educación', '2026-10-15'),
  ('OBSERVATORIO_LABORAL', @p_civil, 'Tasa de cotizantes al año del grado (valor ficticio)', 2023, 2024, 78.0000, 'PORCENTAJE',
   'Valor ficticio para la prueba técnica; el dato real se toma del Observatorio Laboral para la Educación', '2026-10-15');

-- =====================================================================
-- Caso 11. Natalia: canal A en 2022, "sigo igual" en M1 y, en octubre
-- de 2026, revoca su autorización.
-- =====================================================================
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2022-02-01 08:00:00', '2022-02-01 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID(), @motivo = NULL;
INSERT INTO egresados.egresado (sexo, id_ejecucion) VALUES ('F', @id_ejecucion);
SET @e_natalia = LAST_INSERT_ID();
INSERT INTO egresados_identidad.identidad (id_egresado, nombres, primer_apellido, segundo_apellido, correo_personal)
VALUES (@e_natalia, 'Natalia', 'Suárez', 'Pinto', 'natalia.suarez.ficticia@example.com');
INSERT INTO egresados_identidad.documento_identidad (id_egresado, tipo_documento, numero_documento) VALUES (@e_natalia, 'CC', '1000000011');
INSERT INTO egresados.grado (id_egresado, id_programa, anio_ingreso, semestre_ingreso, fecha_grado, estado, id_ejecucion)
VALUES (@e_natalia, @p_industrial, 2017, 1, NULL, 'EN_TRAMITE', @id_ejecucion);
SET @g_natalia = LAST_INSERT_ID();

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('BOT_CONSOLIDACION', @r_consolidacion, '1.0.0', @param_cruce, '2022-03-08 12:00:00', '2022-03-08 12:01:00', 'EXITOSA', 1);
SET @ej = LAST_INSERT_ID();
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, modelo_ia, digest_modelo_ia, parametros, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CLASIFICACION', @r_clasificacion, '1.0.0', 'llama3.1:8b', @digest_modelo, @param_clasificacion, '2022-03-08 12:01:00', '2022-03-08 12:02:00', 'EXITOSA', 2);
SET @ej_clas = LAST_INSERT_ID();
SET @id_ejecucion = @ej;
INSERT INTO egresados_identidad.autorizacion (id_egresado, id_texto_autorizacion, codigo_fuente, fecha_hora, evidencia)
VALUES (@e_natalia, @texto, 'CANAL_A', '2022-03-08 11:58:00', 'Formulario de inscripción a grado 2022-1, envío 000287');
SET @a_natalia = LAST_INSERT_ID();
INSERT INTO egresados_identidad.perfil (url, huella_url)
VALUES ('https://www.linkedin.com/in/natalia-suarez-prueba-uapa-11', 'adec2ee82c75a21732d0e18567b961b04950c5559a951a11ad16899ec57c8fd0');
SET @pf_natalia = LAST_INSERT_ID();
INSERT INTO egresados_identidad.coincidencia (id_egresado, id_perfil, id_ejecucion, puntaje_nombre, puntaje_programa, puntaje_anio, puntaje_ciudad, puntaje_total, nivel)
VALUES (@e_natalia, @pf_natalia, @ej, 1.000, 1.000, 1.000, 1.000, 1.000, 'ALTO');
SET @c_natalia = LAST_INSERT_ID();
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_ejecucion, fecha_hora)
VALUES (@c_natalia, 'AUTOMATICA', 'ACEPTAR', @ej, '2022-03-08 12:00:20');
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, situacion_declarada, huella_archivo)
VALUES (@e_natalia, @pf_natalia, 'CANAL_A', @a_natalia, @ej, '2022-03-08 12:00:00', 'RECIBIDA', 'EMPLEADO',
        'd6672946f3fbb773218ec39dfac721d6d6a371dacdc1d282b1b20a74962d7f32');
SET @cap_natalia = LAST_INSERT_ID();
INSERT INTO egresados.experiencia (id_captura, cargo_original, organizacion_original, ubicacion_original, anio_inicio, mes_inicio, anio_fin, mes_fin, tipo_vinculo,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion,
  codigo_ocupacion_propuesto, metodo_ocupacion, confianza_ocupacion, codigo_ocupacion,
  codigo_ubicacion_propuesto, metodo_ubicacion, confianza_ubicacion, codigo_ubicacion,
  codigo_area_propuesto, metodo_area, confianza_area, codigo_area, id_ejecucion_clasificacion)
VALUES (@cap_natalia, 'Ingeniera industrial', 'Agencia de Infraestructura Digital', 'Bogotá, Distrito Capital, Colombia', 2022, 1, NULL, NULL, 'EMPLEO',
  @o_agencia, 'DICCIONARIO', 1.000, @o_agencia, '2141', 'DICCIONARIO', 1.000, '2141', '11001', 'DICCIONARIO', 1.000, '11001', 'GESTION', 'IA', 0.860, 'GESTION', @ej_clas);
INSERT INTO egresados.estudio_declarado (id_captura, institucion_original, programa_original, anio_inicio, anio_fin, codigo_nivel, id_programa,
  id_organizacion_propuesto, metodo_organizacion, confianza_organizacion, id_organizacion, id_ejecucion_clasificacion)
VALUES (@cap_natalia, 'Universidad Nacional de Colombia', 'Ingeniería Industrial', 2017, 2022, 'PREGRADO', @p_industrial,
  @o_unal, 'DICCIONARIO', 1.000, @o_unal, @ej_clas);
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_natalia;

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_OFICIAL', @r_carga, '1.0.0', '2022-04-04 08:00:00', '2022-04-04 08:01:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
UPDATE egresados.grado SET estado = 'OTORGADO', fecha_grado = '2022-03-25', id_ejecucion = @id_ejecucion WHERE id_grado = @g_natalia;

INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('ENVIO_SOLICITUDES', @r_envios, '1.0.0', '2023-03-27 07:00:00', '2023-03-27 07:05:00', 'EXITOSA', 1);
SET @id_ejecucion = LAST_INSERT_ID();
INSERT INTO egresados.solicitud_actualizacion (id_egresado, codigo_momento, id_ejecucion, fecha_hora_envio, estado_envio, huella_token, fecha_vencimiento)
VALUES (@e_natalia, 'M1', @id_ejecucion, '2023-03-27 07:01:00', 'ENVIADA', 'b9a7f20dd7f67a851f256255926cc3c3aa264c7d320301144844fd183bc03853', '2023-04-26');
SET @s_natalia_m1 = LAST_INSERT_ID();
UPDATE egresados.solicitud_actualizacion
   SET respuesta = 'CONFIRMO_SIN_CAMBIOS', fecha_hora_respuesta = '2023-03-29 18:30:00', id_captura = @cap_natalia
 WHERE id_solicitud = @s_natalia_m1;

-- =====================================================================
-- Depuración (31 de octubre de 2026): conservación limitada
--   * Borra los PDF de las capturas cerradas (queda la huella).
--   * Borra los datos observados de las coincidencias ya decididas.
--   * Borra la URL de los perfiles descartados (queda la huella HMAC).
-- La bitácora registra que esos valores cambiaron, pero no los copia.
-- =====================================================================
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('DEPURACION', @r_depuracion, '1.0.0', '2026-10-31 02:00:00', '2026-10-31 02:01:00', 'EXITOSA', NULL);
SET @id_ejecucion = LAST_INSERT_ID(), @motivo = NULL;

UPDATE egresados.captura
   SET fecha_hora_borrado_archivo = '2026-10-31 02:00:00'
 WHERE estado IN ('VERIFICADA', 'RECHAZADA')
   AND huella_archivo IS NOT NULL
   AND fecha_hora_borrado_archivo IS NULL;

UPDATE egresados_identidad.coincidencia
   SET nombre_observado = NULL, programa_observado = NULL, anio_inicio_observado = NULL,
       anio_fin_observado = NULL, ciudad_observada = NULL,
       fecha_hora_borrado_observados = '2026-10-31 02:00:00'
 WHERE estado IN ('ACEPTADA', 'RECHAZADA')
   AND fecha_hora_borrado_observados IS NULL
   AND (nombre_observado IS NOT NULL OR programa_observado IS NOT NULL OR anio_inicio_observado IS NOT NULL
        OR anio_fin_observado IS NOT NULL OR ciudad_observada IS NOT NULL);

UPDATE egresados_identidad.perfil p
   SET p.url = NULL, p.fecha_hora_borrado_url = '2026-10-31 02:00:00'
 WHERE p.url IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM egresados_identidad.coincidencia c
                    WHERE c.id_perfil = p.id_perfil AND c.estado IN ('ACEPTADA', 'PENDIENTE'))
   AND EXISTS (SELECT 1 FROM egresados_identidad.coincidencia c
                WHERE c.id_perfil = p.id_perfil AND c.estado = 'RECHAZADA');

-- =====================================================================
-- Supresión de Natalia (Ley 1581, art. 8 lit. e; Decreto 1377, art. 9)
-- 1. Se registra la solicitud al recibirla.
-- 2. El programa de supresión calcula las huellas con la clave y llama
--    al procedimiento, que lo hace todo en una transacción.
-- =====================================================================
SET @id_ejecucion = NULL, @motivo = 'Registro de una solicitud de revocatoria recibida por formulario';
INSERT INTO egresados_identidad.solicitud_supresion (tipo_solicitud, canal_solicitud, fecha_hora_solicitud)
VALUES ('REVOCATORIA', 'FORMULARIO', '2026-10-20 09:15:00');
SET @sol_natalia = LAST_INSERT_ID();

CALL egresados_identidad.sp_suprimir_egresado(
  @sol_natalia, @e_natalia, @r_titulares,
  '[{"tipo": "DOCUMENTO", "huella": "9a3a489517da1bcc4919e2d43e3d64bd9f1c7c94ec24971a0541e8d7a9b13551"},
    {"tipo": "URL",       "huella": "adec2ee82c75a21732d0e18567b961b04950c5559a951a11ad16899ec57c8fd0"},
    {"tipo": "CORREO",    "huella": "9117f0e8ab679340a7068b8ca3908d48f78ec3fc5c0fbe4782a4af7cc6728bd5"}]');

SET @id_ejecucion = NULL, @motivo = NULL;
