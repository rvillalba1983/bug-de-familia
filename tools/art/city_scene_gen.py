import math,random,base64
W,H=1600,1000; F=1120; p=math.radians(46); C=(0,-21,31)
f=(0,math.cos(p),-math.sin(p)); u=(0,math.sin(p),math.cos(p))
def dot(a,b): return sum(x*y for x,y in zip(a,b))
def Z(P): return dot([P[i]-C[i] for i in range(3)],f)
def pr(P):
    v=[P[i]-C[i] for i in range(3)]; z=dot(v,f)
    return (W/2+F*v[0]/z, H/2-F*dot(v,u)/z)
def S(P): return F/Z(P)
INK='#160a24';MORA='#3A1A5C';BERE='#6A2BA8';RESET='#00E5FF';BLUE='#0A7FC2';MULTA='#FF1F8F';MULTA2='#A80F6B';BUTA='#FF6A00';OBRA='#FFD400';ACID='#C6FF00';MOHO='#2FBF71';MOHO2='#14704F';OXID='#A8482A';OXID2='#6A2A20';HIER='#8894B5';HIER2='#4A5478';HUES='#F6E7C8'
def rgb(h): return [int(h[i:i+2],16) for i in (1,3,5)]
def mix(a,b,t):
    a,b=rgb(a),rgb(b); return '#%02x%02x%02x'%tuple(int(a[i]+(b[i]-a[i])*t) for i in range(3))
HAZE='#4b2c80'
def hz(c,y): return mix(c,HAZE,max(0,min(1,(y+4)/38))*.5)
R=random.Random(1983)
out=[];glow=[]
def path(pts): return 'M'+'L'.join(f'{x:.1f} {y:.1f}' for x,y in pts)+'Z'
def poly(P3,fill,ow=0,op=1,target=None,stroke=INK):
    pts=[pr(q) for q in P3]; s=''
    if ow: s=f' stroke="{stroke}" stroke-width="{ow:.1f}" stroke-linejoin="round"'
    e=f'<path d="{path(pts)}" fill="{fill}" opacity="{op}"{s}/>'
    (out if target is None else target).append(e)
def line(P3,c,w,op=1,target=None,dash=''):
    pts=[pr(q) for q in P3]; d='M'+'L'.join(f'{x:.1f} {y:.1f}' for x,y in pts)
    (out if target is None else target).append(f'<path d="{d}" fill="none" stroke="{c}" stroke-width="{w:.1f}" stroke-linecap="round" stroke-linejoin="round" opacity="{op}"{dash}/>')
def hull(pts):
    pts=sorted(set((round(a,1),round(b,1)) for a,b in pts))
    def cr(o,a,b): return (a[0]-o[0])*(b[1]-o[1])-(a[1]-o[1])*(b[0]-o[0])
    lo=[]
    for q in pts:
        while len(lo)>1 and cr(lo[-2],lo[-1],q)<=0: lo.pop()
        lo.append(q)
    up=[]
    for q in reversed(pts):
        while len(up)>1 and cr(up[-2],up[-1],q)<=0: up.pop()
        up.append(q)
    return lo[:-1]+up[:-1]
def fan(q,w): return w*S(q)/40
# suelo
poly([(-60,-20,0),(60,-20,0),(60,60,0),(-60,60,0)],'url(#ground)')
poly([(-6.5,-20,0),(6.5,-20,0),(6.5,60,0),(-6.5,60,0)],'url(#road)')
for i in range(420):
    x=R.uniform(-34,34);y=R.uniform(-12,40);l=R.uniform(.5,2.4)
    poly([(x,y,0),(x+l,y+.1,0),(x+l*.9,y+.5,0),(x-.1,y+.42,0)],R.choice([MOHO2,'#2c1b45','#54304e',MORA,'#3d5a4a']),0,.45)
for x in (-6.5,6.5):
    line([(x,-20,0),(x,60,0)],INK,10); line([(x,-20,.02),(x,60,.02)],OBRA,3.5,.8)
for rx in (-2.4,2.4):
    line([(rx,-20,0),(rx,60,0)],INK,8); line([(rx,-20,0),(rx,60,0)],HIER,2.5,.8)
    for y in range(-16,44,2): poly([(rx-.9,y,0),(rx+.9,y,0),(rx+.9,y+.34,0),(rx-.9,y+.34,0)],'#3a2438',0,.8)
# grietas y charcos
for s0 in range(16):
    x=R.uniform(-5.5,5.5);y=R.uniform(-8,26);q=[(x,y,0)]
    for _ in range(5):
        x+=R.uniform(-.9,.9);y+=R.uniform(.2,1.2);q.append((x,y,0))
    line(q,INK,3,.9)
def puddle(cx,cy,a,b,c):
    q=[(cx+a*math.cos(t)*(1+.2*math.sin(5*t)),cy+b*math.sin(t)*(1+.15*math.cos(3*t)),0) for t in [i*.2 for i in range(32)]]
    poly(q,c,4,.92); 
    q2=[(cx-a*.2+a*.45*math.cos(t),cy+b*.25+b*.25*math.sin(t),0) for t in [i*.3 for i in range(22)]]
    poly(q2,HUES,0,.35)
    poly(q,c,0,.65,glow)
puddle(-3.4,6,2.3,1.3,ACID);puddle(4.1,1.2,1.5,.8,RESET);puddle(1.2,14,1.9,1,MULTA)
LIGHT=(-.32,.26) # sombra por metro de altura
items=[]
def shadow(b):
    x,y,w,d,h=b['x'],b['y'],b['w'],b['d'],b['h']
    dx,dy=LIGHT[0]*h,LIGHT[1]*h
    fp=[(x,y),(x+w,y),(x+w,y+d),(x,y+d)]
    all2=[pr((a,c,0)) for a,c in fp]+[pr((a+dx,c+dy,0)) for a,c in fp]
    out.append(f'<path d="{path(hull(all2))}" fill="{INK}" opacity=".58"/>')
def windows(mapf,cols,rows,seed,y,facew,faceh,on=(ACID,RESET,MULTA,OBRA)):
    r=random.Random(seed)
    for j in range(rows):
        for i in range(cols):
            u0=(i+.2)/cols;u1=(i+.8)/cols;v0=(j+.28)/rows;v1=(j+.78)/rows
            q=[mapf(u0,v0),mapf(u1,v0),mapf(u1,v1),mapf(u0,v1)]
            sw=S(q[0])
            k=r.random()
            if k<.34:
                c=r.choice(on);poly(q,INK,sw*.13);poly(q,hz(c,y),0)
                poly(q,c,0,.8,glow)
                mx=[mapf(u0,(v0+v1)/2),mapf(u1,(v0+v1)/2)];line(mx,INK,sw*.05)
                line([mapf((u0+u1)/2,v0),mapf((u0+u1)/2,v1)],INK,sw*.05)
            elif k<.55:
                poly(q,'#22132f',sw*.13)
                poly([q[0],q[1],mapf(u1,(v0+v1)/2),mapf(u0,(v0+v1)/2)],OXID2,0,.8)
                for t in (.3,.5,.7): line([mapf(u0,v0+(v1-v0)*t),mapf(u1,v0+(v1-v0)*t)],INK,sw*.05)
            else:
                poly(q,'#120a1e',sw*.13)
                poly([q[0],q[1],mapf(u0,v1)],BLUE,0,.3)
def patches(mapf,n,seed,cols):
    r=random.Random(seed)
    for _ in range(n):
        a=r.random()*.92;b=r.random()*.94;da=r.uniform(.03,.17);db=r.uniform(.02,.09)
        poly([mapf(a,b),mapf(a+da,b),mapf(a+da*.92,b+db),mapf(a+.01,b+db*.9)],r.choice(cols),0,r.uniform(.3,.7))
def building(b):
    x,y,w,d,h=b['x'],b['y'],b['w'],b['d'],b['h'];c=b['c'];cd=b['cd'];roof=b['roof']
    ow=S((x,y,0))*.14
    fr=lambda a,v:(x+a*w,y,v*h)
    if x+w<0: xs=x+w; sd=lambda a,v:(xs,y+a*d,v*h)
    else: xs=x; sd=lambda a,v:(xs,y+a*d,v*h)
    # lateral
    poly([sd(0,0),sd(1,0),sd(1,1),sd(0,1)],hz(cd,y),ow)
    patches(sd,26,int(x*7+y),[hz(mix(cd,MORA,.5),y),hz(mix(cd,HIER,.3),y),hz(OXID2,y)])
    windows(sd,b['sc'],b['r'],int(y*3+x),y,d,h)
    poly([sd(0,0),sd(1,0),sd(1,.22),sd(0,.22)],INK,0,.32)
    poly([sd(0,.75),sd(1,.75),sd(1,1),sd(0,1)],BERE,0,.14)
    # frente
    poly([fr(0,0),fr(1,0),fr(1,1),fr(0,1)],f'url(#{b["g"]})',ow)
    patches(fr,38,int(x*5+y*2),[hz(mix(c,HUES,.25),y),hz(mix(c,MORA,.45),y),hz(OXID,y),hz(mix(c,INK,.3),y)])
    windows(fr,b['fc'],b['r'],int(y*11+x),y,w,h)
    poly([fr(0,0),fr(1,0),fr(1,.2),fr(0,.2)],INK,0,.38)
    # puerta
    a0,a1=b['door'];q=[fr(a0,0),fr(a1,0),fr(a1,2.6/h),fr(a0,2.6/h)]
    poly(q,hz(OXID,y),ow*.8);line([fr(a0,1.3/h),fr(a1,1.3/h)],INK,ow*.5)
    # rim de cornisa
    line([fr(0,1),fr(1,1)],mix(RESET,HUES,.35),ow*.5,.9)
    line([sd(0,1),sd(1,1)],hz(MULTA,y),ow*.4,.7)
    # techo
    T=lambda a,b_,z=h:(x+a*w,y+b_*d,z)
    poly([T(0,0),T(1,0),T(1,1),T(0,1)],hz(roof,y),ow)
    t2=lambda a,b_:T(.06+.88*a,.08+.84*b_)
    poly([t2(0,0),t2(1,0),t2(1,1),t2(0,1)],hz(mix(roof,MORA,.45),y),ow*.5)
    patches(t2,18,int(y*17),[hz(OXID2,y),hz(BERE,y),hz(MOHO2,y)])
    # conductos
    r=random.Random(int(x*y+3))
    for _ in range(b.get('ac',2)):
        a=r.uniform(.14,.7);e=r.uniform(.18,.6);bw=r.uniform(1.1,2);bd=r.uniform(.9,1.5);bh=r.uniform(.7,1.3)
        X,Y=x+a*w,y+e*d
        poly([(X,Y,h),(X,Y+bd,h),(X,Y+bd,h+bh),(X,Y,h+bh)],hz(HIER2,y),ow*.5) if X<0 else None
        poly([(X,Y,h),(X+bw,Y,h),(X+bw,Y,h+bh),(X,Y,h+bh)],hz(HIER,y),ow*.5)
        poly([(X,Y,h+bh),(X+bw,Y,h+bh),(X+bw,Y+bd,h+bh),(X,Y+bd,h+bh)],hz(mix(HIER,HUES,.3),y),ow*.5)
    if b.get('tank'):
        cx,cy=b['tank'];rr=1.8;zb=h;zt=h+3.2
        ring=lambda z,rd=rr:[(cx+rd*math.cos(t*.2),cy+rd*math.sin(t*.2),z) for t in range(32)]
        hb=hull([pr(q) for q in ring(zb)+ring(zt)])
        out.append(f'<path d="{path(hb)}" fill="{hz(OXID,y)}" stroke="{INK}" stroke-width="{ow*.7:.1f}"/>')
        poly(ring(zt),hz(mix(OBRA,BUTA,.4),y),ow*.6);poly(ring(zt,1.1),INK,0,.9)
    if b.get('sign'):
        sx,sz,c1=b['sign']
        a=(x+sx,y-.5);q=[(a[0],a[1],sz),(a[0]+3.4,a[1],sz),(a[0]+3.4,a[1],sz+2.2),(a[0],a[1],sz+2.2)]
        poly(q,INK,ow*.7);m=[(a[0]+.3,a[1],sz+.3),(a[0]+3.1,a[1],sz+.3),(a[0]+3.1,a[1],sz+1.9),(a[0]+.3,a[1],sz+1.9)]
        poly(m,c1,0);poly(m,c1,0,.95,glow)
        cc=(a[0]+1.7,a[1],sz+1.1)
        poly([(cc[0]-.9,cc[1],cc[2]-.4),(cc[0]+.4,cc[1],cc[2]-.6),(cc[0]+.9,cc[1],cc[2]+.6),(cc[0]-.6,cc[1],cc[2]+.5)],INK)
blds=[dict(x=-23,y=20,w=15,d=11,h=15,c='#6d5a8f',cd='#3f2c64',roof='#75668f',g='w1',fc=7,sc=5,r=6,door=(.55,.72),ac=3,tank=(-17,26)),
dict(x=9,y=22,w=15,d=10,h=17,c='#3f6d9f',cd='#27365f',roof='#6a7fa8',g='w2',fc=7,sc=5,r=7,door=(.2,.35),ac=2,sign=(2,12,MULTA)),
dict(x=-25,y=6,w=16,d=9,h=8,c=OXID,cd='#55261f',roof='#8a6f60',g='w3',fc=7,sc=4,r=3,door=(.7,.85),ac=3,sign=(8,5,ACID)),
dict(x=9.5,y=7,w=15,d=9,h=10,c='#8c4b7b',cd='#4a2354',roof='#7f6a88',g='w4',fc=7,sc=4,r=4,door=(.12,.28),ac=2,tank=(20,11)),
dict(x=-7,y=33,w=14,d=8,h=12,c='#7a5ea6',cd='#3f2c64',roof=BERE,g='w1',fc=8,sc=4,r=5,door=(.42,.58),ac=1)]
def e_b(b):
    def d(): building(b)
    return (b['y'],d)
for b in blds: shadow(b)
items+=[e_b(b) for b in blds]
# seta gigante
def mush(cx,cy,hgt,rad,c1='url(#cap)'):
    r=random.Random(int(cx*cy))
    st=lambda z,rd:[(cx+rd*math.cos(t*.2),cy+rd*.8*math.sin(t*.2),z) for t in range(32)]
    pts=[pr(q) for z in (0,hgt) for q in st(z,rad*.26 if z else rad*.34)]
    out.append(f'<path d="{path(hull(pts))}" fill="url(#stem)" stroke="{INK}" stroke-width="{S((cx,cy,0))*.14:.1f}"/>')
    dome=[]
    for la in range(0,91,10):
        l=math.radians(la)
        rd=rad*math.cos(l);z=hgt+rad*.75*math.sin(l)
        dome+=st(z,rd)
    h2=hull([pr(q) for q in dome])
    gill=st(hgt-.05,rad*.97)
    out.append(f'<path d="{path(h2)}" fill="{c1}" stroke="{INK}" stroke-width="{S((cx,cy,hgt))*.16:.1f}"/>')
    for i in range(14):
        ln=math.radians(r.uniform(180,360)) ; la=math.radians(r.uniform(16,70))
        rd=rad*math.cos(la);z=hgt+rad*.75*math.sin(la);a=(cx+rd*math.cos(ln),cy+rd*.8*math.sin(ln),z)
        cs=S(a)*rad*r.uniform(.07,.15)
        x,y=pr(a);c=r.choice([ACID,HUES,HUES])
        out.append(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{cs:.1f}" ry="{cs*.58:.1f}" fill="{c}"/>')
    x,y=pr((cx,cy,hgt+rad*.55));glow.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{S((cx,cy,hgt))*rad*.8:.1f}" fill="{MULTA}" opacity=".22"/>')
items.append((27.5,lambda:mush(3.2,28,7.5,4.6)))
items.append((12.4,lambda:mush(-6.3,16.5,2.5,1.5)))
items.append((3.3,lambda:mush(7.5,3.5,1.6,1)))
# farolas
def lamp(x,y,col,arm):
    def d():
        Top=(x,y,6.2);H_=(x+arm,y,6.2)
        w=S((x,y,0))
        line([(x,y,0),Top,H_],INK,w*.32);line([(x,y,0),Top,H_],hz(HIER2,y),w*.14)
        px,py=pr(H_)
        out.append(f'<circle cx="{px:.1f}" cy="{py:.1f}" r="{w*.3:.1f}" fill="{col}" stroke="{INK}" stroke-width="{w*.1:.1f}"/>')
        glow.append(f'<circle cx="{px:.1f}" cy="{py:.1f}" r="{w*.75:.1f}" fill="{col}"/>')
        q=[(x+arm+2.4*math.cos(t*.2),y+1.8*math.sin(t*.2),0) for t in range(32)]
        poly(q,col,0,.33,glow)
    return (y,d)
items+=[lamp(-5.7,10,RESET,1.5),lamp(5.7,17,MULTA,-1.5),lamp(-5.7,27,ACID,1.5),lamp(5.7,-2,OBRA,-1.5)]
# sprites con escala real por profundidad
def sprite(fn,x,y,hm,sw,sh,flip=False):
    def d():
        b=base64.b64encode(open(f'art/beta/fuentes/{fn}.svg','rb').read()).decode()
        px,py=pr((x,y,0));s=S((x,y,0))*hm/sh
        wd,hd=sw*s,sh*s
        sx=-1 if flip else 1
        out.append(f'<ellipse cx="{px:.0f}" cy="{py:.0f}" rx="{wd*.34:.0f}" ry="{wd*.12:.0f}" fill="{INK}" opacity=".5"/>')
        out.append(f'<g transform="translate({px:.1f} {py:.1f}) scale({sx} 1)"><image x="{-wd/2:.1f}" y="{-hd*.93:.1f}" width="{wd:.1f}" height="{hd:.1f}" href="data:image/svg+xml;base64,{b}"/></g>')
    return (y,d)
items+=[sprite('07_jubilado_hierro',-1.8,3.8,3.6,512,512),sprite('06_mohocrata',2.6,5.4,3.3,512,512,True),
sprite('07_jubilado_hierro',-3.2,18,3.6,512,512,True),sprite('06_mohocrata',3.4,20.5,3.3,512,512),sprite('06_mohocrata',1.4,22,3.3,512,512),
sprite('01_mina_petanca',.1,8.6,1,256,256),sprite('01_mina_petanca',-.9,1,1,256,256),sprite('04_dron_viejo',-1.4,25,2.8,320,320),sprite('05_urna_esporas',4.6,10,2.3,320,320)]

def bush(x,y,r,c1,c2):
    def d():
        rr=random.Random(int(x*13+y*7))
        for i in range(7):
            a=rr.uniform(0,6.28);dd=rr.uniform(0,r*.75);cx,cy=x+dd*math.cos(a),y+dd*.6*math.sin(a);z=rr.uniform(.2,r*.9);rd=r*rr.uniform(.4,.7)
            px,py=pr((cx,cy,z));sz=S((cx,cy,z))*rd
            out.append(f'<ellipse cx="{px:.1f}" cy="{py:.1f}" rx="{sz:.1f}" ry="{sz*.8:.1f}" fill="{hz(c1 if i%2 else c2,y)}" stroke="{INK}" stroke-width="{S((x,y,0))*.11:.1f}"/>')
    return (y,d)
def scrap(x,y):
    def d():
        rr=random.Random(int(x*3+y*19))
        for i in range(9):
            a=x+rr.uniform(-1.4,1.4);b=y+rr.uniform(-.8,.8);z=rr.uniform(0,.9);l=rr.uniform(.5,1.3);h=rr.uniform(.3,.8)
            poly([(a,b,z),(a+l,b+.1,z+.2),(a+l,b,z+h),(a,b+.1,z+h*.8)],hz(rr.choice([OXID,HIER,HIER2,OBRA,OXID2]),y),S((x,y,0))*.08)
    return (y,d)
for x,y,r,a,b_ in ((-13,1,2.1,MOHO,MOHO2),(-20,0,2.7,MOHO2,'#0f5a48'),(14,2,2.2,MOHO,MOHO2),(21,-3,3,MOHO2,'#0f5a48'),(-12,-8,3,MOHO,'#0f5a48'),(16,-9,2.6,'#5c2a8c',MORA),(-9,18,1.7,MOHO,MOHO2),(8,19,1.7,'#5c2a8c',MOHO2)):
    items.append(bush(x,y,r,a,b_))
for x,y in ((-8.6,2.5),(9,-4.5),(-9,-5),(8.2,16),(-1,31)): items.append(scrap(x,y))
items.sort(key=lambda t:-t[0])
for _,d in items: d()
# cables en 3D
def cable(a,b,sag,c):
    pts=[]
    for i in range(25):
        t=i/24;pts.append((a[0]+(b[0]-a[0])*t,a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t-sag*4*t*(1-t)))
    line(pts,INK,S(a)*.2);line(pts,c,S(a)*.08)
cable((-8,20,15),(9,22,17),3.2,MULTA);cable((-9,8,8),(9.5,8,10),2.4,OBRA);cable((-8,25,13),(9,28,15),3,RESET);cable((-7.5,14,7),(9.2,13.5,9),2,ACID)
for t in range(6):
    a=-6+t*2.2;q=(a,20.4+t*.2,15.2-3.2*4*(t/6+.15)*(1-(t/6+.15))+.2)
    x,y=pr(q);out.append(f'<path d="M{x-11:.0f} {y:.0f}h22l-4 22h-14z" fill="{[OBRA,MULTA,ACID,RESET][t%4]}" stroke="{INK}" stroke-width="4" stroke-linejoin="round"/>')
# primer plano desenfocado
fg=[]
def blob(pts,c): fg.append(f'<path d="{pts}" fill="{c}"/>')
leaf=random.Random(5)
for cx,cy,col in ((40,1010,'#0f3f35'),(1570,1010,'#32104a'),(1590,10,'#0c332c')):
    for i in range(9):
        ang=leaf.uniform(0,360);L=leaf.uniform(120,240)
        fg.append(f'<ellipse cx="{cx+leaf.uniform(-70,70):.0f}" cy="{cy+leaf.uniform(-60,40):.0f}" rx="{L:.0f}" ry="{L*.26:.0f}" transform="rotate({ang:.0f} {cx} {cy})" fill="{col}"/>')
fg2=''
svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><defs>
<linearGradient id="road" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#402b5e"/><stop offset="1" stop-color="#2d1b3b"/></linearGradient>
<radialGradient id="ground" cx=".5" cy=".6" r=".8"><stop offset="0" stop-color="#3f6b4e"/><stop offset="1" stop-color="#20293a"/></radialGradient>
<linearGradient id="w1" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#8d73b3"/><stop offset="1" stop-color="#3a2858"/></linearGradient>
<linearGradient id="w2" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#5f90c6"/><stop offset="1" stop-color="#26325c"/></linearGradient>
<linearGradient id="w3" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#d36b36"/><stop offset="1" stop-color="#592420"/></linearGradient>
<linearGradient id="w4" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#b86a9e"/><stop offset="1" stop-color="#452050"/></linearGradient>
<radialGradient id="cap" cx=".35" cy=".25" r=".9"><stop offset="0" stop-color="#ff5fb0"/><stop offset=".5" stop-color="{MULTA}"/><stop offset="1" stop-color="{MULTA2}"/></radialGradient>
<linearGradient id="stem" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="{ACID}"/><stop offset="1" stop-color="{MOHO2}"/></linearGradient>
<filter id="wob" x="-2%" y="-2%" width="104%" height="104%"><feTurbulence type="fractalNoise" baseFrequency=".018" numOctaves="3" seed="4" result="n"/><feDisplacementMap in="SourceGraphic" in2="n" scale="7"/></filter>
<filter id="gl" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="17"/></filter>
<filter id="bl" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="11"/></filter>
<filter id="brush" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".035 .07" numOctaves="4" seed="9"/><feColorMatrix values="0 0 0 0 .5  0 0 0 0 .5  0 0 0 0 .5  1.5 0 0 0 -.3"/></filter>
<filter id="grain" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".75" numOctaves="2" seed="2"/><feColorMatrix values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  .9 0 0 0 -.33"/></filter>
<radialGradient id="vig" cx=".5" cy=".52" r=".75"><stop offset=".62" stop-color="{INK}" stop-opacity="0"/><stop offset="1" stop-color="{INK}" stop-opacity=".72"/></radialGradient>
<linearGradient id="far" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#7a4fc0" stop-opacity=".55"/><stop offset=".42" stop-color="#7a4fc0" stop-opacity="0"/></linearGradient>
</defs>
<g filter="url(#wob)">{''.join(out)}</g>
<g style="mix-blend-mode:screen" filter="url(#gl)">{''.join(glow)}</g>
<rect width="{W}" height="{H}" fill="url(#far)"/>
<rect width="{W}" height="{H}" filter="url(#brush)" opacity=".42" style="mix-blend-mode:soft-light"/>
<rect width="{W}" height="{H}" filter="url(#grain)" opacity=".4"/>
<rect width="{W}" height="{H}" fill="url(#vig)"/>
<g filter="url(#bl)">{''.join(fg)}{fg2}</g>
</svg>'''
open('scene.svg','w').write(svg)
open('scene.html','w').write(f'<!doctype html><body style="margin:0;background:#000">{svg}')
