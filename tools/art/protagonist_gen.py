#!/usr/bin/env python3
"""Genera data/art/protagonista.json: el Sujeto Sobrante como polígonos que dibuja Godot.
Coordenadas calcadas de la hoja de diseño (recorte 1410x1155). Origen final: entre los pies."""
import json, math, sys, os

INK='#120a1e'; FUR='#d9541a'; FUR_L='#f07a25'; FUR_D='#8f2f14'; SKIN='#e9a768'; SKIN_D='#b86c3f'
LILAC='#8c8fe0'; LILAC_L='#b9bdf5'; LILAC_D='#4c4a9c'; CYAN='#21d4ff'; NAVY='#1f1740'; NAVY_L='#35285f'
PURP='#4a2478'; PURP_L='#7a45b5'; MAG='#c21f7a'; MAG_D='#6d1650'; GOLD='#f0b52e'; GOLD_D='#94601a'
CREAM='#f4d9b0'; PINK='#e8a0b0'; OLIVE='#79803a'; OLIVE_D='#4a4d24'; RUST='#b4501f'; BROWN='#5d4a38'; WHITE='#f5f2ff'
ORIGIN=(960.0,1118.0)

def cr(pts,n=6):
    out=[];k=len(pts)
    for i in range(k):
        p0,p1,p2,p3=pts[(i-1)%k],pts[i],pts[(i+1)%k],pts[(i+2)%k]
        for s in range(n):
            t=s/n;t2=t*t;t3=t2*t
            out.append(tuple(.5*((2*p1[a])+(-p0[a]+p2[a])*t+(2*p0[a]-5*p1[a]+4*p2[a]-p3[a])*t2+(-p0[a]+3*p1[a]-3*p2[a]+p3[a])*t3) for a in(0,1)))
    return out
def ell(c,rx,ry,rot=0,n=20):
    r=math.radians(rot);o=[]
    for i in range(n):
        a=i*math.tau/n;x=rx*math.cos(a);y=ry*math.sin(a)
        o.append((c[0]+x*math.cos(r)-y*math.sin(r),c[1]+x*math.sin(r)+y*math.cos(r)))
    return o
def rgb(h): return [int(h[i:i+2],16)/255 for i in(1,3,5)]
def hexc(c): return '#%02x%02x%02x'%tuple(max(0,min(255,round(v*255))) for v in c)
def S(pts,fill,o=4.0,smooth=False,grad=None,alpha=1.0):
    q=cr(pts) if smooth else list(pts)
    return dict(q=q,fill=fill,o=o,grad=grad,alpha=alpha)
def L(pts,c,w,smooth=False):
    q=cr(pts,5)[:-4] if False else pts
    return dict(q=list(q),line=c,w=w)

def tuft(x,y,w,h,c0=FUR,c1=FUR_D,n=6,o=4):
    pts=[(x,y)]
    for i in range(n):
        a=(i+1)/n; pts.append((x+w*(a-.5/n),y+h*(1 if i%2==0 else .55)))
        pts.append((x+w*a,y+h*.2))
    pts.append((x+w,y-h*.25));pts.append((x,y-h*.25))
    return S(pts,c0,o,False,(c0,c1))
def hand(cx,cy,flip=1,rot=0):
    """Mano oscura con garras de punta crema. Devuelve lista de formas."""
    r=math.radians(rot)
    def T(x,y):
        x*=flip*1.5;y*=1.5
        return (cx+x*math.cos(r)-y*math.sin(r),cy+x*math.sin(r)+y*math.cos(r))
    out=[S([T(-38,-32),T(32,-36),T(42,4),T(26,30),T(-30,30),T(-44,4)],NAVY_L,5,True,(PURP,NAVY))]
    for fx,fy,fa in((-40,16,18),(-14,28,4),(12,30,-6),(40,10,-26)):
        a=math.radians(fa);d=(math.sin(a),math.cos(a))
        n=(d[1],-d[0]);w=12;l=48
        out.append(S([T(fx-n[0]*w,fy-n[1]*w),T(fx+n[0]*w,fy+n[1]*w),T(fx+n[0]*w*.8+d[0]*l*.6,fy+n[1]*w*.8+d[1]*l*.6),T(fx+d[0]*l,fy+d[1]*l),T(fx-n[0]*w*.8+d[0]*l*.6,fy-n[1]*w*.8+d[1]*l*.6)],NAVY,4))
        tp=(fx+d[0]*l*.72,fy+d[1]*l*.72)
        out.append(S(ell(T(*tp),13,14),CREAM,3.5))
    out.append(S(ell(T(8,-4),6,6),MAG,0))
    return out

P={}
# BRAZO ADICIONAL IZQUIERDO (alto, sale de la espalda)
P['arm_extra_left']=dict(pivot=(800,285),shapes=[
 S([(800,245),(735,205),(650,205),(610,250),(640,300),(720,300),(800,330)],PURP,6,True,(PURP_L,NAVY)),
 S([(560,235),(630,215),(655,262),(590,320),(500,345),(470,310)],NAVY_L,6,True,(NAVY_L,NAVY)),
 S([(595,228),(645,228),(652,262),(610,282)],WHITE,4),
 S([(525,282),(585,258),(600,292),(538,320)],LILAC_L,4),
 S([(540,300),(590,282),(596,300),(548,318)],GOLD,0),
 S([(780,262),(825,240),(842,300),(805,330),(760,325)],RUST,5,False,(FUR,RUST)),
 S([(692,226),(722,214),(735,262),(700,275)],LILAC,4),
 tuft(650,290,120,34,PURP_L,NAVY),tuft(490,330,90,30,PURP,NAVY),
]+hand(478,378,-1,28))
# BRAZO ADICIONAL DERECHO
P['arm_extra_right']=dict(pivot=(1125,285),shapes=[
 S([(1120,275),(1180,255),(1245,300),(1290,370),(1250,400),(1190,350),(1130,335)],PURP,6,True,(PURP_L,NAVY)),
 S([(1170,265),(1215,265),(1240,320),(1195,345)],LILAC_L,4),
 S([(1230,298),(1252,275),(1262,300),(1296,298),(1270,325),(1268,350),(1245,332)],BUTA:='#f08a20',3),
 S([(1255,410),(1300,385),(1360,420),(1365,480),(1300,480)],NAVY_L,6,True,(LILAC,NAVY)),
 S([(1305,480),(1350,470),(1362,560),(1320,570)],GOLD,5,False,(GOLD,GOLD_D)),
 S([(1318,490),(1346,486),(1350,530),(1324,534)],NAVY,0),
 tuft(1165,335,110,34,PURP_L,NAVY),S([(1220,300),(1275,370),(1255,392),(1200,335)],LILAC,4),
 S(ell((1282,430),30,26),LILAC_L,5),S(ell((1282,430),14,12),NAVY,0),
]+hand(1345,590,1,-8))
# BRAZO PRINCIPAL IZQUIERDO (bajo)
P['arm_main_left']=dict(pivot=(815,420),shapes=[
 S([(830,380),(760,375),(720,392),(735,420),(705,425),(740,450),(790,470),(830,460)],FUR,6,False,(FUR_L,FUR_D)),
 S([(735,410),(690,440),(620,470),(600,520),(640,560),(700,520),(770,470)],NAVY_L,6,True,(PURP,NAVY)),
 S([(575,540),(650,480),(690,520),(660,590),(590,620),(560,590)],NAVY,6,True,(PURP,NAVY)),
 S([(610,505),(655,478),(680,510),(625,545)],LILAC_L,4),
 S([(575,560),(640,525),(650,548),(590,590)],WHITE,4),
 S([(635,540),(672,525),(678,548),(645,562)],GOLD,0),
 tuft(565,590,100,32,PURP,NAVY),tuft(640,510,110,28,PURP_L,NAVY),
]+hand(585,655,-1,10))
# BRAZO PRINCIPAL DERECHO
P['arm_main_right']=dict(pivot=(1090,430),shapes=[
 S([(1085,400),(1135,410),(1165,480),(1120,530),(1085,500)],FUR_D,6,False,(RUST,FUR_D)),
 S([(1110,510),(1175,500),(1250,590),(1215,640),(1140,590)],NAVY,6,True,(PURP,NAVY)),
 S([(1105,520),(1160,480),(1205,530),(1150,570)],LILAC_L,4),
 S([(1195,590),(1225,572),(1235,600),(1205,618)],GOLD,0),
 S(ell((1150,540),8,8),GOLD,0),
 tuft(1150,590,105,34,PURP,NAVY),S([(1180,520),(1228,558),(1208,590),(1165,552)],LILAC_L,4),
]+hand(1248,672,1,-14))
# PIERNA IZQUIERDA (taparrabos oliva roto y zapatilla)
P['leg_left']=dict(pivot=(830,640),shapes=[
 S([(735,860),(800,860),(790,950),(725,950)],NAVY,6,False,(NAVY_L,NAVY)),
 S([(660,912),(690,905),(740,925),(770,930),(790,945),(770,1050),(765,1100),(745,1128),(620,1124),(595,1098),(600,1065),(650,1030)],NAVY,7,True,(NAVY_L,NAVY)),
 S([(595,1078),(650,1042),(712,1045),(765,1070),(760,1110),(742,1130),(620,1126),(595,1100)],CREAM,6,True,(CREAM,'#caa17f')),
 S([(610,1106),(745,1110),(735,1128),(622,1126)],PURP_L,0),
 S([(660,905),(740,912),(772,932),(760,960),(735,950),(690,936),(668,950)],CREAM,5,False,(CREAM,PINK)),
 L([(642,1012),(726,1000)],CREAM,11),L([(632,1038),(735,1026)],CREAM,11),
 S([(800,630),(945,632),(925,740),(905,830),(885,880),(865,850),(835,905),(810,860),(770,900),(745,860),(700,875),(735,800),(765,730)],OLIVE,6,False,(OLIVE,OLIVE_D)),
 S([(760,800),(805,790),(885,812),(880,860),(868,850),(838,905),(812,860),(770,900),(745,860),(700,875),(735,800)],RUST,0,False,(RUST,FUR_D)),
 S(ell((783,838),22,22),NAVY,4),S(ell((783,838),9,9),BUTA,0),
 L([(868,690),(892,730)],BUTA,5),L([(820,745),(880,770)],PURP_L,6),
 S([(725,698),(800,632),(838,650),(835,700),(760,772),(720,745)],BROWN,6,False,('#7a6049','#3f3226')),
 L([(752,705),(812,655)],INK,4),S([(760,705),(778,690),(784,725),(768,736)],GOLD_D,2),
])
# PIERNA DERECHA
P['leg_right']=dict(pivot=(1000,640),shapes=[
 S([(965,860),(1045,850),(1085,935),(990,960)],NAVY_L,6,False,(PURP,NAVY)),
 S([(1040,920),(1120,916),(1160,960),(1228,1035),(1232,1090),(1100,1095),(965,1062),(965,1030),(990,965)],NAVY,7,True,(NAVY_L,NAVY)),
 S([(965,1022),(1020,1050),(1130,1040),(1232,1038),(1232,1090),(1100,1096),(965,1064)],CREAM,6,True,(CREAM,'#caa17f')),
 S([(975,1050),(1100,1078),(1228,1076),(1228,1090),(1100,1096),(968,1064)],PURP_L,0),
 S([(1035,920),(1115,916),(1120,960),(1075,970),(1050,990)],CREAM,5,False,(CREAM,PINK)),
 L([(1110,985),(1165,970)],CREAM,11),L([(1130,1012),(1190,1000)],CREAM,11),
 S([(925,640),(1072,640),(1095,700),(1135,800),(1095,870),(1045,865),(1005,890),(965,830),(940,790),(915,850),(930,740)],NAVY,6,False,(NAVY_L,NAVY)),
 S([(1062,720),(1110,715),(1130,790),(1085,790)],GOLD,4),S([(1078,735),(1100,732),(1112,778),(1092,778)],NAVY,0),
 S(ell((1092,832),22,24),BROWN,4),S(ell((1092,832),9,10),BUTA,0),
])
# TORSO
P['torso']=dict(pivot=(960,640),shapes=[
 S([(815,395),(1095,400),(1110,470),(1085,520),(1060,590),(840,590),(815,520),(805,455)],NAVY,7,False,(NAVY_L,NAVY)),
 S([(890,470),(955,500),(1020,472),(1030,560),(960,580),(885,560)],SKIN_D,0,False,(RUST,FUR_D)),
 L([(890,440),(955,500),(1020,442)],GOLD_D,4),
 L([(835,450),(890,440),(868,500)],BUTA,5),L([(1045,455),(1078,490)],BUTA,5),L([(850,540),(895,548)],BUTA,5),L([(1030,510),(1065,548)],BUTA,5),
 S([(830,578),(1050,575),(1060,632),(835,640)],'#2c2340',6),
 S([(860,585),(892,583),(892,640),(860,640)],GOLD,0),S([(1010,582),(1042,580),(1042,632),(1012,632)],GOLD,0),
 S([(934,572),(1010,570),(1014,640),(936,642)],GOLD,6,False,(GOLD,GOLD_D)),S([(952,588),(992,586),(994,624),(954,626)],'#2c2340',0),L([(950,606),(998,606)],GOLD,8),
 L([(965,642),(965,720)],GOLD,8),L([(990,642),(990,700)],GOLD,8),
])
P['torso_back']=dict(pivot=(960,640),shapes=[
 S([(815,395),(1095,400),(1110,470),(1085,520),(1060,590),(840,590),(815,520),(805,455)],NAVY,7,False,(PURP,NAVY)),
 S([(915,440),(1000,440),(1010,560),(905,560)],RUST,0,False,(FUR,FUR_D)),
 S([(830,578),(1050,575),(1060,632),(835,640)],'#2c2340',6),
 S(ell((885,510),20,28),LILAC_L,4),S(ell((1035,510),20,28),LILAC_L,4),
])
# BUFANDA
P['scarf']=dict(pivot=(960,380),shapes=[
 S([(785,282),(860,300),(920,368),(1000,392),(1080,370),(1118,340),(1120,385),(1075,445),(990,478),(905,446),(810,368)],PURP,7,False,(MAG,PURP)),
 L([(805,335),(905,410),(990,438),(1085,405)],MAG_D,6),L([(830,362),(915,430),(990,458),(1060,430)],MAG_D,5),
 L([(800,300),(880,370),(990,410),(1105,362)],'#e0389a',6),L([(960,395),(975,470)],MAG_D,5),
])
# CABEZA FRONTAL
hair=[(992,60),(955,92),(893,44),(915,104),(803,80),(866,140),(772,138),(846,184),(818,222),(838,296),(880,352),(925,366),(992,392)]
P['head']=dict(pivot=(960,380),shapes=[
 S([(1040,92),(1036,22),(1075,48),(1090,105)],NAVY,5,False,(CYAN,NAVY)),
 S([(1098,120),(1115,112),(1110,160)],CYAN,3),
 S([(835,212),(780,192),(805,262),(850,298)],SKIN,6,False,(SKIN,SKIN_D)),S([(828,226),(800,212),(815,258),(842,278)],MAG_D,0),
 S([(1120,205),(1145,188),(1138,258),(1112,298)],LILAC_L,6),S([(1125,222),(1136,212),(1130,250),(1118,276)],MAG_D,0),
 S(hair,FUR,7,False,(FUR_L,FUR_D)),
 S([(985,70),(1050,88),(1100,150),(1112,205),(1118,290),(1085,320),(1045,382),(992,388)],LILAC,7,True,(LILAC_L,LILAC_D)),
 S([(992,190),(1100,190),(1112,290),(1085,318),(1045,380),(992,388)],LILAC_D,0,False,(LILAC,LILAC_D)),
 L([(1000,100),(1040,150),(1102,175)],NAVY,5),L([(1040,150),(1010,210)],NAVY,4),L([(1102,175),(1112,285)],NAVY,4),
 S(ell((1052,262),46,42),NAVY,4),
 S(ell((1052,262),34,31),'#0b6a9c',0),S(ell((1052,262),25,23),CYAN,0),S(ell((1052,262),11,10),WHITE,0),
 L([(1013,235),(1078,218)],LILAC_L,8),
 # lado mono
 S([(868,232),(992,246),(992,384),(930,362),(884,318)],SKIN,0,True,(SKIN,SKIN_D)),
 S([(918,312),(958,294),(992,298),(992,386),(944,376),(916,344)],'#f0bd86',4,True),
 S(ell((934,264),32,24,8),INK,0),S(ell((934,266),21,15,8),WHITE,0),S(ell((938,267),10,12),INK,0),S(ell((934,262),3,3),WHITE,0),
 S([(868,222),(925,226),(990,250),(986,270),(920,246),(880,244)],INK,0),
 S([(870,160),(940,168),(980,200),(930,195)],FUR_L,0),S([(910,110),(975,100),(978,140),(935,140)],FUR_L,0),
 L([(850,235),(875,290)],FUR_D,5),L([(882,300),(905,328)],FUR_D,5),
 # hocico mecánico y boca
 S([(992,298),(1034,306),(1058,346),(1034,380),(992,388)],LILAC,4,True,(LILAC_L,LILAC_D)),
 S([(980,284),(1012,284),(1018,304),(996,316),(976,304)],'#7a6fb0',4),
 L([(940,352),(962,344),(1000,350),(1040,344)],INK,6),
 tuft(840,300,70,28,FUR,FUR_D,4,0),
])
P['head_back']=dict(pivot=(960,380),shapes=[
 S([(1040,92),(1036,22),(1075,48),(1090,105)],NAVY,5,False,(CYAN,NAVY)),
 S([(835,212),(780,192),(805,262),(850,298)],SKIN,6,False,(SKIN,SKIN_D)),
 S([(1120,205),(1145,188),(1138,258),(1112,298)],LILAC_L,6),
 S(hair,FUR,7,False,(FUR_L,FUR_D)),
 S([(985,70),(1050,88),(1100,150),(1112,205),(1118,290),(1085,320),(1045,382),(992,388)],LILAC,7,True,(LILAC_L,LILAC_D)),
 L([(1000,100),(1050,200),(1100,250)],NAVY,5),L([(1050,200),(1030,330)],NAVY,5),
 S(ell((1052,300),14,14),CYAN,3),
])


# VISTAS DE PERFIL Y COMPLEMENTOS
P['head_e']=dict(pivot=(960,380),shapes=[
 S([(900,60),(850,20),(860,86),(790,50),(815,120),(740,120),(800,170),(760,225),(830,260),(850,340),(930,392),(1010,380),(1015,120)],FUR,7,False,(FUR_L,FUR_D)),
 S([(868,190),(815,178),(830,262),(880,290)],SKIN,6,False,(SKIN,SKIN_D)),S([(858,206),(830,198),(842,250),(870,270)],MAG_D,0),
 S([(940,180),(1040,190),(1075,250),(1140,300),(1150,345),(1110,385),(1020,392),(950,380),(925,300)],SKIN,6,True,(SKIN,SKIN_D)),
 S([(1040,282),(1140,298),(1152,346),(1110,386),(1030,392),(1010,340)],'#f0bd86',4,True),
 S(ell((1018,256),28,22,6),INK,0),S(ell((1022,258),19,14,6),WHITE,0),S(ell((1030,259),9,11),INK,0),
 S([(965,212),(1050,222),(1078,252),(1050,250),(975,238)],INK,0),
 S(ell((1140,318),8,7),INK,0),L([(1062,360),(1110,352),(1146,358)],INK,6),
 S([(890,90),(965,92),(990,160),(925,150)],FUR_L,0),
])
P['head_w']=dict(pivot=(960,380),shapes=[
 S([(905,80),(895,6),(940,30),(960,90)],NAVY,5,False,(CYAN,NAVY)),
 S([(868,185),(822,160),(830,262),(880,290)],LILAC_L,6),S([(858,204),(838,190),(844,248),(870,270)],MAG_D,0),
 S([(850,120),(900,70),(1000,72),(1060,130),(1075,240),(1150,300),(1152,350),(1110,392),(1010,395),(925,390),(850,330),(838,220)],LILAC,7,True,(LILAC_L,LILAC_D)),
 L([(890,90),(960,160),(1062,175)],NAVY,5),L([(960,160),(925,260)],NAVY,4),L([(925,260),(925,388)],NAVY,4),
 S([(1030,290),(1145,300),(1152,350),(1110,392),(1030,394)],LILAC_D,4,False,(LILAC,LILAC_D)),
 S(ell((1018,250),78,74),CYAN,0,alpha=.2),S(ell((1018,250),46,42),NAVY,4),S(ell((1018,250),34,31),'#0b6a9c',0),S(ell((1018,250),25,23),CYAN,0),S(ell((1018,250),11,10),WHITE,0),
 S(ell((1140,322),7,6),INK,0),L([(1060,362),(1110,356),(1146,360)],INK,6),
 S([(965,205),(1060,196),(1078,216),(980,230)],LILAC_L,0),
])
P['torso_side']=dict(pivot=(960,640),shapes=[
 S([(880,395),(1045,400),(1062,470),(1040,590),(880,590),(860,500)],NAVY,7,False,(NAVY_L,NAVY)),
 L([(905,450),(980,470)],GOLD_D,4),L([(930,510),(1000,540)],BUTA,5),
 S([(875,578),(1045,575),(1050,632),(875,640)],'#2c2340',6),S([(980,572),(1050,570),(1054,640),(982,642)],GOLD,6,False,(GOLD,GOLD_D)),S([(998,588),(1036,586),(1038,624),(1000,626)],'#2c2340',0),
 S([(868,630),(1040,632),(1030,780),(990,870),(955,830),(925,890),(890,840),(860,885),(842,780)],OLIVE,6,False,(OLIVE,OLIVE_D)),
 S([(848,780),(1032,780),(990,870),(955,830),(925,890),(890,840),(860,885)],RUST,0,False,(RUST,FUR_D)),
])
# El lado mono es el derecho del personaje: en la vista N queda a la derecha de la pantalla.
CX=960.0
def xf(shapes,f):
    out=[]
    for s in shapes:
        c=dict(s);c['q']=[f(a,b) for a,b in s['q']];out.append(c)
    return out
def warp(km,kr,dx,cx=990.0):
    return lambda x,y:(cx+dx+(x-cx)*(km if x<cx else kr),y)
def mirror(x,y): return (2*CX-x,y)
def affine(piv,sx=1.0,sy=1.0,rot=0.0,dx=0.0,dy=0.0):
    r=math.radians(rot);c,sn=math.cos(r),math.sin(r)
    def f(x,y):
        a=(x-piv[0])*sx;b=(y-piv[1])*sy
        return (piv[0]+a*c-b*sn+dx,piv[1]+a*sn+b*c+dy)
    return f
# Complementos: formas alrededor de un ancla, en coordenadas de la hoja.
def spike(a,b,c,fill,o=4): return S([a,b,c],fill,o)
def head_addon(name,c):
    x,y=c
    if name=='horns': return [spike((x-58,y+8),(x-74,y-74),(x-26,y-8),PURP_L),spike((x+6,y-6),(x+24,y-104),(x+50,y+2),PURP_L)]
    if name=='crest': return [spike((x+dx-20,y+6-abs(dx)*.08),(x+dx,y-74+abs(dx)*.18),(x+dx+20,y+6-abs(dx)*.08),GOLD) for dx in(-54,-18,18,54)]
    if name=='circlet': return [S([(x-84,y+24),(x+84,y+24),(x+78,y+50),(x-78,y+50)],GOLD,5,False,(GOLD,GOLD_D)),S(ell((x,y+37),12,10),CYAN,3)]
    if name=='antenna': return [L([(x+18,y+6),(x+40,y-86)],INK,9),L([(x+18,y+6),(x+40,y-86)],HIER_C,4),S(ell((x+42,y-96),16,16),MAG,4)]
    if name=='mohawk': return [spike((x+dx-24,y+8),(x+dx*1.25,y-98),(x+dx+24,y+8),CYAN) for dx in(-62,-22,22,62)]
    if name=='dome': return [S(ell((x+6,y+18),78,48),PURP_L,5,alpha=.85),S(ell((x-14,y+2),22,12),WHITE,0,alpha=.7)]
    return []
HIER_C='#8894b5'
def arm_addon(name,c,d):
    x,y=c;dx,dy=d;nx,ny=-dy,dx;P_=lambda a,b:(x+dx*a+nx*b,y+dy*a+ny*b)
    if name=='spikes': return [spike(P_(t-16,14),P_(t,62),P_(t+16,14),CREAM) for t in(-36,0,36)]
    if name=='blade': return [S([P_(-34,12),P_(120,28),P_(142,60),P_(-30,42)],HUES_C,5,False,(WHITE,LILAC_D))]
    if name=='ring': return [S([P_(-14,-46),P_(14,-46),P_(14,46),P_(-14,46)],GOLD,5,False,(GOLD,GOLD_D)),S(ell(P_(0,0),11,11),CYAN,3)]
    if name=='cannon': return [S([P_(-30,20),P_(62,20),P_(62,68),P_(-30,68)],GOLD_D,5,False,(GOLD,GOLD_D)),S(ell(P_(66,44),17,22),INK,3),S(ell(P_(66,44),9,12),MAG,0)]
    if name=='flame': return [spike(P_(t-18,18),P_(t*1.2,78+t*.3),P_(t+18,18),BUTA) for t in(-42,-6,30)]
    if name=='plate': return [S([P_(-44,-34),P_(44,-34),P_(52,34),P_(-52,34)],WHITE,5,False,(WHITE,LILAC)),L([P_(-30,0),P_(30,0)],MAG,6)]
    return []
HUES_C='#f6e7c8'
def leg_addon(name,knee,shoe):
    kx,ky=knee;sx,sy=shoe
    if name=='kneepad': return [S(ell((kx,ky),40,44),GOLD,5),S(ell((kx,ky),17,20),MAG,0)]
    if name=='wheel': return [S(ell((sx,sy),56,56),INK,5),S(ell((sx,sy),34,34),HIER_C,3),S(ell((sx,sy),12,12),GOLD,0)]
    if name=='spikes': return [spike((kx-52+i*30,ky+20),(kx-40+i*30,ky+84),(kx-24+i*30,ky+20),CREAM) for i in range(3)]
    if name=='tubes': return [L([(kx-34,ky-70),(kx+36,ky+64)],INK,16),L([(kx-34,ky-70),(kx+36,ky+64)],CYAN,7)]
    if name=='plates': return [S([(kx-46,ky-48),(kx+46,ky-40),(kx+40,ky+52),(kx-42,ky+46)],LILAC_L,5),L([(kx-30,ky),(kx+30,ky)],NAVY,6)]
    return []
ARM_ANCHOR={'arm_extra_left':((590,285),(-.8,.5)),'arm_extra_right':((1325,445),(.55,.83)),'arm_main_left':((625,545),(-.65,.75)),'arm_main_right':((1185,555),(.7,.7))}
LEG_ANCHOR={'leg_left':((790,850),(690,1085)),'leg_right':((1092,835),(1115,1060))}
ARM_ADDONS=['spikes','blade','ring','cannon','flame','plate']
LEG_ADDONS=['kneepad','wheel','spikes','tubes','plates']
HEAD_ADDONS=['horns','crest','circlet','antenna','mohawk','dome']
CROWN={'head':(1000,86),'head_back':(1000,86),'head_e':(930,96),'head_w':(960,76)}

def with_addons(name,anchor_fn,names):
    return {n:anchor_fn(n) for n in names}
def src(name):
    base=P[name];add={}
    if name in ARM_ANCHOR:
        c,d=ARM_ANCHOR[name];add={n:arm_addon(n,c,d) for n in ARM_ADDONS}
    elif name in LEG_ANCHOR:
        k,sh=LEG_ANCHOR[name];add={n:leg_addon(n,k,sh) for n in LEG_ADDONS}
    elif name in CROWN:
        add={n:head_addon(n,CROWN[name]) for n in HEAD_ADDONS}
    return dict(pivot=base['pivot'],shapes=base['shapes'],addons=add)
def apply(part,f):
    return dict(pivot=f(*part['pivot']),shapes=xf(part['shapes'],f),addons={k:xf(v,f) for k,v in part['addons'].items()})
def chain(*fs):
    def g(x,y):
        for f in fs: x,y=f(x,y)
        return (x,y)
    return g
ARMS=['arm_extra_left','arm_extra_right','arm_main_left','arm_main_right']
SWAP={'arm_extra_left':'arm_extra_right','arm_extra_right':'arm_extra_left','arm_main_left':'arm_main_right','arm_main_right':'arm_main_left','leg_left':'leg_right','leg_right':'leg_left'}
FRONT=['arm_extra_left','arm_extra_right','leg_left','leg_right','torso','arm_main_left','arm_main_right','scarf','head']
BACK=['leg_left','leg_right','arm_main_left','arm_main_right','torso','scarf','head','arm_extra_left','arm_extra_right']
def base_view(head,hw,torso,tw,legs_in=0.0,scale_far=1.0):
    v={}
    v['head']=apply(src(head),hw);v['scarf']=apply(src('scarf'),tw);v['torso']=apply(src(torso),tw)
    for a in ARMS: v[a]=apply(src(a),tw)
    v['leg_left']=apply(src('leg_left'),affine((0,0),dx=legs_in));v['leg_right']=apply(src('leg_right'),affine((0,0),dx=-legs_in))
    return v
def mirrored(v):
    out={}
    for k,p in v.items():
        out[SWAP.get(k,k)]=apply(p,mirror)
    return out
def side_view():
    SH=(960,430);HIP=(960,640);v={}
    def mount(name,to,sx,rot=0.0):
        s=src(name);px,py=s['pivot'];return apply(s,chain(affine((px,py),sx=sx,sy=sx,rot=rot),affine((0,0),dx=to[0]-px,dy=to[1]-py)))
    v['head']=None;v['scarf']=apply(src('scarf'),chain(affine((960,380),sx=.72,sy=1.0)))
    v['torso']=src('torso_side')
    v['arm_extra_right']=mount('arm_extra_right',(930,420),.74,18);v['arm_main_right']=mount('arm_main_right',(965,470),.86,28)
    v['arm_extra_left']=mount('arm_extra_left',(985,410),.6,-40);v['arm_main_left']=mount('arm_main_left',(1000,460),.66,-30)
    v['leg_right']=mount('leg_right',(925,640),.92);v['leg_left']=mount('leg_right',(1010,640),.82)
    v['leg_left']['addons']=apply(src('leg_left'),affine((0,0)))['addons'] and mount('leg_right',(1010,640),.82)['addons']
    return v
SIDE_ORDER=['arm_extra_left','arm_main_left','leg_left','leg_right','torso','scarf','arm_extra_right','arm_main_right','head']
def views():
    idn=lambda x,y:(x,y);V={}
    V['S']=(base_view('head',idn,'torso',idn,34.0),FRONT)
    V['SE']=(base_view('head',warp(1.14,.76,30),'torso',warp(1.1,.84,16,960),0.0),FRONT)
    sw=mirrored(base_view('head',idn,'torso',warp(1.1,.84,16,960),0.0));sw['head']=apply(src('head'),warp(.76,1.14,-30))
    V['SW']=(sw,FRONT)
    e=side_view();e['head']=src('head_e');V['E']=(e,SIDE_ORDER)
    w=mirrored(side_view_filled('head_e'));w['head']=apply(src('head_w'),mirror);V['W']=(w,[SWAP.get(k,k) for k in SIDE_ORDER])
    N=base_view('head_back',mirror,'torso_back',idn,34.0);V['N']=(N,BACK)
    NE=base_view('head_back',chain(mirror,warp(1.1,.8,22,930)),'torso_back',warp(.84,1.1,14,960),0.0);V['NE']=(NE,BACK)
    NW=mirrored(base_view('head_back',idn,'torso_back',warp(.84,1.1,14,960),0.0));NW['head']=apply(src('head_back'),chain(mirror,warp(.8,1.1,-22,930)));V['NW']=(NW,BACK)
    return V
def side_view_filled(h):
    v=side_view();v['head']=src(h);return v

OBRA_C='#ffd400'
def M(pairs): return dict(pairs)
HEADS=[({},''),
 ({LILAC:GOLD,LILAC_L:'#ffd978',LILAC_D:GOLD_D,CYAN:'#2a2a3a','#0b6a9c':INK,FUR:'#c9561a',FUR_L:'#ff9a3a'},''),
 ({LILAC:'#9aa2d8'},'circlet'),
 ({LILAC:'#c9c5b0',LILAC_L:'#efe9cf',LILAC_D:'#6f6a58',CYAN:'#ffd97a','#0b6a9c':GOLD_D},'crest'),
 ({LILAC:'#6d3f9e',LILAC_L:'#a074d0',LILAC_D:'#3a1f68',CYAN:WHITE},'horns'),
 ({CYAN:'#58f0ff'},'mohawk'),
 ({LILAC:'#3a3a78',LILAC_L:'#6868b8',LILAC_D:'#1f1f4a'},'antenna'),
 ({LILAC:'#5c3a86',LILAC_L:'#8a60b8',LILAC_D:'#2f1f50',CYAN:'#ff2b3a','#0b6a9c':'#7a1020'},'dome'),
 ({LILAC:'#2a8a8a',LILAC_L:'#62c4b8',LILAC_D:'#134a54',CYAN:OBRA_C,'#0b6a9c':GOLD_D},'circlet'),
 ({FUR:'#b33a18',LILAC:'#7aa0f0',LILAC_L:'#b4ccff'},'')]

def pal(main,light,dark,metal,acc=GOLD,tip=CREAM):
    return {PURP:main,PURP_L:light,NAVY:dark,NAVY_L:mixh(dark,light,.35),LILAC:metal,LILAC_L:mixh(metal,'#ffffff',.45),WHITE:mixh(metal,'#ffffff',.7),GOLD:acc,GOLD_D:mixh(acc,'#000000',.4),CREAM:tip,RUST:mixh(main,'#a8482a',.5),FUR_D:mixh(main,'#000000',.4),FUR:mixh(main,'#ff6a00',.5)}
def mixh(a,b,t):
    ca,cb=rgb(a),rgb(b);return hexc([ca[i]+(cb[i]-ca[i])*t for i in range(3)])
A1=[({},''),
 (pal('#6a2ba8','#a06ae0','#241247','#e8e2f8',GOLD),'plate'),
 (pal('#2a2a6a','#6a6ae0','#10102e','#e0e8ff','#ffd400','#f0d8b0'),'ring'),
 (pal('#a01f3a','#e04860','#3a0f22','#e8e2f8','#ffd400'),'spikes'),
 (pal('#3a3a6a','#7a7ac0','#12122e','#f0f0ff','#d8c8ff','#ffffff'),'blade'),
 (pal('#0a7fc2','#37d0ff','#072a50','#b0f0ff','#00e5ff','#d8ffff'),'cannon'),
 (pal('#2a2a3a','#5a5a78','#0f0f1a','#c8c8d8','#00e5ff','#a0ffff'),'flame'),
 (pal('#8a8a2a','#d8d860','#2a2a10','#f0f0c0','#ffd400'),'ring'),
 (pal('#0a4a9a','#2a8ae0','#071a3a','#a0d8ff','#00e5ff','#d0f0ff'),'plate'),
 (pal('#5a3a1a','#b08050','#20140a','#f0dcc0','#ff6a00'),'spikes'),
 (pal('#0a8aa8','#40d8f0','#04303f','#d0f8ff','#00e5ff','#ffffff'),'blade'),
 (pal('#7a1f5a','#c0509a','#2a0f2a','#f0d0e8','#ffd400'),'cannon'),
 (pal('#1a1a2a','#4a4a60','#0a0a14','#d0d0e0','#ffffff'),'plate'),
 (pal('#a85a10','#f0a030','#3a1a08','#ffe0a0','#ffd400'),'flame'),
 (pal('#4a2a9a','#8a60e0','#1a0f40','#c0b0ff','#c6ff00'),'ring'),
 (pal('#6a7a1a','#b0c840','#20280a','#e8f0b0','#c6ff00'),'spikes'),
 (pal('#c0c0d0','#ffffff','#3a3a4a','#ffffff','#ff1f8f','#ffffff'),'blade'),
 (pal('#b01a1a','#ff5030','#3a0a0a','#ffd0a0','#ff6a00'),'flame'),
 (pal('#1a7a7a','#40d0c0','#072a30','#c0fff0','#ffd400'),'cannon'),
 (pal('#8a6a1a','#e0c050','#2a200a','#fff0b0','#ff6a00'),'plate')]
def lp(pants,light,skirt,shoe,sole,acc=GOLD):
    return {NAVY:pants,NAVY_L:light,PURP:pants,PURP_L:light,OLIVE:skirt,OLIVE_D:mixh(skirt,'#000000',.4),CREAM:sole,PINK:mixh(sole,'#ff80a0',.3),GOLD:acc,BROWN:mixh(skirt,'#3a2a1a',.5),RUST:mixh(skirt,'#a8482a',.6)}
L1=[({},''),
 (lp('#3a2a5a','#7a60a0','#a09070','#3a2a5a','#f0e0c0'),'kneepad'),
 (lp('#c8b890','#f0e6c8','#7a6a50','#3a3050','#ffffff'),'plates'),
 (lp('#a04a18','#f08030','#5a2a10','#2a2030','#f0e0c0','#ff6a00'),'tubes'),
 (lp('#7a6a1a','#c8b840','#4a4410','#1a1420','#e0d090','#ffd400'),'wheel'),
 (lp('#4a2a7a','#a050d0','#ff1f8f','#2a1a40','#70e0ff','#00e5ff'),'tubes'),
 (lp('#b8905a','#ecc890','#7a5a30','#3a2a20','#f0d8a0'),'kneepad'),
 (lp('#5a3a2a','#a87050','#3a2a1a','#2a2030','#c8a880','#ff6a00'),'spikes'),
 (lp('#2a4a8a','#5a90e0','#1a2a50','#10182e','#a0c8ff','#00e5ff'),'wheel'),
 (lp('#3a3a4a','#8088a0','#5a2a2a','#1a1a24','#e0e0e0','#ff6a00'),'plates')]

def seg_cross(a,b,c,d):
    def o(p,q,r): return (q[0]-p[0])*(r[1]-p[1])-(q[1]-p[1])*(r[0]-p[0])
    return o(a,b,c)*o(a,b,d)<0 and o(c,d,a)*o(c,d,b)<0
def simple(q):
    n=len(q)
    for i in range(n):
        for j in range(i+2,n):
            if i==0 and j==n-1: continue
            if seg_cross(q[i],q[(i+1)%n],q[j],q[(j+1)%n]): return False
    return True
BAD=[]
def bake_shapes(shapes,where):
    ox,oy=ORIGIN;out=[]
    for i,s in enumerate(shapes):
        pts=[]
        for x,y in s['q']:
            pt=[round(x-ox,1),round(y-oy,1)]
            if not pts or pts[-1]!=pt: pts.append(pt)
        if 'line' in s:
            out.append(dict(line=pts,c=s['line'],w=s['w']));continue
        if len(pts)>2 and pts[0]==pts[-1]: pts.pop()
        if not simple(pts): BAD.append((where,i))
        e=dict(p=pts,o=s['o'])
        if s['grad']: e['g']=list(s['grad'])
        else: e['c']=s['fill']
        if s['alpha']!=1.0: e['a']=s['alpha']
        out.append(e)
    return out
def bake():
    ox,oy=ORIGIN;res={}
    for vn,(parts,order) in views().items():
        res[vn]=dict(order=order,parts={k:dict(pivot=[round(p['pivot'][0]-ox,1),round(p['pivot'][1]-oy,1)],shapes=bake_shapes(p['shapes'],f'{vn}/{k}'),addons={a:bake_shapes(v,f'{vn}/{k}/{a}') for a,v in p['addons'].items()}) for k,p in parts.items()})
    if BAD: print('AUTOINTERSECCION',BAD[:30],len(BAD))
    return dict(views=res,variants=dict(head=[dict(map=m,addon=a) for m,a in HEADS],arm=[dict(map=m,addon=a) for m,a in A1],leg=[dict(map=m,addon=a) for m,a in L1]))
if __name__=='__main__':
    json.dump(bake(),open(sys.argv[1],'w'),separators=(',',':'),ensure_ascii=False)
