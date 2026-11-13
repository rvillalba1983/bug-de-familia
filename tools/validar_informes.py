#!/usr/bin/env python3
"""Comprueba el informe JUnit de GdUnit4 y detecta falsos verdes.

GdUnit4 escribe `reports/report_N/results.xml`. Cuando no ejecuta ninguna
prueba (por ejemplo, porque una ruta `-a` no existe) termina con codigo 0,
igual que si todo hubiera pasado: es el falso verde que dejo pasar el PR #7
(ADR 0028). Este script exige, sobre el informe real:

- que el informe exista y sea JUnit de GdUnit4;
- que se hayan ejecutado casos (no cero) y al menos `--minimo`;
- que no haya fallos ni errores, contados en la raiz y en cada suite (el XML
  real de GdUnit4 no escribe `errors` en la raiz, solo en las suites);
- que no haya pruebas omitidas;
- que los conteos cuadren (raiz = suma de suites = casos del XML, y las cifras
  de fallos y omitidas de la raiz coincidan con la suma de las suites);
- que cada carpeta pedida con `-a` tenga al menos una suite.

Si se pasa `--registro`, ademas revisa el registro de la ejecucion: los
errores de parseo y de carga de scripts (`SCRIPT ERROR:`, `Parse Error:` y
`ERROR:` que mencionen una ruta `res://`) fallan aunque el informe no los
refleje (son fallos de descubrimiento fuera del informe). Las lineas
`USER ERROR:` se listan como avisos: un `push_error` de codigo bajo prueba no
implica que la prueba haya fallado.

Uso (desde la raiz del repo):

    python tools/validar_informes.py --grupo core --minimo 39 \\
        --argumentos-gdunit "-a res://tests/core -a res://tests/entities" \\
        --registro pruebas.log

`--minimo` es un suelo por grupo, no un total universal: puede subir cuando se
anaden pruebas, pero no debe bajarse para conseguir verde. Las carpetas se
leen de los mismos argumentos que recibe GdUnit4, para no duplicarlos.

Codigo de salida 0 si el informe es fiable, 1 si no.
"""
from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ElementTree
from pathlib import Path

RAIZ: Path = Path(__file__).resolve().parent.parent
PATRON_INFORME = re.compile(r"^report_(\d+)$")
PATRON_CARPETA = re.compile(r"res://[A-Za-z0-9_./-]+")
# Secuencias de color que GdUnit4 puede dejar en el registro redirigido.
PATRON_ANSI = re.compile(r"\x1b\[[0-9;]*m")
# Errores de parseo y de carga de scripts: invalidan la ejecucion aunque el
# informe diga 0 fallos (el informe no siempre recoge el descubrimiento roto).
PREFIJOS_FATAL = ("SCRIPT ERROR:", "Parse Error:")


def buscar_informe(base: Path) -> Path | None:
    """Devuelve el results.xml del informe mas reciente, o None."""
    candidatos: list[tuple[int, Path]] = []
    if not base.is_dir():
        return None
    for entrada in base.iterdir():
        if not entrada.is_dir():
            continue
        coincidencia = PATRON_INFORME.match(entrada.name)
        if not coincidencia:
            continue
        informe = entrada / "results.xml"
        if informe.is_file():
            candidatos.append((int(coincidencia.group(1)), informe))
    if not candidatos:
        return None
    return max(candidatos)[1]


def carpetas_de(argumentos: str) -> list[str]:
    """Extrae las carpetas res:// de una cadena de argumentos de GdUnit4."""
    return [ruta.rstrip("/") for ruta in PATRON_CARPETA.findall(argumentos)]


def leer_informe(ruta: Path) -> dict[str, object]:
    """Lee el XML y devuelve los conteos y las suites."""
    raiz = ElementTree.parse(ruta).getroot()
    suites: list[dict[str, object]] = []
    for suite in raiz.findall("testsuite"):
        suites.append({
            "name": suite.get("name", ""),
            "package": suite.get("package", "").rstrip("/"),
            "tests": int(suite.get("tests", "0")),
            "failures": int(suite.get("failures", "0")),
            "errors": int(suite.get("errors", "0")),
            "skipped": int(suite.get("skipped", "0")),
        })
    return {
        "etiqueta": raiz.tag,
        "tests": int(raiz.get("tests", "0")),
        "failures": int(raiz.get("failures", "0")),
        "errores": int(raiz.get("errors", "0")),
        "skipped": int(raiz.get("skipped", "0")),
        "suites": suites,
        "casos": len(raiz.findall(".//testcase")),
    }


def comprobar(datos: dict[str, object], minimo: int,
              carpetas: list[str]) -> tuple[list[str], list[str]]:
    """Devuelve (lineas correctas, errores) del informe ya leido."""
    buenas: list[str] = []
    errores: list[str] = []

    if datos["etiqueta"] != "testsuites":
        errores.append(f"ERROR el informe no es JUnit de GdUnit4 "
                       f"(raiz <{datos['etiqueta']}>)")
    else:
        buenas.append("OK informe JUnit de GdUnit4")

    suites: list[dict[str, object]] = datos["suites"]  # type: ignore[assignment]
    tests: int = datos["tests"]  # type: ignore[assignment]
    casos: int = datos["casos"]  # type: ignore[assignment]
    suma_suites = sum(int(suite["tests"]) for suite in suites)

    if tests <= 0 or casos <= 0:
        errores.append("ERROR no se ejecuto ninguna prueba: GdUnit4 acabo sin "
                       "suites (revisa que las rutas -a existan)")
    else:
        buenas.append(f"OK pruebas ejecutadas: {casos}")

    if tests < minimo:
        errores.append(f"ERROR solo {tests} pruebas; el suelo de este grupo es "
                       f"{minimo} (no lo bajes para conseguir verde)")
    elif tests > 0:
        buenas.append(f"OK suelo del grupo: {tests} >= {minimo}")

    fallos_raiz = int(datos["failures"])  # type: ignore[arg-type]
    errores_raiz = int(datos["errores"])  # type: ignore[arg-type]
    omitidas_raiz = int(datos["skipped"])  # type: ignore[arg-type]
    fallos_suites = sum(int(suite["failures"]) for suite in suites)
    errores_suites = sum(int(suite["errors"]) for suite in suites)
    omitidas_suites = sum(int(suite["skipped"]) for suite in suites)
    if (fallos_raiz > 0 or fallos_suites > 0 or errores_raiz > 0
            or errores_suites > 0):
        errores.append(f"ERROR el informe tiene fallos o errores: la raiz "
                       f"{fallos_raiz} fallos y {errores_raiz} errores; las "
                       f"suites {fallos_suites} fallos y {errores_suites} "
                       f"errores")
    else:
        buenas.append("OK fallos y errores: 0")

    omitidas = max(omitidas_raiz, omitidas_suites)
    if omitidas > 0:
        errores.append(f"ERROR hay {omitidas} pruebas omitidas; no se omite una "
                       f"prueba para conseguir verde")
    else:
        buenas.append("OK pruebas omitidas: 0")

    # La raiz agrega a las suites; si difieren, el informe esta truncado o
    # manipulado. GdUnit4 no escribe `errors` en la raiz: esa cifra no se
    # compara, solo se cuenta (arriba) en cada nivel.
    if fallos_raiz != fallos_suites or omitidas_raiz != omitidas_suites:
        errores.append(f"ERROR la raiz y las suites no cuadran en fallos u "
                       f"omitidas (raiz {fallos_raiz}/{omitidas_raiz}, suites "
                       f"{fallos_suites}/{omitidas_suites}): informe truncado")

    if not (tests == suma_suites == casos):
        errores.append(f"ERROR los conteos no cuadran: raiz {tests}, suites "
                       f"{suma_suites}, casos en el XML {casos}")

    if not suites:
        errores.append("ERROR el informe no contiene ninguna suite")

    for carpeta in carpetas:
        buscada = carpeta[len("res://"):] if carpeta.startswith("res://") else carpeta
        encontradas = [suite for suite in suites
                       if str(suite["package"]) == buscada
                       or str(suite["package"]).startswith(buscada + "/")]
        if not encontradas:
            errores.append(f"ERROR ninguna suite de {carpeta}: la carpeta no se "
                           f"descubrio o no tiene pruebas")
        else:
            buenas.append(f"OK {carpeta}: {len(encontradas)} suites")

    return buenas, errores


def revisar_registro(texto: str) -> tuple[list[str], list[str]]:
    """Devuelve (avisos, errores) del registro de la ejecucion de GdUnit4.

    Los errores de parseo y de carga de scripts invalidan la ejecucion aunque
    el informe no los refleje: son fallos de descubrimiento fuera del informe.
    Los `USER ERROR:` (push_error de codigo bajo prueba) se listan como
    avisos, no como fallos.
    """
    avisos: list[str] = []
    errores: list[str] = []
    vistas: set[str] = set()
    for numero, cruda in enumerate(texto.split("\n"), 1):
        linea = PATRON_ANSI.sub("", cruda).strip()
        if not linea or linea in vistas:
            continue
        fatal = linea.startswith(PREFIJOS_FATAL) or (
            linea.startswith("ERROR:") and "res://" in linea)
        if fatal:
            vistas.add(linea)
            errores.append(f"ERROR registro linea {numero}: {linea}")
        elif linea.startswith("USER ERROR:"):
            vistas.add(linea)
            avisos.append(f"AVISO registro linea {numero}: {linea}")
    return avisos, errores


def main() -> int:
    analizador = argparse.ArgumentParser(
        description="Valida el informe JUnit de GdUnit4 contra falsos verdes.")
    analizador.add_argument("--informes", type=Path, default=RAIZ / "reports",
                            help="directorio de informes (por defecto reports/)")
    analizador.add_argument("--grupo", default="", help="nombre del grupo del matrix")
    analizador.add_argument("--minimo", type=int, default=1,
                            help="suelo de pruebas ejecutadas en este grupo")
    analizador.add_argument("--argumentos-gdunit", default="",
                            help="cadena con los -a res://... que recibio GdUnit4")
    analizador.add_argument("--registro", type=Path, default=None,
                            help="registro de la ejecucion (p. ej. pruebas.log)")
    argumentos = analizador.parse_args()

    etiqueta = f"[{argumentos.grupo}] " if argumentos.grupo else ""
    avisos: list[str] = []
    errores_registro: list[str] = []
    if argumentos.registro is not None:
        ruta_registro = argumentos.registro if argumentos.registro.is_absolute() \
            else RAIZ / argumentos.registro
        if not ruta_registro.is_file():
            print(f"ERROR {etiqueta}no se encontro el registro "
                  f"{ruta_registro}: la ejecucion no llego a escribirlo")
            print("FALLO: 1 comprobacion fallida")
            return 1
        avisos, errores_registro = revisar_registro(
            ruta_registro.read_text(encoding="utf-8", errors="replace"))

    base = argumentos.informes if argumentos.informes.is_absolute() \
        else RAIZ / argumentos.informes
    ruta = buscar_informe(base)
    if ruta is None:
        print(f"ERROR {etiqueta}no hay ningun informe en {base}: GdUnit4 no "
              f"ejecuto pruebas o el run se corto")
        print("FALLO: 1 comprobacion fallida")
        return 1

    try:
        datos = leer_informe(ruta)
    except (ElementTree.ParseError, OSError) as fallo:
        print(f"ERROR {etiqueta}no se pudo leer {ruta}: {fallo}")
        print("FALLO: 1 comprobacion fallida")
        return 1

    buenas, errores = comprobar(datos, argumentos.minimo,
                                carpetas_de(argumentos.argumentos_gdunit))
    errores = errores_registro + errores
    print(f"Informe: {ruta.relative_to(RAIZ) if ruta.is_relative_to(RAIZ) else ruta}")
    for linea in buenas:
        print(f"{etiqueta}{linea}")
    for aviso in avisos:
        print(f"{etiqueta}{aviso}")
    for error in errores:
        print(f"{etiqueta}{error}")
    if errores:
        print(f"FALLO: {len(errores)} comprobaciones fallidas")
        return 1
    print(f"OK: informe fiable ({datos['tests']} pruebas, "
          f"{len(datos['suites'])} suites)")  # type: ignore[arg-type]
    return 0


if __name__ == "__main__":
    sys.exit(main())
