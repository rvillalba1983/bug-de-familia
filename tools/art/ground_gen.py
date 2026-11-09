#!/usr/bin/env python3
"""Hornea las texturas pintadas y repetibles del suelo de la beta en art/beta/."""
import sys
from playwright.sync_api import sync_playwright
SETS={'suelo_bosque':('#1a3a33 #24493c #2c5a44 #3b7350 #274a55','#6fa56a'),
      'suelo_ciudad':('#22163a #2c1c47 #34224f #452e62 #54304e','#7a5ea6'),
      'suelo_barro':('#3f2a2c #54302a #6a3a2a #7a3f28 #4a2a33','#c07a40')}
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
with sync_playwright() as p:
    b=p.chromium.launch();pg=b.new_page(viewport={'width':512,'height':512})
    for n,(c,l) in SETS.items():
        pg.set_content(page(c,l));pg.wait_for_timeout(300);pg.screenshot(path=f'{sys.argv[1]}/{n}.png')
    b.close()
