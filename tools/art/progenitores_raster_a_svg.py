#!/usr/bin/env python3
"""Convierte el raster generado a SVG de juego para los progenitores (P-58).

El modelo devuelve WebP/PNG opaco sobre blanco. Este script recorta el fondo
blanco conectado al borde, recorta al personaje, escala a 512x560 y guarda un
SVG de 256x280 con el mapa de bits incrustado en base64. Así se conservan los
nombres `.svg`, el `viewBox` y las rutas que ya esperan GuardVisual y
validar_datos.py, sin tocar lógica ni datos.

Uso:
    python tools/art/progenitores_raster_a_svg.py --entrada <dir> --salida <dir>

El directorio de entrada debe contener <id><sufijo>.webp (o .png).
"""

from __future__ import annotations

import argparse
import base64
import subprocess
import struct
import zlib
from pathlib import Path

import numpy as np
from scipy import ndimage

FFMPEG = Path(r"C:\Users\usuario\opencode_projects\ffmpeg\bin\ffmpeg.exe")
if not FFMPEG.is_file():
    FFMPEG = Path("ffmpeg")
FFPROBE = FFMPEG.with_name("ffprobe.exe") if FFMPEG.name == "ffmpeg.exe" else Path("ffprobe")
ANCHO, ALTO = 256, 280
LIENZO_ANCHO, LIENZO_ALTO = 512, 560
PIE = 520  ## Los pies a 520/560 = 0.93, como GuardVisual.ART_FEET.
MARGEN = 12


def leer_raster(ruta: Path) -> np.ndarray:
    """Decodifica cualquier raster que entienda ffmpeg a RGBA nativo."""
    proceso = subprocess.run(
        [str(FFMPEG), "-v", "error", "-i", str(ruta), "-f", "rawvideo",
         "-pix_fmt", "rgba", "-"],
        capture_output=True, check=True,
    )
    info = subprocess.run(
        [str(FFPROBE), "-v", "error",
         "-select_streams", "v:0", "-show_entries", "stream=width,height",
         "-of", "csv=p=0:s=x", str(ruta)],
        capture_output=True, text=True, check=True,
    )
    ancho, alto = (int(x) for x in info.stdout.strip().split("x"))
    return np.frombuffer(proceso.stdout, dtype=np.uint8).reshape(alto, ancho, 4)


def quitar_fondo_blanco(imagen: np.ndarray) -> np.ndarray:
    """Hace transparente el blanco conectado con el borde, con antialias."""
    rgb = imagen[:, :, :3].astype(np.int16)
    cerca_blanco = (rgb >= 242).all(axis=2)
    etiquetas, _ = ndimage.label(cerca_blanco, structure=np.ones((3, 3)))
    borde = np.unique(np.concatenate((
        etiquetas[0, :], etiquetas[-1, :], etiquetas[:, 0], etiquetas[:, -1],
    )))
    fondo = np.isin(etiquetas, borde[borde != 0])
    adyacente = ndimage.binary_dilation(fondo, structure=np.ones((3, 3))) & ~fondo
    blancura = np.clip((rgb.min(axis=2) - 232) / 23.0, 0.0, 1.0)
    alfa = np.where(
        fondo, 0, np.where(adyacente, np.rint(255 * (1.0 - blancura)), 255),
    )
    resultado = imagen.copy()
    resultado[:, :, 3] = alfa.astype(np.uint8)
    return resultado


def recortar_y_escalar(imagen: np.ndarray) -> np.ndarray:
    """Recorta al personaje y lo coloca sobre un lienzo 512x560 transparente."""
    filas, columnas = np.nonzero(imagen[:, :, 3] > 8)
    if filas.size == 0:
        raise ValueError("la imagen quedó vacía al quitar el fondo")
    y0, y1 = max(filas.min() - MARGEN, 0), min(filas.max() + MARGEN + 1, imagen.shape[0])
    x0, x1 = max(columnas.min() - MARGEN, 0), min(columnas.max() + MARGEN + 1, imagen.shape[1])
    recorte = imagen[y0:y1, x0:x1]
    alto, ancho = recorte.shape[:2]
    escala = min((LIENZO_ANCHO - 2 * MARGEN) / ancho, PIE / alto)
    nuevo_ancho = max(1, round(ancho * escala))
    nuevo_alto = max(1, round(alto * escala))
    datos = subprocess.run(
        [str(FFMPEG), "-v", "error", "-f", "rawvideo", "-pix_fmt", "rgba",
         "-s", "%dx%d" % (ancho, alto), "-i", "-", "-vf",
         "scale=%d:%d:flags=lanczos" % (nuevo_ancho, nuevo_alto),
         "-f", "rawvideo", "-pix_fmt", "rgba", "-"],
        input=recorte.tobytes(), capture_output=True, check=True,
    ).stdout
    escalado = np.frombuffer(datos, dtype=np.uint8).reshape(
        nuevo_alto, nuevo_ancho, 4
    )
    lienzo = np.zeros((LIENZO_ALTO, LIENZO_ANCHO, 4), dtype=np.uint8)
    x = (LIENZO_ANCHO - nuevo_ancho) // 2
    y = max(0, PIE - nuevo_alto)
    lienzo[y:y + nuevo_alto, x:x + nuevo_ancho] = escalado
    return lienzo


def png_en_memoria(imagen: np.ndarray) -> bytes:
    """Codifica RGBA a PNG con la biblioteca estándar."""
    alto, ancho = imagen.shape[:2]
    filas = bytearray()
    for fila in imagen:
        filas.append(0)
        filas.extend(fila.tobytes())

    def bloque(tipo: bytes, datos: bytes) -> bytes:
        return (
            struct.pack(">I", len(datos)) + tipo + datos
            + struct.pack(">I", zlib.crc32(tipo + datos) & 0xFFFFFFFF)
        )

    return b"".join((
        b"\x89PNG\r\n\x1a\n",
        bloque(b"IHDR", struct.pack(">IIBBBBB", ancho, alto, 8, 6, 0, 0, 0)),
        bloque(b"IDAT", zlib.compress(bytes(filas), 9)),
        bloque(b"IEND", b""),
    ))


def svg_con_raster(datos_png: bytes) -> str:
    """Envuelve el PNG en el SVG que espera el motor."""
    return (
        '<!-- Arte definitivo P-58. Generado con modelo de imagen y '
        'procesado por tools/art/progenitores_raster_a_svg.py. '
        'Origen y modelo: art/shared/progenitores/ORIGEN.md. -->\n'
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'xmlns:xlink="http://www.w3.org/1999/xlink" '
        'width="%d" height="%d" viewBox="0 0 %d %d">\n'
        '<image x="0" y="0" width="%d" height="%d" '
        'xlink:href="data:image/png;base64,%s"/>\n'
        '</svg>\n'
    ) % (
        ANCHO, ALTO, LIENZO_ANCHO, LIENZO_ALTO,
        LIENZO_ANCHO, LIENZO_ALTO,
        base64.b64encode(datos_png).decode("ascii"),
    )


def convertir(entrada: Path, salida: Path) -> None:
    salida.mkdir(parents=True, exist_ok=True)
    total = 0
    for ruta in sorted([*entrada.glob("*.webp"), *entrada.glob("*.png")]):
        imagen = quitar_fondo_blanco(leer_raster(ruta))
        lienzo = recortar_y_escalar(imagen)
        svg = svg_con_raster(png_en_memoria(lienzo))
        destino = salida / (ruta.stem + ".svg")
        destino.write_text(svg, encoding="utf-8", newline="\n")
        total += 1
        print("OK %s -> %s" % (ruta.name, destino.name))
    print("OK: %d imagenes convertidas" % total)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--entrada", type=Path, required=True)
    parser.add_argument("--salida", type=Path, required=True)
    args = parser.parse_args()
    convertir(args.entrada, args.salida)


if __name__ == "__main__":
    main()
