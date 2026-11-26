#!/usr/bin/env python3
"""Hornea texturas pintadas y repetibles del suelo, sin modelos externos.

Uso: python tools/art/ground_gen.py <carpeta> [suelo_x ...]
Sin nombres, hornea los ocho suelos; con nombres, solo esos (no pisa los demás).
Origen: dibujo procedural propio. Herramienta: Playwright + Chromium locales.
"""
import sys
from playwright.sync_api import sync_playwright
SETS={'suelo_bosque':('#1a3a33 #24493c #2c5a44 #3b7350 #274a55','#6fa56a'),
      'suelo_ciudad':('#22163a #2c1c47 #34224f #452e62 #54304e','#7a5ea6'),
      'suelo_barro':('#3f2a2c #54302a #6a3a2a #7a3f28 #4a2a33','#c07a40'),
      'suelo_taller':('#2c3242 #3a4353 #4a5464 #5a4650 #2a3848','#00e5ff'),
      'suelo_mercado':('#3a3222 #4a3d28 #5c4a30 #6a4a38 #443228','#ffd400'),
      'suelo_archivo':('#3a3428 #4a4030 #5a4e3a #6a5c48 #4a4038','#f6e7c8'),
      'suelo_colmena':('#2e3420 #3e4428 #4e5430 #5a4a24 #3a4428','#c6ff00'),
      'suelo_piedra':('#2c2c2c #383838 #444444 #505050 #3a3434','#8894b5')}
def rgb(h): return [int(h[i:i+2],16)/255 for i in (1,3,5)]
def page(cols,light):
    c=[rgb(x) for x in cols.split()];t=lambda i:' '.join(f'{v[i]:.3f}' for v in c);L=rgb(light)
    return f'''<!doctype html><body style="margin:0"><svg xmlns="http://www.w3.org/2000/svg" width="512" height="512"><defs>
<filter id="a" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".0234" numOctaves="4" seed="8" stitchTiles="stitch"/>
<feColorMatrix values="1.9 0 0 0 -.45 1.9 0 0 0 -.45 1.9 0 0 0 -.45 0 0 0 0 1"/>
<feComponentTransfer><feFuncR type="discrete" tableValues="{t(0)}"/><feFuncG type="discrete" tableValues="{t(1)}"/><feFuncB type="discrete" tableValues="{t(2)}"/></feComponentTransfer></filter>
<filter id="b" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".0391 .1016" numOctaves="3" seed="3" stitchTiles="stitch"/>
<feColorMatrix values="0 0 0 0 {L[0]:.3f} 0 0 0 0 {L[1]:.3f} 0 0 0 0 {L[2]:.3f} 2.6 0 0 0 -1.25"/></filter>
<filter id="c" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".5" numOctaves="2" seed="5" stitchTiles="stitch"/>
<feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1.2 0 0 0 -.45"/></filter></defs>
<rect width="512" height="512" filter="url(#a)"/><rect width="512" height="512" filter="url(#b)" opacity=".22"/><rect width="512" height="512" filter="url(#c)" opacity=".35"/></svg>'''
wanted=sys.argv[2:] or list(SETS)
unknown=[n for n in wanted if n not in SETS]
if unknown: raise SystemExit('Suelos desconocidos: '+', '.join(unknown))
with sync_playwright() as p:
    b=p.chromium.launch();pg=b.new_page(viewport={'width':512,'height':512})
    for n in wanted:
        c,l=SETS[n]
        pg.set_content(page(c,l));pg.wait_for_timeout(300);pg.screenshot(path=f'{sys.argv[1]}/{n}.png')
    b.close()
