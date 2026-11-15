#!/usr/bin/env python3
"""Mide el binario exportado con varios casos y saca la mediana de cada uno.

Sirve para comparar dos versiones en la MISMA maquina (por ejemplo, antes y
despues de un cambio). No sustituye a la medicion en la grafica real del
director: es una comparacion relativa.

Uso:
  python tools/medir_comparar.py <binario.exe> [etiqueta]
"""
from __future__ import annotations

import os
import statistics
import subprocess
import sys

CASOS = ["ciudad", "caminando", "pelea", "pausa"]
RONDAS = 3
DRIVER = "opengl3"


def medir(binario: str) -> dict[str, list[float]]:
    carpeta = os.path.dirname(os.path.abspath(binario))
    informe = os.path.join(carpeta, "medicion.txt")
    resultados: dict[str, list[float]] = {caso: [] for caso in CASOS}
    for ronda in range(1, RONDAS + 1):
        for caso in CASOS:
            if os.path.isfile(informe):
                os.remove(informe)
            entorno = dict(os.environ)
            entorno["CASO"] = caso
            entorno["RONDA"] = str(ronda)
            entorno.pop("QUITAR", None)
            entorno.pop("ESCALA", None)
            subprocess.run([os.path.abspath(binario), "--rendering-driver", DRIVER],
                           env=entorno, check=False, capture_output=True)
            if not os.path.isfile(informe):
                print("  sin medicion para %s (ronda %d)" % (caso, ronda), file=sys.stderr)
                continue
            with open(informe, encoding="utf-8") as fichero:
                for linea in fichero:
                    if not linea.startswith("RESULTADO"):
                        continue
                    campos = dict(par.split("=", 1) for par in linea.split() if "=" in par)
                    if campos.get("quitar", "") != "":
                        continue
                    resultados[caso].append(float(campos["fotograma_mediana"]))
    return resultados


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2
    binario = sys.argv[1]
    etiqueta = sys.argv[2] if len(sys.argv) > 2 else os.path.basename(binario)
    print("Midiendo %s (driver %s, %d rondas)" % (etiqueta, DRIVER, RONDAS))
    datos = medir(binario)
    print("| caso | mediana ms | muestras |")
    print("|---|---|---|")
    for caso in CASOS:
        valores = datos[caso]
        if not valores:
            print("| %s | sin datos | 0 |" % caso)
            continue
        print("| %s | %.2f | %d |" % (caso, statistics.median(valores), len(valores)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
