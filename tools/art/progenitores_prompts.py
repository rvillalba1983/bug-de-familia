#!/usr/bin/env python3
"""Plantilla de prompt para el arte definitivo de los 15 progenitores (P-58).

Fuentes de lore: data/world/progenitors.json (nombre, color, material, propiedad
fija) y data/conversation/progenitors.json (muerte por caída). Este módulo solo
compone texto: no llama a servicios externos ni escribe recursos.

Uso:
    python tools/art/progenitores_prompts.py ramon base
    python tools/art/progenitores_prompts.py --manifiesto tools/manifiesto.json
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
MUNDO = RAIZ / "data" / "world" / "progenitors.json"
DIALOGOS = RAIZ / "data" / "conversation" / "progenitors.json"
SUFIJOS = ("", "_se", "_e", "_ne", "_n")
VISTAS_NOMBRE = ("base", "se", "e", "ne", "n")

# Texto compartido. En inglés porque es la instrucción que recibe el modelo;
# la documentación y el registro en español viven en ORIGEN.md y el ADR.
ESTILO = (
    "Single isolated game character sprite for a 2D stealth game. "
    "STYLE: grotesque cartoon with a painted finish, strange asymmetric "
    "anatomy, exaggerated eyes, mouths and limbs, saturated unnatural colors, "
    "a deliberate mix of appealing and repulsive, visual humor, adult aesthetic. "
    "Thick clean ink outlines in deep purple-black #1B0E2A, painterly shadows "
    "in violet #6A2BA8, crisp cel-painted highlights, readable silhouette, "
    "painted brush texture. "
    "CAMERA: high angled top-down view (Zelda-like), fixed high camera, you see "
    "the face and the foreshortened body, not a flat side elevation, not pure "
    "top-down, not isometric. "
    "DETAIL: subtle signs of an old fall — scuffed edges, one crooked limb, a "
    "small crack or a dizzy eye — because this being once fell and died. "
    "OUTPUT: one full-body character centered with margin, isolated on a "
    "plain pure white background with no scenery, no floor, no ground shadow, "
    "no text, no letters, no numbers, no watermark, no border, no frame. "
    "Vertical canvas, slightly taller than wide, about 256 by 280 proportions."
)

# Rasgos visuales por progenitor: silueta, rasgo de la propiedad fija y guiño
# a la muerte por caída. Todo derivado del nombre, material y lore del JSON.
PERSONAJES: dict[str, dict[str, str]] = {
    "ramon": {
        "visual": "A grumpy elderly handyman, heavy amber nano-steel plating "
                  "with tiny rivets, a crooked moustache, a wrench fused to one "
                  "hand, one eye bigger than the other",
        "propiedad": "a small broken hinge on the chest that still clicks (p047)",
        "caida": "a bandaged knee and an ashamed, regretful half-glance",
    },
    "contestador": {
        "visual": "A squat blue answering-machine creature, a gel-memory body "
                  "that keeps every dent, a speaker grille for a face, two "
                  "reel-to-reel tape wheels and loose recording cables",
        "propiedad": "one empty memory reel spinning on its own (p049)",
        "caida": "a cracked casing with a loop of garbled recording leaking out",
    },
    "biela": {
        "visual": "A lanky silver being built around one enormous mechanical "
                  "knee, connecting-rod limbs and polished nano-steel joints, "
                  "a smug mechanical grin",
        "propiedad": "a detachable knee piston marked with a serial notch (p004)",
        "caida": "the perfect knee now slightly bent the wrong way",
    },
    "pliegue_oculto": {
        "visual": "A lavender photonic-fiber being folded into itself, parts of "
                  "the body missing or creased into glowing light, a shy "
                  "almost-invisible face",
        "propiedad": "one sharp luminous fold that should not exist (p013)",
        "caida": "a crumpled corner that never unfolded after the fall",
    },
    "papel_cebolla": {
        "visual": "A pale layered being made of translucent onion-paper sheets "
                  "around a plasma-crystal core, teary eyes, several overlapping "
                  "see-through silhouettes",
        "propiedad": "a transparent protocol sheet pinned to the chest (p008)",
        "caida": "one outer layer peeled off and left transparent",
    },
    "susurro": {
        "visual": "A shy cyan plasma-crystal ghost with a hushing gesture, big "
                  "round eyes, a translucent crystalline body and visible sound "
                  "ripples around the hands",
        "propiedad": "a stolen voice coiled in a crystal near the mouth (p009)",
        "caida": "a hairline fracture where the last whisper escaped",
    },
    "frecuencia": {
        "visual": "A flamboyant magenta photonic-fiber diva, an enormous open "
                  "singing mouth, dramatic lashes, a gown woven from glowing "
                  "light fibers and receipts as hair",
        "propiedad": "a vibrating receipt held at a perfect high note (p019)",
        "caida": "one earring hanging at a slightly wrong octave",
    },
    "boletina": {
        "visual": "A green bioceramic mushroom lady with a glazed organic cap, a "
                  "painted ballot-paper face under the brim and a smug smile",
        "propiedad": "a living voting hat with its own loud mouth (p028)",
        "caida": "a dented cap still casting its lone opposing vote",
    },
    "yesquero": {
        "visual": "An extremely mushroomy yellow-green bioceramic fungus man, "
                  "three stacked caps, spore dots and an overconfident grin",
        "propiedad": "a championship tinder-cap badge on the biggest mushroom (p026)",
        "caida": "a slightly squashed cap from the landing",
    },
    "fiador": {
        "visual": "A gold magnetic-alloy appraiser with greedy magnifying eyes, "
                  "a little balance scale and calipers, scraps of metal floating "
                  "around him",
        "propiedad": "an organ-appraisal tag dangling from one hand (p021)",
        "caida": "a crooked scale still weighing an unpaid debt",
    },
    "garantia": {
        "visual": "A smug golden magnetic-alloy lady with a stamped contract "
                  "sash, a crisp business smile and small tools hovering around "
                  "her belt",
        "propiedad": "a three-second countdown stamp on her wrist (p022)",
        "caida": "one high heel chipped at the fourth second",
    },
    "avalista": {
        "visual": "A teal scrap-metal loan shark with several mismatched extra "
                  "arms for rent, riveted plates and a moneylender's sneer",
        "propiedad": "a rented arm with a price tag swinging from it (p044)",
        "caida": "one loose arm still reaching for the rent",
    },
    "cartero": {
        "visual": "A spectral postal worker in blue quantum wood, a shifting "
                  "grain satchel, a peaked cap and ghostly letters drifting out",
        "propiedad": "one last undelivered envelope glowing in the bag (p036)",
        "caida": "a scuffed satchel corner from the final route",
    },
    "paquete": {
        "visual": "A cardboard-box-bodied inspector in brown quantum wood with "
                  "probability seams, an inspector badge and a curious eye "
                  "peeking through the flaps",
        "propiedad": "a half-opened parcel he is secretly inspecting (p038)",
        "caida": "a crushed corner where the best piece was kept",
    },
    "ultimo_mono": {
        "visual": "A scruffy grey memory-gel robot monkey with an absurd "
                  "flamboyant wig, drooping eyes and a tired, self-deprecating "
                  "posture",
        "propiedad": "a memory-gel wig that refuses to fall off (p050)",
        "caida": "a dented ear with the wig still perfectly intact",
    },
}

VISTAS: dict[str, str] = {
    "base": "VIEW: front view, facing the camera directly.",
    "se": "VIEW: three-quarter view facing lower-right (southeast), turning "
          "about 45 degrees to the right, still seeing the face.",
    "e": "VIEW: side profile facing right (east), the far-side limbs partly "
         "hidden behind the body.",
    "ne": "VIEW: three-quarter rear view facing upper-right (northeast), turning "
          "away about 135 degrees, seeing more back than face.",
    "n": "VIEW: rear view facing away from the camera (north), back of the head "
         "and body, no visible face.",
}


def cargar_lore() -> dict:
    mundo = json.loads(MUNDO.read_text(encoding="utf-8"))
    dialogos = json.loads(DIALOGOS.read_text(encoding="utf-8"))
    return {"mundo": mundo, "dialogos": dialogos}


def construir_prompt(identificador: str, vista: str, lore: dict | None = None) -> str:
    """Devuelve el prompt completo para un progenitor y una vista."""
    if vista not in VISTAS:
        raise ValueError("vista desconocida: %s" % vista)
    lore = lore or cargar_lore()
    datos = lore["mundo"][identificador]
    muerte = lore["dialogos"][identificador]["death"]
    rasgos = PERSONAJES[identificador]
    return " ".join((
        "SUBJECT: %s." % datos["name"],
        "%s." % rasgos["visual"],
        "Material: %s — make the surface and texture unmistakable."
        % datos["material"],
        "Main color: %s, used across the body." % datos["color"],
        "Fixed property visual: %s." % rasgos["propiedad"],
        "Lore of the fall: %s Show it as %s." % (muerte, rasgos["caida"]),
        VISTAS[vista],
        ESTILO,
    ))


def manifiesto() -> list[dict]:
    lore = cargar_lore()
    salida: list[dict] = []
    for identificador in lore["mundo"]:
        for vista in VISTAS_NOMBRE:
            sufijo = SUFIJOS[VISTAS_NOMBRE.index(vista)]
            salida.append({
                "id": identificador,
                "vista": vista,
                "sufijo": sufijo,
                "archivo": "%s%s" % (identificador, sufijo),
                "prompt": construir_prompt(identificador, vista, lore),
            })
    return salida


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("id", nargs="?", help="id del progenitor")
    parser.add_argument("vista", nargs="?", choices=VISTAS_NOMBRE,
                        help="nombre de la vista")
    parser.add_argument("--manifiesto", type=Path,
                        help="escribe los 75 prompts en un JSON")
    args = parser.parse_args()
    if args.manifiesto:
        datos = manifiesto()
        args.manifiesto.parent.mkdir(parents=True, exist_ok=True)
        args.manifiesto.write_text(
            json.dumps(datos, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8", newline="\n",
        )
        print("OK: %d prompts en %s" % (len(datos), args.manifiesto))
        return
    if not args.id or not args.vista:
        parser.error("indica id y vista, o usa --manifiesto")
    print(construir_prompt(args.id, args.vista))


if __name__ == "__main__":
    main()
