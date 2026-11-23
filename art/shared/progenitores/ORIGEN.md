# ORIGEN del arte de los 15 progenitores (P-58)

Arte definitivo generado el 23-nov-2026 para sustituir los 75 SVG
geométricos de `tools/art/progenitores_gen.py`. Cada entrada es un SVG de
256 × 280 con `viewBox="0 0 512 560"` y un PNG incrustado en base64.
Fondo transparente, sin texto, sin sombra de suelo.

## Procedencia común

- **Datos de lore**: `data/world/progenitors.json` (nombre, color, material,
  propiedad fija) y `data/conversation/progenitors.json` (muerte por caída).
- **Plantilla de prompt**: `tools/art/progenitores_prompts.py`.
- **Vistas base** (15): `openrouter/recraft/recraft-v4.1-flash-v2:free`
  (prompt de texto).
- **Vistas direccionales generadas con modelo** (17):
  `openrouter/microsoft/mai-image-2.7-flash` y
  `openrouter/bytedance-seed/seedream-5-5`, usando la vista base convertida
  a PNG como referencia.
- **Vistas direccionales derivadas** (43):
  `tools/art/progenitores_derivar_vistas.py`, que aplica escalado horizontal,
  espejo y ajuste de luminancia/tinte a la vista base. Decisión del director
  al agotarse los créditos de los modelos de imagen.
- **Postproceso**: `tools/art/progenitores_raster_a_svg.py` elimina el fondo
  blanco por relleno conectado al borde, recorta, escala a 512 × 560 con los
  pies en y=520 y guarda el SVG con el PNG incrustado. ffmpeg y Python 3.12
  con numpy y scipy. Ningún recurso de terceros ni material externo.
- **Estilo pedido**: cartoon grotesco de acabado pintado, anatomías
  extrañas, formas asimétricas, colores saturados, mezcla de atractivo y
  desagradable, humor visual, estética adulta. Cámara alta inclinada fija
  tipo Zelda. Paleta «Cuñado Radiactivo»: contornos #1B0E2A, sombras #6A2BA8.
- **Autor**: agente principal del proyecto, por encargo del director.
- **Servicios externos**: autorizados explícitamente en el encargo de P-58.
  La partida no llama a ningún servicio; todo va incluido en el SVG.

## Registro por imagen

| Archivo | Prompt (identificador + vista) | Modelo / herramienta | Referencia |
|---|---|---|---|
| `ramon.svg` | ramon / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `ramon_se.svg` | ramon / se | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `ramon_e.svg` | ramon / e | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `ramon_ne.svg` | ramon / ne | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `ramon_n.svg` | ramon / n | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `contestador.svg` | contestador / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `contestador_se.svg` | contestador / se | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `contestador_e.svg` | contestador / e | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `contestador_ne.svg` | contestador / ne | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `contestador_n.svg` | contestador / n | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `biela.svg` | biela / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `biela_se.svg` | biela / se | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `biela_e.svg` | biela / e | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `biela_ne.svg` | biela / ne | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `biela_n.svg` | biela / n | `openrouter/microsoft/mai-image-2.7-flash` | vista base del mismo progenitor |
| `pliegue_oculto.svg` | pliegue_oculto / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `pliegue_oculto_se.svg` | pliegue_oculto / se | `openrouter/bytedance-seed/seedream-5-5` | vista base del mismo progenitor |
| `pliegue_oculto_e.svg` | pliegue_oculto / e | `openrouter/bytedance-seed/seedream-5-5` | vista base del mismo progenitor |
| `pliegue_oculto_ne.svg` | pliegue_oculto / ne | `openrouter/bytedance-seed/seedream-5-5` | vista base del mismo progenitor |
| `pliegue_oculto_n.svg` | pliegue_oculto / n | `openrouter/bytedance-seed/seedream-5-5` | vista base del mismo progenitor |
| `papel_cebolla.svg` | papel_cebolla / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `papel_cebolla_se.svg` | papel_cebolla / se | `openrouter/bytedance-seed/seedream-5-5` | vista base del mismo progenitor |
| `papel_cebolla_e.svg` | papel_cebolla / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `papel_cebolla_ne.svg` | papel_cebolla / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `papel_cebolla_n.svg` | papel_cebolla / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `susurro.svg` | susurro / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `susurro_se.svg` | susurro / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `susurro_e.svg` | susurro / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `susurro_ne.svg` | susurro / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `susurro_n.svg` | susurro / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `frecuencia.svg` | frecuencia / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `frecuencia_se.svg` | frecuencia / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `frecuencia_e.svg` | frecuencia / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `frecuencia_ne.svg` | frecuencia / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `frecuencia_n.svg` | frecuencia / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `boletina.svg` | boletina / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `boletina_se.svg` | boletina / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `boletina_e.svg` | boletina / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `boletina_ne.svg` | boletina / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `boletina_n.svg` | boletina / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `yesquero.svg` | yesquero / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `yesquero_se.svg` | yesquero / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `yesquero_e.svg` | yesquero / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `yesquero_ne.svg` | yesquero / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `yesquero_n.svg` | yesquero / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `fiador.svg` | fiador / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `fiador_se.svg` | fiador / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `fiador_e.svg` | fiador / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `fiador_ne.svg` | fiador / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `fiador_n.svg` | fiador / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `garantia.svg` | garantia / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `garantia_se.svg` | garantia / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `garantia_e.svg` | garantia / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `garantia_ne.svg` | garantia / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `garantia_n.svg` | garantia / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `avalista.svg` | avalista / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `avalista_se.svg` | avalista / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `avalista_e.svg` | avalista / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `avalista_ne.svg` | avalista / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `avalista_n.svg` | avalista / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `cartero.svg` | cartero / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `cartero_se.svg` | cartero / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `cartero_e.svg` | cartero / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `cartero_ne.svg` | cartero / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `cartero_n.svg` | cartero / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `paquete.svg` | paquete / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `paquete_se.svg` | paquete / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `paquete_e.svg` | paquete / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `paquete_ne.svg` | paquete / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `paquete_n.svg` | paquete / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `ultimo_mono.svg` | ultimo_mono / base | `openrouter/recraft/recraft-v4.1-flash-v2:free` | — |
| `ultimo_mono_se.svg` | ultimo_mono / se | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `ultimo_mono_e.svg` | ultimo_mono / e | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `ultimo_mono_ne.svg` | ultimo_mono / ne | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |
| `ultimo_mono_n.svg` | ultimo_mono / n | `tools/art/progenitores_derivar_vistas.py` | vista base del mismo progenitor |

Los prompts literales están en la plantilla y se reconstruyen con:

```bash
python tools/art/progenitores_prompts.py --manifiesto manifiesto_p58.json
```

## Validación

- Importación de Godot 4.7.2 en modo headless sin errores.
- `tests/art/art_progenitores_test.gd`: 75 vistas, 256 × 280, transparencia,
  `viewBox`, incrustación PNG y ausencia de texto y del generador anterior.
- Revisión visual en partida: pendiente de aprobación del director.
