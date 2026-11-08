#!/usr/bin/env python3
"""Genera data/art/protagonista.json: el Sujeto Sobrante como polígonos que dibuja Godot.
Coordenadas calcadas de la hoja de diseño (recorte 1410x1155). Origen final: entre los pies."""
import json, math, sys, os

INK='#120a1e'; FUR='#d9541a'; FUR_L='#f07a25'; FUR_D='#8f2f14'; SKIN='#e9a768'; SKIN_D='#b86c3f'
LILAC='#8c8fe0'; LILAC_L='#b9bdf5'; LILAC_D='#4c4a9c'; CYAN='#21d4ff'; NAVY='#1f1740'; NAVY_L='#35285f'
PURP='#4a2478'; PURP_L='#7a45b5'; MAG='#c21f7a'; MAG_D='#6d1650'; GOLD='#f0b52e'; GOLD_D='#94601a'
CREAM='#f4d9b0'; PINK='#e8a0b0'; OLIVE='#79803a'; OLIVE_D='#4a4d24'; RUST='#b4501f'; BROWN='#5d4a38'; WHITE='#f5f2ff'
ORIGIN=(905.0,1118.0)

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

def bake():
    ox,oy=ORIGIN;res={};bad=[]
    for name,part in P.items():
        shapes=[]
        for idx,s in enumerate(part['shapes']):
            pts=[]
            for x,y in s['q']:
                pt=[round(x-ox,1),round(y-oy,1)]
                if not pts or pts[-1]!=pt: pts.append(pt)
            if 'line' in s:
                shapes.append(dict(line=pts,c=s['line'],w=s['w']));continue
            if len(pts)>2 and pts[0]==pts[-1]: pts.pop()
            if not simple(pts): bad.append((name,idx))
            if s['grad']:
                ys=[p[1] for p in pts];y0,y1=min(ys),max(ys);c0,c1=rgb(s['grad'][0]),rgb(s['grad'][1])
                cols=[hexc([c0[i]+(c1[i]-c0[i])*((p[1]-y0)/max(1,y1-y0)) for i in range(3)]) for p in pts]
                shapes.append(dict(p=pts,cs=cols,o=s['o']))
            else:
                shapes.append(dict(p=pts,c=s['fill'],o=s['o']))
        res[name]=dict(pivot=[part['pivot'][0]-ox,part['pivot'][1]-oy],shapes=shapes)
    if bad: print('AUTOINTERSECCION',bad)
    return res
if __name__=='__main__':
    json.dump(bake(),open(sys.argv[1],'w'),separators=(',',':'),ensure_ascii=False)
