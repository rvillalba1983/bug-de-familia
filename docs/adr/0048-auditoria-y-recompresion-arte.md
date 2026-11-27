# ADR 0048: auditoría y recompresión local del arte (27-nov)

Estado: decisión del director del 27-nov, implementada en la rama
`fase/auditoria-arte-27-11` y todavía **sin fusionar**. Coste: 0 créditos.
Sin servicios externos, sin arte nuevo y sin mover rutas. Las ganancias se
informan como bytes, nunca como FPS.

## Contexto

El punto de diseño futuro del 14-nov en `docs/03_ESTADO.md` pedía revisar
`art/` para (a) organizar por categorías y (b) estudiar si los PNG estaban
optimizados para Godot. El director eligió para esta conversación la opción
de **auditoría y optimización local**, con tres límites explícitos: no mover
rutas, no generar arte nuevo y no subir nada a servicios externos. Tampoco
se ha autorizado medir en la gráfica real.

El inventario inicial de `art/` era de 40.500.406 bytes, con dos PNG de
carga que concentraban el 12,8 % de ese total.

## Decisión

### 1. Auditoría lectora repetible

`tools/art/auditar_arte.py` emite un JSON con inventario por extensión,
archivos mayores, integridad de PNG (firma, CRC de todos los chunks y
descompresión de IDAT), grupos por SHA256 y candidatos a huérfano por
nombre literal. **No escribe nada** y no necesita Godot ni dependencias.

Los candidatos a huérfano son una pista, no una sentencia: las rutas
dinámicas (`%s`, concatenaciones) producen falsos positivos. Ningún archivo
se borra basándose solo en esta heurística.

### 2. Recompresión PNG sin pérdida y verificada

`tools/art/recomprimir_png.py [rutas]` prueba 5 estrategias de zlib
(`default`, `filtered`, `huffman`, `rle` y `fixed`), 9 niveles y 2 tamaños
de ventana. Solo sustituye los chunks IDAT, conserva el formato de píxel y
las demás etiquetas, y exige que los datos descomprimidos sean idénticos.
Por defecto **no modifica nada**: hay que pasar `--aplicar`. Si no hay
ganancia, no escribe. Tras aplicarlo se ejecutó `godot --headless --import`.

### 3. Resultado medido

| Archivo | Antes (bytes) | Después (bytes) | Ganancia |
|---|---:|---:|---:|
| `art/loading/protagonist_gamberra.png` | 2.614.533 | 2.506.518 | 108.015 |
| `art/loading/carga_con_npcs.png` | 2.560.532 | 2.505.072 | 55.460 |
| **Total** | 5.175.065 | 5.011.590 | **163.475** |

El hash MD5 de los píxeles, calculado con `ffmpeg -f hash -hash md5 -f
rawvideo`, es idéntico antes y después en los dos archivos:
`a3ea5cca848e0a89cf35b2bb15943a7f` y `cc381fb968a03755c23d2be85a0d3c32`.

El total de `art/` pasa de 40.500.406 a 40.336.931 bytes (−0,40 %); el de
los PNG, de 12.246.029 a 12.082.554 bytes (−1,33 %). Los `.import` no
cambiaron: `uid`, `path` y parámetros de importación siguen intactos.

**Tiempo de importación: no medido.** No se tomó una línea base antes de
comprimir, así que no se afirma mejora de tiempo de carga ni de FPS.

### 4. Hallazgos de la auditoría

- 435 SVG (27.641.588 bytes), 31 PNG, 467 `.import`, 1 TTF, 2 MD y 1 TXT.
- 31/31 PNG íntegros; ningún PNG duplicado por SHA256.
- Dos pares de SVG idénticos: `pierna_d.svg` y `pierna_i.svg` de
  `don_ramon_e` y de `jubilado_hierro_e`. Son piezas de un rig que comparten
  dibujo; no se han tocado porque eliminarlas exigiría cambiar el código.
- `art/shared/progenitores/ORIGEN.md` registra **75 de 75** SVG de esa
  carpeta, sin entradas sobrantes. El resto del árbol de arte no tiene un
  registro de origen equivalente; queda como deuda documental, no se crea
  en esta fase.
- Candidatos sin referencia literal: `art/loading/protagonist_gamberra.png`,
  `art/shared/progenitores/contestador_e.svg` y
  `art/shared/progenitores/contestador_n.svg`. La pantalla de carga usa
  solo `carga_con_npcs.png` (`ui/loading_screen.gd:39`), pero el director
  decidió **conservar** el PNG. Los dos SVG probablemente se cargan por
  ruta dinámica y siguen sin tocarse.

La reorganización por carpetas del punto (a) del pendiente del 14-nov
sigue abierta: mover rutas queda fuera del alcance aprobado.

### 5. Verificación ejecutada

- `python -m unittest discover -s tools/tests -q`: 76 pruebas, 0 fallos
  (1 omitida), incluidas 8 nuevas de auditoría y 3 de recompresión.
- `godot --headless --path . --import`: sin errores de script; los `.import`
  quedan sin cambios.
- `tests/art`: 51/51 (`report_63`, JUnit validado).
- `tests/ui`: 37/37 (`report_62`, JUnit validado).
- `python tools/verificar.py`: OK (incluye 314 literales `res://` y 900
  conversaciones).
- `python tools/formatear.py --comprobar`: 0 errores, 78 avisos
  preexistentes.

### 6. No ejecutado

Suite completa `res://tests`, medición en gráfica real, exportación del
`.exe` de esta rama, borrado de huérfanos y reorganización de carpetas.
