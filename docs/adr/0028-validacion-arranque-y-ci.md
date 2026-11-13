# ADR 0028: validación de arranque y conteo de pruebas antes de fusionar

Estado: **validada** (13-nov-2026). El mecanismo se implementó en herramientas y workflows de la rama `arreglo/arranque-despliegue-cero` y se validó con resultados reales: `tools/verificar_humo.py` detectó 9 errores en el `.exe` antiguo (BetaLayout/BetaZone, escena beta inexistente, sin partida); `tools/validar_informes.py` detectó el falso verde (GdUnit devuelve 0 con 0 casos); tras el arreglo, la suite completa dio 372/372 (53 suites) con el informe JUnit validado, el import quedó limpio y el `.exe` arrancó montando `despliegue_cero` con 36 habitantes. Documentado en `HERRAMIENTAS.md`.

## Contexto

El PR #7 (fase contenido-zonas) se fusionó en `main` el 13-nov con CI verde, siguiendo el procedimiento de `adr/0023-exe-en-cada-fusion.md`: el `.exe` se genera antes de pedir la fusión. Sin embargo, tras la fusión el `.exe` local y el de GitHub no arrancan: el renombrado beta → despliegue_cero quedó incompleto y hay errores de parseo (`BetaLayout` en `scenes/zones/zone_base.gd:459`; `BetaZone` en `conversion/action_system.gd:178, 180, 267 y 271`), fallos de compilación en `scenes/sandbox/sandbox.gd`, `simulation/zone_manager.gd` y `scenes/world/world.gd`, y la zona de inicio «beta» ya no existe (incidente documentado en `docs/03_ESTADO.md`, sección «Incidente de arranque tras el PR #7»).

Dos huecos de validación quedaron expuestos:

1. **El CI verde no prueba el arranque del `.exe`.** La exportación se genera, pero nadie comprueba que arranca. El exportar.yml solo produce el artefacto.
2. **El CI verde no garantiza que las pruebas se ejecutaran.** Si un script no compila, las suites afectadas pueden no llegar a ejecutar casos y el run puede salir verde igualmente. Además, el CI va dividido en 4 jobs (core, combate, simulación, beta), así que ningún job muestra por sí solo el total de la suite. La cifra «367 pruebas» que la fase dejaba escrita es **histórica y no comprobada**: no es una referencia fiable para contrastar nada.

**Causa identificada del falso verde** (coincide con el diagnóstico y con lo que las herramientas nuevas cubren; la confirmación final llega con los resultados de qa): GdUnit4 termina con código 0 aunque no ejecute ningún caso —por ejemplo, cuando la carpeta pedida con `-a` no existe, como tras el renombrado beta → despliegue_cero—, y el CI solo comprobaba el código de salida del proceso, no el informe JUnit que GdUnit4 escribe en `reports/report_N/results.xml`.

## Decisión (en implementación)

1. **Prueba de humo del binario exportado en cada fusión.** Herramienta: `tools/verificar_humo.py`. Lanza el binario exportado con `--headless` y la escena principal real de `project.godot`, con el perfil de usuario aislado (`user://` redirigido a un directorio propio con `APPDATA` en Windows y `XDG_DATA_HOME` en Linux). No basta con `exit 0` ni con un log sin errores (`world.gd` solo hace `push_error` y sigue vivo): exige la prueba positiva de que la zona se montó — `user://partida.json` con esquema versión 3, cuerpo del protagonista, zona actual (`--zona`, por defecto `despliegue_cero`) marcada visitada, estado no vacío y población con individuos— y revisa el registro (banner del motor; rechaza prefijos `ERROR:`/`USER ERROR:`/`SCRIPT ERROR:`/`Parse Error:` y avisos de zona sin montar). En el CI corre en el job «arranque» de `pruebas.yml` sobre el binario Linux; el binario Windows del artefacto de `exportar.yml` se puede comprobar a mano con la misma herramienta. Esto es una verificación técnica que el equipo ya hace como parte de los arreglos y pruebas pedidos: **no crea ningún requisito nuevo de aprobación**; las aprobaciones siguen siendo las del procedimiento de fusión ya vigente (`adr/0023-exe-en-cada-fusion.md` y las reglas de Git de `AGENTS.md`).
2. **Verificar descubrimiento y ejecución, no una cifra fija.** Herramienta: `tools/validar_informes.py`, que valida el informe JUnit real de GdUnit4 (`reports/report_N/results.xml`, el más reciente): que exista y sea de GdUnit4, que se hayan ejecutado casos (no cero, y al menos el suelo `--minimo` del grupo), que no haya fallos, errores ni omitidas, que los conteos cuadren (raíz = suma de suites = casos del XML) y que cada carpeta pedida con `-a` tenga al menos una suite. `--minimo` es un suelo por grupo, no un total universal: puede subir con cada prueba nueva, pero no debe bajarse para conseguir verde. No se fija un total universal: el número sube con cada prueba nueva y el CI reparte la ejecución entre jobs; el número real de pruebas de la fase queda **no verificable hasta que corra la suite completa**, y se registra como tal.
3. **Rutas `res://` literales verificadas sin Godot.** Herramienta: `tools/validar_rutas.py`, integrada en `tools/verificar.py`: recorre código, escenas, datos y workflows y comprueba cada literal `res://...` contra el árbol; un renombrado incompleto como el del 13-nov falla en segundos, antes de descargar Godot. No cubre rutas dinámicas ni `user://`.
4. **CI (en revisión en esta rama).** Objetivo registrado, puede seguir cambiando hasta el resultado de qa: en `pruebas.yml`, import que falla ante errores de script del log, matrix renombrada a «despliegue_cero» con suelo por grupo y paso de validación del informe con `validar_informes.py`; job nuevo «arranque» (Linux) con `verificar_humo.py`. En `exportar.yml`, exportación que falla ante errores de script y comprueba que `.exe` y `.pck` existen y no están vacíos.
5. **No cerrar una fase sin arranque verificado.** Una fase solo se marca cerrada (y el «Mundo completo» se declara confirmado) cuando coincidan: CI verde con descubrimiento y conteos verificados, prueba de humo del binario sin errores y, según la fase, la validación manual en partida que ya exige el flujo del proyecto.

## Consecuencias y limitaciones

- La decisión añade un paso al procedimiento de fusión (`adr/0023-exe-en-cada-fusion.md`); si la validación lo confirma, ese ADR se actualiza en el mismo cambio. El mecanismo concreto ya está documentado en `HERRAMIENTAS.md` (§3 y §8).
- No está validada: los tres scripts (`validar_rutas.py`, `validar_informes.py`, `verificar_humo.py`) y el arreglo de arranque en curso esperan resultados que confirmen que detectan este tipo de fallo y que las suites vuelven a ejecutarse de verdad.
- La prueba de humo en headless no cubre la ventana ni la gráfica; no sustituye a la validación manual en partida ni a la medición en gráfica real.
- Al no fijarse una cifra universal, la detección de regresiones por conteo es relativa: detecta suites vacías, parseos fallidos y desajustes entre lo descubierto y lo ejecutado, no un total objetivo. El total real se conocerá con la suite completa cuando el arranque funcione.
- Sin requisitos de aprobación nuevos: los puntos 1 y 2 son comprobaciones técnicas; solo el cierre de fase y la fusión siguen las aprobaciones del director ya establecidas.

## Referencias

- Incidente reproducido con log literal: `docs/03_ESTADO.md`, sección «Incidente de arranque tras el PR #7 (13-nov)».
- Generación del `.exe` en cada fusión: `adr/0023-exe-en-cada-fusion.md`.
- Herramientas y CI: `adr/0019-herramientas-ci-y-mcp.md` y `HERRAMIENTAS.md`.
- Renombrado afectado: fases multi-zona y contenido-zonas (`adr/0027-multi-zona.md`).
