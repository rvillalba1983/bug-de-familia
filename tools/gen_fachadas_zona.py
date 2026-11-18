"""Genera las 32 fachadas de corredor por zona (P-56): 8 zonas x 4 variantes.

Cada zona usa una paleta propia acorde al lore. Las 4 variantes comparten la
paleta pero varian en ventanas, puertas, dano y detalles para que no se vean
iguales al alternar por orden de montaje.
"""
import os

OUT = "art/shared"

# Paletas por zona: (muro, cornisa, cristal, zocalo, acento, ink)
PALETTES = {
    "cumbre": ("#5A4A78", "#3A2A5C", "#8894B5", "#4A3A6E", "#c8b8e8", "#1B0E2A"),
    "desguace": ("#6A4A3A", "#3A2A20", "#8A6A4A", "#4A3020", "#d8985a", "#1B0E2A"),
    "encrucijada": ("#4A5A5A", "#2A3A3A", "#8A9A9A", "#3A4A4A", "#8fdbd8", "#1B0E2A"),
    "gran_cruce": ("#5A5A4A", "#3A3A2A", "#9A9A8A", "#4A4A3A", "#ffe14a", "#1B0E2A"),
    "gran_mercado": ("#6A5A3A", "#3A2A1A", "#A09060", "#4A3A20", "#a0d060", "#1B0E2A"),
    "paso": ("#4A5A4A", "#2A3A2A", "#8A9A8A", "#3A4A3A", "#a0d060", "#1B0E2A"),
    "poligono": ("#4A5A6A", "#2A3A4A", "#8A9AAA", "#3A4A5A", "#8fdbd8", "#1B0E2A"),
    "taller": ("#6A5A3A", "#3A2A1A", "#A09060", "#4A3A20", "#d8985a", "#1B0E2A"),
}

DETAILS = {
    "cumbre": ["pliegue", "archivo", "esquina", "grieta"],
    "desguace": ["chatarra", "mina", "petanca", "oxido"],
    "encrucijada": ["cruce", "mezcla", "esquina", "signo"],
    "gran_cruce": ["cruce", "grande", "esquina", "signo"],
    "gran_mercado": ["toldo", "puesto", "caja", "fúngico"],
    "paso": ["taller", "zigzag", "engranaje", "mina"],
    "poligono": ["almacen", "caja", "puerta", "camion"],
    "taller": ["maquina", "prensa", "torno", "engranaje"],
}

def svg(zone, idx):
    muro, cornisa, cristal, zocalo, acento, ink = PALETTES[zone]
    det = DETAILS[zone][idx % 4]
    # Variacion de ventanas: cada variante cambia que ventana esta tapiada/rota
    variants = [
        (0, 1, 2, 3),  # todas abiertas
        (1, 2, 3, 0),  # una tapiada
        (2, 3, 0, 1),  # otra tapiada
        (3, 0, 1, 2),  # otra
    ]
    v = variants[idx]
    # Ventanas altas (5): estados 0=abierta,1=tapiada,2=rota,3=persiana
    def win_fill(state):
        if state == 1: return ink
        if state == 2: return cristal
        if state == 3: return acento
        return cristal
    def win_extra(state, x):
        if state == 1:
            return f'<rect x="{x+6}" y="54" width="44" height="12" fill="{acento}" stroke="{ink}" stroke-width="3" transform="rotate(-4 {x+28} 60)"/>'
        if state == 2:
            return f'<path d="{x+8} 48 L{x+22} 58 L{x+12} 66 Z" fill="{cristal}" opacity="0.55"/>'
        if state == 3:
            return f'<rect x="{x}" y="52" width="56" height="44" fill="{acento}" stroke="{ink}" stroke-width="4"/>'
        return ""
    high_wins = []
    for i in range(5):
        x = 12 + i*80
        st = v[i % 4] if i < 4 else 0
        fill = win_fill(st)
        high_wins.append(f'    <rect x="{x}" y="42" width="56" height="52" fill="{fill}" stroke="{ink}" stroke-width="5"/>')
        extra = win_extra(st, x)
        if extra:
            high_wins.append("    " + extra)
    high_wins_str = "\n".join(high_wins)

    # Ventanas bajas (4)
    low_states = [(idx+1)%4, (idx+2)%4, (idx+3)%4, idx%4]
    low_wins = []
    for i in range(4):
        x = 18 + i*100
        st = low_states[i]
        fill = ink if st == 1 else (cristal if st in (0,2) else acento)
        low_wins.append(f'    <rect x="{x}" y="146" width="64" height="62" fill="{fill}" stroke="{ink}" stroke-width="5"/>')
    low_wins_str = "\n".join(low_wins)

    return f'''<?xml version="1.0" encoding="UTF-8"?>
<!--
  fachada_corredor_{zone}_{idx+1:02d} · Fachada propia de {zone} (P-56)
  Bug de Familia · variante {idx+1} de 4
  Origen: dibujo propio; no usa material de terceros
  Herramienta: tools/gen_fachadas_zona.py (generador propio)
  Lienzo 400 x 240 · sin fondo · se estira al frente del pasillo (200 u de alto)
  Detalle tematico: {det}
-->
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="240" viewBox="0 0 400 240">
  <defs>
    <linearGradient id="muro" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{muro}"/>
      <stop offset="0.55" stop-color="{cornisa}"/>
      <stop offset="1" stop-color="{zocalo}"/>
    </linearGradient>
    <linearGradient id="cornisa" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{acento}"/>
      <stop offset="1" stop-color="{cornisa}"/>
    </linearGradient>
    <linearGradient id="cristal" x1="0" y1="0" x2="0.6" y2="1">
      <stop offset="0" stop-color="{cristal}"/>
      <stop offset="0.6" stop-color="{muro}"/>
      <stop offset="1" stop-color="{ink}"/>
    </linearGradient>
    <linearGradient id="zocalo" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{cristal}"/>
      <stop offset="1" stop-color="{muro}"/>
    </linearGradient>
  </defs>

  <!-- muro: cubre todo el lienzo -->
  <rect x="0" y="0" width="400" height="240" fill="url(#muro)"/>

  <!-- llagas del ladrillo -->
  <g stroke="{cristal}" stroke-width="2" fill="none" opacity="0.16">
    <path d="M0 40H400M0 60H400M0 80H400M0 132H400M0 152H400M0 172H400M0 192H400M0 206H400"/>
  </g>
  <g stroke="{cristal}" stroke-width="2" fill="none" opacity="0.12">
    <path d="M48 40V60M120 60V80M192 40V60M264 60V80M336 40V60M84 132V152M156 152V172M228 132V152M300 152V172M372 132V152"/>
  </g>
  <!-- esquinas en sombra -->
  <g fill="{ink}" opacity="0.2">
    <rect x="0" y="26" width="10" height="186"/>
    <rect x="390" y="26" width="10" height="186"/>
  </g>

  <!-- cornisa -->
  <rect x="0" y="0" width="400" height="26" fill="url(#cornisa)"/>
  <g fill="{ink}" opacity="0.45">
    <rect x="10" y="26" width="14" height="10"/>
    <rect x="42" y="26" width="14" height="10"/>
    <rect x="74" y="26" width="14" height="10"/>
    <rect x="106" y="26" width="14" height="10"/>
    <rect x="138" y="26" width="14" height="10"/>
    <rect x="170" y="26" width="14" height="10"/>
    <rect x="202" y="26" width="14" height="10"/>
    <rect x="234" y="26" width="14" height="10"/>
    <rect x="266" y="26" width="14" height="10"/>
    <rect x="298" y="26" width="14" height="10"/>
    <rect x="330" y="26" width="14" height="10"/>
    <rect x="362" y="26" width="14" height="10"/>
  </g>
  <path d="M0 26H400" stroke="{ink}" stroke-width="7"/>

  <!-- marcos claros -->
  <g fill="{cristal}" stroke="{ink}" stroke-width="5" stroke-linejoin="round">
    <rect x="5" y="35" width="70" height="66"/>
    <rect x="85" y="35" width="70" height="66"/>
    <rect x="165" y="35" width="70" height="66"/>
    <rect x="245" y="35" width="70" height="66"/>
    <rect x="325" y="35" width="70" height="66"/>
  </g>

  <!-- ventanas altas -->
{high_wins_str}

  <!-- imposta entre plantas -->
  <rect x="0" y="120" width="400" height="12" fill="{muro}"/>
  <path d="M0 120H400M0 132H400" stroke="{ink}" stroke-width="4"/>

  <!-- ventanas bajas -->
  <g stroke="{ink}" stroke-width="5" stroke-linejoin="round">
{low_wins_str}
  </g>

  <!-- acento tematico: banda central con el color de acento -->
  <rect x="0" y="108" width="400" height="6" fill="{acento}" opacity="0.6"/>

  <!-- bajantes de hierro -->
  <g stroke="{ink}" stroke-width="4" stroke-linejoin="round" fill="{cristal}">
    <rect x="4" y="26" width="12" height="186"/>
    <rect x="384" y="26" width="12" height="186"/>
  </g>

  <!-- grietas -->
  <g fill="none" stroke="{ink}" stroke-width="3" stroke-linecap="round" opacity="0.8">
    <path d="M104 134L112 156L102 176"/>
    <path d="M244 134L258 158L248 178"/>
  </g>

  <!-- zocalo -->
  <rect x="0" y="212" width="400" height="28" fill="url(#zocalo)"/>
  <path d="M0 212H400" stroke="{ink}" stroke-width="6"/>
  <g stroke="{ink}" stroke-width="4" opacity="0.55" fill="none">
    <path d="M62 212V240M146 212V240M230 212V240M314 212V240"/>
  </g>
  <g fill="{acento}" stroke="{ink}" stroke-width="3" stroke-linejoin="round" opacity="0.85">
    <circle cx="100" cy="222" r="9"/>
    <circle cx="286" cy="224" r="8"/>
  </g>
</svg>
'''

def main():
    for zone in PALETTES:
        for idx in range(4):
            path = os.path.join(OUT, f"fachada_corredor_{zone}_{idx+1:02d}.svg")
            with open(path, "w", encoding="utf-8") as f:
                f.write(svg(zone, idx))
            print("wrote", path)

if __name__ == "__main__":
    main()
