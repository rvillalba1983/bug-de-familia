#!/usr/bin/env python3
"""Genera los objetos de la beta en art/beta/props/. Origen: Claude, sin servicios externos."""
from pathlib import Path

OUT = Path(__file__).resolve().parents[2] / "art/beta/props"
INK, BER, CIAN, AZUL, ROSA, NAR, AMA, ACIDO, MOHO, OXI, HIER, HUE = (
    "#1B0E2A", "#6A2BA8", "#00E5FF", "#0A7FC2", "#FF1F8F", "#FF6A00",
    "#FFD400", "#C6FF00", "#2FBF71", "#A8482A", "#8894B5", "#F6E7C8",
)
STROKE = f'stroke="{INK}" stroke-width="5" stroke-linejoin="round" stroke-linecap="round"'


def r(x, y, w, h, fill, rx=4, extra=""):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" {STROKE} {extra}/>'


def c(x, y, rad, fill):
    return f'<circle cx="{x}" cy="{y}" r="{rad}" fill="{fill}" {STROKE}/>'


def p(points, fill):
    return f'<polygon points="{points}" fill="{fill}" {STROKE}/>'


def l(d, color=INK, width=5):
    return f'<path d="{d}" fill="none" stroke="{color}" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round"/>'


def blob(d, fill):
    return f'<path d="{d}" fill="{fill}" {STROKE}/>'


def shadow(x, y, rx, ry):
    return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{INK}" opacity="0.35"/>'


PROPS = {
    "caja": (130, 120, shadow(65, 108, 56, 10) + r(14, 26, 102, 82, OXI) + r(14, 26, 102, 20, NAR)
             + l("M20 50 L110 104") + l("M110 50 L20 104") + c(30, 92, 5, AMA) + c(100, 92, 5, AMA)),
    "caja_rota": (160, 80, shadow(80, 68, 72, 9) + p("12,66 34,28 62,48 70,66", OXI) + p("70,66 88,18 124,40 112,66", NAR)
                  + p("112,66 132,44 150,66", OXI) + l("M46 40 L52 62") + l("M96 30 L92 60")),
    "terminal": (112, 168, shadow(56, 156, 46, 10) + r(22, 80, 68, 76, AZUL) + r(10, 12, 92, 76, HIER, 10)
                 + r(22, 24, 68, 50, CIAN, 6) + l("M32 40 L60 40 M32 54 L78 54", INK, 4) + c(40, 116, 8, ROSA) + c(70, 116, 8, AMA)),
    "pierna": (120, 120, shadow(60, 108, 44, 9) + r(44, 8, 34, 50, HIER, 10) + c(60, 62, 14, AMA)
               + r(46, 68, 30, 34, AZUL, 8) + blob("M40 100 H96 Q104 112 92 112 H42 Q34 112 40 100Z", ROSA)),
    "brazo": (120, 120, shadow(60, 108, 44, 9) + r(10, 54, 50, 28, HIER, 10) + c(62, 68, 14, AMA)
              + r(66, 54, 26, 28, AZUL, 8) + l("M92 56 L112 42 M94 68 L116 68 M92 80 L112 94", INK, 9) + l("M92 56 L112 42 M94 68 L116 68 M92 80 L112 94", CIAN, 4)),
    "grieta": (140, 140, l("M72 8 L54 44 L82 66 L52 96 L70 132", INK, 13) + l("M72 8 L54 44 L82 66 L52 96 L70 132", OXI, 5)
               + l("M18 26 L122 118", ROSA, 11) + l("M122 26 L18 118", ROSA, 11)),
    "generador": (192, 192, shadow(96, 176, 82, 13) + r(20, 66, 152, 108, OXI, 12) + r(36, 84, 70, 62, AZUL, 8)
                  + l("M48 100 H94 M48 116 H94 M48 132 H94", INK, 5) + c(136, 112, 24, AMA) + l("M136 92 L128 114 H144 L136 134", INK, 5)
                  + r(140, 20, 22, 50, HIER, 5) + blob("M151 18 Q130 2 150 -2 Q172 2 151 18Z", CIAN)),
    "panel": (144, 192, shadow(72, 180, 60, 10) + r(16, 12, 112, 168, HIER, 10) + r(30, 28, 84, 48, CIAN, 6)
              + l("M42 44 H90 M42 60 H72", INK, 5) + "".join(c(46 + x * 26, 100 + y * 26, 9, [ROSA, AMA, ACIDO][(x + y) % 3]) for x in range(3) for y in range(3))),
    "contestador": (170, 200, shadow(85, 188, 72, 11) + r(26, 112, 118, 76, BER, 8) + blob("M22 104 Q24 56 85 56 Q146 56 148 104Z", AZUL)
                    + c(85, 80, 17, HUE) + c(85, 80, 7, INK) + blob("M12 44 Q16 8 85 8 Q154 8 158 44 Q150 60 128 46 Q124 30 85 30 Q46 30 42 46 Q20 60 12 44Z", ROSA)
                    + r(58, 130, 54, 18, CIAN, 4) + c(62, 168, 7, AMA) + c(108, 168, 7, ACIDO)),
    "sombrero": (120, 92, shadow(60, 78, 52, 8) + blob("M16 70 Q60 86 104 70 Q110 58 92 58 L84 20 Q60 6 36 20 L28 58 Q10 58 16 70Z", OXI)
                 + l("M30 54 Q60 66 90 54", AMA, 7) + c(74, 34, 5, HIER) + c(44, 38, 5, HIER)),
    "acta": (96, 110, shadow(48, 100, 38, 7) + p("14,10 72,10 84,26 84,98 14,98", HUE) + p("72,10 84,26 72,26", HIER)
             + l("M26 38 H72 M26 54 H72 M26 70 H52", BER, 5) + blob("M62 92 q-4 -22 12 -22 q14 0 8 22z", MOHO)),
    "aceite": (200, 84, blob("M12 46 Q24 12 76 20 Q118 2 156 22 Q196 28 186 56 Q164 80 116 68 Q70 84 36 72 Q6 66 12 46Z", INK)
               + '<ellipse cx="74" cy="38" rx="28" ry="8" fill="#6A2BA8"/><ellipse cx="136" cy="34" rx="16" ry="5" fill="#00E5FF" opacity="0.7"/>'),
    "robot_apagado": (210, 180, shadow(105, 164, 92, 12) + r(44, 72, 122, 86, HIER, 18) + r(66, 96, 76, 40, OXI, 6)
                      + blob("M60 76 Q58 22 106 22 Q154 22 150 76Z", HIER) + l("M82 50 L96 62 M96 50 L82 62 M122 50 L136 62 M136 50 L122 62", INK, 6)
                      + l("M106 22 L114 4") + c(116, 6, 5, ROSA) + r(14, 104, 32, 52, AZUL, 10) + r(164, 104, 32, 52, AZUL, 10)),
    "placa": (96, 96, shadow(48, 86, 36, 6) + r(12, 18, 72, 62, AMA, 8) + c(22, 28, 4, INK) + c(74, 28, 4, INK) + c(22, 70, 4, INK) + c(74, 70, 4, INK)
              + l("M30 42 H66 M30 56 H58", INK, 6)),
    "etiqueta": (96, 96, shadow(48, 88, 30, 6) + p("20,30 42,8 84,8 84,62 42,84 20,62", ROSA) + c(38, 30, 7, HUE) + l("M52 36 H74 M52 52 H70", HUE, 5)),
    "soldadura": (130, 110, shadow(65, 98, 56, 8) + r(10, 34, 52, 60, HIER, 4) + r(68, 34, 52, 60, AZUL, 4)
                  + l("M64 26 q-12 10 2 18 q14 10 -2 18 q-14 10 2 18 q12 8 -2 18", NAR, 11) + l("M64 26 q-12 10 2 18 q14 10 -2 18 q-14 10 2 18 q12 8 -2 18", AMA, 4)),
    "restos_fiesta": (180, 120, shadow(90, 106, 80, 10) + p("20,104 36,42 54,104", ROSA) + p("66,104 72,60 98,104", CIAN)
                      + r(106, 66, 54, 38, OXI, 4) + l("M18 34 Q90 72 164 28", INK, 5)
                      + p("44,44 62,44 53,66", AMA) + p("84,52 102,52 93,74", ACIDO) + p("124,44 142,44 133,66", ROSA)),
    "objeto_perdido": (120, 112, shadow(60, 100, 48, 8) + blob("M22 96 Q10 54 38 44 Q32 22 60 20 Q90 22 82 44 Q112 54 98 96Z", NAR) + l("M42 44 Q60 54 80 44", INK, 7) + c(60, 72, 13, AMA) + l("M60 66 V76 M60 82 V82", INK, 5)),
    "guardado": (220, 130, '<ellipse cx="110" cy="96" rx="102" ry="30" fill="#00E5FF" opacity="0.28" stroke="#00E5FF" stroke-width="5"/>'
                 + '<ellipse cx="110" cy="96" rx="66" ry="18" fill="#FF1F8F" opacity="0.3"/>' + r(98, 40, 24, 58, HIER, 6) + c(110, 26, 19, ACIDO) + l("M78 12 Q68 26 78 40 M142 12 Q152 26 142 40", CIAN, 5)),
    "mirador": (360, 300, shadow(180, 278, 160, 18) + r(40, 150, 280, 118, OXI, 8) + l("M60 150 V40 M300 150 V40", INK, 13) + l("M60 150 V40 M300 150 V40", HIER, 5)
                + p("60,40 150,62 60,84", ROSA) + l("M40 186 H320 M40 226 H320", INK, 5)),
    "toldo": (360, 240, r(10, 10, 340, 220, CIAN, 16, 'fill-opacity="0.25"') + "".join(f'<rect x="{10 + i * 68}" y="10" width="34" height="220" fill="{ROSA}" opacity="0.45"/>' for i in range(5))
              + r(10, 10, 340, 220, "none", 16)),
    "camara": (120, 110, l("M60 104 V68", INK, 13) + l("M60 104 V68", HIER, 5) + r(14, 16, 92, 54, AZUL, 12) + c(78, 44, 18, HUE) + c(78, 44, 9, ROSA) + c(30, 30, 6, ROSA)),
}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, (w, h, body) in PROPS.items():
        svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="-2 -6 {w + 4} {h + 8}">{body}</svg>\n'
        (OUT / f"{name}.svg").write_text(svg, encoding="utf8")


if __name__ == "__main__":
    main()
