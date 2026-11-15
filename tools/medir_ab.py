#!/usr/bin/env python3
"""Compara dos binarios midiendo en rondas alternadas.

Alterna A y B en cada ronda (como hace tools/medir_windows/MEDIR.bat), para que
el calor de la maquina afecte por igual a los dos binarios y la diferencia no
sea ruido.

Uso:
  python tools/medir_ab.py <binarioA> <binarioB> [rondas] [etiquetaA] [etiquetaB]
"""
from __future__ import annotations

import os
import statistics
import subprocess
import sys

CASOS = ["ciudad", "caminando", "pelea", "pausa"]
DRIVER = "opengl3"


def medir_una(binario: str, caso: str, ronda: int) -> float | None:
    carpeta = os.path.dirname(os.path.abspath(binario))
    informe = os.path.join(carpeta, "medicion.txt")
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
        return None
    with open(informe, encoding="utf-8") as fichero:
        for linea in fichero:
            if not linea.startswith("RESULTADO"):
                continue
            campos = dict(par.split("=", 1) for par in linea.split() if "=" in par)
            if campos.get("quitar", "") != "":
                continue
            return float(campos["fotograma_mediana"])
    return None


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__, file=sys.stderr)
        return 2
    bin_a = sys.argv[1]
    bin_b = sys.argv[2]
    rondas = int(sys.argv[3]) if len(sys.argv) > 3 else 5
    etq_a = sys.argv[4] if len(sys.argv) > 4 else "A"
    etq_b = sys.argv[5] if len(sys.argv) > 5 else "B"
    datos: dict[str, dict[str, list[float]]] = {
        caso: {"A": [], "B": []} for caso in CASOS
    }
    for ronda in range(1, rondas + 1):
        for caso in CASOS:
            valor_a = medir_una(bin_a, caso, ronda)
            valor_b = medir_una(bin_b, caso, ronda)
            if valor_a is not None:
                datos[caso]["A"].append(valor_a)
            if valor_b is not None:
                datos[caso]["B"].append(valor_b)
        print("ronda %d de %d hecha" % (ronda, rondas), flush=True)
    print("")
    print("| caso | %s ms | %s ms | diferencia |" % (etq_a, etq_b))
    print("|---|---|---|---|")
    for caso in CASOS:
        a = datos[caso]["A"]
        b = datos[caso]["B"]
        if not a or not b:
            print("| %s | sin datos | | |" % caso)
            continue
        ma = statistics.median(a)
        mb = statistics.median(b)
        print("| %s | %.2f | %.2f | %+.1f %% |" % (caso, ma, mb, (mb - ma) / ma * 100.0))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
