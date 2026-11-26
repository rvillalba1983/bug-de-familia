"""Añade fachadas y carteles a las zonas que aún no los declaran (ADR 0044).

No toca los rect de los corredores: solo delimita las bocas existentes con los
mismos dos rects que ya usan las 8 zonas del P-56. Es idempotente y visible: si
un corredor tiene `walls` o `facades`, se respeta; si el borde no es conocido,
falla con un error en lugar de inventar geometría. La señal se elige con el
mismo djb2 de `String.hash()` que el fallback de `ZoneBase`, para que declararla
no cambie la cartelería ya vista en partida.

Uso: python tools/gen_fachadas_zonas_json.py
"""
import glob
import json
import os

DEPTH = 400
THICK = 40
SIGN_COUNT = 10


def sign_for(destination: str) -> str:
    """ Réplica de `posmod(hash(destino), 10) + 1` de GDScript (djb2, 32 bits). """
    value = 5381
    for char in destination.encode("utf-8"):
        value = ((value << 5) + value + char) & 0xFFFFFFFF
    return "señal_%02d" % (value % SIGN_COUNT + 1)


def facades_for(corridor: dict) -> list:
    edge = corridor.get("edge")
    x, y, width, height = corridor["rect"]
    if edge in ("north", "south"):
        face_y = y + height if edge == "north" else y - DEPTH
        return [
            [x - THICK, face_y, THICK, DEPTH],
            [x + width, face_y, THICK, DEPTH],
        ]
    if edge in ("west", "east"):
        face_x = x + width if edge == "west" else x - DEPTH
        return [
            [face_x, y - THICK, DEPTH, THICK],
            [face_x, y + height, DEPTH, THICK],
        ]
    raise ValueError("Borde de corredor desconocido: %r" % (edge,))


def decorate_corridor(corridor: dict) -> dict:
    """Añade fachadas y señal sin mover ni borrar ningún campo existente."""
    facades = facades_for(corridor) if not (
        corridor.get("facades") or corridor.get("walls")
    ) else None
    sign = sign_for(str(corridor["to"])) if not corridor.get("sign") else None
    if facades is None and sign is None:
        return corridor
    result = {}
    for key, value in corridor.items():
        result[key] = value
        if key == "rect" and facades is not None:
            result["facades"] = facades
        if key == "to" and sign is not None:
            result["sign"] = sign
    return result


def main() -> None:
    total = 0
    for path in sorted(glob.glob("data/zones/*.json")):
        with open(path, "r", encoding="utf-8") as handle:
            zone = json.load(handle)
        corridors = zone.get("geometry", {}).get("corridors", [])
        updated = [decorate_corridor(corridor) for corridor in corridors]
        if updated == corridors:
            continue
        zone["geometry"]["corridors"] = updated
        with open(path, "w", encoding="utf-8", newline="\n") as handle:
            json.dump(zone, handle, indent=2, ensure_ascii=False)
            handle.write("\n")
        count = sum(1 for c in updated if c.get("facades"))
        signs = sum(1 for c in updated if c.get("sign"))
        print("%s: %d corredores delimitados, %d señales" % (
            os.path.basename(path), count, signs))
        total += count
    print("Total de corredores delimitados:", total)


if __name__ == "__main__":
    main()
