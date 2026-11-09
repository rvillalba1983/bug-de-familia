#!/usr/bin/env python3
"""Genera las fachadas de la centralita y el depósito, encajadas en sus muros."""
import sys,re
OUT=sys.argv[1]
TARGET=sys.argv[2]
s=open('tools/art/beta_assets_gen.py').read()
a='<path d="{crack}" fill="none" stroke="{INK}" stroke-width="16"'
i=s.index(a);j=s.index('<rect x="780" y="440"')
s=s[:i]+s[j:]
b='<path d="M382 420H546V720H382Z" fill="{INK}"/>'
assert b in s
s=s.replace(b,'<g transform="translate(422 0) scale(1.171 1) translate(-382 0)">'+b)
c='stroke="{INK}" stroke-width="7"/>\n{glow(365,470,16,RESET)}'
if c in s: pass
d='M436 538L492 594M492 538L436 594" stroke="{INK}" stroke-width="7"/>'
assert d in s
s=s.replace(d,d+'</g>')
sys.argv=['x',OUT];exec(s)
for f,n,w,h in (('09_centralita_contestador','fachada_centralita',500,480),('10_deposito_mohocrata','fachada_deposito',640,533)):
    t=open(f'{OUT}/{f}.svg').read()
    t=re.sub(r'width="960" height="800" viewBox="0 0 960 800"><defs>(.*?)</defs>',lambda m:f'width="{w}" height="{h}" viewBox="0 0 {w} {h}"><defs>{m.group(1)}</defs><g transform="scale({w/960:.5f} {h/800:.5f})">',t,count=1,flags=re.S).replace('</svg>','</g></svg>')
    open(f'{TARGET}/{n}.svg','w').write(t)
