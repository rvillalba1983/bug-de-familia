#!/usr/bin/env python3
"""Separa la vista sur de un personaje SVG en piezas para animarlo con huesos.

Cada pieza conserva el lienzo de 512 x 512, de modo que basta colocarla en el mismo sitio.
Uso: python3 tools/art/rig_split.py
Origen: art/beta/*.svg, generados por Claude. Sin servicios externos.
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "art" / "beta"
ELEMENT = re.compile(r"<(path|circle|ellipse|rect)\b[^>]*/>")

# Línea del SVG -> pieza, o lista con la pieza de cada elemento de la línea.
JUBILADO = {
    2: ["pierna_i", "pierna_d"], 3: ["pierna_i", "pierna_d"],
    4: "cordones", 5: ["pierna_i", "pierna_d"], 6: "brazo_d",
    7: "brazos", 8: "brazos", 9: "brazo_i", 10: "brazo_i", 11: "brazo_d",
    **{n: "torso" for n in range(12, 22)},
    **{n: "cabeza" for n in range(22, 35)},
}
BRAZOS = {"M136": "brazo_i", "M380": "brazo_d"}


def split_laces(element):
    """Separa una ruta con dos trazos en un elemento por trazo."""
    d = re.search(r'd="([^"]+)"', element).group(1)
    return [element.replace(d, "M" + t.strip()) for t in d.split("M") if t.strip()]


def main():
    lines = (ROOT / "jubilado_hierro.svg").read_text(encoding="utf8").splitlines()
    head, _, _ = lines[0].partition("</defs>")
    head += "</defs>"
    parts = {}
    for number, target in JUBILADO.items():
        if number > len(lines):
            continue
        line = lines[number - 1].replace("</svg>", "")
        if target == "cordones":
            for piece, element in zip(("pierna_i", "pierna_d"), split_laces(line)):
                parts.setdefault(piece, []).append(element)
        elif target == "brazos":
            wrapper = 'fill="none" stroke-linecap="round" '
            for match in ELEMENT.finditer(line):
                element = match.group(0)
                d = re.search(r'd="(M\d+)', element).group(1)
                parts.setdefault(BRAZOS[d], []).append(element.replace("<path ", "<path " + wrapper, 1))
        elif isinstance(target, list):
            for piece, match in zip(target, ELEMENT.finditer(line)):
                parts.setdefault(piece, []).append(match.group(0))
        else:
            parts.setdefault(target, []).append(line)
    folder = ROOT / "rig" / "jubilado_hierro"
    folder.mkdir(parents=True, exist_ok=True)
    for name, body in parts.items():
        (folder / f"{name}.svg").write_text(head + "".join(body) + "</svg>\n", encoding="utf8")
    print(sorted(parts))


if __name__ == "__main__":
    main()
