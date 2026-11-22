#!/usr/bin/env python3
"""Conecta el campo art de progenitors.json con los SVG generados."""

from __future__ import annotations

import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
RUTA = RAIZ / "data" / "world" / "progenitors.json"

texto = RUTA.read_text(encoding="utf-8")
partes = re.split(r'^  "([a-z_]+)": \{$', texto, flags=re.MULTILINE)
if len(partes) < 3:
    raise SystemExit("No se encontraron progenitores")

resultado = [partes[0]]
for indice in range(1, len(partes), 2):
    identificador = partes[indice]
    bloque = partes[indice + 1]
    patron = r'^    "art": "[^"]+"(,?)$'
    nuevo = '    "art": "progenitores/%s"\\1' % identificador
    bloque, count = re.subn(patron, nuevo, bloque, count=1, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit("Campo art no encontrado o duplicado en %s" % identificador)
    resultado.extend([ '  "%s": {' % identificador, bloque])

RUTA.write_text("".join(resultado), encoding="utf-8", newline="\n")
print("OK: campo art conectado en %d progenitores" % ((len(partes) - 1) // 2))
