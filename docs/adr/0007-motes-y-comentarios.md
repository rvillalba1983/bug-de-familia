# ADR 0007: motes y comentarios del protagonista

**Decisión.** Los textos aprobados de P-09 viven en datos: `data/ai/nicknames.json` (motes de las 20 IAs y de los progenitores de la beta) y `data/protagonist/comments.json` (comentarios por suceso). Origen: escritos por Claude y aprobados por el director el 9-nov-2026 (`docs/borradores/P-09_lote_1.md` y `P-09_lote_2.md`).

**Motes.** La marca `{mote}` en una frase de IA o de progenitor se sustituye al decirla (`Nicknames`). Además, las frases de peligro, pelea, pieza perdida, acierto, fallo y conversión reciben a veces el mote delante.

**Comentarios.** `ProtagonistVoice` existe solo en la zona de la beta. Usa señales cuando las hay y revisa una vez por segundo lo demás (marcas de la investigación, cercanía y desgaste). Comparte el bocadillo y la cola de las IAs, pasa delante de ellas y no gasta tokens. Lo que ya había ocurrido al cargar una partida no se comenta.

**Valores provisionales**, a ajustar al probar: 30 % de frases con mote delante; 25 s mínimos entre comentarios y de 45 s a 10 min por tipo de comentario, salvo los de historia; parado 30 s; comentario sobre las IAs cada 5 min; 25 % al responder una conversión; 20 % al entrar en pausa táctica; 340 píxeles para comentar lo que se ve.

**Pendiente.** Los comentarios `cupido_in_love` y `fast_travel` están escritos, pero esperan a Cupido_Beta y al viaje entre puntos de guardado. Los motes de las 14 IAs aún no jugables se activarán al implementarlas.
