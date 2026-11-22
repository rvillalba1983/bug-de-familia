#!/usr/bin/env python3
"""Borra los `.log` de `reports/` con más de 48 horas sin escritura.

  python tools/limpiar_logs.py

Lo llama `tools/verificar.py` antes del resto de comprobaciones, así que la
limpieza ocurre al verificar o al commitear sin ningún paso manual. En CI no
hay `reports/`: no hace nada y devuelve 0.

La edad se mide desde la última modificación: un log que sigue escribiéndose
no se borra aunque se creara hace días. Solo toca archivos `.log` directos de
`reports/`; no recorre subdirectorios ni toca informes HTML/XML ni `humo.log`.

Opciones: `--directorio`, `--horas` (48 por defecto) y `--dry-run`.

Solo stdlib, sin dependencias y sin llamadas a servicios externos.
"""
from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
DIRECTORIO = RAIZ / "reports"
HORAS = 48


def limpiar(
	directorio: Path,
	ahora: float | None = None,
	horas: int = HORAS,
	seco: bool = False,
) -> tuple[int, int, list[str]]:
	"""Borra los `.log` antiguos y devuelve (borrados, recientes, errores)."""
	instante = time.time() if ahora is None else ahora
	limite = horas * 3600
	borrados = 0
	recientes = 0
	errores: list[str] = []
	try:
		nombre = directorio.relative_to(RAIZ).as_posix()
	except ValueError:
		nombre = str(directorio)
	if not directorio.is_dir():
		print(f"[OMITIDO] No existe {nombre}; no hay logs que limpiar")
		return (0, 0, errores)
	for ruta in sorted(directorio.glob("*.log")):
		if ruta.is_symlink() or not ruta.is_file():
			continue
		try:
			antiguedad = instante - ruta.stat().st_mtime
		except OSError as error:
			errores.append(f"{ruta.name}: no se pudo leer la fecha ({error})")
			continue
		if antiguedad <= limite:
			recientes += 1
			continue
		if seco:
			print(f"[SIMULADO] {nombre}/{ruta.name} ({antiguedad / 3600:.1f} h)")
		else:
			try:
				ruta.unlink()
			except OSError as error:
				errores.append(f"{ruta.name}: no se pudo borrar ({error})")
				continue
			print(f"[BORRADO] {nombre}/{ruta.name} ({antiguedad / 3600:.1f} h)")
		borrados += 1
	print(f"Limpieza de logs: {borrados} borrados, {recientes} recientes, "
		  f"{len(errores)} errores (umbral {horas} h)")
	for error in errores:
		print(f"[ERROR] {error}")
	return (borrados, recientes, errores)


def main() -> int:
	analizador = argparse.ArgumentParser(
		description="Borra los .log de reports/ con más de 48 horas.")
	analizador.add_argument("--directorio", type=Path, default=DIRECTORIO)
	analizador.add_argument("--horas", type=int, default=HORAS)
	analizador.add_argument("--dry-run", action="store_true")
	args = analizador.parse_args()
	if args.horas <= 0:
		analizador.error("--horas debe ser positivo")
	_, _, errores = limpiar(args.directorio, horas=args.horas, seco=args.dry_run)
	return 1 if errores else 0


if __name__ == "__main__":
	sys.exit(main())
