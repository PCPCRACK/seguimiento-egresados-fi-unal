# Metodología para la consolidación de información de egresados a partir de LinkedIn

> **Estado:** versión de entrega (noviembre de 2026). Lo pendiente está al final, en "Pendientes".
> Facultad de Ingeniería – Universidad Nacional de Colombia, sede Bogotá.

## 0. Principios de diseño

1. **El registro oficial de la UNAL manda.** Nombre, programa, fecha de grado y documento vienen de los registros académicos (SIA). LinkedIn nunca corrige el registro oficial: se compara contra él.
2. **Acceso legítimo.** Ningún proceso automático accede a LinkedIn. Los datos llegan porque el egresado los entrega o porque una persona los consulta manualmente, con un protocolo definido.
3. **Automatizar lo que no toca LinkedIn.** Validar, cruzar, puntuar, estandarizar, detectar duplicados y generar incidencias lo hacen procesos automáticos (los "bots"). Las decisiones dudosas las toma una persona.
4. **Minimización.** Solo se guarda lo que responde a una pregunta de análisis (sección 6).
5. **Nada se sobrescribe.** Cada dato nuevo queda registrado con su fuente y su fecha.
6. **Reproducible y sostenible**, como pide el enunciado. Todo proceso automático guarda su versión y sus parámetros, y cada muestra guarda su semilla aleatoria, de modo que cualquier resultado se puede volver a obtener. Los diccionarios de equivalencias crecen con cada validación, así que el trabajo manual baja con el tiempo.

## 1. Identificación de egresados

### 1.1 Población objetivo

Egresados de los programas de pregrado y posgrado de la Facultad de Ingeniería, sede Bogotá, según el registro oficial de grados.

- **El modelo de datos cubre los dos niveles desde el inicio.** Una persona puede tener varios grados, y el catálogo de programas incluye el nivel (pregrado, especialización, maestría, doctorado). Así no hay que rehacer tablas para ampliar el alcance, y se puede responder, por ejemplo, cuántos egresados de pregrado siguen un posgrado en la misma Facultad.
- **Pregrado y posgrado también se operan juntos.** El piloto toma Ingeniería de Sistemas y Computación con su maestría y su doctorado, y la ampliación incorpora cada programa con sus posgrados (`04_plan_implementacion.md`). Así, quien tiene los dos grados recibe una sola invitación, y desde el inicio se prueba el paso de pregrado a posgrado.
- **El catálogo incluye programas que ya no ofrecen admisión y nombres anteriores,** porque esos programas siguen teniendo egresados.
- **Las reglas que dependen del programa** (por ejemplo, la duración mínima que sirve para descartar casos imposibles) se guardan en el catálogo de programas, no en el código.
- **Quien se inscribe a grado entra al sistema antes de graduarse,** con su grado "en trámite". Es la lista de espera de los próximos egresados.

### 1.2 Canales de recolección

| Canal | Cuándo | Qué aporta el egresado | Quién accede a LinkedIn |
|---|---|---|---|
| **A. Autorización y carga en el grado** | Inscripción a grado / paz y salvo | Autorización de tratamiento, URL de su perfil y PDF de su perfil ("Guardar en PDF") | Nadie: el egresado descarga su propio perfil |
| **B. Actualización por el egresado** | En cada momento de seguimiento (1.5) | Confirmación de un clic ("sigo igual") o un PDF nuevo si hubo cambios | Nadie |
| **C. Consulta manual asistida** | Cohortes antiguas sin autorización ni URL | Nada: un auxiliar consulta perfiles públicos con protocolo y registra variables mínimas | Una persona, manualmente |

Fuentes complementarias, sin datos individuales de LinkedIn: Observatorio Laboral para la Educación (MinEducación), con datos agregados por programa, y las encuestas de egresados de la UNAL.

**Egresados sin LinkedIn.** En los canales A y B, "no tengo LinkedIn" es una respuesta válida, no un dato faltante. A quien la marque se le pide un formulario corto con su empleo actual (organización, cargo, ciudad, año y mes de inicio), registrado con la fuente "formulario directo".
- *Por qué:* si solo se midiera a quienes usan LinkedIn, los indicadores quedarían sesgados hacia los sectores donde LinkedIn es común. El enunciado admite fuentes complementarias "cuando corresponda".

**Situación laboral declarada.** El formulario de los canales A y B incluye una sola pregunta: situación actual (empleado, independiente, estudiando, buscando empleo, otra).
- *Por qué:* LinkedIn muestra los empleos, pero no muestra el desempleo. Un perfil sin empleo actual puede ser de alguien sin trabajo o de alguien que no actualiza. Sin esta pregunta, la tasa de vinculación no se puede interpretar.

**¿Por qué el bot no obtiene los datos a partir de la URL, si el egresado dio permiso?**

- Las descargas de datos de LinkedIn ("Guardar en PDF" o "Descargar mis datos") solo las puede hacer el titular de la cuenta con su sesión iniciada. La URL pública del perfil no da acceso a ellas.
- Abrir la URL con un programa es acceso automatizado. El Acuerdo de usuario de LinkedIn (sección 8.2) prohíbe usar software, scripts o robots para acceder a perfiles o copiarlos. La autorización que el egresado da a la UNAL no modifica ese contrato entre LinkedIn y la cuenta que accede.
- LinkedIn ofrece una API oficial de portabilidad (*Member Data Portability*), pero solo para miembros ubicados en la UE/EEE y Suiza (exigencia de la Ley de Mercados Digitales europea). No aplica a la mayoría de egresados.
- Pedirle al egresado su usuario y contraseña de LinkedIn queda descartado: viola las condiciones de LinkedIn y es una mala práctica de seguridad.

Por eso el diseño ataca el problema real, que es el **cansancio del egresado**, y no intenta saltarse la plataforma (ver 1.5).

**Cómo entrega el egresado sus datos: el PDF del perfil.** En su propio perfil, el egresado da clic en **Más → Guardar en PDF** y LinkedIn descarga el archivo al instante. Luego lo sube al formulario de la Facultad. Todo ocurre en una sola sesión de pocos minutos.

**Por qué el PDF y no la descarga de datos en CSV.** LinkedIn también ofrece "Descargar mis datos", con archivos CSV más estructurados, pero no son inmediatos: el egresado tiene que pedirlos, esperar un correo (de minutos a 48 horas) y volver para subirlos. Cada paso de más hace que una parte de los egresados abandone o ignore el correo. Se prefiere un dato un poco menos estructurado que llegue, a uno mejor estructurado que no llegue.

**Qué trae el PDF y qué se hace con cada parte** (según un perfil de prueba, octubre de 2026):

| Sección del PDF | Se guarda | Uso |
|---|---|---|
| Experiencia: empresa, cargo, fechas (mes y año), ciudad | Sí | Experiencia laboral, con códigos de ocupación (CUOC), actividad económica (CIIU) y ubicación (DIVIPOLA) |
| Educación: institución, programa, años | Sí | Cruce con el registro oficial y formación posterior |
| URL del perfil | Solo para verificar | Se compara con la URL registrada en el formulario |
| Correo, titular, certificaciones, aptitudes, extracto | No | Se descartan al leer el PDF (minimización) |

El PDF se borra cuando su captura queda verificada (sección 5, conservación limitada).

**Lo que el lector del PDF debe manejar:**

- **Dos columnas:** al extraer el texto se mezclan, así que se separan por posición en la página antes de buscar las secciones.
- **Idioma:** los títulos y fechas salen en el idioma del perfil ("Experiencia" o "Experience") y a veces mezclados ("octubre de 2026 - Present").
- **Varios cargos en una misma empresa:** LinkedIn los agrupa bajo un solo nombre de empresa.
- Lo que el lector no logre interpretar va a revisión humana; nunca entra a la base sin revisar.

### 1.3 Verificación: los dos bots

Los dos bots usan el **mismo motor de cruce**. Cambian el origen de los datos y el uso del puntaje.

**Identificar una vez, capturar muchas veces.** Que un perfil pertenece a un egresado se decide una sola vez. En las capturas siguientes del mismo perfil, el bot 1 solo comprueba que la URL del PDF sea la del perfil ya aceptado. Si el egresado cambió su URL personalizada, se abre una incidencia y el revisor actualiza el perfil.

**Bot 1 – Consolidación (canales A y B).** Recibe el formulario y el PDF del perfil.
1. Valida el formato de la URL (`linkedin.com/in/<identificador>`) y comprueba que **la URL impresa en el PDF sea la misma que la del formulario**. Si no coincide, alguien subió el perfil de otra persona y el caso va a revisión.
2. Comprueba que el mismo archivo no se haya subido antes (por su huella).
3. Extrae experiencia y educación, y descarta el resto del PDF.
4. En la primera captura, comprueba la coherencia con el registro oficial: que los estudios declarados incluyan a la UNAL, el programa (por catálogo de equivalencias, porque el egresado escribe el nombre a su manera) y un año de grado compatible. Aquí el puntaje **no identifica a la persona** (ya se identificó en el grado). Detecta errores.
5. Estandariza cargos, organizaciones y ubicaciones (3.1).
6. Carga la información como una nueva captura y abre incidencias de calidad cuando haga falta.

**Bot 2 – Verificación (canal C).** El auxiliar busca el perfil y registra en un formulario los datos mínimos del candidato: nombre visible, estudios con años, ciudad y URL. El bot:
1. Comprueba que ni el egresado ni el perfil estén en la lista de no contactar.
2. Calcula el puntaje de confianza contra el registro oficial.
3. Clasifica el candidato en alto, medio o bajo.
4. Descarta los casos imposibles y deja el motivo registrado.
5. Pone en cola de revisión humana los casos de nivel medio.

El bot **no busca ni extrae nada**: decide sobre lo que el auxiliar encontró.

**Cada búsqueda queda registrada, también las que no encuentran a nadie.** "Se buscó y no se encontró" es información distinta de "no se buscó": la tasa de no encontrados por estrato mide el sesgo de la muestra.

**Antes del canal C:** a las cohortes antiguas con correo conocido se les envía una invitación a usar el canal B. La búsqueda manual se reserva para quienes no respondan.

### 1.4 Puntaje de confianza

| Componente | Regla | Peso inicial |
|---|---|---|
| Nombre | Similitud entre nombres normalizados: minúsculas, sin tildes, sin partículas ("de", "del", "la"). Admite uno o dos apellidos | 0,50 |
| Programa | El programa declarado corresponde al programa oficial (por catálogo de equivalencias) | 0,25 |
| Año de grado | Coincide con el oficial, con tolerancia de ±1 año (en LinkedIn se suele poner el año de terminación de materias) | 0,15 |
| Ciudad | Coincide o es compatible | 0,10 |

- **Alto (≥ 0,85):** se acepta, con auditoría por muestreo.
- **Medio (0,60 – 0,85):** revisión humana.
- **Bajo (< 0,60):** se descarta y queda el motivo registrado.
- **Imposible:** descarte automático, por ejemplo si el año de grado menos el año de ingreso es menor que la duración mínima del programa.

Los pesos y umbrales son una **propuesta inicial** y se calibran con casos reales:
- Cada decisión se guarda por separado (la automática, la de la revisión humana y la de la auditoría), en vez de un solo campo que se sobrescribe. Así se puede medir cuántas veces la revisión contradice al nivel alto; si pasa con frecuencia, el umbral sube.
- Cada puntaje guarda el valor de cada componente y la ejecución que lo calculó, con la versión del algoritmo y los pesos vigentes. Así una decisión pasada se puede explicar y reproducir.
- Si un componente no se pudo observar (por ejemplo, el perfil no muestra la ciudad), cuenta como 0 en el total. Es un criterio conservador: con menos evidencia, el caso tiende a la revisión humana. Igual se guarda como "no observado" y no como 0, para no confundirlo con un dato que sí se observó y no coincide.

### 1.5 Momentos de seguimiento (contra el cansancio del egresado)

En lugar de pedir una actualización cada año, el seguimiento se hace en **momentos definidos**: M0 (grado), M1, M3 y M5 años después del grado, y luego cada 5 años. Los momentos se guardan como un catálogo, así que la Facultad puede cambiarlos sin modificar el código.

- Cada solicitud es de **un clic** si nada cambió: un enlace personal que confirma "sigo en el mismo cargo".
- El enlace lleva un código único que vence. En la base se guarda solo su huella, para que una copia de la base no permita usar los enlaces.
- Solo si hubo cambios se pide un PDF nuevo del perfil.
- La respuesta queda registrada en la solicitud. Así se mide la **tasa de respuesta por momento**, que es el indicador del cansancio.
- Los envíos se escalonan por lotes para no concentrar la carga de revisión.

### 1.6 Cobertura de cohortes antiguas: muestreo

No es viable ni necesario consultar a mano a todos los egresados antiguos. Para los indicadores de la Facultad basta una **muestra estratificada** por programa y cohorte. El tamaño por estrato para estimar una proporción es:

```
n0 = z² · p · (1 − p) / e²        (z = 1,96 al 95 %; p = 0,5; e = margen de error)
n  = n0 / (1 + (n0 − 1) / N)      (corrección por población finita, N = población del estrato)
```

- **La población de cada estrato (N) son quienes no respondieron a la invitación del canal B** (1.3). Quienes respondieron ya están medidos y pesan 1; la muestra representa al resto. Es el submuestreo de no respondientes de Hansen y Hurwitz (1946): una primera fase barata (el correo) y, para quienes no responden, una muestra con un método más costoso (la búsqueda manual).
- **El número de búsquedas es n dividido por la tasa de encontrados esperada,** con un máximo de N. Si se buscaran solo n, los no encontrados dejarían un margen peor que el planeado. Cuando el estrato es tan pequeño que habría que buscar a todos, se hace censo.
- El tamaño de cada muestra se ajusta a las horas del auxiliar con la regla de `04_plan_implementacion.md`, sección 5.
- Se registra el diseño de cada muestra (margen, nivel de confianza y la semilla aleatoria con que se seleccionó). Con la semilla se obtiene otra vez la misma selección.
- Se registran el estrato y el peso de cada egresado seleccionado. El peso (población del estrato ÷ seleccionados) es lo que convierte los resultados de la muestra en estimaciones de toda la cohorte. Al calcular los indicadores se ajusta por los no encontrados del estrato.

Cada indicador se publica junto con su cobertura, para dejar visible el sesgo (por ejemplo, que los recién egresados estén sobrerrepresentados).

## 2. Variables

La lista completa, con dominios, formatos, obligatoriedad y reglas de validación, está en `03_diccionario_datos.md`; las decisiones que la rigen, en `02_modelo_datos.md` (paso 2). Criterios acordados:

- **Del registro oficial:**
  - Identificación, en la base restringida. Puede haber varios documentos por persona (por ejemplo, tarjeta de identidad al ingresar y cédula al graduarse).
  - Programa, periodo de ingreso y fecha de grado.
  - **Sexo registrado.** *Por qué:* permite analizar brechas de género en vinculación y en cargos, una pregunta relevante para una facultad de ingeniería. Viene del registro académico, no se le pide al egresado, y no es dato sensible según la Ley 1581 (art. 5).
- **De LinkedIn o del formulario directo:**
  - Cargo (texto original y código de ocupación de la CUOC), organización (normalizada, con su actividad económica según la CIIU Rev. 4 A.C.) y ubicación (municipio según la DIVIPOLA, o país según ISO 3166-1).
  - Año y mes de inicio y de fin, y si es el empleo actual.
  - **Tipo de vínculo:** empleo, práctica, independiente o voluntariado. *Por qué:* una práctica o una pasantía no deben contar como primer empleo.
  - **Área de desempeño:** docencia, investigación, desarrollo, consultoría, gestión, operación, emprendimiento u otra. Complementa a la ocupación: la ocupación dice qué es el cargo; el área dice a qué se dedica la persona.
  - Estudios posteriores: institución, nivel, programa y años.
- **Del formulario:** situación laboral declarada (1.2).
- **Fechas:** año obligatorio y mes opcional. Nunca se inventa el día. Con el mes, el indicador "tiempo hasta el primer empleo" se calcula en meses; sin el mes, en años, y queda marcado con menor precisión.
- **No se guardan:** fotos, contactos, conexiones, publicaciones, recomendaciones, aptitudes, extracto ni texto libre completo del perfil. Tampoco edad ni fecha de nacimiento, que no responden ninguna pregunta de análisis.
- **Se consideró y se descartó la modalidad de admisión** (regular, PAES, PEAMA). Algunas modalidades del PAES están dirigidas a comunidades indígenas y a población afrocolombiana, palenquera y raizal, así que el dato podría revelar el origen racial o étnico. Ese es un dato sensible (Ley 1581, art. 5) y exige un tratamiento especial que este sistema no justifica.

## 3. Recolección y consolidación

- **Historial por capturas.** Cada PDF subido, cada formulario directo o cada consulta manual crea una **captura** con su fuente, fecha, canal y responsable. Las experiencias y estudios extraídos quedan asociados a esa captura.
  - Nada se sobrescribe ni se borra: un PDF nuevo crea una captura nueva.
  - El **estado actual** de un egresado es su última captura verificada. Los estados (vigente, desactualizado, pendiente) se calculan a partir de las fechas; no se guardan, para que no puedan contradecir los datos.
  - La confirmación de un clic ("sigo igual") no crea captura nueva: se registra como respuesta a la solicitud de actualización, apuntando a la captura que confirma.
  - **Por qué no la vigencia por fila:** obligaría a comparar fila por fila qué cambió entre dos PDF, y eso suma lógica y errores. Cada PDF ya es una foto completa del perfil en una fecha, y la captura la guarda tal cual.
  - **Por qué no el versionado automático de MariaDB** (`WITH SYSTEM VERSIONING`): registra cambios en la base, no la fuente de donde vino el dato. Se puede usar como complemento en los catálogos.
- **Duplicados:**
  - de persona: mismo documento (incluidos los documentos anteriores), o mismo nombre normalizado, programa y año;
  - de perfil: misma URL o misma huella asignada a dos egresados;
  - de captura: mismo archivo PDF (misma huella SHA-256);
  - de experiencia: misma organización, cargo y año dentro de una captura.
- **Estandarización con catálogos y diccionarios.** Cada catálogo oficial (programas, ocupaciones, sectores, ubicaciones) tiene un **diccionario de equivalencias** que traduce cómo escribe la gente ("Bogotá, Distrito Capital, Colombia", "Bancolombia S.A.") al código oficial. Las organizaciones se normalizan una sola vez, de modo que todas las experiencias en la misma organización compartan el mismo sector. El detalle está en `02_modelo_datos.md`, paso 1.

### 3.1 Clasificación: diccionario primero, IA local después

1. **Primero se consulta el diccionario.** Si el texto ya fue validado antes, recibe ese código. Para la actividad económica de una organización colombiana con NIT conocido, se toma la actividad que tiene registrada, en lugar de inferirla.
2. **La IA local (Ollama) solo clasifica los textos nuevos:** cargo → ocupación (CUOC), organización → actividad económica (CIIU Rev. 4 A.C.), ubicación → DIVIPOLA o ISO, y el área de desempeño. Se guardan el código que propone, su nivel de confianza y la ejecución (el modelo y su huella exacta).
3. **Lo dudoso va a revisión humana.** Se guardan el código propuesto y el final, para medir la precisión de la IA.
4. **Cuando una persona valida una clasificación, el par texto–código entra al diccionario,** y la próxima vez no se usa la IA.

- *Por qué el diccionario primero:* el mismo texto recibe siempre el mismo código, la clasificación es explicable, y la carga de IA y de revisión baja con el tiempo.
- *Por qué la IA no identifica personas:* identificar exige una regla explicable y auditable, que es el puntaje (1.4).
- *Por qué IA local:* el modelo corre en un equipo de la Facultad, así que los datos personales no salen a servicios de terceros.

## 4. Calidad y trazabilidad

Las dimensiones de calidad salen del principio de veracidad o calidad de la Ley 1581 (art. 4 lit. d): la información debe ser **veraz, completa, exacta, actualizada, comprobable y comprensible**.

| Tipo de incidencia | Dimensión | Cómo se detecta |
|---|---|---|
| Incompleta | Completa | Faltan campos obligatorios en la captura |
| Ambigua | Comprensible / exacta | Puntaje medio, clasificación de la IA con confianza baja, o texto que el lector del PDF no pudo interpretar |
| Desactualizada | Actualizada | La última verificación es anterior al momento de seguimiento que ya debió ocurrir |
| No verificable | Comprobable | El perfil no muestra formación en la UNAL, o la URL ya no existe |
| URL distinta | Veraz | La URL del PDF no coincide con la del perfil aceptado o la del formulario |
| Duplicada | Exacta | Reglas de la sección 3 |

- **Faltantes:** un campo vacío nunca debe ser ambiguo. "No tengo LinkedIn" o "sin empleo actual" son respuestas, no faltantes. Un dato que debía estar y no está genera una incidencia de tipo incompleta que indica el campo.
- Cada incidencia tiene estado (abierta, en revisión, resuelta, descartada), responsable y fecha. Su descripción no incluye valores de identidad (nombres, documentos, URL), para que la base de análisis no los contenga.
- **Trazabilidad:** cada dato apunta a su fuente (de qué canal vino), a la ejecución que lo produjo (qué proceso, con qué versión y parámetros) y al responsable que lo decidió o corrigió. Cada cambio queda en una bitácora. Hay una bitácora por base, porque la bitácora guarda valores anteriores y nuevos, y en la base de análisis filtraría la identidad.

## 5. Protección de datos personales

Marco: **Ley Estatutaria 1581 de 2012** y **Decreto 1377 de 2013**.

- **Principios aplicados (Ley 1581, art. 4):** finalidad (b), libertad (c), veracidad o calidad (d), acceso y circulación restringida (f), seguridad (g) y confidencialidad (h).
- **Base legal de cada canal.** Cada captura registra su fuente, y cada fuente tiene su base legal.
  - **Canales A y B: autorización del titular** (Ley 1581, art. 9). Se conserva la prueba: fecha, canal, versión del texto aceptado y evidencia (Decreto 1377, art. 8).
  - **Canal C: dato público.** La profesión u oficio es dato público (Decreto 1377, art. 3, num. 2), y los datos de naturaleza pública no requieren autorización (Ley 1581, art. 10 lit. b). Aun así, quien trata datos sin autorización debe cumplir la ley (Ley 1581, art. 10, último inciso). Por eso el canal C registra lo mínimo, invita al egresado a autorizar (canal B) y respeta la lista de no contactar. Para otros datos del perfil, como la organización o la ciudad, la calificación de dato público es menos clara: **se recomienda que la Oficina Jurídica de la UNAL valide esta base antes de operar el canal C.**
- **Revocatoria y supresión (Ley 1581, art. 8 lit. e; Decreto 1377, art. 9):** el egresado puede revocar la autorización o pedir la supresión en cualquier momento. La solicitud se atiende como reclamo: máximo 15 días hábiles, prorrogables hasta 8 más informándole los motivos (Ley 1581, art. 15). Si no se atiende, el titular puede pedir a la Superintendencia de Industria y Comercio que ordene la revocatoria (Decreto 1377, art. 9). El procedimiento es el siguiente:

  1. **Se deja de tratar de inmediato:** no se le envían más solicitudes y sale de todo análisis nuevo.
  2. **Se borran todos sus datos individuales:** identidad, documentos, perfiles de LinkedIn, coincidencias, capturas, experiencias, estudios declarados, solicitudes, incidencias y su rastro en las bitácoras.
     - *Por qué borrar y no solo marcar como inactivo:* una marca de "borrado" conserva los datos, y eso no es supresión.
     - *Por qué borrar todo y no solo la identidad:* sin la identidad los datos quedan seudonimizados, no anónimos. En cohortes pequeñas, programa + año + empresa + cargo + ciudad puede bastar para saber quién es.
  3. **Se conserva:**
     - **Los indicadores ya publicados.** Son agregados que no identifican a nadie (por la regla de celda mínima, sección 6) y no se recalculan hacia atrás.
     - **La constancia de la revocatoria** (fecha, canal y fecha de atención), para demostrar el cumplimiento.
     - **Una lista de no contactar** con huellas de todos sus documentos, sus URL y sus correos, calculadas con HMAC-SHA256 y una clave secreta guardada fuera de la base. Las calcula el programa que tiene la clave; la base nunca la ve. Sirve para que el canal C no lo vuelva a incluir sin autorización.
       - *Por qué una huella y no el documento:* no se puede revertir para saber quién es.
       - *Por qué HMAC con clave y no un SHA-256 simple:* los números de documento son pocos y predecibles. Quien tenga la base podría calcular el hash de todos los números posibles y encontrar el que coincide; sin la clave, no puede.
       - *Por qué todas las huellas y no solo la del documento actual:* una persona puede tener varios documentos y perfiles, y el canal C podría volver a encontrarla por cualquiera de ellos.
  4. **No se toca el registro académico oficial** (grado, programa, fecha). La UNAL lo conserva por otra obligación legal y este sistema solo borra su copia. Por la misma razón, la supresión no procede para datos que el titular tenga el deber legal o contractual de mantener (Decreto 1377, art. 9).

  **En la base de datos:** todo el procedimiento es una sola transacción: o se hace completo o no se hace nada. Las tablas de la persona tienen llaves foráneas con borrado en cascada, de modo que borrar al egresado borra todo lo que depende de él en las dos bases, sin dejar registros huérfanos. Los perfiles se borran explícitamente en el mismo procedimiento, porque un perfil no depende de un egresado (puede ser solo un candidato). Los catálogos nunca se borran. La constancia y la lista de no contactar viven en `egresados_identidad`.
- **Conservación limitada (Decreto 1377, art. 11):** los datos se conservan solo el tiempo razonable y necesario para la finalidad.
  - El PDF se borra cuando su captura queda verificada o rechazada; se conserva su huella SHA-256 como prueba de qué archivo se procesó. Aquí basta un SHA-256 simple porque un PDF no se puede adivinar, a diferencia de un número de documento.
  - Los datos observados de cada candidato del canal C (nombre visible, programa, años, ciudad) se borran cuando se cierra su decisión, porque ya cumplieron su función; quedan los puntajes. Si el candidato se descartó (es otra persona), también se borra su URL y queda solo la huella HMAC, para no volver a procesar ese perfil.
  - Un proceso periódico de depuración aplica estas reglas y queda registrado.
  - La bitácora no copia la URL ni los datos observados: registra que cambiaron, sin el valor. Si los copiara, el borrado no borraría nada.
- **Datos sensibles:** no se tratan (Ley 1581, art. 5). Por eso se descartó la modalidad de admisión (sección 2).
- **Seudonimización en dos bases de datos:**
  - `egresados_identidad`: nombres, documentos, correos, perfiles de LinkedIn, coincidencias con los datos observados de cada candidato, autorizaciones, supresiones y su propia bitácora. Solo pueden leerla los responsables del cruce y de atender las solicitudes de los titulares.
  - `egresados`: datos académicos, capturas, experiencias, catálogos, seguimiento y calidad. Se identifica a cada persona con un ID interno sin significado.
  - El rol de analista no tiene ningún permiso sobre `egresados_identidad`, así que no puede ver quién es quién, ni por error ni a propósito.
  - Los respaldos de identidad se guardan aparte y con más protección.
  - Una revocatoria se atiende sabiendo exactamente dónde está cada dato personal.
- **Responsabilidad demostrada (Decreto 1377, art. 26):** el responsable debe poder demostrar ante la Superintendencia de Industria y Comercio que aplica medidas apropiadas y efectivas. Las autorizaciones con su evidencia, las decisiones registradas, las bitácoras y las constancias de supresión son esa demostración.
- **Acceso legítimo:** sin raspado (sección 1.2).

## 6. Análisis

Preguntas que la Facultad podría responder, por programa y cohorte:

1. **Vinculación:** ¿qué porcentaje de egresados está vinculado laboralmente en cada momento de seguimiento? Se mide como vínculo declarado (en LinkedIn o en el formulario), junto con la situación laboral declarada, porque la ausencia de un empleo en LinkedIn no distingue el desempleo de un perfil desactualizado.
2. **Sectores y ocupaciones:** ¿en qué sectores (CIIU) y ocupaciones (CUOC) trabajan?
3. **Inserción:** ¿cuánto tardan en conseguir el primer empleo después del grado? Se excluyen prácticas y voluntariados.
4. **Pertinencia:** ¿qué porcentaje trabaja en el área de su formación? Se usa la lista de ocupaciones afines que define cada comité de programa.
5. **Movilidad:** ¿dónde trabajan: Bogotá, otras ciudades o el exterior?
6. **Formación posterior:** ¿qué porcentaje hace un posgrado, y dónde?
7. **Evolución de la trayectoria** (el enunciado pide comprender la "inserción y evolución"): ¿qué porcentaje llega a cargos directivos (gran grupo 1 de la CUOC, "directores y gerentes") a los 5 y a los 10 años? ¿Cuántos cambian de sector?
8. **Brechas:** las preguntas anteriores comparadas por sexo.
9. **Del propio sistema:** cobertura por cohorte, tasa de respuesta por momento de seguimiento, precisión del nivel alto según las auditorías, no encontrados por estrato y porcentaje de perfiles desactualizados.

**Reglas para publicar:**

- **Celda mínima:** no se publica ningún indicador calculado sobre menos de 5 personas (umbral ajustable por la Facultad). *Por qué:* que un agregado "no identifica a nadie" solo es cierto si el grupo es suficientemente grande. Un porcentaje calculado sobre las 2 egresadas de una cohorte pequeña las identifica.
- **Cobertura visible:** cada indicador se publica con su cobertura y, si sale de una muestra, con su margen de error.
- **Contraste con fuentes oficiales:** los resultados se comparan con indicadores agregados que publiquen fuentes oficiales por programa (por ejemplo, el Observatorio Laboral), para estimar el sesgo de medir con LinkedIn.

## 7. Implementación

Se desarrolla en `04_plan_implementacion.md`: actividades, responsables, recursos, cronograma y mecanismo de actualización periódica. En resumen:

- **Seis fases:** acuerdos, construcción, piloto, evaluación, ampliación y operación periódica, con la operación completa desde el mes 19.
- **Piloto de un semestre con Ingeniería de Sistemas y Computación y sus posgrados,** para calibrar el puntaje y medir los tiempos reales antes de ampliar.
- **Capacidad:** con 12 horas semanales del auxiliar, el piloto cabe en un semestre. Para la Facultad completa, el canal C rota tres programas por año, y los canales A y B cubren a todos cada año.
- **Actualización periódica:** envíos semanales del canal B en el aniversario del grado (momentos de seguimiento, sección 1.5), depuración mensual, calibración trimestral y una muestra anual del canal C, con indicadores que muestran si el proceso funciona.

---

## Registro de decisiones

Cada decisión con la alternativa que se descartó y el motivo.

| # | Se eligió | En vez de | Por qué |
|---|---|---|---|
| 1 | Registro oficial de la UNAL como fuente de verdad | Datos de LinkedIn como referencia | LinkedIn es autodeclarado y puede estar incompleto o equivocado. El registro académico es oficial; LinkedIn se compara contra él, nunca lo corrige |
| 2 | Ningún proceso automático accede a LinkedIn | Un bot que abra las URL autorizadas | El Acuerdo de usuario de LinkedIn (8.2) prohíbe el acceso automatizado. La autorización del egresado a la UNAL no cambia ese contrato, y la cuenta usada sería bloqueada |
| 3 | PDF del perfil ("Guardar en PDF") | CSV de "Descargar mis datos" | El PDF es inmediato y se sube en la misma sesión. El CSV es más estructurado, pero llega por correo (de minutos a 48 horas) y exige volver; cada paso extra hace que parte de los egresados abandone. Además, el PDF trae la URL del perfil, que sirve como control de identidad |
| 4 | Un motor de cruce para dos bots | Dos programas distintos | La regla de comparación es la misma; solo cambian los umbrales y el origen del dato. Un solo motor evita que las dos versiones den resultados distintos para el mismo caso |
| 5 | El auxiliar busca y el bot 2 clasifica | Un bot que busque y clasifique | Buscar en LinkedIn de forma automática es acceso automatizado (decisión 2). La parte repetitiva y propensa a error, que es comparar y puntuar, sí se automatiza |
| 6 | Puntaje ponderado con tres niveles | Coincidencia exacta de nombre | En LinkedIn la gente usa un apellido, omite tildes o abrevia. La coincidencia exacta perdería egresados reales; el puntaje permite aceptar, revisar o descartar con criterio |
| 7 | Tolerancia de ±1 año en el año de grado | Exigir el año exacto | En LinkedIn se suele poner el año de terminación de materias o el esperado, no el de la ceremonia |
| 8 | Momentos de seguimiento (M0, M1, M3, M5) con confirmación de un clic | Pedir actualización cada año | Menos solicitudes significan menos cansancio y más respuestas. Además, los cambios laborales relevantes se concentran en los primeros años |
| 9 | Muestra estratificada para cohortes antiguas | Consulta manual de todos | La consulta manual total no es viable para un auxiliar. Una muestra bien diseñada estima los indicadores con un margen de error conocido |
| 10 | IA local (Ollama) | Un servicio de IA en la nube | Los datos personales no salen a un tercero, sin contratos de transferencia ni riesgos de circulación (Ley 1581, art. 4 lit. f) |
| 11 | La IA solo estandariza (ocupación, actividad económica, ubicación y área) | Usar la IA para identificar personas | Identificar exige una regla explicable y auditable, y eso es el puntaje. Un modelo de lenguaje no da un motivo verificable de por qué dos registros son la misma persona |
| 12 | Catálogos oficiales del DANE (CUOC, CIIU Rev. 4 A.C., DIVIPOLA) | Categorías propias | Permiten comparar con estadísticas nacionales y con el Observatorio Laboral, y no dependen del criterio de quien clasifica |
| 13 | Año obligatorio y mes opcional | Solo año, o fecha completa | Solo con el año, "tiempo hasta el primer empleo" pierde precisión. La fecha completa obligaría a inventar el día, que LinkedIn no muestra |
| 14 | Historial por capturas | Vigencia por fila, o versionado automático de MariaDB | Cada PDF es una foto completa del perfil y la captura la guarda tal cual. La vigencia por fila exige comparar fila por fila qué cambió. El versionado de MariaDB registra cambios en la base, no la fuente del dato |
| 15 | Dos bases de datos (identidad y análisis) | Una base con permisos por tabla | Los permisos se dan por base completa y el analista no puede ver la identidad ni por error. Con una sola base, un `GRANT` mal puesto expone todo |
| 16 | Pregrado y posgrado en el modelo y en la operación, desde el piloto | Solo pregrado, o el posgrado en una fase posterior | Ampliar después obligaría a rehacer tablas y a contactar dos veces a quien tiene los dos grados. Con los dos niveles juntos se puede ver, por ejemplo, quién sigue un posgrado en la misma Facultad |
| 17 | Borrar todos los datos individuales al revocar | Borrar solo la identidad, o marcar como inactivo | Sin la identidad los datos quedan seudonimizados, no anónimos, y se puede reidentificar a la persona. Una marca conserva los datos y no es supresión |
| 18 | HMAC-SHA256 con clave secreta en la lista de no contactar | SHA-256 simple, o guardar el documento | Los números de documento son predecibles: un hash simple se revierte probando todos. El documento en claro contradice la revocatoria |
| 19 | MariaDB | SQLite, PostgreSQL o Excel | Es el motor que usa la dependencia. Frente a SQLite, es multiusuario y tiene roles y permisos. Frente a Excel, garantiza integridad con llaves y restricciones |
| 20 | MariaDB 12.3 LTS | MariaDB 13.0 (la más nueva) | La 13.0 es de ciclo corto y pierde soporte a finales de 2026. La 12.3 tiene soporte hasta 2029 |
| 21 | Configuración de MariaDB: InnoDB, `utf8mb4`, intercalación en español, modo estricto, roles por función | Otros motores, juegos de caracteres e intercalaciones; permisos por usuario | Detalle y pruebas en `02_modelo_datos.md`, paso 0 |
| 22 | Documentación en Markdown en el repositorio | Word o PDF | Markdown se versiona con Git, se ve directo en GitHub y permite revisar los cambios línea por línea. El enunciado pide publicar la propuesta en GitHub (punto 3.3), así que el repositorio es el documento y no hace falta una copia en otro formato |
| 23 | Identificar una vez y capturar muchas veces | Repetir el cruce en cada captura | La identidad no cambia; repetir el cruce en cada PDF solo agrega trabajo de revisión. En las capturas siguientes basta comprobar la URL |
| 24 | Cada decisión sobre una coincidencia como registro aparte | Un campo de decisión que se sobrescribe | Para calibrar los umbrales hay que comparar la decisión del bot con la de la revisión humana en el mismo caso |
| 25 | Diccionario de equivalencias antes que la IA | Clasificar todo con IA cada vez | El mismo texto recibe siempre el mismo código, la clasificación es explicable y la carga de IA y de revisión baja con el tiempo |
| 26 | Registrar también las búsquedas que no encuentran a nadie | Registrar solo lo encontrado | "No encontrado" es información: mide el sesgo de la muestra y separa lo que no se buscó de lo que no se encontró |
| 27 | Formulario directo para quien no tiene LinkedIn | Medir solo a quienes tienen LinkedIn | Evita sesgar los indicadores hacia los sectores donde LinkedIn es común |
| 28 | Preguntar la situación laboral en el formulario | Inferirla del perfil | LinkedIn no muestra el desempleo; sin la pregunta, la tasa de vinculación no se puede interpretar |
| 29 | Sexo registrado como variable de análisis | No incluirlo | Permite analizar brechas de género. Viene del registro oficial y no es dato sensible (Ley 1581, art. 5). Se publica con regla de celda mínima |
| 30 | Excluir la modalidad de admisión | Incluirla para analizar equidad | Algunas modalidades revelan el origen étnico, que es dato sensible (Ley 1581, art. 5) |
| 31 | Borrar el PDF al verificar la captura y conservar su huella SHA-256 | Guardar el PDF indefinidamente | El PDF trae datos que se decidió no guardar (correo, aptitudes) y la ley limita el tiempo de conservación (Decreto 1377, art. 11). La huella detecta archivos repetidos y prueba qué se procesó |
| 32 | Canal C con base en dato público, validado por la Oficina Jurídica | Exigir autorización para todo, o no documentar la base legal | Exigir autorización dejaría sin datos a las cohortes antiguas. No documentar la base legal impediría demostrar el cumplimiento (Decreto 1377, art. 26) |
| 33 | Regla de celda mínima para publicar | Publicar cualquier cruce | Un indicador sobre muy pocas personas las identifica |
| 34 | Muestra con semilla y pesos registrados | Selección sin registrar | Sin la semilla no se puede repetir la selección; sin los pesos no se puede estimar la cohorte |
| 35 | Decisiones del modelo conceptual | Alternativas de modelado | Detalle en `02_modelo_datos.md`, paso 1, sección 1.13 |
| 36 | Ocupaciones con la CUOC (DANE, actualización 2025) | CIUO-08 A.C. | Es el referente oficial para las ocupaciones del mercado laboral colombiano (Decreto 654 de 2021). Se construye sobre la CIUO-08, así que conserva la comparación internacional en los niveles superiores, y agrega un quinto nivel que distingue mejor los cargos |
| 37 | Decisiones del modelo lógico | Alternativas de modelado | Detalle en `02_modelo_datos.md`, paso 2, sección 2.9 |
| 38 | Decisiones del modelo físico | Alternativas de tipos y mecanismos | Detalle, con las pruebas hechas en el servidor, en `02_modelo_datos.md`, paso 3 (secciones 3.1 y 3.11) |
| 39 | Decisiones del plan de implementación | Alternativas de operación | Detalle en `04_plan_implementacion.md`, sección 10 |

## Pendientes

1. Probar el lector del PDF con un perfil que tenga varios cargos en una misma empresa (actividad 1.5 del plan de implementación).

**Para validar con la Facultad** (no bloquean el diseño):

2. Base legal del canal C, con la Oficina Jurídica de la UNAL (actividad 0.3 del plan).
3. Ocupaciones afines a cada programa, con cada comité asesor (actividades 0.7 y 4.2).
4. Umbral de celda mínima para publicar (actividad 0.1).

## Fuentes verificadas

| Dato | Fuente | Estado |
|---|---|---|
| Principios, datos sensibles, derechos, autorización y casos sin autorización | Ley 1581 de 2012, arts. 4, 5, 8, 9 y 10 | Verificado (texto en el Régimen Legal de Bogotá) |
| Dimensiones de calidad: veraz, completa, exacta, actualizada, comprobable y comprensible | Ley 1581 de 2012, art. 4 lit. d | Verificado (texto en el Régimen Legal de Bogotá) |
| Plazo de reclamos: 15 días hábiles + 8 de prórroga | Ley 1581 de 2012, art. 15 | Verificado (texto en el Régimen Legal de Bogotá) |
| La profesión u oficio es dato público | Decreto 1377 de 2013, art. 3, num. 2 | Verificado (texto en el Régimen Legal de Bogotá) |
| Prueba de la autorización | Decreto 1377 de 2013, art. 8 | Verificado (texto en el Régimen Legal de Bogotá) |
| Revocatoria y supresión; excepción por deber legal o contractual; orden de la SIC | Decreto 1377 de 2013, art. 9 | Verificado (texto en el Régimen Legal de Bogotá) |
| Conservación limitada: tiempo razonable y necesario | Decreto 1377 de 2013, art. 11 | Verificado (texto en el Régimen Legal de Bogotá) |
| Responsabilidad demostrada | Decreto 1377 de 2013, art. 26 (capítulo VI) | Verificado (texto en el Régimen Legal de Bogotá) |
| Compilación en el Decreto 1074 de 2015 | Decreto Único Reglamentario 1074 de 2015 | Por verificar el artículo exacto |
| Modalidades del PAES (comunidades indígenas; población afrocolombiana, palenquera y raizal) | Dirección de Bienestar UNAL, Programas de Admisión Especial | Verificado |
| Prohibición de bots y raspado | Acuerdo de usuario de LinkedIn, sección 8.2 | Verificado en la ayuda de LinkedIn; citar el texto vigente |
| API de portabilidad solo para UE/EEE y Suiza | Ayuda de LinkedIn y Microsoft Learn (DMA) | Verificado |
| Tiempos de "Descargar mis datos" (CSV) | Ayuda de LinkedIn, "Descargar tus datos" | Verificado (motivo para descartar el CSV) |
| Contenido de "Guardar en PDF" | Perfil de prueba, octubre de 2026 | Verificado |
| Programas de la Facultad: 9 pregrados, 4 especializaciones, 16 maestrías y 8 doctorados | Página de programas académicos de la Facultad | Verificado en la página; faltan códigos SNIES y duraciones (SNIES y la Secretaría de Facultad) |
| CUOC: adoptada por el Decreto 654 de 2021 y la Resolución 771 de 2021; actualización 2025 (Resolución 1241 de 2025); cinco niveles: 10 grandes grupos, 43 subgrupos principales, 136 subgrupos, 452 grupos primarios y 680 ocupaciones | Página de la CUOC en el sitio del DANE | Verificado. Confirmar los dígitos de cada nivel con el archivo de estructura al cargar el catálogo |
| CIIU Rev. 4 A.C. (2022) es la versión vigente; 21 secciones identificadas con letras; la CIIU Rev. 5 está en adaptación | Documento oficial del DANE | Verificado. Confirmar los conteos con la estructura detallada al cargar el catálogo |
| DIVIPOLA: departamento de 2 dígitos, municipio de 5 dígitos (departamento + 3) y centro poblado de 8 | Página de la DIVIPOLA en el sitio del DANE y fuentes secundarias | Verificado. Confirmar con el archivo del DANE al cargar el catálogo |
| Submuestreo de no respondientes | Hansen, M. H. y Hurwitz, W. N. (1946). The problem of non-response in sample surveys. *Journal of the American Statistical Association*, 41(236), 517–529 | Verificado |
| Comportamiento de MariaDB 12.3.3: llaves foráneas entre bases, `CHECK` sin fecha actual, `UNIQUE` sobre columnas calculadas, conversiones de tipos | Pruebas en el servidor, 29 de octubre de 2026 | Verificado (`02_modelo_datos.md`, paso 3.1) |
| En un disparador, `CURRENT_USER()` devuelve la cuenta dueña; los borrados en cascada no activan disparadores; `REGEXP` distingue mayúsculas según la intercalación | Documentación de MariaDB | Verificado |
