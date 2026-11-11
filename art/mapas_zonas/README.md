# Mapas de zonas (SVG sin texto, importables en Godot)

Carpeta: `art/mapas_zonas/`. Un SVG por zona (680×520), sin elementos `<text>` para que Godot 4.7 los importe como texturas vectoriales. Los nombres y etiquetas de cada mapa están en esta lista; el SVG contiene solo la geometría (formas, colores, caminos, guardados).

Las zonas son cuadradas (caja envolvente); la forma real se talla con zonas bloqueadas (áreas oscuras). Los caminos sinuosos llevan al borde, donde se cambia de zona.

## 1. El Enchufe (`01_el_enchufe.svg`)
Nudo neutral. Infraestructura antigua (Central, Terminal, Nodo×2). Guardados: 4. Bordes: ↑ cumbre, ↓ taller, ← beta, → gran_mercado/lonja.

## 2. Bosque de las Ciudades Perdidas (`02_bosque_ciudades_perdidas.svg`)
Bosque + ciudad perdida. Centralita, Depósito, Cámara. Tierra de nadie con minas. Guardados: 4. Bordes: ↑ cumbre, ↓ desguace, ← enchufe, → asamblea.

## 3. Cumbre de los Pliegues (`03_cumbre_de_los_pliegues.svg`)
Montañas. Ciudad plegada (Archivo, Pliegue, Cámara, Resonancia, Lonja). Guardados: 4. Bordes: ↑ borde, ↓ archivo, ← enchufe, → valle.

## 4. Archivo de las Esquinas (`04_archivo_de_las_esquinas.svg`)
Archivo antiguo. Estanterías, Archivos, Documentos, Fichas. Taller de Jubilados (Mantenimiento). Guardados: 3. Bordes: ↑ borde, ↓ cámara, ← cumbre, → sendero.

## 5. Cámara de Resonancia (`05_camara_de_resonancia.svg`)
Cámara acústica central con túneles. Almacén y Depósito (Manada). Guardados: 3. Bordes: ↑ archivo, ↓ canon, ← borde, → borde.

## 6. Cañón del Eco (`06_canon_del_eco.svg`)
Cañón con paredes altas. 3 puntos de eco. Puestos de Grux. Guardados: 3. Bordes: ↑ cámara, ↓ instalación, ← borde, → borde.

## 7. Gran Mercado (`07_gran_mercado.svg`)
Mercado con 9 puestos. Plaza central. Almacenes de Manada (×4). Zona fúngica Mohócrata. Guardados: 4. Bordes: ↑ enchufe, ↓ colmena, ← lonja, → camino.

## 8. Lonja de los Dientes (`08_lonja_de_los_dientes.svg`)
Lonja con 15 puestos densos. Talleres Jubilados (×4). Guardados: 3. Bordes: ↑ gran_mercado, ↓ asamblea, ← borde, → borde.

## 9. Talleres de Abuela RAM (`09_talleres_de_abuela_ram.svg`)
4 talleres + máquinas (Máquina, Prensa, Torno). Zona fúngica Mohócrata. Guardados: 3. Bordes: ↑ enchufe, ↓ paso, ← borde, → desguace.

## 10. Desguace de las Nueve (`10_desguace_de_las_nueve.svg`)
Chatarra (×4), Almacenes Manada (×3), Restos (×3). Club de petanca secreto (dashed). Guardados: 3. Bordes: ↑ beta, ↓ borde, ← taller, → asamblea.

## 11. Asamblea de las Esporas (`11_asamblea_de_las_esporas.svg`)
Asamblea central (elipse). 4 zonas fúngicas Mohócrata. Archivo y Pliegue (Plegados). Guardados: 4. Bordes: ↑ lonja, ↓ atajo, ← desguace, → colmena.

## 12. Atajo de las Esporas (`12_atajo_de_las_esporas.svg`)
Pasadizo estrecho (zigzag). 3 zonas fúngicas. Almacén y Depósito (Manada). Guardados: 3. Bordes: ↑ asamblea, ↓ colmena, ← borde, → borde.

## 13. Colmena Fúngica (`13_colmena_fungica.svg`)
Red micelial (elipse con 7 nodos). Nodo central. Túneles (Ecos ×2). Guardados: 3. Bordes: ↑ atajo, ↓ encrucijada, ← borde, → gran_mercado.

## 14. La Última Ruta (`14_la_ultima_ruta.svg`)
Ruta principal alargada. 5 almacenes (Manada). 5 puestos (Grux). Guardados: 4. Bordes: ↑ beta, ↓ instalación, ← borde, → polígono.

## 15. Polígono de Reparto (`15_poligono_de_reparto.svg`)
4 almacenes Manada + 3 talleres Jubilados. Guardados: 4. Bordes: ↑ última_ruta, ↓ borde, ← camino, → borde.

## 16. Camino de los Dientes (`16_camino_de_los_dientes.svg`)
Camino zigzag. 4 puestos (Grux). 3 archivos (Plegados). Guardados: 4. Bordes: ↑ gran_mercado, ↓ borde, ← borde, → borde.

## 17. La Instalación Anterior (`17_la_instalacion_anterior.svg`)
Ruinas (×4). Centro vacío (el botón que no existe). 4 trampas. Guardados: 2. Bordes: ↑ canon, ↓ antecámara, ← borde, → borde.

## 18. La Antecámara (`18_la_antecamara.svg`)
Ruinas (×3). Archivo y Pliegue (Plegados). Túnel y Eco (Ecos). Guardados: 3. Bordes: ↑ instalación, ↓ borde, ← borde, → encrucijada.

## 19. La Encrucijada (`19_la_encrucijada.svg`)
Forma de cruz. 4 especies en las esquinas (Plegados, Ecos, Grux, Jubilados). Guardados: 3. Bordes: ↑ colmena, ↓ gran_cruce, ← antecámara, → valle.

## 20. Valle de las Esquinas (`20_valle_de_las_esquinas.svg`)
Valle zigzag. Montañas (×4). 3 archivos (Plegados). 2 túneles (Ecos). 3 puestos (Grux). Guardados: 3. Bordes: ↑ cumbre, ↓ gran_cruce, ← encrucijada, → borde.

## 21. Sendero del Pliegue (`21_sendero_del_pliegue.svg`)
Sendero estrecho (zigzag). 3 archivos (Plegados). 3 almacenes (Manada). Montañas (×2). Guardados: 3. Bordes: ↑ archivo, ↓ borde, ← borde, → borde.

## 22. Paso de las Nueve (`22_paso_de_las_nueve.svg`)
Paso zigzag. 3 talleres (Jubilados). Zona fúngica Mohócrata (×3). Guardados: 3. Bordes: ↑ taller, ↓ borde, ← borde, → borde.

## 23. El Gran Cruce (`23_el_gran_cruce.svg`)
Forma de cruz. 4 especies en las esquinas. Guardados: 3. Bordes: ↑ encrucijada, ↓ borde, ← paso, → cementerio.

## 24. Cementerio de Robots (`24_cementerio_de_robots.svg`)
Cementerio (9 tumbas). Puestos (Grux ×3). Almacenes (Manada ×3). Talleres (Jubilados ×2). Guardados: 3. Bordes: ↑ valle, ↓ borde, ← gran_cruce, → borde.

---

**Nota sobre el flujo de trabajo:** los SVGs son **mapas de diseño** (blueprints). En Godot, el juego real se construye con nodos separados (suelo, paredes, props, fachadas, vegetación) como hace la beta (`scenes/beta/beta_layout.gd`, `beta_facades.gd`, `beta_ground.gd`). Los SVGs muestran la distribución y sirven de referencia para el level designer; Godot añade los elementos renderizados después. Si se quieren importar en Godot como texturas, los SVGs ya están sin texto y son compatibles con el importador de Godot 4.7.

**Origen:** creados por el director con otra IA (Claude), estilo rupestre/jeroglífico, a partir de los grandes sucesos y zonas del lore. Registrado el 12-nov-2026 en `docs/36_pipeline_graficos.md`. El director ha autorizado abrir el abanico de generadores de imagen para ilustraciones de lore y pantallas intermedias (el juego jugable sigue con Godot + SVG).
