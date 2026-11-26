#!/usr/bin/env python3
"""Pruebas de `tools/limpiar_logs.py` (stdlib, sin Godot ni repo)."""
from __future__ import annotations

import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import limpiar_logs  # noqa: E402

AHORA = 1_800_000_000.0


class LimpiarLogsTest(unittest.TestCase):
	def crear(self, carpeta: Path, nombre: str, horas: float) -> Path:
		ruta = carpeta / nombre
		ruta.write_text("registro\n", encoding="utf-8")
		os.utime(ruta, (AHORA - horas * 3600, AHORA - horas * 3600))
		return ruta

	def test_borra_log_de_mas_de_8_horas(self) -> None:
		with tempfile.TemporaryDirectory() as temporal:
			carpeta = Path(temporal)
			ruta = self.crear(carpeta, "viejo.log", 9)
			resultado = limpiar_logs.limpiar(carpeta, ahora=AHORA)
			self.assertEqual(resultado, (1, 0, []))
			self.assertFalse(ruta.exists())

	def test_conserva_log_reciente(self) -> None:
		with tempfile.TemporaryDirectory() as temporal:
			carpeta = Path(temporal)
			ruta = self.crear(carpeta, "reciente.log", 7)
			resultado = limpiar_logs.limpiar(carpeta, ahora=AHORA)
			self.assertEqual(resultado, (0, 1, []))
			self.assertTrue(ruta.exists())

	def test_conserva_log_en_el_limite(self) -> None:
		with tempfile.TemporaryDirectory() as temporal:
			carpeta = Path(temporal)
			ruta = self.crear(carpeta, "limite.log", limpiar_logs.HORAS)
			resultado = limpiar_logs.limpiar(carpeta, ahora=AHORA)
			self.assertEqual(resultado, (0, 1, []))
			self.assertTrue(ruta.exists())

	def test_no_toca_otros_archivos_ni_subdirectorios(self) -> None:
		with tempfile.TemporaryDirectory() as temporal:
			carpeta = Path(temporal)
			self.crear(carpeta, "antiguo.log", 100)
			xml = self.crear(carpeta, "results.xml", 100)
			html = self.crear(carpeta, "index.html", 100)
			subdirectorio = carpeta / "report_1"
			subdirectorio.mkdir()
			interno = self.crear(subdirectorio, "interno.log", 100)
			limpiar_logs.limpiar(carpeta, ahora=AHORA)
			self.assertFalse((carpeta / "antiguo.log").exists())
			self.assertTrue(xml.exists())
			self.assertTrue(html.exists())
			self.assertTrue(interno.exists())

	def test_directorio_ausente_no_es_error(self) -> None:
		with tempfile.TemporaryDirectory() as temporal:
			resultado = limpiar_logs.limpiar(
				Path(temporal) / "no_hay", ahora=AHORA)
			self.assertEqual(resultado, (0, 0, []))

	def test_dry_run_no_borra(self) -> None:
		with tempfile.TemporaryDirectory() as temporal:
			carpeta = Path(temporal)
			ruta = self.crear(carpeta, "viejo.log", 9)
			resultado = limpiar_logs.limpiar(carpeta, ahora=AHORA, seco=True)
			self.assertEqual(resultado, (1, 0, []))
			self.assertTrue(ruta.exists())

	def test_ignora_enlaces_simbolicos(self) -> None:
		with tempfile.TemporaryDirectory() as temporal:
			carpeta = Path(temporal)
			objetivo = self.crear(carpeta, "objetivo.log", 100)
			enlace = carpeta / "enlace.log"
			try:
				enlace.symlink_to(objetivo)
			except (OSError, NotImplementedError):
				self.skipTest("el sistema no permite crear enlaces simbolicos")
			limpiar_logs.limpiar(carpeta, ahora=AHORA)
			self.assertTrue(enlace.is_symlink())
			self.assertFalse(objetivo.exists())


if __name__ == "__main__":
	unittest.main()
