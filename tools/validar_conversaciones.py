#!/usr/bin/env python3
"""Valida las conversaciones de P-42 en data/conversation/live_<especie>.json.

Comprueba, sin Godot:

- Que exista un catálogo por cada especie de data/world/species.json.
- Que cada especie tenga al menos MINIMO conversaciones.
- Que los identificadores no se repitan y que ninguna conversación repita la
  frase de apertura de otra (ni dentro de la especie ni entre especies): dos
  habitantes de la misma zona no deben contar lo mismo.
- Que todos los nodos tengan texto, todas las opciones tengan etiqueta y que
  cada `next` apunte a un nodo existente (o a "" para volver al menú).
- Que solo se usen las acciones que entiende simulation/live_dialogue.gd.
- Que existan conversaciones de regalo de pieza, de pelea con el protagonista
  y de pelea entre razas, y cadenas largas de preguntas.

Uso:
	python tools/validar_conversaciones.py
	python tools/validar_conversaciones.py --raiz <directorio>
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

SPECIES_JSON = "data/world/species.json"
CONVERSACIONES = "data/conversation"
MINIMO = 150
MINIMO_ACCIONES = 10
MINIMO_CADENAS_LARGAS = 15
CADENA_LARGA = 5
LARGO_MAXIMO = 160
ACCIONES = {"", "gift_piece", "hit", "provoke_battle", "praise", "insult"}


def especies(raiz: Path, fallos: list[str]) -> list[str]:
	"""Especies del juego, en el orden de data/world/species.json."""
	ruta = raiz / SPECIES_JSON
	if not ruta.exists():
		fallos.append(f"{SPECIES_JSON}: no existe")
		return []
	try:
		datos = json.loads(ruta.read_text(encoding="utf-8"))
	except json.JSONDecodeError as error:
		fallos.append(f"{SPECIES_JSON}: JSON inválido: {error}")
		return []
	return list(datos)


def validar_conversacion(ruta: str, conv: dict, fallos: list[str]) -> dict:
	"""Valida una conversación y devuelve sus acciones y su número de nodos."""
	ident = str(conv.get("id", "?"))
	nodos = conv.get("nodes")
	acciones: dict[str, int] = {}
	if not isinstance(nodos, dict) or not nodos:
		fallos.append(f"{ruta}: {ident}: sin nodos")
		return {"acciones": acciones, "nodos": 0}
	if "root" not in nodos:
		fallos.append(f"{ruta}: {ident}: falta el nodo «root»")
		return {"acciones": acciones, "nodos": len(nodos)}
	for clave, nodo in nodos.items():
		if not isinstance(nodo, dict):
			fallos.append(f"{ruta}: {ident}:{clave}: el nodo no es un objeto")
			continue
		texto = nodo.get("text")
		if not isinstance(texto, str) or not texto.strip():
			fallos.append(f"{ruta}: {ident}:{clave}: texto vacío")
		elif len(texto) > LARGO_MAXIMO:
			fallos.append(
				f"{ruta}: {ident}:{clave}: {len(texto)} caracteres (máximo {LARGO_MAXIMO})")
		opciones = nodo.get("options")
		if not isinstance(opciones, list) or not opciones:
			fallos.append(f"{ruta}: {ident}:{clave}: sin opciones")
			continue
		for opcion in opciones:
			if not isinstance(opcion, dict):
				fallos.append(f"{ruta}: {ident}:{clave}: opción mal formada")
				continue
			etiqueta = opcion.get("label")
			if not isinstance(etiqueta, str) or not etiqueta.strip():
				fallos.append(f"{ruta}: {ident}:{clave}: opción sin etiqueta")
			siguiente = opcion.get("next", "")
			if not isinstance(siguiente, str):
				fallos.append(f"{ruta}: {ident}:{clave}: next no es texto")
			elif siguiente and siguiente not in nodos:
				fallos.append(f"{ruta}: {ident}:{clave}: next «{siguiente}» no existe")
			accion = opcion.get("action", "")
			if accion not in ACCIONES:
				fallos.append(f"{ruta}: {ident}:{clave}: acción desconocida «{accion}»")
			elif accion:
				acciones[accion] = acciones.get(accion, 0) + 1
	revisar_alcanzables(ruta, ident, nodos, fallos)
	return {"acciones": acciones, "nodos": len(nodos)}


def revisar_alcanzables(ruta: str, ident: str, nodos: dict, fallos: list[str]) -> None:
	"""Todo nodo debe poder alcanzarse desde root; si no, es contenido muerto."""
	vistos: set[str] = set()
	pendientes: list[str] = ["root"]
	while pendientes:
		clave = pendientes.pop()
		if clave in vistos or clave not in nodos:
			continue
		vistos.add(clave)
		for opcion in nodos[clave].get("options", []):
			siguiente = opcion.get("next", "")
			if siguiente and siguiente not in vistos:
				pendientes.append(siguiente)
	huerfanos = sorted(set(nodos) - vistos)
	if huerfanos:
		fallos.append(f"{ruta}: {ident}: nodos inalcanzables: {', '.join(huerfanos)}")


def comprobar(raiz: Path) -> tuple[int, list[str], list[str]]:
	"""Valida todos los catálogos. Devuelve (conversaciones, avisos, fallos)."""
	fallos: list[str] = []
	avisos: list[str] = []
	total = 0
	aperturas: dict[str, str] = {}
	for especie in especies(raiz, fallos):
		ruta_rel = f"{CONVERSACIONES}/live_{especie}.json"
		ruta = raiz / ruta_rel
		if not ruta.exists():
			fallos.append(f"{ruta_rel}: no existe")
			continue
		try:
			datos = json.loads(ruta.read_text(encoding="utf-8"))
		except json.JSONDecodeError as error:
			fallos.append(f"{ruta_rel}: JSON inválido: {error}")
			continue
		if datos.get("species") != especie:
			fallos.append(f"{ruta_rel}: species «{datos.get('species')}» no es «{especie}»")
		conversaciones = datos.get("conversations")
		if not isinstance(conversaciones, list):
			fallos.append(f"{ruta_rel}: falta la lista conversations")
			continue
		if len(conversaciones) < MINIMO:
			fallos.append(
				f"{ruta_rel}: {len(conversaciones)} conversaciones (mínimo {MINIMO})")
		total += len(conversaciones)
		identificadores: set[str] = set()
		acciones: dict[str, int] = {}
		largas = 0
		for conv in conversaciones:
			if not isinstance(conv, dict):
				fallos.append(f"{ruta_rel}: hay una conversación que no es un objeto")
				continue
			ident = str(conv.get("id", ""))
			if not ident:
				fallos.append(f"{ruta_rel}: conversación sin id")
			elif ident in identificadores:
				fallos.append(f"{ruta_rel}: id repetido «{ident}»")
			identificadores.add(ident)
			nodos = conv.get("nodes")
			if isinstance(nodos, dict) and isinstance(nodos.get("root"), dict):
				apertura = str(nodos["root"].get("text", "")).strip()
				if apertura in aperturas:
					fallos.append(
						f"{ruta_rel}: {ident}: repite la apertura de {aperturas[apertura]}")
				else:
					aperturas[apertura] = ident
			resultado = validar_conversacion(ruta_rel, conv, fallos)
			if resultado["nodos"] >= CADENA_LARGA:
				largas += 1
			for accion, cuenta in resultado["acciones"].items():
				acciones[accion] = acciones.get(accion, 0) + cuenta
		for accion in ("gift_piece", "hit", "provoke_battle"):
			if acciones.get(accion, 0) < MINIMO_ACCIONES:
				fallos.append(
					f"{ruta_rel}: solo {acciones.get(accion, 0)} conversaciones con «{accion}» "
					f"(mínimo {MINIMO_ACCIONES})")
		if largas < MINIMO_CADENAS_LARGAS:
			fallos.append(
				f"{ruta_rel}: solo {largas} cadenas de {CADENA_LARGA} o más nodos "
				f"(mínimo {MINIMO_CADENAS_LARGAS})")
		avisos.append(
			f"{especie}: {len(conversaciones)} conversaciones, "
			f"{acciones.get('gift_piece', 0)} regalos, {acciones.get('hit', 0)} peleas, "
			f"{acciones.get('provoke_battle', 0)} batallas entre razas, {largas} cadenas largas")
	return total, avisos, fallos


def main() -> int:
	parser = argparse.ArgumentParser(description=__doc__)
	parser.add_argument("--raiz", default=".", help="directorio del proyecto")
	args = parser.parse_args()
	total, avisos, fallos = comprobar(Path(args.raiz))
	for aviso in avisos:
		print(f"  {aviso}")
	for fallo in fallos:
		print(f"ERROR {fallo}")
	print(f"Conversaciones: {total}, fallos: {len(fallos)}")
	return 0 if not fallos else 1


if __name__ == "__main__":
	raise SystemExit(main())
