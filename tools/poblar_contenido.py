import json

# --- El Enchufe ---
path = 'data/zones/el_enchufe.json'
# encoding="utf-8" obligatorio: sin el, Windows lee con cp1252 y corrompe los
# acentos (el mojibake de 65 strings en c020fe5). newline="\n" evita CRLF.
with open(path, encoding='utf-8') as f:
    d = json.load(f)

d['actors'] = [
    {"id": "operador", "route": "operador_route", "species": "jubilado"},
    {"id": "escrutador", "route": "escrutador_route", "species": "mohocrata"}
]
d['items'] = [
    {"at": "crate_a", "id": "crate_a", "type": "crate"},
    {"at": "crate_b", "id": "crate_b", "type": "crate"},
    {"at": "pickup_leg", "id": "pickup_leg_1", "type": "leg"},
    {"at": "pickup_arm", "id": "pickup_arm_1", "type": "arm"}
]
d['convertibles'] = [
    {"id": "crate_a", "material": "madera_cuantica"},
    {"id": "crate_b", "material": "madera_cuantica"}
]
d['props'] = [
    {"at": "antennas", "id_prefix": "antena", "material": "fibra_fotonica", "prop": "antena", "size": [70, 130]},
    {"at": "panels", "id_prefix": "terminal", "material": "gel_memoria", "prop": "terminal", "size": [56, 84]}
]

with open(path, 'w', encoding='utf-8', newline='\n') as f:
    json.dump(d, f, ensure_ascii=False, indent=2)
    f.write('\n')
print('El Enchufe updated')

# --- Lonja ---
path = 'data/zones/lonja.json'
with open(path, encoding='utf-8') as f:
    d = json.load(f)

# Add grux to species
d['species'] = ['grux', 'jubilado']
d['species'].sort()
d['planned_species'] = []

# Add grux population
d['population']['grux'] = {"start": 8, "target": 10, "max": 14}

# Add grux home geometry
d['geometry']['grux_home'] = [800, 800, 600, 500]
d['geometry']['grux_gate'] = [1100, 1050]

# Add grux home
d['homes']['grux'] = {"area": "grux_home", "gate": "grux_gate"}

# Add geometry for content
d['geometry']['toldos'] = [[1500, 1200], [2000, 1200], [2500, 1200], [3000, 1200]]
d['geometry']['paneles'] = [[1200, 2000], [1800, 2000], [2800, 2000]]
d['geometry']['crate_a'] = [1600, 2600]
d['geometry']['crate_b'] = [2400, 2600]
d['geometry']['pickup_leg'] = [2000, 1600]
d['geometry']['pickup_arm'] = [2800, 1600]
d['geometry']['tasador_route'] = [[1600, 1800], [2400, 1800], [2400, 2400], [1600, 2400]]
d['geometry']['fiador_route'] = [[1800, 2000], [2200, 2000], [2200, 2200], [1800, 2200]]

d['actors'] = [
    {"id": "tasador", "route": "tasador_route", "species": "jubilado"},
    {"id": "fiador", "route": "fiador_route", "species": "grux"}
]
d['items'] = [
    {"at": "crate_a", "id": "crate_a", "type": "crate"},
    {"at": "crate_b", "id": "crate_b", "type": "crate"},
    {"at": "pickup_leg", "id": "pickup_leg_1", "type": "leg"},
    {"at": "pickup_arm", "id": "pickup_arm_1", "type": "arm"}
]
d['convertibles'] = [
    {"id": "crate_a", "material": "madera_cuantica"},
    {"id": "crate_b", "material": "madera_cuantica"}
]
d['props'] = [
    {"at": "toldos", "id_prefix": "toldo", "material": "madera_cuantica", "prop": "toldo", "size": [120, 60]},
    {"at": "paneles", "id_prefix": "panel", "material": "fibra_fotonica", "prop": "panel", "size": [72, 96]}
]

with open(path, 'w', encoding='utf-8', newline='\n') as f:
    json.dump(d, f, ensure_ascii=False, indent=2)
    f.write('\n')
print('Lonja updated')
