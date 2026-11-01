-- =====================================================================
-- 02_cuenta_y_roles.sql
-- Cuenta dueña de los disparadores, procedimientos y vistas, y los
-- cinco roles. Los permisos de cada rol se dan en 08_permisos.sql,
-- cuando ya existen las tablas, vistas y procedimientos.
-- Modelo de datos, pasos 0.4 y 3.9.
-- =====================================================================

SET NAMES utf8mb4;

-- Cuenta dueña: bloqueada (ACCOUNT LOCK), así que nadie inicia sesión
-- con ella. Si el dueño de los disparadores fuera la cuenta de una
-- persona, al irse esa persona habría que rehacerlos todos.
CREATE USER IF NOT EXISTS 'definidor_egresados'@'localhost' ACCOUNT LOCK;
GRANT ALL PRIVILEGES ON egresados.* TO 'definidor_egresados'@'localhost';
GRANT ALL PRIVILEGES ON egresados_identidad.* TO 'definidor_egresados'@'localhost';

-- Un rol por función, en vez de permisos por usuario: si cambia el
-- auxiliar, a la persona nueva se le asigna el rol y ya está.
CREATE ROLE IF NOT EXISTS rol_admin;
CREATE ROLE IF NOT EXISTS rol_bot;
CREATE ROLE IF NOT EXISTS rol_revisor;
CREATE ROLE IF NOT EXISTS rol_titulares;
CREATE ROLE IF NOT EXISTS rol_analista;
