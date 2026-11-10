#!/usr/bin/env python3
"""Valida y rota los modelos de los agentes de OpenCode.

OpenCode V2 NO encadena modelos: cada agente tiene un unico `model` y una
peticion ya empezada conserva su modelo aunque cambie la configuracion. Por eso
la rotacion no es automatica: se ejecuta este script y se RELANZA la tarea.

  python tools/cambiar_modelo.py --estado
  python tools/cambiar_modelo.py --validar
  python tools/cambiar_modelo.py --rotar qa
  python tools/cambiar_modelo.py --usar qa opencode/big-pickle
  python tools/cambiar_modelo.py --restaurar qa

Edita solo la linea `"model":` del agente en opencode.jsonc, conservando el
resto del JSONC (comentarios, comas y cadenas del system). Solo stdlib.
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TABLA = RAIZ / "tools" / "modelos_agentes.json"
CONFIG = RAIZ / "opencode.jsonc"
FALLBACK = RAIZ / "FALLBACK_MODELS.md"
SIN_SYSTEM = {"por_defecto", "explore"}
MODELO = re.compile(r'^(\s*"model"\s*:\s*")([^"]+)(".*)$')
CLAVE_AGENTE = re.compile(r'^\s*"([a-z_-]+)"\s*:\s*\{\s*$')


def cargar_tabla() -> dict[str, list[str]]:
	datos = json.loads(TABLA.read_text(encoding="utf8"))
	return {nombre: info["cadena"] for nombre, info in datos["agentes"].items()}


def lineas_config() -> list[str]:
	return CONFIG.read_text(encoding="utf8").splitlines(keepends=True)


def localizar(lineas: list[str], agente: str) -> int:
	"""Indice de la linea `"model":` del agente, o -1."""
	if agente == "por_defecto":
		for i, linea in enumerate(lineas):
			if '"agents"' in linea:
				break
			if MODELO.match(linea):
				return i
		return -1
	inicio = -1
	for i, linea in enumerate(lineas):
		coincide = CLAVE_AGENTE.match(linea)
		if coincide and coincide.group(1) == agente:
			inicio = i
			break
	if inicio < 0:
		return -1
	for i in range(inicio + 1, min(inicio + 12, len(lineas))):
		if MODELO.match(lineas[i]):
			return i
	return -1


def activo(lineas: list[str], indice: int) -> str:
	coincide = MODELO.match(lineas[indice])
	return coincide.group(2) if coincide else ""


def escribir(lineas: list[str], indice: int, modelo: str) -> None:
	coincide = MODELO.match(lineas[indice])
	lineas[indice] = f"{coincide.group(1)}{modelo}{coincide.group(3)}\n"
	CONFIG.write_text("".join(lineas), encoding="utf8")


def fragmento_agente(texto: str, agente: str) -> str:
	"""Bloque del agente, para comprobar que su system cita los alternativos."""
	marca = f'"{agente}": {{'
	inicio = texto.find(marca)
	if inicio < 0:
		return ""
	fin = texto.find('\n    },', inicio)
	return texto[inicio:fin if fin > 0 else len(texto)]


def estado(tabla: dict[str, list[str]], lineas: list[str]) -> None:
	for agente, cadena in tabla.items():
		indice = localizar(lineas, agente)
		actual = activo(lineas, indice) if indice >= 0 else "NO ENCONTRADO"
		posicion = cadena.index(actual) if actual in cadena else -1
		etiqueta = "principal" if posicion == 0 else (
			f"alternativo {posicion}" if posicion > 0 else "FUERA DE CADENA")
		print(f"{agente:18s} {etiqueta:15s} {actual}")
		print(f"{'':18s} cadena: {' > '.join(cadena)}")


def validar(tabla: dict[str, list[str]], lineas: list[str]) -> int:
	errores = 0
	texto_config = "".join(lineas)
	texto_fallback = FALLBACK.read_text(encoding="utf8")
	for agente, cadena in tabla.items():
		if len(cadena) != 4 or len(set(cadena)) != 4:
			print(f"ERROR {agente}: la cadena debe tener 4 modelos distintos: {cadena}")
			errores += 1
			continue
		indice = localizar(lineas, agente)
		if indice < 0:
			print(f"ERROR {agente}: no se encuentra su linea model en opencode.jsonc")
			errores += 1
			continue
		actual = activo(lineas, indice)
		if actual not in cadena:
			print(f"ERROR {agente}: modelo activo '{actual}' fuera de su cadena")
			errores += 1
		for modelo in cadena:
			if modelo not in texto_fallback:
				print(f"ERROR {agente}: '{modelo}' no aparece en FALLBACK_MODELS.md")
				errores += 1
		if agente not in SIN_SYSTEM:
			bloque = fragmento_agente(texto_config, agente)
			for modelo in cadena[1:]:
				if modelo not in bloque:
					print(f"ERROR {agente}: alternativo '{modelo}' no esta en su system")
					errores += 1
	print(f"OK: {len(tabla)} agentes, 1 principal + 3 alternativos, 0 errores"
		  if errores == 0 else f"FALLO: {errores} errores")
	return 0 if errores == 0 else 1


def cambiar(tabla: dict[str, list[str]], lineas: list[str], agente: str,
			modelo: str, motivo: str) -> int:
	cadena = tabla.get(agente)
	if not cadena:
		print(f"ERROR: agente desconocido '{agente}'")
		return 2
	if modelo not in cadena:
		print(f"ERROR: '{modelo}' no esta en la cadena de {agente}: {cadena}")
		return 2
	indice = localizar(lineas, agente)
	if indice < 0:
		print(f"ERROR: no se encuentra la linea model de {agente}")
		return 2
	anterior = activo(lineas, indice)
	if anterior == modelo:
		print(f"SIN CAMBIO: {agente} ya usa {modelo}")
		return 0
	escribir(lineas, indice, modelo)
	print(f"ROTADO {agente}: {anterior} -> {modelo}")
	print(f"Motivo: {motivo}")
	print("OpenCode recarga la config solo. RELANZA la tarea: la peticion que")
	print("fallo no se reintenta con el modelo nuevo (documentacion V2).")
	print("Registra el cambio en un ADR y en FALLBACK_MODELS.md.")
	return 0


def main() -> int:
	parser = argparse.ArgumentParser(description=__doc__)
	grupo = parser.add_mutually_exclusive_group(required=True)
	grupo.add_argument("--estado", action="store_true")
	grupo.add_argument("--validar", action="store_true")
	grupo.add_argument("--rotar", metavar="AGENTE")
	grupo.add_argument("--usar", nargs=2, metavar=("AGENTE", "MODELO"))
	grupo.add_argument("--restaurar", metavar="AGENTE")
	parser.add_argument("--motivo", default="limite o retirada del modelo anterior")
	args = parser.parse_args()

	tabla = cargar_tabla()
	lineas = lineas_config()
	if args.estado:
		estado(tabla, lineas)
		return 0
	if args.validar:
		return validar(tabla, lineas)
	if args.rotar:
		cadena = tabla.get(args.rotar)
		if not cadena:
			print(f"ERROR: agente desconocido '{args.rotar}'")
			return 2
		indice = localizar(lineas, args.rotar)
		actual = activo(lineas, indice) if indice >= 0 else ""
		siguiente = cadena[(cadena.index(actual) + 1) % len(cadena)] if actual in cadena else cadena[0]
		return cambiar(tabla, lineas, args.rotar, siguiente, args.motivo)
	if args.usar:
		return cambiar(tabla, lineas, args.usar[0], args.usar[1], args.motivo)
	if args.restaurar:
		return cambiar(tabla, lineas, args.restaurar,
					   tabla[args.restaurar][0], "volver al modelo principal")
	return 2


if __name__ == "__main__":
	raise SystemExit(main())
