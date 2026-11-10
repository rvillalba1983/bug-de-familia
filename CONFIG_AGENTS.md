# Equipo de agentes - Configuración

Última actualización: 10-nov-2026, junto a `adr/0018-agentes-y-modelos.md`. Modelos, precios y procedimiento de cambio: `FALLBACK_MODELS.md`.

## El equipo

`opencode.jsonc` define ocho agentes del proyecto y fija el modelo del integrado `explore`. El modelo por defecto (línea `model`) lo usan `build`, `plan` y `general`.

| Agente | Dominio | Puede tocar | Modelo |
|---|---|---|---|
| `arquitecto` | Arquitectura, ADR, coherencia entre sistemas | Todo, con confirmación | Go `glm-5.2` |
| `ingeniero-godot` | GDScript y escenas de Godot 4.7.2 | `*.gd`, `*.tscn`, con confirmación | Go `kimi-k2.7-code` |
| `gameplay` | Mecánicas, simulación, balance, especies | `*.gd`, `*.tscn`, con confirmación | Go `qwen3.7-plus` |
| `qa` | Auditoría y diseño de pruebas | Solo lectura | Gratis `deepseek-v4.1-flash-free` |
| `documentacion` | Documentación, lore, continuidad | `*.md`, `*.json`, con confirmación | Gratis `glm-5.3-flash-free` |
| `datos` | Contenido del mundo en JSON (`data/`) | `*.json`, con confirmación | Go `glm-5.2` |
| `arte` | Atlas, estilo visual y capturas | `art/**`, `data/art/**`, con confirmación | Go `qwen3.8-flash` |
| `audio` | Melodías y voces con `gen_audio.py` | `audio/**`, `data/audio/**`, con confirmación | Go `glm-5.3-flash` |
| `medidor` | Medir rendimiento en la gráfica real | Solo lectura | Go `glm-5.3-flash` |
| `explore` (integrado) | Búsqueda rápida por código y web | Solo lectura | Gratis `big-pickle` |
| Por defecto (`build`, `plan`, `general`) | Conversación principal, planes, investigación | Según permisos globales | Gratis `big-pickle` |

Reglas comunes a todos: `git push` siempre pide confirmación, los parámetros provisionales se marcan como tales y nadie desactiva pruebas para conseguir verde.

## Reparto de dominios entre agentes parecidos

- **ingeniero-godot** frente a **gameplay**: el ingeniero implementa; gameplay diseña y propone. Si una discusión es «¿cómo debe sentirse esto?», es gameplay; si es «¿cómo se escribe esto en Godot?», es el ingeniero.
- **datos** frente a **documentacion**: datos edita los JSON del mundo; documentacion edita los documentos. Un cambio de contenido va a datos; un cambio de spec o de lore, a documentacion (y el arquitecto si toca decisiones).
- **arte** frente a **audio**: mismo patrón con recursos. Ambos registran origen y herramienta de lo que generan (requisito de `AGENTS.md`).
- **medidor** mide e interpreta; las optimizaciones las propone al arquitecto y las implementa el ingeniero.
- **qa** no edita: diseña pruebas y audita. Las escribe luego el ingeniero.

## Añadir o cambiar un agente

1. Editar `agents` en `opencode.jsonc`: descripción, `model`, `system`, `mode: "subagent"` y permisos.
2. Elegir modelo según `FALLBACK_MODELS.md` y anotar los alternativos en el propio `system`.
3. Actualizar este archivo y `FALLBACK_MODELS.md`.
4. Si es una decisión técnica, ADR en `docs/adr/` y sincronizar `AGENTS.md` y `CLAUDE.md` si cambia la política general.
5. La configuración se recarga sola al guardar; `/reload` fuerza la recarga.

## Verificación

- `opencode run` desde la raíz del proyecto debe mostrar `big-pickle` en la cabecera de la respuesta.
- `/models` debe listar los modelos de `opencode` (gratuitos) y de `opencode-go` (suscripción).
- Un subagente se prueba pidiéndole algo de su dominio en una conversación.
