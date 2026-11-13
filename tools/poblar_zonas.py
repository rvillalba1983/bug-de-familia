#!/usr/bin/env python3
"""Puebla las zonas esqueleto (sin población) del mundo multi-zona.

Fase «contenido-zonas» (ADR 0027). Ahora que las 6 especies están implementadas,
cada zona declara en «species» TODAS las especies que la habitan (las que estaban
en «planned_species» pasan a «species») y añade «population» (límites provisionales)
y «homes» (área y puerta) para cada especie, con su geometría.

Los valores de población son provisionales (el director los ajusta jugando):
- 1 especie: 10/12/16 · 2 especies: 8/10/14 · 3: 6/8/12 · 4: 5/7/10.

No toca despliegue_cero.json (la zona de arranque) ni las zonas con contenido
completo (el_enchufe, lonja).
"""

import json
import glob
import os

ZONES_DIR = "data/zones"
SKIP = {"despliegue_cero", "el_enchufe", "lonja"}

PREFIX = {
    "jubilado": "jub",
    "mohocrata": "moho",
    "plegado": "pleg",
    "eco": "eco",
    "grux": "grux",
    "manada": "manada",
}

HOME_SIZE = (400, 400)
# Centros candidatos (deterministas) para repartir las casas cuando caben.
SLOTS = [(1100, 1100), (2900, 1100), (1100, 2900), (2900, 2900)]


def pop_for(count: int) -> dict:
    if count <= 1:
        return {"start": 10, "target": 12, "max": 16}
    if count == 2:
        return {"start": 8, "target": 10, "max": 14}
    if count == 3:
        return {"start": 6, "target": 8, "max": 12}
    return {"start": 5, "target": 7, "max": 10}


def overlaps(a: list, b: list) -> bool:
    return not (
        a[0] + a[2] <= b[0] or b[0] + b[2] <= a[0]
        or a[1] + a[3] <= b[1] or b[1] + b[3] <= a[1]
    )


def inside(rect: list, floor: list) -> bool:
    return not (
        rect[0] < floor[0] or rect[1] < floor[1]
        or rect[0] + rect[2] > floor[0] + floor[2]
        or rect[1] + rect[3] > floor[1] + floor[3]
    )


def place_home(species_index: int, blocks: list, floor: list, placed: list) -> list:
    order = SLOTS[species_index:] + SLOTS[:species_index]
    for cx, cy in order:
        rect = [cx - HOME_SIZE[0] // 2, cy - HOME_SIZE[1] // 2, HOME_SIZE[0], HOME_SIZE[1]]
        if not inside(rect, floor):
            continue
        if any(overlaps(rect, other) for other in blocks + placed):
            continue
        return rect
    for gy in range(floor[1] + 100, floor[1] + floor[3] - HOME_SIZE[1], 100):
        for gx in range(floor[0] + 100, floor[0] + floor[2] - HOME_SIZE[0], 100):
            rect = [gx, gy, HOME_SIZE[0], HOME_SIZE[1]]
            if any(overlaps(rect, other) for other in blocks + placed):
                continue
            return rect
    return [floor[0] + 100, floor[1] + 100, HOME_SIZE[0], HOME_SIZE[1]]


def leer_json(ruta: str) -> dict:
    """Lee un JSON en UTF-8: sin el encoding, Windows usa cp1252 (mojibake)."""
    with open(ruta, encoding="utf-8") as handle:
        datos = json.load(handle)
    return datos


def escribir_json(ruta: str, datos: dict) -> None:
    """Escribe un JSON en UTF-8 con LF y salto final, sin escapar acentos."""
    with open(ruta, "w", encoding="utf-8", newline="\n") as handle:
        json.dump(datos, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def main() -> None:
    changed = []
    for path in sorted(glob.glob(os.path.join(ZONES_DIR, "*.json"))):
        zone_id = os.path.splitext(os.path.basename(path))[0]
        if zone_id in SKIP:
            continue
        data = leer_json(path)

        species = list(data.get("species", []))
        for planned in data.get("planned_species", []):
            if planned not in species:
                species.append(planned)
        species.sort()
        data["species"] = species
        data["planned_species"] = []

        if not species:
            continue

        geometry = data.setdefault("geometry", {})
        blocks = geometry.get("shape_blocks", [])
        floor = geometry.get("floor_rect", [0, 0, 4000, 4000])

        population = {}
        homes = {}
        placed = []
        for index, species_id in enumerate(species):
            prefix = PREFIX.get(species_id, species_id)
            rect = place_home(index, blocks, floor, placed)
            placed.append(rect)
            gate = [rect[0] + rect[2] // 2, rect[1] + rect[3] // 2]
            geometry["%s_home" % prefix] = rect
            geometry["%s_gate" % prefix] = gate
            homes[species_id] = {"area": "%s_home" % prefix, "gate": "%s_gate" % prefix}
            population[species_id] = pop_for(len(species))

        data["population"] = population
        data["homes"] = homes

        escribir_json(path, data)
        changed.append("%s: %s" % (zone_id, ", ".join(species)))

    for line in changed:
        print(line)


if __name__ == "__main__":
    main()
