# ADR 0018: equipo de agentes y modelos con OpenCode Go

Estado: aprobado por el director el 10-nov. La cuenta y la suscripción Go están activas y validadas con peticiones reales. Pendiente de fusión en `main`.

## Problema

Los agentes del proyecto iban todos sobre `openrouter/auto`, una cadena de tres modelos gratuitos de OpenRouter definida en la configuración global. El director la ha probado para el trabajo diario y es lenta y no viable: el tier gratuito limita a 50 peticiones al día. Además, la post-beta (cuatro razas, 13 progenitores, zonas nuevas, tres niveles de simulación) necesita perfiles que no existían: contenido en JSON, arte, audio y medición en la gráfica real.

## Decisión

Suscripción a OpenCode Go (plan Go, 10 $ al mes) como fuente fija de modelos, combinada con los modelos gratuitos de la consola de OpenCode siempre que sirvan. Sin «Extra Usage»: la intención es no pasar de los 10 $ al mes.

| Agente | Modelo | Fuente |
|---|---|---|
| Por defecto (`build`, `plan`, `general`) | `opencode/big-pickle` | Gratis |
| `explore` | `opencode/big-pickle` | Gratis |
| `arquitecto` | `opencode-go/glm-5.3` | Go |
| `datos` | `opencode-go/minimax-m3` | Go |
| `ingeniero-godot` | `opencode-go/kimi-k2.7-code` | Go |
| `gameplay` | `opencode-go/qwen3.7-plus` | Go |
| `qa` | `opencode/deepseek-v4.1-flash-free` | Gratis |
| `documentacion` | `opencode/glm-5.3-flash-free` | Gratis |
| `arte` | `opencode-go/qwen3.8-flash` | Go |
| `audio`, `medidor` | `opencode-go/glm-5.3-flash` | Go |

Criterios de asignación:

- El mayor volumen es la conversación principal, no los subagentes: el modelo por defecto es el gratuito, y las ventanas de Go quedan para los especialistas.
- Donde existe gemela gratuita del mismo modelo (DeepSeek y GLM flash), el agente usa la gratis y la de Go queda de respaldo.
- Cada agente especializado usa el modelo fuerte de su dominio (código para Kimi K2.7 Code, razonamiento de GLM-5.3 en arquitectura, 1M de contexto y 60 $ de límite para MiniMax M3 en datos, multimodal para Qwen en arte), con Big Pickle de primer respaldo.
- Los premium del catálogo Go (Kimi K3.1 Pro, Grok 4.7, Gemini Argon) solo traen 15 $ de límite mensual: sin agente fijo, uso manual y puntual.

Agentes nuevos: `datos` (JSON del mundo), `arte` y `audio` (separados al pedirse el director: perfiles y permisos distintos) y `medidor` (rendimiento en la gráfica real). El equipo completo y los permisos, en `CONFIG_AGENTS.md`; precios, límites y alternativos, en `FALLBACK_MODELS.md`.

## Horario de menor coste

Solo DeepSeek en Go cambia de precio: el doble de lunes a viernes entre las 02:00-05:00 y 07:00-11:00, hora española de invierno. El resto cuesta igual a cualquier hora y los gratuitos no tienen franja. Plan: qa trabaja con el gratuito a cualquier hora; si cae al DeepSeek de Go, se hace fuera de punta o se usa otro alternativo.

## Consecuencias

- Go no encadena modelos: cuando un modelo agota su ventana de 5 horas o se retira un gratuito, el cambio es a mano, siguiendo `FALLBACK_MODELS.md` y documentándolo en un ADR.
- Los gratuitos son por tiempo limitado. Si se retiran, los agentes afectados fallan con 404 hasta cambiar su modelo. Big Pickle es además un modelo «sigiloso» cuyo proveedor puede usar las conversaciones para mejorarlo durante el periodo gratuito; DeepSeek y GLM flash free son de retención cero.
- El director decidió que big-pickle lleve las conversaciones principales: acepta ese uso de datos y la fragilidad del gratuito. Para tareas delicadas se cambia de modelo solo en esa conversación (`/models`), sin tocar la configuración.
- La cuenta sirve 24 de los 32 modelos publicados en la documentación de Go (comprobado al activarla): entre los ausentes, `glm-5.2` y `gpt-5.6-luna`. Por eso arquitecto usa `glm-5.3` y datos `minimax-m3`.
- Validado el 10-nov con peticiones reales: `arquitecto` sobre `opencode-go/glm-5.3` y `documentacion` sobre `opencode/glm-5.3-flash-free` respondieron correctamente; las conversaciones principales ya iban sobre `opencode/big-pickle`.
- En la consola hay que habilitar Regiones › Global para el respaldo `deepseek-v4.1-flash` de Go. Lo activó el director el 10-nov y quedó validado con una petición real.
- La cadena `openrouter/auto` global deja de usarse en este repositorio (sigue existiendo para otros proyectos). El plugin `.opencode/_disabled/model-fallback` sigue desactivado.
- Coste fijo: 10 $ al mes mientras dure la suscripción, sin prepago por token.

## Alternativas consideradas

- **OpenRouter con saldo prepago**: sin cuota fija y con los 600 modelos, pero por 10 $ da unas cinco veces menos uso que Go en los modelos flash equivalentes, y el plan gratuito ya resultó inviable.
- **Solo consola de OpenCode por uso**: acceso a los premium (Claude, GPT, Gemini) pagando por token, sin cuota fija; pero el gasto mensual sería variable e impredecible para el volumen de este proyecto.
- **Mantener la cadena gratuita de OpenRouter**: rechazada por el director por lentitud y límite de 50 peticiones al día.
