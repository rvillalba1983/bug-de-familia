# Bug de Familia: instrucciones para Claude Code

El usuario es el director del producto. Claude es responsable técnico y de producción: programa, integra, prueba y documenta. No le traslades decisiones técnicas triviales.

## Antes de trabajar
Lee `docs/00_LEEME.md` y `docs/02_DECISIONES.md`, y después solo los documentos de la tarea según la tabla del índice.

## Comandos
Motor: Godot 4.7.2 estable.

```
godot --headless --import                          # importar el proyecto
godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests -c   # pruebas
python tools/verificar.py                     # datos + normas de formato (determinista, local)
```

Comprobaciones deterministas antes de commitear: `tools/verificar.py`. En OpenCode, comando `/verificar`. Ver `docs/adr/0019-herramientas-ci-y-mcp.md`.

## Reglas
- Respeta `docs/02_DECISIONES.md`. No restaures decisiones sustituidas.
- No resuelvas por tu cuenta nada de `docs/01_CONFLICTOS_Y_PENDIENTES.md`: propón alternativas y sigue con tareas independientes.
- No inventes lo que falta. Parámetros provisionales, sí, marcados como tales.
- Mantén siempre una versión ejecutable. Trabaja por fases (`docs/40_plan_desarrollo.md`) y entregas pequeñas.
- No afirmes que algo funciona sin probarlo. Distingue pruebas ejecutadas de no ejecutadas.
- Pruebas automáticas por sistema e integración donde haya interacciones. Semillas reproducibles.
- Comprueba las APIs contra la versión fijada de Godot. Normas de código: `docs/35_normas_codigo.md`.
- Actualiza la documentación cuando cambie una decisión técnica, y registra ADR en `docs/adr/`.
- No subas código ni recursos a servicios externos sin autorización.
- Registra origen y herramienta de cada recurso generado.

## Modelo
- `opencode.jsonc` define el equipo: ver `CONFIG_AGENTS.md` (quién es quién) y `FALLBACK_MODELS.md` (precios, límites y alternativos). Decisión: `docs/adr/0018-agentes-y-modelos.md`.
- El modelo por defecto es `opencode/big-pickle` (gratuito); los agentes especializados usan OpenCode Go (`opencode-go/<modelo>`) o su gemela gratuita cuando existe.
- Go no encadena modelos: el fallback es a mano, siguiendo `FALLBACK_MODELS.md` y documentándolo en un ADR.
- Franja punta: solo el DeepSeek de Go (respaldo de qa), de lunes a viernes en 02:00-05:00 y 07:00-11:00, hora española de invierno.
- `.opencode/_disabled/model-fallback` sigue desactivado a propósito (hook inexistente en V2). No lo reactives.
- Comprobación rápida: `opencode run` debe mostrar `big-pickle` en la cabecera. Si falla por cuota o retirada (429/402/404), pega el error literal y aplica `FALLBACK_MODELS.md`.

## Una fase por conversación
- Cada fase del plan se hace en una conversación propia, que termina al fusionar esa fase en `main`.
- Al empezar, lee también `docs/03_ESTADO.md`: indica por dónde vamos y cómo preparar el entorno.
- Al fusionar en `main`: actualiza `docs/03_ESTADO.md` y comunica al usuario que hay que cambiar de conversación.

## Al cerrar una tarea
Informa de: qué se ha hecho, archivos afectados, pruebas y resultados, validación manual necesaria, limitaciones y decisiones que requieren aprobación.

## Trabajar con OpenCode
- Una fase del plan por conversación; la conversación termina al fusionar esa fase en `main`.
- El trabajo de dominio se delega a subagentes especialistas (equipo en `opencode.jsonc`, ver `CONFIG_AGENTS.md`).
- Las tareas deterministas van en scripts: solo se revisa la respuesta.
- La conversación principal coordina y decide con el director.
