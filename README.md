# Seguimiento de egresados a partir de LinkedIn

Prueba técnica para la convocatoria 2026-C2240: estudiante auxiliar en automatización de procesos, Vicedecanatura Académica, Facultad de Ingeniería, Universidad Nacional de Colombia, sede Bogotá.

**Autor:** David Andrés Rojas Villarreal

Propuesta de **metodología**, **modelo de datos en MariaDB** y **datos de prueba** para consolidar información profesional de los egresados de la Facultad a partir de LinkedIn y de fuentes complementarias. Como pide el enunciado, no se recolectan datos reales: todas las personas y empresas de los datos de prueba son ficticias.

## La propuesta en breve

- **Acceso legítimo, sin raspado.** Ningún proceso automático entra a LinkedIn: sus condiciones de uso lo prohíben, y la autorización del egresado a la Universidad no cambia eso. Los datos llegan por tres canales:
  - **A.** Al inscribirse a grado, el egresado autoriza el tratamiento y sube el PDF de su propio perfil ("Guardar en PDF").
  - **B.** En cada momento de seguimiento (1, 3 y 5 años después del grado) confirma con un clic que sigue igual, o sube un PDF nuevo si algo cambió.
  - **C.** Para las cohortes antiguas, un auxiliar consulta perfiles públicos sobre una muestra estratificada.

  Quien no tiene LinkedIn responde un formulario corto.
- **Dos bots que no tocan LinkedIn.** El de consolidación lee el PDF, comprueba que su URL sea la del egresado y clasifica la información. El de verificación puntúa los candidatos que encuentra el auxiliar.
- **Cruce con el registro oficial**, que es el que manda. Un puntaje de confianza combina nombre, programa, año de grado y ciudad. Según el nivel (alto, medio, bajo o imposible), el caso se acepta, va a revisión humana o se descarta, y cada decisión queda registrada para calibrar los umbrales.
- **Estandarización con las clasificaciones oficiales:** CUOC para las ocupaciones, CIIU Rev. 4 A.C. para la actividad económica y DIVIPOLA para la ubicación, todas del DANE. Se suman diccionarios de equivalencias que crecen con cada validación. La IA local solo clasifica lo que el diccionario no conoce, y nunca identifica personas.
- **Protección de datos** (Ley 1581 de 2012 y Decreto 1377 de 2013):
  - la identidad va en una base separada, a la que el analista no tiene acceso;
  - conservación limitada: el PDF y los datos observados se borran al cerrar cada caso;
  - la supresión completa se hace en una sola transacción, y queda una lista de no contactar con huellas HMAC;
  - ningún indicador se publica sobre grupos de menos de 5 personas.
- **Implementación por fases,** con un piloto de un semestre en Ingeniería de Sistemas y Computación y sus posgrados. La muestra del canal C se dimensiona con las horas reales del auxiliar (12 por semana): el piloto cabe en un semestre, y para la Facultad completa el canal C rota tres programas por año mientras los canales A y B cubren a todos.

## Cómo está organizado

| Ruta | Contenido |
|---|---|
| [`docs/01_metodologia.md`](docs/01_metodologia.md) | Metodología: identificación, variables, recolección, calidad, protección de datos, análisis y **registro de decisiones** (cada elección con su alternativa descartada) |
| [`docs/02_modelo_datos.md`](docs/02_modelo_datos.md) | Modelo de datos en cuatro pasos: configuración de MariaDB, modelo conceptual (39 entidades en 7 patrones, con diagramas), modelo lógico y modelo físico, con las pruebas hechas en el servidor |
| [`docs/03_diccionario_datos.md`](docs/03_diccionario_datos.md) | Diccionario de datos: 28 dominios y las 39 tablas, columna por columna |
| [`docs/04_plan_implementacion.md`](docs/04_plan_implementacion.md) | Plan de implementación: fases y cronograma, actividades con responsable, recursos, capacidad del auxiliar y tamaño de la muestra, calendario de actualización, indicadores del proceso y riesgos |
| [`sql/`](sql) | Scripts de MariaDB: estructura, disparadores, bitácora, procedimientos, vistas, permisos, catálogos, datos de prueba y consultas |

## Correspondencia con el enunciado

| Punto | Dónde está |
|---|---|
| 3.1 Documento metodológico | `docs/01_metodologia.md`, secciones 1 a 7 |
| 3.1 Implementación: actividades, recursos, responsables y actualización periódica | `docs/04_plan_implementacion.md` |
| 3.2.1 Diccionario de datos | `docs/03_diccionario_datos.md` |
| 3.2.2 Estructura de almacenamiento | `docs/02_modelo_datos.md` (pasos 0 y 3) y `sql/03_tablas.sql` |
| 3.2.3 Identificación de registros | `docs/02_modelo_datos.md`, paso 1 (secciones 1.12 y 2.2) |
| 3.2.4 Estandarización | Catálogos y diccionarios: `docs/02_modelo_datos.md`, paso 1, y `sql/09_catalogos.sql` |
| 3.2.5 Control de calidad | `docs/01_metodologia.md`, sección 4; `sql/11_consultas_calidad.sql` y `sql/13_pruebas_reglas.sql` |
| 3.2.6 Datos de prueba | `sql/10_datos_prueba.sql` |
| 3.3 Publicación en GitHub | Este repositorio |

## Cómo instalar la base de datos

Requisito: MariaDB 12.3 (probado en 12.3.3). Desde la carpeta del repositorio, en PowerShell:

```powershell
& "C:\Program Files\MariaDB 12.3\bin\mariadb.exe" -u root -p -e "source sql/instalar_todo.sql"
```

Eso crea las dos bases (`egresados_identidad` y `egresados`), la cuenta dueña y los roles, las 39 tablas, 120 disparadores, 2 procedimientos, 5 vistas y los permisos, y carga los catálogos y los datos de prueba.

Para comprobar que las reglas se cumplen, este script intenta romper 18 de ellas y luego deshace todo:

```powershell
& "C:\Program Files\MariaDB 12.3\bin\mariadb.exe" -u root -p --force -e "source sql/13_pruebas_reglas.sql"
```

| Script | Para qué |
|---|---|
| `sql/11_consultas_calidad.sql` | Control de calidad: cola de revisión, incidencias, duplicados, desactualizados, faltantes, conservación limitada |
| `sql/12_consultas_analisis.sql` | Indicadores: vinculación, sectores, ocupaciones, tiempo hasta el primer empleo, pertinencia, movilidad, posgrado, trayectoria y brechas |
| `sql/00_pruebas_motor.sql` | Las 16 pruebas de MariaDB que decidieron los tipos de datos |
| `sql/99_borrar_todo.sql` | Borra todo para reinstalar (solo en un entorno de prueba) |

## Los datos de prueba

Diez egresados ficticios, y un undécimo que revoca su autorización. Cada caso muestra una parte del diseño:

| Caso | Qué muestra |
|---|---|
| Laura | Canal A y dos actualizaciones: historial de capturas, una práctica que no cuenta como empleo, ascenso a directiva, auditoría |
| Andrés | Una experiencia repetida en el PDF (incidencia resuelta) y un "sigo igual" de un clic |
| Valentina | La URL del PDF no coincide con la del formulario: queda en revisión |
| Carlos | Canal C: puntaje medio, revisión humana y un cargo nuevo que entra al diccionario |
| Diana | Canal C: se buscó y no se encontró |
| Jorge | Canal C: dos candidatos, uno descartado y su URL borrada |
| Paula | Un candidato imposible (carrera de dos años) |
| Sebastián | Doble titulación, tarjeta de identidad y cédula, correo que rebota |
| Mariana | Sin LinkedIn: formulario directo, buscando empleo |
| Felipe | Grado en trámite y un dato faltante en el PDF |
| Natalia | Revoca su autorización: de ella solo quedan la constancia y las huellas |

## Pendientes

Para validar con la Facultad: la base legal del canal C (Oficina Jurídica), las ocupaciones afines a cada programa (comités asesores) y el umbral de celda mínima. El plan de implementación los incluye como actividades (0.1, 0.3, 0.7 y 4.2).

## Herramientas

MariaDB 12.3, Git y Markdown, con diagramas Mermaid que GitHub muestra directamente. El trabajo se desarrolló con apoyo de Claude (Anthropic) como asistente. Las decisiones se discutieron y se tomaron una a una, y cada una está justificada en el registro de decisiones de la metodología.
