# Bug de Familia: índice de documentación

Paquete unificado creado el 8 de noviembre de 2026. Cada tema vive en un solo sitio.

## Empieza aquí
| Archivo | Contenido |
|---|---|
| `CLAUDE.md` | Instrucciones permanentes para Claude Code |
| `02_DECISIONES.md` | Lo que está decidido. Manda sobre todo lo demás |
| `01_CONFLICTOS_Y_PENDIENTES.md` | Lo que está sin resolver o falta |
| `03_ESTADO.md` | Por dónde va el desarrollo y cómo preparar el entorno |
| `40_plan_desarrollo.md` | Orden de trabajo y criterios de aceptación |
| `controles.md` | Controles del juego |

## Qué leer según la tarea
| Tarea | Documentos |
|---|---|
| Cámara, movimiento, sigilo, combate | `14`, `30`, `35` |
| Cuerpo y piezas | `11`, `30`, `35` |
| Conversión | `12`, `11`, `13` |
| IAs | `13`, `19`, `33` |
| Investigación y conversaciones | `17`, `19`, `33`, `32` |
| Encuentros, misiones y beta | `18`, `41`, `16` |
| Zonas y mundo | `15`, `34`, `30` |
| Simulación y personajes | `21`, `31`, `32`, `33` |
| Gráficos y animación | `36`, `11`, `42` |
| Audio | `37` |
| Textos, lore y preguntas | `10`, `16`, `50`, `51` |

## Diseño
| Archivo | Contenido |
|---|---|
| `10_vision.md` | Identidad, pilares y tono |
| `11_protagonista.md` | Anatomía, piezas y supervivencia |
| `12_conversion.md` | Convertir objetos en piezas |
| `12b_catalogo_conversion.md` | Las 50 propiedades y 100 acciones aprobadas |
| `13_ias.md` | Las 20 IAs, tokens y familia |
| `14_sigilo_combate_peligros.md` | Núcleo de juego |
| `15_mundo_tiempo.md` | Zonas, calendario, población y simulación |
| `16_razas_facciones.md` | Las seis razas |
| `17_investigacion.md` | Conocimiento e investigación |
| `18_encuentros_misiones_progenitores.md` | Encuentros y misiones |
| `19_dialogo_interfaz.md` | Conversación e interfaz |
| `21_autonomia_memoria_muerte.md` | Vida de los personajes |
| `41_beta.md` | Alcance de la beta |
| `42_pulido_visual_interfaz.md` | Fase de pulido visual e interfaz |
| `50_lore.md` | Historia de las seis especies |
| `51_situaciones.md` | Situaciones que genera el mundo |

## Técnica y producción
| Archivo | Contenido |
|---|---|
| `30_arquitectura.md` | Sistemas, datos y pruebas |
| `31_sistemas_comportamiento.md` | Diez sistemas de percepción, conducta y simulación |
| `32_dependencias.md` | Relaciones entre sistemas |
| `33_motor_conversaciones.md` | Motor social offline |
| `34_zonas_y_contenido.md` | Zonas fijas, contenido variable y persistencia |
| `35_normas_codigo.md` | Normas de GDScript, calidad y dependencias |
| `36_pipeline_graficos.md` | Producción gráfica |
| `37_audio.md` | Música y voces |

## Herramientas
Los scripts de medición y captura viven en `tools/`. Para medir el rendimiento en la gráfica real del director con Windows: `tools/medir_windows/MEDIR.bat`. Capturas de partida: `tools/capture_helper.gd` y `tools/captura_partida.gd`. Qué herramienta se usa en cada fase: `03_ESTADO.md`.

Comprobaciones deterministas, de más baratas a más caras (todas locales, sin servicios externos):

| Comando | Qué comprueba |
|---|---|
| `python tools/verificar.py` | Punto de entrada único: datos + normas de formato + medición si existe `medicion.txt` |
| `python tools/validar_datos.py` | 46 comprobaciones de `data/`; `--actualizar` y `--estricto` |
| `python tools/formatear.py --comprobar` | UTF-8 sin BOM, LF y línea final de `docs/35_normas_codigo.md` |
| `python tools/comparar_medicion.py medicion.txt` | Regresiones de rendimiento contra `tools/medir_windows/referencia.txt` |

El comando `/verificar` de OpenCode lanza el primero. Los dos workflows de GitHub Actions (`.github/workflows/`) ejecutan las pruebas y exportan el `.exe`. Decisión completa: `adr/0019-herramientas-ci-y-mcp.md`.

## Referencias visuales
`referencias/hoja_diseno_protagonista.png`.
