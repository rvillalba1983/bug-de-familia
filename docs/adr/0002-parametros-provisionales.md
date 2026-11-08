# ADR 0002: parámetros provisionales de sigilo y cuerpo

Fecha: 2026-11-08 · Estado: provisional, a ajustar al probar

## Decisión
Valores usados hasta que el director los ajuste. Están en constantes marcadas como provisionales.

| Parámetro | Valor |
|---|---|
| Velocidad: andar / correr / agachado | 180 / 320 / 110 px/s |
| Radio del ruido al correr | 340 px, cada 0,4 s |
| Ruido de romper una caja | 640 px; las paredes lo reducen a la mitad |
| Guardia: patrulla / investigar / perseguir | 110 / 150 / 240 px/s |
| Visión del guardia | 320 px, ±35° |
| Visión del dron | 200 px, ±40°; ve por encima de las coberturas |
| Visión de la cámara | 380 px, ±18°, barrido de ±35° |
| Alcance agachado | 70 % del normal |
| Tiempo en detectar | 0,6 s de cerca, 1,6 s al límite |
| Daño de un golpe | 34 sobre 100 |
| Probabilidad de golpe en la cabeza | peso 1 frente a 4 de cada extremidad |
| Fin de pelea | 3 s sin alerta |

## Decisiones técnicas
- Una cámara o un dron dan la alarma y el guardia investiga; la pelea solo empieza si el propio guardia detecta al jugador.
- Si se cierra la selección con la cabeza vacía, se pone el primer repuesto.
- Un archivo de guardado dañado se aparta como `.danada` y empieza una partida nueva, hasta decidir la política definitiva (P-17).
