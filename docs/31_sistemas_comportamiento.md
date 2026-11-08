> Decidido el 8-nov: los personajes aprenden hechos, lugares y relaciones, pero no habilidades; el rol es fijo y los cargos sociales cambian aparte. Rigen los tres niveles de simulación de `02_DECISIONES.md`.

BUG DE FAMILIA
DOCUMENTO DE DISEÑO TÉCNICO
Sistemas de inteligencia, comportamiento y simulación del mundo
Versión: 1.0
Estado: Decisiones de diseño aprobadas
Motor: Godot 2D
Tipo de simulación: Offline, sin inteligencia artificial generativa
________________

1. OBJETIVO DEL DOCUMENTO
Este documento recoge las decisiones de diseño tomadas para los diez sistemas que regulan la percepción, inteligencia, comportamiento, memoria, conocimiento y autonomía de los habitantes del mundo de Bug de Familia.
El objetivo es construir un mundo vivo en el que los personajes y las especies tengan comportamientos propios, puedan relacionarse, aprender, transmitir información, investigar acontecimientos y generar consecuencias independientemente de las acciones del protagonista.
El sistema debe funcionar completamente offline y sin IA generativa.
Las decisiones aquí recogidas se consideran aprobadas. Las propuestas de implementación técnica son orientativas y no constituyen todavía una arquitectura definitiva.
________________

2. SISTEMAS DEFINIDOS
SISTEMA 1. PERCEPCIÓN INDIVIDUAL DE LOS PERSONAJES
Decisión aprobada: percepción específica por especie.
Cada especie dispone de un sistema sensorial común para sus individuos.
Los personajes de una misma especie comparten las características sensoriales propias de ella. No se contemplan, por ahora, diferencias sensoriales individuales.
Los sentidos pueden incluir:
* Vista.
* Oído.
* Olfato.
* Detección de vibraciones.
* Percepción térmica.
* Percepción química.
Cada especie tendrá sus propias características sensoriales, incluyendo:
* Alcance.
* Precisión.
* Sensibilidad.
* Limitaciones.
* Capacidad para detectar estímulos.
* Influencia de obstáculos y condiciones ambientales.
La percepción debe condicionar la información que recibe cada personaje y, por tanto, sus decisiones.
Propuesta técnica:
* PerceptionComponent.
* SpeciesPerceptionDefinition.
* SensoryConfiguration.
* StimulusSystem.
________________

SISTEMA 2. INVESTIGACIÓN AUTÓNOMA DE ANOMALÍAS
Decisión aprobada: investigación contextual y social.
Los personajes podrán investigar acontecimientos, anomalías y situaciones que consideren relevantes.
La decisión de investigar dependerá de diferentes factores:
* Conocimientos.
* Experiencias anteriores.
* Necesidades.
* Relaciones sociales.
* Rol.
* Características de la especie.
* Peligrosidad percibida.
* Intereses individuales o colectivos.
La investigación no será una secuencia automática ni un comportamiento universal.
Cada personaje decidirá si investiga, ignora, evita o comunica aquello que ha percibido.
Los personajes podrán:
* Investigar por iniciativa propia.
* Solicitar ayuda.
* Avisar a otros individuos.
* Compartir sus interpretaciones.
* Transmitir información incompleta o incorrecta.
* Generar diferentes interpretaciones sobre un mismo acontecimiento.
Propuesta técnica:
* StimulusSystem.
* InvestigationComponent.
* InvestigationMemory.
* DecisionSystem.
* NavigationAgent2D.
________________

SISTEMA 3. INTELIGENCIA COLECTIVA DE LOS GRUPOS
Decisión aprobada: organización social específica por especie.
Cada especie dispondrá de su propio modelo de organización social.
No existirá una estructura social universal.
Dependiendo de la especie, su organización podrá basarse en modelos como:
* Jerarquía.
* Cooperación.
* Consenso.
* Competencia.
* Organización colectiva.
* Otros modelos sociales específicos.
Los individuos mantendrán autonomía dentro de su organización.
No todas las especies tendrán que formar grupos ni funcionar mediante estructuras colectivas.
La inteligencia colectiva deberá respetar las características sociales propias de cada especie.
Propuesta técnica:
* GroupAI.
* IndividualAI.
* SocialOrganizationDefinition.
* GroupDecisionSystem.
________________

SISTEMA 4. ENTORNO FUNCIONAL, DINÁMICO Y REACTIVO
Decisión aprobada: entorno dinámico y reactivo.
El escenario no será un simple decorado. Los elementos relevantes del mundo tendrán estados y comportamientos propios.
Los habitantes podrán modificar el entorno y las modificaciones podrán afectar a otros individuos y especies.
El sistema contemplará:
* Elementos interactivos con estados propios.
* Consumo y regeneración de recursos.
* Modificaciones del entorno por parte de los habitantes.
* Fenómenos naturales que alteran los escenarios.
* Interacciones entre organismos y entorno.
* Consecuencias de las modificaciones sobre otras especies.
* Evolución del mundo sin intervención del protagonista.
No será necesario simular absolutamente todos los elementos del escenario.
Se simularán funcionalmente aquellos elementos que puedan tener consecuencias relevantes sobre el mundo.
Propuesta técnica:
* WorldObject.
* EnvironmentSystem.
* ResourceSystem.
* OrganismComponent.
* InteractionSystem.
* WorldSimulation.
________________

SISTEMA 5. ESPECIALIZACIÓN BIOLÓGICA DE LAS ESPECIES
Decisión aprobada: capacidades y limitaciones biológicas.
Cada especie tendrá capacidades y debilidades biológicas propias.
Estas características condicionarán su interacción con el entorno y con otras especies.
Las capacidades biológicas podrán afectar a:
* Movimiento.
* Percepción.
* Resistencia.
* Alimentación.
* Supervivencia.
* Interacción con elementos.
* Defensa y ataque.
* Adaptación a condiciones ambientales.
No se contempla evolución biológica dinámica de las especies.
Matiz adicional aprobado:
Los personajes especiales tendrán mejores estadísticas que los individuos normales.
Por tanto, será necesario distinguir entre las estadísticas habituales de una especie y las características superiores de determinados personajes especiales.
Propuesta técnica:
* SpeciesDefinition.
* SpeciesCapabilities.
* SpeciesSenses.
* SpeciesWeaknesses.
* IndividualTraits.
* BiologicalState.
________________

SISTEMA 6. MEMORIA DE ACONTECIMIENTOS
Decisión aprobada: memoria compartida y transmisión cultural.
Los personajes podrán conservar recuerdos y transmitir información a otros individuos.
La transmisión tendrá reglas diferentes dependiendo de si los individuos pertenecen a la misma especie o a especies diferentes.
Transmisión entre individuos de la misma especie
La transmisión de información se producirá mediante encuentros entre individuos de la misma especie.
Los recuerdos, acontecimientos e información podrán compartirse y transmitirse culturalmente.
Transmisión entre especies diferentes
Cuando la información pase entre individuos de especies diferentes, únicamente se transmitirá un fragmento de información.
El contenido de ese fragmento será variable.
No se transmitirá necesariamente el acontecimiento completo ni toda la información que conoce el individuo original.
Consecuencias
La información podrá transformarse durante las transmisiones.
Podrán aparecer:
* Relatos incompletos.
* Interpretaciones diferentes.
* Mitos.
* Tradiciones.
* Historias modificadas.
* Versiones contradictorias.
* Información parcialmente correcta.
Separación entre realidad y recuerdo
Debe existir una separación técnica entre:
1. El acontecimiento real.
2. El recuerdo individual del acontecimiento.
3. La interpretación del personaje.
4. La información transmitida a otros individuos.
5. La versión que finalmente conoce cada receptor.
La verdad objetiva del mundo no debe modificarse por las interpretaciones de los personajes.
Propuesta técnica:
* MemorySystem.
* EventRecord.
* IndividualMemory.
* RelationshipMemory.
* KnowledgeSystem.
* MemoryDecay.
________________

SISTEMA 7. ROLES Y ORGANIZACIÓN SOCIAL DE LOS INDIVIDUOS
Decisión aprobada: roles fijos por individuo.
Cada individuo tendrá un rol determinado.
Los roles serán fijos y no cambiarán dinámicamente como consecuencia de la experiencia o de las circunstancias.
Cada especie podrá disponer de sus propios roles, de acuerdo con su organización social.
Los roles condicionarán:
* Funciones.
* Prioridades.
* Comportamientos.
* Decisiones.
* Relaciones sociales.
* Capacidades o responsabilidades asociadas.
La definición concreta de los roles dependerá de cada especie.
Aspecto pendiente
Todavía no se ha decidido cómo se determina el rol de cada individuo.
Podría establecerse mediante nacimiento, generación, asignación social u otro mecanismo.
Propuesta técnica:
* RoleDefinition.
* SocialRoleComponent.
* RoleBehaviorProfile.
* SpeciesSocialStructure.
________________

SISTEMA 8. APRENDIZAJE DE LOS PERSONAJES
Decisión aprobada: aprendizaje individual y social.
Los personajes podrán aprender tanto de sus propias experiencias como de otros individuos.
Aprendizaje individual
Los personajes podrán adquirir conocimientos a partir de sus propias experiencias.
Por ejemplo:
* Reconocer lugares peligrosos.
* Identificar rutas seguras.
* Recordar recursos.
* Reconocer individuos hostiles.
* Aprender de conflictos anteriores.
* Identificar situaciones conocidas.
Aprendizaje social
Los personajes podrán aprender mediante encuentros y observación de otros individuos.
El aprendizaje social respetará las reglas de transmisión aprobadas en el sistema 6:
* Entre individuos de la misma especie se podrá transmitir información mediante encuentros.
* Entre especies diferentes solo se transmitirá un fragmento variable de información.
Diferencias individuales
Dos personajes de la misma especie podrán tener conocimientos y experiencias diferentes.
El aprendizaje no implica modificación del rol fijo del individuo.
Propuesta técnica:
* LearningComponent.
* ExperienceProcessor.
* SocialLearningSystem.
* BehaviorKnowledge.
* BehaviorProfile.
________________

SISTEMA 9. INFORMACIÓN PARCIAL Y CONOCIMIENTO DEL MUNDO
Decisión aprobada: sistema combinado de conocimiento distribuido.
Este sistema es fundamental para la exploración y el descubrimiento de la historia de Bug de Familia.
La información del mundo estará distribuida entre los personajes.
El jugador podrá descubrir acontecimientos, secretos y datos importantes hablando o interactuando con numerosos individuos.
Sin embargo, no todos los personajes conocerán toda la información.
Un conocimiento podrá estar disponible en muchos personajes, pero no necesariamente en todos.
Asignación de conocimientos al crear individuos
En el momento de crear cada individuo se le asignará un grupo de conocimientos.
Ese grupo podrá contener diferentes combinaciones de:
Realidades:
* Información objetivamente correcta.
* Datos que corresponden con acontecimientos reales.
* Conocimientos verificables dentro del mundo.
Creencias:
* Interpretaciones personales.
* Explicaciones que el individuo considera verdaderas.
* Ideas transmitidas culturalmente.
* Creencias que pueden ser correctas o incorrectas.
Datos erróneos:
* Información falsa.
* Recuerdos incorrectos.
* Datos incompletos interpretados equivocadamente.
* Información distorsionada durante transmisiones anteriores.
Diez variaciones por tipo de individuo
Cada tipo de individuo tendrá disponibles diez variaciones de grupos de conocimientos.
Por tanto, la asignación de conocimientos no será idéntica para todos los individuos del mismo tipo.
Las diez variaciones podrán combinar de manera diferente:
* Información verdadera.
* Creencias.
* Datos erróneos.
* Información parcial.
* Conocimientos históricos.
* Conocimientos sobre otras especies.
* Información sobre lugares y acontecimientos.
Generación de variaciones
Se contemplan dos mecanismos:
1. Variaciones previamente definidas y almacenadas.
2. Variaciones generadas al principio de cada partida.
Todavía está pendiente decidir si se utilizará uno de ellos o una combinación de ambos.
Objetivo de diseño
La información necesaria para descubrir la historia y los secretos del mundo debe estar repartida entre diferentes personajes.
Esto permitirá que cada partida pueda ofrecer recorridos de descubrimiento distintos.
No se garantizará que el jugador encuentre a un individuo concreto ni que todos los personajes puedan proporcionar información relevante.
La distribución del conocimiento deberá respetar la coherencia objetiva de los acontecimientos del mundo.
Propuesta técnica:
* KnowledgeCatalog.
* KnowledgeGroupDefinition.
* KnowledgeVariationSet.
* IndividualKnowledge.
* KnowledgeGenerator.
* KnowledgePropagationSystem.
* KnowledgeReliability.
________________

SISTEMA 10. ACCIONES Y CONSECUENCIAS INDIRECTAS
Decisión aprobada: sistema combinado con simulación por distancia.
Las acciones de los personajes y los acontecimientos del mundo podrán generar consecuencias directas e indirectas.
Las consecuencias podrán afectar a:
* Individuos.
* Grupos.
* Relaciones sociales.
* Territorios.
* Recursos.
* Poblaciones.
* Ecosistemas.
* Otras especies.
Una acción podrá desencadenar una cadena de acontecimientos.
Por ejemplo:
Un individuo roba alimento a otro. El afectado abandona su grupo. El grupo pierde capacidad de defensa. Una tercera especie aprovecha la situación para ocupar su territorio.
El mundo podrá generar estas cadenas de acontecimientos sin intervención del protagonista.
Simulación según la distancia al protagonista
Se establecen dos niveles principales de simulación.
A. Cerca del protagonista: simulación real
Cuando una zona se encuentre dentro del área de simulación cercana:
* Los personajes ejecutarán sus comportamientos.
* Se calcularán movimientos e interacciones individuales.
* Se podrán producir enfrentamientos reales.
* Se ejecutarán decisiones y reacciones.
* Se calcularán consecuencias sociales y ecológicas.
* El jugador podrá observar los acontecimientos.
B. Lejos del protagonista: simulación estadística
Cuando una zona se encuentre fuera del área de simulación cercana:
* No se ejecutarán individualmente los comportamientos.
* No se realizarán movimientos ni animaciones individuales.
* Se calcularán resultados mediante estadísticas, probabilidades, reglas y estados agregados.
* Podrán cambiar poblaciones, recursos, territorios y relaciones.
* Podrán producirse acontecimientos y consecuencias sin representar físicamente cada acción.
Transición entre niveles de simulación
Cuando el protagonista se aproxime a una zona que estaba siendo simulada estadísticamente, el sistema deberá transformar su estado en una simulación real coherente.
Ejemplo:
Si una población ha perdido individuos durante la simulación estadística, cuando el protagonista llegue encontrará una población reducida.
No deberán aparecer personajes que estadísticamente hayan desaparecido.
Consideraciones de coherencia
Los resultados de ambos niveles deben ser compatibles.
La simulación estadística no puede producir estados imposibles para las reglas del mundo.
Los acontecimientos importantes, los personajes especiales y las transiciones entre niveles podrán necesitar reglas específicas.
La distancia será el criterio principal de selección del nivel de simulación, aunque podrán existir excepciones justificadas.
Propuesta técnica:
* WorldSimulationManager.
* ProximitySimulationSystem.
* RealSimulationSystem.
* StatisticalSimulationSystem.
* SimulationTransitionSystem.
* WorldStateRepository.
* ConsequenceResolver.
________________

3. PRINCIPIOS GENERALES DERIVADOS DE LAS DECISIONES
Los diez sistemas anteriores establecen una serie de principios que deberán respetarse durante el desarrollo.
3.1. Autonomía del mundo
El mundo debe evolucionar independientemente del protagonista.
Los personajes y grupos podrán tomar decisiones, investigar, aprender, relacionarse y generar acontecimientos sin intervención del jugador.
3.2. Diferencias entre especies
No debe existir un comportamiento universal aplicado a todas las especies.
Cada especie tendrá sus propias características sensoriales, biológicas y sociales.
3.3. Autonomía individual
Los individuos conservarán autonomía dentro de su especie y de sus grupos.
Pertenecer a una misma especie no significa conocer, pensar o actuar exactamente igual.
3.4. Conocimiento limitado
Ningún personaje debe disponer automáticamente de información que no haya podido conocer.
El conocimiento estará condicionado por la percepción, las experiencias, la memoria, los encuentros y las transmisiones.
3.5. Verdad objetiva
Los acontecimientos del mundo tendrán una realidad objetiva.
Las creencias, los recuerdos y las transmisiones podrán ser incorrectos, incompletos o contradictorios, pero no modificarán lo que realmente sucedió.
3.6. Información distribuida
La historia y los secretos del mundo estarán repartidos entre diferentes personajes, lugares, objetos y acontecimientos.
El descubrimiento dependerá de la exploración y de las interacciones del jugador.
3.7. Simulación eficiente
El mundo tendrá diferentes niveles de simulación según la distancia al protagonista.
No será necesario ejecutar individualmente todos los comportamientos de todos los personajes en todo momento.
3.8. Desarrollo offline
Todos estos sistemas deberán funcionar sin conexión a Internet y sin depender de IA generativa.
Las decisiones y comportamientos se implementarán mediante reglas, datos, estados, algoritmos, probabilidades y sistemas de simulación.
________________

4. ESTADO DE LAS DECISIONES
Los diez sistemas están aprobados en cuanto a su orientación funcional.
Sin embargo, todavía no se han definido todos los detalles de implementación.
Quedan pendientes, entre otros:
* Alcances y parámetros concretos de los sentidos de cada especie.
* Reglas de decisión y prioridades de investigación.
* Modelos sociales específicos de cada especie.
* Catálogo de elementos funcionales del entorno.
* Estadísticas biológicas y excepciones de personajes especiales.
* Reglas de conservación, olvido y transformación de recuerdos.
* Mecanismo de asignación de roles fijos.
* Tipos y profundidad de los aprendizajes.
* Diseño concreto de las diez variaciones de conocimiento por tipo de individuo.
* Procedimiento de creación de variaciones al iniciar una partida.
* Umbrales de distancia y criterios de cambio entre simulación real y estadística.
* Algoritmos de simulación estadística y transición.
Estos aspectos deberán concretarse en una fase posterior de diseño.
________________

5. SIGUIENTE FASE DEL PROYECTO
La siguiente fase consistirá en diseñar la arquitectura conjunta de estos diez sistemas en Godot 2D.
El objetivo será determinar:
1. Cómo se relacionan los diez sistemas.
2. Qué dependencias existen entre ellos.
3. Qué información comparte cada sistema.
4. Qué componentes pertenecen a cada personaje.
5. Qué sistemas son globales y cuáles funcionan por especie o grupo.
6. Cómo se gestionan los acontecimientos y sus consecuencias.
7. Cómo se conserva la coherencia entre simulación real y estadística.
8. Cómo se persiste el estado del mundo.
9. Cómo se optimiza el rendimiento en PC.
La arquitectura definitiva deberá respetar todas las decisiones aprobadas en este documento.
Este documento constituye la referencia funcional de los diez sistemas de inteligencia, comportamiento y simulación de Bug de Familia.
