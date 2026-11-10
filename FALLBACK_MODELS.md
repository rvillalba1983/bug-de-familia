# Guía de modelos y fallback de los agentes

Última actualización: 10-nov-2026, junto a `adr/0018-agentes-y-modelos.md`.

## Fuentes de modelos

| Fuente | Prefijo | Coste | Cuándo |
|---|---|---|---|
| Consola de OpenCode, gratuitos | `opencode/<modelo>` | 0 $ | Siempre que existan: son por tiempo limitado y pueden retirarse |
| OpenCode Go (plan Go, 10 $/mes) | `opencode-go/<modelo>` | Incluido hasta el límite de cada modelo | Respaldo fijo cuando el gratuito no basta o se retira |

La cuenta de OpenRouter y su cadena `openrouter/auto` global (`~/.config/opencode/opencode.json`) siguen existiendo para otros proyectos; este repositorio ya no la usa.

## Asignación actual por agente

Cada modelo de Go tiene tres ventanas: 5 horas (20 % del límite mensual), semanal (50 %) y mensual (100 %). Superada una ventana, ese modelo se bloquea hasta que se renueve: hay que cambiar de modelo a mano. Los gratuitos no tienen franja punta; el único precio variable es DeepSeek en Go (ver abajo).

**Todos los agentes tienen su principal y tres alternativos**, en este orden. La fuente única de verdad es `tools/modelos_agentes.json`; `tools/cambiar_modelo.py --validar` comprueba que esta guía, `opencode.jsonc` y el `system` de cada agente no se han desincronizado. OpenCode V2 no encadena modelos: al agotarse uno, la petición en curso falla y no se reintenta sola.

| Agente | Modelo principal | Alternativos, en orden |
|---|---|---|
| Por defecto (`build`, `plan`, `general`) | `opencode/big-pickle` (gratis) | `opencode-go/kimi-k2.7-code`, `opencode/iceman-free`, `opencode/glm-5.3-flash-free` |
| `explore` (integrado) | `opencode/big-pickle` (gratis) | `opencode-go/gpt-6-luna`, `opencode/beam-free`, `opencode/glm-5.3-flash-free` |
| `arquitecto` | `opencode-go/glm-5.3` | `opencode/big-pickle`, `opencode-go/kimi-k2.7-code`, `opencode/glm-5.3-flash-free` |
| `ingeniero-godot` | `opencode-go/kimi-k2.7-code` | `opencode/big-pickle`, `opencode-go/glm-5.3`, `opencode/glm-5.3-flash-free` |
| `gameplay` | `opencode-go/qwen3.7-plus` | `opencode/big-pickle`, `opencode-go/minimax-m3`, `opencode/glm-5.3-flash-free` |
| `qa` | `opencode/deepseek-v4.1-flash-free` (gratis) | `opencode-go/deepseek-v4.1-flash` (¡franja punta!), `opencode/big-pickle`, `opencode/beam-free` |
| `documentacion` | `opencode/glm-5.3-flash-free` (gratis) | `opencode-go/glm-5.3-flash`, `opencode/big-pickle`, `opencode-go/gpt-6-luna` |
| `datos` | `opencode-go/minimax-m3` | `opencode/big-pickle`, `opencode-go/glm-5.3-flash`, `opencode/glm-5.3-flash-free` |
| `arte` | `opencode-go/qwen3.8-flash` | `opencode-go/qwen3.7-plus`, `opencode/big-pickle`, `opencode/glm-5.3-flash-free` |
| `audio` | `opencode-go/glm-5.3-flash` | `opencode/glm-5.3-flash-free`, `opencode/big-pickle`, `opencode/beam-free` |
| `medidor` | `opencode-go/glm-5.3-flash` | `opencode/glm-5.3-flash-free`, `opencode-go/gpt-6-luna`, `opencode/beam-free` |

Criterio: los agentes con versión gemela gratuita (qa, documentacion) o de alto volumen (conversaciones principales, explore) van sobre el gratuito; los especializados sin gemela gratuita usan Go con Big Pickle de primer respaldo, para no gastar ventanas de otros modelos de Go.

## Rotaciones vigentes (10-nov)

| Agente | Modelo en config | Motivo | Volver |
|---|---|---|---|
| `explore` | `opencode-go/gpt-6-luna` (alternativo 1, de pago) | `Free usage limit reached` en `opencode/big-pickle`; el director pidió «rota a modelo de pago» | `python tools/cambiar_modelo.py --restaurar explore` |

La cadena de `tools/modelos_agentes.json` no cambia: sigue siendo la fuente única y el
principal de la cadena sigue siendo `big-pickle`. Validado con `--validar` (0 errores) y
la tarea se relanzó con el modelo nuevo. Detalle completo en `adr/0022-rotacion-explore-a-go.md`.

## Catálogo Go usado

Precio por millón de tokens y límite mensual de uso incluido en el plan Go (10 $/mes):

| Modelo | Entrada | Salida | Límite mensual | Uso |
|---|---|---|---|---|
| `kimi-k2.7-code` | 0,95 $ | 4,00 $ | 60 $ | Código GDScript |
| `glm-5.3` | 1,40 $ | 4,40 $ | 15 $ | Arquitectura |
| `qwen3.7-plus` | 0,40 $ | 1,60 $ | 60 $ | Gameplay y balance |
| `qwen3.8-flash` | 0,15 $ | 0,47 $ | 30 $ | Arte (multimodal) |
| `glm-5.3-flash` | 0,15 $ | 0,50 $ | 60 $ | Audio y medidor |
| `gpt-6-luna` | 0,10 $ | 0,50 $ | 15 $ | Respaldo barato |
| `minimax-m3` | 0,30 $ | 1,20 $ | 60 $ | Datos (JSON) |
| `deepseek-v4.1-flash` | 0,15–0,30 $ | 0,60–1,20 $ | 100 $ | Respaldo de qa |

Premium del catálogo (Kimi K3.1 Pro, Grok 4.7, Gemini 4 Argon, Claude Haiku): solo 15 $ de límite mensual. No se asignan a ningún agente; si una tarea puntual los necesita, se eligen a mano en esa conversación.

La cuenta sirve 24 de los 32 modelos publicados en la documentación de Go (comprobado al activarla el 10-nov). Entre los ausentes: `glm-5.2`, `gpt-5.6-luna`, `kimi-k3`, `longcat-2.0` e `hy3`. Por eso arquitecto usa `glm-5.3` y datos `minimax-m3`. Validado con peticiones reales: `glm-5.3` en Go y `glm-5.3-flash-free` en la consola.

## Franja punta: solo DeepSeek en Go

`opencode-go/deepseek-v4.1-flash` y `deepseek-v4-pro` cuestan el doble de lunes a viernes en 02:00-05:00 y 07:00-11:00, hora española de invierno (una hora más en verano; el horario de referencia es UTC). El resto de modelos cuesta igual a cualquier hora, y `opencode/deepseek-v4.1-flash-free` (el principal de qa) no tiene franja punta.

Plan: qa trabaja con el gratuito a cualquier hora. Si hay que caer al DeepSeek de Go, se hace fuera de la franja punta, o se usa otro alternativo.

## Gratuitos de la consola usados

| Modelo | Privacidad | Nota |
|---|---|---|
| `opencode/big-pickle` | Durante el periodo gratuito, puede usar las conversaciones para mejorar el modelo | Modelo «sigiloso»; es el que atiende las conversaciones principales |
| `opencode/glm-5.3-flash-free` | Retención cero, sin entrenamiento | Gemela gratuita de glm-5.3-flash |
| `opencode/deepseek-v4.1-flash-free` | Retención cero, sin entrenamiento | Gemela gratuita de deepseek-v4.1-flash |
| `opencode/beam-free` | Sin entrenamiento; retiene 30 días | Respaldo |
| `opencode/iceman-free` | Retiene y usa los datos para mejorar el modelo | Respaldo |

Todos son «por tiempo limitado». Cuando OpenCode los retire, los agentes que los usan como principal fallarán con error 404 y pasarán a su primer alternativo siguiendo el procedimiento de abajo.

## Procedimiento de cambio (fallback)

Cuando un modelo falla por límite de Go, por retirada del periodo gratuito (429/402/404) o por decisión del director:

1. Identificar el modelo que falló con el error literal. Ejemplo real del 10-nov: el subagente `qa` devolvió `Free usage limit reached. Free models work in OpenCode; subscribe to OpenCode Go to keep going` y la tarea murió en vez de seguir con su alternativo.
2. Elegir el siguiente modelo de la cadena en `tools/modelos_agentes.json`. Antes de tocar un modelo de pago distinto del asignado, probar los gratuitos que queden.
3. Ejecutar `python tools/cambiar_modelo.py --rotar <agente>` (o `--usar <agente> <modelo>`). El script edita solo la línea `model` de `opencode.jsonc`; la configuración se recarga sola. Con `--estado` se ve la cadena completa y con `--validar` se comprueba la sincronización.
4. **Relanzar la tarea**: la petición que falló no se reintenta con el modelo nuevo (documentación V2 de Models). No sirve con cambiar la config a mitad de sesión.
5. Documentar el cambio en un ADR de `docs/adr/` (qué falló, qué se eligió, fecha y motivo) y actualizar este archivo y `CONFIG_AGENTS.md`. Con `--restaurar <agente>` se vuelve al principal cuando se renueve la ventana.
6. Informar al director.

Ver el uso consumido en la consola de OpenCode (opencode.ai/console): cada modelo muestra su saldo de las ventanas de 5 horas, semana y mes.

## Ajustes de la consola necesarios

- **Suscripción Go**: imprescindible para los modelos `opencode-go/*`.
- **Ajustes › Privacidad › Regiones › Global**: habilita `deepseek-v4.1-flash` y `deepseek-v4-pro` en Go (el respaldo de qa). Activado por el director el 10-nov y validado con una petición real; el servidor de DeepSeek es de retención cero.
- **Uso adicional (Extra Usage)**: opcional; si se activa, al agotar un límite de Go se sigue con el saldo prepago de la consola en vez de bloquearse. Por ahora desactivado: la intención es no pasar de los 10 $/mes.
