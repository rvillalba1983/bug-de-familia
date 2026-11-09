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
- Si el único guardado se corrompe, se empieza otra partida, sin copias de seguridad (8-nov).
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
- Mohócratas y Grux llegaron a este planeta después del colapso; las otras dos razas alienígenas ya estaban. Todas se conocían fuera de este planeta, y por eso pudieron influir en sucesos anteriores (8-nov).
- Si muere un personaje único aliado, se pierde para siempre y deja huella: restos y comentarios de otros personajes. Lo que sabía solo se recupera por otras pistas (8-nov).

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
- Todo el arte del juego se hace con Godot y SVG. Se descarta generar imágenes con ChatGPT (9-nov).
- La hoja de diseño del protagonista sigue siendo la referencia visual. El protagonista se dibuja con polígonos de Godot, por piezas, calcado de ella (9-nov).
- Paleta «Cuñado Radiactivo» y reglas de estilo en `36_pipeline_graficos.md` (9-nov).
- Recursos por paquetes completos y validados. Todo recurso de la partida es local.
- El prototipo usa gráficos sencillos para probar la diversión; el arte final llega después.

## Interacción (8-nov)
- Los objetos se recogen solo con pasar por encima, sin pulsar nada.
- Convertir usa una tecla propia (Q): actúa sobre lo convertible más cercano al alcance, que se marca en el mundo.

## Armas a distancia (8-nov)
- Existen al menos cuatro, creadas por conversión con su propio objetivo; además, lanzar chatarra (F) está siempre disponible.
- Romper una caja deja restos visibles, que se pueden convertir.

## Beta
- Una zona de bosque con ciudades perdidas, cuatro retos y solo Mohócratas y Jubilados de Hierro, en tensión por la chatarra (8-nov).
- Antes de la beta se define solo el mapa y los progenitores que necesita (8-nov).
- Progenitores de la beta: El Contestador (IA vieja) y Don Ramón de Mantenimiento (robot).
- Mapa de la beta (8-nov): ciudad perdida en el centro con la chatarra en disputa, Jubilados al norte, Mohócratas al sur, tierra de nadie entre ambos y bosque alrededor. Un bando por raza.
- El Contestador sigue en una centralita sellada y solo reproduce mensajes grabados de los progenitores discutiendo el experimento. Con la bobina recuperada se oye el resto (8-nov).
- Don Ramón va errante reparando cosas y solo habla si antes discutes o peleas con él: revela que te escondió de los demás progenitores (8-nov).
- Ambos progenitores pueden morir. El reto de Don Ramón cuenta al encontrarlo (8-nov).
- El apagón de los Jubilados va de las 21:00 a las 8:00 reales. Es una ventaja, y ningún reto depende de él (8-nov).
- Al completar los cuatro retos, las IAs comentan lo logrado y se sigue jugando en la zona (8-nov).
- Enemigos y peligros de la beta: patrullas de las dos razas, cámaras y drones viejos, minas y lluvia ácida ocasional, que destruye piezas metálicas. Las zonas que quitan habilidades quedan para después (8-nov).

## Pendientes cerrados (8-nov)
- **Lumi Influencer:** crea señuelos y atrae seguidores curiosos que distraen a los enemigos (P-15).
- **Publicación:** itch.io, descarga gratuita (P-16).
- **Ausencias largas:** si una especie cae mucho en una zona sin el jugador, llegan individuos que migran desde otra (P-17).
- **Zonas que quitan cosas:** hay dos tipos, las que desgastan o rompen piezas de forma permanente y las que silencian a las IAs activas y anulan sus ventajas mientras estés dentro (P-04).
- **Misiones emergentes:** las cuentan las IAs activas y los personajes cercanos, sin lista ni marcadores. Pueden dar piezas, información y favores, sin moneda, o no dar premio directo y solo cambiar el mundo (P-11).
- **Cadenas de consecuencias:** máximo 4 pasos, y el mismo suceso no se repite en una zona hasta pasado un tiempo de enfriamiento (P-13).
- **Difusión de información:** si pasa algo interesante, quienes lo ven van hacia otros personajes o incluso a otras zonas a contarlo (P-14).
- **Relaciones entre razas:** las iniciales salen del lore y cambian con lo que ocurra en cada partida (P-10).
- **Viaje rápido:** desde un punto de guardado a cualquier otro ya visitado, nunca en plena pelea. El mundo sigue durante el viaje y cada viaje cuesta desgaste de piernas y tokens de las IAs activas.
- **Progenitores en la beta:** Don Ramón te suelda un repuesto al contarte la verdad; El Contestador solo da historia.
- **Zonas lejanas:** solo ocurren sucesos grandes (población, guerras, migraciones y festividades), que llegan como rumores o se ven al volver (P-13).
- **Tono:** muy ofensivo con el protagonista, la humanidad y las máquinas, sin ataques a colectivos reales (P-09).
- **Peligros de la beta:** mina de 45 de daño; lluvia ácida a intervalos irregulares; de 5 a 10 s al azar para responder en encuentros tensos; Don Ramón se rinde al perder el 70 % de su salud.
- **Alcance de los rumores:** no se mide en distancia. Durante los 4 minutos siguientes al acontecimiento, quienes lo han visto y todos los que se van enterando lo propagan hasta donde les dé tiempo. Pasado ese plazo, nadie más lo difunde (P-14).
- **Rumores:** cada persona que cuenta algo puede cambiar detalles. Un suceso grande altera a esa especie en la zona durante unos días (P-14).
- **Conocimiento por individuo:** cada rol sabe de lo suyo y la especie marca cómo lo cuenta. El rol es fijo y se asigna al nacer según lo que necesite su grupo (P-14).
- **Descubrir consecuencias:** por restos, cambios en el mundo y conversaciones, y las IAs dicen lo que observan sin explicar la causa. El resumen de fin de partida revela cada cadena solo hasta donde llegó (P-13).
- **Contenido por encargo:** Claude propone las compatibilidades del catálogo y el director revisa la tabla (P-02); Claude implementa las 20 IAs definidas y ajusta números jugando (P-05); Claude escribe preguntas, motes y comentarios, y el director marca lo que no le haga gracia (P-09).

## Lo que no se puede inventar
Progenitores y su origen, personalidades de las IA, reglas de tokens, mapa, barra de salud, diario, personajes protegidos, multijugador, conexión online, vehículos, recetas cerradas de conversión.

## Fase 8 (9-nov)
- Las zonas nuevas, los tres niveles de simulación y el viaje entre puntos de guardado se aplazan a una etapa post-beta. La fase 8 se hace dentro de la zona beta, sin cambiar lo decidido para el juego completo.
- Claude escribe las 36 festividades (`data/world/festivals.json`) y el director tacha las que no le gusten.

## Fase 9 (9-nov)
- Las otras cuatro razas y los 13 progenitores restantes se aplazan a la etapa post-beta. La zona beta sigue con solo Mohócratas y Jubilados.
- La música se sintetiza por código hasta las 100 melodías, sabiendo que serán más parecidas entre sí.
- Controles: chapa con F1 y ventana tipo chat arriba a la izquierda.
- La silueta del cuerpo se usa también al cambiar piezas.
- En la pausa táctica el mundo se oscurece y se cubre de niebla, y las tres IAs activas aparecen como fantasmas de colores, con ojos y boca propios según su personalidad, divagando (9-nov; antes eran las 20). No gasta tokens.
- La vista de cambio de piezas va centrada, con el personaje casi a pantalla completa y las piezas dibujadas enteras. Cada pieza muestra su nivel (1 a 5, color del marco) y si es especial (estrella). Los valores concretos de sus estadísticas siguen sin mostrarse.

## Cierre de la beta (9-nov)
- Población: 18 por especie al empezar, objetivo 20 y máximo 26. Provisional.
- Controles: ver `controles.md`. Esc sale de cualquier panel; C, F1 y M solo abren.
- El chat de las IAs enseña solo sus últimos 4 mensajes, sin scroll ni historial.
- Al convertir se ve qué llevas y cuántos repuestos quedan en cada zona.
- Las consecuencias al salir de la zona siguen en la etapa post-beta: no hay por dónde salir.

## Optimización en gráfica integrada (9-nov)
- Personajes dibujados al 50 % de su tamaño. Solo visual: colisiones, alcances y detección no cambian.
- Cola del protagonista quieta. Su color sigue indicando qué IA habla.
- Efectos en movimiento reducidos: charcos, cables, plantas y copas quietos, sin moscas ni humo, y menos lluvia y esporas.
- Límite opcional de 30 imágenes por segundo en las opciones, apagado por defecto.

## Autonomía de Claude
- Una fase por conversación: termina al fusionar en `main`, se anota el avance en `03_ESTADO.md` y se avisa al usuario de que hay que cambiar de conversación (8-nov).
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
| Imágenes base con ChatGPT | Arte con Godot y SVG |
| Descarte del protagonista en SVG por su acabado | Protagonista con polígonos de Godot, aprobado para seguir (9-nov) |
| Fabricación experimental aparte | Solo conversión |
| Solo sustituir piezas rotas, siempre | Libre fuera de peleas, pausa inicial y sustitución al destruirse en pelea |
| Protagonista cuadrúpedo tipo zorro | Humanoide de cuatro brazos, dos piernas y cola |
| Límite fijo de 20 NPC por especie | Configurable por especie y zona |
| Reaparición o recuperación del protagonista | Muerte permanente |
