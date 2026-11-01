-- =====================================================================
-- 01_bases.sql
-- Crea las dos bases de datos del sistema.
-- Modelo de datos, paso 0. Se ejecuta como administrador.
-- =====================================================================
--
-- Por qué dos bases: la identidad (nombres, documentos, URL) queda
-- separada de los datos de análisis, y el rol de analista no tiene
-- ningún permiso sobre ella (decisión 15 de la metodología).
--
-- El juego de caracteres y la intercalación se declaran aquí, aunque el
-- servidor ya los traiga por defecto, para que el resultado no dependa
-- de la configuración del servidor donde se instale.

SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS egresados_identidad
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_uca1400_spanish_ai_ci;

CREATE DATABASE IF NOT EXISTS egresados
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_uca1400_spanish_ai_ci;
