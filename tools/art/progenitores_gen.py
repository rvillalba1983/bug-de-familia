#!/usr/bin/env python3
"""Genera el arte SVG propio de los quince progenitores.

Origen de los datos: data/world/progenitors.json (nombre y color).
Herramienta: este script, sin recursos externos ni servicios de terceros.
Cinco vistas por progenitor, en el orden de GuardVisual.VIEW_SUFFIX:
base, _se, _e, _ne y _n. Las vistas cambian la mirada y el perfil, no la paleta.
"""

from __future__ import annotations

import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
ENTRADA = RAIZ / "data" / "world" / "progenitors.json"
SALIDA = RAIZ / "art" / "shared" / "progenitores"
SUFIJOS = ("", "_se", "_e", "_ne", "_n")

# Cada rasgo es un fragmento SVG con dos marcadores de color: {c} y {d}.
# Son siluetas geometricas dibujadas a mano para este proyecto.
RASGOS: dict[str, str] = {
    "ramon": (
        '<path d="M348 214l58-42" stroke="{d}" stroke-width="18" '
        'stroke-linecap="round"/><path d="M392 158l34 30-30 30-34-30z" '
        'fill="{c}" stroke="{d}" stroke-width="6"/>'
        '<rect x="150" y="106" width="212" height="16" rx="4" fill="{c}"/>'
    ),
    "contestador": (
        '<rect x="150" y="250" width="212" height="122" rx="8" fill="{d}" '
        'stroke="{c}" stroke-width="6"/><circle cx="200" cy="290" r="16" '
        'fill="{c}"/><circle cx="310" cy="290" r="16" fill="{c}"/>'
        '<path d="M256 250V186M220 186h72" stroke="{c}" stroke-width="8"/>'
    ),
    "biela": (
        '<circle cx="146" cy="368" r="26" fill="none" stroke="{c}" '
        'stroke-width="12"/><circle cx="366" cy="368" r="26" fill="none" '
        'stroke="{c}" stroke-width="12"/><path d="M256 360v72" '
        'stroke="{c}" stroke-width="14"/>'
    ),
    "pliegue_oculto": (
        '<path d="M256 116l96 116-96 58-96-58z" fill="{c}" opacity=".55" '
        'stroke="{d}" stroke-width="6"/><path d="M256 116v174M160 232l192 0" '
        'stroke="{d}" stroke-width="4" stroke-dasharray="10 8"/>'
    ),
    "papel_cebolla": (
        '<path d="M170 220h172v150H170z" fill="{c}" opacity=".18" '
        'stroke="{d}" stroke-width="4"/><path d="M190 240h172v150H190z" '
        'fill="{c}" opacity=".18" stroke="{d}" stroke-width="4"/>'
        '<path d="M210 260h172v150H210z" fill="{c}" opacity=".18" '
        'stroke="{d}" stroke-width="4"/>'
    ),
    "susurro": (
        '<path d="M256 86q104 0 104 120v96H152V206q0-120 104-120z" '
        'fill="{c}" opacity=".72" stroke="{d}" stroke-width="6"/>'
        '<path d="M370 190q30 22 0 44M386 174q50 38 0 76" fill="none" '
        'stroke="{c}" stroke-width="6"/>'
    ),
    "frecuencia": (
        '<path d="M196 232v112M196 232l64-12v112" fill="none" '
        'stroke="{c}" stroke-width="9"/><circle cx="184" cy="344" r="18" '
        'fill="{c}"/><circle cx="248" cy="332" r="18" fill="{c}"/>'
        '<path d="M292 232h72v124h-72z" fill="{d}"/><path d="M300 256h56M300 278h56'
        'M300 300h40" stroke="{c}" stroke-width="5"/>'
    ),
    "boletina": (
        '<path d="M116 168q140-96 280 0z" fill="{c}" stroke="{d}" '
        'stroke-width="8"/><rect x="212" y="168" width="88" height="56" '
        'rx="6" fill="{d}"/><path d="M232 196h20M272 196h20" '
        'stroke="{c}" stroke-width="8"/>'
    ),
    "yesquero": (
        '<path d="M126 164q130-92 260 0z" fill="{c}" stroke="{d}" '
        'stroke-width="8"/><circle cx="200" cy="204" r="12" fill="{d}"/>'
        '<circle cx="256" cy="188" r="12" fill="{d}"/>'
        '<circle cx="312" cy="204" r="12" fill="{d}"/>'
    ),
    "fiador": (
        '<path d="M256 206v-70M176 206h160" stroke="{c}" stroke-width="9"/>'
        '<path d="M186 206l70 62 70-62z" fill="none" stroke="{d}" '
        'stroke-width="8"/><rect x="320" y="300" width="64" height="44" '
        'rx="4" fill="{d}" stroke="{c}" stroke-width="5"/>'
    ),
    "garantia": (
        '<path d="M206 224h100M206 348h100M206 224l50 62-50 62M306 224l-50 62 50 62" '
        'fill="none" stroke="{c}" stroke-width="9"/>'
        '<rect x="224" y="160" width="64" height="48" rx="4" fill="{d}"/>'
    ),
    "avalista": (
        '<path d="M366 244q70 30 44 118" fill="none" stroke="{c}" '
        'stroke-width="26" stroke-linecap="round"/><circle cx="410" cy="370" r="26" '
        'fill="{c}" stroke="{d}" stroke-width="6"/>'
        '<rect x="384" y="284" width="52" height="34" rx="4" fill="{d}"/>'
    ),
    "cartero": (
        '<rect x="134" y="300" width="120" height="88" rx="8" fill="{d}" '
        'stroke="{c}" stroke-width="6"/><path d="M134 300l60 44 60-44" '
        'fill="none" stroke="{c}" stroke-width="6"/>'
        '<rect x="294" y="252" width="72" height="52" rx="4" fill="{c}" '
        'opacity=".8"/><path d="M294 252l36 30 36-30" fill="none" '
        'stroke="{d}" stroke-width="5"/>'
    ),
    "paquete": (
        '<rect x="160" y="270" width="192" height="118" rx="6" fill="{c}" '
        'opacity=".7" stroke="{d}" stroke-width="7"/>'
        '<path d="M160 270l56-46h80l56 46M256 224v164" fill="none" '
        'stroke="{d}" stroke-width="6"/><rect x="236" y="310" width="40" '
        'height="30" fill="{d}"/>'
    ),
    "ultimo_mono": (
        '<path d="M158 108q98-70 196 0q-24 44-98 44t-98-44z" fill="{c}" '
        'stroke="{d}" stroke-width="7"/>'
        '<path d="M180 138q76 34 152 0" fill="none" stroke="{d}" stroke-width="5"/>'
        '<circle cx="196" cy="126" r="8" fill="{d}"/>'
        '<circle cx="316" cy="126" r="8" fill="{d}"/>'
    ),
}

# Desplazamiento del rasgo segun la vista, para que no sea un calco literal.
DESPLAZAMIENTOS = ((0, 0), (18, 2), (28, 6), (16, -6), (0, 0))


def oscurecer(hex_color: str) -> str:
    """Mezcla el color con negro para obtener el tono de contorno."""
    limpio = hex_color.lstrip("#")
    canales = [int(limpio[i:i + 2], 16) for i in (0, 2, 4)]
    return "#" + "".join("%02x" % int(canal * 0.55) for canal in canales)


def ojos(index: int, color: str) -> str:
    """Dos ojos de frente, uno de perfil y ninguno en la vista de espaldas."""
    if index == 4:
        return '<path d="M204 140q52 26 104 0" fill="none" stroke="%s" stroke-width="6"/>' % color
    if index in (1, 2, 3):
        return '<circle cx="294" cy="130" r="20" fill="%s"/><circle cx="298" cy="134" r="8" fill="#141018"/>' % color
    return (
        '<circle cx="204" cy="130" r="20" fill="%s"/><circle cx="208" cy="134" r="8" '
        'fill="#141018"/><circle cx="308" cy="130" r="20" fill="%s"/>'
        '<circle cx="312" cy="134" r="8" fill="#141018"/>' % (color, color)
    )


def svg_para(identificador: str, nombre: str, color: str, indice: int) -> str:
    sufijo = SUFIJOS[indice]
    oscuro = oscurecer(color)
    dx, dy = DESPLAZAMIENTOS[indice]
    rasgo = RASGOS[identificador].format(c=color, d=oscuro)
    cabecera = (
        '<!-- Generado por tools/art/progenitores_gen.py desde '
        'data/world/progenitors.json. Sin recursos externos. -->\n'
        '<svg xmlns="http://www.w3.org/2000/svg" width="256" height="280" '
        'viewBox="0 0 512 560">\n'
        '<defs><linearGradient id="cuerpo" x1="0" y1="0" x2="0" y2="1">'
        '<stop offset="0" stop-color="%s"/><stop offset="1" stop-color="%s"/>'
        '</linearGradient></defs>\n'
        '<ellipse cx="256" cy="520" rx="146" ry="24" fill="#141018" opacity=".45"/>\n'
        '<g fill="none" stroke="%s" stroke-width="30" stroke-linecap="round">'
        '<path d="M210 438V500"/><path d="M302 438V500"/></g>\n'
        '<path d="M158 252q-14 186 18 210h160q32-24 18-210q-10-72-98-72t-98 72z" '
        'fill="url(#cuerpo)" stroke="%s" stroke-width="9"/>\n'
        '<path d="M160 250q-12 150 16 206h44q-18-140-8-206z" fill="%s" opacity=".55"/>\n'
        '<g transform="translate(%d %d)">%s</g>\n'
        '<path d="M156 116q0-92 100-92t100 92q0 82-100 82T156 116z" '
        'fill="%s" stroke="%s" stroke-width="9"/>\n'
        '%s\n'
        '<path d="M222 180q34 18 68 0" fill="none" stroke="%s" stroke-width="6"/>\n'
        '<title>%s</title></svg>\n'
    ) % (
        color, oscuro, oscuro, oscuro, oscuro, dx, dy, rasgo, color, oscuro,
        ojos(indice, color), oscuro, nombre,
    )
    return cabecera


def main() -> None:
    datos = json.loads(ENTRADA.read_text(encoding="utf-8"))
    SALIDA.mkdir(parents=True, exist_ok=True)
    total = 0
    for identificador, entrada in datos.items():
        color = str(entrada["color"])
        nombre = str(entrada["name"])
        for indice, sufijo in enumerate(SUFIJOS):
            destino = SALIDA / ("%s%s.svg" % (identificador, sufijo))
            destino.write_text(
                svg_para(identificador, nombre, color, indice),
                encoding="utf-8",
                newline="\n",
            )
            total += 1
    print("OK: %d SVGs en %s" % (total, SALIDA.relative_to(RAIZ).as_posix()))


if __name__ == "__main__":
    main()
