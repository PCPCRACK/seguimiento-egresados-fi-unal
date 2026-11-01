-- =====================================================================
-- 99_borrar_todo.sql
-- BORRA las dos bases, la cuenta dueña y los roles, para volver a
-- instalar desde cero. Solo para el entorno de desarrollo o de prueba.
-- =====================================================================
--
-- Las llaves foráneas entre las dos bases impiden borrar una mientras la
-- otra la referencia; por eso se desactiva su comprobación solo durante
-- el borrado.

SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS egresados;
DROP DATABASE IF EXISTS egresados_identidad;
SET FOREIGN_KEY_CHECKS = 1;

DROP USER IF EXISTS 'definidor_egresados'@'localhost';
DROP ROLE IF EXISTS rol_admin;
DROP ROLE IF EXISTS rol_bot;
DROP ROLE IF EXISTS rol_revisor;
DROP ROLE IF EXISTS rol_titulares;
DROP ROLE IF EXISTS rol_analista;
