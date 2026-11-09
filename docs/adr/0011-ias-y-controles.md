# ADR 0011: las 20 IAs, espectros y controles (fase 9)

Estado: pendiente de aprobación del director.

## Hecho
- `data/ai/personalities.json`: 20 IAs y 14 parejas de la familia. Textos de Claude, sin servicios externos, pendientes de crítica (P-09).
- `ai/ai_perks.gd`: ventajas de las IAs. `ui/ai_spectres.gd`: espectros de la pausa táctica, con azar propio y sin gastar tokens.
- `ui/controls_panel.gd` (F1) y `ui/controls_window.gd`, con datos en `data/ui/controls.json`.

## Valores provisionales (P-05)
Coste de tokens 0,5 por esfuerzo. Una IA agotada vuelve con 24 tokens, unas 6 piezas descartadas sobre ella. Siestaware gasta el 10 %. Bonificaciones en las constantes de `AiPerks`. Sin ajustar jugando.

## Limitaciones
- Narcisa 9 no tiene ventaja real: los disfraces aún no existen como acción.
- Lumi crea señuelos solo como ruido; los seguidores curiosos visibles no están hechos.
- Conspi-Ranoia y Ma-Ma-Matriz dan avisos solo en la zona beta.
- Una prueba cambió `tokens = 0.1` por `0.0`, porque Siestaware gasta menos de 0,1 y el bucle no acababa.
