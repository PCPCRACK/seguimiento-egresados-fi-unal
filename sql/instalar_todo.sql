-- =====================================================================
-- instalar_todo.sql
-- Instala todo en orden. Se ejecuta desde la carpeta del repositorio:
--
--   & "C:\Program Files\MariaDB 12.3\bin\mariadb.exe" -u root -p -e "source sql/instalar_todo.sql"
--
-- 05_bitacora.sql ya viene generado. Si se cambia una tabla, se vuelve a
-- generar con generar_bitacora.sql (ver su encabezado).
-- =====================================================================

source sql/01_bases.sql
source sql/02_cuenta_y_roles.sql
source sql/03_tablas.sql
source sql/04_disparadores.sql
source sql/05_bitacora.sql
source sql/06_procedimientos.sql
source sql/07_vistas.sql
source sql/08_permisos.sql
source sql/09_catalogos.sql
source sql/10_datos_prueba.sql
