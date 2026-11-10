# ADR 0020: tres modelos por agente y rotación determinista

Estado: decidido por el director el 10-nov y aplicado en la rama
`feature/configuracion-opencode-agentes`, pendiente de fusión en `main`.

## Problema

El director pidió confirmar qué ocurre cuando un agente agota el límite de su
modelo y que **todos los agentes tuvieran tres modelos que utilizar**.

La respuesta antes de este ADR era insatisfactoria: cada agente tenía tres
alternativos, pero solo **escritos en su `system` y en `FALLBACK_MODELS.md`**.
No había nada que los aplicara. El 10-nov, al lanzar una auditoría con `qa`,
el gratuito devolvió el error literal:

```text
Free usage limit reached. Free models work in OpenCode (https://opencode.ai);
subscribe to OpenCode Go to keep going: https://opencode.ai/go
```

El subagente murió en vez de continuar con su alternativo. El diagnóstico lo
tuvo que hacer la conversación principal.

## Comprobación contra la documentación oficial de OpenCode V2

- `model` es **un único modelo** por agente (Models, Agents). No existe un campo
  de cadena ni de reintentos entre modelos en la configuración de V2.
- `/models` y `opencode run --model` cambian la selección de una sesión o de un
  run, no la configuración del agente.
- El único fallback que describe la doc es: si el modelo configurado no está
  habilitado o su proveedor no está disponible, se usa «el modelo soportado más
  nuevo disponible». No es controlable y podría elegir un modelo de pago.
- **«A model request already in progress keeps the settings it started with»**
  (Models, *Caveats*): aunque se cambiase la configuración en caliente, la
  petición que ya falló no se reintenta con el modelo nuevo.
- `docs/02_DECISIONES.md` y `AGENTS.md` ya advertían de que Go no encadena
  modelos. El plugin `.opencode/_disabled/model-fallback` sigue desactivado a
  propósito (usaba un hook inexistente en V2); no se reactiva.

Conclusión: **no es posible garantizar la conmutación automática dentro de la
misma petición con la API de V2**. Cualquier solución que lo prometiera sería
inventar una API del motor, prohibido por `docs/35_normas_codigo.md`.

## Decisión

1. **Un principal y tres alternativos por agente**, en orden, para los once
   perfiles: los nueve del proyecto, `explore` y el modelo por defecto. La
   fuente única de verdad es `tools/modelos_agentes.json`.
2. **`tools/cambiar_modelo.py`** hace operativa la rotación con un comando:
   - `--estado`: muestra el modelo activo y la cadena de cada agente.
   - `--validar`: comprueba que `opencode.jsonc`, los `system` de los agentes y
     `FALLBACK_MODELS.md` están sincronizados con la tabla (código 0/1).
   - `--rotar <agente>`: pasa al siguiente modelo de la cadena, editando solo
     la línea `model` y conservando el resto del JSONC.
   - `--usar <agente> <modelo>`, `--restaurar <agente>` y `--motivo`.
3. **Procedimiento obligatorio tras un error 429/402/404 o de límite**: rotar,
   **relanzar la tarea** y documentar el cambio en un ADR. Queda escrito en
   `FALLBACK_MODELS.md`, `CONFIG_AGENTS.md`, `AGENTS.md` y `CLAUDE.md`.
4. Se corrige al pasar la tabla un error previo: el `system` de `datos` citaba
   su propio modelo principal (`opencode-go/minimax-m3`) como alternativo.
   Pasa a `opencode-go/glm-5.3-flash`. `explore` y el modelo por defecto, que
   solo tenían uno y tres alternativos respectivamente en la guía, quedan con
   tres en la tabla.

## Consecuencias

- La rotación **no es automática ni reintenta la petición en curso**: es un
  comando de un paso más el relanzamiento de la tarea. Es el máximo que permite
  V2 sin plugins de terceros.
- `--validar` debe ejecutarse antes de commitear cambios de modelos; el CI
  podría incorporarlo en el paso de verificaciones deterministas.
- Cambiar el modelo de un agente requiere actualizar la tabla, el `system`,
  `FALLBACK_MODELS.md`, `CONFIG_AGENTS.md` y un ADR. `--validar` detecta la
  desincronización entre los tres primeros.
- Los modelos alternativos de pago siguen sujetos a la franja punta de DeepSeek
  en Go (`FALLBACK_MODELS.md`). Rotar a ciegas puede aumentar el coste; por eso
  el procedimiento pide probar antes los gratuitos que queden.
- No se reactiva el plugin desactivado ni se añaden dependencias externas.

## Alternativas consideradas

- **Plugin propio con hooks de V2 para cambiar el modelo al vuelo**: rechazado.
  Además de la limitación de la petición en curso, exigiría Node/Bun, código de
  terceros no verificado y contradice la decisión de `AGENTS.md` sobre
  `.opencode/_disabled/model-fallback`.
- **Volver a la cadena `openrouter/auto`**: rechazada por el director en el
  ADR 0018 (lenta, 50 peticiones diarias). Además es una cadena por proveedor,
  no por agente.
- **Dejar los alternativos solo documentados**: rechazado; es lo que falló hoy.
