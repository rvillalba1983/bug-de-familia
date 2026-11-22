# ADR 0037: limpieza automática de logs de pruebas

Estado: **aceptado por el director el 21-nov-2026**. Implementado en la rama
`fase/postbeta-progenitores-encuentros`; pendiente de commit, push y PR.

## Contexto

Los días 20 y 21-nov dos ejecuciones de GdUnit4 en modo headless se colgaron
en el prompt `debug>` (descrito en `AGENTS.md` y `HERRAMIENTAS.md` §4) y
escribieron 36,74 GiB en `reports/combat2.log` y 11,46 GiB en
`reports/zones.log`. Se borraron el 21-nov, junto con un `gz.log` de una
tercera ejecución colgada. `reports/` está ignorada por git: el CI no puede
limpiar estos archivos y el consumo crece solo en la máquina local.

## Decisión

1. **Ámbito:** solo archivos `.log` directos de `reports/` con más de 48 horas
   desde su última modificación (mtime). Se conservan los informes HTML/XML,
   los subdirectorios, `humo.log` y los enlaces simbólicos.
2. **Disparador:** `tools/verificar.py`, como primer paso. Se ejecuta al
   verificar o antes de cada commit, y también en el CI (donde no hay
   `reports/` y la herramienta no hace nada).
3. **Edad por mtime, no por fecha de creación:** un log que se sigue
   escribiendo no se borra aunque se haya creado hace días.
4. **Visibilidad:** cada borrado se imprime con su antigüedad. Si un archivo
   no se puede leer o borrar, se imprime `[ERROR]` y `verificar.py` falla:
   ningún fallo queda silenciado.
5. **Sin tarea programada de Windows:** el director descartó crear una tarea
   del sistema; la limpieza solo ocurre cuando se verifica o se commitea.

## Alternativas descartadas

- **Tarea programada de Windows cada hora:** habría sido autónoma, pero
  requiere un cambio en el sistema fuera del repositorio. Descartada por el
  director.
- **Borrar también `reports/report_N/` y `humo.log`:** descartada; se perderían
  informes y registros que aún pueden servir para diagnosticar un fallo.
- **Borrar logs grandes aunque sean recientes:** descartada; el criterio
  pedido es temporal y un log activo podría estar en uso.

## Consecuencias y limitaciones

- Un log que deja de escribirse y no se toca en 48 h se borra en la primera
  verificación posterior. Un log **activo** no se borra: hay que cortar la
  ejecución colgada con `cmd /c "... < NUL"` y un timeout, como ya indica
  `HERRAMIENTAS.md` §4.
- `limpiar_logs.py` acepta `--horas` y `--dry-run` para probar sin borrar.
- Pruebas ejecutadas el 21-nov: 7 casos nuevos en
  `tools/tests/test_limpiar_logs.py`; en Windows se omite el de enlaces
  simbólicos por falta de permisos. `python -m unittest discover -s
  tools/tests -q`: 68 pruebas, OK (1 omitida).
  `python tools/formatear.py --comprobar --resumen`: 378 archivos, 0 errores.
- **No ejecutadas:** suite GdUnit ni exportación del `.exe`. El cambio solo
  afecta a herramientas Python y documentación.
- Queda fuera de alcance la causa de los errores de `combat_test.gd:59` y
  `content_test.gd:120` que provocaron los logs; el director pidió limitarse
  al consumo de disco.
