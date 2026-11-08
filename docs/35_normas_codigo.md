# DECISIÓN TECNOLÓGICA Y NORMAS DE DESARROLLO
# BUG DE FAMILIA

ESTADO: Decisión aprobada como línea base del proyecto.
PLATAFORMA: PC exclusivamente.
MOTOR: Godot 4.
LENGUAJE PRINCIPAL: GDScript tipado.
EJECUCIÓN DEL JUEGO: Completamente offline.

==================================================
1. DECISIÓN TECNOLÓGICA
==================================================

El proyecto se desarrollará con Godot 4 y GDScript tipado como combinación principal.

GDScript será el lenguaje para:
- Lógica de juego y reglas de cada sistema.
- Control del protagonista, movimiento y combate.
- IA local de criaturas y personajes.
- Simulación del ecosistema y de las zonas.
- Misiones, acontecimientos, diálogos e interacciones.
- Inventarios, piezas modulares y fabricación.
- Interfaz, guardado y gestión de estados.

Godot proporcionará:
- Escenas y nodos para estructurar entidades, zonas y sistemas.
- Recursos Resource para definir datos reutilizables.
- AnimationPlayer, Skeleton2D y Bone2D para animación y articulación 2D.
- TileMapLayer y escenas para construir el mundo en vista alta inclinada.
- Shaders para materiales, efectos, anomalías e iluminación.
- Herramientas integradas de depuración, perfiles y pruebas.

TECNOLOGÍAS COMPLEMENTARIAS

- GDScript tipado: código principal.
- Resources de Godot: primera opción para datos estructurados y reutilizables.
- JSON: intercambio, importación/exportación o configuración externa cuando aporte una ventaja clara.
- Shaders: efectos visuales ejecutados en GPU.
- Herramientas locales externas: generación, edición y conversión de recursos gráficos y sonoros antes de integrarlos.
- Git: control de versiones desde el primer día.

No se incorporarán Java, Spring Boot, PostgreSQL, servidores ni servicios de IA en tiempo de ejecución.

Tampoco se añadirá C# o C++ preventivamente. Una tecnología adicional solo se justificará mediante una necesidad concreta, una prueba y una decisión documentada.

VERSIÓN DE GODOT

Antes de crear la estructura definitiva, Claude comprobará cuál es la versión estable de Godot 4 adecuada en ese momento.

Se fijará una versión concreta y se documentará.

No se actualizará el motor ni se cambiará de versión principal sin revisar compatibilidad, ejecutar las pruebas y documentar el cambio.

==================================================
2. PRINCIPIOS GENERALES DE CÓDIGO
==================================================

1. Claridad antes que ingenio. El código debe ser fácil de leer, revisar y modificar.
2. Tipado estático siempre que sea razonable. Declarar tipos de variables, parámetros y retornos. Evitar Variant y tipos implícitos cuando se pueda expresar el tipo real.
3. Responsabilidad única. Cada script debe tener un propósito identificable. Evitar controladores gigantes que gestionen todo el juego.
4. Composición antes que herencia profunda. Preferir nodos y componentes pequeños que colaboren entre sí.
5. Acoplamiento bajo. Los sistemas se comunican mediante interfaces, señales, recursos o contratos explícitos.
6. Datos separados de comportamiento. Especies, piezas, materiales, eventos y parámetros deben poder configurarse sin reescribir la lógica principal.
7. Estados explícitos. Evitar combinaciones de booleanos que permitan estados contradictorios. Usar enums o máquinas de estados cuando corresponda.
8. Aleatoriedad controlada. Usar generadores aleatorios identificables y semillas reproducibles en simulaciones y pruebas.
9. Rendimiento medido. No optimizar por intuición ni introducir complejidad prematura. Medir antes de cambiar algoritmos.
10. Errores visibles. Validar datos y contratos en puntos de entrada. No ocultar fallos con valores por defecto silenciosos.
11. Sin dependencias online en el juego. La partida debe funcionar sin conexión y no depender de APIs, servidores o modelos remotos.
12. Código y documentación coherentes. Todo cambio relevante debe actualizar pruebas y documentación.

==================================================
3. CONVENCIONES RECOMENDADAS PARA GDSCRIPT
==================================================

Aplicar de forma consistente la guía de estilo oficial de Godot, además de estas reglas de proyecto.

3.1 NOMBRES Y FORMATO

- Usar tabuladores para la indentación, siguiendo la guía de estilo oficial de Godot.
- Mantener una única convención de formato en todo el proyecto.
- Usar finales de línea LF y codificación UTF-8 sin BOM.
- Mantener las líneas por debajo de 100 caracteres siempre que sea razonable.
- Clases y tipos: PascalCase.
- Variables, funciones y señales: snake_case.
- Constantes: CONSTANT_CASE.
- Archivos: snake_case.gd, coincidiendo con el nombre de la clase cuando proceda.
- Nombres descriptivos y específicos del dominio; evitar abreviaturas crípticas.

Ejemplo:

class_name CreatureBrain
extends Node

signal target_changed(new_target: Node2D)

const MAX_ACTIVE_TARGETS: int = 4

var movement_speed: float = 120.0
var current_target: Node2D

func set_target(new_target: Node2D) -> void:
    current_target = new_target
    target_changed.emit(current_target)

3.2 TIPADO

- Tipar variables, constantes, parámetros y valores de retorno.
- Tipar arrays y diccionarios cuando sea posible.
- Usar enums para conjuntos cerrados de estados o categorías.
- Evitar conversiones dinámicas dispersas.
- No desactivar advertencias del motor para esconder problemas.
- Si una API de Godot obliga a usar un tipo dinámico, encapsularlo y validar el valor en el límite del sistema.

3.3 ESTRUCTURA DE SCRIPTS

Orden recomendado:

1. @tool (solo si es necesario).
2. class_name.
3. extends.
4. Documentación breve de la clase.
5. Señales.
6. Enums y constantes.
7. Variables exportadas.
8. Variables privadas.
9. Métodos incorporados de Godot (_ready, _process, _physics_process, etc.).
10. API pública.
11. Métodos privados.

No crear scripts extensos por comodidad. Si un script mezcla responsabilidades, dividirlo en componentes con límites claros.

3.4 CICLO DE VIDA Y PROCESAMIENTO

- Usar _physics_process() para movimiento y cálculos que deban sincronizarse con la física.
- Usar _process() para lógica dependiente del fotograma que no requiera sincronización física.
- Desactivar procesamiento en nodos que no lo necesiten.
- Evitar recorrer todos los NPC en cada fotograma para simular el mundo.
- La simulación de criaturas debe respetar los tres niveles del diseño:
  1. Simulación individual completa cerca del jugador.
  2. Simulación simplificada en zonas cercanas o activas.
  3. Simulación estadística en zonas lejanas.
- No usar _process() como sustituto de un sistema de eventos o de una simulación por intervalos.
- Evitar búsquedas repetidas de nodos en bucles críticos; conservar referencias válidas y gestionar correctamente su ciclo de vida.

3.5 ESCENAS, NODOS Y RECURSOS

- Cada escena debe representar una entidad, pantalla, zona o composición con una responsabilidad clara.
- Mantener árboles de nodos comprensibles y poco profundos cuando sea posible.
- Usar Resource para datos compartidos o configuraciones tipadas.
- No usar escenas como contenedores indiscriminados de lógica de negocio.
- Evitar dependencias rígidas entre rutas internas de nodos; exponer referencias o contratos claros.
- Definir una convención estable para carpetas, recursos, escenas y scripts antes de crecer.

3.6 SEÑALES Y COMUNICACIÓN

- Usar señales para comunicar eventos entre componentes que no deban conocerse directamente.
- No convertir todas las llamadas en señales: las llamadas directas son adecuadas cuando existe una dependencia explícita y estable.
- Evitar cadenas largas de señales difíciles de seguir.
- Documentar quién emite un evento, quién lo recibe y qué datos transporta.
- Desconectar señales cuando el ciclo de vida del objeto lo requiera.

3.7 ERRORES Y VALIDACIÓN

- Validar datos importados y recursos configurables al cargarlos.
- Comprobar referencias opcionales antes de utilizarlas.
- Fallar de forma explícita durante desarrollo si falta un recurso obligatorio.
- No capturar o ignorar errores sin registrar el motivo y definir una recuperación.
- Los errores de contenido deben señalar el archivo y el campo problemático.

==================================================
4. ARQUITECTURA Y CALIDAD ESPECÍFICAS DE BUG DE FAMILIA
==================================================

4.1 SISTEMAS SEPARADOS

Mantener límites claros entre, al menos:

- Protagonista y piezas modulares.
- Movimiento y navegación.
- Combate y pausa táctica.
- Criaturas y comportamiento individual.
- Simulación de población y ecosistema.
- Zonas y transiciones.
- Tiempo, día/noche y festividades.
- Anomalías ambientales.
- Misiones y acontecimientos.
- Conversión, materiales e inventarios.
- Diálogos, comunicación y audio.
- Guardado y carga.
- Interfaz y presentación.

La lista es una guía de separación, no una obligación de crear cientos de scripts.

El objetivo es que cada sistema pueda desarrollarse y probarse sin romper innecesariamente los demás.

4.2 CONTRATOS ENTRE SISTEMAS

- Definir entradas, salidas, eventos y responsabilidades de cada sistema.
- Evitar que un sistema modifique directamente variables internas de otro.
- Centralizar las reglas que deban ser invariantes, por ejemplo compatibilidad de piezas o condiciones de muerte.
- Mantener los datos de contenido separados del código que los interpreta.
- Documentar las dependencias y los flujos relevantes.

4.3 RENDIMIENTO

- Establecer objetivos de rendimiento y medirlos en hardware PC representativo.
- El objetivo orientativo de 40–60 personajes visibles simultáneamente debe validarse con perfiles reales; no es una garantía previa.
- Usar simulación escalonada y actualizaciones por intervalos para entidades lejanas.
- Evitar asignaciones y búsquedas innecesarias en bucles de alta frecuencia.
- Evaluar pooling, multithreading u optimizaciones avanzadas solo cuando el perfilador identifique un cuello de botella.
- No sacrificar claridad ni corrección por microoptimizaciones sin evidencia.

4.4 ALEATORIEDAD Y SIMULACIÓN REPRODUCIBLE

- Poder fijar semillas en pruebas.
- Registrar los datos necesarios para reproducir errores de simulación.
- Evitar que una prueba dependa del azar no controlado.
- Separar la generación aleatoria de contenido de las reglas que validan ese contenido.
- Al reanudar una partida, calcular el avance del mundo con límites y salvaguardas para evitar saltos destructivos.

4.5 GUARDADO Y MUERTE PERMANENTE

- Tratar el guardado como un sistema crítico.
- Probar interrupciones, datos incompletos, versiones incompatibles y recuperación ante corrupción técnica.
- La protección frente a corrupción no debe permitir revertir una muerte permanente ni recuperar una partida anterior.
- Una muerte del protagonista debe terminar la partida según las reglas aprobadas.
- Iniciar una partida nueva sobrescribe el único espacio de partida.
- No introducir ranuras adicionales, reaparición ni restauración de progreso sin aprobación del usuario.

==================================================
5. PRUEBAS OBLIGATORIAS
==================================================

Cada sistema debe incorporar pruebas automáticas desde su desarrollo, no dejar todas las pruebas para el final.

TIPOS DE PRUEBAS

- Unitarias: reglas y funciones aisladas; por ejemplo, compatibilidad de piezas, cálculo de daño o reproducción.
- Integración: comunicación entre sistemas; por ejemplo, una pieza rota durante un combate y su sustitución en pausa táctica.
- Regresión: errores corregidos que no deben reaparecer.
- Datos y contenido: validación de especies, piezas, eventos, materiales, diálogos y referencias a recursos.
- Rendimiento: escenarios reproducibles con poblaciones y situaciones exigentes.
- Persistencia: guardar, cerrar, cargar y simular el paso del tiempo; comprobar también la muerte permanente.

CRITERIOS PARA ACEPTAR UN CAMBIO

Un cambio no se considera terminado hasta que:

1. El proyecto importa y arranca sin errores nuevos.
2. Las pruebas relevantes pasan.
3. Se han probado las interacciones afectadas.
4. No se han introducido recursos rotos o referencias ausentes.
5. La documentación afectada está actualizada.
6. Se ha revisado el diff para detectar cambios accidentales.

No desactivar, borrar ni debilitar pruebas para conseguir un resultado verde.

Si una prueba deja de ser válida, justificar el cambio y sustituirla por otra que cubra el comportamiento esperado.

==================================================
6. DESARROLLO CON IA: NORMAS PARA CLAUDE CODE
==================================================

Claude actuará como ingeniero principal y agente de implementación, mientras el usuario mantiene la dirección del producto y aprueba las decisiones que cambien el diseño acordado.

6.1 AUTORIDAD Y LÍMITES

Claude puede decidir y ejecutar de forma autónoma:

- Estructura interna de carpetas y scripts.
- Nombres, tipos, algoritmos y patrones de implementación.
- División técnica de tareas y orden de trabajo.
- Herramientas locales auxiliares.
- Refactorizaciones que preserven el comportamiento aprobado.
- Pruebas técnicas, instrumentación y documentación.
- Ajustes de rendimiento respaldados por mediciones.

Claude debe pedir aprobación antes de:

- Cambiar plataforma, motor o lenguaje principal.
- Añadir dependencias online o servicios durante la partida.
- Cambiar controles, perspectiva, combate o reglas de muerte y guardado.
- Alterar el concepto, anatomía o funcionamiento aprobado del protagonista.
- Eliminar o cambiar sistemas o características de producto.
- Introducir monetización, telemetría, DRM o conexión obligatoria.
- Hacer cambios que afecten de forma sustancial al alcance o a la dirección artística.
- Sobrescribir o borrar recursos de usuario que no estén bajo control de versiones.

Ante una ambigüedad menor, elegir la opción más simple y coherente, documentarla y continuar.

Ante una ambigüedad que afecte al diseño del juego, detener solo esa decisión y preguntar; continuar con tareas independientes cuando sea posible.

6.2 FLUJO DE TRABAJO POR TAREA

Para cada tarea, Claude seguirá este ciclo:

1. Leer contexto: revisar CLAUDE.md, documentos de diseño, arquitectura, decisiones y código relacionado.
2. Definir objetivo: expresar brevemente qué comportamiento se va a conseguir y qué queda fuera.
3. Inspeccionar antes de editar: localizar escenas, scripts, recursos y pruebas existentes. No duplicar sistemas.
4. Planificar: dividir el trabajo en pasos pequeños y verificables.
5. Implementar: realizar cambios acotados, respetando los contratos existentes.
6. Probar: ejecutar pruebas relevantes y comprobar el arranque e importación del proyecto.
7. Revisar: examinar el diff, buscar efectos secundarios y validar que no se han alterado decisiones aprobadas.
8. Documentar: actualizar la documentación y el registro de decisiones si corresponde.
9. Informar: resumir qué se ha hecho, archivos afectados, pruebas ejecutadas, resultado y limitaciones pendientes.

No declarar una tarea terminada si no se han ejecutado las verificaciones posibles.

Distinguir claramente entre pruebas ejecutadas, pruebas no ejecutadas y resultados esperados.

6.3 CAMBIOS PEQUEÑOS Y REVERSIBLES

- Preferir entregas pequeñas que puedan revisarse y revertirse.
- Evitar reescrituras amplias cuando un cambio localizado sea suficiente.
- No mezclar refactorizaciones no relacionadas con la tarea principal.
- Crear commits con mensajes descriptivos cuando el flujo de trabajo del repositorio lo permita.
- No reescribir historial, borrar ramas ni ejecutar comandos destructivos sin autorización.
- Antes de una operación destructiva, explicar el alcance y solicitar confirmación.

6.4 USO RESPONSABLE DE HERRAMIENTAS

- Priorizar documentación oficial y versiones compatibles con el motor fijado.
- No instalar plugins, paquetes, ejecutables o herramientas de procedencia dudosa.
- No ejecutar comandos copiados de fuentes externas sin entender su efecto.
- No subir código, recursos, registros ni datos del proyecto a servicios externos sin autorización.
- No incluir claves, tokens, contraseñas ni datos personales en el repositorio.
- No asumir que una herramienta de IA ha producido un recurso correcto: inspeccionarlo, probarlo y validarlo.
- Mantener el juego final offline aunque el proceso de desarrollo pueda usar herramientas de IA externas, siempre que el usuario lo haya autorizado.

6.5 RECURSOS GENERADOS POR IA

Para imágenes, animaciones, música, sonidos, voces y textos:

- Registrar origen, herramienta, fecha, parámetros relevantes y licencia o condiciones de uso cuando proceda.
- Revisar calidad, coherencia artística, legibilidad, integración y rendimiento.
- Comprobar que no se han introducido marcas, personajes o material protegido de terceros de forma no autorizada.
- Mantener los originales y los recursos finales separados.
- No integrar un recurso generado directamente en el juego sin validación.
- Producir y validar paquetes completos de recursos antes de incorporarlos al proyecto.
- Para voces y música, confirmar que los archivos funcionan localmente y no requieren llamadas a servicios externos.

6.6 PROTECCIÓN FRENTE A ERRORES DE LA IA

Claude debe asumir que tanto el contexto como sus propias propuestas pueden ser incompletos.

Por ello:

- No inventar APIs de Godot, propiedades, métodos ni opciones de configuración.
- Comprobar las APIs contra la versión fijada del motor.
- No afirmar que una prueba se ha ejecutado si no se ha ejecutado.
- No sustituir una implementación real por pseudocódigo sin avisar.
- No dejar TODO, stubs o métodos vacíos como si la funcionalidad estuviera terminada.
- No ocultar errores con pass, @warning_ignore o capturas genéricas sin una razón documentada.
- No modificar decisiones aprobadas para hacer más fácil una implementación.
- Si detecta una contradicción entre documentos, código y requisitos, señalarla y proponer una resolución; no decidir silenciosamente sobre producto.

6.7 INFORME DE FINALIZACIÓN

Al terminar cada tarea, Claude entregará un informe breve con:

- Objetivo: comportamiento implementado.
- Cambios: archivos y sistemas afectados.
- Pruebas: comandos o pruebas ejecutadas y resultados.
- Validación manual: comprobaciones que requieren abrir el juego, si las hay.
- Pendiente: limitaciones, riesgos o tareas no completadas.
- Decisiones: decisiones técnicas tomadas y cualquier decisión de producto que requiera aprobación.

==================================================
7. DEFINITION OF DONE
==================================================

Una funcionalidad se considera terminada cuando:

- Cumple el comportamiento solicitado y respeta las decisiones aprobadas.
- Está implementada en el sistema adecuado, sin acoplamiento innecesario.
- Usa tipado y convenciones coherentes con el proyecto.
- Tiene pruebas automáticas apropiadas.
- Se integra correctamente con los sistemas afectados.
- No genera errores nuevos ni advertencias injustificadas.
- Tiene datos y recursos validados.
- No depende de servicios online durante la partida.
- Está documentada en la medida necesaria.
- Claude ha informado con transparencia de las pruebas y limitaciones.

==================================================
8. LIBRERÍAS, ADDONS Y HERRAMIENTAS REUTILIZABLES
==================================================

Godot incluye una API amplia y muchas capacidades que no necesitan dependencias externas.

Antes de incorporar una librería, Claude debe comprobar si el motor ya ofrece una solución suficiente.

8.1 CAPACIDADES NATIVAS: PRIMERA OPCIÓN

Usar primero las herramientas incluidas en Godot 4:

- Movimiento y matemáticas: Vector2, Transform2D, Geometry2D, CharacterBody2D y nodos relacionados.
- Búsqueda de caminos en cuadrícula: AStarGrid2D o AStar2D, según la representación del escenario.
- Navegación 2D: NavigationAgent2D y el sistema de navegación de Godot cuando encaje con los mapas y obstáculos.
- Animación: AnimationPlayer, AnimationTree, Skeleton2D, Bone2D y tweens.
- Datos: Resource, ResourceLoader, ResourceSaver, JSON y ConfigFile.
- Eventos y comunicación: señales, grupos y llamadas tipadas entre componentes.
- Audio: buses, reproductores, mezcladores y recursos de audio integrados.
- Interfaz: nodos Control, contenedores y temas.
- Aleatoriedad: RandomNumberGenerator, con semillas controladas para reproducir pruebas.

No añadir una librería externa para sustituir estas capacidades sin demostrar una ventaja concreta.

8.2 ADDONS CANDIDATOS PARA EL PROYECTO

Estos son candidatos para evaluar mediante una pequeña prueba de concepto.

No quedan todos aprobados para instalación automática.

Claude comprobará la compatibilidad con la versión exacta de Godot elegida, el estado de mantenimiento, la licencia, las plataformas soportadas y el coste de integración.

GDUNIT4

Uso:
- Pruebas unitarias.
- Pruebas de integración.
- Pruebas de escenas escritas en GDScript.

Recomendación:
Candidato prioritario para la infraestructura de pruebas. Elegir una versión compatible con el motor fijado.

Repositorio:
https://github.com/godot-gdunit-labs/gdUnit4

DIALOGUE MANAGER

Uso:
- Editor y ejecución de diálogos ramificados.
- Condiciones y respuestas.
- Conversaciones contextuales.
- Soporte de traducción.

Recomendación:
Candidato para prototipar conversaciones y diálogos de criaturas.

Repositorio:
https://github.com/nathanhoad/godot_dialogue_manager

PARLEY

Uso:
- Editor visual basado en nodos.
- Diseño, prueba y ejecución de secuencias de diálogo.

Recomendación:
Alternativa a Dialogue Manager. Evaluar solo si su flujo visual encaja mejor. No instalar ambos sin una necesidad real.

Documentación:
https://parley.bisterixstudio.com/docs/introduction

LIMBOAI

Uso:
- Árboles de comportamiento.
- Máquinas de estados jerárquicas.
- IA de criaturas y personajes.
- Comportamientos personalizados en GDScript.

Recomendación:
Candidato para comportamientos complejos. Probar primero una criatura representativa y revisar los requisitos de GDExtension/binarios para Windows y el resto de plataformas PC objetivo.

Repositorio:
https://github.com/limbonaut/limboai

CONSIDERACIONES SOBRE LIMBOAI

LimboAI está implementado en C++ y se integra con Godot como extensión o módulo, aunque permite escribir comportamientos personalizados en GDScript.

Su uso no cambia el lenguaje principal del juego, pero añade una dependencia compilada que debe validarse para las exportaciones de PC objetivo.

Si una versión compatible no está disponible o la dependencia complica la distribución, Claude implementará una solución interna sencilla con GDScript.

8.3 SELECCIÓN INICIAL RECOMENDADA

La propuesta inicial de evaluación es:

1. GdUnit4: probarlo primero para dar soporte a las pruebas automáticas desde el inicio.
2. Un solo sistema de diálogos: comparar Dialogue Manager y Parley con un prototipo que incluya conversación ramificada, condiciones, respuestas, eventos del mundo y persistencia. Elegir uno o mantener un sistema propio si ambos introducen limitaciones.
3. LimboAI: no incorporarlo al principio por anticipado. Evaluarlo cuando exista una criatura con comportamiento suficientemente complejo para justificar árboles de comportamiento o máquinas de estados jerárquicas.
4. Navegación, animación, datos, audio e interfaz: empezar con las capacidades nativas de Godot.

La selección final corresponde a Claude en el plano técnico, siempre que respete estas reglas y documente la decisión.

Si la elección afecta al diseño del juego, al alcance o a una decisión aprobada, debe consultar al usuario.

8.4 POLÍTICA DE DEPENDENCIAS

Antes de añadir cualquier librería o addon, Claude debe:

1. Identificar el problema concreto que resuelve y por qué la API nativa no basta.
2. Comprobar que funciona con la versión exacta de Godot fijada para el proyecto.
3. Revisar actividad del repositorio, publicaciones, incidencias abiertas y señales de mantenimiento.
4. Revisar licencia y condiciones de uso, especialmente si el juego se distribuye comercialmente.
5. Confirmar que funciona en las plataformas PC que se vayan a soportar y que no requiere servicios online durante la partida.
6. Evaluar tamaño, rendimiento, dependencias transitivas, binarios y dificultad de actualización.
7. Crear una prueba de concepto aislada antes de integrarla en los sistemas principales.
8. Registrar nombre, versión exacta, origen, licencia, finalidad y procedimiento de actualización.
9. Fijar la versión utilizada; no actualizar dependencias automáticamente sin ejecutar las pruebas.
10. Mantener una alternativa o plan de sustitución cuando la dependencia sea crítica.

No añadir dependencias por popularidad, moda o comodidad puntual.

Cada dependencia aumenta el coste de mantenimiento y puede introducir incompatibilidades futuras.

8.5 SEGURIDAD, OFFLINE Y DISTRIBUCIÓN

- El juego no debe descargar código, datos, voces, música ni recursos durante la partida.
- Los addons se integran en el proyecto durante el desarrollo y sus componentes necesarios se distribuyen localmente con el juego.
- No incorporar telemetría, anuncios, analítica, DRM ni conexiones remotas sin autorización expresa.
- Revisar el código y los binarios de cada dependencia antes de integrarlos.
- Mantener un inventario de dependencias y licencias para preparar la distribución del juego.
- Comprobar que las licencias permiten el uso y la distribución previstos.
- Una herramienta de desarrollo puede necesitar conexión para instalarse o actualizarse; eso no autoriza a que el juego final dependa de ella en tiempo de ejecución.

8.6 DÓNDE BUSCAR E INSTALAR

La fuente preferida es la Asset Library de Godot y el repositorio oficial del proyecto.

La documentación de Godot explica la instalación y activación de plugins:

Instalación de plugins:
https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html

Creación de plugins:
https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html

Distinguir entre:

- Plugin de editor: amplía el editor y puede necesitar activación en Project Settings → Plugins.
- Librería o scripts de runtime: se incorporan al proyecto y se usan desde GDScript; no necesariamente requieren activar un plugin.
- GDExtension: añade código compilado y exige comprobar los binarios disponibles para cada plataforma y versión.
- Asset o recurso: imágenes, audio, shaders, escenas, fuentes y otros contenidos; revisar siempre licencia y compatibilidad.

==================================================
9. REFERENCIAS OFICIALES
==================================================

Consultar siempre la documentación correspondiente a la versión concreta de Godot utilizada.

MANUAL DE GDSCRIPT:
https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/

GUÍA DE ESTILO DE GDSCRIPT:
https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html

BUENAS PRÁCTICAS DE SCRIPTING:
https://docs.godotengine.org/en/stable/tutorials/best_practices/

ORGANIZACIÓN DE PROYECTOS:
https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html

RECURSOS:
https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html

PLUGINS DE EDITOR:
https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html

CLAUDE CODE:
https://docs.anthropic.com/en/docs/claude-code/overview

REGLA DE MANTENIMIENTO:

Si la documentación oficial cambia entre versiones, prevalece la documentación de la versión fijada del motor.

Las normas de este documento son reglas del proyecto; cualquier excepción debe justificarse y documentarse.
