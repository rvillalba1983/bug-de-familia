#!/usr/bin/env python3
"""Genera las vistas de espalda (_n) y de lado (_e) de los NPC.

El directorio de salida se pasa como argumento: python tools/art/npc_views_gen.py <carpeta>
"""
import sys
src=open('tools/art/beta_assets_gen.py').read().split('# 1 MINA')[0]
sys.argv=['x',sys.argv[1]];exec(src)
def out(n,w,h,dw,dh,d,b):
    open(f'{OUT}/{n}.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{dw}" height="{dh}" viewBox="0 0 {w} {h}"><defs>{d}</defs>{b}</svg>\n')
# JUBILADO
dj=rad('a',HIER,HIER2,.3,.2,1)+rad('b',HUES,HIER,.3,.2,1)+rad('mine',HIER,MORA)
BOINA=lambda cx,cy: f'<g transform="rotate(-6 {cx} {cy})"><ellipse cx="{cx}" cy="{cy}" rx="132" ry="40" fill="{MORA}" {ol(8)}/><ellipse cx="{cx-26}" cy="{cy-12}" rx="74" ry="18" fill="{BERE}"/><path d="M{cx} {cy-38}q2-20 18-22" stroke="{INK}" stroke-width="9" fill="none" stroke-linecap="round"/></g>'
mine=lambda x,y:f'<circle cx="{x}" cy="{y}" r="46" fill="url(#mine)" {ol(7)}/><path d="M{x-42} {y-7}Q{x} {y-36} {x+44} {y-7}" stroke="{OBRA}" stroke-width="8" fill="none"/><rect x="{x-8}" y="{y-54}" width="24" height="12" rx="3" fill="{MULTA}" {ol(4)}/>'
SLIP=f'<g {ol(7)}><path d="M178 400V446H232V400Z" fill="{HIER2}"/><path d="M286 400V446H340V400Z" fill="{HIER2}"/><path d="M150 466Q150 432 196 432Q244 432 244 466Q196 486 150 466Z" fill="{MULTA}"/><path d="M272 466Q272 432 318 432Q366 432 366 466Q318 486 272 466Z" fill="{MULTA}"/></g>'
out('jubilado_hierro_n',512,512,256,256,dj,shadow(256,474,162,26)+SLIP+f'''
<g fill="none" stroke-linecap="round"><path d="M136 274Q92 310 104 356" stroke="{INK}" stroke-width="30"/><path d="M380 272Q422 310 410 356" stroke="{INK}" stroke-width="30"/><path d="M136 274Q92 310 104 356" stroke="{HIER}" stroke-width="18" stroke-dasharray="10 8"/><path d="M380 272Q422 310 410 356" stroke="{HIER}" stroke-width="18" stroke-dasharray="10 8"/></g>{mine(104,398)}
<path d="M410 356L420 472" stroke="{INK}" stroke-width="18" stroke-linecap="round"/><path d="M410 356L420 472" stroke="{OBRA}" stroke-width="9" stroke-linecap="round"/>
<path d="M132 240Q124 410 256 416Q392 410 384 240Q372 170 258 170Q140 170 132 240Z" fill="url(#a)" {ol(8)}/>
{scratches(71,160,240,366,400,22,HUES,2.5,.35)}
<rect x="186" y="228" width="140" height="130" rx="12" fill="{OXID}" {ol(7)}/><g stroke="{INK}" stroke-width="7"><path d="M204 256H308M204 284H308M204 312H308"/></g><circle cx="256" cy="336" r="10" fill="{RESET}" {ol(4)}/>
{rivets([(150,256),(166,352),(206,398),(310,394),(366,342)],6,HUES)}
<rect x="218" y="154" width="84" height="34" fill="{HIER2}" {ol(6)}/>
<path d="M116 118Q116 44 256 44Q398 44 398 118Q398 196 256 196Q116 196 116 118Z" fill="url(#b)" {ol(8)}/><path d="M176 150H336" stroke="{INK}" stroke-width="7" stroke-linecap="round"/>{rivets([(150,120),(362,120),(256,172)],6,HIER2)}{BOINA(256,58)}''')
out('jubilado_hierro_e',512,512,256,256,dj,shadow(256,474,150,26)+f'''
<g {ol(7)}><path d="M210 400V446H264V400Z" fill="{HIER2}"/><path d="M196 466Q196 432 250 432Q310 432 316 466Q250 486 196 466Z" fill="{MULTA}"/></g><circle cx="258" cy="436" r="12" fill="{OBRA}" {ol(4)}/>
{mine(116,352)}
<path d="M176 244Q164 410 250 416Q354 410 352 244Q340 170 262 170Q184 170 176 244Z" fill="url(#a)" {ol(8)}/>
{scratches(72,190,240,340,400,16,HUES,2.5,.35)}
<circle cx="296" cy="312" r="40" fill="{HUES}" {ol(6)}/><path d="M296 312L314 292" stroke="{MULTA}" stroke-width="7" stroke-linecap="round"/><circle cx="296" cy="312" r="6" fill="{INK}"/>
<path d="M240 280Q230 340 306 362" stroke="{INK}" stroke-width="30" fill="none" stroke-linecap="round"/><path d="M240 280Q230 340 306 362" stroke="{HIER}" stroke-width="18" stroke-dasharray="10 8" fill="none" stroke-linecap="round"/>
<path d="M346 262L356 472" stroke="{INK}" stroke-width="18" stroke-linecap="round"/><path d="M346 262L356 472" stroke="{OBRA}" stroke-width="9" stroke-linecap="round"/><path d="M306 362Q330 340 346 300" stroke="{INK}" stroke-width="26" fill="none" stroke-linecap="round"/>
<rect x="222" y="154" width="74" height="34" fill="{HIER2}" {ol(6)}/>
<path d="M150 118Q150 44 262 44Q372 44 382 112Q392 190 268 196Q150 196 150 118Z" fill="url(#b)" {ol(8)}/>
{glow(322,118,38,RESET)}<circle cx="322" cy="118" r="40" fill="{INK}"/><circle cx="322" cy="118" r="30" fill="{RESET}"/><circle cx="330" cy="118" r="14" fill="{INK}"/><circle cx="314" cy="104" r="8" fill="#fff"/>
<path d="M286 80Q330 56 378 82" fill="none" stroke="{INK}" stroke-width="15" stroke-linecap="round"/>
<path d="M280 172Q330 140 396 164Q372 186 330 180Q300 188 280 172Z" fill="{HUES}" {ol(5)}/>{BOINA(262,58)}''')
# MOHOCRATA
dm=rad('cap',MULTA,MULTA2,.35,.25,.9)+lin('st',ACID,MOHO2)+rad('hat',BUTA,OXID2,.3,.2,1)
ROOTS=f'<g fill="none" stroke-linecap="round"><path d="M180 396Q108 410 88 346" stroke="{INK}" stroke-width="34"/><path d="M336 388Q424 392 438 322" stroke="{INK}" stroke-width="34"/><path d="M180 396Q108 410 88 346" stroke="{MOHO}" stroke-width="22"/><path d="M336 388Q424 392 438 322" stroke="{MOHO}" stroke-width="22"/></g>'
def cap_hat(cx=256):
    sh=cx-256
    spots=''.join(f'<ellipse cx="{x+sh}" cy="{y}" rx="{a}" ry="{b}" fill="{c}"/>' for x,y,a,b,c in((150,172,26,15,HUES),(216,124,20,11,ACID),(346,160,30,17,HUES),(280,196,22,12,ACID)))
    return f'''<g transform="translate({sh} 0)"><path d="M86 226Q84 124 256 110Q432 124 430 226Q420 268 256 268Q92 268 86 226Z" fill="url(#cap)" {ol(8)}/></g>{spots}<g transform="translate({sh} 0) rotate(-9 256 96)"><path d="M160 118L176 42Q256 22 336 42L352 118Q256 148 160 118Z" fill="url(#hat)" {ol(7)}/><path d="M136 112Q256 174 376 112L386 134Q256 196 126 134Z" fill="{HIER}" {ol(7)}/><path d="M176 42Q256 22 336 42Q330 64 256 66Q182 64 176 42Z" fill="{HIER2}" {ol(5)}/>{dots(22,190,74,322,118,16,INK,2,4,.9)}</g>'''
out('mohocrata_n',512,512,256,256,dm,shadow(256,470,158,28)+ROOTS+f'''
<path d="M170 266Q152 400 168 462Q214 480 256 464Q300 480 346 462Q362 400 342 266Z" fill="url(#st)" {ol(7)}/>{dots(21,190,300,330,450,20,MOHO2,3,9,.75)}
<path d="M236 300Q256 380 240 450M290 310Q272 380 286 448" stroke="{MOHO2}" stroke-width="7" fill="none"/>
<g {ol(5)}><path d="M64 348l-14-30l18 12l6-26l12 24l18-16l-6 34z" fill="{ACID}"/><path d="M430 322l-10-20l14 8l6-18l10 18l12-10l-6 26z" fill="{ACID}"/></g>{cap_hat()}''')
gill=''.join(f'<path d="M{x} 244Q{x+6} 262 {x+12} 280" stroke="{MULTA2}" stroke-width="4" fill="none"/>' for x in range(120,392,24))
def eye(x,y,r,c=OBRA): return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}" {ol(4)}/><ellipse cx="{x+r*.25:.0f}" cy="{y}" rx="{r*.28:.1f}" ry="{r*.7:.1f}" fill="{INK}"/>'
out('mohocrata_e',512,512,256,256,dm,shadow(256,470,140,28)+f'''<path d="M250 390Q190 410 170 348" stroke="{INK}" stroke-width="32" fill="none" stroke-linecap="round"/><path d="M250 390Q190 410 170 348" stroke="{MOHO}" stroke-width="20" fill="none" stroke-linecap="round"/>
<path d="M186 266Q168 400 190 462Q250 480 310 462Q350 400 336 266Z" fill="url(#st)" {ol(7)}/>{dots(23,200,330,300,450,12,MOHO2,3,8,.7)}
<path d="M270 370Q340 346 352 372Q350 430 278 432Z" fill="{INK}"/><path d="M286 376l10 22l10-26l12 24l12-28l12 18" fill="{HUES}" {ol(3)}/>
<g transform="translate(346 330)"><rect x="-6" y="-92" width="72" height="88" fill="{HUES}" {ol(6)}/><path d="M6 -70h48M6 -50h32" stroke="{MORA}" stroke-width="5"/></g>
<path d="M300 400Q372 390 374 330" stroke="{INK}" stroke-width="30" fill="none" stroke-linecap="round"/><path d="M300 400Q372 390 374 330" stroke="{MOHO}" stroke-width="18" fill="none" stroke-linecap="round"/>
<path d="M104 240Q256 300 408 240Q394 274 256 278Q118 274 104 240Z" fill="{MORA}" {ol(5)}/>{gill}{cap_hat()}{eye(300,306,36)}{eye(356,296,20,RESET)}''')
# DON RAMON
dr=lin('mono',RESET2 if 0 else RESET2,MORA)+rad('head',HIER,HIER2,.3,.2,1)+lin('mask',OBRA,BUTA)
BOOTS=f'<g {ol(8)}><path d="M178 440V496H240V440Z" fill="url(#mono)"/><path d="M276 440V496H338V440Z" fill="url(#mono)"/><path d="M160 520Q160 482 208 484Q248 484 250 520Z" fill="{OBRA}"/><path d="M266 520Q268 484 308 484Q356 482 356 520Z" fill="{OBRA}"/></g>'
out('don_ramon_n',512,560,256,280,dr,shadow(256,520,150,26)+BOOTS+f'''
<g fill="none" stroke-linecap="round"><path d="M134 262Q70 300 82 362" stroke="{INK}" stroke-width="34"/><path d="M380 262Q444 300 432 362" stroke="{INK}" stroke-width="34"/><path d="M134 262Q70 300 82 362" stroke="{RESET2}" stroke-width="20"/><path d="M380 262Q444 300 432 362" stroke="{RESET2}" stroke-width="20"/></g><circle cx="82" cy="366" r="26" fill="{HIER2}" {ol(6)}/><circle cx="432" cy="366" r="26" fill="{HIER2}" {ol(6)}/>
<path d="M136 230Q124 400 150 452H366Q392 400 380 230Q368 178 258 178Q146 178 136 230Z" fill="url(#mono)" {ol(8)}/>{scratches(41,170,250,360,430,16,RESET,2.5,.3)}
<path d="M186 188L330 396M326 188L182 396" stroke="{INK}" stroke-width="22"/><path d="M186 188L330 396M326 188L182 396" stroke="{OBRA}" stroke-width="11"/>
<path d="M136 398H378V428H136Z" fill="{OXID}" {ol(6)}/><rect x="176" y="384" width="56" height="64" rx="6" fill="{HIER}" {ol(6)}/><rect x="282" y="390" width="46" height="54" rx="6" fill="{BUTA}" {ol(6)}/>
<rect x="218" y="156" width="78" height="32" fill="{HIER2}" {ol(6)}/>
<path d="M136 120Q134 40 256 42Q378 40 376 120Q374 192 256 192Q138 192 136 120Z" fill="url(#head)" {ol(8)}/><g transform="rotate(-7 256 40)"><path d="M150 76Q148 0 256 -2Q364 0 362 76Q256 104 150 76Z" fill="url(#mask)" {ol(8)}/><path d="M172 72Q256 92 340 72" stroke="{INK}" stroke-width="12" fill="none"/></g>''')
out('don_ramon_e',512,560,256,280,dr,shadow(256,520,130,26)+f'''<g {ol(8)}><path d="M222 440V496H284V440Z" fill="url(#mono)"/><path d="M210 520Q212 484 262 484Q330 482 336 520Z" fill="{OBRA}"/></g>
<path d="M176 230Q166 400 188 452H330Q350 400 340 230Q330 178 258 178Q186 178 176 230Z" fill="url(#mono)" {ol(8)}/>
<path d="M300 188L296 300" stroke="{INK}" stroke-width="22"/><path d="M300 188L296 300" stroke="{OBRA}" stroke-width="11"/><path d="M226 300H338V388H226Z" fill="{RESET2}" {ol(6)}/>
<path d="M176 398H344V428H176Z" fill="{OXID}" {ol(6)}/><path d="M196 410h40v48h-40z" fill="{HUES}" {ol(5)}/>
{glow(424,300,22,OBRA)}<path d="M240 262Q300 340 400 310" stroke="{INK}" stroke-width="32" fill="none" stroke-linecap="round"/><path d="M240 262Q300 340 400 310" stroke="{HIER}" stroke-width="18" fill="none" stroke-linecap="round"/><path d="M396 322L440 302L432 282L392 296Z" fill="{HIER2}" {ol(6)}/><path d="M442 296l22-10M442 300l26 6M438 286l6-24" stroke="{OBRA}" stroke-width="5" stroke-linecap="round"/>
<rect x="222" y="156" width="70" height="32" fill="{HIER2}" {ol(6)}/>
<path d="M170 120Q168 40 268 42Q368 42 372 120Q376 192 268 192Q172 192 170 120Z" fill="url(#head)" {ol(8)}/><circle cx="330" cy="128" r="28" fill="{INK}"/><circle cx="330" cy="128" r="19" fill="{ACID}"/><circle cx="338" cy="130" r="8" fill="{INK}"/><path d="M300 122Q330 96 360 122L360 104Q330 84 300 104Z" fill="{HIER2}" {ol(5)}/>
<path d="M300 172Q350 150 396 168Q370 190 336 180Z" fill="{INK}"/><path d="M372 174l48 16" stroke="{INK}" stroke-width="12" stroke-linecap="round"/><path d="M372 174l44 14" stroke="{HUES}" stroke-width="6" stroke-linecap="round"/>
<g transform="rotate(-7 266 40)"><path d="M168 76Q166 0 266 -2Q368 0 372 72Q270 104 168 76Z" fill="url(#mask)" {ol(8)}/><path d="M300 36H372V70Q330 80 300 74Z" fill="{INK}"/><path d="M310 44H364V62Q336 68 310 64Z" fill="{RESET}" opacity=".7"/></g>''')
# DRON
dd=rad('a',HIER,HIER2)+rad('b',MULTA,MULTA2,.4,.4,.7)+lin('c',OBRA,BUTA)
def rotor(x,y): return f'<ellipse cx="{x}" cy="{y}" rx="46" ry="14" fill="{RESET}" opacity=".3"/><ellipse cx="{x}" cy="{y}" rx="42" ry="7" fill="{HUES}" {ol(3)}/><circle cx="{x}" cy="{y}" r="9" fill="{HIER2}" {ol(4)}/>'
FR=f'<g fill="none" stroke="{INK}" stroke-width="12" stroke-linecap="round"><path d="M112 124L64 86M208 124L256 86"/></g>{rotor(62,82)}{rotor(258,82)}'
out('dron_viejo_n',320,320,160,160,dd,shadow(160,288,86,16,.42)+FR+f'<ellipse cx="160" cy="158" rx="92" ry="74" fill="url(#a)" {ol(7)}/><rect x="112" y="118" width="96" height="74" rx="8" fill="{HIER2}" {ol(6)}/><path d="M124 138h72M124 156h72M124 174h72" stroke="{INK}" stroke-width="6"/>{rivets([(92,180),(232,172)])}<path d="M150 88V52" stroke="{INK}" stroke-width="5"/><circle cx="150" cy="46" r="9" fill="{ACID}" {ol(4)}/>')
out('dron_viejo_e',320,320,160,160,dd,shadow(160,288,86,16,.42)+FR+f'<ellipse cx="160" cy="158" rx="92" ry="74" fill="url(#a)" {ol(7)}/>{glow(214,166,30,MULTA)}<circle cx="214" cy="166" r="34" fill="{INK}"/><circle cx="214" cy="166" r="26" fill="url(#b)"/><circle cx="222" cy="168" r="11" fill="{INK}"/><path d="M92 110l34-14l10 26l-36 12z" fill="url(#c)" {ol(4)}/><path d="M150 88V52" stroke="{INK}" stroke-width="5"/><circle cx="150" cy="46" r="9" fill="{ACID}" {ol(4)}/>')
