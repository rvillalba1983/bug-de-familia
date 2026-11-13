#!/usr/bin/env python3
"""Un solo comando para todas las verificaciones deterministas del proyecto.

  python tools/verificar.py

Ejecuta, con el mismo interprete, validar_datos.py, validar_rutas.py,
formatear.py --comprobar, cambiar_modelo.py --validar y las pruebas de las
propias herramientas; y si existe medicion.txt en la raiz, comparar_medicion.py.
Es la comprobacion que usa el workflow de GitHub Actions (pruebas.yml) antes de
descargar Godot: falla rapido y no gasta minutos de CI ni tokens en errores
mecanicos.

validar_rutas.py existe por el incidente del 13-nov (ADR 0028): el renombrado
beta -> despliegue_cero dejo rutas res:// rotas en escenas, tests y workflows,
y el juego no arrancaba. Esta comprobacion lo detecta en segundos, sin Godot.

Solo stdlib, sin dependencias y sin llamadas a servicios externos.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
PASOS = [
	("Datos", ["tools/validar_datos.py"]),
	("Rutas res:// literales", ["tools/validar_rutas.py"]),
	("Normas de formato", ["tools/formatear.py", "--comprobar", "--resumen"]),
	("Modelos de los agentes", ["tools/cambiar_modelo.py", "--validar"]),
	("Pruebas de las herramientas",
	 ["-m", "unittest", "discover", "-s", "tools/tests", "-q"]),
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
