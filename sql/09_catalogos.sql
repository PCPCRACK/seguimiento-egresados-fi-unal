-- =====================================================================
-- 09_catalogos.sql
-- Responsables, catálogos y diccionarios de MUESTRA para la prueba.
-- =====================================================================
--
-- Qué es real y qué es muestra:
--   * Programas: los nombres son los de la página de programas de la
--     Facultad. Los códigos SNIES y SIA quedan vacíos, y la duración
--     mínima es un valor de ejemplo, a confirmar con la Secretaría.
--   * CUOC, CIIU Rev. 4 A.C. y DIVIPOLA: solo una muestra de códigos.
--     En operación, cada catálogo se carga completo del archivo oficial
--     del DANE. De la CUOC se incluyen los cuatro niveles superiores;
--     el quinto (ocupación) viene del archivo oficial.
--   * Organizaciones: las universidades son reales; las empresas y la
--     entidad pública son FICTICIAS.
--   * Responsables: las personas son ficticias.
--
-- Este script lo ejecuta root. Como la bitácora exige que todo usuario
-- que escribe esté registrado como responsable, el primer registro es
-- el propio root. Los cambios manuales llevan @motivo.

SET NAMES utf8mb4;

SET @id_ejecucion = NULL;
SET @motivo = 'Instalación: registro de responsables';

-- ---------------------------------------------------------------------
-- Responsables
-- ---------------------------------------------------------------------
INSERT INTO egresados.responsable (usuario_bd, nombre, tipo, fecha_alta) VALUES
  ('root',              'Administrador de la base (instalación)',                  'PERSONA', '2020-01-01'),
  ('bot_carga',         'Bot de carga del registro oficial',                       'BOT',     '2020-01-01'),
  ('bot_consolidacion', 'Bot 1: consolidación (canales A y B)',                    'BOT',     '2020-01-01'),
  ('bot_verificacion',  'Bot 2: verificación (canal C)',                           'BOT',     '2020-01-01'),
  ('bot_clasificacion', 'Bot de clasificación (diccionario e IA local)',           'BOT',     '2020-01-01'),
  ('bot_envios',        'Bot de envío de solicitudes de actualización',            'BOT',     '2020-01-01'),
  ('bot_muestreo',      'Bot de selección de muestras',                            'BOT',     '2020-01-01'),
  ('bot_depuracion',    'Bot de depuración (conservación limitada)',               'BOT',     '2020-01-01'),
  ('aux_revisor',       'Auxiliar de seguimiento (persona ficticia)',              'PERSONA', '2020-01-01'),
  ('resp_titulares',    'Responsable de protección de datos (persona ficticia)',   'PERSONA', '2020-01-01');

SET @r_root          = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'root');
SET @r_revisor       = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'aux_revisor');

-- La carga de catálogos es una ejecución: queda registrada qué versión de
-- cada clasificación se cargó.
INSERT INTO egresados.ejecucion (tipo_proceso, id_responsable, version_programa, parametros,
                                 fecha_hora_inicio, fecha_hora_fin, resultado, registros_procesados)
VALUES ('CARGA_CATALOGO', @r_root, '1.0.0',
        '{"CUOC": "actualizacion 2025 (muestra)", "CIIU": "Rev. 4 A.C. 2022 (muestra)", "DIVIPOLA": "muestra", "ISO_3166_1": "muestra"}',
        '2020-12-01 08:00:00', '2020-12-01 08:10:00', 'EXITOSA', NULL);
SET @id_ejecucion = LAST_INSERT_ID();
SET @motivo = NULL;

-- ---------------------------------------------------------------------
-- Catálogos propios
-- ---------------------------------------------------------------------
INSERT INTO egresados.cat_nivel_formacion (codigo_nivel, nombre, orden) VALUES
  ('TECNICO',         'Técnico profesional',    1),
  ('TECNOLOGICO',     'Tecnológico',            2),
  ('PREGRADO',        'Pregrado universitario', 3),
  ('ESPECIALIZACION', 'Especialización',        4),
  ('MAESTRIA',        'Maestría',               5),
  ('DOCTORADO',       'Doctorado',              6),
  ('OTRO',            'Otro',                   NULL),
  ('NO_DETERMINADO',  'No determinado',         NULL);

INSERT INTO egresados.cat_fuente (codigo_fuente, nombre, base_legal, norma, es_individual) VALUES
  ('CANAL_A',              'PDF del perfil en la inscripción a grado',               'AUTORIZACION',           'Ley 1581 de 2012, art. 9', 1),
  ('CANAL_B',              'PDF del perfil en un momento de seguimiento',            'AUTORIZACION',           'Ley 1581 de 2012, art. 9', 1),
  ('CANAL_C',              'Consulta manual de un perfil público',                   'DATO_PUBLICO',           'Decreto 1377 de 2013, art. 3 num. 2; Ley 1581 de 2012, art. 10 lit. b', 1),
  ('FORMULARIO_DIRECTO',   'Formulario de la Facultad para egresados sin LinkedIn',  'AUTORIZACION',           'Ley 1581 de 2012, art. 9', 1),
  ('REGISTRO_ACADEMICO',   'Registro académico oficial',                             'REGISTRO_INSTITUCIONAL', NULL, 1),
  ('ENCUESTA',             'Encuesta de egresados de la Universidad',                'AUTORIZACION',           'Ley 1581 de 2012, art. 9', 1),
  ('OBSERVATORIO_LABORAL', 'Observatorio Laboral para la Educación',                 'SIN_DATOS_PERSONALES',   NULL, 0);

INSERT INTO egresados.cat_tipo_incidencia (codigo_tipo_incidencia, nombre, dimension, severidad, bloquea_captura) VALUES
  ('INCOMPLETA',     'Información incompleta',                'COMPLETA',     'MEDIA', 1),
  ('AMBIGUA',        'Información ambigua',                   'COMPRENSIBLE', 'MEDIA', 1),
  ('DESACTUALIZADA', 'Información desactualizada',            'ACTUALIZADA',  'BAJA',  0),
  ('NO_VERIFICABLE', 'Información no verificable',            'COMPROBABLE',  'ALTA',  1),
  ('URL_DISTINTA',   'URL del PDF distinta a la registrada',  'VERAZ',        'ALTA',  1),
  ('DUPLICADA',      'Registro duplicado',                    'EXACTA',       'MEDIA', 1);

INSERT INTO egresados.cat_momento_seguimiento (codigo_momento, anios_desde_grado, es_activo) VALUES
  ('M0', 0, 1), ('M1', 1, 1), ('M3', 3, 1), ('M5', 5, 1), ('M10', 10, 1), ('M15', 15, 1), ('M20', 20, 1);

INSERT INTO egresados.cat_area_desempeno (codigo_area, nombre, criterio) VALUES
  ('DOCENCIA',       'Docencia',       'Enseña en una institución educativa.'),
  ('INVESTIGACION',  'Investigación',  'Genera conocimiento nuevo en un grupo, centro o laboratorio de investigación.'),
  ('DESARROLLO',     'Desarrollo',     'Diseña o construye productos, sistemas, obras o procesos.'),
  ('CONSULTORIA',    'Consultoría',    'Asesora a terceros como experto externo.'),
  ('GESTION',        'Gestión',        'Dirige equipos, proyectos o áreas de una organización.'),
  ('OPERACION',      'Operación',      'Opera, mantiene o supervisa procesos, sistemas o infraestructura en funcionamiento.'),
  ('EMPRENDIMIENTO', 'Emprendimiento', 'Fundó o dirige su propia empresa.'),
  ('OTRA',           'Otra',           'Ninguna de las anteriores.');

-- ---------------------------------------------------------------------
-- Clasificaciones oficiales (MUESTRA)
-- ---------------------------------------------------------------------

-- Ubicaciones: países (ISO 3166-1 alfa-2), departamentos y municipios (DIVIPOLA)
INSERT INTO egresados.cat_ubicacion (codigo_ubicacion, nombre, codigo_padre, es_vigente) VALUES
  ('CO', 'Colombia',       NULL, 1),
  ('US', 'Estados Unidos', NULL, 1),
  ('ES', 'España',         NULL, 1),
  ('DE', 'Alemania',       NULL, 1),
  ('MX', 'México',         NULL, 1),
  ('CA', 'Canadá',         NULL, 1),
  ('CL', 'Chile',          NULL, 1);
INSERT INTO egresados.cat_ubicacion (codigo_ubicacion, nombre, codigo_padre, es_vigente) VALUES
  ('05', 'Antioquia',       'CO', 1),
  ('08', 'Atlántico',       'CO', 1),
  ('11', 'Bogotá, D. C.',   'CO', 1),
  ('25', 'Cundinamarca',    'CO', 1),
  ('76', 'Valle del Cauca', 'CO', 1);
INSERT INTO egresados.cat_ubicacion (codigo_ubicacion, nombre, codigo_padre, es_vigente) VALUES
  ('05001', 'Medellín',      '05', 1),
  ('08001', 'Barranquilla',  '08', 1),
  ('11001', 'Bogotá, D. C.', '11', 1),
  ('25175', 'Chía',          '25', 1),
  ('25754', 'Soacha',        '25', 1),
  ('25817', 'Tocancipá',     '25', 1),
  ('76001', 'Cali',          '76', 1);

-- Actividades económicas (CIIU Rev. 4 A.C.): sección -> división -> grupo -> clase
INSERT INTO egresados.cat_actividad_economica (codigo_actividad, nombre, codigo_padre, es_vigente) VALUES
  ('B', 'Explotación de minas y canteras', NULL, 1),
  ('D', 'Suministro de electricidad, gas, vapor y aire acondicionado', NULL, 1),
  ('F', 'Construcción', NULL, 1),
  ('J', 'Información y comunicaciones', NULL, 1),
  ('K', 'Actividades financieras y de seguros', NULL, 1),
  ('M', 'Actividades profesionales, científicas y técnicas', NULL, 1),
  ('O', 'Administración pública y defensa; planes de seguridad social de afiliación obligatoria', NULL, 1),
  ('P', 'Educación', NULL, 1);
INSERT INTO egresados.cat_actividad_economica (codigo_actividad, nombre, codigo_padre, es_vigente) VALUES
  ('06', 'Extracción de petróleo crudo y gas natural', 'B', 1),
  ('35', 'Suministro de electricidad, gas, vapor y aire acondicionado', 'D', 1),
  ('42', 'Obras de ingeniería civil', 'F', 1),
  ('62', 'Desarrollo de sistemas informáticos, consultoría informática y actividades relacionadas', 'J', 1),
  ('64', 'Actividades de servicios financieros, excepto las de seguros y de pensiones', 'K', 1),
  ('71', 'Actividades de arquitectura e ingeniería; ensayos y análisis técnicos', 'M', 1),
  ('84', 'Administración pública y defensa; planes de seguridad social de afiliación obligatoria', 'O', 1),
  ('85', 'Educación', 'P', 1);
INSERT INTO egresados.cat_actividad_economica (codigo_actividad, nombre, codigo_padre, es_vigente) VALUES
  ('061', 'Extracción de petróleo crudo', '06', 1),
  ('351', 'Generación, transmisión, distribución y comercialización de energía eléctrica', '35', 1),
  ('421', 'Construcción de carreteras y vías de ferrocarril', '42', 1),
  ('620', 'Desarrollo de sistemas informáticos, consultoría informática y actividades relacionadas', '62', 1),
  ('641', 'Intermediación monetaria', '64', 1),
  ('711', 'Actividades de arquitectura e ingeniería y otras actividades conexas de consultoría técnica', '71', 1),
  ('841', 'Administración del Estado y aplicación de la política económica y social de la comunidad', '84', 1),
  ('854', 'Educación superior', '85', 1);
INSERT INTO egresados.cat_actividad_economica (codigo_actividad, nombre, codigo_padre, es_vigente) VALUES
  ('0610', 'Extracción de petróleo crudo', '061', 1),
  ('3511', 'Generación de energía eléctrica', '351', 1),
  ('4210', 'Construcción de carreteras y vías de ferrocarril', '421', 1),
  ('6201', 'Actividades de desarrollo de sistemas informáticos (planificación, análisis, diseño, programación, pruebas)', '620', 1),
  ('6202', 'Actividades de consultoría informática y actividades de administración de instalaciones informáticas', '620', 1),
  ('6412', 'Bancos comerciales', '641', 1),
  ('7110', 'Actividades de arquitectura e ingeniería y otras actividades conexas de consultoría técnica', '711', 1),
  ('8412', 'Actividades ejecutivas de la administración pública', '841', 1),
  ('8544', 'Educación de universidades', '854', 1);

-- Ocupaciones (CUOC): los cuatro niveles superiores, que siguen a la CIUO-08
INSERT INTO egresados.cat_ocupacion (codigo_ocupacion, nombre, codigo_padre, es_vigente) VALUES
  ('1', 'Directores y gerentes', NULL, 1),
  ('2', 'Profesionales científicos e intelectuales', NULL, 1);
INSERT INTO egresados.cat_ocupacion (codigo_ocupacion, nombre, codigo_padre, es_vigente) VALUES
  ('13', 'Directores y gerentes de producción y operaciones', '1', 1),
  ('21', 'Profesionales de las ciencias y de la ingeniería', '2', 1),
  ('23', 'Profesionales de la enseñanza', '2', 1),
  ('24', 'Especialistas en organización de la administración pública y de empresas', '2', 1),
  ('25', 'Profesionales de tecnología de la información y las comunicaciones', '2', 1);
INSERT INTO egresados.cat_ocupacion (codigo_ocupacion, nombre, codigo_padre, es_vigente) VALUES
  ('133', 'Directores de servicios de tecnología de la información y las comunicaciones', '13', 1),
  ('214', 'Ingenieros (excluyendo electrotecnólogos)', '21', 1),
  ('215', 'Ingenieros en electrotecnología', '21', 1),
  ('231', 'Profesores de universidades y de la enseñanza superior', '23', 1),
  ('242', 'Especialistas en organización de la administración', '24', 1),
  ('251', 'Desarrolladores y analistas de software y multimedia', '25', 1);
INSERT INTO egresados.cat_ocupacion (codigo_ocupacion, nombre, codigo_padre, es_vigente) VALUES
  ('1330', 'Directores de servicios de tecnología de la información y las comunicaciones', '133', 1),
  ('2141', 'Ingenieros industriales y de producción', '214', 1),
  ('2142', 'Ingenieros civiles', '214', 1),
  ('2144', 'Ingenieros mecánicos', '214', 1),
  ('2145', 'Ingenieros químicos', '214', 1),
  ('2151', 'Ingenieros electricistas', '215', 1),
  ('2152', 'Ingenieros electrónicos', '215', 1),
  ('2310', 'Profesores de universidades y de la enseñanza superior', '231', 1),
  ('2421', 'Analistas de gestión y organización', '242', 1),
  ('2511', 'Analistas de sistemas', '251', 1),
  ('2512', 'Desarrolladores de software', '251', 1);

-- ---------------------------------------------------------------------
-- Programas de la Facultad (nombres de la página de programas)
-- ---------------------------------------------------------------------
INSERT INTO egresados.cat_programa (nombre, codigo_nivel, codigo_snies, codigo_sia, semestres_minimos, es_vigente) VALUES
  ('Ingeniería Agrícola',                              'PREGRADO',        NULL, NULL, 8, 1),
  ('Ingeniería Civil',                                 'PREGRADO',        NULL, NULL, 8, 1),
  ('Ingeniería de Sistemas y Computación',             'PREGRADO',        NULL, NULL, 8, 1),
  ('Ingeniería Eléctrica',                             'PREGRADO',        NULL, NULL, 8, 1),
  ('Ingeniería Electrónica',                           'PREGRADO',        NULL, NULL, 8, 1),
  ('Ingeniería Industrial',                            'PREGRADO',        NULL, NULL, 8, 1),
  ('Ingeniería Mecánica',                              'PREGRADO',        NULL, NULL, 8, 1),
  ('Ingeniería Mecatrónica',                           'PREGRADO',        NULL, NULL, 8, 1),
  ('Ingeniería Química',                               'PREGRADO',        NULL, NULL, 8, 1),
  ('Especialización en Estructuras',                   'ESPECIALIZACION', NULL, NULL, 2, 1),
  ('Maestría en Ingeniería de Sistemas y Computación', 'MAESTRIA',        NULL, NULL, 3, 1),
  ('Maestría en Ingeniería Industrial',                'MAESTRIA',        NULL, NULL, 3, 1),
  ('Doctorado en Ingeniería Sistemas y Computación',   'DOCTORADO',       NULL, NULL, 6, 1);

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
SET @p_m_industrial = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Maestría en Ingeniería Industrial');
SET @p_d_sistemas  = (SELECT id_programa FROM egresados.cat_programa WHERE nombre = 'Doctorado en Ingeniería Sistemas y Computación');

-- ---------------------------------------------------------------------
-- Organizaciones (las empresas y la entidad pública son ficticias)
-- ---------------------------------------------------------------------
INSERT INTO egresados.cat_organizacion (nombre, codigo_pais, nit, codigo_actividad_propuesto, metodo_actividad,
                                        confianza_actividad, codigo_actividad, id_ejecucion_clasificacion) VALUES
  ('Universidad Nacional de Colombia',          'CO', NULL, '8544', 'IA', 0.990, '8544', @id_ejecucion),
  ('Universidad de los Andes',                  'CO', NULL, '8544', 'IA', 0.990, '8544', @id_ejecucion),
  ('Technische Universität München',            'DE', NULL, '8544', 'IA', 0.980, '8544', @id_ejecucion),
  ('Andina Software S.A.S.',                    'CO', NULL, '6201', 'IA', 0.930, '6201', @id_ejecucion),
  ('Banco Cordillera S.A.',                     'CO', NULL, '6412', 'IA', 0.950, '6412', @id_ejecucion),
  ('Consultores de Ingeniería Sabana Ltda.',    'CO', NULL, '7110', 'IA', 0.880, '7110', @id_ejecucion),
  ('Vías del Llano S.A.S.',                     'CO', NULL, '4210', 'IA', 0.910, '4210', @id_ejecucion),
  ('Energía Andina E.S.P.',                     'CO', NULL, '3511', 'IA', 0.940, '3511', @id_ejecucion),
  ('Agencia de Infraestructura Digital',        'CO', NULL, '8412', 'IA', 0.700, '8412', @id_ejecucion);

SET @o_unal      = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Universidad Nacional de Colombia');
SET @o_andes     = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Universidad de los Andes');
SET @o_tum       = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Technische Universität München');
SET @o_andina    = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Andina Software S.A.S.');
SET @o_banco     = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Banco Cordillera S.A.');
SET @o_sabana    = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Consultores de Ingeniería Sabana Ltda.');
SET @o_vias      = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Vías del Llano S.A.S.');
SET @o_energia   = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Energía Andina E.S.P.');
SET @o_agencia   = (SELECT id_organizacion FROM egresados.cat_organizacion WHERE nombre = 'Agencia de Infraestructura Digital');

-- ---------------------------------------------------------------------
-- Diccionarios de equivalencias (texto normalizado -> valor)
-- ---------------------------------------------------------------------
INSERT INTO egresados.programa_alias (texto_normalizado, id_programa, origen, id_responsable, fecha_hora_validacion) VALUES
  ('ingenieria agricola',                               @p_agricola,    'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('ingenieria civil',                                  @p_civil,       'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('ingenieria de sistemas y computacion',              @p_sistemas,    'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('ingenieria electrica',                              @p_electrica,   'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('ingenieria electronica',                            @p_electronica, 'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('ingenieria industrial',                             @p_industrial,  'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('ingenieria mecanica',                               @p_mecanica,    'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('ingenieria mecatronica',                            @p_mecatronica, 'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('ingenieria quimica',                                @p_quimica,     'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('maestria en ingenieria de sistemas y computacion',  @p_m_sistemas,  'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('maestria en ingenieria industrial',                 @p_m_industrial,'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('doctorado en ingenieria sistemas y computacion',    @p_d_sistemas,  'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  -- Como lo escriben los egresados (el primero es el del PDF de prueba)
  ('ingenieria en sistemas y computacion',              @p_sistemas,    'VALIDADO', @r_revisor, '2021-03-12 10:00:00'),
  ('ingenieria de sistemas',                            @p_sistemas,    'VALIDADO', @r_revisor, '2021-03-12 10:05:00'),
  ('ingenieria electrica y electronica',                @p_electrica,   'VALIDADO', @r_revisor, '2021-03-12 10:10:00');

INSERT INTO egresados.organizacion_alias (texto_normalizado, id_organizacion, origen, id_responsable, fecha_hora_validacion) VALUES
  ('universidad nacional de colombia',          @o_unal,    'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('universidad nacional',                      @o_unal,    'VALIDADO', @r_revisor, '2021-03-12 11:00:00'),
  ('unal',                                      @o_unal,    'VALIDADO', @r_revisor, '2021-03-12 11:00:00'),
  ('universidad de los andes',                  @o_andes,   'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('uniandes',                                  @o_andes,   'VALIDADO', @r_revisor, '2021-03-12 11:05:00'),
  ('technische universitat munchen',            @o_tum,     'OFICIAL',  @r_root,    '2020-12-01 09:00:00'),
  ('andina software sas',                       @o_andina,  'VALIDADO', @r_revisor, '2021-03-12 11:10:00'),
  ('andina software',                           @o_andina,  'VALIDADO', @r_revisor, '2021-03-12 11:10:00'),
  ('banco cordillera sa',                       @o_banco,   'VALIDADO', @r_revisor, '2021-03-12 11:15:00'),
  ('banco cordillera',                          @o_banco,   'VALIDADO', @r_revisor, '2021-03-12 11:15:00'),
  ('consultores de ingenieria sabana ltda',     @o_sabana,  'VALIDADO', @r_revisor, '2021-03-12 11:20:00'),
  ('vias del llano sas',                        @o_vias,    'VALIDADO', @r_revisor, '2021-03-12 11:25:00'),
  ('energia andina esp',                        @o_energia, 'VALIDADO', @r_revisor, '2021-03-12 11:30:00'),
  ('agencia de infraestructura digital',        @o_agencia, 'VALIDADO', @r_revisor, '2021-03-12 11:35:00');

-- El catálogo de cargos: cargo escrito -> ocupación. Los cargos ambiguos
-- ("analista", "consultor") no entran: se clasifican caso por caso.
INSERT INTO egresados.cargo_alias (texto_normalizado, codigo_ocupacion, origen, id_responsable, fecha_hora_validacion) VALUES
  ('desarrollador de software',    '2512', 'VALIDADO', @r_revisor, '2021-03-12 12:00:00'),
  ('desarrolladora de software',   '2512', 'VALIDADO', @r_revisor, '2021-03-12 12:00:00'),
  ('desarrollador backend',        '2512', 'VALIDADO', @r_revisor, '2021-03-12 12:00:00'),
  ('backend developer',            '2512', 'VALIDADO', @r_revisor, '2021-03-12 12:00:00'),
  ('ingeniero de software',        '2512', 'VALIDADO', @r_revisor, '2021-03-12 12:00:00'),
  ('ingeniera de software',        '2512', 'VALIDADO', @r_revisor, '2021-03-12 12:00:00'),
  ('analista de sistemas',         '2511', 'VALIDADO', @r_revisor, '2021-03-12 12:05:00'),
  ('ingeniero civil',              '2142', 'VALIDADO', @r_revisor, '2021-03-12 12:10:00'),
  ('ingeniera civil',              '2142', 'VALIDADO', @r_revisor, '2021-03-12 12:10:00'),
  ('ingeniero industrial',         '2141', 'VALIDADO', @r_revisor, '2021-03-12 12:15:00'),
  ('ingeniera industrial',         '2141', 'VALIDADO', @r_revisor, '2021-03-12 12:15:00'),
  ('ingeniero mecanico',           '2144', 'VALIDADO', @r_revisor, '2021-03-12 12:20:00'),
  ('ingeniero quimico',            '2145', 'VALIDADO', @r_revisor, '2021-03-12 12:25:00'),
  ('ingeniero electricista',       '2151', 'VALIDADO', @r_revisor, '2021-03-12 12:30:00'),
  ('ingeniero electronico',        '2152', 'VALIDADO', @r_revisor, '2021-03-12 12:35:00'),
  ('docente universitario',        '2310', 'VALIDADO', @r_revisor, '2021-03-12 12:40:00'),
  ('profesor universitario',       '2310', 'VALIDADO', @r_revisor, '2021-03-12 12:40:00'),
  ('gerente de tecnologia',        '1330', 'VALIDADO', @r_revisor, '2021-03-12 12:45:00'),
  ('directora de tecnologia',      '1330', 'VALIDADO', @r_revisor, '2021-03-12 12:45:00'),
  ('analista de procesos',         '2421', 'VALIDADO', @r_revisor, '2021-03-12 12:50:00');

-- LinkedIn escribe la misma ciudad de varias formas. En el exterior solo
-- se registra el país.
INSERT INTO egresados.ubicacion_alias (texto_normalizado, codigo_ubicacion, origen, id_responsable, fecha_hora_validacion) VALUES
  ('bogota distrito capital colombia',  '11001', 'VALIDADO', @r_revisor, '2021-03-12 13:00:00'),
  ('bogota dc colombia',                '11001', 'VALIDADO', @r_revisor, '2021-03-12 13:00:00'),
  ('bogota',                            '11001', 'VALIDADO', @r_revisor, '2021-03-12 13:00:00'),
  ('medellin antioquia colombia',       '05001', 'VALIDADO', @r_revisor, '2021-03-12 13:05:00'),
  ('cali valle del cauca colombia',     '76001', 'VALIDADO', @r_revisor, '2021-03-12 13:10:00'),
  ('tocancipa cundinamarca colombia',   '25817', 'VALIDADO', @r_revisor, '2021-03-12 13:15:00'),
  ('colombia',                          'CO',    'VALIDADO', @r_revisor, '2021-03-12 13:20:00'),
  ('munich bavaria germany',            'DE',    'VALIDADO', @r_revisor, '2021-03-12 13:25:00'),
  ('munich alemania',                   'DE',    'VALIDADO', @r_revisor, '2021-03-12 13:25:00'),
  ('madrid españa',                     'ES',    'VALIDADO', @r_revisor, '2021-03-12 13:30:00');

-- ---------------------------------------------------------------------
-- Afinidad programa -> ocupaciones pertinentes (EJEMPLO: la define cada
-- comité de programa). Un código cubre sus niveles inferiores.
-- ---------------------------------------------------------------------
INSERT INTO egresados.afinidad_programa_ocupacion (id_programa, codigo_ocupacion, soporte, id_responsable) VALUES
  (@p_sistemas,    '25',   'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_sistemas,    '133',  'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_m_sistemas,  '25',   'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_m_sistemas,  '133',  'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_m_sistemas,  '2310', 'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_civil,       '2142', 'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_industrial,  '2141', 'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_industrial,  '2421', 'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_mecanica,    '2144', 'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_quimica,     '2145', 'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_electrica,   '2151', 'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor),
  (@p_electronica, '2152', 'Ejemplo para la prueba: debe definirlo el comité asesor del programa', @r_revisor);

-- ---------------------------------------------------------------------
-- Texto de autorización (EJEMPLO: el definitivo lo redacta la Oficina
-- Jurídica de la Universidad)
-- ---------------------------------------------------------------------
INSERT INTO egresados_identidad.texto_autorizacion (version, texto, fecha_inicio_vigencia, fecha_fin_vigencia)
VALUES ('1.0.0',
        'TEXTO DE EJEMPLO PARA LA PRUEBA TÉCNICA. Autorizo a la Universidad Nacional de Colombia, Facultad de Ingeniería, sede Bogotá, para tratar mis datos personales con la finalidad de hacer seguimiento a mi trayectoria profesional como egresado: recibir solicitudes de actualización, conservar el PDF de mi perfil de LinkedIn hasta verificar su contenido y usar mis datos laborales, de forma agregada, en estudios de la Facultad. Conozco mis derechos a conocer, actualizar, rectificar y suprimir mis datos y a revocar esta autorización (Ley 1581 de 2012, art. 8).',
        '2020-01-01', NULL);

SET @id_ejecucion = NULL;
