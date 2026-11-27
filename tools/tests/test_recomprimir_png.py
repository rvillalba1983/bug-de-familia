#!/usr/bin/env python3
"""Pruebas de `tools/art/recomprimir_png.py` (stdlib, sin Godot)."""
from __future__ import annotations

import struct
import sys
import tempfile
import unittest
import zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "art"))

import auditar_arte  # noqa: E402
import recomprimir_png  # noqa: E402


def png_con_nivel(nivel: int) -> tuple[bytes, bytes]:
    ancho = alto = 64
    cabecera = struct.pack(">IIBBBBB", ancho, alto, 8, 6, 0, 0, 0)
    fila = b"\x00" + (b"\x11\x22\x33\xff" * ancho)
    pixeles = fila * alto
    compresor = zlib.compressobj(nivel, zlib.DEFLATED, 15)
    comprimido = compresor.compress(pixeles) + compresor.flush()
    png = (recomprimir_png.FIRMA_PNG
           + recomprimir_png.escribir_chunk(b"IHDR", cabecera)
           + recomprimir_png.escribir_chunk(b"IDAT", comprimido)
           + recomprimir_png.escribir_chunk(b"IEND", b""))
    return png, pixeles


class RecomprimirPngTest(unittest.TestCase):
    def test_analisis_no_modifica_el_archivo(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            ruta = Path(temporal) / "a.png"
            original, _ = png_con_nivel(0)
            ruta.write_bytes(original)
            informe = recomprimir_png.recomprimir(ruta)
            self.assertFalse(informe["aplicado"])
            self.assertGreater(informe["ganancia"], 0)
            self.assertEqual(ruta.read_bytes(), original)

    def test_aplicar_reduce_y_conserva_pixeles(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            ruta = Path(temporal) / "a.png"
            original, pixeles = png_con_nivel(0)
            ruta.write_bytes(original)
            informe = recomprimir_png.recomprimir(ruta, aplicar=True)
            self.assertTrue(informe["aplicado"])
            self.assertTrue(informe["pixeles_identicos"])
            self.assertLess(len(ruta.read_bytes()), len(original))
            self.assertIsNone(auditar_arte.integridad_png(ruta))
            _, idat = recomprimir_png.leer_chunks(ruta.read_bytes())
            self.assertEqual(zlib.decompress(idat), pixeles)
            self.assertFalse(ruta.with_name("a.png.tmp").exists())

    def test_rechaza_firma_invalida(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            ruta = Path(temporal) / "a.png"
            ruta.write_bytes(b"no es un png")
            with self.assertRaises(ValueError):
                recomprimir_png.recomprimir(ruta)


if __name__ == "__main__":
    unittest.main()
