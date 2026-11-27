#!/usr/bin/env python3
"""Pruebas de `tools/art/auditar_arte.py` (stdlib, sin Godot)."""
from __future__ import annotations

import struct
import sys
import tempfile
import unittest
import zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "art"))

import auditar_arte  # noqa: E402


def chunk(tipo: bytes, datos: bytes) -> bytes:
    return (struct.pack(">I", len(datos)) + tipo + datos
            + struct.pack(">I", zlib.crc32(tipo + datos) & 0xFFFFFFFF))


def png_minimal() -> bytes:
    cabecera = struct.pack(">IIBBBBB", 1, 1, 8, 6, 0, 0, 0)
    pixeles = b"\x00\xff\x00\x00\xff"
    return (auditar_arte.FIRMA_PNG + chunk(b"IHDR", cabecera)
            + chunk(b"IDAT", zlib.compress(pixeles)) + chunk(b"IEND", b""))


class AuditarArteTest(unittest.TestCase):
    def test_integridad_png_valido_y_corrupt(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            ruta = Path(temporal) / "a.png"
            ruta.write_bytes(png_minimal())
            self.assertIsNone(auditar_arte.integridad_png(ruta))
            dañado = bytearray(png_minimal())
            dañado[-8] ^= 0xFF
            ruta.write_bytes(bytes(dañado))
            self.assertIn("CRC", auditar_arte.integridad_png(ruta) or "")

    def test_block_agrupa_por_extension_y_bytes(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            ruta = Path(temporal)
            (ruta / "a.svg").write_text("x" * 4, encoding="utf-8")
            (ruta / "b.svg").write_text("y" * 6, encoding="utf-8")
            (ruta / "c.png").write_bytes(b"12345")
            informe = auditar_arte.block([ruta / "a.svg", ruta / "b.svg",
                                          ruta / "c.png"])
            self.assertEqual(informe[".svg"], {"archivos": 2, "bytes": 10})
            self.assertEqual(informe[".png"], {"archivos": 1, "bytes": 5})

    def test_duplicados_solo_agrupa_identicos(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            ruta = Path(temporal)
            (ruta / "a.png").write_bytes(png_minimal())
            (ruta / "b.png").write_bytes(png_minimal())
            (ruta / "c.svg").write_text("<svg/>", encoding="utf-8")
            grupos = auditar_arte.duplicados([ruta / "a.png", ruta / "b.png",
                                              ruta / "c.svg"])
            self.assertEqual(len(grupos), 1)
            self.assertEqual(len(next(iter(grupos.values()))), 2)

    def test_sin_referencias_ignora_import_y_cuenta_codigo(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            raiz = Path(temporal)
            (raiz / "art").mkdir()
            (raiz / "src").mkdir()
            (raiz / "art" / "huerfano.png").write_bytes(png_minimal())
            (raiz / "art" / "usado.png").write_bytes(png_minimal())
            (raiz / "art" / "huerfano.png.import").write_text(
                "source_file=\"res://art/huerfano.png\"\n", encoding="utf-8")
            (raiz / "src" / "x.gd").write_text(
                'load("res://art/usado.png")\n', encoding="utf-8")
            falta = auditar_arte.sin_referencias(
                raiz, [raiz / "art" / "huerfano.png",
                       raiz / "art" / "usado.png"])
            self.assertEqual(falta, [raiz / "art" / "huerfano.png"])

    def test_auditar_devuelve_resumen_sin_escribir(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            raiz = Path(temporal)
            (raiz / "art").mkdir()
            (raiz / "art" / "a.png").write_bytes(png_minimal())
            informe = auditar_arte.auditar(raiz)
            self.assertEqual(informe["png_integros"], 1)
            self.assertEqual(informe["png_problemas"], {})
            self.assertEqual(informe["total_bytes"],
                             (raiz / "art" / "a.png").stat().st_size)
            self.assertEqual(list((raiz / "art").iterdir()),
                             [raiz / "art" / "a.png"])


if __name__ == "__main__":
    unittest.main()
