#!/usr/bin/env python3
"""Auditoría lectora del arte de `art/`: inventario, integridad y huérfanos.

No escribe archivos. Se ejecuta con:

    python tools/art/auditar_arte.py

La salida es JSON en stdout, con números estables para comparar una revisión
con otra. No necesita dependencias externas ni Godot.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import struct
import zlib
from collections import Counter
from pathlib import Path

FIRMA_PNG = b"\x89PNG\r\n\x1a\n"
EXTENSIONES_ARTE = {".png", ".svg", ".ttf"}
EXTENSIONES_REFERENCIA = {
    ".gd", ".tscn", ".tres", ".json", ".cfg", ".ini", ".gdshader", ".py",
}
DIRECTORIOS_IGNORADOS = {".git", ".godot", "build", "reports"}


def block(archivos: list[Path]) -> dict:
    """Devuelve número de archivos y bytes por extensión, ordenado por bytes."""
    conteo: Counter[str] = Counter()
    tamanyo: Counter[str] = Counter()
    for archivo in archivos:
        extension = archivo.suffix.lower() or "(sin extensión)"
        conteo[extension] += 1
        tamanyo[extension] += archivo.stat().st_size
    return {
        extension: {"archivos": conteo[extension], "bytes": tamanyo[extension]}
        for extension in sorted(tamanyo, key=lambda ext: (-tamanyo[ext], ext))
    }


def integridad_png(archivo: Path) -> str | None:
    """Comprueba firma, CRC de los chunks y descompresión de IDAT.

    Devuelve None si el PNG es íntegro o una descripción del problema.
    """
    datos = archivo.read_bytes()
    if not datos.startswith(FIRMA_PNG):
        return "firma PNG inválida"
    pos = 8
    idat = bytearray()
    ultimo = b""
    while pos + 12 <= len(datos):
        longitud = struct.unpack(">I", datos[pos:pos + 4])[0]
        tipo = datos[pos + 4:pos + 8]
        fin = pos + 8 + longitud
        if fin + 4 > len(datos):
            return "chunk truncado"
        contenido = datos[pos + 8:fin]
        crc = struct.unpack(">I", datos[fin:fin + 4])[0]
        if zlib.crc32(tipo + contenido) & 0xFFFFFFFF != crc:
            return "CRC inválido en " + tipo.decode("latin-1")
        if tipo == b"IDAT":
            idat.extend(contenido)
        ultimo = tipo
        pos = fin + 4
    if pos != len(datos) or ultimo != b"IEND":
        return "bytes sobrantes o IEND ausente"
    try:
        zlib.decompress(bytes(idat))
    except zlib.error as error:
        return "IDAT no descomprimible: " + str(error)
    return None


def duplicados(archivos: list[Path]) -> dict[str, list[str]]:
    """Agrupa por SHA256 los archivos de arte con contenido idéntico."""
    por_hash: dict[str, list[str]] = {}
    for archivo in archivos:
        if archivo.suffix.lower() not in {".png", ".svg"}:
            continue
        digest = hashlib.sha256(archivo.read_bytes()).hexdigest()
        por_hash.setdefault(digest, []).append(archivo.as_posix())
    return {digest: rutas for digest, rutas in por_hash.items() if len(rutas) > 1}


def sin_referencias(raiz: Path, archivos: list[Path],
                    limite: int | None = None) -> list[Path]:
    """Candidatos a huérfanos: su nombre no aparece como literal en el código.

    Las rutas dinámicas (`%s`, concatenaciones) producen falsos positivos, así
    que el resultado es una pista para revisar a mano, nunca una lista final.
    Los `.import` no cuentan: los genera Godot a partir del archivo de arte.
    """
    textos: list[str] = []
    for ruta in raiz.rglob("*"):
        if not ruta.is_file() or ruta.suffix.lower() not in EXTENSIONES_REFERENCIA:
            continue
        if any(parte in DIRECTORIOS_IGNORADOS for parte in ruta.parts):
            continue
        try:
            textos.append(ruta.read_text(encoding="utf-8"))
        except UnicodeDecodeError:
            continue
    cuerpo = "\n".join(textos)
    candidatos = sorted(
        (archivo for archivo in archivos
         if archivo.suffix.lower() in EXTENSIONES_ARTE
         and archivo.name not in cuerpo),
        key=lambda archivo: (-archivo.stat().st_size, archivo.as_posix()),
    )
    return candidatos if limite is None else candidatos[:limite]


def auditar(raiz: Path, top: int = 10) -> dict:
    """Devuelve el informe completo de auditoría sin modificar nada."""
    carpeta_arte = raiz / "art"
    archivos = sorted(ruta for ruta in carpeta_arte.rglob("*") if ruta.is_file())
    pngs = [ruta for ruta in archivos if ruta.suffix.lower() == ".png"]
    errores = {
        ruta.relative_to(raiz).as_posix(): problema
        for ruta in pngs
        if (problema := integridad_png(ruta)) is not None
    }
    mayores = sorted(archivos, key=lambda ruta: -ruta.stat().st_size)[:top]
    return {
        "raiz": raiz.as_posix(),
        "por_extension": block(archivos),
        "total_bytes": sum(ruta.stat().st_size for ruta in archivos),
        "mayores": [
            {
                "ruta": ruta.relative_to(raiz).as_posix(),
                "bytes": ruta.stat().st_size,
            }
            for ruta in mayores
        ],
        "png_integros": len(pngs) - len(errores),
        "png_problemas": errores,
        "duplicados": duplicados(archivos),
        "nota_candidatos": (
            "El nombre no aparece como literal; las rutas dinámicas pueden "
            "dar falsos positivos. Revisar a mano antes de borrar nada."
        ),
        "candidatos_sin_referencia_literal": [
            ruta.relative_to(raiz).as_posix()
            for ruta in sin_referencias(raiz, archivos, limite=top)
        ],
    }


def main(argv: list[str] | None = None) -> int:
    analizador = argparse.ArgumentParser(description=__doc__)
    analizador.add_argument(
        "--raiz",
        type=Path,
        default=Path(__file__).resolve().parents[2],
        help="Raíz del repositorio (por defecto, la de este script)",
    )
    analizador.add_argument("--top", type=int, default=10)
    argumentos = analizador.parse_args(argv)
    informe = auditar(argumentos.raiz.resolve(), argumentos.top)
    print(json.dumps(informe, ensure_ascii=False, indent=2))
    return 1 if informe["png_problemas"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
