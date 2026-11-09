# ARCHITECTURE — Bug de Familia

## 1. Principios obligatorios

1. PC exclusivamente; no introducir requisitos de Android ni abstracciones multiplataforma innecesarias.
2. Funcionamiento completo offline. No depender de APIs, servidores, autenticación online ni modelos generativos en ejecución.
3. Sistemas independientes, con responsabilidades claras, interfaces y contratos explícitos.
4. Contenido y comportamientos configurables mediante datos externos siempre que sea razonable.
5. La simulación debe escalar según distancia al jugador.
6. El guardado debe preservar la muerte permanente y el único espacio de partida.
7. Las pruebas automáticas por sistema son obligatorias. Claude debe añadir pruebas de integración cuando las interacciones entre sistemas lo requieran.
8. No introducir complejidad técnica sin una necesidad demostrada.

## 2. Elecciones técnicas

Godot 4 y GDScript tipado. Verificar la versión estable antes de fijarla. Registrar decisiones estructurales como ADR, comprobar licencias y priorizar herramientas locales y reproducibles. Autonomía y límites en `02_DECISIONES.md`.

## 3. Sistemas lógicos sugeridos

La siguiente separación es una propuesta de arquitectura, no una obligación de implementar cada módulo como proyecto o plugin independiente:

- `WorldTime`: hora local, ciclo día/noche, calendario y festividades.
- `WorldState`: estado persistente de zonas, recursos, poblaciones y eventos.
- `ZoneManager`: carga, descarga, conexiones y transiciones entre zonas.
- `SimulationDirector`: asigna nivel de simulación según distancia/actividad.
- `FullSimulation`: comportamiento individual de entidades cercanas.
- `SimplifiedSimulation`: reglas agregadas de zonas próximas.
- `StatisticalSimulation`: evolución estadística de zonas lejanas.
- `SpeciesSystem`: definiciones, límites configurables, reproducción, necesidades y comportamiento.
- `EntityIdentity`: identidad y estado persistente de personajes únicos.
- `FactionSystem`: sociedades, relaciones, jerarquías y memoria social.
- `EventSystem`: generación, selección, propagación y resolución de acontecimientos.
- `MissionSystem`: conversión de eventos en misiones, objetivos, etapas y recompensas.
- `NarrativeKnowledge`: fragmentos de lore, pistas, condiciones y vías alternativas de descubrimiento.
- `PlayerCharacter`: estado, movimiento y capacidades.
- `ModularBody`: anclajes, piezas, compatibilidades e inventarios por posición.
- `CombatSystem`: tiempo real, daño, objetivos, pausa táctica y estados de extremidades.
- `ConversionSystem`: materiales, objetivos, preguntas y generación de piezas.
- `InventorySystem`: recursos, piezas, tokens, límites y reglas de cambio según el contexto (libre, pausa inicial, sustitución en pelea).
- `DormantAI`: tokens recibidos de piezas descartadas y capacidad máxima.
- `AudioDirector`: música contextual, voces, sonidos y mezcla.
- `Presentation`: cámara en vista alta inclinada, interfaz diegética, señales y feedback.
- `SaveSystem`: único espacio, autoguardado, versión de datos y permadeath.

Los nombres son orientativos; Claude puede proponer otros manteniendo la separación de responsabilidades.

## 4. Simulación por niveles

### Nivel completo
Para entidades próximas al jugador:
- Identidad individual.
- IA y decisiones locales.
- Movimiento y animación.
- Combate e interacciones.
- Percepción y relaciones relevantes.

### Nivel simplificado
Para zonas próximas:
- Actualización agregada de alimentación y recursos.
- Desplazamiento entre subáreas.
- Reproducción y mortalidad.
- Conflictos y fusiones de grupos.
- Eventos locales sin animar individuos continuamente.

### Nivel estadístico
Para zonas lejanas:
- Poblaciones por especie y grupos.
- Recursos y tendencias.
- Reproducción y mortalidad probabilísticas.
- Migraciones, conflictos y anomalías.
- Relaciones entre facciones y consecuencias agregadas.

Las transiciones entre niveles deben conservar coherencia: al volver a cargar una zona, no deben duplicarse individuos, recursos, objetos ni acontecimientos. Se requieren pruebas específicas de transición y conservación de invariantes.

## 5. Poblaciones y límites

- El máximo de población será configurable por especie y zona.
- La configuración puede incluir mínimo, objetivo y máximo, pero Claude propondrá el esquema exacto.
- Los valores por defecto pueden variar por zona y pueden ser aleatorios dentro de rangos configurados.
- El objetivo de 40–60 personajes visibles es un objetivo de experiencia, no un límite rígido ni una garantía sin pruebas.
- El límite de individuos no debe confundirse con el límite de entidades activas en simulación completa.
- Los individuos muertos no reaparecen. La recuperación poblacional ocurre mediante nuevos nacimientos.
- Personajes únicos deben conservar identidad y no regenerarse como si fueran NPC comunes.

## 6. Tiempo

- El ciclo día/noche y el calendario usan la hora local real del jugador, sin requerir conexión.
- Con el juego cerrado el mundo se congela: se conserva el estado guardado y no se simula el tiempo transcurrido.
- Al volver, los eventos programados se recalculan según hora y estado, sin efecto retroactivo.
- Las festividades pasadas dejan rastro (restos y comentarios), sin simular nada más.

## 7. Eventos y misiones

El EventSystem debe:
- Admitir eventos frecuentes de distintas categorías.
- Separar frecuencia, probabilidad, gravedad, duración, radio geográfico y consecuencias.
- Evitar acumulación imposible de eventos y conflictos de estado.
- Permitir eventos pequeños y extraordinarios.
- Ser configurable mediante datos.
- Registrar consecuencias para el ecosistema y las facciones.

El MissionSystem debe crear misiones desde eventos elegibles. Una misión debe tener identificador estable, origen, objetivos, condiciones, etapas, plazo opcional, estado y resultado. No debe depender de generación textual online. Las plantillas, reglas y fragmentos se preparan durante el desarrollo.

## 8. Protagonista modular

- Construcción basada en piezas independientes y huesos 2D, adecuada a la vista alta inclinada.
- Cuatro brazos y dos piernas; cabeza intercambiable según diseño aprobado; cola con función de comunicación de IA y cambio de color.
- Cada posición tiene compatibilidades definidas.
- Cada extremidad tiene inventario separado con máximo de cuatro opciones.
- No compartir automáticamente una pieza entre posiciones incompatibles.
- Animaciones base reutilizables más movimientos especiales por pieza.
- Combinar esqueletos, animación procedural y animaciones específicas donde aporte valor.
- Evitar generar una animación completa para cada combinación de piezas.
- Definir anclajes, pivotes, orientación, oclusión y orden de dibujo de forma consistente.

## 9. Guardado y muerte permanente

Reglas de producto en `02_DECISIONES.md`. El SaveSystem usa escritura atómica, copias técnicas temporales, validación, versionado de esquema y migraciones, sin ofrecer jamás la restauración de una partida muerta. La diferencia entre protección ante corrupción y recuperación tras muerte debe quedar probada.

## 11. Interfaz y cámara

- Cámara en vista alta inclinada (tipo Zelda), de ángulo fijo.
- Interfaz mínima y principalmente diegética.
- Deben ser claros la selección de objetivos, profundidad, oclusión, colisiones, rutas y estados críticos.
- Controles exclusivamente teclado y ratón.
- Claude debe proponer y documentar el mapa de controles antes de cerrar la primera fase jugable.

## 12. Persistencia y datos

- Datos de especies, piezas, compatibilidades, eventos, misiones, recursos y audio separados del código siempre que sea viable.
- Validación de esquemas al cargar.
- Identificadores estables para entidades persistentes.
- Semillas aleatorias registrables para reproducir errores.
- Versionado de datos y migraciones.
- No ejecutar código arbitrario procedente de archivos de contenido.

Catálogos de contenido en `core/data/` y zonas en `data/zones/`: ver `adr/0016-revision-codigo.md`.

## 13. Rendimiento

No fijar límites definitivos sin medición. Claude debe crear escenarios de prueba reproducibles que incluyan:
- 40–60 entidades visibles como objetivo inicial.
- Varias especies y comportamientos simultáneos.
- Combate y efectos.
- Transiciones de nivel de simulación.
- Carga y descarga de zonas.
- Recuperación de mundo tras ausencia.

Medir CPU, GPU, memoria, tiempos de carga y estabilidad de frame time. Los objetivos de FPS y requisitos mínimos de PC se propondrán tras un prototipo medible y se documentarán.

## 14. Pruebas obligatorias

- Pruebas automáticas por sistema.
- Pruebas de integración para interacciones entre simulación, zonas, eventos, misiones, inventario y guardado.
- Pruebas de permadeath y sobrescritura de partida.
- Pruebas de transiciones entre niveles de simulación sin duplicaciones.
- Pruebas de conversión y compatibilidades.
- Pruebas de tiempo local, cambio de día y festividades.
- Pruebas de reanudación tras cerrar el juego y de rastro de festividades.
- Pruebas de rendimiento y regresión.
- Pruebas visuales de cámara en vista alta inclinada, animaciones, oclusiones y legibilidad.

La respuesta elegida en el cuestionario fue pruebas automáticas por sistema. Las pruebas de integración anteriores son un requisito de seguridad arquitectónica para comprobar que los sistemas independientes funcionan juntos, no una sustitución de esa decisión.

## 15. Sistemas de sigilo

Añadir a los sistemas lógicos: `StealthSystem` (conos de visión, ruido y detección) y `PauseController` (pausa táctica), ambos desde las primeras fases.
