# Decisiones vigentes

Fuente única de lo que está decidido. Si otro documento dice otra cosa, manda este, salvo lo marcado como conflicto en `01_CONFLICTOS_Y_PENDIENTES.md`.

**Orden de prioridad:** decisión más reciente del director > este registro > documentos especializados de este paquete > fuentes antiguas (PDF del 4-nov, maestro v0.3, consolidada v0.5).

## Producto
| Tema | Decisión | Fecha |
|---|---|---|
| Plataforma | PC exclusivamente. Android descartado definitivamente | 8-nov |
| Controles | Teclado y ratón exclusivamente, al estilo WoW adaptado a cámara fija (`controles.md`). Sin mando ni táctil | 8-nov |
| Perspectiva | Vista alta inclinada, tipo Zelda, con cámara de ángulo fijo. Ni isométrica ni cenital pura | 8-nov |
| Núcleo | Sigilo táctico + investigación | 8-nov |
| Motor | Godot 4.7.2 estable con GDScript tipado (ver `adr/0001-motor-y-pruebas.md`) | 8-nov |
| Conectividad | Juego completamente offline. Sin IA generativa en ejecución | 6-nov |
| Idioma | Español, con los textos separados del código | 8-nov |
| Modelo | Gratuito, por hobby, sin anuncios, compras, telemetría ni DRM. Actualizaciones gratuitas | 4-nov |
| Plazo | Sin plazo | 4-nov |
| Roles | El usuario dirige y prueba; Claude programa, integra, prueba y documenta | 4-nov |
| Dificultad | Fija, sin selector ni adaptación | 6-nov |
| Modo de juego | Un jugador. Sin multijugador, nube obligatoria, cuentas ni mods | 6-nov |

## Guardado y muerte
- Autoguardado en puntos de guardado y momentos seguros. Un único espacio de partida.
- Muerte permanente del protagonista. Nueva partida desde cero, que sobrescribe la anterior.
- Muerte inmediata al quedarse sin piernas (8-nov).
- La cabeza tiene repuestos como las extremidades y se puede cambiar en plena pelea. Si se rompe y no queda ninguno, muerte inmediata (8-nov).
- Con una sola pierna: mitad de velocidad y sin correr (8-nov).
- La protección ante corrupción técnica no permite revertir una muerte.
- Al terminar la partida: resumen de lo aprendido y críticas de las IAs.

## Protagonista
- Sujeto Sobrante: experimento fallido, híbrido de robot, animal e IA.
- Cuatro brazos (dos desde los hombros, dos desde los omóplatos), dos piernas, una cabeza y una cola. Las seis extremidades y la cabeza son modulares.
- La hoja de diseño (`Hoja de diseño del simio cyborg neón.png`) es la referencia visual.
- Aspecto: el de la hoja, medio mono medio robot. Origen: experimento híbrido.
- Sin niveles, experiencia, barra de salud, hambre, sed ni descanso.

## Conversión y piezas
- La conversión es la del diseño original: **nunca falla** y el conocimiento decide la calidad (8-nov).
- La conversión es la única forma de crear piezas. No existe fabricación aparte (8-nov).
- Las preguntas de conversión también verifican: confirman claramente si un dato era cierto o falso (8-nov).
- Descartar piezas recarga tokens de una IA dormida; lo que exceda su capacidad se pierde (8-nov).
- Inventario: 4 repuestos por zona del cuerpo (6 extremidades y cabeza), 28 en total (8-nov).
- Una pierna dura unos 10 minutos andando sin parar (8-nov).
- Los golpes caen sobre todo en extremidades; la cabeza, mucho menos (8-nov).
- Cambio de piezas (8-nov): si no estás interactuando, libertad total. Si va a empezar una pelea, hay una pausa inicial para elegir piezas. En medio de la pelea, solo se cambia una pieza cuando se destruye una puesta, y la selección pausa el juego.

## Mundo y misiones
- Zonas conectadas, de geometría diseñada a mano, con contenido variable por partida.
- Día y noche con la hora local real, de forma estricta (8-nov).
- Con el juego cerrado el mundo se congela. Las festividades pasadas dejan rastro al volver (restos y comentarios), sin simular nada más (8-nov).
- Geometría de zona fija, con estados diseñados de antemano como puente roto o zona inundada (8-nov).
- Pueden nacer y llegar nuevos individuos también en directo, con el jugador presente (8-nov).
- Sin vehículos, pero se puede viajar entre puntos de guardado (8-nov).
- Rol fijo por individuo, con cargos sociales aparte que sí cambian (8-nov).
- Los personajes aprenden hechos, lugares y relaciones, pero no habilidades (8-nov).
- Historia larga de las seis especies; dos razas alienígenas llegaron a este planeta antes del colapso y dos después (8-nov).
- 36 festividades fijas al año, tres por mes.
- Tres niveles de simulación: completa cerca, simplificada en zonas próximas y estadística en zonas lejanas.
- Misiones en dos capas: retos diseñados y misiones emergentes de acontecimientos (8-nov).
- Muerte individual permanente de NPC; las poblaciones se recuperan por reproducción.
- Los humanos existieron y desaparecieron (8-nov).
- Sin final fijo. Historias independientes conectadas por un misterio general.

## IAs
- Una IA se pierde para siempre al acumular varios agravios: tres enfados graves o una pelea física, según su personalidad (8-nov).
- Descartar una pieza da una recarga mínima de tokens: hacen falta muchas para despertar a una IA (8-nov).

## Combate
- Preguntas con tiempo solo al convertir y en encuentros tensos; el resto es conversación contextual (8-nov).
- Tiempo real con pausa táctica. Durante la pausa: cambiar piezas permitidas, seleccionar objetivos y planificar acciones.
- Las soluciones no violentas valen lo mismo que las violentas. Siempre hay al menos una vía sin matar.

## Conocimiento
- El conocimiento pertenece al jugador: sin diario ni enciclopedia automática.
- Todo misterio tiene explicación objetiva, aunque el jugador no la descubra.
- Nadie está protegido por el guion.

## Producción
- Sprites en 8 direcciones (8-nov).
- Las imágenes base las genera el usuario con ChatGPT, con el acabado pintado de la hoja de diseño. Claude recorta, limpia, prepara, anima e integra (8-nov).
- Las versiones SVG del protagonista se descartaron por no alcanzar ese acabado.
- Recursos por paquetes completos y validados. Todo recurso de la partida es local.
- El prototipo usa gráficos sencillos para probar la diversión; el arte final llega después.

## Beta
- Una zona de bosque con ciudades perdidas, cuatro retos y solo Mohócratas y Jubilados de Hierro, en tensión por la chatarra (8-nov).
- Antes de la beta se define solo el mapa y los progenitores que necesita (8-nov).
- Progenitores de la beta: El Contestador (IA vieja) y Don Ramón de Mantenimiento (robot).

## Lo que no se puede inventar
Progenitores y su origen, personalidades de las IA, reglas de tokens, mapa, barra de salud, diario, personajes protegidos, multijugador, conexión online, vehículos, recetas cerradas de conversión.

## Autonomía de Claude
**Decide solo y documenta:** módulos, algoritmos, datos, herramientas locales, orden técnico de tareas, parámetros provisionales, refactorizaciones, optimizaciones medidas y decisiones artísticas menores.

**Pregunta antes de:** cambiar plataforma, motor, controles o perspectiva; alterar mecánicas, muerte, guardado, combate, conversión, tokens o el protagonista; añadir dependencias online; eliminar características; convertir objetivos orientativos en límites que reduzcan el alcance; y subir código o recursos a servicios externos.

## Objetivos orientativos (a validar, no son promesas)
40–60 personajes visibles · al menos 100 melodías · voces en al menos 40 idiomas o acentos · diez vías para cada fragmento de lore importante, cuando sea razonable.

## Decisiones sustituidas
| Antes | Ahora |
|---|---|
| Android, control táctil, mando | PC con teclado y ratón |
| Isométrica; después, cenital | Vista alta inclinada |
| Guardado solo en puntos concretos | Autoguardado en puntos y momentos seguros |
| Conversión que puede fallar, con mesa o recetas | Conversión que nunca falla |
| Misiones solo fijas o solo dinámicas | Dos capas |
| Gráficos solo SVG sin generadores externos | Imágenes base con ChatGPT |
| Generador de imágenes integrado en Claude | El usuario genera con ChatGPT |
| Fabricación experimental aparte | Solo conversión |
| Solo sustituir piezas rotas, siempre | Libre fuera de peleas, pausa inicial y sustitución al destruirse en pelea |
| Protagonista cuadrúpedo tipo zorro | Humanoide de cuatro brazos, dos piernas y cola |
| Límite fijo de 20 NPC por especie | Configurable por especie y zona |
| Reaparición o recuperación del protagonista | Muerte permanente |
