#!/usr/bin/env python3
"""Añade el campo 'timbre' a cada IA de data/ai/personalities.json (P-29).

El timbre decide el bus de voz y, con él, el filtro que suena:
  normal     -> voz tal cual
  radio      -> radio de bolsillo rota
  eco        -> sala vacía
  distorsion -> voz saturada

El cambio es quirúrgico: se inserta una línea tras el "pitch" de cada IA, sin
reformatear el resto del fichero.
"""

import os
import re
import sys

RUTA = os.path.join("data", "ai", "personalities.json")

# Un timbre por IA, elegido para que case con su personalidad.
TIMBRES = {
    "panico": "radio",
    "dr_desprecio": "distorsion",
    "mama": "distorsion",
    "troll": "distorsion",
    "abuela": "eco",
    "arbitro": "normal",
    "pesimo_optimus": "radio",
    "matriz": "eco",
    "cupido": "normal",
    "rencorosa": "distorsion",
    "friki": "radio",
    "compost": "normal",
    "conspi": "eco",
    "siestaware": "radio",
    "sargento_bit": "radio",
    "narcisa": "normal",
    "nihil": "eco",
    "burocrata": "eco",
    "lumi": "normal",
    "chef": "distorsion",
}

PATRON_IA = re.compile(r'^(\s*)"([a-z_]+)": \{$')
PATRON_PITCH = re.compile(r'^(\s*)"pitch": ([0-9.]+),$')


def main() -> int:
    with open(RUTA, encoding="utf-8") as fichero:
        lineas = fichero.readlines()
    salida = []
    ia_actual = ""
    insertadas = []
    for linea in lineas:
        coincide_ia = PATRON_IA.match(linea.rstrip("\n"))
        if coincide_ia:
            ia_actual = coincide_ia.group(2)
        salida.append(linea)
        coincide_pitch = PATRON_PITCH.match(linea.rstrip("\n"))
        if coincide_pitch and ia_actual in TIMBRES:
            sangria = coincide_pitch.group(1)
            salida.append('%s"timbre": "%s",\n' % (sangria, TIMBRES[ia_actual]))
            insertadas.append(ia_actual)
    if sorted(insertadas) != sorted(TIMBRES):
        print("ERROR: IAs sin timbre o timbres de sobra")
        print("  faltantes: %s" % ", ".join(sorted(set(TIMBRES) - set(insertadas))))
        print("  sobrantes: %s" % ", ".join(sorted(set(insertadas) - set(TIMBRES))))
        return 1
    with open(RUTA, "w", encoding="utf-8", newline="") as fichero:
        fichero.writelines(salida)
    print("Timbre asignado a %d IAs" % len(insertadas))
    return 0


if __name__ == "__main__":
    sys.exit(main())
