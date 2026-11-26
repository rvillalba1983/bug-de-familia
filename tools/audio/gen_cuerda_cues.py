#!/usr/bin/env python3
"""Añade 10 cues de cuerda pulsada sin regenerar la biblioteca existente.

Uso: python3 tools/audio/gen_cuerda_cues.py [carpeta_del_proyecto]
Necesita numpy, scipy y ffmpeg con libvorbis. Los originales quedan intactos.
"""
import json
import os

import numpy as np

import gen_audio as base

ORIGEN = ("tools/audio/gen_audio.py + tools/audio/gen_cuerda_cues.py, "
          "Claude, sintesis local, 26-nov-2026, sin servicios externos")

# n alto para que las semillas no choquen con las 100 pistas originales.
CUES = [
    dict(n=101, file="cuerda_001.ogg", state="dia", zone="bosque", lead="guitarra"),
    dict(n=102, file="cuerda_002.ogg", state="dia", zone="barrio_jubilado", lead="oud"),
    dict(n=103, file="cuerda_003.ogg", state="dia", zone="barrio_mohocrata", lead="shamisen"),
    dict(n=104, file="cuerda_004.ogg", state="dia", zone="tierra_de_nadie", lead="laud"),
    dict(n=105, file="cuerda_005.ogg", state="noche", zone="bosque", lead="guitarra"),
    dict(n=106, file="cuerda_006.ogg", state="noche", zone="barrio_mohocrata", lead="shamisen"),
    dict(n=107, file="cuerda_007.ogg", state="tension", zone="tierra_de_nadie", lead="oud"),
    dict(n=108, file="cuerda_008.ogg", state="tension", zone="bosque", lead="guitarra"),
    dict(n=109, file="cuerda_009.ogg", state="tension", zone="barrio_jubilado", lead="shamisen"),
    dict(n=110, file="cuerda_010.ogg", state="tension", zone="barrio_mohocrata", lead="laud"),
]

PARAMETROS = {
    "dia": dict(bpm=(56, 68), scale=["dorico", "pentatonica", "mixolidio"],
                intensity=0.25, duration=(38.0, 44.0), crossfade=3.5),
    "noche": dict(bpm=(48, 56), scale=["dorico", "pelog", "hijaz"],
                  intensity=0.18, duration=(40.0, 46.0), crossfade=4.0),
    "tension": dict(bpm=(84, 96), scale=["frigio_dom", "menor_arm", "hijaz"],
                    intensity=0.6, duration=(34.0, 40.0), crossfade=2.0),
}


def guitarra(freq, seconds, rng):
    """Karplus-Strong con cuerpo: guitarra clásica sin muestras externas."""
    pulsacion = base.pluck(freq, seconds, rng, 0.997)
    cuerpo = base.lowpass(pulsacion, 1800)
    return pulsacion + 0.25 * cuerpo


def oud(freq, seconds, rng):
    """Laúd árabe: mástil corto y quinta afinada al aire."""
    return (base.pluck(freq, seconds, rng, 0.991)
            + 0.35 * base.pluck(freq * 1.4983, seconds, rng, 0.988))


def shamisen(freq, seconds, rng):
    """Shamisen: ataque seco y armónico metálico alto."""
    return (base.pluck(freq, seconds, rng, 0.998)
            + 0.12 * base.pluck(freq * 3.01, seconds, rng, 0.985))


LEADS_CUERDA = {
    "guitarra": guitarra,
    "oud": oud,
    "shamisen": shamisen,
    "laud": base.laud,
}


def preparar(indice):
    """Convierte una plantilla en entrada completa del catálogo."""
    rng = np.random.default_rng(26000 + indice)
    plantilla = dict(CUES[indice])
    estado = plantilla["state"]
    parametros = PARAMETROS[estado]
    tension = estado == "tension"
    bpm = int(rng.integers(*parametros["bpm"]))
    plantilla.update(
        palette="cuerda_pulsada",
        ambient=not tension,
        any_zone=tension,
        intensity=parametros["intensity"],
        bpm=bpm,
        bpm_fin=bpm + 18 if tension else bpm,
        scale=str(rng.choice(parametros["scale"])),
        duration=round(float(rng.uniform(*parametros["duration"])), 2),
        layers=3,
        crossfade=parametros["crossfade"],
    )
    return plantilla


def track_cuerda(entry):
    """Cue ambiental o de tensión creciente, sin batería ni muestras."""
    rng = np.random.default_rng(entry["n"] * 7919 + 11)
    escala = base.SCALES[entry["scale"]]
    seconds = entry["duration"]
    total = int(seconds * base.SR)
    mezcla = np.zeros(total)
    clave = int(rng.integers(45, 57))
    lead = LEADS_CUERDA[entry["lead"]]
    tension = entry["state"] == "tension"
    motivo_a = base.motif(rng, escala, 16)
    motivo_b = base.motif(rng, escala, 16)
    forma = [motivo_a, motivo_b, motivo_a, list(reversed(motivo_b))]
    if not tension:
        zumbido = base.drone(base.hz(clave - 12), total, rng)
        mezcla += zumbido * 0.06
    bpm = float(entry["bpm"])
    bpm_fin = float(entry["bpm_fin"])
    at_sec = 0.0
    compas = 0
    while at_sec < seconds:
        paso = 60.0 / bpm / 2.0
        notas = forma[compas % len(forma)]
        for i, nota in enumerate(notas):
            at = (at_sec + i * paso) * base.SR
            densidad = 0.78 if tension else 0.55
            if nota is not None and rng.random() < densidad:
                largo = paso * (1.15 if tension else 2.6)
                ganancia = 0.44 + rng.uniform(-0.05, 0.05)
                sonido = lead(base.hz(clave + 12 + nota), largo, rng)
                base.place(mezcla, sonido, at, ganancia)
            if tension and compas % 2 == 0 and i % 4 == 0:
                raiz = escala[0]
                grave = base.pluck(base.hz(clave + raiz), paso * 1.5, rng, 0.993)
                base.place(mezcla, grave, at, 0.3)
        at_sec += len(notas) * paso
        compas += 1
        progreso = min(1.0, at_sec / seconds)
        bpm = bpm + (bpm_fin - bpm) * progreso
    mezcla = base.lowpass(mezcla, 5200 if tension else 3200)
    t = np.arange(total)
    fundido = (np.minimum(1.0, t / (0.4 * base.SR))
               * np.minimum(1.0, (total - t) / (2.0 * base.SR)))
    mezcla *= fundido
    pico = float(np.max(np.abs(mezcla)))
    mezcla = mezcla / pico * 0.72
    ruta = os.path.join(base.ROOT, "audio/music", entry["file"])
    return base.write(mezcla, ruta, "1")


def anotar_originales(tracks):
    """Añade metadatos sin tocar los campos ni los archivos existentes."""
    for track in tracks:
        if "palette" in track:
            continue
        track["lead"] = base.ZONE_LEAD.get(track["zone"], "laud")
        track["palette"] = "original"
        track["ambient"] = track["state"] in ("dia", "noche")
        track["bpm_fin"] = track["bpm"]


def main():
    ruta = os.path.join(base.ROOT, "data/audio/library.json")
    with open(ruta, "r", encoding="utf8") as fuente:
        datos = json.load(fuente)
    originales = [t for t in datos["tracks"]
                  if not str(t["file"]).startswith("res://audio/music/cuerda_")]
    anotar_originales(originales)
    # Una plantilla por cue: orden fijo y sin duplicados.
    entradas = [preparar(i) for i in range(len(CUES))]
    picos = [track_cuerda(entry) for entry in entradas]
    nuevos = [dict(file="res://audio/music/" + e["file"], state=e["state"],
                   zone=e["zone"], any_zone=e["any_zone"],
                   intensity=e["intensity"], bpm=e["bpm"], bpm_fin=e["bpm_fin"],
                   scale=e["scale"], duration=e["duration"], layers=e["layers"],
                   crossfade=e["crossfade"], lead=e["lead"], palette=e["palette"],
                   ambient=e["ambient"]) for e in entradas]
    datos["tracks"] = originales + nuevos
    datos["origin"] = ORIGEN
    with open(ruta, "w", encoding="utf8", newline="\n") as salida:
        json.dump(datos, salida, ensure_ascii=False, indent=1)
        salida.write("\n")
    print("cues", len(nuevos), "pistas totales", len(datos["tracks"]),
          "pico max", round(max(picos), 3))


if __name__ == "__main__":
    main()
