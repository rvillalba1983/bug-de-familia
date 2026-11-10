#!/usr/bin/env python3
"""Un solo comando para todas las verificaciones deterministas del proyecto.

  python tools/verificar.py

Ejecuta con el mismo interprete validar_datos.py, formatear.py --comprobar y,
si existe medicion.txt en la raiz, comparar_medicion.py. Es la comprobacion que
usa el workflow de GitHub Actions (pruebas.yml) antes de descargar Godot: falla
rapido y no gasta minutos de CI ni tokens en errores mecanicos.

Solo stdlib, sin dependencias y sin llamadas a servicios externos.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
PASOS = [
	("Datos", ["tools/validar_datos.py"]),
	("Normas de formato", ["tools/formatear.py", "--comprobar", "--resumen"]),
]


def ejecutar(nombre: str, argumentos: list[str]) -> bool:
	resultado = subprocess.run([sys.executable, *argumentos], cwd=RAIZ)
	print(f"[{'OK' if resultado.returncode == 0 else 'FALLO'}] {nombre}")
	return resultado.returncode == 0


def main() -> int:
	correcto = True
	for nombre, argumentos in PASOS:
		correcto = ejecutar(nombre, argumentos) and correcto
	medicion = RAIZ / "medicion.txt"
	if medicion.exists():
		correcto = ejecutar(
			"Comparacion de medicion",
			["tools/comparar_medicion.py", str(medicion)],
		) and correcto
	else:
		print("[OMITIDO] Comparacion de medicion (no hay medicion.txt en la raiz)")
	print("VERIFICACION: OK" if correcto else "VERIFICACION: FALLO")
	return 0 if correcto else 1


if __name__ == "__main__":
	sys.exit(main())
