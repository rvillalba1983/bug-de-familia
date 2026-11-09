class_name Motivation
extends RefCounted
## Elige la actividad por puntuación. No siempre gana lo sensato (rareza).

const FLEE_FEAR: float = 60.0
const WEIRD_CHANCE: float = 0.012


static func choose(sim: WorldSim, npc: NpcState, festival_today: bool) -> String:
	var scores: Dictionary = {
		"huir": npc.emotion("miedo") * (1.0 if npc.emotion("miedo") >= FLEE_FEAR else 0.2),
		"llorar": npc.emotion("tristeza") * 0.8,
		"cotillear": 0.0,
		"fiesta": 0.0,
		"trabajar": 30.0 + npc.trait_value("ambicion") * 0.1,
	}
	if sim.rumors.fresh_news(sim, npc) >= 0:
		scores["cotillear"] = 40.0 + npc.trait_value("sociabilidad") * 0.4
	if festival_today:
		scores["fiesta"] = 55.0 + npc.trait_value("sociabilidad") * 0.2
	if sim.rng.randf() < WEIRD_CHANCE * npc.trait_value("rareza") / 50.0:
		return "rarezas"
	var best: String = "trabajar"
	for key: String in scores:
		if float(scores[key]) > float(scores[best]):
			best = key
	return best
