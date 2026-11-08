> Decidido el 8-nov: los personajes aprenden hechos, lugares y relaciones, pero no habilidades. Rigen los tres niveles de simulación de `02_DECISIONES.md`; los cuatro niveles de actividad de aquí son internos del motor social.

# BUG DE FAMILIA
## ESPECIFICACIÓN TÉCNICA — MOTOR DE CONVERSACIONES Y SIMULACIÓN SOCIAL

**Versión:** 1.0
**Motor:** Godot 4
**Lenguaje:** GDScript tipado
**Funcionamiento:** 100 % offline, sin IA generativa y sin conexión a Internet.

---

# 1. OBJETIVO DEL SISTEMA

Construir un motor de simulación social y conversaciones contextuales que permita crear personajes autónomos con personalidad, memoria, conocimientos, creencias, relaciones, objetivos e intenciones propias.

El mundo debe evolucionar sin depender de la presencia del protagonista.

Los personajes deben poder:
- Conversar entre ellos.
- Compartir información.
- Mentir deliberadamente.
- Equivocarse.
- Desarrollar creencias.
- Recordar acontecimientos.
- Olvidar información irrelevante.
- Establecer relaciones.
- Crear y transmitir rumores.
- Modificar sus opiniones.
- Desarrollar conflictos.
- Actuar según sus propios objetivos.
- Reaccionar a acontecimientos sin intervención del jugador.

El sistema debe ser reutilizable para todas las especies y personajes del videojuego.

# 2. PRINCIPIOS FUNDAMENTALES

1. Los personajes funcionan independientemente del protagonista.
2. Cada personaje tiene conocimientos y recuerdos individuales.
3. Existe una verdad objetiva de los acontecimientos.
4. Los personajes pueden interpretar incorrectamente los hechos.
5. Los personajes pueden mentir conscientemente.
6. Los personajes tienen personalidad estable y emociones dinámicas.
7. Las relaciones sociales pueden ser asimétricas.
8. Los personajes tienen objetivos individuales y colectivos.
9. La información se transmite mediante rutas de comunicación.
10. Las sociedades pueden desarrollar creencias colectivas.
11. El motor debe ser determinista cuando se utilice la misma semilla y el mismo estado inicial.
12. Las conversaciones se generan mediante reglas, condiciones, puntuaciones y fragmentos de texto.
13. El sistema no depende de árboles de diálogo tradicionales como mecanismo principal.
14. La historia objetiva no puede modificarse por una conversación.
15. El mundo debe poder simularse por eventos y niveles de actividad.

# 3. ARQUITECTURA GENERAL

El sistema estará dividido en los siguientes motores independientes:

## 3.1. World Engine
Gestiona:
- Tiempo del mundo.
- Día y noche.
- Zonas.
- Poblaciones.
- Clima.
- Acontecimientos ambientales.
- Actividad de las especies.
- Migraciones.
- Reproducción.

## 3.2. Truth Engine
Gestiona:
- Historia objetiva.
- Hechos históricos.
- Acontecimientos reales.
- Relaciones causales.
- Cronología.
- Evidencias físicas.
- Origen de los misterios.

Los hechos objetivos deben tener una explicación coherente y descubrible.

## 3.3. Knowledge Engine
Gestiona:
- Conocimientos individuales.
- Creencias.
- Información adquirida.
- Fuentes de información.
- Credibilidad.
- Evidencias.
- Contradicciones.
- Información oculta.

## 3.4. Memory Engine
Gestiona:
- Recuerdos individuales.
- Experiencias.
- Conversaciones importantes.
- Intensidad emocional.
- Consolidación de recuerdos.
- Olvido progresivo.
- Memoria social.

## 3.5. Social Engine
Gestiona:
- Relaciones entre personajes.
- Grupos.
- Jerarquías.
- Alianzas.
- Rivalidades.
- Familias.
- Deudas.
- Enemistades.
- Relaciones colectivas.

## 3.6. Personality Engine
Gestiona:
- Rasgos de personalidad.
- Emociones.
- Preferencias.
- Aversión.
- Miedos.
- Costumbres.
- Cambios de personalidad a largo plazo.

## 3.7. Motivation Engine
Gestiona:
- Objetivos individuales.
- Objetivos colectivos.
- Prioridades.
- Necesidades.
- Intenciones.
- Selección de acciones.

## 3.8. Rumor Engine
Gestiona:
- Creación de rumores.
- Transmisión.
- Distorsión.
- Propagación entre grupos.
- Fiabilidad de las fuentes.
- Caducidad.
- Repercusiones sociales.

## 3.9. Dialogue Engine
Gestiona:
- Contexto de conversación.
- Interpretación de intenciones.
- Generación de opciones contextuales.
- Selección de respuestas.
- Variantes lingüísticas.
- Consecuencias.
- Actualización de recuerdos y relaciones.

## 3.10. Consistency Engine
Gestiona:
- Coherencia cronológica.
- Coherencia de acontecimientos.
- Ubicación de personajes.
- Relaciones válidas.
- Procedencia de conocimientos.
- Estado de personajes.
- Integridad de los datos.

# 4. MODELO DE PERSONAJES

Cada personaje tendrá un identificador permanente.

Ejemplos:
- NPC_000142
- NPC_000143
- NPC_000144

Cada personaje estará compuesto por los siguientes componentes.

## 4.1. Identidad

- Identificador.
- Especie.
- Nombre.
- Edad.
- Sexo.
- Grupo.
- Rol social.
- Ubicación.
- Estado vital.

## 4.2. Personalidad

Rasgos numéricos de 0 a 100:

- Agresividad.
- Curiosidad.
- Sociabilidad.
- Egoísmo.
- Generosidad.
- Cobardía.
- Ambición.
- Honestidad.
- Suspicacia.
- Empatía.

También tendrá preferencias y aversiones.

Los rasgos serán relativamente estables, aunque podrán cambiar después de experiencias importantes.

## 4.3. Emociones

Valores dinámicos de 0 a 100:

- Miedo.
- Ira.
- Alegría.
- Confianza.
- Tristeza.
- Frustración.
- Curiosidad.
- Ansiedad.

Las emociones pueden cambiar rápidamente según los acontecimientos.

## 4.4. Relaciones

Cada personaje tendrá relaciones individuales con otros personajes.

Variables posibles:
- Confianza.
- Afecto.
- Respeto.
- Miedo.
- Rivalidad.
- Deuda.
- Lealtad.
- Dependencia.

Las relaciones pueden ser asimétricas.

## 4.5. Objetivos

Cada personaje tendrá objetivos individuales y, cuando corresponda, colectivos.

Ejemplos:
- Sobrevivir.
- Conseguir comida.
- Proteger a su familia.
- Defender su grupo.
- Investigar algo.
- Conseguir un objeto.
- Evitar a determinada especie.
- Buscar pareja.
- Vengarse.
- Conseguir prestigio.

# 5. SISTEMA DE CONOCIMIENTO

Los conocimientos estarán separados de la verdad objetiva.

## 5.1. Hechos objetivos

Cada hecho tendrá un identificador único.

Ejemplos:

- CITY_UNDERGROUND_EXISTS.
- CITY_DESTROYED.
- ANCIENT_WAR.
- SURVIVOR_SPECIES_EXISTS.

Los hechos se almacenan en el Truth Engine.

## 5.2. Creencias individuales

Cada personaje podrá:
- Conocer un hecho.
- Desconocerlo.
- Creer que es verdadero.
- Creer que es falso.
- Tener dudas.
- Conocer versiones contradictorias.

Cada creencia tendrá un grado de confianza.

## 5.3. Procedencia de la información

Cada conocimiento almacenará:
- Identificador del hecho.
- Fuente.
- Personaje que lo transmitió.
- Lugar de adquisición.
- Fecha.
- Si fue presenciado directamente.
- Evidencias disponibles.
- Nivel de confianza.
- Distorsión.
- Motivación para ocultarlo.

## 5.4. Contradicciones

El sistema debe permitir:
- Creencias incompatibles.
- Información incorrecta.
- Mentiras.
- Interpretaciones diferentes.
- Personajes que conocen la verdad pero no la aceptan.
- Personajes que poseen varias versiones de un acontecimiento.

Las creencias contradictorias no deben considerarse errores del sistema.

# 6. SISTEMA DE MEMORIA

Se utilizarán tres tipos de memoria.

## 6.1. Memoria episódica

Experiencias personales.

Ejemplo:
"El protagonista me salvó de un depredador".

## 6.2. Memoria semántica

Conocimientos adquiridos sobre el mundo.

Ejemplo:
"La especie de los habitantes del norte es peligrosa".

## 6.3. Memoria social

Información sobre otros personajes.

Ejemplo:
"NPC_000143 suele mentir".

Cada recuerdo tendrá:
- Identificador.
- Fecha.
- Importancia.
- Intensidad emocional.
- Personajes implicados.
- Lugar.
- Hechos relacionados.
- Estado de consolidación.

Los recuerdos importantes pueden permanecer durante toda la partida. Los irrelevantes pueden olvidarse progresivamente.

# 7. SOCIEDADES Y PROPAGACIÓN DE RUMORES

Cada grupo social tendrá:
- Identidad.
- Especie.
- Miembros.
- Estructura de autoridad.
- Creencias colectivas.
- Tradiciones.
- Objetivos.
- Recursos.
- Relaciones con otros grupos.
- Enemigos.
- Aliados.
- Rumores conocidos.

## 7.1. Propagación

Los rumores pueden:
- Originarse deliberadamente.
- Originarse por equivocación.
- Transmitirse entre individuos.
- Distorsionarse.
- Ser rechazados.
- Ser aceptados.
- Generar conflictos.
- Convertirse en creencias colectivas.

Cada rumor tendrá:
- Origen.
- Fuente.
- Alcance geográfico.
- Fiabilidad.
- Distorsión.
- Velocidad de transmisión.
- Importancia.
- Caducidad.

No todos los personajes deben conocer todos los rumores.

La información necesita una ruta de transmisión.

# 8. SISTEMA DE OBJETIVOS E INTENCIONES

Se utilizará un sistema de selección de comportamientos basado en puntuaciones y reglas (Utility AI).

Ejemplo de prioridades iniciales:

- Evitar morir: 100.
- Proteger descendencia: 95.
- Defender al grupo: 85.
- Conseguir comida: 75.
- Investigar un ruido: 40.
- Hablar con desconocidos: 15.

Las prioridades cambiarán según el contexto.

Los personajes podrán interrumpir conversaciones para atender necesidades o amenazas.

# 9. MOTOR DE CONVERSACIONES CONTEXTUALES

El jugador no tendrá un listado fijo de preguntas.

El sistema generará opciones dinámicamente según:

- Conocimientos del jugador.
- Conocimientos del NPC.
- Relación entre ambos.
- Recuerdos.
- Personalidad.
- Emociones.
- Objetivos.
- Acontecimientos anteriores.
- Situación del mundo.
- Contexto de la conversación.

## 9.1. Categorías de intenciones

Información:
- Preguntar.
- Investigar.
- Aclarar.

Social:
- Saludar.
- Bromear.
- Elogiar.
- Insultar.

Persuasión:
- Convencer.
- Negociar.
- Prometer.

Conflicto:
- Acusar.
- Amenazar.
- Intimidar.

Cooperación:
- Ayudar.
- Ofrecer.
- Solicitar.

Información propia:
- Revelar.
- Ocultar.
- Mentir.

Relaciones:
- Disculparse.
- Agradecer.
- Reconciliarse.

Conversación:
- Cambiar de tema.
- Insistir.
- Terminar.

## 9.2. Generación de opciones

El proceso será:

1. Obtener el contexto del jugador y del NPC.
2. Consultar conocimientos.
3. Consultar recuerdos.
4. Consultar relaciones.
5. Consultar emociones.
6. Consultar objetivos.
7. Evaluar intenciones disponibles.
8. Comprobar condiciones.
9. Generar opciones.
10. Mostrar opciones al jugador.

## 9.3. Selección de respuestas

Cada respuesta tendrá:
- Condiciones.
- Prioridad.
- Intención.
- Tema.
- Fragmentos de texto.
- Efectos.
- Variantes.

Las respuestas se construirán combinando fragmentos compatibles.

No se utilizará generación de lenguaje mediante IA.

# 10. ESTRUCTURA TÉCNICA EN GODOT

Carpetas:

res://

- core/
  - game_manager.gd
  - event_bus.gd
  - world_clock.gd
  - save_manager.gd

- simulation/
  - world_engine/
  - truth_engine/
  - knowledge_engine/
  - memory_engine/
  - social_engine/
  - personality_engine/
  - motivation_engine/
  - rumor_engine/

- dialogue/
  - dialogue_engine.gd
  - context_builder.gd
  - intent_resolver.gd
  - option_generator.gd
  - response_selector.gd
  - consequence_executor.gd
  - dialogue_ui.gd

- entities/
  - npc/
  - species/
  - groups/
  - objects/

- data/
  - facts/
  - events/
  - personalities/
  - species/
  - dialogue/
  - intentions/
  - relationships/

- persistence/
  - world_snapshot.gd
  - event_log.gd
  - migration_manager.gd

- tests/
  - dialogue/
  - knowledge/
  - social/
  - simulation/

## 10.1. Tecnologías

- Godot 4.
- GDScript tipado.
- Godot Resources para definiciones estáticas.
- Diccionarios y objetos GDScript para estados dinámicos.
- JSON para configuración e intercambio de datos.
- Guardados locales.
- SQLite opcional si el volumen de información lo justifica.

## 10.2. Componentes del NPC

El NPCState estará compuesto por:

- NPCIdentity.
- NPCPersonality.
- NPCEmotions.
- Knowledge.
- Memories.
- Relationships.
- Beliefs.
- Goals.
- CurrentGroup.
- CurrentActivity.
- CurrentLocation.

La lógica de simulación estará separada de la representación gráfica.

# 11. RENDIMIENTO Y SIMULACIÓN

Se utilizarán cuatro niveles de actividad.

Nivel 1: personajes cercanos al jugador.
- Simulación completa.
- Movimiento.
- Emociones.
- Conversaciones.
- Objetivos.
- Relaciones.
- Recuerdos.

Nivel 2: personajes de zonas próximas.
- Actualizaciones periódicas.
- Actividades.
- Relaciones.
- Rumores.
- Acontecimientos importantes.

Nivel 3: personajes de zonas alejadas.
- Simulación mediante eventos agregados.
- Sin actualización continua.

Nivel 4: personajes sin actividad relevante.
- Conservación de estado.
- Actualización únicamente cuando se produce un evento relevante.

## 11.1. Simulación basada en eventos

No actualizar todos los NPC continuamente.

Ejemplo:

EVENTO: NPC_0012 HA SIDO ATACADO.

Consecuencias:
- Actualizar recuerdos.
- Modificar miedo.
- Modificar relación con atacante.
- Notificar a testigos.
- Generar posibles rumores.
- Evaluar reacción del grupo.

Solamente se actualizarán los sistemas afectados.

## 11.2. Testigos

La información se transmitirá según:
- Presencia física.
- Percepción del acontecimiento.
- Escucha.
- Comunicación.
- Relaciones sociales.
- Movilidad entre zonas.

Los personajes que no tengan contacto con una fuente no deben conocer automáticamente los acontecimientos.

## 11.3. Tiempo

Un World Clock central controlará:
- Día y noche.
- Horarios de especies.
- Periodos de descanso.
- Reuniones.
- Reproducción.
- Migraciones.
- Festividades.
- Cambios ambientales.

Los cambios temporales generarán eventos, no consultas continuas de cada NPC.

# 12. SISTEMA DE ACONTECIMIENTOS

Cada acontecimiento tendrá:
- Identificador.
- Tipo.
- Protagonistas.
- Ubicación.
- Fecha.
- Testigos.
- Causas.
- Consecuencias.
- Evidencias.

Ejemplo:

EVENT_00042

Tipo: DESAPARICION.

Protagonista: NPC_000142.

Ubicación: ZONE_0008.

Testigos:
- NPC_000143.
- NPC_000145.

Consecuencias:
- NPC_000142 desaparece.
- NPC_000143 sospecha de una especie rival.
- NPC_000145 cree que ha escapado voluntariamente.
- El grupo inicia una búsqueda.

El acontecimiento real queda registrado. Las interpretaciones se almacenan individualmente.

Ciclo:

Acontecimiento real.
Identificación de testigos.
Actualización de recuerdos.
Actualización de conocimientos.
Generación de interpretaciones.
Transmisión de rumores.
Actualización de creencias.
Cambios de relaciones y objetivos.
Nuevos acontecimientos.

# 13. CONSISTENCIA

El Consistency Engine comprobará:

- Identidad de personajes.
- Ubicación.
- Cronología.
- Procedencia de conocimientos.
- Coherencia de acontecimientos.
- Relaciones válidas.
- Estado vital.
- Integridad de datos.

Ejemplos:
- Un NPC no puede estar físicamente en dos lugares.
- Nadie puede recordar algo que todavía no ha sucedido.
- Los personajes no pueden conocer información sin una fuente.
- Un personaje muerto no puede protagonizar nuevos acontecimientos físicos.
- Los rumores necesitan rutas de transmisión.
- La verdad objetiva no puede cambiar por una conversación.

Las creencias contradictorias son válidas y no deben eliminarse automáticamente.

# 14. PERSISTENCIA

Se combinarán dos mecanismos.

## Snapshot

Fotografía del estado del mundo:
- WorldClock.
- NPCStates.
- GroupStates.
- KnowledgeStates.
- RelationshipStates.
- WorldState.

## EventLog

Registro de acontecimientos posteriores al snapshot.

Al cargar:
1. Recuperar snapshot.
2. Reproducir eventos posteriores.
3. Reconstruir estados.
4. Recuperar actividad de NPC.
5. Reanudar simulación.

Los acontecimientos históricos importantes deben conservarse.

Se implementará versionado de guardados y migraciones.

# 15. PLAN DE DESARROLLO

## Fase 1. Núcleo de personajes

- Identidad.
- Personalidad.
- Emociones.
- Relaciones.
- Conversaciones contextuales.
- Variantes de respuestas.

Resultado: dos personajes pueden mantener conversaciones diferentes según su personalidad y relación.

## Fase 2. Conocimiento y memoria

- Registro de hechos.
- Creencias individuales.
- Memoria episódica.
- Fuentes de información.
- Mentiras intencionadas.

Resultado: dos personajes pueden conocer versiones diferentes de un mismo acontecimiento.

## Fase 3. Sociedad y rumores

- Grupos.
- Relaciones colectivas.
- Transmisión de información.
- Distorsión de rumores.
- Conflictos.
- Alianzas.

Resultado: los personajes empiezan a construir historias colectivas.

## Fase 4. Autonomía

- Objetivos individuales.
- Prioridades.
- Decisiones autónomas.
- Reacciones a acontecimientos.
- Actividades sociales.

Resultado: el mundo empieza a funcionar sin el protagonista.

## Fase 5. Simulación avanzada

- Propagación entre zonas.
- Simulación por niveles.
- Cambios culturales.
- Evolución de creencias colectivas.
- Consistencia histórica.

Resultado: sociedades que desarrollan su propia historia.

## Fase 6. Integración completa

- Ciclo día/noche.
- Clima.
- Acontecimientos ambientales.
- Poblaciones.
- Migraciones.
- Misiones.
- Descubrimientos.
- Guardado completo del universo.

Resultado: el motor social funciona integrado en Bug de Familia.

# 16. LABORATORIO DE SIMULACIÓN

Antes de integrar el motor en el videojuego, se desarrollará una aplicación de pruebas independiente.

Configuración inicial:
- Una especie.
- Una zona.
- Tres grupos.
- Veinte personajes.
- Una historia compartida.

Funciones:

## Visualizador de personajes
Permite consultar:
- Personalidad.
- Emociones.
- Conocimientos.
- Creencias.
- Recuerdos.
- Relaciones.
- Objetivos.

## Simulador social
Permite avanzar:
- Una hora.
- Un día.
- Una semana.

Permite observar cómo evolucionan personajes, relaciones y sociedades.

## Probador de conversaciones
Permite seleccionar dos personajes y simular conversaciones.

Debe mostrar:
- Contexto.
- Intenciones disponibles.
- Condiciones evaluadas.
- Motivo de selección de cada respuesta.
- Consecuencias.
- Cambios de memoria.
- Cambios de relaciones.

Es imprescindible disponer de herramientas de depuración que expliquen por qué el motor ha tomado cada decisión.

# 17. MEMORIA COLECTIVA DE LAS ESPECIES

Se implementarán tres niveles de información:

1. Verdad objetiva: lo que realmente ocurrió.
2. Memoria colectiva: lo que una sociedad cree que ocurrió.
3. Creencias individuales: lo que cada personaje considera verdadero.

Las especies podrán desarrollar:
- Tradiciones.
- Mitos.
- Tabúes.
- Enemigos históricos.
- Creencias religiosas o culturales ficticias.
- Interpretaciones históricas.
- Disidencias.
- Cambios culturales.

Los individuos podrán cuestionar su propia cultura, ocultar sus opiniones, convertirse en disidentes o intentar convencer a otros.

Las sociedades podrán modificar sus creencias colectivas cuando aparezcan evidencias o cambien sus circunstancias.

# 18. DECISIONES TÉCNICAS CERRADAS

- Motor: Godot 4.
- Lenguaje: GDScript tipado.
- Arquitectura: componentes y servicios independientes.
- Conversaciones: contextuales.
- Interacción: opciones dinámicas, sin texto libre.
- Selección de respuestas: reglas, puntuaciones y variantes.
- Personalidad: rasgos estables y emociones dinámicas.
- Memoria: episódica, semántica y social.
- Conocimiento: hechos, creencias y fuentes.
- Historia: verdad objetiva independiente.
- Sociedades: grupos, relaciones y rumores.
- Autonomía: Utility AI basada en reglas.
- Simulación: eventos y niveles de actividad.
- Persistencia: snapshots y registro de eventos.
- Ejecución: 100 % local y offline.
- IA generativa: ninguna.

# 19. OBJETIVO FINAL

Construir un motor de simulación social capaz de generar situaciones, conversaciones, conflictos, rumores e historias emergentes.

El objetivo no es generar diálogos infinitos, sino generar situaciones potencialmente infinitas mediante la combinación de un catálogo controlado de conocimientos, intenciones, recuerdos, respuestas y consecuencias.

El mundo debe poder desarrollar su propia historia sin que el protagonista esté presente.

El protagonista podrá descubrir esa historia mediante conversaciones, personajes, objetos, ruinas, acontecimientos y evidencias.

Todos los misterios tendrán una explicación objetiva coherente, aunque el jugador puede no llegar a descubrirla.

**Principio rector del proyecto:**

El jugador no debe sentir que está hablando con personajes que esperan a que llegue para contarle una historia. Debe sentir que está visitando un mundo donde todos tienen una vida, una historia, sus propios intereses y una versión diferente de la realidad.
