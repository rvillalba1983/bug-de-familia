#!/usr/bin/env python3
"""Deriva las cuatro vistas restantes a partir de la vista base (P-58).

Cuando el modelo de imágenes no está disponible, este script aproxima
las vistas _se, _e, _ne y _n mediante transformaciones deterministas de la
vista base: escalado horizontal, espejo y ajuste de luminancia para simular
el giro y la vuelta. El fondo blanco se preserva para que el convertidor
posterior pueda eliminarlo. No sustituye al arte generado con modelo, pero
mantiene las cinco vistas coherentes en paleta y silueta.

Uso:
    python tools/art/progenitores_derivar_vistas.py --entrada <dir> --salida <dir>

El directorio de entrada debe contener los 15 raster base (<id>.webp/.png).
El directorio de salida recibe las vistas derivadas (<id><sufijo>.png).
"""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

import numpy as np
from scipy import ndimage

RAIZ = Path(__file__).resolve().parents[2]
PROGENITORES = RAIZ / "data" / "world" / "progenitors.json"
FFMPEG = Path(r"C:\Users\usuario\opencode_projects\ffmpeg\bin\ffmpeg.exe")
if not FFMPEG.is_file():
    FFMPEG = Path("ffmpeg")
FFPROBE = FFMPEG.with_name("ffprobe.exe") if FFMPEG.name == "ffmpeg.exe" else Path("ffprobe")

SUFIJOS = ("_se", "_e", "_ne", "_n")

# (escala_x, espejo, oscurecido, tinte_violeta)
TRANSFORMACIONES: dict[str, tuple[float, bool, float, float]] = {
    "_se": (0.82, False, 0.0, 0.0),
    "_e": (0.48, False, 0.0, 0.0),
    "_ne": (0.82, True, 0.12, 0.18),
    "_n": (0.92, True, 0.22, 0.30),
}
UMBRAL_FONDO = 232


def leer_raster(ruta: Path) -> tuple[np.ndarray, int, int]:
    """Decodifica el raster a RGB; devuelve (pixeles, ancho, alto)."""
    info = subprocess.run(
        [str(FFPROBE), "-v", "error", "-select_streams", "v:0",
         "-show_entries", "stream=width,height", "-of", "csv=p=0:s=x", str(ruta)],
        capture_output=True, text=True, check=True,
    )
    ancho, alto = (int(x) for x in info.stdout.strip().split("x"))
    crudo = subprocess.run(
        [str(FFMPEG), "-v", "error", "-i", str(ruta), "-f", "rawvideo",
         "-pix_fmt", "rgb24", "-"],
        capture_output=True, check=True,
    ).stdout
    return np.frombuffer(crudo, dtype=np.uint8).reshape(alto, ancho, 3), ancho, alto


def escribir_raster(imagen: np.ndarray, ruta: Path) -> None:
    """Codifica RGB a PNG."""
    alto, ancho = imagen.shape[:2]
    subprocess.run(
        [str(FFMPEG), "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
         "-s", "%dx%d" % (ancho, alto), "-i", "-", str(ruta)],
        input=imagen.tobytes(), capture_output=True, check=True,
    )


def transformar(imagen: np.ndarray, sufijo: str) -> np.ndarray:
    """Aplica la transformación determinista correspondiente a una vista."""
    escala, espejo, oscurecido, tinte = TRANSFORMACIONES[sufijo]
    fondo = imagen.min(axis=2) >= UMBRAL_FONDO

    resultado = np.fliplr(imagen) if espejo else imagen.copy()
    resultado_fondo = np.fliplr(fondo) if espejo else fondo.copy()

    if escala != 1.0:
        alto, ancho = imagen.shape[:2]
        nuevo_ancho = max(1, round(ancho * escala))
        resultado = ndimage.zoom(
            resultado, (1.0, nuevo_ancho / ancho, 1.0), order=1,
        ).astype(np.uint8)
        resultado_fondo = ndimage.zoom(
            resultado_fondo.astype(np.uint8), (1.0, nuevo_ancho / ancho),
            order=0,
        ).astype(bool)

    if oscurecido or tinte:
        rgb = resultado.astype(np.float32)
        if oscurecido:
            rgb *= (1.0 - oscurecido)
        if tinte:
            violeta = np.array([106.0, 43.0, 168.0], dtype=np.float32)
            rgb = rgb * (1.0 - tinte) + violeta * tinte
        resultado = np.clip(rgb, 0, 255).astype(np.uint8)

    resultado[resultado_fondo] = 255
    return resultado


def derivar(entrada: Path, salida: Path) -> None:
    salida.mkdir(parents=True, exist_ok=True)
    total = 0
    identificadores = json.loads(PROGENITORES.read_text(encoding="utf-8")).keys()
    for identificador in identificadores:
        bases = [p for p in (*entrada.glob(identificador + ".webp"),
                           *entrada.glob(identificador + ".png"))]
        if not bases:
            print("AVISO: sin base para %s" % identificador)
            continue
        imagen, _, _ = leer_raster(bases[0])
        for sufijo in SUFIJOS:
            destino = salida / (identificador + sufijo + ".png")
            if destino.exists():
                continue
            escribir_raster(transformar(imagen, sufijo), destino)
            total += 1
            print("OK %s -> %s" % (bases[0].name, destino.name))
    print("OK: %d vistas derivadas" % total)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--entrada", type=Path, required=True)
    parser.add_argument("--salida", type=Path, required=True)
    args = parser.parse_args()
    derivar(args.entrada, args.salida)


if __name__ == "__main__":
    main()
