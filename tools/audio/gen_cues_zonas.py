#!/usr/bin/env python3
"""Añade 69 cues zonales de cuerda pulsada sin regenerar la biblioteca.

Uso: python3 tools/audio/gen_cues_zonas.py [carpeta_del_proyecto]
Necesita numpy, scipy y ffmpeg con libvorbis. Solo escribe los OGG que faltan,
comprueba que no haya entradas sin archivo (ni archivos sin entrada) y deja
intactas las 110 pistas y las 120 voces anteriores. Sin servicios externos.
"""
import json
import os
import shutil
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_audio as base
import gen_cuerda_cues as cues

ORIGEN = ("tools/audio/gen_audio.py + tools/audio/gen_cuerda_cues.py + "
          "tools/audio/gen_cues_zonas.py, Claude, sintesis local, "
          "26-nov-2026, sin servicios externos")
ESTADOS = ("dia", "noche", "tension")
LEADS = ("guitarra", "laud", "oud", "shamisen")
PRIMERA_SEMILLA = 111
BASE_RNG = 30000
TOTAL_CUES = 69
ZONAS_ESPERADAS = 23
EXCLUIDAS = {"despliegue_cero"}
PREFIJO = "res://audio/music/"
CLAVES = ("file", "state", "zone", "any_zone", "intensity", "bpm", "bpm_fin",
          "scale", "duration", "layers", "crossfade", "lead", "palette",
          "ambient")


def raiz_proyecto():
    """Carpeta del proyecto: argumento opcional o padre de tools/audio."""
    explicitas = [a for a in sys.argv[1:] if not a.startswith("--")]
    if explicitas:
        return os.path.abspath(explicitas[0])
    return os.path.dirname(os.path.dirname(os.path.dirname(
        os.path.abspath(__file__))))


ROOT = raiz_proyecto()
base.ROOT = ROOT


def zonas():
    """Ids de data/zones/*.json, ordenados y sin despliegue_cero."""
    carpeta = os.path.join(ROOT, "data", "zones")
    ids = []
    for nombre in sorted(os.listdir(carpeta)):
        if not nombre.endswith(".json"):
            continue
        with open(os.path.join(carpeta, nombre), "r", encoding="utf8") as fuente:
            zona = json.load(fuente)
        if zona.get("id") not in EXCLUIDAS:
            ids.append(str(zona["id"]))
    if len(ids) != ZONAS_ESPERADAS or len(set(ids)) != ZONAS_ESPERADAS:
        raise SystemExit(
            "Se esperaban %d zonas distintas; se han leído %d"
            % (ZONAS_ESPERADAS, len(ids)))
    return sorted(ids)


def preparar_entradas():
    """69 entradas internas con semillas fijas y lead rotado."""
    entradas = []
    n = PRIMERA_SEMILLA
    for id_zona in zonas():
        for estado in ESTADOS:
            rng = np.random.default_rng(BASE_RNG + n)
            parametros = cues.PARAMETROS[estado]
            tension = estado == "tension"
            bpm = int(rng.integers(*parametros["bpm"]))
            entradas.append(dict(
                n=n,
                file="zona_%s_%s.ogg" % (id_zona, estado),
                state=estado,
                zone=id_zona,
                any_zone=False,
                intensity=parametros["intensity"],
                bpm=bpm,
                bpm_fin=bpm + 18 if tension else bpm,
                scale=str(rng.choice(parametros["scale"])),
                duration=round(float(rng.uniform(*parametros["duration"])), 2),
                layers=3,
                crossfade=parametros["crossfade"],
                lead=LEADS[(n - PRIMERA_SEMILLA) % len(LEADS)],
                palette="cuerda_zonal",
                ambient=not tension,
            ))
            n += 1
    if n - PRIMERA_SEMILLA != TOTAL_CUES:
        raise SystemExit(
            "Se esperaban %d cues; se han preparado %d"
            % (TOTAL_CUES, n - PRIMERA_SEMILLA))
    return entradas


def metadatos(entrada):
    """Entrada del catálogo, sin la semilla interna 'n'."""
    datos = {clave: entrada[clave] for clave in CLAVES}
    datos["file"] = PREFIJO + entrada["file"]
    return datos


def comprobar(entradas, pistas):
    """Devuelve solo las entradas pendientes; falla ante cualquier incoherencia."""
    por_archivo = {}
    for pista in pistas:
        archivo = pista.get("file")
        if archivo in por_archivo:
            raise SystemExit("Archivo duplicado en el catálogo: %s" % archivo)
        por_archivo[archivo] = pista
    esperados = {PREFIJO + e["file"] for e in entradas}
    for archivo in por_archivo:
        if archivo.startswith(PREFIJO + "zona_") and archivo not in esperados:
            raise SystemExit("Entrada zonal desconocida: %s" % archivo)
    nombres = {e["file"] for e in entradas}
    carpeta = os.path.join(ROOT, "audio", "music")
    for nombre in os.listdir(carpeta):
        if nombre.startswith("zona_") and nombre.endswith(".ogg") and nombre not in nombres:
            raise SystemExit("OGG zonal desconocido: %s" % nombre)
    pendientes = []
    for entrada in entradas:
        archivo = PREFIJO + entrada["file"]
        ruta = os.path.join(carpeta, entrada["file"])
        en_catalogo = archivo in por_archivo
        en_disco = os.path.isfile(ruta)
        if en_catalogo != en_disco:
            raise SystemExit(
                "Incoherencia en %s: entrada=%s, OGG=%s"
                % (entrada["file"], en_catalogo, en_disco))
        if en_catalogo:
            if por_archivo[archivo] != metadatos(entrada):
                raise SystemExit(
                    "Metadatos distintos en %s; no se sobrescribe" % archivo)
        else:
            pendientes.append(entrada)
    return pendientes


def main():
    if shutil.which("ffmpeg") is None:
        candidato = r"C:\Users\usuario\opencode_projects\ffmpeg\bin"
        if os.path.isdir(candidato):
            os.environ["PATH"] = candidato + os.pathsep + os.environ.get("PATH", "")
    if shutil.which("ffmpeg") is None:
        raise SystemExit("No se ha encontrado ffmpeg con libvorbis")
    ruta = os.path.join(ROOT, "data", "audio", "library.json")
    with open(ruta, "r", encoding="utf8") as fuente:
        datos = json.load(fuente)
    entradas = preparar_entradas()
    pendientes = comprobar(entradas, datos["tracks"])
    picos = [cues.track_cuerda(entrada) for entrada in pendientes]
    if pendientes:
        datos["tracks"] = datos["tracks"] + [metadatos(e) for e in pendientes]
    cambio_origen = datos.get("origin") != ORIGEN
    if cambio_origen:
        datos["origin"] = ORIGEN
    if pendientes or cambio_origen:
        with open(ruta, "w", encoding="utf8", newline="\n") as salida:
            json.dump(datos, salida, ensure_ascii=False, indent=1)
            salida.write("\n")
        estado = "catalogo actualizado"
    else:
        estado = "sin cambios: catalogo y OGG intactos"
    pico = round(max(picos), 3) if picos else "n/a (sin generacion)"
    print("zonas %d, cues %d, creados %d, pistas totales %d, pico max %s, %s"
          % (len(zonas()), len(entradas), len(pendientes), len(datos["tracks"]),
             pico, estado))


if __name__ == "__main__":
    main()
