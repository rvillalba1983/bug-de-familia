# ADR 0033: Muertes bestiales (P-27)

- Fecha: 2026-11-16
- Estado: Aceptada

## Contexto
P-27 pedía muertes exageradas, gamberras y chocantes (no «muertes de bestias»), con catálogo revisado y aprobado por el director, igual que P-09. Ya existía infraestructura: `DeathCatalog` (`pick` con semilla, sin gastar RNG si hay una sola opción), `data/combat/deaths.json` (solo `caida`), `species.json` con `deaths` por especie y `guard_impacts.gd`/`guard_visual.gd` consumiendo los campos de caída.

Las ideas del lote 1 que dependían de escenario (árbol, lluvia) no encajaban con el mundo actual. Además, crear animaciones nuevas del rig por cada muerte encarecía el arte y las pruebas validan que la animación exista como clip.

## Decisión
1. **Datos y catálogo.** `deaths.json` pasa a tener 13 entradas: `caida` (sin efecto, compatibilidad) y 12 muertes con `effect`, `effect_color` y `effect_duration`, manteniendo los campos de caída (`animation`, `shake`, `stop`, `land_delay`, `land_shake`, `land_squash`, `corpse_time`). `DeathCatalog.FIELDS` y `ids()` se amplían en consecuencia.
2. **Reparto.** Cada especie recibe 6 muertes genéricas (`trozos`, `cohete`, `confeti`, `congelado`, `estatua`, `muelle`) y 1 propia: Jubilado `apagon`, Mohócrata `oxidacion`, Plegado `origami`, Eco `burbujas`, Grux `prensa`, Manada `dispersion`.
3. **Efecto visual.** La caída física reutiliza la animación `caer`. Lo gamberro se dibuja en un `DeathEffect` (`combat/death_effect.gd`) que se instancia al caer el guardia (`Guard._spawn_death_effect`) y no altera reglas, colisiones ni `corpse_time`.
4. **Pruebas.** `tests/combat/deaths_test.gd` valida catálogo, reparto por especie, reproducibilidad con semilla 1234, consumo de RNG solo con varias opciones, que cada efecto puede reproducirse sobre un guardia y que al caer se conserva `corpse_time` y aparece el efecto.

Catálogo aprobado por el director: `docs/borradores/P-23_P-27_P-09_lotes.md` (lote 2, 16-nov-2026).

## Consecuencias
- Las muertes dejan de ser solo «caída» y pasan a ser contenido de datos ampliable.
- Nuevas muertes futuras deben declarar todos los campos del catálogo, usar una animación existente (o añadirla y cubrirla en pruebas) y, si llevan efecto, implementarlo en `DeathEffect`.
- Queda pendiente validación manual en partida (lectura visual y tono) y, como siempre, la medición/regresión la marca el CI y la gráfica real del director.
