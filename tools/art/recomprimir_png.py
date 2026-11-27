#!/usr/bin/env python3
"""Recompresión PNG sin pérdida, con verificación píxel a píxel.

Prueba varias combinaciones de zlib y solo escribe cuando el resultado es
más pequeño y los datos de imagen sin filtrar son idénticos. Por defecto no
modifica nada: hay que pasar `--aplicar`.

    python tools/art/recomprimir_png.py art/loading/carga_con_npcs.png
    python tools/art/recomprimir_png.py --aplicar art/loading/carga_con_npcs.png

No cambia el formato de píxel ni las etiquetas; solo reemplaza los chunks IDAT.
Tras aplicarlo hace falta `godot --headless --import` para actualizar `.import`.
"""
from __future__ import annotations

import argparse
import json
import struct
import sys
import zlib
from pathlib import Path

FIRMA_PNG = b"\x89PNG\r\n\x1a\n"
ESTRATEGIAS = (
    ("default", zlib.Z_DEFAULT_STRATEGY),
    ("filtered", zlib.Z_FILTERED),
    ("huffman", zlib.Z_HUFFMAN_ONLY),
    ("rle", zlib.Z_RLE),
    ("fixed", zlib.Z_FIXED),
)
NIVELES = range(1, 10)
MEMORIAS = (8, 9)


def leer_chunks(datos: bytes) -> tuple[list[tuple[bytes, bytes]], bytes]:
    """Devuelve los chunks y los datos IDAT concatenados de un PNG."""
    if not datos.startswith(FIRMA_PNG):
        raise ValueError("firma PNG inválida")
    pos = 8
    chunks: list[tuple[bytes, bytes]] = []
    idat = bytearray()
    while pos + 12 <= len(datos):
        longitud = struct.unpack(">I", datos[pos:pos + 4])[0]
        tipo = datos[pos + 4:pos + 8]
        fin = pos + 8 + longitud
        if fin + 4 > len(datos):
            raise ValueError("chunk truncado")
        contenido = datos[pos + 8:fin]
        crc = struct.unpack(">I", datos[fin:fin + 4])[0]
        if zlib.crc32(tipo + contenido) & 0xFFFFFFFF != crc:
            raise ValueError("CRC inválido en " + tipo.decode("latin-1"))
        chunks.append((tipo, contenido))
        if tipo == b"IDAT":
            idat.extend(contenido)
        pos = fin + 4
    if pos != len(datos) or chunks[-1][0] != b"IEND":
        raise ValueError("IEND ausente o bytes sobrantes")
    return chunks, bytes(idat)


def escribir_chunk(tipo: bytes, contenido: bytes) -> bytes:
    crc = zlib.crc32(tipo + contenido) & 0xFFFFFFFF
    return (struct.pack(">I", len(contenido)) + tipo + contenido
            + struct.pack(">I", crc))


def mejor_composicion(pixeles: bytes) -> tuple[bytes, str, int, int]:
    """Devuelve la compresión zlib más pequeña que reproduzca los píxeles."""
    mejor: tuple[bytes, str, int, int] | None = None
    for nombre, estrategia in ESTRATEGIAS:
        for nivel in NIVELES:
            for memoria in MEMORIAS:
                compresor = zlib.compressobj(
                    nivel, zlib.DEFLATED, 15, memoria, estrategia)
                comprimido = compresor.compress(pixeles) + compresor.flush()
                if mejor is not None and len(comprimido) >= len(mejor[0]):
                    continue
                if zlib.decompress(comprimido) != pixeles:
                    continue
                mejor = (comprimido, nombre, nivel, memoria)
    if mejor is None:
        raise ValueError("ninguna combinación de zlib reproduce los píxeles")
    return mejor


def reconstruir(chunks: list[tuple[bytes, bytes]],
                comprimido: bytes) -> bytes:
    """Sustituye todos los IDAT por uno solo, conservando el resto de chunks."""
    salida = bytearray(FIRMA_PNG)
    insertado = False
    for tipo, contenido in chunks:
        if tipo == b"IDAT":
            if not insertado:
                salida.extend(escribir_chunk(b"IDAT", comprimido))
                insertado = True
            continue
        salida.extend(escribir_chunk(tipo, contenido))
    return bytes(salida)


def recomprimir(ruta: Path, aplicar: bool = False) -> dict:
    """Analiza un PNG y, con `aplicar`, lo reescribe solo si hay ganancia."""
    original = ruta.read_bytes()
    chunks, idat = leer_chunks(original)
    pixeles = zlib.decompress(idat)
    comprimido, estrategia, nivel, memoria = mejor_composicion(pixeles)
    nuevo = reconstruir(chunks, comprimido)
    if zlib.decompress(leer_chunks(nuevo)[1]) != pixeles:
        raise ValueError("la reconstrucción no conserva los píxeles")
    ganancia = len(original) - len(nuevo)
    aplicado = aplicar and ganancia > 0
    if aplicado:
        temporal = ruta.with_name(ruta.name + ".tmp")
        temporal.write_bytes(nuevo)
        temporal.replace(ruta)
    return {
        "ruta": ruta.as_posix(),
        "bytes_antes": len(original),
        "bytes_despues": len(nuevo),
        "ganancia": ganancia,
        "parametros": {
            "estrategia": estrategia,
            "nivel": nivel,
            "memoria": memoria,
        },
        "pixeles_identicos": True,
        "aplicado": aplicado,
    }


def main(argv: list[str] | None = None) -> int:
    analizador = argparse.ArgumentParser(description=__doc__)
    analizador.add_argument("rutas", nargs="+", type=Path)
    analizador.add_argument(
        "--aplicar", action="store_true",
        help="Escribir el archivo cuando la ganancia sea positiva",
    )
    argumentos = analizador.parse_args(argv)
    try:
        informes = [recomprimir(ruta, argumentos.aplicar)
                    for ruta in argumentos.rutas]
    except (OSError, ValueError) as error:
        print("ERROR: " + str(error), file=sys.stderr)
        return 1
    print(json.dumps(informes, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
