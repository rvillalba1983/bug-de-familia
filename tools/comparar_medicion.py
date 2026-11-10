#!/usr/bin/env python3
"""Compara la medición exportada (medicion.txt) contra la tabla de referencia.

Uso (desde la raíz del repositorio):
    python tools/comparar_medicion.py C:\\ruta\\a\\medicion.txt
    python tools/comparar_medicion.py C:\\ruta\\a\\medicion.txt --umbral 20
    python tools/comparar_medicion.py C:\\ruta\\a\\medicion.txt --actualizar

Solo lee medicion.txt; con --actualizar reescribe la referencia con las
medianas medidas. No toca las herramientas de medición.

Qué compara: solo las rondas completas (quitar vacío). De cada caso toma la
mediana de fotograma_mediana entre rondas y el peor fotograma_p99. Superar la
referencia en más de --umbral por ciento es una regresión.

Formato de la referencia (tools/medir_windows/referencia.txt), una línea por caso:
    <caso> <mediana_ms> <p99_ms|->
El p99 '-' significa «sin dato, sin límite». Las líneas en blanco y las que
empiezan por '#' se ignoran.

Códigos de salida: 0 sin regresiones, 1 con regresiones, 2 error de uso o de
lectura del fichero.
"""

from __future__ import annotations

import argparse
import statistics
import sys
from dataclasses import dataclass
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
REFERENCIA_DEFECTO = RAIZ / "tools" / "medir_windows" / "referencia.txt"

CAMPO_MEDIANA = "fotograma_mediana"
CAMPO_P99 = "fotograma_p99"
CAMPO_QUITAR = "quitar"
ANCHO_CASO = 10
ANCHO_NUM = 11

SALE_OK = 0
SALE_REGRESIONES = 1
SALE_ERROR = 2


@dataclass
class Resultado:
    """Una línea RESULTADO de medicion.txt."""

    linea: int
    caso: str
    quitar: str
    ronda: str
    campos: dict[str, str]


@dataclass
class Referencia:
    """Fila de la tabla de referencia para un caso."""

    mediana: float
    p99: float | None  # None: sin dato, sin límite


def _numero(texto: str | None) -> float | None:
    """Convierte a float o devuelve None si falta o no es numérico."""
    if texto is None:
        return None
    try:
        return float(texto)
    except ValueError:
        return None


def _leer_linea_resultado(texto: str, numero: int) -> Resultado | None:
    """Parsea una línea RESULTADO; None si no lo es.

    Los valores se agrupan por espacios, pero campos como
    ventana=Vector2i(1280, 720) o grafica=ANGLE (Intel, ...) contienen
    espacios: los tokens sin '=' se añaden al valor anterior.
    """
    tokens = texto.split()
    if not tokens or tokens[0] != "RESULTADO" or len(tokens) < 2:
        return None
    campos: dict[str, str] = {}
    for token in tokens[2:]:
        if "=" in token:
            clave, _, valor = token.partition("=")
            campos[clave] = valor
        elif campos:
            clave = next(reversed(campos))
            campos[clave] = campos[clave] + " " + token
    return Resultado(
        linea=numero,
        caso=tokens[1],
        quitar=campos.get(CAMPO_QUITAR, ""),
        ronda=campos.get("ronda", ""),
        campos=campos,
    )


def leer_medicion(ruta: Path) -> list[Resultado]:
    """Devuelve todas las líneas RESULTADO del medicion.txt."""
    resultados: list[Resultado] = []
    with ruta.open("r", encoding="utf-8", errors="replace") as fichero:
        for numero, linea in enumerate(fichero, start=1):
            resultado = _leer_linea_resultado(linea.rstrip("\n"), numero)
            if resultado is not None:
                resultados.append(resultado)
    return resultados


def leer_referencia(ruta: Path) -> dict[str, Referencia]:
    """Lee la tabla de referencia; lanza FileNotFoundError si no existe."""
    filas: dict[str, Referencia] = {}
    with ruta.open("r", encoding="utf-8") as fichero:
        for numero, linea in enumerate(fichero, start=1):
            texto = linea.strip()
            if not texto or texto.startswith("#"):
                continue
            partes = texto.split()
            if len(partes) < 2:
                raise ValueError(f"{ruta}:{numero}: línea con menos de dos columnas: {texto}")
            mediana = _numero(partes[1])
            if mediana is None or mediana <= 0.0:
                raise ValueError(f"{ruta}:{numero}: mediana no válida: {texto}")
            p99 = partes[2] if len(partes) >= 3 else "-"
            if p99 == "-":
                limite = None
            else:
                limite = _numero(p99)
                if limite is None or limite <= 0.0:
                    raise ValueError(f"{ruta}:{numero}: p99 no válido: {texto}")
            filas[partes[0]] = Referencia(mediana=mediana, p99=limite)
    return filas


def escribir_referencia(ruta: Path, filas: dict[str, Referencia]) -> None:
    """Escribe la tabla de referencia con columnas alineadas."""
    cabecera = [
        "# Referencia de fotogramas (ms) para comparar_medicion.py.",
        "# Hardware: Intel HD 520 del director (ver docs/adr/0017-optimizacion-integrada.md).",
        "# Marcas provisionales: contrastar cada cifra con la medición que la generó.",
        "# Columnas: <caso> <mediana_ms> <p99_ms> ; p99 '-' significa sin dato, sin límite.",
        "",
    ]
    cuerpo = [
        f"{caso:<10} {fila.mediana:>7.2f} {('-' if fila.p99 is None else f'{fila.p99:>7.2f}')}"
        for caso, fila in filas.items()
    ]
    ruta.write_text("\n".join(cabecera + cuerpo) + "\n", encoding="utf-8")


def completas(resultados: list[Resultado]) -> dict[str, list[Resultado]]:
    """Agrupa por caso solo las rondas completas (quitar vacío)."""
    grupos: dict[str, list[Resultado]] = {}
    for resultado in resultados:
        if resultado.quitar == "":
            grupos.setdefault(resultado.caso, []).append(resultado)
    return grupos


def resumir(rondas: list[Resultado]) -> tuple[float | None, float | None]:
    """Mediana de fotograma_mediana y peor fotograma_p99 de todas las rondas."""
    medianas: list[float] = []
    peores: list[float] = []
    for ronda in rondas:
        mediana = _numero(ronda.campos.get(CAMPO_MEDIANA))
        if mediana is not None:
            medianas.append(mediana)
        p99 = _numero(ronda.campos.get(CAMPO_P99))
        if p99 is not None:
            peores.append(p99)
    mediana = statistics.median(medianas) if medianas else None
    peor = max(peores) if peores else None
    return mediana, peor


def _fnumero(valor: float | None) -> str:
    return "sin datos" if valor is None else f"{valor:.2f}"


def _porcentaje(actual: float, referencia: float) -> float:
    return (actual / referencia - 1.0) * 100.0


def _tabla(
    casos: list[str],
    medidas: dict[str, tuple[float | None, float | None]],
    referencia: dict[str, Referencia],
) -> list[str]:
    lineas = [
        f"{'Caso':<{ANCHO_CASO}} {'Rondas':>{6}} {'Mediana(ms)':>{ANCHO_NUM}}"
        f" {'Ref.(ms)':>{ANCHO_NUM}} {'Dif.':>{7}}"
        f" {'P99(ms)':>{ANCHO_NUM}} {'P99 ref.':>{8}}",
    ]
    for caso in casos:
        rondas, mediana, p99 = medidas[caso]
        fila_ref = referencia.get(caso)
        if fila_ref is None:
            dif = "sin ref."
            ref_texto = "-"
            p99_ref = "-"
        else:
            ref_texto = f"{fila_ref.mediana:.2f}"
            dif = (
                "sin datos"
                if mediana is None
                else f"{_porcentaje(mediana, fila_ref.mediana):+.1f}%"
            )
            p99_ref = "-" if fila_ref.p99 is None else f"{fila_ref.p99:.2f}"
        lineas.append(
            f"{caso:<{ANCHO_CASO}} {rondas:>{6}} {_fnumero(mediana):>{ANCHO_NUM}}"
            f" {ref_texto:>{ANCHO_NUM}} {dif:>{7}}"
            f" {_fnumero(p99):>{ANCHO_NUM}} {p99_ref:>{8}}"
        )
    return lineas


def _parejas_regresion(
    casos: list[str],
    medidas: dict[str, tuple[float | None, float | None]],
    referencia: dict[str, Referencia],
    porcentaje_umbral: float,
) -> list[str]:
    """Textos de cada regresión detectada: mediana y, si hay dato, p99."""
    textos: list[str] = []
    factor = 1.0 + porcentaje_umbral / 100.0
    for caso in casos:
        filas = medidas[caso]
        mediana, p99 = filas[1], filas[2]
        fila_ref = referencia.get(caso)
        if fila_ref is None:
            continue
        if mediana is not None:
            tope = fila_ref.mediana * factor
            if mediana > tope:
                textos.append(
                    f"- {caso}: mediana {mediana:.2f} ms > {fila_ref.mediana:.2f} ms"
                    f" x {factor:.2f} = {tope:.2f} ms"
                    f" ({_porcentaje(mediana, fila_ref.mediana):+.1f} %)"
                )
        if p99 is not None and fila_ref.p99 is not None:
            tope = fila_ref.p99 * factor
            if p99 > tope:
                textos.append(
                    f"- {caso}: p99 {p99:.2f} ms > {fila_ref.p99:.2f} ms"
                    f" x {factor:.2f} = {tope:.2f} ms"
                    f" ({_porcentaje(p99, fila_ref.p99):+.1f} %)"
                )
    return textos


def _orden_casos(
    medidas: dict[str, list[Resultado]],
    referencia: dict[str, Referencia],
) -> list[str]:
    """Casos de la referencia en su orden, más los medidos que no están en ella."""
    casos = [caso for caso in referencia if caso in medidas]
    casos += [caso for caso in medidas if caso not in referencia]
    return casos


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="comparar_medicion.py",
        description="Compara un medicion.txt exportado contra la tabla de referencia.",
    )
    parser.add_argument(
        "medicion",
        help="ruta del medicion.txt generado junto al ejecutable exportado",
    )
    parser.add_argument(
        "--referencia",
        default=str(REFERENCIA_DEFECTO),
        help=f"tabla de contraste (por defecto {REFERENCIA_DEFECTO})",
    )
    parser.add_argument(
        "--umbral",
        type=float,
        default=25.0,
        help="porcentaje sobre la referencia a partir del cual hay regresión (25 por omisión)",
    )
    parser.add_argument(
        "--actualizar",
        action="store_true",
        help="reescribe la referencia con las medianas de este medicion.txt",
    )
    argumentos = parser.parse_args(argv)
    if argumentos.umbral < 0.0:
        parser.error("--umbral no puede ser negativo")

    ruta_medicion = Path(argumentos.medicion)
    ruta_referencia = Path(argumentos.referencia)
    try:
        resultados = leer_medicion(ruta_medicion)
    except OSError as error:
        print(f"ERROR: no se puede leer {ruta_medicion}: {error}", file=sys.stderr)
        return SALE_ERROR
    if not resultados:
        print(
            f"ERROR: {ruta_medicion} no tiene líneas 'RESULTADO <caso> ...'",
            file=sys.stderr,
        )
        return SALE_ERROR

    try:
        referencia = leer_referencia(ruta_referencia)
    except FileNotFoundError:
        referencia = {}
        print(f"AVISO: no existe {ruta_referencia}; nada tendrá contraste.\n", file=sys.stderr)
    except (OSError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return SALE_ERROR

    grupos = completas(resultados)
    parciales = sum(1 for r in resultados if r.quitar != "")

    if argumentos.actualizar:
        return _actualizar_referencia(ruta_referencia, grupos, referencia)

    casos = _orden_casos(grupos, referencia)
    medidas = {caso: resumir(grupos[caso]) for caso in casos}
    tabla: dict[str, tuple[int, float | None, float | None]] = {
        caso: (len(grupos[caso]), *resumido) for caso, resumido in medidas.items()
    }

    print(f"Medición: {ruta_medicion}")
    print(f"Referencia: {ruta_referencia}")
    print(f"Umbral de regresión: +{argumentos.umbral:.0f} %")
    print(f"Rondas completas comparadas: {len(resultados) - parciales}; con 'quitar=' descartadas: {parciales}")
    sin_ref = [caso for caso in casos if caso not in referencia]
    if sin_ref:
        print(f"Sin referencia (no se comparan): {', '.join(sin_ref)}")
    en_ref_faltantes = [caso for caso in referencia if caso not in grupos]
    if en_ref_faltantes:
        print(f"En referencia pero sin medir aquí: {', '.join(en_ref_faltantes)}")
    print()

    for linea in _tabla(casos, tabla, referencia):
        print(linea)
    print()

    regresiones = _parejas_regresion(casos, tabla, referencia, argumentos.umbral)
    if regresiones:
        print("Regresiones detectadas:")
        for texto in regresiones:
            print(texto)
        print()
    print(f"REGRESIONES: {len(regresiones)}")
    return SALE_REGRESIONES if regresiones else SALE_OK


def _actualizar_referencia(
    ruta_referencia: Path,
    grupos: dict[str, list[Resultado]],
    actual: dict[str, Referencia],
) -> int:
    """Reescribe la referencia con las medianas medidas; conserva el p99 previo."""
    if not grupos:
        print("ERROR: no hay rondas completas (quitar vacío); nada que actualizar.", file=sys.stderr)
        return SALE_ERROR
    filas: dict[str, Referencia] = {}
    for caso, filas_previas in actual.items():
        if caso not in grupos:
            filas[caso] = filas_previas
    for caso in _orden_casos(grupos, actual):
        mediana, _ = resumir(grupos[caso])
        if mediana is None:
            print(f"AVISO: {caso}: sin fotograma_mediana legible; no se actualiza.", file=sys.stderr)
            continue
        previa = actual.get(caso)
        filas[caso] = Referencia(
            mediana=mediana,
            p99=None if previa is None else previa.p99,
        )
    try:
        escribir_referencia(ruta_referencia, filas)
    except OSError as error:
        print(f"ERROR: no se puede escribir {ruta_referencia}: {error}", file=sys.stderr)
        return SALE_ERROR
    print(f"Referencia actualizada con {len(grupos)} casos medidos: {ruta_referencia}")
    print("Recuerda dejar constancia en docs/03_ESTADO.md de hardware y driver de la medición.")
    return SALE_OK


if __name__ == "__main__":
    sys.exit(main())
