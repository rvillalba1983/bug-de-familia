#!/usr/bin/env python3
"""Normaliza y comprueba el formato de texto del proyecto.

Normas de docs/35_normas_codigo.md (3.1): UTF-8 sin BOM, finales de linea LF
y una unica linea final. Esas tres se corrigen. El resto (tabuladores, lineas
de menos de 100 caracteres, espacios al final) solo se AVISA: reescribir la
indentacion automaticamente podria romper cadenas multilinea de GDScript.

Uso:
  python tools/formatear.py <archivo>              # lo usa el formatter de OpenCode
  python tools/formatear.py --comprobar            # recorre el repo, no modifica
  python tools/formatear.py --comprobar --resumen  # solo errores y totales

Solo stdlib, sin dependencias y sin llamadas a servicios externos.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
BOM = b"\xef\xbb\xbf"
# .bat y .cmd se excluyen: los scripts por lotes de Windows usan CRLF a proposito
# (.gitattributes fuerza eol=crlf en *.cmd) y no son codigo del juego.
EXTENSIONES = {
	".gd", ".py", ".json", ".jsonc", ".yml", ".yaml", ".csv", ".cfg",
	".tscn", ".tres", ".md", ".txt", ".gdshader", ".sh",
}
EXCLUIR = {
	".git", ".godot", "addons", "art", "audio", "build", "export", "reports",
}
AVISAR_ESPACIOS = {
	".gd", ".py", ".json", ".jsonc", ".yml", ".yaml", ".csv", ".cfg",
	".tscn", ".tres", ".gdshader",
}
AVISAR_LARGO = {".gd", ".py"}
LIMITE = 100


def analizar(ruta: Path, aplicar: bool) -> tuple[list[str], list[str]]:
	"""Devuelve (infracciones corregibles, avisos) y reescribe si aplicar."""
	crudo = ruta.read_bytes()
	infracciones: list[str] = []
	if crudo.startswith(BOM):
		crudo = crudo[len(BOM):]
		infracciones.append("BOM UTF-8")
	texto = crudo.decode("utf-8")
	if "\r" in texto:
		infracciones.append("finales de linea que no son LF")
		texto = texto.replace("\r\n", "\n").replace("\r", "\n")
	if texto and not texto.endswith("\n"):
		infracciones.append("falta la linea final")
		texto += "\n"
	elif texto.endswith("\n\n"):
		infracciones.append("lineas finales de mas")
		texto = texto.rstrip("\n") + "\n"

	avisos: list[str] = []
	sufijo = ruta.suffix.lower()
	for numero, linea in enumerate(texto.split("\n"), 1):
		if sufijo in AVISAR_ESPACIOS and linea.strip() and linea != linea.rstrip(" \t"):
			avisos.append(f"linea {numero}: espacios al final")
		if sufijo in AVISAR_LARGO and len(linea) > LIMITE:
			avisos.append(f"linea {numero}: {len(linea)} caracteres (limite {LIMITE})")
		if sufijo == ".gd" and linea.startswith("    ") and linea.strip():
			avisos.append(f"linea {numero}: indentacion con espacios")

	if aplicar and infracciones:
		ruta.write_bytes(texto.encode("utf-8"))
	return infracciones, avisos


def formatear_uno(ruta: Path) -> int:
	"""Modo formatter: normaliza un archivo y avisa de lo que no se corrige."""
	try:
		infracciones, avisos = analizar(ruta, aplicar=True)
	except (UnicodeDecodeError, OSError) as error:
		print(f"ERROR {ruta}: {error}", file=sys.stderr)
		return 1
	for detalle in infracciones:
		print(f"CORREGIDO {ruta.name}: {detalle}", file=sys.stderr)
	for detalle in avisos[:3]:
		print(f"AVISO {ruta.name}: {detalle}", file=sys.stderr)
	if len(avisos) > 3:
		print(f"AVISO {ruta.name}: y {len(avisos) - 3} mas", file=sys.stderr)
	return 0


def recorrer() -> list[Path]:
	"""Archivos de texto del repo, sin depender de git (no esta en este PATH)."""
	archivos: list[Path] = []
	for directorio, subdirs, nombres in os.walk(RAIZ):
		# .github se revisa: los workflows tambien deben cumplir las normas.
		subdirs[:] = [d for d in subdirs
					  if d not in EXCLUIR and (not d.startswith(".") or d == ".github")]
		for nombre in nombres:
			ruta = Path(directorio) / nombre
			if ruta.suffix.lower() in EXTENSIONES:
				archivos.append(ruta)
	return sorted(archivos)


def comprobar(resumen: bool) -> int:
	"""Modo comprobacion: no modifica nada; falla solo por infracciones."""
	archivos = recorrer()
	con_error = 0
	con_aviso = 0
	for ruta in archivos:
		relativo = ruta.relative_to(RAIZ).as_posix()
		try:
			infracciones, avisos = analizar(ruta, aplicar=False)
		except (UnicodeDecodeError, OSError) as error:
			print(f"ERROR {relativo}: {error}")
			con_error += 1
			continue
		if infracciones:
			print(f"ERROR {relativo}: {'; '.join(infracciones)}")
			con_error += 1
		if avisos:
			con_aviso += 1
			if not resumen:
				print(f"AVISO {relativo}: {len(avisos)} lineas fuera de norma "
					  f"(ejemplo: {avisos[0]})")
	print(f"OK: {len(archivos)} archivos revisados, 0 errores, "
		  f"{con_aviso} con avisos" if con_error == 0
		  else f"FALLO: {con_error} archivos con errores, {con_aviso} con avisos")
	return 0 if con_error == 0 else 1


def main() -> int:
	argumentos = sys.argv[1:]
	if argumentos[:1] == ["--comprobar"]:
		return comprobar(resumen="--resumen" in argumentos[1:])
	if len(argumentos) == 1 and not argumentos[0].startswith("-"):
		return formatear_uno(Path(argumentos[0]))
	print("Uso: formatear.py <archivo> | --comprobar [--resumen]", file=sys.stderr)
	return 2


if __name__ == "__main__":
	sys.exit(main())
