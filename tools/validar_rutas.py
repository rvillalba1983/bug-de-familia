#!/usr/bin/env python3
"""Comprueba que las rutas `res://` literales del proyecto existan.

Lee codigo y recursos operativos (GDScript, escenas, datos, workflows) y
verifica cada literal `res://...` contra el arbol de trabajo. Detecta en
segundos roturas como un renombrado de carpeta que deja escenas, pruebas o
datos apuntando al sitio viejo, sin descargar ni ejecutar Godot.

Esta comprobacion existe por el incidente del 13-nov (ADR 0028): el renombrado
beta -> despliegue_cero dejo `scenes/despliegue_cero/despliegue_cero_zone.tscn`
apuntando a un script que ya no existe y `simulation/zone_manager.gd` cargando
`res://scenes/beta/beta_zone.tscn`, y el juego no arrancaba.

No revisa rutas dinamicas (`%s`, formatos, concatenaciones), rutas que terminan
en `/` (se usan para crear o recorrer directorios), `user://` ni
`res://.godot/...` (solo existe tras importar).

Uso (desde la raiz del repo):

    python tools/validar_rutas.py
    python tools/validar_rutas.py --raiz <directorio>

Salida: una linea `ERROR <archivo>:<linea> ruta inexistente <ruta>` por fallo.
Codigo de salida 0 si todas las rutas existen, 1 si falta alguna.
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from collections.abc import Iterator
from pathlib import Path

RAIZ: Path = Path(__file__).resolve().parent.parent

EXTENSIONES: set[str] = {".gd", ".tscn", ".tres", ".cfg", ".godot", ".json",
                         ".yml", ".yaml"}
# Carpetas que no son fuentes operativas: binarios, arte, documentacion y
# salidas de herramientas. Se recorren los .github para vigilar los workflows.
EXCLUIR: set[str] = {".git", ".godot", "addons", "art", "audio", "build",
                     "docs", "export", "reports"}
# El prefijo obliga a que la ruta empiece en res://; el resto corta en el primer
# caracter que no puede formar parte de una ruta entre comillas o en un comentario.
PATRON = re.compile(r"res://[^\s\"'`()\[\],;#]+")
DINAMICAS: tuple[str, ...] = ("%", "{", "}", "$", "*", "?")


def archivos(raiz: Path) -> Iterator[Path]:
    """Recorre las fuentes operativas del proyecto, sin entrar en EXCLUIR."""
    for directorio, subdirs, nombres in os.walk(raiz):
        subdirs[:] = sorted(
            nombre for nombre in subdirs
            if nombre not in EXCLUIR
            and (not nombre.startswith(".") or nombre == ".github")
        )
        for nombre in sorted(nombres):
            ruta = Path(directorio) / nombre
            if ruta.suffix.lower() in EXTENSIONES:
                yield ruta


def es_dinamica(ruta: str) -> bool:
    """True si la ruta no se puede comprobar tal cual esta escrita."""
    if not ruta.startswith("res://") or ruta == "res://":
        return True
    if ruta.endswith("/"):
        return True
    if ruta.startswith("res://.godot"):
        return True
    return any(marca in ruta for marca in DINAMICAS)


def literales(texto: str) -> Iterator[tuple[int, str]]:
    """Devuelve (linea, ruta) de cada literal res:// comprobable."""
    for numero, linea in enumerate(texto.split("\n"), 1):
        for hallado in PATRON.finditer(linea):
            ruta = hallado.group(0).rstrip(".")
            if es_dinamica(ruta):
                continue
            yield numero, ruta


def comprobar(raiz: Path) -> tuple[int, int, list[str]]:
    """Devuelve (archivos revisados, literales revisados, errores)."""
    revisados = 0
    total = 0
    errores: list[str] = []
    for archivo in archivos(raiz):
        revisados += 1
        try:
            texto = archivo.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as fallo:
            relativo = archivo.relative_to(raiz).as_posix()
            errores.append(f"ERROR {relativo} no se pudo leer: {fallo}")
            continue
        for numero, ruta in literales(texto):
            total += 1
            if not (raiz / ruta[len("res://"):]).exists():
                relativo = archivo.relative_to(raiz).as_posix()
                errores.append(f"ERROR {relativo}:{numero} ruta inexistente {ruta}")
    return revisados, total, errores


def main() -> int:
    analizador = argparse.ArgumentParser(
        description="Comprueba que las rutas res:// literales existan.")
    analizador.add_argument("--raiz", type=Path, default=RAIZ,
                            help="raiz del proyecto (por defecto, la del repo)")
    argumentos = analizador.parse_args()

    raiz: Path = argumentos.raiz.resolve()
    revisados, total, errores = comprobar(raiz)
    for error in errores:
        print(error)
    if errores:
        with_fallo = len({error.split(" ")[1].split(":")[0] for error in errores})
        print(f"FALLO: {len(errores)} rutas inexistentes en {with_fallo} archivos "
              f"({total} literales revisados en {revisados} archivos)")
        return 1
    print(f"OK: {total} literales res:// en {revisados} archivos, "
          f"0 rutas inexistentes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
