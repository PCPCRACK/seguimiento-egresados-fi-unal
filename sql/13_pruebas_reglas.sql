-- =====================================================================
-- 13_pruebas_reglas.sql
-- Intenta romper cada regla del modelo y comprueba que la base lo impide.
-- Se ejecuta después de los datos de prueba, con --force para que siga
-- después de cada error:
--
--   & "C:\Program Files\MariaDB 12.3\bin\mariadb.exe" -u root -p --force -e "source sql/13_pruebas_reglas.sql"
--
-- Todo va dentro de una transacción que se deshace al final: no deja
-- ningún cambio. Cada prueba dice qué se espera; casi todas, un ERROR.
-- =====================================================================

SET NAMES utf8mb4;

SET @e_laura     = (SELECT id_egresado FROM egresados_identidad.documento_identidad WHERE tipo_documento = 'CC' AND numero_documento = '1000000001');
SET @e_andres    = (SELECT id_egresado FROM egresados_identidad.documento_identidad WHERE tipo_documento = 'CC' AND numero_documento = '1000000002');
SET @e_valentina = (SELECT id_egresado FROM egresados_identidad.documento_identidad WHERE tipo_documento = 'CC' AND numero_documento = '1000000003');
SET @e_jorge     = (SELECT id_egresado FROM egresados_identidad.documento_identidad WHERE tipo_documento = 'CC' AND numero_documento = '80000006');
SET @e_paula     = (SELECT id_egresado FROM egresados_identidad.documento_identidad WHERE tipo_documento = 'CC' AND numero_documento = '1000000007');

SET @pf_laura     = (SELECT id_perfil FROM egresados_identidad.coincidencia WHERE id_egresado = @e_laura AND estado = 'ACEPTADA');
SET @pf_valentina = (SELECT id_perfil FROM egresados_identidad.coincidencia WHERE id_egresado = @e_valentina);
SET @c_jorge_a    = (SELECT id_coincidencia FROM egresados_identidad.coincidencia WHERE id_egresado = @e_jorge AND estado = 'RECHAZADA');
SET @a_laura      = (SELECT MIN(id_autorizacion) FROM egresados_identidad.autorizacion WHERE id_egresado = @e_laura);
SET @cap_laura    = (SELECT MIN(id_captura) FROM egresados.captura WHERE id_egresado = @e_laura);
SET @cap_valent   = (SELECT id_captura FROM egresados.captura WHERE id_egresado = @e_valentina);
SET @pdf_laura    = (SELECT huella_archivo FROM egresados.captura WHERE id_captura = @cap_laura);
SET @m            = (SELECT MIN(id_muestra) FROM egresados.muestra);
SET @r_revisor    = (SELECT id_responsable FROM egresados.responsable WHERE usuario_bd = 'aux_revisor');
SET @ej           = (SELECT MAX(id_ejecucion) FROM egresados.ejecucion WHERE tipo_proceso = 'BOT_CONSOLIDACION');
SET @i_abierta    = (SELECT MIN(id_incidencia) FROM egresados.incidencia WHERE estado = 'ABIERTA');

SET @id_ejecucion = NULL, @motivo = 'Prueba de reglas (se deshace al final)';

START TRANSACTION;

SELECT 'R1. Una captura no puede nacer verificada (esperado: ERROR del disparador)' AS prueba;
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado)
VALUES (@e_laura, @pf_laura, 'CANAL_B', @a_laura, @ej, NOW(), 'VERIFICADA');

SELECT 'R2. No se verifica una captura con incidencias bloqueantes abiertas (esperado: ERROR)' AS prueba;
UPDATE egresados.captura SET estado = 'VERIFICADA' WHERE id_captura = @cap_valent;

SELECT 'R3. Un egresado no puede tener dos perfiles aceptados (esperado: ERROR de duplicado)' AS prueba;
INSERT INTO egresados_identidad.decision_coincidencia (id_coincidencia, tipo_decision, resultado, id_responsable, fecha_hora)
VALUES (@c_jorge_a, 'REVISION', 'ACEPTAR', @r_revisor, NOW());

SELECT 'R4. Los puntajes de una coincidencia no se modifican (esperado: ERROR del disparador)' AS prueba;
UPDATE egresados_identidad.coincidencia SET puntaje_total = 0.990 WHERE id_coincidencia = @c_jorge_a;

SELECT 'R5. Un empleo no empieza en el futuro (esperado: ERROR del disparador)' AS prueba;
INSERT INTO egresados.experiencia (id_captura, cargo_original, anio_inicio, tipo_vinculo)
VALUES (@cap_laura, 'Cargo de prueba', 2099, 'EMPLEO');

SELECT 'R6. Los códigos van en mayúsculas (esperado: ERROR de CHECK)' AS prueba;
INSERT INTO egresados.cat_fuente (codigo_fuente, nombre, base_legal, es_individual)
VALUES ('canal_d', 'Fuente de prueba', 'AUTORIZACION', 1);

SELECT 'R7. Un cambio manual sin motivo (esperado: ERROR ck_bitacora_motivo)' AS prueba;
SET @motivo = NULL;
UPDATE egresados.cat_area_desempeno SET criterio = 'Criterio cambiado sin motivo.' WHERE codigo_area = 'OTRA';
SET @motivo = 'Prueba de reglas (se deshace al final)';

SELECT 'R8. Un texto de autorización publicado no cambia (esperado: ERROR del disparador)' AS prueba;
UPDATE egresados_identidad.texto_autorizacion SET texto = CONCAT(texto, ' Cambio.') WHERE version = '1.0.0';

SELECT 'R9. Solo una versión vigente del texto (esperado: ERROR de duplicado)' AS prueba;
INSERT INTO egresados_identidad.texto_autorizacion (version, texto, fecha_inicio_vigencia)
VALUES ('2.0.0', 'Texto de prueba.', '2026-11-01');

SELECT 'R10. Captura de un perfil que no está aceptado (esperado: ERROR del disparador)' AS prueba;
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado)
VALUES (@e_valentina, @pf_valentina, 'CANAL_A',
        (SELECT MIN(id_autorizacion) FROM egresados_identidad.autorizacion WHERE id_egresado = @e_valentina),
        @ej, NOW(), 'RECIBIDA');

SELECT 'R11. El mismo PDF dos veces (esperado: ERROR de duplicado en la huella)' AS prueba;
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado, huella_archivo)
VALUES (@e_laura, @pf_laura, 'CANAL_B', @a_laura, @ej, NOW(), 'RECIBIDA', @pdf_laura);

SELECT 'R12. Una captura con la autorización de otra persona (esperado: ERROR de llave compuesta)' AS prueba;
INSERT INTO egresados.captura (id_egresado, id_perfil, codigo_fuente, id_autorizacion, id_ejecucion, fecha_hora_captura, estado)
VALUES (@e_andres, NULL, 'FORMULARIO_DIRECTO', @a_laura, @ej, NOW(), 'RECIBIDA');

SELECT 'R13. Una búsqueda en la muestra de un egresado no seleccionado (esperado: ERROR de llave compuesta)' AS prueba;
INSERT INTO egresados.busqueda (id_egresado, id_muestra, id_responsable, fecha_hora, version_protocolo, resultado)
VALUES (@e_paula, @m, @r_revisor, NOW(), '1.0.0', 'NO_ENCONTRADO');

SELECT 'R14. Una propuesta sin método ni confianza (esperado: ERROR de CHECK)' AS prueba;
INSERT INTO egresados.experiencia (id_captura, cargo_original, anio_inicio, tipo_vinculo, codigo_ocupacion_propuesto)
VALUES (@cap_laura, 'Cargo de prueba', 2020, 'EMPLEO', '2512');

SELECT 'R15. Texto con un espacio al final, aunque PAD SPACE lo ignore al comparar (esperado: ERROR de CHECK)' AS prueba;
INSERT INTO egresados.cat_area_desempeno (codigo_area, nombre, criterio) VALUES ('PRUEBA', 'Prueba ', 'Criterio.');

SELECT 'R16. Texto normalizado con tilde (esperado: ERROR de CHECK)' AS prueba;
INSERT INTO egresados.cargo_alias (texto_normalizado, codigo_ocupacion, origen, id_responsable, fecha_hora_validacion)
VALUES ('ingeniero de diseño mecánico', '2144', 'VALIDADO', @r_revisor, NOW());

SELECT 'R17. Texto normalizado con ñ y sin tildes (esperado: ENTRA, porque la ñ se conserva)' AS prueba;
INSERT INTO egresados.cargo_alias (texto_normalizado, codigo_ocupacion, origen, id_responsable, fecha_hora_validacion)
VALUES ('ingeniero de diseño mecanico', '2144', 'VALIDADO', @r_revisor, NOW());
SELECT texto_normalizado, codigo_ocupacion FROM egresados.cargo_alias WHERE texto_normalizado = 'ingeniero de diseño mecanico';

SELECT 'R18. Cerrar una incidencia sin solución (esperado: ERROR de CHECK)' AS prueba;
UPDATE egresados.incidencia SET estado = 'RESUELTA', fecha_hora_cierre = NOW() WHERE id_incidencia = @i_abierta;

ROLLBACK;

SELECT 'Fin: transacción deshecha; la base quedó como estaba' AS prueba;
