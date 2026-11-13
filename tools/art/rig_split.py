#!/usr/bin/env python3
"""Separa cada vista de un personaje SVG en piezas para animarlo con huesos.

Cada pieza conserva el lienzo original, de modo que basta colocarla en el mismo sitio.
Una vista de perfil puede repetir un elemento en dos piezas: la pierna se ve una vez,
pero al andar hacen falta dos. Los números son los elementos de dibujo del SVG, en orden
y sin contar grupos; una tupla (n, k) es el trazo k de una ruta con varios trazos.

Uso: python3 tools/art/rig_split.py
Origen: art/shared/*.svg, generados por Claude. Sin servicios externos.
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "art" / "shared"
TAG = re.compile(r"<(/?)(g|path|circle|ellipse|rect)\b[^>]*?(/?)>", re.S)
PART_ORDER = ("pierna_i", "pierna_d", "brazo_i", "brazo_d", "torso", "cabeza")


def span(first, last):
    return list(range(first, last + 1))


VIEWS = {
    "jubilado_hierro": {
        "pierna_i": [1, 3, (5, 0), 6], "pierna_d": [2, 4, (5, 1), 7],
        "brazo_i": [12, 14, *span(16, 22)], "brazo_d": [8, 9, 10, 11, 13, 15, 23],
        "torso": span(24, 72), "cabeza": span(73, 93),
    },
    "jubilado_hierro_e": {
        "pierna_i": [1, 2, 3], "pierna_d": [1, 2, 3], "brazo_i": [4, 5, 6],
        "brazo_d": span(27, 31), "torso": span(7, 26), "cabeza": span(32, 44),
    },
    "jubilado_hierro_n": {
        "pierna_i": [1, 3], "pierna_d": [2, 4], "brazo_i": [5, 7, 9, 10, 11],
        "brazo_d": [6, 8, 12, 13], "torso": span(14, 44), "cabeza": span(45, 53),
    },
    "mohocrata": {
        "brazo_i": [1, 3, 5], "brazo_d": [2, 4, 6, 7, 8, 9],
        "torso": span(10, 29), "cabeza": span(30, 98),
    },
    "mohocrata_e": {
        "brazo_i": [1, 2], "brazo_d": span(18, 21),
        "torso": span(3, 17), "cabeza": span(22, 62),
    },
    "mohocrata_n": {
        "brazo_i": [1, 3, 27], "brazo_d": [2, 4, 28],
        "torso": span(5, 26), "cabeza": span(29, 52),
    },
    "don_ramon": {
        "pierna_i": [1, 3, (5, 0)], "pierna_d": [2, 4, (5, 1)],
        "brazo_i": [6, 8, *span(20, 23)], "brazo_d": [7, 9, *span(10, 19)],
        "torso": span(24, 67), "cabeza": span(68, 89),
    },
    "don_ramon_e": {
        "pierna_i": [1, 2], "pierna_d": [1, 2], "brazo_d": span(9, 14),
        "torso": span(3, 8), "cabeza": span(15, 26),
    },
    "don_ramon_n": {
        "pierna_i": [1, 3], "pierna_d": [2, 4], "brazo_i": [5, 7, 9],
        "brazo_d": [6, 8, 10], "torso": span(11, 32), "cabeza": span(33, 36),
    },
}


def leaves_of(text):
    """Devuelve (cabecera, elementos); cada elemento lleva los grupos que lo envuelven."""
    defs_end = text.index("</defs>") + len("</defs>")
    head, body = text[:defs_end], text[defs_end:]
    open_groups, result = [], []
    for match in TAG.finditer(body):
        closing, tag, empty = match.groups()
        if tag == "g":
            if closing:
                open_groups.pop()
            elif not empty:
                open_groups.append(match.group(0))
        else:
            result.append((match.group(0), tuple(open_groups)))
    return head, result


def single_stroke(element, index):
    d = re.search(r'd="([^"]+)"', element).group(1)
    strokes = ["M" + t.strip() for t in d.split("M") if t.strip()]
    return element.replace(d, strokes[index])


def render(entry):
    element, groups = entry
    return "".join(groups) + element + "</g>" * len(groups)


def split_view(name, spec):
    head, elements = leaves_of((ROOT / f"{name}.svg").read_text(encoding="utf8"))
    folder = ROOT / "rig" / name
    folder.mkdir(parents=True, exist_ok=True)
    for part, ids in spec.items():
        chosen = []
        for item in ids:
            if isinstance(item, tuple):
                element, groups = elements[item[0]]
                chosen.append((single_stroke(element, item[1]), groups))
            else:
                chosen.append(elements[item])
        (folder / f"{part}.svg").write_text(head + "".join(map(render, chosen)) + "</svg>\n", encoding="utf8")
    used = {i[0] if isinstance(i, tuple) else i for ids in spec.values() for i in ids}
    missing = sorted(set(range(1, len(elements))) - used)
    if missing:
        raise SystemExit(f"{name}: elementos sin pieza: {missing}")
    print(name, [p for p in PART_ORDER if p in spec])


def main():
    for name, spec in VIEWS.items():
        split_view(name, spec)


if __name__ == "__main__":
    main()
