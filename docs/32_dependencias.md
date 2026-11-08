> Decidido el 8-nov: los personajes aprenden hechos, lugares y relaciones, pero no habilidades.

BUG DE FAMILIA
Documento técnico: Dependencias entre sistemas
Estado: Decisiones aprobadas
Motor: Godot 2D
Arquitectura objetivo: Simulación offline, sin IA generativa.
________________

1. Objetivo
Este documento define las dependencias funcionales entre los sistemas principales de Bug de Familia.
Su objetivo es establecer cómo se relacionan, colaboran e intercambian información, manteniendo una separación clara de responsabilidades.
Las dependencias deben permitir:
* Mantener los sistemas independientes a nivel de implementación.
* Evitar duplicidades de información.
* Garantizar la coherencia del mundo simulado.
* Permitir que los personajes actúen de forma autónoma.
* Conservar la continuidad de los acontecimientos.
* Compatibilizar la simulación detallada con la simulación estadística.
* Facilitar futuras ampliaciones sin tener que modificar todos los sistemas.
Principio general: los sistemas deben estar separados, pero compartir información mediante relaciones y contratos definidos.
________________

2. Dependencias aprobadas
2.1. Biología ↔ Percepción
Decisión aprobada: C — Biología como configuración base y percepción como especialización.
Responsabilidades
El sistema de biología define las capacidades y limitaciones físicas de cada especie.
El sistema de percepción utiliza esas capacidades para configurar el funcionamiento de sus sentidos.
La biología determina qué puede percibir una especie, mientras que percepción determina cómo funciona esa capacidad sensorial.
Funcionamiento
1. Biología proporciona las capacidades sensoriales disponibles.
2. Percepción consulta esa configuración.
3. Percepción establece los parámetros específicos de cada sentido.
4. Los personajes utilizan esos parámetros cuando necesitan percibir su entorno.
Ejemplo
Una especie dispone biológicamente de visión nocturna.
El sistema de percepción determina:
* Alcance de visión en oscuridad.
* Precisión de detección.
* Capacidad para distinguir formas.
* Efectos de las condiciones ambientales.
Criterio técnico
Ambos sistemas deben permanecer separados a nivel de código.
La relación se establece mediante configuración y datos compartidos, evitando que el sistema de biología tenga que implementar directamente las operaciones de percepción.
________________

2.2. Percepción ↔ Entorno
Decisión aprobada: D — Sistema híbrido de generación y consulta de estímulos.
Responsabilidades
El entorno genera estímulos a partir de sus elementos, acontecimientos y condiciones ambientales.
Un sistema centralizado gestiona la propagación de esos estímulos.
Los personajes consultan el sistema de percepción para determinar qué estímulos pueden detectar.
Funcionamiento
1. Un elemento del entorno genera un estímulo.
2. El sistema centralizado gestiona su propagación.
3. La propagación tiene en cuenta distancia, obstáculos, materiales, clima, vegetación y otras condiciones.
4. Los personajes realizan consultas sensoriales.
5. El sistema determina qué estímulos son compatibles con sus capacidades.
6. Cada personaje recibe únicamente la información que puede percibir.
Ejemplo
Un objeto cae y genera ruido.
* El entorno genera el estímulo sonoro.
* El sistema centralizado calcula su propagación.
* Una pared puede reducir o bloquear el sonido.
* Los personajes con capacidad auditiva compatible pueden detectarlo.
* Los personajes sin esa capacidad no reciben información sobre el ruido.
Criterio técnico
No se debe permitir que cada personaje inspeccione continuamente todos los elementos del entorno.
La propagación de estímulos se centraliza para evitar un coste computacional excesivo.
Los personajes consultan el sistema cuando necesitan información sensorial.
________________

2.3. Memoria ↔ Conocimientos
Decisión aprobada: D — Sistemas independientes con procedencia de información.
Responsabilidades
El sistema de memoria almacena acontecimientos y experiencias vividas por los individuos.
El sistema de conocimientos almacena información que un individuo considera conocida.
Ambos sistemas son independientes, aunque existe una relación entre ellos.
Funcionamiento
Los conocimientos pueden proceder de:
* Experiencias propias.
* Recuerdos de acontecimientos.
* Información transmitida por otros individuos.
* Observaciones.
* Aprendizajes anteriores.
Cada conocimiento conserva información sobre su procedencia.
Reglas
* Un personaje puede conocer algo sin recordar quién se lo contó.
* Un recuerdo puede existir sin convertirse en un conocimiento útil.
* Un conocimiento puede modificarse con el tiempo.
* La modificación de un conocimiento no altera el acontecimiento original.
* La procedencia de la información debe poder rastrearse.
* Los relatos transmitidos pueden deformarse sin modificar la verdad objetiva.
Criterio técnico
Memoria y conocimientos no deben compartir una única estructura de datos.
Es necesario conservar la trazabilidad de la información para poder reconstruir cómo se ha propagado y transformado.
________________

2.4. Memoria ↔ Aprendizaje
Decisión aprobada: C — Aprendizaje condicionado por memoria y repetición.
Responsabilidades
El sistema de memoria conserva las experiencias.
El sistema de aprendizaje utiliza esas experiencias para generar o reforzar conocimientos y comportamientos aprendidos.
Funcionamiento
1. El personaje experimenta un acontecimiento.
2. El sistema de memoria determina si se conserva.
3. El sistema de aprendizaje evalúa la experiencia almacenada.
4. Si la experiencia tiene suficiente relevancia, puede generar aprendizaje.
5. La repetición de experiencias puede reforzar conocimientos existentes.
Reglas
* No todas las experiencias generan aprendizaje.
* Los acontecimientos poco relevantes pueden olvidarse sin producir conocimientos.
* La importancia del acontecimiento influye en su capacidad para generar aprendizaje.
* Las experiencias repetidas pueden reforzar conocimientos.
* El aprendizaje depende de que la experiencia se conserve en memoria.
* El aprendizaje social también forma parte del sistema, respetando las reglas de transmisión de información entre individuos.
Criterio técnico
El sistema de aprendizaje no debe procesar directamente todos los acontecimientos del mundo.
Debe trabajar sobre las experiencias que el sistema de memoria conserva y pone a su disposición.
Queda pendiente concretar cómo se aplica la repetición al aprendizaje de información recibida de otros individuos.
________________

2.5. Conocimientos ↔ Decisiones
Decisión aprobada: D — Decisiones basadas en información, contexto y comportamiento individual.
Responsabilidades
El sistema de conocimientos proporciona la información que un personaje tiene disponible.
El sistema de decisiones utiliza esa información junto con otros factores para determinar qué puede hacer y qué decide hacer.
Factores que intervienen
* Conocimientos.
* Creencias.
* Información errónea.
* Necesidades.
* Roles sociales.
* Relaciones.
* Experiencias.
* Percepción actual.
* Peligrosidad estimada.
* Circunstancias del entorno.
Comportamientos extravagantes
Bug de Familia permite comportamientos deliberadamente absurdos, extravagantes, antinaturales o disparatados.
Estos comportamientos forman parte de la personalidad y del carácter del mundo. No deben considerarse automáticamente errores de la simulación.
Ejemplos:
* Abandonar una persecución para ponerse a bailar.
* Regalar un recurso a un enemigo porque le resulta simpático.
* Organizar una ceremonia absurda en mitad de una situación peligrosa.
* Interpretar un acontecimiento terrible como una celebración.
* Ignorar una obligación importante por una motivación aparentemente ridícula.
No todos los individuos tendrán la misma tendencia a comportarse de esta manera.
Reglas
* Los personajes no tienen por qué tomar siempre la decisión más lógica.
* Pueden actuar basándose en información incorrecta.
* Pueden interpretar erróneamente lo que sucede.
* Pueden priorizar motivaciones personales frente a necesidades colectivas.
* El comportamiento extravagante debe responder a características o reglas internas del personaje, aunque resulte incomprensible para el jugador.
* El humor no debe destruir la coherencia objetiva del mundo.
Criterio técnico
El sistema debe permitir combinar decisiones funcionales con comportamientos extravagantes.
No debe existir una obligación de seleccionar siempre la acción matemáticamente más eficiente.
________________

2.6. Roles ↔ Comportamiento
Decisión aprobada: D — Rol contextual combinado con personalidad individual.
Responsabilidades
El sistema de roles establece las funciones y responsabilidades esperadas de cada individuo.
El sistema de comportamiento determina cómo actúa realmente el individuo.
El rol define
* Responsabilidades.
* Capacidades específicas asociadas al puesto.
* Prioridades.
* Obligaciones.
* Relaciones sociales.
* Expectativas de comportamiento.
El comportamiento depende de
* Rol.
* Personalidad.
* Conocimientos.
* Necesidades.
* Experiencias.
* Relaciones.
* Circunstancias.
* Decisiones individuales.
Reglas
* Los roles son fijos por individuo.
* El rol no cambia dinámicamente por experiencia o circunstancias.
* El rol no determina de manera absoluta las acciones.
* Un individuo puede incumplir sus responsabilidades.
* La personalidad y las circunstancias pueden prevalecer sobre las obligaciones.
* Se permiten comportamientos absurdos o extravagantes incluso cuando contradicen las funciones del individuo.
Principio fundamental
El rol determina lo que se espera de un individuo, no necesariamente lo que hará.
________________

2.7. Individuos ↔ Grupos
Decisión aprobada: D — Sistema dinámico de influencia mutua.
Responsabilidades
Los individuos mantienen autonomía y capacidad de decisión.
Los grupos constituyen estructuras sociales capaces de influir en sus integrantes y de verse modificadas por ellos.
Influencia de los individuos sobre los grupos
Los individuos pueden:
* Influir en decisiones colectivas.
* Generar conflictos internos.
* Promover alianzas.
* Provocar divisiones.
* Modificar comportamientos colectivos.
* Cuestionar o incumplir decisiones grupales.
Influencia de los grupos sobre los individuos
Los grupos pueden influir en:
* Prioridades.
* Comportamientos.
* Relaciones.
* Decisiones.
* Percepción del peligro.
* Acceso a recursos.
* Obligaciones sociales.
Reglas
* La influencia depende de la especie.
* La organización social determina cómo se ejerce esa influencia.
* Las relaciones personales también intervienen.
* Las circunstancias pueden modificar temporalmente la influencia colectiva.
* Los individuos conservan autonomía.
* No todos los grupos tienen que funcionar mediante órdenes.
* Pueden existir grupos cooperativos, jerárquicos, competitivos, consensuales u otras estructuras.
Criterio técnico
Los grupos no deben implementarse únicamente como entidades que dan órdenes a sus miembros.
Deben funcionar como estructuras sociales vivas, con influencia bidireccional sobre sus integrantes.
________________

2.8. Simulación ↔ Consecuencias
Decisión aprobada: D — Simulación híbrida con diferentes niveles de detalle.
Responsabilidades
El sistema de simulación determina el nivel de detalle con el que se representa cada parte del mundo.
El sistema de consecuencias garantiza que las acciones y acontecimientos produzcan efectos coherentes, independientemente del nivel de detalle utilizado.
Simulación cercana al protagonista
Cuando el protagonista está cerca, se utiliza simulación real.
Se representan:
* Movimientos.
* Comportamientos individuales.
* Interacciones.
* Acciones.
* Reacciones.
* Consecuencias observables.
Simulación lejana al protagonista
Cuando el protagonista está lejos, se utiliza simulación estadística.
No es necesario ejecutar físicamente las acciones de todos los individuos.
Se actualizan:
* Poblaciones.
* Recursos.
* Relaciones.
* Territorios.
* Estados de los grupos.
* Acontecimientos relevantes.
* Cambios en el entorno.
Personajes especiales
Los personajes especiales mantienen siempre su identidad y estado individual, aunque se encuentren lejos del protagonista.
Reconstrucción de situaciones
Cuando el protagonista se aproxima a una zona que estaba funcionando mediante simulación estadística:
1. Se consulta el estado estadístico de la zona.
2. Se recuperan los acontecimientos relevantes.
3. Se reconstruyen los individuos y grupos necesarios.
4. Se genera una situación física coherente con lo sucedido.
5. Se continúa con simulación real.
Reglas
* La distancia al protagonista es el criterio principal para determinar el nivel de simulación.
* Pueden existir excepciones para acontecimientos importantes o personajes especiales.
* No es necesario ejecutar continuamente todos los individuos del mundo.
* Debe conservarse la continuidad de los personajes importantes.
* Los acontecimientos relevantes deben mantener trazabilidad.
* La reconstrucción no puede contradecir los resultados de la simulación estadística.
Criterio técnico
Los niveles de simulación deben compartir un modelo común de información.
La simulación estadística no debe ser un sistema independiente que genere resultados incompatibles con la simulación real.
________________

3. Principios arquitectónicos derivados
Las ocho dependencias establecen una serie de principios que deberán respetarse durante el diseño técnico en Godot.
3.1. Separación de responsabilidades
Cada sistema debe tener una responsabilidad concreta.
Que dos sistemas intercambien información no significa que deban fusionarse.
3.2. Información con procedencia
Los conocimientos, recuerdos y relatos deben conservar su origen siempre que corresponda.
La información transmitida no debe confundirse con la verdad objetiva.
3.3. Verdad objetiva del mundo
Los acontecimientos tienen una realidad objetiva independiente de lo que los personajes recuerden, crean o cuenten.
Los personajes pueden equivocarse, mentir o transmitir versiones contradictorias.
3.4. Autonomía individual
Los individuos mantienen capacidad de decisión incluso cuando pertenecen a grupos organizados.
Las obligaciones sociales no garantizan su cumplimiento.
3.5. Coherencia entre niveles de simulación
La simulación real y la estadística deben representar el mismo mundo.
La diferencia está en el nivel de detalle, no en las reglas fundamentales.
3.6. Mundo independiente del protagonista
Los sistemas deben permitir que individuos, grupos, especies y zonas evolucionen sin intervención directa del jugador.
3.7. Comportamiento no necesariamente óptimo
Los personajes no deben limitarse a seleccionar la acción más eficiente.
La personalidad, las creencias, los errores de interpretación y las tendencias extravagantes forman parte de su comportamiento.
________________

4. Decisiones pendientes para las siguientes fases
Las dependencias están aprobadas, pero todavía no constituyen una arquitectura de clases o componentes.
Antes de implementar los sistemas en Godot será necesario concretar:
1. Qué información pertenece a cada entidad: especie, individuo, grupo, zona, acontecimiento, conocimiento, recuerdo, estímulo y recurso.
2. Qué sistemas son propietarios de cada dato.
3. Qué información se comparte y mediante qué mecanismos.
4. Cómo se identifican y relacionan los acontecimientos.
5. Cómo se conserva la procedencia de los conocimientos.
6. Cómo se implementan los cambios entre simulación estadística y real.
7. Cómo se organizan las configuraciones de especies e individuos.
8. Qué datos se guardan en las partidas y cómo se recuperan.
Estas cuestiones deberán resolverse antes de establecer la estructura definitiva de clases, nodos, recursos y componentes de Godot.
________________

5. Estado del documento
Elemento
	Estado
	Diez sistemas funcionales
	Aprobados
	Ocho dependencias entre sistemas
	Aprobadas
	Principios arquitectónicos derivados
	Documentados
	Modelo de datos y propiedad de información
	Pendiente
	Arquitectura de clases y componentes Godot
	Pendiente
	Persistencia y guardado
	Pendiente
	Implementación técnica
	Pendiente
	Conclusión: Bug de Familia tendrá una arquitectura basada en sistemas independientes pero interconectados, capaces de mantener un mundo persistente, autónomo y coherente mediante simulación offline, sin depender de inteligencia artificial generativa.
