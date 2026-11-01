# Diccionario de datos

> **Estado:** completo, para revisión. Atributos y reglas del modelo lógico (paso 2) y tipos de MariaDB del modelo físico (paso 3).
> Las decisiones que rigen este diccionario están en [`02_modelo_datos.md`](02_modelo_datos.md), pasos 2 y 3. La implementación está en [`sql/03_tablas.sql`](../sql/03_tablas.sql), y cada restricción lleva el nombre de su tabla y su regla.

**Cómo leer las tablas**

| Columna | Significado |
|---|---|
| Atributo | Nombre de la columna |
| Descripción | Qué guarda |
| Dominio | Tipo lógico, con su formato, su tipo en MariaDB y su validación (sección 1) |
| Oblig. | **Sí**: no puede quedar vacío. **No**: puede quedar vacío, y la última columna dice qué significa el vacío. **—**: columna calculada, no se escribe |
| Llave | **PK**: llave primaria. **FK → tabla**: llave foránea. **UQ**: valor único. **UQ1**, **FK1** o **FK2**: la regla aplica a varias columnas juntas (las que llevan la misma marca) |
| Reglas | Validación, valores permitidos y significado del vacío |

En las llaves foráneas, **Cascada** significa que el registro se borra si se borra el referenciado, y **Restringida**, que el borrado del referenciado se impide.

## 1. Dominios

| Dominio | Qué representa | Formato | Tipo en MariaDB | Validación física |
|---|---|---|---|---|
| `ID` | Identificador interno sin significado | Entero positivo | `INT UNSIGNED`; con `AUTO_INCREMENT` en la llave primaria | Lo asigna la base |
| `CODIGO` | Código de un catálogo propio | Mayúsculas, dígitos y guion bajo; de 1 a 30 caracteres | `VARCHAR(30)` exacto | `REGEXP '^[A-Z0-9_]{1,30}$'` |
| `COD_OCUPACION` | Código de la CUOC | De 1 a 5 dígitos, según el nivel | `VARCHAR(5)` exacto | `REGEXP '^[0-9]{1,5}$'` |
| `COD_ACTIVIDAD` | Código de la CIIU Rev. 4 A.C. | Una letra (sección) o de 2 a 4 dígitos | `VARCHAR(4)` exacto | `REGEXP '^([A-U]\|[0-9]{2,4})$'` |
| `COD_UBICACION` | País (ISO 3166-1 alfa-2) o código DIVIPOLA | 2 letras (país), 2 dígitos (departamento) o 5 dígitos (municipio) | `VARCHAR(5)` exacto | `REGEXP '^([A-Z]{2}\|[0-9]{2}\|[0-9]{5})$'` |
| `LISTA` | Uno de los valores enumerados en la columna Reglas | Mayúsculas y guion bajo | `VARCHAR(n)` exacto, con `n` = largo del valor más largo | `IN (...)` con los valores de la lista |
| `HUELLA` | Resultado de SHA-256 o de HMAC-SHA256 | 64 caracteres hexadecimales en minúsculas | `CHAR(64)` exacto | `REGEXP '^[0-9a-f]{64}$'` |
| `URL_PERFIL` | URL de un perfil de LinkedIn | `https://www.linkedin.com/in/<identificador>`, en minúsculas, sin parámetros ni barra final. Las variantes de país (`co.linkedin.com`) se convierten a `www` | `VARCHAR(128)` exacto | `REGEXP '^https://www\\.linkedin\\.com/in/[a-z0-9%_-]{3,100}$'` |
| `NUM_DOCUMENTO` | Número de un documento de identidad | Letras mayúsculas y dígitos, sin puntos, guiones ni espacios | `VARCHAR(20)` exacto | `REGEXP '^[A-Z0-9]{3,20}$'` |
| `NIT` | NIT de una organización colombiana | Solo dígitos, sin dígito de verificación | `VARCHAR(10)` exacto | `REGEXP '^[0-9]{6,10}$'` |
| `VERSION` | Versión de un programa, protocolo o texto | `mayor.menor.parche`, por ejemplo `1.2.0` | `VARCHAR(20)` exacto | `REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+$'` |
| `CORREO` | Correo electrónico | `usuario@dominio`, en minúsculas, hasta 254 caracteres | `VARCHAR(254)` en `utf8mb4_bin` | `REGEXP '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$'` y `x = LOWER(x)` |
| `USUARIO_BD` | Usuario de MariaDB | Solo el nombre de usuario, sin el equipo | `VARCHAR(128)` en `utf8mb4_bin` | `x <> ''` |
| `TEXTO` | Texto corto | Hasta 300 caracteres | `VARCHAR(300)` en español | `x <> '' AND CHAR_LENGTH(x) = CHAR_LENGTH(TRIM(x))`: no vacío y sin espacios al inicio ni al final |
| `TEXTO_NORMALIZADO` | Texto preparado para comparar | Minúsculas; sin tildes ni diéresis, pero conserva la ñ (igual que la intercalación, paso 0); sin signos de puntuación; un solo espacio entre palabras | `VARCHAR(300)` en español | `REGEXP '(?-i)^[a-z0-9ñ]+( [a-z0-9ñ]+)*$'` |
| `TEXTO_LARGO` | Texto extenso, como un texto legal | Hasta 20 000 caracteres | `TEXT` en español | `x <> '' AND CHAR_LENGTH(x) <= 20000` |
| `DESCRIPCION` | Texto libre | Hasta 1000 caracteres | `VARCHAR(1000)` en español | `x <> ''`. En la base `egresados`, sin valores de identidad: es una regla de uso, que no se puede validar en la base |
| `ANIO` | Año | Entero de 4 dígitos | `SMALLINT` | `BETWEEN 1940 AND 2100`. Cada atributo dice si puede ser posterior al año actual; esa regla va en un disparador (paso 3.5) |
| `MES` | Mes | Entero | `TINYINT` | `BETWEEN 1 AND 12` |
| `SEMESTRE` | Semestre académico | Entero | `TINYINT` | `IN (1, 2)` |
| `ENTERO` | Cantidad | Entero | `INT` | `>= 0` |
| `FECHA` | Fecha | `AAAA-MM-DD` | `DATE` | La valida el tipo |
| `FECHA_HORA` | Fecha y hora | `AAAA-MM-DD hh:mm:ss`, hora de Colombia | `DATETIME` | La valida el tipo |
| `BOOLEANO` | Sí o no | 1 (sí) o 0 (no) | `TINYINT` | `IN (0, 1)` |
| `PROPORCION` | Valor entre 0 y 1: puntajes, confianzas, márgenes | 3 decimales | `DECIMAL(4,3)` | `BETWEEN 0 AND 1` |
| `PESO` | Peso muestral | 4 decimales | `DECIMAL(12,4)` | `>= 1` |
| `DECIMAL` | Valor numérico de un indicador | Hasta 4 decimales | `DECIMAL(18,4)` | — |
| `JSON` | Documento JSON | JSON | `JSON` | MariaDB agrega sola la validación `json_valid` (paso 3, prueba T5) |

- **"Exacto"** significa `CHARACTER SET ascii COLLATE ascii_bin`: comparación byte a byte, que distingue mayúsculas (paso 3.2). **"En español"** significa la intercalación de la base, `utf8mb4_uca1400_spanish_ai_ci`.
- Las expresiones regulares están escritas tal como van en SQL: la barra invertida se duplica porque MariaDB la usa como escape dentro de las cadenas. Si se escribiera `'\.'`, MariaDB lo leería como `'.'`, que en una expresión regular significa "cualquier carácter".

## 2. Patrones comunes

### 2.1 Diccionarios de equivalencias

Las cuatro tablas de alias tienen la misma estructura. Solo cambia el destino.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_<tabla>` | Identificador | `ID` | Sí | PK | |
| `texto_normalizado` | Texto como lo escribe la gente, normalizado | `TEXTO_NORMALIZADO` | Sí | UQ | Un texto equivale a un solo valor. Los textos ambiguos (por ejemplo, el cargo "analista") no entran: se clasifican caso por caso |
| destino | Valor al que equivale | El del catálogo | Sí | FK → catálogo | Restringida |
| `origen` | De dónde salió la equivalencia | `LISTA` | Sí | | `OFICIAL` (nombre oficial o anterior), `VALIDADO` (validado por una persona) |
| `id_responsable` | Quién la agregó | `ID` | Sí | FK → `responsable` | Restringida |
| `fecha_hora_validacion` | Cuándo se agregó | `FECHA_HORA` | Sí | | |

| Tabla | Llave primaria | Destino |
|---|---|---|
| `programa_alias` | `id_programa_alias` | `id_programa` → `cat_programa` |
| `organizacion_alias` | `id_organizacion_alias` | `id_organizacion` → `cat_organizacion` |
| `cargo_alias` | `id_cargo_alias` | `codigo_ocupacion` → `cat_ocupacion` |
| `ubicacion_alias` | `id_ubicacion_alias` | `codigo_ubicacion` → `cat_ubicacion` |

### 2.2 Clasificaciones

Cada clasificación usa cuatro columnas: `<x>_propuesto`, `metodo_<x>`, `confianza_<x>` y el valor final `<x>`. La explicación está en el paso 2.6 del modelo. Aparecen en `experiencia` (organización, ocupación, ubicación y área), en `estudio_declarado` (institución) y en `cat_organizacion` (actividad económica).

### 2.3 Quién hizo el registro

En `captura`, `decision_coincidencia` e `incidencia`, el autor es **exactamente uno** de dos: una ejecución (proceso automático) o un responsable (persona). La regla se valida en la propia fila.

### 2.4 Bitácoras

`bitacora_identidad` y `bitacora` tienen la misma estructura (sección 3.10). Cada una registra los cambios de su propia base.

## 3. Base `egresados_identidad`

### 3.1 `identidad`

Nombres y contacto de cada egresado. Relación 1 a 1 con `egresado`.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_egresado` | Egresado al que pertenece | `ID` | Sí | PK, FK → `egresado` | Relación 1 a 1. Cascada |
| `nombres` | Nombres según el registro académico | `TEXTO` | Sí | | |
| `primer_apellido` | Primer apellido | `TEXTO` | Sí | | |
| `segundo_apellido` | Segundo apellido | `TEXTO` | No | | Vacío: no tiene segundo apellido en el registro |
| `correo_personal` | Correo de contacto principal | `CORREO` | No | | Vacío: no se conoce |
| `correo_institucional` | Correo de la universidad | `CORREO` | No | | Termina en `@unal.edu.co`. Vacío: no se conoce |

### 3.2 `documento_identidad`

Todos los documentos que ha tenido la persona.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_documento` | Identificador | `ID` | Sí | PK | |
| `id_egresado` | Persona a la que pertenece | `ID` | Sí | FK → `identidad` | Cascada |
| `tipo_documento` | Tipo de documento | `LISTA` | Sí | UQ1 | `CC` (cédula de ciudadanía), `TI` (tarjeta de identidad), `CE` (cédula de extranjería), `PA` (pasaporte), `PPT` (permiso por protección temporal), `OTRO` |
| `numero_documento` | Número | `NUM_DOCUMENTO` | Sí | UQ1 | La pareja tipo + número no se repite |

### 3.3 `texto_autorizacion`

Versiones del texto de autorización.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_texto_autorizacion` | Identificador | `ID` | Sí | PK | |
| `version` | Versión del texto | `VERSION` | Sí | UQ | |
| `texto` | Texto completo, con las finalidades del tratamiento | `TEXTO_LARGO` | Sí | | No se modifica una vez publicado: un cambio es una versión nueva |
| `fecha_inicio_vigencia` | Desde cuándo se muestra | `FECHA` | Sí | | |
| `fecha_fin_vigencia` | Hasta cuándo se mostró | `FECHA` | No | | Vacío: versión vigente. Solo puede haber una versión vigente. Si tiene valor, es igual o posterior al inicio |
| `marca_vigente` | Columna técnica para la regla de una sola versión vigente | `BOOLEANO` | — | UQ | Calculada: 1 si `fecha_fin_vigencia` está vacía; vacío si no. Como `UNIQUE` admite varios vacíos, solo puede haber una fila con 1 |

### 3.4 `autorizacion`

Prueba de que un egresado aceptó una versión del texto (Decreto 1377, art. 8).

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_autorizacion` | Identificador | `ID` | Sí | PK | |
| `id_egresado` | Quién autoriza | `ID` | Sí | FK → `identidad` | Cascada |
| `id_texto_autorizacion` | Versión aceptada | `ID` | Sí | FK → `texto_autorizacion` | Restringida |
| `codigo_fuente` | Canal en que se otorgó | `CODIGO` | Sí | FK → `cat_fuente` | Solo `CANAL_A` o `CANAL_B` |
| `fecha_hora` | Momento de la aceptación | `FECHA_HORA` | Sí | | Dentro de la vigencia del texto aceptado |
| `evidencia` | Identificador del envío en el sistema que recibió el formulario | `TEXTO` | Sí | | Es la prueba de la autorización |

### 3.5 `perfil`

Perfiles de LinkedIn, aceptados o candidatos.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_perfil` | Identificador | `ID` | Sí | PK | |
| `url` | URL normalizada del perfil | `URL_PERFIL` | No | UQ | Vacío: borrada por conservación limitada (candidato descartado) |
| `huella_url` | HMAC-SHA256 de la URL normalizada | `HUELLA` | Sí | UQ | Reconoce el perfil aunque su URL se haya borrado. La calcula el programa que tiene la clave; la base nunca ve la clave |
| `fecha_hora_borrado_url` | Cuándo se borró la URL | `FECHA_HORA` | No | | Vacío: URL vigente. Tiene valor si y solo si `url` está vacía |

### 3.6 `coincidencia`

Comparación entre un egresado y un perfil.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_coincidencia` | Identificador | `ID` | Sí | PK | |
| `id_egresado` | Egresado comparado | `ID` | Sí | FK → `identidad`, UQ1 | Cascada |
| `id_perfil` | Perfil comparado | `ID` | Sí | FK → `perfil`, UQ1 | Cascada. Un par egresado–perfil se compara una sola vez |
| `id_busqueda` | Búsqueda manual que encontró al candidato | `ID` | No | FK → `busqueda` | Cascada. Vacío: no viene del canal C |
| `id_ejecucion` | Ejecución del motor de cruce que calculó el puntaje | `ID` | Sí | FK → `ejecucion` | Restringida |
| `nombre_observado` | Nombre como aparece en el perfil | `TEXTO` | No | | Se borra al cerrar la decisión. Vacío: borrado |
| `programa_observado` | Programa como aparece en el perfil | `TEXTO` | No | | Se borra al cerrar la decisión. Vacío: borrado o no observado |
| `anio_inicio_observado` | Año de inicio de los estudios observado | `ANIO` | No | | Igual que el anterior |
| `anio_fin_observado` | Año de fin de los estudios observado | `ANIO` | No | | Igual que el anterior |
| `ciudad_observada` | Ciudad observada | `TEXTO` | No | | Igual que el anterior |
| `puntaje_nombre` | Similitud del nombre | `PROPORCION` | Sí | | |
| `puntaje_programa` | Coincidencia del programa | `PROPORCION` | No | | Vacío: el programa no se observó; cuenta como 0 en el total |
| `puntaje_anio` | Coincidencia del año de grado | `PROPORCION` | No | | Vacío: el año no se observó; cuenta como 0 |
| `puntaje_ciudad` | Coincidencia de la ciudad | `PROPORCION` | No | | Vacío: la ciudad no se observó; cuenta como 0 |
| `puntaje_total` | Puntaje ponderado con los pesos de la ejecución | `PROPORCION` | Sí | | Se escribe una vez y no se modifica (excepción controlada, paso 2.7) |
| `nivel` | Clasificación del puntaje | `LISTA` | Sí | | `ALTO`, `MEDIO`, `BAJO`, `IMPOSIBLE`. No se modifica |
| `motivo_nivel` | Por qué el caso es imposible | `DESCRIPCION` | No | | Obligatorio si el nivel es `IMPOSIBLE` |
| `estado` | Resultado de la última decisión | `LISTA` | Sí | | `PENDIENTE`, `ACEPTADA`, `RECHAZADA`. Nace `PENDIENTE`. Lo actualiza un disparador al registrar cada decisión (excepción controlada). A lo sumo una coincidencia aceptada por perfil y una por egresado |
| `perfil_aceptado` | Columna técnica para la regla de un perfil aceptado | `ID` | — | UQ | Calculada: `id_perfil` si el estado es `ACEPTADA`; vacío si no |
| `egresado_aceptado` | Columna técnica para la regla de un perfil por egresado | `ID` | — | UQ | Calculada: `id_egresado` si el estado es `ACEPTADA`; vacío si no |
| `fecha_hora_borrado_observados` | Cuándo se borraron los datos observados | `FECHA_HORA` | No | | Vacío: aún guardados |

### 3.7 `decision_coincidencia`

Cada decisión sobre una coincidencia.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_decision` | Identificador | `ID` | Sí | PK | |
| `id_coincidencia` | Coincidencia decidida | `ID` | Sí | FK → `coincidencia` | Cascada |
| `tipo_decision` | Quién decide | `LISTA` | Sí | | `AUTOMATICA`, `REVISION`, `AUDITORIA` |
| `resultado` | Qué se decidió | `LISTA` | Sí | | `ACEPTAR`, `RECHAZAR`, `ENVIAR_A_REVISION`. `ENVIAR_A_REVISION` solo en decisiones automáticas |
| `id_ejecucion` | Ejecución que decidió | `ID` | No | FK → `ejecucion` | Obligatorio si es `AUTOMATICA`; vacío en otro caso |
| `id_responsable` | Persona que decidió | `ID` | No | FK → `responsable` | Obligatorio si es `REVISION` o `AUDITORIA`; vacío si es `AUTOMATICA` |
| `motivo` | Razón de la decisión | `DESCRIPCION` | No | | Obligatorio si el resultado es `RECHAZAR` |
| `fecha_hora` | Cuándo se decidió | `FECHA_HORA` | Sí | | |

### 3.8 `solicitud_supresion`

Constancia de una revocatoria o supresión. **No tiene llave hacia la persona, a propósito.**

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_solicitud_supresion` | Identificador | `ID` | Sí | PK | |
| `tipo_solicitud` | Qué pidió el titular | `LISTA` | Sí | | `REVOCATORIA`, `SUPRESION` |
| `canal_solicitud` | Por dónde llegó | `LISTA` | Sí | | `CORREO`, `FORMULARIO`, `ESCRITO`, `OTRO` |
| `fecha_hora_solicitud` | Cuándo llegó | `FECHA_HORA` | Sí | | |
| `fecha_hora_atencion` | Cuándo se atendió | `FECHA_HORA` | No | | Vacío: en trámite. Igual o posterior a la solicitud. Plazo legal: 15 días hábiles, prorrogables 8 (Ley 1581, art. 15) |
| `id_responsable` | Quién la atendió | `ID` | No | FK → `responsable` | Obligatorio cuando hay fecha de atención |
| `observacion` | Notas | `DESCRIPCION` | No | | Sin datos que identifiquen al titular |

### 3.9 `huella_no_contactar`

Lista de no contactar: huellas de los datos de quien revocó.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_huella` | Identificador | `ID` | Sí | PK | |
| `id_solicitud_supresion` | Constancia a la que pertenece | `ID` | Sí | FK → `solicitud_supresion` | Restringida: las constancias no se borran |
| `tipo_huella` | Qué dato representa | `LISTA` | Sí | | `DOCUMENTO`, `URL`, `CORREO` |
| `huella` | HMAC-SHA256 del valor normalizado | `HUELLA` | Sí | | El documento entra como `TIPO:NUMERO`, la URL normalizada y el correo en minúsculas. Se busca por este campo, que no es único: una persona puede revocar más de una vez. La calcula el programa que tiene la clave |

### 3.10 `bitacora_identidad`

Cambios en las tablas de esta base. `bitacora` (sección 4.29) tiene la misma estructura.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_bitacora` | Identificador | `ID` | Sí | PK | |
| `tabla` | Tabla modificada | `TEXTO` | Sí | | |
| `id_registro` | Llave del registro modificado | `TEXTO` | Sí | | Se guarda como texto porque cada tabla tiene su propia llave |
| `id_egresado` | Persona a la que se refiere el cambio | `ID` | No | FK → `identidad` | Cascada. Vacío: el cambio no es de una persona (por ejemplo, un texto de autorización) |
| `operacion` | Tipo de cambio | `LISTA` | Sí | | `INSERT`, `UPDATE`, `DELETE` |
| `valores_anteriores` | Valores antes del cambio | `JSON` | No | | Vacío en `INSERT` |
| `valores_nuevos` | Valores después del cambio | `JSON` | No | | Vacío en `DELETE` |
| `usuario_bd` | Usuario de la sesión de MariaDB | `USUARIO_BD` | Sí | FK → `responsable` (`usuario_bd`) | Lo toma el disparador con `SESSION_USER()`, sin el equipo; no lo envía la aplicación |
| `id_ejecucion` | Proceso automático que hizo el cambio | `ID` | No | FK → `ejecucion` | Vacío: cambio manual |
| `motivo` | Por qué se hizo el cambio | `DESCRIPCION` | No | | Obligatorio si no hay ejecución (cambio manual) |
| `fecha_hora` | Cuándo se hizo | `FECHA_HORA` | Sí | | |

**Valores que la bitácora no copia:** `perfil.url` y los datos observados de `coincidencia` (`nombre_observado`, `programa_observado`, `anio_inicio_observado`, `anio_fin_observado`, `ciudad_observada`). Se registra que cambiaron, sin el valor, porque se borran por conservación limitada. Las tablas `egresado` y `perfil` no registran borrados (paso 3.6 del modelo).

## 4. Base `egresados`

### Formación oficial

### 4.1 `egresado`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_egresado` | Identificador interno sin significado | `ID` | Sí | PK | La carga inicial inserta en orden aleatorio, para que el número no conserve el orden del archivo fuente |
| `sexo` | Sexo según el registro académico | `LISTA` | No | | `F`, `M`, `O` (otro). Vacío: no registrado |
| `id_ejecucion` | Carga del registro oficial que lo creó | `ID` | Sí | FK → `ejecucion` | Restringida |

### 4.2 `grado`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_grado` | Identificador | `ID` | Sí | PK | |
| `id_egresado` | Egresado | `ID` | Sí | FK → `egresado`, UQ1 | Cascada |
| `id_programa` | Programa cursado | `ID` | Sí | FK → `cat_programa`, UQ1 | Restringida. Una persona no tiene dos grados del mismo programa |
| `anio_ingreso` | Año de ingreso al programa | `ANIO` | No | | Vacío: no disponible en el registro |
| `semestre_ingreso` | Semestre de ingreso | `SEMESTRE` | No | | Solo si hay año de ingreso |
| `fecha_grado` | Fecha de la ceremonia | `FECHA` | No | | Obligatoria si el estado es `OTORGADO`; vacía en otro caso |
| `estado` | Estado del grado | `LISTA` | Sí | | `EN_TRAMITE`, `OTORGADO`, `CANCELADO`. Si la duración entre ingreso y grado es menor que la mínima del programa, se abre una incidencia: sería un error del registro oficial |
| `id_ejecucion` | Carga oficial que lo registró o actualizó por última vez | `ID` | Sí | FK → `ejecucion` | Restringida |

### 4.3 `cat_programa`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_programa` | Identificador | `ID` | Sí | PK | |
| `nombre` | Nombre oficial vigente | `TEXTO` | Sí | UQ | Los nombres anteriores van en `programa_alias` |
| `codigo_nivel` | Nivel de formación | `CODIGO` | Sí | FK → `cat_nivel_formacion` | Restringida |
| `codigo_snies` | Código del programa en el SNIES | `CODIGO` | No | UQ | Vacío: el programa no tiene código |
| `codigo_sia` | Código del plan de estudios en el sistema académico | `CODIGO` | No | UQ | Une la carga oficial con el catálogo. Vacío: programa anterior al sistema |
| `semestres_minimos` | Duración mínima realista | `ENTERO` | Sí | | Mayor que 0. Una duración menor es imposible |
| `es_vigente` | Si admite estudiantes | `BOOLEANO` | Sí | | 0: ya no admite, pero tiene egresados |

### 4.4 `programa_alias`

Diccionario de equivalencias (sección 2.1). Destino: `id_programa` → `cat_programa`.

### 4.5 `afinidad_programa_ocupacion`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_programa` | Programa | `ID` | Sí | PK, FK → `cat_programa` | Restringida |
| `codigo_ocupacion` | Ocupación afín, en cualquier nivel | `COD_OCUPACION` | Sí | PK, FK → `cat_ocupacion` | Restringida. Un código cubre sus niveles inferiores: si se marca `251`, toda ocupación que empiece por `251` es afín |
| `soporte` | Documento que la respalda, por ejemplo un acta del comité de programa | `TEXTO` | Sí | | |
| `id_responsable` | Quién la registró | `ID` | Sí | FK → `responsable` | Restringida |

### 4.6 `cat_nivel_formacion`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `codigo_nivel` | Código | `CODIGO` | Sí | PK | `TECNICO`, `TECNOLOGICO`, `PREGRADO`, `ESPECIALIZACION`, `MAESTRIA`, `DOCTORADO`, `OTRO`, `NO_DETERMINADO` |
| `nombre` | Nombre | `TEXTO` | Sí | UQ | |
| `orden` | Posición para comparar niveles | `ENTERO` | No | UQ | De 1 (técnico) a 6 (doctorado). Vacío en `OTRO` y `NO_DETERMINADO`, que no se comparan |

### Capturas y contenido

### 4.7 `captura`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_captura` | Identificador | `ID` | Sí | PK | El PDF temporal se guarda con este número como nombre, así que su ruta no se almacena |
| `id_egresado` | Egresado | `ID` | Sí | FK → `egresado`; FK1 → `coincidencia`; FK2 → `autorizacion` | Cascada |
| `id_perfil` | Perfil del que proviene | `ID` | No | FK1 → `coincidencia` | Junto con `id_egresado` debe existir en `coincidencia`, con estado `ACEPTADA`. Vacío: fuente sin perfil (formulario directo) |
| `codigo_fuente` | Fuente | `CODIGO` | Sí | FK → `cat_fuente` | Restringida. Solo fuentes individuales |
| `id_autorizacion` | Autorización que la ampara | `ID` | No | FK2 → `autorizacion` | Cascada: solo ocurre en la supresión. Obligatoria si la base legal de la fuente es `AUTORIZACION`. Junto con `id_egresado` debe existir en `autorizacion` (llave compuesta): la autorización es del mismo egresado |
| `id_ejecucion` | Proceso que la creó | `ID` | No | FK → `ejecucion` | Exactamente uno de `id_ejecucion` e `id_responsable` (sección 2.3) |
| `id_responsable` | Persona que la registró (canal C) | `ID` | No | FK → `responsable` | |
| `fecha_hora_captura` | Cuándo se subió el PDF o se hizo la consulta | `FECHA_HORA` | Sí | | |
| `estado` | Estado de la captura | `LISTA` | Sí | | `RECIBIDA`, `EN_REVISION`, `VERIFICADA`, `RECHAZADA`. Solo las verificadas cuentan para el análisis |
| `situacion_declarada` | Situación laboral que declaró el egresado | `LISTA` | No | | `EMPLEADO`, `INDEPENDIENTE`, `ESTUDIANDO`, `BUSCANDO_EMPLEO`, `OTRA`. Vacío: no se preguntó (canal C) |
| `huella_archivo` | SHA-256 del PDF | `HUELLA` | No | UQ | El mismo archivo no se procesa dos veces. Vacío: la fuente no es un PDF |
| `fecha_hora_borrado_archivo` | Cuándo se borró el PDF | `FECHA_HORA` | No | | Vacío: el archivo sigue guardado, o no hubo archivo. Se llena al verificar o rechazar la captura |

### 4.8 `experiencia`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_experiencia` | Identificador | `ID` | Sí | PK | |
| `id_captura` | Captura a la que pertenece | `ID` | Sí | FK → `captura` | Cascada |
| `cargo_original` | Cargo como lo escribió la persona | `TEXTO` | Sí | | |
| `organizacion_original` | Organización como la escribió | `TEXTO` | No | | Vacío: no declarada |
| `ubicacion_original` | Ubicación como la escribió | `TEXTO` | No | | Vacío: no declarada |
| `anio_inicio` | Año de inicio | `ANIO` | Sí | | No puede ser posterior al año actual |
| `mes_inicio` | Mes de inicio | `MES` | No | | Vacío: no declarado |
| `anio_fin` | Año de fin | `ANIO` | No | | Vacío: empleo actual ("Present"). Igual o posterior al año de inicio; no posterior al año actual |
| `mes_fin` | Mes de fin | `MES` | No | | Solo si hay año de fin. Vacío: no declarado o empleo actual. Si los años de inicio y fin son iguales y hay ambos meses, el de fin es igual o posterior |
| `es_actual` | Si es el empleo actual | `BOOLEANO` | — | | Calculada: 1 si `anio_fin` está vacío |
| `tipo_vinculo` | Tipo de vínculo | `LISTA` | Sí | | `EMPLEO`, `PRACTICA`, `INDEPENDIENTE`, `VOLUNTARIADO`. El bot lo asigna por palabras del cargo ("practicante", "pasante", "intern", "freelance", "voluntario"…); `EMPLEO` si no encuentra ninguna |
| `id_organizacion_propuesto` | Organización propuesta | `ID` | No | FK → `cat_organizacion` | Restringida. Clasificación (sección 2.2) |
| `metodo_organizacion` | Cómo se propuso | `LISTA` | No | | `DICCIONARIO`, `IA` |
| `confianza_organizacion` | Confianza de la propuesta | `PROPORCION` | No | | 1 si viene del diccionario |
| `id_organizacion` | Organización final | `ID` | No | FK → `cat_organizacion` | Restringida. Vacío: no declarada (si `organizacion_original` está vacía) o pendiente |
| `codigo_ocupacion_propuesto` | Ocupación propuesta | `COD_OCUPACION` | No | FK → `cat_ocupacion` | Restringida |
| `metodo_ocupacion` | Cómo se propuso | `LISTA` | No | | `DICCIONARIO`, `IA` |
| `confianza_ocupacion` | Confianza de la propuesta | `PROPORCION` | No | | 1 si viene del diccionario |
| `codigo_ocupacion` | Ocupación final (CUOC) | `COD_OCUPACION` | No | FK → `cat_ocupacion` | Restringida. Vacío: pendiente |
| `codigo_ubicacion_propuesto` | Ubicación propuesta | `COD_UBICACION` | No | FK → `cat_ubicacion` | Restringida |
| `metodo_ubicacion` | Cómo se propuso | `LISTA` | No | | `DICCIONARIO`, `IA` |
| `confianza_ubicacion` | Confianza de la propuesta | `PROPORCION` | No | | 1 si viene del diccionario |
| `codigo_ubicacion` | Ubicación final | `COD_UBICACION` | No | FK → `cat_ubicacion` | Restringida. Vacío: no declarada (si `ubicacion_original` está vacía) o pendiente |
| `codigo_area_propuesto` | Área propuesta | `CODIGO` | No | FK → `cat_area_desempeno` | Restringida |
| `metodo_area` | Cómo se propuso | `LISTA` | No | | `IA` |
| `confianza_area` | Confianza de la propuesta | `PROPORCION` | No | | |
| `codigo_area` | Área final | `CODIGO` | No | FK → `cat_area_desempeno` | Restringida. Vacío: pendiente |
| `id_ejecucion_clasificacion` | Ejecución que hizo las propuestas | `ID` | No | FK → `ejecucion` | Restringida. Vacío: aún sin clasificar |

### 4.9 `estudio_declarado`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_estudio` | Identificador | `ID` | Sí | PK | |
| `id_captura` | Captura a la que pertenece | `ID` | Sí | FK → `captura` | Cascada |
| `institucion_original` | Institución como la escribió | `TEXTO` | Sí | | |
| `programa_original` | Título o programa como lo escribió | `TEXTO` | No | | Vacío: no declarado |
| `anio_inicio` | Año de inicio | `ANIO` | No | | Vacío: no declarado |
| `anio_fin` | Año de fin | `ANIO` | No | | Vacío: no declarado. Puede ser posterior al año actual (año esperado). Igual o posterior al año de inicio |
| `codigo_nivel` | Nivel de formación | `CODIGO` | Sí | FK → `cat_nivel_formacion` | Restringida. El bot lo deduce del título; `NO_DETERMINADO` si no puede |
| `id_programa` | Programa de la Facultad al que corresponde | `ID` | No | FK → `cat_programa` | Restringida. Se asigna con `programa_alias`, y solo si la institución es la UNAL: una maestría con el mismo nombre en otra universidad no es un programa de la Facultad. Vacío: no es de la Facultad o no se identificó |
| `id_organizacion_propuesto` | Institución propuesta | `ID` | No | FK → `cat_organizacion` | Restringida. Clasificación (sección 2.2) |
| `metodo_organizacion` | Cómo se propuso | `LISTA` | No | | `DICCIONARIO`, `IA` |
| `confianza_organizacion` | Confianza de la propuesta | `PROPORCION` | No | | 1 si viene del diccionario |
| `id_organizacion` | Institución final | `ID` | No | FK → `cat_organizacion` | Restringida. Vacío: pendiente |
| `id_ejecucion_clasificacion` | Ejecución que hizo las propuestas | `ID` | No | FK → `ejecucion` | Restringida. Vacío: aún sin clasificar |

### 4.10 `cat_organizacion`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_organizacion` | Identificador | `ID` | Sí | PK | |
| `nombre` | Nombre normalizado | `TEXTO` | Sí | UQ1 | |
| `codigo_pais` | País de la sede principal | `COD_UBICACION` | No | UQ1, FK → `cat_ubicacion` | Restringida. Debe ser un código de nivel país. Vacío: no determinado |
| `nit` | NIT, sin dígito de verificación | `NIT` | No | UQ | Solo organizaciones colombianas. Permite tomar la actividad económica registrada en vez de inferirla |
| `codigo_actividad_propuesto` | Actividad propuesta | `COD_ACTIVIDAD` | No | FK → `cat_actividad_economica` | Restringida. Clasificación (sección 2.2) |
| `metodo_actividad` | Cómo se propuso | `LISTA` | No | | `REGISTRO`, `IA` |
| `confianza_actividad` | Confianza de la propuesta | `PROPORCION` | No | | 1 si viene del registro |
| `codigo_actividad` | Actividad económica final (CIIU) | `COD_ACTIVIDAD` | No | FK → `cat_actividad_economica` | Restringida. Se prefiere el nivel de clase. Vacío: pendiente |
| `id_ejecucion_clasificacion` | Ejecución que hizo la propuesta | `ID` | No | FK → `ejecucion` | Restringida. Vacío: aún sin clasificar |

### 4.11 `organizacion_alias`

Diccionario de equivalencias (sección 2.1). Destino: `id_organizacion` → `cat_organizacion`.

### Catálogos de estandarización

### 4.12 `cat_ocupacion`

Ocupaciones según la CUOC.

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `codigo_ocupacion` | Código CUOC | `COD_OCUPACION` | Sí | PK | |
| `nombre` | Nombre | `TEXTO` | Sí | | |
| `codigo_padre` | Código del nivel superior | `COD_OCUPACION` | No | FK → `cat_ocupacion` | Restringida. Vacío: gran grupo. Es el código sin su último dígito |
| `nivel` | Nivel en la jerarquía | `LISTA` | — | | Calculada por la longitud del código: `GRAN_GRUPO` (1), `SUBGRUPO_PRINCIPAL` (2), `SUBGRUPO` (3), `GRUPO_PRIMARIO` (4), `OCUPACION` (5) |
| `es_vigente` | Si pertenece a la versión cargada | `BOOLEANO` | Sí | | 0: código de una versión anterior; no se borra |

### 4.13 `cargo_alias`

Diccionario de equivalencias (sección 2.1). Destino: `codigo_ocupacion` → `cat_ocupacion`. Es el catálogo de cargos que pide el enunciado.

### 4.14 `cat_actividad_economica`

Actividades económicas según la CIIU Rev. 4 A.C. (2022).

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `codigo_actividad` | Código CIIU | `COD_ACTIVIDAD` | Sí | PK | |
| `nombre` | Nombre | `TEXTO` | Sí | | |
| `codigo_padre` | Código del nivel superior | `COD_ACTIVIDAD` | No | FK → `cat_actividad_economica` | Restringida. Vacío: sección. Una división apunta a su sección (letra); un grupo o una clase, al código sin su último dígito |
| `nivel` | Nivel en la jerarquía | `LISTA` | — | | Calculada por el formato del código: `SECCION` (letra), `DIVISION` (2), `GRUPO` (3), `CLASE` (4) |
| `es_vigente` | Si pertenece a la versión cargada | `BOOLEANO` | Sí | | |

### 4.15 `cat_ubicacion`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `codigo_ubicacion` | Código del país o código DIVIPOLA | `COD_UBICACION` | Sí | PK | En el exterior solo se registra el país |
| `nombre` | Nombre | `TEXTO` | Sí | | |
| `codigo_padre` | Código del nivel superior | `COD_UBICACION` | No | FK → `cat_ubicacion` | Restringida. Vacío: país. Un departamento apunta a `CO`; un municipio, a sus dos primeros dígitos |
| `nivel` | Nivel en la jerarquía | `LISTA` | — | | Calculada por el formato del código: `PAIS` (2 letras), `DEPARTAMENTO` (2 dígitos), `MUNICIPIO` (5 dígitos) |
| `es_vigente` | Si sigue vigente | `BOOLEANO` | Sí | | |

### 4.16 `ubicacion_alias`

Diccionario de equivalencias (sección 2.1). Destino: `codigo_ubicacion` → `cat_ubicacion`.

### 4.17 `cat_area_desempeno`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `codigo_area` | Código | `CODIGO` | Sí | PK | `DOCENCIA`, `INVESTIGACION`, `DESARROLLO`, `CONSULTORIA`, `GESTION`, `OPERACION`, `EMPRENDIMIENTO`, `OTRA` |
| `nombre` | Nombre | `TEXTO` | Sí | UQ | |
| `criterio` | Cuándo se asigna esta área | `DESCRIPCION` | Sí | | Lo usan la IA y los revisores para clasificar igual |

### 4.18 `cat_fuente`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `codigo_fuente` | Código | `CODIGO` | Sí | PK | `CANAL_A`, `CANAL_B`, `CANAL_C`, `FORMULARIO_DIRECTO`, `REGISTRO_ACADEMICO`, `ENCUESTA`, `OBSERVATORIO_LABORAL` |
| `nombre` | Nombre | `TEXTO` | Sí | UQ | |
| `base_legal` | Base legal del tratamiento | `LISTA` | Sí | | `AUTORIZACION`, `DATO_PUBLICO`, `REGISTRO_INSTITUCIONAL`, `SIN_DATOS_PERSONALES` |
| `norma` | Norma que la respalda | `TEXTO` | No | | Por ejemplo, "Ley 1581 de 2012, art. 9". Vacío: no aplica |
| `es_individual` | Si aporta datos de personas | `BOOLEANO` | Sí | | Solo las fuentes individuales originan capturas; las demás, indicadores externos |

### 4.19 `cat_tipo_incidencia`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `codigo_tipo_incidencia` | Código | `CODIGO` | Sí | PK | `INCOMPLETA`, `AMBIGUA`, `DESACTUALIZADA`, `NO_VERIFICABLE`, `URL_DISTINTA`, `DUPLICADA` |
| `nombre` | Nombre | `TEXTO` | Sí | UQ | |
| `dimension` | Dimensión de calidad (Ley 1581, art. 4 lit. d) | `LISTA` | Sí | | `VERAZ`, `COMPLETA`, `EXACTA`, `ACTUALIZADA`, `COMPROBABLE`, `COMPRENSIBLE` |
| `severidad` | Gravedad | `LISTA` | Sí | | `ALTA`, `MEDIA`, `BAJA` |
| `bloquea_captura` | Si impide verificar la captura | `BOOLEANO` | Sí | | |

### 4.20 `cat_momento_seguimiento`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `codigo_momento` | Código | `CODIGO` | Sí | PK | `M0`, `M1`, `M3`, `M5`, `M10`, `M15`… |
| `anios_desde_grado` | Años después del grado | `ENTERO` | Sí | UQ | |
| `es_activo` | Si se sigue usando | `BOOLEANO` | Sí | | |

### Seguimiento y cobertura

### 4.21 `solicitud_actualizacion`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_solicitud` | Identificador | `ID` | Sí | PK | |
| `id_egresado` | Egresado | `ID` | Sí | FK → `egresado`; FK1 → `captura`; UQ1 | Cascada |
| `codigo_momento` | Momento de seguimiento | `CODIGO` | Sí | FK → `cat_momento_seguimiento`, UQ1 | Restringida. Una solicitud por egresado y momento |
| `id_ejecucion` | Envío que la generó | `ID` | Sí | FK → `ejecucion` | Restringida |
| `fecha_hora_envio` | Cuándo se envió | `FECHA_HORA` | Sí | | |
| `numero_recordatorios` | Recordatorios enviados | `ENTERO` | Sí | | 0 al crearla |
| `estado_envio` | Resultado del envío | `LISTA` | Sí | | `ENVIADA`, `REBOTADA`. Un rebote abre una incidencia `DESACTUALIZADA` sobre el correo |
| `huella_token` | SHA-256 del código del enlace personal | `HUELLA` | Sí | UQ | El código no se guarda. Basta SHA-256 simple porque el código es aleatorio y no se puede adivinar |
| `fecha_vencimiento` | Hasta cuándo sirve el enlace | `FECHA` | Sí | | Posterior a la fecha de envío |
| `respuesta` | Qué respondió el egresado | `LISTA` | No | | `CONFIRMO_SIN_CAMBIOS`, `ACTUALIZO`. Vacío: sin respuesta |
| `fecha_hora_respuesta` | Cuándo respondió | `FECHA_HORA` | No | | Tiene valor si y solo si hay respuesta; no posterior al vencimiento |
| `id_captura` | Captura confirmada o nueva | `ID` | No | FK1 → `captura` | Cascada. Obligatoria si hay respuesta. Junto con `id_egresado` debe existir en `captura` (llave compuesta): la captura es del mismo egresado |

### 4.22 `muestra`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_muestra` | Identificador | `ID` | Sí | PK | |
| `poblacion` | Población muestreada | `DESCRIPCION` | Sí | | Por ejemplo, "pregrado, cohortes de grado 2000 a 2015" |
| `margen_error` | Margen de error (e) | `PROPORCION` | Sí | | Mayor que 0 |
| `nivel_confianza` | Nivel de confianza | `PROPORCION` | Sí | | Por ejemplo, 0,950 |
| `proporcion_supuesta` | Proporción supuesta (p) | `PROPORCION` | Sí | | 0,500 si no hay información previa |
| `semilla` | Semilla aleatoria de la selección | `ENTERO` | Sí | | |
| `id_ejecucion` | Ejecución que hizo la selección | `ID` | Sí | FK → `ejecucion` | Restringida |

### 4.23 `muestra_egresado`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_muestra` | Muestra | `ID` | Sí | PK, FK → `muestra` | Restringida |
| `id_egresado` | Egresado seleccionado | `ID` | Sí | PK, FK → `egresado` | Cascada |
| `estrato` | Etiqueta del estrato en el diseño | `TEXTO` | Sí | | Por ejemplo, el programa y el rango de cohortes |
| `peso` | Egresados del estrato ÷ seleccionados en él | `PESO` | Sí | | Igual para todos los del mismo estrato |

### 4.24 `busqueda`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_busqueda` | Identificador | `ID` | Sí | PK | |
| `id_egresado` | Egresado buscado | `ID` | Sí | FK → `egresado`; FK1 → `muestra_egresado` | Cascada |
| `id_muestra` | Muestra a la que pertenece la búsqueda | `ID` | No | FK1 → `muestra_egresado` | Cascada. Junto con `id_egresado` debe existir en `muestra_egresado`. Vacío: búsqueda fuera de una muestra |
| `id_responsable` | Quién buscó | `ID` | Sí | FK → `responsable` | Restringida |
| `fecha_hora` | Cuándo | `FECHA_HORA` | Sí | | |
| `version_protocolo` | Versión del protocolo de consulta | `VERSION` | Sí | | |
| `resultado` | Resultado | `LISTA` | Sí | | `ENCONTRADO`, `VARIOS_CANDIDATOS`, `NO_ENCONTRADO` |

### 4.25 `indicador_externo`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_indicador_externo` | Identificador | `ID` | Sí | PK | |
| `codigo_fuente` | Fuente que lo publica | `CODIGO` | Sí | FK → `cat_fuente`, UQ1 | Restringida. Solo fuentes no individuales |
| `id_programa` | Programa | `ID` | No | FK → `cat_programa`, UQ1 | Restringida. Vacío: indicador de toda la institución |
| `nombre_indicador` | Nombre del indicador | `TEXTO` | Sí | UQ1 | |
| `anio_cohorte` | Año de grado de la cohorte medida | `ANIO` | No | UQ1 | Vacío: no aplica |
| `anio_medicion` | Año de la medición | `ANIO` | Sí | UQ1 | |
| `valor` | Valor | `DECIMAL` | Sí | | |
| `unidad` | Unidad | `LISTA` | Sí | | `PORCENTAJE`, `PESOS`, `PERSONAS` |
| `referencia` | Dónde se publicó | `TEXTO` | Sí | | |
| `fecha_consulta` | Cuándo se consultó | `FECHA` | Sí | | |

### Proceso y calidad

### 4.26 `responsable`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_responsable` | Identificador | `ID` | Sí | PK | |
| `usuario_bd` | Usuario de MariaDB | `USUARIO_BD` | Sí | UQ | Todo usuario que escribe en las bases debe estar registrado aquí |
| `nombre` | Nombre de la persona o del bot | `TEXTO` | Sí | | |
| `tipo` | Tipo | `LISTA` | Sí | | `PERSONA`, `BOT` |
| `fecha_alta` | Desde cuándo participa | `FECHA` | Sí | | |
| `fecha_baja` | Hasta cuándo participó | `FECHA` | No | | Vacío: activo. Nunca se borra, porque la bitácora lo sigue referenciando |

### 4.27 `ejecucion`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_ejecucion` | Identificador | `ID` | Sí | PK | |
| `tipo_proceso` | Proceso ejecutado | `LISTA` | Sí | | `CARGA_OFICIAL`, `CARGA_CATALOGO`, `BOT_CONSOLIDACION`, `BOT_VERIFICACION`, `CLASIFICACION`, `ENVIO_SOLICITUDES`, `MUESTREO`, `DEPURACION` |
| `id_responsable` | Bot o persona que la lanzó | `ID` | Sí | FK → `responsable` | Restringida |
| `version_programa` | Versión del programa ejecutado | `VERSION` | Sí | | |
| `modelo_ia` | Nombre del modelo de IA | `TEXTO` | No | | Vacío: el proceso no usa IA |
| `digest_modelo_ia` | Huella exacta del modelo en Ollama | `HUELLA` | No | | Obligatoria si hay modelo |
| `parametros` | Pesos, umbrales, versiones de las clasificaciones y demás parámetros vigentes | `JSON` | No | | Vacío: sin parámetros |
| `fecha_hora_inicio` | Inicio | `FECHA_HORA` | Sí | | |
| `fecha_hora_fin` | Fin | `FECHA_HORA` | No | | Vacío: en curso o interrumpida. Igual o posterior al inicio |
| `resultado` | Resultado | `LISTA` | No | | `EXITOSA`, `CON_ERRORES`, `FALLIDA`. Vacío: en curso |
| `registros_procesados` | Cantidad de registros procesados | `ENTERO` | No | | |

### 4.28 `incidencia`

| Atributo | Descripción | Dominio | Oblig. | Llave | Reglas |
|---|---|---|---|---|---|
| `id_incidencia` | Identificador | `ID` | Sí | PK | |
| `codigo_tipo_incidencia` | Tipo | `CODIGO` | Sí | FK → `cat_tipo_incidencia` | Restringida |
| `id_egresado` | Egresado afectado | `ID` | Sí | FK → `egresado`; FK1 → `captura` | Cascada |
| `id_captura` | Captura afectada | `ID` | No | FK1 → `captura` | Cascada. Junto con `id_egresado` debe existir en `captura` (llave compuesta): la captura es del mismo egresado. Vacío: no es de una captura (por ejemplo, un error del registro oficial) |
| `campo_afectado` | Tabla y campo | `TEXTO` | No | | Por ejemplo, `experiencia.anio_inicio`. Vacío: afecta al registro completo |
| `descripcion` | Qué pasa | `DESCRIPCION` | Sí | | Sin valores de identidad |
| `estado` | Estado | `LISTA` | Sí | | `ABIERTA`, `EN_REVISION`, `RESUELTA`, `DESCARTADA` |
| `id_ejecucion` | Proceso que la abrió | `ID` | No | FK → `ejecucion` | Exactamente uno de `id_ejecucion` e `id_responsable_apertura` (sección 2.3) |
| `id_responsable_apertura` | Persona que la abrió | `ID` | No | FK → `responsable` | |
| `id_responsable_asignado` | Persona que debe atenderla | `ID` | No | FK → `responsable` | Vacío: sin asignar |
| `fecha_hora_apertura` | Cuándo se abrió | `FECHA_HORA` | Sí | | |
| `fecha_hora_cierre` | Cuándo se cerró | `FECHA_HORA` | No | | Tiene valor si y solo si el estado es `RESUELTA` o `DESCARTADA`. Igual o posterior a la apertura |
| `solucion` | Cómo se resolvió | `DESCRIPCION` | No | | Obligatoria al cerrar |

### 4.29 `bitacora`

Cambios en las tablas de esta base. Misma estructura que `bitacora_identidad` (sección 3.10), con `id_egresado` → `egresado`.
