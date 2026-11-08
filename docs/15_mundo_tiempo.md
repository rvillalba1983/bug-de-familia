# Mundo y tiempo

## Estructura
- Numerosas zonas relativamente independientes, conectadas por accesos que se descubren explorando, con cargas breves.
- Diseño mayoritariamente manual; lo procedural es para elementos dinámicos. Detalle técnico en `34_zonas_y_contenido.md`.
- Se puede volver a cualquier zona conocida si hay camino.
- Lo que pierdes o ganas te acompaña entre zonas.
- La geometría de cada zona es fija. Los cambios relevantes persisten como estados diseñados de antemano, como puente roto o zona inundada.
- Sin vehículos ni monturas. Se puede viajar entre puntos de guardado.
- Una nueva partida mantiene la estructura del mundo; cambian situaciones, relaciones y acontecimientos.

## Tiempo
- Día y noche con la hora local real, de forma estricta. Las especies cambian de actividad según la hora.
- Con el juego cerrado el mundo se congela: solo avanzan el día, la noche y el calendario.

## Festividades
- 36 al año, tres por mes, en fechas del calendario real. Si no estás jugando, pasan y no se recuperan, pero dejan rastro al volver: restos y comentarios, sin simular nada más.
- Se comunican por comportamiento, conversaciones, IA y ambiente. No son misiones ni bloquean contenido.
- Afectan a actividades, reuniones, comercio y conversaciones. El jugador puede intervenir y alterarlas, con consecuencias locales permanentes.
- Estructura fija con variaciones. Sin ubicación fija: dependen de quién esté presente. Todas las especies pueden participar y los grupos pueden organizarlas o apropiárselas.
- Eventos procedentes de catálogos escritos, no de IA generativa.

## Anomalías y acontecimientos
- Anomalías ambientales de todo tamaño, desde fenómenos menores hasta catástrofes. Pueden moverse entre zonas y alterar poblaciones, recursos y comportamiento. Ejemplo: una lluvia de sal reduce drásticamente una población sin eliminar la especie.
- Acontecimientos muy frecuentes y variados, con jerarquía entre cotidianos, extraños, sociales, ambientales y extraordinarios. Tienen causas coherentes.
- Los importantes pueden ocurrir sin que el jugador los vea y descubrirse por sus consecuencias.

## Población
- Límites configurables por especie y zona.
- Reproducción entre grupos compatibles; grupos próximos pueden fusionarse o enfrentarse.
- Recolonización natural desde otras zonas.
- Nacimientos y llegadas pueden ocurrir también en directo, con el jugador presente.
- No todas las especies son depredadoras.
- Número inicial de especies: lo fija Claude según capacidad; la beta usa dos.

## Simulación por distancia
| Nivel | Dónde | Qué se simula |
|---|---|---|
| Completa | Zona del protagonista | IA, movimiento, interacciones, decisiones y animación individuales |
| Simplificada | Zonas cercanas o conocidas | Alimentación, desplazamiento, reproducción, conflictos, relaciones y recursos, sin animar |
| Estadística | Zonas lejanas | Poblaciones, recursos, relaciones y acontecimientos agregados, sin individuos activos |

Al regresar, los acontecimientos importantes se conservan con exactitud y los detalles cotidianos pueden aproximarse. Las transiciones no deben duplicar ni perder individuos, recursos ni acontecimientos.
