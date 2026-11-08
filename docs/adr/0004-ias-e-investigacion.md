# ADR 0004: primeras IAs y caso investigable

Fecha: 2026-11-08 · Estado: provisional, a ajustar al probar

## IAs
- Seis jugables: Pánico.exe, Dr. Desprecio, Mamá Ansiosa, Troll-o-Matic, Abuela RAM y El Árbitro. Datos y frases en `data/ai/personalities.json`.
- Tres activas al azar; capacidad de 100 tokens; hablar cuesta 1,5 por punto de esfuerzo.
- Descartar una pieza da 4 tokens a la IA dormida con menos (recarga mínima).
- Fallar las dos preguntas de una conversión es un enfado grave: la IA calla 20 s. Al llegar a su tolerancia se pierde para siempre. La pelea física contra una IA queda para más adelante.
- Ventajas: Pánico avisa de enemigos, a veces en falso; Dr. Desprecio alarga los aturdimientos; Mamá avisa de piezas gastadas; Abuela RAM descarta una opción falsa; Troll-o-Matic señala una respuesta falsa; El Árbitro anula a Troll.
- Voz sintetizada, sin archivos ni red.

## Investigación
- Caso de prueba en `data/investigation/case_01.json`: la desaparición de Manolo Cojinete. Personajes y textos provisionales, pendientes de revisión del director.
- Salidas: paz (deducción con pruebas), tregua (negociación), guerra (mentira o no intervenir en 5 minutos).
- El estado interno no se muestra: no hay diario.
- Este motor de opciones con condiciones sirve para el prototipo; el motor social completo se integra en la fase 8.
- Las conversaciones detienen el tiempo.
