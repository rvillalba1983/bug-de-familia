# Plan de desarrollo

Objetivo inmediato: una beta jugable que demuestre que el sigilo y la investigación son divertidos, antes de invertir en arte final o en simulación masiva. Cada fase acaba con una versión ejecutable, pruebas reales e informe.

| Fase | Contenido | Criterio de aceptación | Necesita |
|---|---|---|---|
| 0. Preparación | Fijar versión de Godot, repositorio, GdUnit4, estructura, escena de prueba con gráficos sencillos | Proyecto mínimo que arranca con sus pruebas | — |
| 1. Movimiento y cámara | Vista inclinada, ratón y teclado, colisiones, orden Y, oclusión y pausa táctica | Moverse y leer el espacio es fiable | — |
| 2. **Sigilo** | Conos de visión, ruido, coberturas, guardia, cámara y dron básicos | **Hito de diversión:** un reto resoluble de tres formas, probado por el director | P-04 provisional |
| 3. Cuerpo modular | Ranuras, inventarios, desgaste, pérdida, sustitución con pausa, muerte, autoguardado y único espacio | Reglas de muerte y guardado superan pruebas | — |
| 4. Conversión | Flujo completo con subconjunto de materiales, objetivos y preguntas | Convertir un objeto da una pieza usable y nunca falla | P-02, P-09 |
| 5. IAs e investigación | 3 activas de un subconjunto, tokens, cola, parloteo; prototipo de investigación con Mohócratas y Jubilados | Investigar, deducir y conversar resulta divertido sin combatir | P-05, P-18 |
| 6. Combate | Tiempo real con coberturas, armas, daño por extremidad | Peligroso, legible y evitable | — |
| 7. **Beta** | Zona de bosque, 4 retos, 2 progenitores, encuentros, peligros | Se completa de varias formas sin matar | P-01, P-08, P-10 |
| Arte | En paralelo desde la fase 2: prueba de ángulo con ChatGPT, luego protagonista por piezas y zona de bosque | Se ve bien en el juego y se aprueba | — |
| 8. Mundo vivo | Varias zonas, tres niveles de simulación, acontecimientos, misiones emergentes, festividades y motor social completo | Sin duplicados ni estados incoherentes | P-11, P-13, P-14 |
| 9. Contenido y pulido | Resto de razas, IAs y progenitores; batallas y vista de estrategia; música y voces; rendimiento | Medido, estable y documentado | — |

## Por qué este orden
El plan anterior ponía el combate antes que la investigación y construía el ecosistema muy pronto. Con el núcleo decidido el 8-nov, lo primero es probar lo más arriesgado y barato de cambiar: si el sigilo divierte. La simulación masiva es lo más caro y se apoya en decisiones aún abiertas, así que va después de la beta.

## Primera sesión de Claude Code
1. Leer `CLAUDE.md`, `00_LEEME.md` y `02_DECISIONES.md`.
2. Comprobar la versión estable de Godot 4 y registrarla.
3. Seguir por la primera fase sin terminar.

## Riesgos a validar pronto
1. Que ChatGPT mantenga al personaje y el ángulo pieza a pieza.
2. Legibilidad de cuatro brazos y piezas intercambiables en cámara.
3. Lectura de conos de visión con vista inclinada.
4. Coste de arte por dirección.
5. Rendimiento de 40–60 personajes.

## Gestión de cambios
Toda decisión técnica relevante se documenta como ADR. Si obliga a cambiar la experiencia aprobada, se detiene y se pide autorización.
