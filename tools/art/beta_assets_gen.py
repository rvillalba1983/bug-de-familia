import random, os, sys
OUT=sys.argv[1]
# Paleta "Cuñado Radiactivo"
INK='#1B0E2A'; MORA='#3A1A5C'; BERE='#6A2BA8'; RESET='#00E5FF'; RESET2='#0A7FC2'; MULTA='#FF1F8F'; MULTA2='#A80F6B'
BUTA='#FF6A00'; OBRA='#FFD400'; ACID='#C6FF00'; MOHO='#2FBF71'; MOHO2='#14704F'; OXID='#A8482A'; OXID2='#6A2A20'
HIER='#8894B5'; HIER2='#4A5478'; HUES='#F6E7C8'; CARN='#FFB995'
def ol(w=6): return f'stroke="{INK}" stroke-width="{w}" stroke-linejoin="round" stroke-linecap="round"'
def rad(i,a,b,cx=.35,cy=.3,r=.85): return f'<radialGradient id="{i}" cx="{cx}" cy="{cy}" r="{r}"><stop offset="0" stop-color="{a}"/><stop offset="1" stop-color="{b}"/></radialGradient>'
def lin(i,a,b,x2=0,y2=1): return f'<linearGradient id="{i}" x1="0" y1="0" x2="{x2}" y2="{y2}"><stop offset="0" stop-color="{a}"/><stop offset="1" stop-color="{b}"/></linearGradient>'
def save(n,w,h,defs,body):
    open(f'{OUT}/{n}.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><defs>{defs}</defs>{body}</svg>\n')
def shadow(cx,cy,rx,ry,o=.5): return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{INK}" opacity="{o}"/>'
def glow(cx,cy,r,c): return ''.join(f'<circle cx="{cx}" cy="{cy}" r="{r*k}" fill="{c}" opacity="{o}"/>' for k,o in((2.2,.10),(1.6,.18)))
def rivets(pts,r=4,c=HUES): return ''.join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}" stroke="{INK}" stroke-width="2"/>' for x,y in pts)
def scratches(seed,x0,y0,x1,y1,n,c,w=2,o=.55):
    r=random.Random(seed);s=''
    for _ in range(n):
        x=r.uniform(x0,x1);y=r.uniform(y0,y1);dx=r.uniform(-16,16);dy=r.uniform(-6,6)
        s+=f'<path d="M{x:.0f} {y:.0f}l{dx:.0f} {dy:.0f}" stroke="{c}" stroke-width="{w}" stroke-linecap="round" opacity="{o}"/>'
    return s
def dots(seed,x0,y0,x1,y1,n,c,a=2,b=6,o=.8):
    r=random.Random(seed)
    return ''.join(f'<circle cx="{r.uniform(x0,x1):.0f}" cy="{r.uniform(y0,y1):.0f}" r="{r.uniform(a,b):.1f}" fill="{c}" opacity="{o}"/>' for _ in range(n))

# 1 MINA DE PETANCA (simple)
d=rad('a',HIER,MORA)+rad('b',MULTA,MULTA2)
save('01_mina_petanca',256,256,d,shadow(128,212,84,20)+f'''
<circle cx="128" cy="134" r="80" fill="url(#a)" {ol(7)}/>
<path d="M58 112Q128 66 198 112M50 142Q128 92 206 142M60 176Q128 128 196 176" fill="none" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
<path d="M54 127Q128 80 202 127" fill="none" stroke="{OBRA}" stroke-width="13"/>
<path d="M72 116l14-9 9 13-14 8zM112 96l15-3 4 15-15 3zM155 100l14 5-5 14-14-5z" fill="{INK}"/>
<ellipse cx="96" cy="88" rx="22" ry="11" transform="rotate(-28 96 88)" fill="{HUES}" opacity=".75"/>
{glow(134,60,14,MULTA)}<rect x="114" y="54" width="40" height="20" rx="6" fill="{HIER2}" {ol(5)}/>
<ellipse cx="134" cy="50" rx="19" ry="11" fill="url(#b)" {ol(5)}/><ellipse cx="128" cy="46" rx="6" ry="3" fill="{HUES}"/>
<path d="M90 170l10-12 10 12 10-12 10 12" fill="none" stroke="{RESET}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>
<circle cx="170" cy="160" r="13" fill="{OXID}" {ol(4)}/><circle cx="170" cy="160" r="5" fill="{INK}"/>''')

# 2 BOBINA (simple)
d=lin('a',BUTA,OXID2,1,0)+rad('b',RESET,RESET2)
tape=f'<path d="M186 176C232 186 236 222 200 226C170 229 160 212 136 222" fill="none" stroke="{INK}" stroke-width="9" stroke-linecap="round"/><path d="M186 176C232 186 236 222 200 226C170 229 160 212 136 222" fill="none" stroke="{MULTA}" stroke-width="3.5" stroke-linecap="round"/>'
wind=''.join(f'<path d="M56 {y}Q128 {y+30} 200 {y}" fill="none" stroke="{OBRA}" stroke-width="2" opacity=".5"/>' for y in range(118,172,8))
save('02_bobina',256,256,d,shadow(128,204,92,22)+tape+f'''
<path d="M42 170V190Q128 236 214 190V170Z" fill="{RESET2}" {ol(6)}/>
<ellipse cx="128" cy="170" rx="86" ry="36" fill="url(#b)" {ol(6)}/>
<path d="M58 100V168Q128 208 198 168V100Z" fill="url(#a)" {ol(6)}/>{wind}
<path d="M42 92V110Q128 152 214 110V92Z" fill="{RESET2}" {ol(6)}/>
<ellipse cx="128" cy="92" rx="86" ry="38" fill="url(#b)" {ol(6)}/>
<ellipse cx="128" cy="92" rx="52" ry="22" fill="{MORA}" {ol(4)}/>
<ellipse cx="128" cy="90" rx="24" ry="11" fill="{HUES}" {ol(4)}/><ellipse cx="128" cy="90" rx="8" ry="4" fill="{INK}"/>
<path d="M60 76Q84 60 112 58" fill="none" stroke="{HUES}" stroke-width="5" stroke-linecap="round" opacity=".8"/>
<path d="M150 130q30 2 38 -8l6 34q-20 16 -44 14z" fill="{HUES}" {ol(4)}/><path d="M158 142l22-5M158 154l18-4" stroke="{MULTA}" stroke-width="4" stroke-linecap="round"/>
<g fill="{MOHO}" {ol(3)}><ellipse cx="66" cy="140" rx="11" ry="7"/><ellipse cx="82" cy="154" rx="7" ry="5"/></g>''')

# 3 CARTEL TIERRA DE NADIE (simple)
d=lin('a',OBRA,BUTA)+lin('b',OXID,OXID2,1,0)
save('03_cartel_tierra_de_nadie',256,256,d,shadow(112,226,56,12)+f'''
<path d="M108 226L120 122L136 122L128 226Z" fill="url(#b)" {ol(6)}/>
<g transform="rotate(-9 128 90)"><path d="M128 14L216 96L128 178L40 96Z" fill="url(#a)" {ol(7)}/>
<path d="M128 30L198 96L128 162L58 96Z" fill="none" stroke="{INK}" stroke-width="5"/>
<path d="M128 56L140 76L164 66L154 90L178 98L154 108L162 132L140 120L128 142L116 120L94 132L102 108L78 98L102 90L92 66L116 76Z" fill="{MULTA}" {ol(4)}/>
<circle cx="128" cy="100" r="17" fill="{INK}"/><circle cx="122" cy="94" r="4" fill="{RESET}"/>
<path d="M170 56q12-8 22-2l-6 12q10 2 8 10l-26-2q-4-10 2-18z" fill="{HUES}" {ol(3)}/>
<circle cx="84" cy="66" r="5" fill="{INK}"/><circle cx="178" cy="124" r="4" fill="{INK}"/><circle cx="100" cy="150" r="3" fill="{INK}"/></g>
<g {ol(4)}><path d="M88 228q-2-22 18-20q16 2 16 20z" fill="{MOHO2}"/><ellipse cx="100" cy="204" rx="22" ry="11" fill="{MULTA}"/></g>
{dots(4,86,198,116,208,5,ACID,2,3,1)}''')

# 4 DRON VIEJO (medio)
d=rad('a',HIER,HIER2)+rad('b',MULTA,MULTA2,.4,.4,.7)+lin('c',OBRA,BUTA)
def rotor(x,y,bent=False):
    t=' transform="rotate(28 %d %d)"'%(x,y) if bent else ''
    return f'<g{t}><ellipse cx="{x}" cy="{y}" rx="46" ry="14" fill="{RESET}" opacity=".3"/><ellipse cx="{x}" cy="{y}" rx="42" ry="7" fill="{HUES}" {ol(3)}/><circle cx="{x}" cy="{y}" r="9" fill="{HIER2}" {ol(4)}/></g>'
save('04_dron_viejo',320,320,d,shadow(160,288,86,16,.42)+f'''
<g fill="none" stroke="{INK}" stroke-width="12" stroke-linecap="round"><path d="M112 124L64 86M208 124L256 86M108 190L60 214"/></g>
<g fill="none" stroke="{HIER}" stroke-width="6" stroke-linecap="round"><path d="M112 124L64 86M208 124L256 86M108 190L60 214"/></g>
{rotor(62,82)}{rotor(258,82)}{rotor(56,216,True)}
<path d="M202 198q34 16 28 44q-6 18 -22 14" fill="none" stroke="{INK}" stroke-width="7" stroke-linecap="round"/><path d="M208 256l-10-8M208 256l4-13" stroke="{RESET}" stroke-width="4" stroke-linecap="round"/>
<ellipse cx="160" cy="158" rx="92" ry="74" fill="url(#a)" {ol(7)}/>
<path d="M78 176Q160 244 242 176Q226 228 160 232Q94 228 78 176Z" fill="{HIER2}"/>
<path d="M190 96l38 24l-14 26l-40-22z" fill="url(#c)" {ol(4)}/><path d="M196 110l20 12" stroke="{INK}" stroke-width="3"/>
<path d="M96 104q30-26 62-26" fill="none" stroke="{HUES}" stroke-width="6" stroke-linecap="round" opacity=".7"/>
{glow(148,166,40,MULTA)}<circle cx="148" cy="166" r="42" fill="{INK}"/><circle cx="148" cy="166" r="33" fill="url(#b)"/>
<circle cx="152" cy="170" r="14" fill="{INK}"/><circle cx="136" cy="152" r="8" fill="{HUES}"/>
<path d="M104 136L194 124" stroke="{INK}" stroke-width="10" stroke-linecap="round"/>
{rivets([(92,180),(232,172),(170,222),(112,214)])}
<path d="M150 88V52" stroke="{INK}" stroke-width="5"/>{glow(150,46,8,ACID)}<circle cx="150" cy="46" r="9" fill="{ACID}" {ol(4)}/>''')

# 5 URNA DE ESPORAS (medio)
d=lin('a',OXID,OXID2,1,1)+lin('b',HIER,HIER2)+rad('c',ACID,MOHO)
papers=''.join(f'<path d="M{x} {y}l22-7l6 18l-22 7z" fill="{HUES}" {ol(3)} transform="rotate({r} {x} {y})"/>' for x,y,r in((28,256,-14),(272,262,20),(286,214,-30)))
sp=dots(9,100,14,230,92,20,ACID,3,8,.8)+dots(10,120,30,210,80,10,HUES,2,4,.9)
save('05_urna_esporas',320,320,d,shadow(160,288,118,22)+papers+f'''
<path d="M74 120L246 120L262 276L58 276Z" fill="url(#a)" {ol(7)}/>
<path d="M74 120L120 120L108 276L58 276Z" fill="{OXID}" opacity=".6"/>
{scratches(5,76,150,244,262,14,HUES,2,.35)}
<path d="M64 110L256 110L274 136L46 136Z" fill="url(#b)" {ol(7)}/>
<path d="M92 98L228 98L256 116L64 116Z" fill="{HIER}" {ol(6)}/>
<path d="M112 106H208" stroke="{INK}" stroke-width="14" stroke-linecap="round"/>
<path d="M118 102l10 10l10-10l10 10l10-10l10 10l10-10l10 10l10-10" fill="none" stroke="{HUES}" stroke-width="5" stroke-linejoin="round"/>
{sp}
<g {ol(5)}>{''.join(f'<circle cx="{x}" cy="176" r="20" fill="{c}"/>' for x,c in((104,ACID),(160,ACID),(216,MORA)))}</g>
<ellipse cx="98" cy="170" rx="6" ry="4" fill="{HUES}"/><ellipse cx="154" cy="170" rx="6" ry="4" fill="{HUES}"/>
<path d="M210 170l12 12M222 170l-12 12" stroke="{INK}" stroke-width="4" stroke-linecap="round"/>
<g {ol(5)}><path d="M58 276Q50 226 86 214Q118 212 124 276Z" fill="url(#c)"/><ellipse cx="82" cy="206" rx="34" ry="19" fill="{MULTA}"/>
<path d="M226 276Q226 240 246 234Q272 238 266 276Z" fill="url(#c)"/><ellipse cx="248" cy="226" rx="26" ry="14" fill="{MULTA}"/></g>
<circle cx="72" cy="240" r="7" fill="{OBRA}" {ol(3)}/><circle cx="73" cy="240" r="2.5" fill="{INK}"/><circle cx="96" cy="246" r="10" fill="{OBRA}" {ol(3)}/><circle cx="94" cy="246" r="3.5" fill="{INK}"/>
{dots(12,62,198,106,206,6,HUES,2,4,1)}{dots(13,232,220,264,230,4,HUES,2,3,1)}''')

# 6 MOHOCRATA
d=rad('cap',MULTA,MULTA2,.35,.25,.9)+lin('st',ACID,MOHO2)+rad('hat',BUTA,OXID2,.3,.2,1)+rad('mini',BUTA,MULTA2)
def eye(x,y,r,c=OBRA,lid=False):
    s=f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}" {ol(4)}/><ellipse cx="{x+r*.2:.0f}" cy="{y+r*.1:.0f}" rx="{r*.28:.1f}" ry="{r*.7:.1f}" fill="{INK}"/><circle cx="{x-r*.3:.0f}" cy="{y-r*.4:.0f}" r="{r*.2:.1f}" fill="#fff"/>'
    if lid: s+=f'<path d="M{x-r-3} {y-r*.15:.0f}Q{x} {y-r*1.5:.0f} {x+r+3} {y-r*.15:.0f}Z" fill="{MULTA2}" {ol(4)}/>'
    return s
gills=''.join(f'<path d="M{x} 226Q{256+(x-256)*.8:.0f} 262 {256+(x-256)*.55:.0f} 286" stroke="{MULTA2}" stroke-width="4" fill="none"/>' for x in range(112,412,22))
caps=''.join(f'<ellipse cx="{x}" cy="{y}" rx="{a}" ry="{b}" fill="{c}" transform="rotate({r} {x} {y})"/>' for x,y,a,b,r,c in((150,172,26,15,-24,HUES),(216,124,20,11,-8,ACID),(346,160,30,17,22,HUES),(280,196,22,12,0,ACID),(112,214,13,8,-20,ACID),(398,214,14,8,20,ACID)))
save('06_mohocrata',512,512,d,shadow(256,470,158,28)+f'''
<g fill="none" stroke-linecap="round"><path d="M180 396Q108 410 88 346" stroke="{INK}" stroke-width="34"/><path d="M336 388Q424 392 438 322" stroke="{INK}" stroke-width="34"/>
<path d="M180 396Q108 410 88 346" stroke="{MOHO}" stroke-width="22"/><path d="M336 388Q424 392 438 322" stroke="{MOHO}" stroke-width="22"/></g>
<g {ol(5)}><path d="M64 348l-14-30l18 12l6-26l12 24l18-16l-6 34z" fill="{ACID}"/></g>
<g transform="rotate(10 438 280)"><path d="M396 228L482 222L490 306L404 314Z" fill="{HUES}" {ol(6)}/><path d="M416 250l50-4M418 272l32-3" stroke="{MORA}" stroke-width="5" stroke-linecap="round"/><path d="M438 296l10 10l22-26" fill="none" stroke="{MULTA}" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/></g>
<path d="M430 322l-10-20l14 8l6-18l10 18l12-10l-6 26z" fill="{ACID}" {ol(5)}/>
<g {ol(7)}><path d="M170 266Q152 400 168 462Q214 480 256 464Q300 480 346 462Q362 400 342 266Z" fill="url(#st)"/></g>
<path d="M170 300Q156 400 168 462Q190 472 210 472Q186 380 194 280Z" fill="{MOHO2}" opacity=".55"/>
{dots(21,190,340,330,450,14,MOHO2,3,8,.7)}
<path d="M196 366Q256 322 318 366Q318 432 258 432Q196 432 196 366Z" fill="{INK}"/>
<path d="M208 366l14 22l12-30l16 28l12-32l14 34l12-28l14 18z" fill="{HUES}" {ol(3)}/>
<path d="M226 424l10-18l10 18l12-22l10 22l12-18l8 14" fill="{HUES}" {ol(3)}/>
<path d="M232 430Q258 406 288 430Q258 440 232 430Z" fill="{MULTA}"/>
<g {ol(8)}><path d="M86 226Q84 124 256 110Q432 124 430 226Q420 268 256 268Q92 268 86 226Z" fill="url(#cap)"/></g>
<path d="M98 232Q256 296 418 232Q394 276 256 278Q118 276 98 232Z" fill="{MORA}" {ol(5)}/>{gills}
{caps}
{eye(172,300,27)}{eye(246,306,40,OBRA)}{eye(322,298,22,RESET)}{eye(376,262,12,OBRA)}
<g transform="rotate(-9 256 96)">
<path d="M160 118L176 42Q256 22 336 42L352 118Q256 148 160 118Z" fill="url(#hat)" {ol(7)}/>
<path d="M136 112Q256 174 376 112L386 134Q256 196 126 134Z" fill="{HIER}" {ol(7)}/>
<path d="M176 42Q256 22 336 42Q330 64 256 66Q182 64 176 42Z" fill="{HIER2}" {ol(5)}/>
{dots(22,190,74,322,118,16,INK,2,4,.9)}{rivets([(162,132),(216,150),(296,150),(350,132)],5,OBRA)}
<path d="M196 92q30 12 54 2" stroke="{HUES}" stroke-width="5" fill="none" stroke-linecap="round" opacity=".6"/>
<path d="M346 50q34-18 54-2" stroke="{INK}" stroke-width="13" stroke-linecap="round" fill="none"/><ellipse cx="412" cy="46" rx="24" ry="13" fill="{HIER}" {ol(6)}/></g>
<g {ol(5)}><path d="M112 148Q106 110 126 106Q146 112 138 150Z" fill="{ACID}"/><ellipse cx="124" cy="98" rx="29" ry="19" fill="url(#mini)"/></g>
<circle cx="116" cy="130" r="7" fill="{OBRA}" {ol(3)}/><circle cx="133" cy="128" r="5" fill="{OBRA}" {ol(3)}/>
{dots(23,110,86,144,96,5,HUES,2,4,1)}''')

# 7 JUBILADO DE HIERRO
d=rad('a',HIER,HIER2,.3,.2,1)+rad('b',HUES,HIER,.3,.2,1)+lin('c',BUTA,OXID2)+rad('mine',HIER,MORA)
save('07_jubilado_hierro',512,512,d,shadow(256,474,162,26)+f'''
<g {ol(7)}><path d="M178 400V446H232V400Z" fill="{HIER2}"/><path d="M286 400V446H340V400Z" fill="{HIER2}"/></g>
<g {ol(7)}><path d="M150 466Q150 432 196 432Q244 432 244 466Q196 486 150 466Z" fill="{MULTA}"/><path d="M272 466Q272 432 318 432Q366 432 366 466Q318 486 272 466Z" fill="{MULTA}"/></g>
<path d="M162 448Q198 430 234 448M284 448Q320 430 356 448" stroke="{HUES}" stroke-width="7" fill="none" stroke-linecap="round"/>
<circle cx="198" cy="436" r="12" fill="{OBRA}" {ol(4)}/><circle cx="320" cy="436" r="12" fill="{OBRA}" {ol(4)}/>
<path d="M420 260L428 472" stroke="{INK}" stroke-width="18" stroke-linecap="round"/><path d="M420 260L428 472" stroke="{OBRA}" stroke-width="9" stroke-linecap="round"/><path d="M392 262Q396 222 430 228Q452 234 450 262" stroke="{INK}" stroke-width="18" fill="none" stroke-linecap="round"/><path d="M392 262Q396 222 430 228Q452 234 450 262" stroke="{OBRA}" stroke-width="9" fill="none" stroke-linecap="round"/>
<g fill="none" stroke-linecap="round"><path d="M136 274Q92 310 104 356" stroke="{INK}" stroke-width="30"/><path d="M380 272Q422 284 424 266" stroke="{INK}" stroke-width="30"/>
<path d="M136 274Q92 310 104 356" stroke="{HIER}" stroke-width="18" stroke-dasharray="10 8"/><path d="M380 272Q422 284 424 266" stroke="{HIER}" stroke-width="18" stroke-dasharray="10 8"/></g>
<g><circle cx="104" cy="398" r="46" fill="url(#mine)" {ol(7)}/><path d="M64 380Q104 352 146 380M60 402Q104 374 150 402" stroke="{INK}" stroke-width="4" fill="none"/><path d="M62 391Q104 362 148 391" stroke="{OBRA}" stroke-width="8" fill="none"/>{glow(108,352,8,MULTA)}<rect x="96" y="344" width="24" height="12" rx="3" fill="{MULTA}" {ol(4)}/></g>
<g {ol(6)}><path d="M78 358q4-20 22-18q22-6 32 10l-6 16l-46 0z" fill="{HIER2}"/></g>
<circle cx="426" cy="256" r="22" fill="{HIER2}" {ol(6)}/>
<path d="M132 240Q124 410 256 416Q392 410 384 240Q372 170 258 170Q140 170 132 240Z" fill="url(#a)" {ol(8)}/>
<path d="M134 280Q136 408 256 416Q214 396 196 330Q180 280 188 196Q136 210 134 280Z" fill="{HIER2}"/>
{scratches(31,160,240,366,400,22,HUES,2.5,.35)}
<path d="M292 200l78 22l6 60l-62 44l-42-40z" fill="url(#c)" {ol(5)}/><path d="M308 220l44 14l2 36l-34 24l-20-22z" fill="{OXID}"/>{dots(33,306,226,352,292,10,OBRA,2,4,.6)}
<circle cx="238" cy="312" r="54" fill="{HUES}" {ol(7)}/><circle cx="238" cy="312" r="42" fill="#fff" {ol(3)}/>
<path d="M238 312L262 288" stroke="{MULTA}" stroke-width="8" stroke-linecap="round"/><path d="M238 312L216 330" stroke="{INK}" stroke-width="6" stroke-linecap="round"/><circle cx="238" cy="312" r="7" fill="{INK}"/>
<path d="M238 276v9M202 312h9M238 348v-9M274 312h-9" stroke="{INK}" stroke-width="5"/>
{rivets([(150,256),(166,352),(206,398),(310,394),(366,342)],6,HUES)}
<path d="M308 342l34 8l-4 36l-34-6z" fill="{HUES}" {ol(4)}/><path d="M316 350l18 34M334 354l-20 28" stroke="{MULTA}" stroke-width="5"/>
<rect x="218" y="154" width="84" height="34" fill="{HIER2}" {ol(6)}/>
<path d="M116 118Q116 44 256 44Q398 44 398 118Q398 196 256 196Q116 196 116 118Z" fill="url(#b)" {ol(8)}/>
<path d="M120 138Q152 196 256 196Q362 196 394 138Q342 170 256 170Q172 170 120 138Z" fill="{HIER}"/>
<circle cx="192" cy="122" r="29" fill="{INK}"/><circle cx="192" cy="122" r="19" fill="{BUTA}"/><circle cx="196" cy="126" r="7" fill="{INK}"/><circle cx="185" cy="115" r="5" fill="{HUES}"/>
{glow(318,118,40,RESET)}<circle cx="318" cy="118" r="44" fill="{INK}"/><circle cx="318" cy="118" r="34" fill="{RESET}"/><circle cx="318" cy="118" r="16" fill="{INK}"/><circle cx="304" cy="102" r="9" fill="#fff"/>
<path d="M336 82L290 150" stroke="{HUES}" stroke-width="4"/>
<path d="M160 92Q192 74 224 100" fill="none" stroke="{INK}" stroke-width="15" stroke-linecap="round"/><path d="M280 106Q316 56 362 84" fill="none" stroke="{INK}" stroke-width="15" stroke-linecap="round"/>
<path d="M196 164Q226 136 256 158Q290 136 322 166Q300 182 256 172Q218 182 196 164Z" fill="{HUES}" {ol(5)}/>
<path d="M210 160l-4 12M226 152l-3 16M286 152l3 16M304 160l4 12" stroke="{HIER}" stroke-width="3"/>
<g transform="rotate(-6 256 60)"><ellipse cx="256" cy="58" rx="132" ry="40" fill="{MORA}" {ol(8)}/><ellipse cx="230" cy="46" rx="74" ry="18" fill="{BERE}"/><path d="M256 20q2-20 18-22" stroke="{INK}" stroke-width="9" fill="none" stroke-linecap="round"/></g>''')

# 8 DON RAMON
d=lin('mono',RESET2,MORA)+rad('head',HIER,HIER2,.3,.2,1)+lin('mask',OBRA,BUTA)
sparks=''.join(f'<path d="M{x} {y}l{a} {b}" stroke="{c}" stroke-width="5" stroke-linecap="round"/>' for x,y,a,b,c in((448,204,20,-24,OBRA),(452,216,30,-4,ACID),(444,190,4,-30,HUES),(432,196,-16,-22,OBRA),(456,228,22,14,BUTA)))
keys=''.join(f'<g transform="rotate({r} 332 372)"><path d="M332 372v36" stroke="{INK}" stroke-width="9" stroke-linecap="round"/><path d="M332 372v36" stroke="{OBRA}" stroke-width="4"/><path d="M332 400h10M332 408h7" stroke="{OBRA}" stroke-width="4"/></g>' for r in(-30,-8,16,38))
save('08_don_ramon',512,560,d,shadow(256,520,150,26)+f'''
<g {ol(8)}><path d="M178 440V496H240V440Z" fill="url(#mono)"/><path d="M276 440V496H338V440Z" fill="url(#mono)"/></g>
<g {ol(8)}><path d="M160 520Q160 482 208 484Q248 484 250 520Z" fill="{OBRA}"/><path d="M266 520Q268 484 308 484Q356 482 356 520Z" fill="{OBRA}"/></g>
<path d="M172 506H240M276 506H344" stroke="{INK}" stroke-width="5"/>
<g fill="none" stroke-linecap="round"><path d="M134 262Q70 300 82 362" stroke="{INK}" stroke-width="34"/><path d="M380 260Q440 248 434 214" stroke="{INK}" stroke-width="34"/>
<path d="M134 262Q70 300 82 362" stroke="{RESET2}" stroke-width="20"/><path d="M380 260Q440 248 434 214" stroke="{HIER}" stroke-width="20"/></g>
{glow(446,204,24,OBRA)}{sparks}
<path d="M412 214L448 202L440 182L408 192Z" fill="{HIER2}" {ol(6)}/><path d="M440 188L462 196" stroke="{INK}" stroke-width="8"/><circle cx="426" cy="222" r="22" fill="{HIER}" {ol(6)}/>
<g transform="rotate(-24 82 400)"><rect x="70" y="372" width="24" height="96" rx="5" fill="{HIER}" {ol(6)}/><path d="M50 372Q50 334 76 334V362H90V334Q116 334 114 372Q106 396 82 396Q58 396 50 372Z" fill="{HIER}" {ol(6)}/><circle cx="82" cy="448" r="6" fill="{INK}"/></g>
<circle cx="82" cy="366" r="26" fill="{HIER2}" {ol(6)}/>
<path d="M136 230Q124 400 150 452H366Q392 400 380 230Q368 178 258 178Q146 178 136 230Z" fill="url(#mono)" {ol(8)}/>
<path d="M136 230Q126 400 150 452H204Q180 330 194 188Q144 196 136 230Z" fill="{MORA}"/>
{scratches(41,170,250,360,430,16,RESET,2.5,.3)}
<path d="M186 188L176 300H334L326 188" fill="none" stroke="{INK}" stroke-width="22"/><path d="M186 188L176 300H334L326 188" fill="none" stroke="{OBRA}" stroke-width="11"/>
<path d="M176 300H334V388H176Z" fill="{RESET2}" {ol(6)}/><path d="M196 322H314V372H196Z" fill="{MORA}" {ol(4)}/>
<path d="M214 320V290h16v30M286 322v-38M278 284h16" fill="none" stroke="{INK}" stroke-width="9"/><path d="M214 320V290h16v30" fill="{HUES}"/><path d="M286 322v-38M278 284h16" fill="none" stroke="{HIER}" stroke-width="5"/>
<path d="M226 336l6 16l10-22l10 26l10-30l10 26l8-16" fill="none" stroke="{ACID}" stroke-width="5" stroke-linejoin="round" stroke-linecap="round"/>
<path d="M136 398H378V428H136Z" fill="{OXID}" {ol(6)}/><rect x="236" y="392" width="44" height="42" rx="5" fill="{OBRA}" {ol(6)}/><rect x="247" y="403" width="22" height="20" fill="{INK}"/>
<circle cx="332" cy="372" r="10" fill="none" stroke="{INK}" stroke-width="5"/>{keys}
<path d="M146 410h40v48h-40z" fill="{HUES}" {ol(5)}/><path d="M154 424h24M154 436h24M154 448h14" stroke="{MULTA}" stroke-width="4"/>
<rect x="218" y="156" width="78" height="32" fill="{HIER2}" {ol(6)}/>
<path d="M136 120Q134 40 256 42Q378 40 376 120Q374 192 256 192Q138 192 136 120Z" fill="url(#head)" {ol(8)}/>
<circle cx="200" cy="128" r="30" fill="{INK}"/><circle cx="200" cy="128" r="21" fill="{ACID}"/><circle cx="204" cy="132" r="8" fill="{INK}"/><path d="M170 118Q200 92 232 118L232 106Q200 84 170 106Z" fill="{HIER2}" {ol(5)}/>
<circle cx="312" cy="128" r="30" fill="{INK}"/><circle cx="312" cy="128" r="21" fill="{ACID}"/><circle cx="308" cy="132" r="8" fill="{INK}"/><path d="M282 122Q312 96 342 122L342 104Q312 82 282 104Z" fill="{HIER2}" {ol(5)}/>
<path d="M196 170Q254 140 318 170Q286 192 256 178Q226 192 196 170Z" fill="{INK}"/><path d="M212 172l6-14M232 168l2-16M280 168l-2-16M300 172l-6-14" stroke="{HIER}" stroke-width="4"/>
<path d="M286 176l52 16" stroke="{INK}" stroke-width="13" stroke-linecap="round"/><path d="M286 176l48 14" stroke="{HUES}" stroke-width="6" stroke-linecap="round"/><circle cx="340" cy="192" r="6" fill="{BUTA}"/>
<path d="M348 182q12-14 2-26q-8-12 6-26" stroke="{HIER}" stroke-width="5" fill="none" stroke-linecap="round" opacity=".7"/>
<g transform="rotate(-7 256 40)"><path d="M150 76Q148 0 256 -2Q364 0 362 76Q256 104 150 76Z" fill="url(#mask)" {ol(8)}/>
<path d="M200 36H312V70Q256 82 200 70Z" fill="{INK}"/><path d="M212 44H300V62Q256 70 212 62Z" fill="{RESET}" opacity=".7"/>
<path d="M216 48l30-2" stroke="#fff" stroke-width="5" stroke-linecap="round"/>
{rivets([(166,62),(346,62)],7,HIER)}</g>''')

# 9 CENTRALITA
d=lin('wall',HIER2,MORA)+lin('roof',BERE,MORA)+lin('door',OBRA,BUTA)+rad('scr',RESET,RESET2)+lin('leaf',MOHO,MOHO2)
W,H=960,800
cables=''.join(f'<path d="M{a} {b}C{a+30} {b+c} {e-30} {f+c} {e} {f}" fill="none" stroke="{INK}" stroke-width="10" stroke-linecap="round"/><path d="M{a} {b}C{a+30} {b+c} {e-30} {f+c} {e} {f}" fill="none" stroke="{col}" stroke-width="4" stroke-linecap="round"/>' for a,b,c,e,f,col in((230,330,70,420,345,MULTA),(420,345,100,620,330,OBRA),(620,330,80,790,352,RESET),(320,338,120,510,342,ACID)))
jacks=''.join(f'<circle cx="{x}" cy="{y}" r="9" fill="{INK}"/><circle cx="{x}" cy="{y}" r="4" fill="{c}"/>' for x,y,c in[(x,y,random.Random(x*y).choice([OBRA,MULTA,RESET,HIER])) for x in range(118,332,28) for y in range(452,540,30)])
bushes=''.join(f'<g {ol(6)}><circle cx="{x}" cy="{y}" r="{r}" fill="url(#leaf)"/><circle cx="{x+r*.8:.0f}" cy="{y+8}" r="{r*.7:.0f}" fill="url(#leaf)"/><circle cx="{x-r*.8:.0f}" cy="{y+10}" r="{r*.6:.0f}" fill="url(#leaf)"/></g>' for x,y,r in((104,726,48),(850,724,50),(620,760,30)))
crack=f'M676 420L650 468L690 502L654 548L694 590L668 640'
bricks=''.join(f'<rect x="{x+(i%2)*26}" y="{y}" width="46" height="20" fill="{HIER2 if (x+y)%3 else MORA}" opacity=".85"/>' for i,y in enumerate(range(384,650,27)) for x in range(556,800,56))
save('09_centralita_contestador',W,H,d,shadow(480,742,440,48,.55)+f'''
<path d="M84 720V340H876V720Z" fill="url(#wall)" {ol(10)}/>
{bricks}
{scratches(55,100,370,860,700,50,HUES,3,.22)}
<path d="M84 60H876L916 340H44Z" fill="url(#roof)" {ol(10)}/>
<path d="M124 60L92 340M208 60L190 340M296 60L290 340M384 60L382 340M472 60L474 340M560 60L568 340M650 60L664 340M738 60L758 340M824 60L850 340" stroke="{INK}" stroke-width="5" opacity=".65"/>
<path d="M36 334H924V372H36Z" fill="{HIER}" {ol(9)}/>{rivets([(70+x*82,353) for x in range(11)],6,OBRA)}
{cables}
<g transform="translate(0 -6)"><path d="M180 262Q180 212 480 212Q780 212 780 262L792 288Q480 324 168 288Z" fill="{INK}" opacity=".55"/>
<path d="M210 244L252 150H708L750 244Q480 282 210 244Z" fill="{MORA}" {ol(9)}/><path d="M252 150H708L730 196H230Z" fill="{BERE}"/>
<g fill="{HUES}" {ol(6)}><rect x="316" y="166" width="58" height="44" rx="6"/><rect x="451" y="166" width="58" height="44" rx="6"/><rect x="586" y="166" width="58" height="44" rx="6"/></g>
<g fill="{INK}">{''.join(f'<circle cx="{x}" cy="188" r="11"/>' for x in(345,480,615))}</g>
<path d="M162 118Q150 34 480 34Q810 34 798 118L796 158Q700 170 660 148L654 110Q480 90 306 110L300 148Q260 170 164 158Z" fill="{MULTA}" {ol(10)}/>
<path d="M186 84Q240 56 400 54" stroke="{HUES}" stroke-width="11" fill="none" stroke-linecap="round" opacity=".75"/>
<path d="M200 150q40 8 82 2M680 152q40 8 92-2" stroke="{MULTA2}" stroke-width="9" fill="none" stroke-linecap="round"/></g>
{glow(832,150,28,MULTA)}<path d="M832 280V178" stroke="{INK}" stroke-width="12"/><circle cx="832" cy="150" r="30" fill="{MULTA}" {ol(8)}/><circle cx="822" cy="140" r="9" fill="{HUES}"/>
<path d="M70 330V260h60v70" fill="{OXID}" {ol(7)}/><path d="M60 260h80" stroke="{INK}" stroke-width="16" stroke-linecap="round"/>{dots(50,66,190,132,250,8,HIER,8,16,.45)}
<rect x="96" y="426" width="256" height="136" fill="{OXID2}" {ol(8)}/>{jacks}
<path d="M112 590H336V684H112Z" fill="{HIER2}" {ol(7)}/><path d="M112 610H336M112 632H336M112 654H336" stroke="{INK}" stroke-width="10"/>
<path d="M336 684L312 690L300 676" stroke="{OBRA}" stroke-width="8" fill="none" stroke-linecap="round"/><path d="M112 590l60 30" stroke="{HUES}" stroke-width="5" opacity=".5"/>
<path d="M382 420H546V720H382Z" fill="{INK}"/><path d="M394 432H534V720H394Z" fill="url(#door)" {ol(7)}/>
<path d="M394 500L534 560M394 572L534 632M394 644L534 704M394 432L534 492" stroke="{INK}" stroke-width="18"/>
<circle cx="464" cy="566" r="50" fill="{HIER}" {ol(8)}/><circle cx="464" cy="566" r="31" fill="{HIER2}" {ol(5)}/><path d="M464 526V606M424 566H504M436 538L492 594M492 538L436 594" stroke="{INK}" stroke-width="7"/>
<path d="{crack}" fill="none" stroke="{INK}" stroke-width="16" stroke-linejoin="round" stroke-linecap="round"/><path d="{crack}" fill="none" stroke="{ACID}" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>
<path d="M650 468l-36 8M690 502l40-14M654 548l-40 16M694 590l42 8" stroke="{INK}" stroke-width="8" stroke-linecap="round"/>
<rect x="780" y="440" width="76" height="124" rx="6" fill="{HIER}" {ol(8)}/><rect x="794" y="454" width="48" height="30" fill="url(#scr)" {ol(4)}/>
{''.join(f'<rect x="{794+x*17}" y="{496+y*19}" width="13" height="14" rx="2" fill="{HUES}" {ol(2)}/>' for x in range(3) for y in range(3))}
<path d="M84 720H876V738H84Z" fill="{MORA}" {ol(8)}/>
<g fill="none" stroke-linecap="round"><path d="M892 340Q860 420 884 480Q850 540 876 620" stroke="{INK}" stroke-width="13"/><path d="M892 340Q860 420 884 480Q850 540 876 620" stroke="{MOHO}" stroke-width="6"/></g>
<g {ol(4)} fill="url(#leaf)"><ellipse cx="868" cy="420" rx="18" ry="9" transform="rotate(30 868 420)"/><ellipse cx="880" cy="500" rx="20" ry="9" transform="rotate(-25 880 500)"/><ellipse cx="862" cy="560" rx="17" ry="8" transform="rotate(20 862 560)"/></g>
{bushes}''')

# 10 DEPOSITO MOHOCRATA
d=rad('cap',MULTA,MULTA2,.35,.2,.95)+lin('st',ACID,MOHO2)+lin('door',OXID,OXID2)+rad('win',ACID,MOHO)+rad('hub',HIER,HIER2)+rad('coil',BUTA,OXID2)
r=random.Random(77)
plates=''
for x,y,w,h,c,rot in((170,250,150,80,OXID,-22),(330,160,160,90,HIER2,-8),(500,140,170,90,OXID2,5),(675,212,140,90,HIER,20),(400,290,180,74,OXID,-2),(250,110,0,0,OXID,0)):
    if not w: continue
    pass
platesd=''.join(f'<g transform="rotate({rt} {x} {y})"><rect x="{x-w/2}" y="{y-h/2}" width="{w}" height="{h}" rx="5" fill="{c}" {ol(7)}/><path d="M{x-w/2+14} {y-h/2+14}h{w-28}" stroke="{HUES}" stroke-width="4" opacity=".45"/>{rivets([(x-w/2+12,y+h/2-12),(x+w/2-12,y+h/2-12),(x+w/2-12,y-h/2+12)],5,OBRA)}</g>' for x,y,w,h,c,rt in((190,290,150,76,OXID,-26),(342,186,168,84,HIER2,-9),(530,172,178,84,OXID2,6),(722,274,146,80,HIER,24),(460,296,190,68,OXID,-2)))
spores=dots(60,560,8,780,120,30,ACID,3,9,.75)+dots(61,590,20,750,100,14,HUES,2,5,.9)
win=lambda x,y,r: f'<g>{glow(x,y,r,ACID)}<circle cx="{x}" cy="{y}" r="{r+9}" fill="{HIER2}" {ol(7)}/><circle cx="{x}" cy="{y}" r="{r}" fill="url(#win)"/><path d="M{x-r} {y}H{x+r}M{x} {y-r}V{y+r}" stroke="{INK}" stroke-width="5"/></g>'
cagebars=''.join(f'<path d="M{x} 520V690" stroke="{INK}" stroke-width="11"/><path d="M{x} 520V690" stroke="{HIER}" stroke-width="4"/>' for x in range(746,900,30))
bu=''.join(f'<g {ol(6)}><path d="M{x-14} {y+52}Q{x-22} {y} {x} {y-6}Q{x+22} {y} {x+14} {y+52}Z" fill="url(#st)"/><ellipse cx="{x}" cy="{y-10}" rx="{a}" ry="{a*.52:.0f}" fill="url(#cap)"/></g>' for x,y,a in((80,640,44),(150,674,30),(924,676,34)))
save('10_deposito_mohocrata',W,H,d,shadow(480,748,420,46,.55)+spores+f'''
<g {ol(9)}><path d="M640 182Q626 80 664 70L720 74Q742 108 722 196Z" fill="{HIER2}"/><ellipse cx="692" cy="72" rx="46" ry="19" fill="{INK}"/></g>
<path d="M194 400Q168 610 208 720Q480 770 752 720Q792 610 766 400Z" fill="url(#st)" {ol(11)}/>
<path d="M194 420Q168 610 208 720Q260 730 304 734Q258 590 280 400Z" fill="{MOHO2}" opacity=".6"/>
{dots(62,300,500,740,710,24,MOHO2,5,13,.55)}
{scratches(63,230,450,740,710,20,HUES,3,.25)}
<path d="M390 736V590Q480 490 570 590V736Z" fill="{INK}"/>
<path d="M404 736V596Q480 512 556 596V736Z" fill="url(#door)" {ol(7)}/>
<path d="M404 620H556M404 672H556M480 540V736" stroke="{INK}" stroke-width="6"/>
<path d="M388 590Q480 478 572 590L556 610Q480 520 404 610Z" fill="{HUES}" {ol(6)}/><path d="M410 576l14 20l12-34l16 30l14-42l18 42l14-30l14 34l14-20" fill="{INK}"/>
{win(286,520,36)}{win(674,516,40)}{win(320,630,22)}
<g transform="rotate(-5 650 640)"><rect x="608" y="592" width="96" height="122" fill="{HUES}" {ol(6)}/><circle cx="656" cy="628" r="20" fill="{MULTA}" {ol(4)}/><path d="M630 668h52M630 688h52" stroke="{INK}" stroke-width="7"/><path d="M640 618l10 10M672 618l-10 10M644 640h24" stroke="{INK}" stroke-width="4"/></g>
<path d="M58 348Q40 92 480 76Q920 92 902 348Q892 422 480 428Q68 422 58 348Z" fill="url(#cap)" {ol(12)}/>
<path d="M64 378Q480 500 896 378Q870 452 480 462Q90 452 64 378Z" fill="{MORA}" {ol(9)}/>
{''.join(f'<path d="M{480+(x-480)*1.0:.0f} 400Q{480+(x-480)*.9:.0f} 438 {480+(x-480)*.8:.0f} 456" stroke="{MULTA2}" stroke-width="7" fill="none"/>' for x in range(110,870,40))}
{platesd}
<ellipse cx="460" cy="130" rx="86" ry="42" fill="url(#hub)" {ol(8)}/><ellipse cx="460" cy="124" rx="44" ry="20" fill="{HUES}" {ol(5)}/><ellipse cx="460" cy="122" rx="14" ry="7" fill="{INK}"/>
<ellipse cx="136" cy="330" rx="38" ry="21" fill="{ACID}" transform="rotate(-30 136 330)"/><ellipse cx="848" cy="340" rx="30" ry="16" fill="{ACID}" transform="rotate(30 848 340)"/><ellipse cx="240" cy="172" rx="30" ry="16" fill="{HUES}" transform="rotate(-24 240 172)"/>
<path d="M730 520H906V690H730Z" fill="{MORA}" opacity=".85" {ol(8)}/>
{glow(818,620,50,BUTA)}<ellipse cx="818" cy="668" rx="58" ry="20" fill="{RESET2}" {ol(6)}/><path d="M770 594V664Q818 690 866 664V594Z" fill="url(#coil)" {ol(6)}/><ellipse cx="818" cy="592" rx="60" ry="22" fill="{RESET}" {ol(6)}/><ellipse cx="818" cy="590" rx="20" ry="8" fill="{INK}"/>
{cagebars}<path d="M722 514H914V534H722ZM722 684H914V704H722Z" fill="{HIER}" {ol(7)}/>
<rect x="800" y="706" width="36" height="28" rx="3" fill="{OBRA}" {ol(6)}/><path d="M818 700v8" stroke="{INK}" stroke-width="10"/><circle cx="818" cy="722" r="5" fill="{INK}"/>
{bu}''')
