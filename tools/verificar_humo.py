#!/usr/bin/env python3
"""Prueba de humo del juego exportado con comprobacion positiva de arranque.

Lanzar el binario y ver `exit 0` o un log sin errores no demuestra que el mundo
se haya montado: `scenes/world/world.gd` solo registra un `push_error` y sigue
vivo. Por eso esta herramienta exige una prueba positiva: `ZoneManager.start()`
llama a `autosave()` en cuanto monta la zona, y `SaveSystem` escribe
`user://partida.json`. Si el archivo aparece con la zona actual, el cuerpo del
protagonista y la poblacion, el arranque es real.

Se lanza el binario con `--headless` (escena principal real de `project.godot`),
se espera a que aparezca la partida y se detiene el proceso. No depende de
`--quit-after`: si la partida no aparece, el arranque falla aunque el proceso
siga vivo.

El perfil de usuario del juego es un directorio unico creado dentro de
`--datos` (por eso la partida nunca toca el perfil real del usuario). Se
rechazan como `--datos` la carpeta personal, la raiz del disco y el perfil
real de datos (APPDATA/XDG_DATA_HOME). El modo `--partida` exige `--registro`:
sin el registro de la misma corrida no hay prueba de que el juego arrancara.

Uso (desde la raiz del repo):

    python tools/verificar_humo.py --binario build/bug_de_familia.x86_64 \\
        --datos humo_datos --registro humo.log

    # solo validar una partida y el registro de su misma corrida
    python tools/verificar_humo.py --partida partida.json --registro humo.log

Codigo de salida 0 si el arranque se demuestra, 1 si no.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path

RAIZ: Path = Path(__file__).resolve().parent.parent
PARTIDA = "partida.json"
# Prefijos de linea que invalidan el arranque aunque el proceso termine con
# codigo 0. Godot imprime los errores de script y de carga con estos prefijos.
PREFIJOS_ERROR = ("ERROR:", "USER ERROR:", "SCRIPT ERROR:", "Parse Error:")
# Mensajes concretos de zona no montada: `push_error` no siempre es fatal.
FRASES_SIN_ZONA = ("no se pudo montar la zona inicial", "la zona de inicio")
MARCA_MOTOR = "Godot Engine v"


def revisar_registro(texto: str) -> tuple[list[str], list[str]]:
    """Devuelve (lineas correctas, errores) del registro del juego."""
    buenas: list[str] = []
    errores: list[str] = []
    vistos: set[str] = set()
    if MARCA_MOTOR in texto:
        version = next(linea.strip() for linea in texto.split("\n")
                       if MARCA_MOTOR in linea)
        buenas.append(f"OK el motor arranco: {version}")
    else:
        errores.append("ERROR el registro no muestra el arranque del motor "
                       f"({MARCA_MOTOR!r} ausente)")
    for numero, linea in enumerate(texto.split("\n"), 1):
        limpia = linea.strip()
        empezar = limpia.startswith(PREFIJOS_ERROR)
        sin_zona = any(frase in linea for frase in FRASES_SIN_ZONA)
        if (empezar or sin_zona) and limpia not in vistos:
            vistos.add(limpia)
            errores.append(f"ERROR registro linea {numero}: {limpia}")
    return buenas, errores


def validar_partida(datos: object, zona: str) -> tuple[list[str], list[str]]:
    """Devuelve (lineas correctas, errores) de la partida guardada."""
    buenas: list[str] = []
    errores: list[str] = []
    if not isinstance(datos, dict):
        return [], ["ERROR la partida no es un objeto JSON"]

    try:
        version = int(datos.get("version", -1))
    except (TypeError, ValueError):
        version = -1
    if version != 3:
        errores.append(f"ERROR la partida tiene version "
                       f"{datos.get('version')!r}, se esperaba 3")
    else:
        buenas.append("OK la partida tiene el esquema esperado")

    cuerpo = datos.get("body")
    if isinstance(cuerpo, dict) and cuerpo:
        buenas.append(f"OK protagonista guardado ({len(cuerpo)} campos de cuerpo)")
    else:
        errores.append("ERROR la partida no trae el cuerpo del protagonista: "
                       "no se creo el jugador")

    zonas = datos.get("world_zones")
    if not isinstance(zonas, dict):
        return buenas, errores + [
            "ERROR la partida no trae world_zones: el gestor no monto ninguna zona"]
    actual = str(zonas.get("current", ""))
    if actual != zona:
        errores.append(f"ERROR la zona actual es {actual!r}, se esperaba {zona!r}")
    else:
        buenas.append(f"OK la zona actual es {zona}")

    registros = zonas.get("records")
    registro = registros.get(zona) if isinstance(registros, dict) else None
    if not isinstance(registro, dict):
        return buenas, errores + [
            f"ERROR no hay estado guardado de la zona {zona}: no se monto"]
    if bool(registro.get("visited", False)):
        buenas.append(f"OK la zona {zona} quedo marcada como visitada")
    else:
        errores.append(f"ERROR la zona {zona} no quedo marcada como visitada")
    if not (registro.get("level_state") or registro.get("world")):
        errores.append(f"ERROR la zona {zona} no guardo estado: monto vacia")
    poblacion = registro.get("population")
    if isinstance(poblacion, dict) and poblacion:
        try:
            total = sum(int(valor) for valor in poblacion.values())
        except (TypeError, ValueError):
            errores.append(f"ERROR la poblacion de {zona} tiene valores no "
                           f"numericos: {poblacion!r}")
        else:
            if total <= 0:
                errores.append(f"ERROR la poblacion de {zona} suma {total}: "
                               f"la zona monto sin habitantes")
            else:
                especies = ", ".join(f"{clave}={valor}"
                                     for clave, valor in sorted(poblacion.items()))
                buenas.append(f"OK poblacion de {zona}: {total} individuos "
                              f"({especies})")
    else:
        errores.append(f"ERROR la zona {zona} no tiene poblacion: monto sin "
                       f"habitantes")
    return buenas, errores


def resolver_binario(ruta: Path) -> Path:
    """Ruta absoluta del binario.

    `Popen` cambia el directorio de trabajo al del binario: una ruta relativa
    como `build/bug_de_familia.x86_64` se resolveria contra el nuevo
    directorio y buscaria `build/build/...`. Se resuelve antes de lanzar.
    """
    return ruta.resolve()


def base_segura(base: Path) -> str | None:
    """Razon por la que `base` no vale como perfil del humo, o None.

    El perfil del humo debe ser un directorio propio: nunca la carpeta
    personal, la raiz del disco ni el perfil real de datos del usuario.
    """
    try:
        resuelta = base.resolve()
    except OSError as fallo:
        return f"no se pudo resolver la ruta ({fallo})"
    sospechosas = [Path.home().resolve()]
    sospechosas.append(Path(resuelta.anchor))
    for nombre in ("APPDATA", "XDG_DATA_HOME"):
        valor = os.environ.get(nombre)
        if valor:
            sospechosas.append(Path(valor).resolve())
    for sospechosa in sospechosas:
        if resuelta == sospechosa:
            return f"es la carpeta personal, la raiz del disco o el perfil " \
                   f"real de datos ({resuelta})"
    return None


def buscar_partida(base: Path) -> Path | None:
    """Primera partida.json bajo base (user:// incluye el nombre del proyecto)."""
    if not base.is_dir():
        return None
    for ruta in sorted(base.rglob(PARTIDA)):
        return ruta
    return None


def entorno_datos(base: Path) -> dict[str, str]:
    """Redirige user:// a base para no depender del perfil del runner."""
    entorno = os.environ.copy()
    base.mkdir(parents=True, exist_ok=True)
    if os.name == "nt":
        entorno["APPDATA"] = str(base.resolve())
    else:
        entorno["XDG_DATA_HOME"] = str(base.resolve())
    return entorno


def lanzar(binario: Path, base: Path, registro: Path, espera: int,
           zona: str, comando: list[str] | None = None
           ) -> tuple[list[str], list[str]]:
    """Lanza el binario, espera la partida y devuelve (buenas, errores)."""
    razon = base_segura(base)
    if razon is not None:
        return [], [f"ERROR el directorio de datos {base} no se puede usar: "
                    f"{razon}; usa un directorio aparte (p. ej. humo_datos)"]
    base.mkdir(parents=True, exist_ok=True)
    # Directorio unico de esta corrida: la partida se escribe y se borra solo
    # aqui dentro, nunca en un arbol previo elegido con --datos.
    ejecucion = Path(tempfile.mkdtemp(prefix="humo_", dir=str(base)))
    orden = comando if comando is not None else [str(binario), "--headless"]
    with registro.open("w", encoding="utf-8") as salida:
        proceso = subprocess.Popen(
            orden, cwd=str(binario.parent),
            stdout=salida, stderr=subprocess.STDOUT,
            env=entorno_datos(ejecucion), stdin=subprocess.DEVNULL,
        )
        try:
            partida = esperar_partida(proceso, ejecucion, espera)
        finally:
            codigo = proceso.poll()
            detener(proceso)
    texto = registro.read_text(encoding="utf-8", errors="replace")
    buenas, errores = revisar_registro(texto)
    if partida is None:
        final = (f"termino con codigo {codigo}" if codigo is not None
                 else f"siguio vivo {espera} s")
        return buenas, errores + [
            f"ERROR el juego {final} sin escribir {PARTIDA}: "
            f"la zona {zona} no llego a montarse"]
    try:
        datos = json.loads(partida.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as fallo:
        return buenas, errores + [f"ERROR no se pudo leer {partida}: {fallo}"]
    mas_buenas, mas_errores = validar_partida(datos, zona)
    return buenas + mas_buenas, errores + mas_errores


def esperar_partida(proceso: subprocess.Popen[bytes], base: Path,
                    espera: int) -> Path | None:
    """Espera a que aparezca la partida; None si el proceso muere o se agota."""
    limite = time.monotonic() + espera
    while time.monotonic() < limite:
        if proceso.poll() is not None:
            return None
        partida = buscar_partida(base)
        if partida is not None:
            time.sleep(1.0)  # deja terminar la escritura atomica
            return partida
        time.sleep(0.25)
    return None


def detener(proceso: subprocess.Popen[bytes]) -> None:
    """Detiene el juego; no falla si ya habia terminado."""
    if proceso.poll() is not None:
        return
    proceso.terminate()
    try:
        proceso.wait(timeout=15)
    except subprocess.TimeoutExpired:
        proceso.kill()
        try:
            proceso.wait(timeout=15)
        except subprocess.TimeoutExpired:
            # Ni SIGKILL (Linux) ni TerminateProcess (Windows) dejan proceso
            # vivo; si aun asi no acabara, el timeout del job de CI corta.
            pass


def main() -> int:
    analizador = argparse.ArgumentParser(
        description="Prueba de humo del juego exportado con prueba positiva.")
    analizador.add_argument("--binario", type=Path,
                            help="ruta al binario exportado")
    analizador.add_argument("--datos", type=Path, default=RAIZ / "humo_datos",
                            help="directorio para redirigir user://")
    analizador.add_argument("--registro", type=Path, default=None,
                            help="archivo de registro de la ejecucion "
                                 "(por defecto humo.log en la raiz; con "
                                 "--partida es obligatorio)")
    analizador.add_argument("--espera", type=int, default=60,
                            help="segundos maximos para que aparezca la partida")
    analizador.add_argument("--zona", default="despliegue_cero",
                            help="zona que debe quedar montada")
    analizador.add_argument("--partida", type=Path,
                            help="valida esta partida ya guardada, sin lanzar")
    argumentos = analizador.parse_args()

    if argumentos.partida is not None:
        if argumentos.registro is None:
            print("ERROR --partida exige --registro: sin el registro de la "
                  "misma corrida no se puede afirmar que el juego arranco")
            return 1
        registro = argumentos.registro.resolve()
        if not registro.is_file():
            print(f"ERROR no se encontro el registro {registro}: para "
                  f"afirmar el arranque hace falta el registro de esa "
                  f"corrida")
            return 1
        texto = registro.read_text(encoding="utf-8", errors="replace")
        buenas, errores = revisar_registro(texto)
        try:
            datos = json.loads(
                argumentos.partida.resolve().read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError) as fallo:
            print(f"ERROR no se pudo leer {argumentos.partida}: {fallo}")
            return 1
        mas_buenas, mas_errores = validar_partida(datos, argumentos.zona)
        buenas, errores = buenas + mas_buenas, errores + mas_errores
    else:
        if argumentos.binario is None:
            print("ERROR falta --binario o --partida", file=sys.stderr)
            return 2
        binario = resolver_binario(argumentos.binario)
        if not binario.is_file():
            print(f"ERROR no existe el binario {binario}",
                  file=sys.stderr)
            return 2
        registro = (argumentos.registro if argumentos.registro is not None
                    else RAIZ / "humo.log").resolve()
        buenas, errores = lanzar(
            binario, argumentos.datos.resolve(), registro,
            argumentos.espera, argumentos.zona)

    for linea in buenas:
        print(linea)
    for error in errores:
        print(error)
    if errores:
        print(f"FALLO: {len(errores)} comprobaciones fallidas; registro en "
              f"{argumentos.registro}")
        return 1
    print(f"OK: el juego arranca y monta la zona {argumentos.zona}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
