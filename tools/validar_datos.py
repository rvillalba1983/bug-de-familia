#!/usr/bin/env python3
"""Validador determinista de los datos del juego (Bug de Familia).

Solo biblioteca estandar de Python 3.12. No modifica nada dentro de `data/`.

Uso (desde la raiz del repo):

    python tools/validar_datos.py              # valida
    python tools/validar_datos.py --actualizar # reescribe tools/referencia_datos.json
    python tools/validar_datos.py --estricto   # los conteos tambien fallan

Salida: una linea `ERROR <archivo> <detalle>` por problema y un resumen final.
Codigo de salida 0 si todo esta bien, 1 si hay errores.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

RAIZ: Path = Path(__file__).resolve().parent.parent
DATA: Path = RAIZ / "data"
REFERENCIA: Path = RAIZ / "tools" / "referencia_datos.json"

ESPECIE_RAIZ: str = "res://art/beta/"


class Informe:
    """Acumula errores y avisos de la validacion."""

    def __init__(self) -> None:
        self.errores: list[str] = []
        self.avisos: list[str] = []
        self.comprobaciones: int = 0
        self.archivos: set[str] = set()

    def error(self, archivo: str, detalle: str) -> None:
        self.errores.append("ERROR %s %s" % (archivo, detalle))

    def aviso(self, archivo: str, detalle: str) -> None:
        self.avisos.append("AVISO %s %s" % (archivo, detalle))

    def cuenta(self, archivo: str) -> None:
        """Registra que se ha hecho una comprobacion sobre un archivo."""
        self.comprobaciones += 1
        self.archivos.add(archivo)


# ---------------------------------------------------------------------------
# Utilidades de carga
# ---------------------------------------------------------------------------


def cargar_json(ruta: Path, informe: Informe) -> Any:
    """Carga un JSON y avisa si el archivo esta roto."""
    rel = ruta.relative_to(RAIZ).as_posix()
    informe.archivos.add(rel)
    try:
        texto = ruta.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        informe.error(rel, "no se puede leer como UTF-8: %s" % exc)
        return None
    try:
        return json.loads(texto)
    except json.JSONDecodeError as exc:
        informe.error(rel, "JSON invalido: linea %d columna %d: %s" % (exc.lineno, exc.colno, exc.msg))
        return None


def ids_unicos(lista: Any, campo: str, rel: str, informe: Informe, contexto: str) -> list[str]:
    """Comprueba que no haya ids repetidos en una lista de diccionarios."""
    vistos: dict[str, int] = {}
    orden: list[str] = []
    if not isinstance(lista, list):
        informe.error(rel, "%s: se esperaba una lista" % contexto)
        return orden
    for indice, entrada in enumerate(lista):
        if not isinstance(entrada, dict):
            informe.error(rel, "%s[%d]: no es un objeto" % (contexto, indice))
            continue
        if campo not in entrada:
            informe.error(rel, "%s[%d]: falta el campo '%s'" % (contexto, indice, campo))
            continue
        valor = entrada[campo]
        if not isinstance(valor, str) or not valor:
            informe.error(rel, "%s[%d].%s: debe ser una cadena no vacia" % (contexto, indice, campo))
            continue
        if valor in vistos:
            informe.error(
                rel,
                "%s: id duplicado '%s' (indices %d y %d)" % (contexto, valor, vistos[valor], indice),
            )
        else:
            vistos[valor] = indice
            orden.append(valor)
    return orden


def claves_unicas(mapa: Any, rel: str, informe: Informe, contexto: str) -> list[str]:
    """Las claves de un diccionario JSON ya son unicas: se valida el tipo."""
    if not isinstance(mapa, dict):
        informe.error(rel, "%s: se esperaba un objeto" % contexto)
        return []
    return list(mapa.keys())


def comprobar_referencia(
    valor: Any,
    validos: set[str],
    rel: str,
    campo: str,
    informe: Informe,
) -> None:
    """Comprueba que un identificador exista en el catalogo indicado."""
    if not isinstance(valor, str):
        informe.error(rel, "%s: debe ser una cadena" % campo)
        return
    if valor not in validos:
        informe.error(rel, "%s: '%s' no existe en el catalogo referenciado" % (campo, valor))


def comprobar_lista_de_referencias(
    valores: Any,
    validos: set[str],
    rel: str,
    campo: str,
    informe: Informe,
) -> None:
    if not isinstance(valores, list):
        informe.error(rel, "%s: se esperaba una lista" % campo)
        return
    for indice, valor in enumerate(valores):
        comprobar_referencia(valor, validos, rel, "%s[%d]" % (campo, indice), informe)


def comprobar_duplicados(valores: list[str], rel: str, campo: str, informe: Informe) -> None:
    vistos: set[str] = set()
    for valor in valores:
        if valor in vistos:
            informe.error(rel, "%s: valor duplicado '%s'" % (campo, valor))
        vistos.add(valor)


def comprobar_fichero_existe(ruta: Path, rel: str, campo: str, informe: Informe) -> None:
    if not ruta.is_file():
        informe.error(rel, "%s: no existe el archivo '%s'" % (campo, ruta.relative_to(RAIZ).as_posix()))


# ---------------------------------------------------------------------------
# Comprobaciones por archivo
# ---------------------------------------------------------------------------


def validar_mundo(informe: Informe) -> dict[str, Any]:
    """Especies, progenitores, misiones, eventos, festivales y batallas."""
    conteos: dict[str, Any] = {}

    especies = cargar_json(DATA / "world" / "species.json", informe)
    rel_sp = "data/world/species.json"
    informe.cuenta(rel_sp)
    ids_especie = claves_unicas(especies, rel_sp, informe, "raices")
    conteos["species"] = len(ids_especie)

    conversiones = cargar_json(DATA / "conversion" / "catalog.json", informe)
    rel_ca = "data/conversion/catalog.json"
    informe.cuenta(rel_ca)
    materiales = set(claves_unicas(conversiones.get("materials", {}), rel_ca, informe, "materials"))
    propiedades = set(claves_unicas(conversiones.get("properties", {}), rel_ca, informe, "properties"))

    muertes = cargar_json(DATA / "combat" / "deaths.json", informe)
    rel_de = "data/combat/deaths.json"
    informe.cuenta(rel_de)
    ids_muerte = claves_unicas(muertes, rel_de, informe, "raices")
    conteos["deaths"] = len(ids_muerte)

    # --- Especies: rival, actor y rangos de poblacion.
    if isinstance(especies, dict):
        for nombre, datos in especies.items():
            campo = "especies.%s" % nombre
            if not isinstance(datos, dict):
                informe.error(rel_sp, "%s: no es un objeto" % campo)
                continue
            rival = datos.get("rival")
            if rival is None:
                informe.error(rel_sp, "%s: falta 'rival'" % campo)
            else:
                comprobar_referencia(rival, set(ids_especie), rel_sp, "%s.rival" % campo, informe)

            inicio = datos.get("start")
            objetivo = datos.get("target")
            maximo = datos.get("max")
            if not all(isinstance(v, int) for v in (inicio, objetivo, maximo)):
                informe.error(rel_sp, "%s: 'start', 'target' y 'max' deben ser enteros" % campo)
            else:
                if not inicio <= objetivo <= maximo:
                    informe.error(
                        rel_sp,
                        "%s: start(%d) <= target(%d) <= max(%d) no se cumple"
                        % (campo, inicio, objetivo, maximo),
                    )

            actor = datos.get("actor")
            if not isinstance(actor, dict):
                informe.error(rel_sp, "%s.actor: falta o no es un objeto" % campo)
            else:
                material = actor.get("material")
                if material is None:
                    informe.error(rel_sp, "%s.actor: falta 'material'" % campo)
                else:
                    comprobar_referencia(material, materiales, rel_sp, "%s.actor.material" % campo, informe)
                muertes_especie = actor.get("deaths")
                if not isinstance(muertes_especie, list) or not muertes_especie:
                    informe.error(rel_sp, "%s.actor.deaths: debe ser una lista no vacia" % campo)
                else:
                    comprobar_lista_de_referencias(
                        muertes_especie, set(ids_muerte), rel_sp, "%s.actor.deaths" % campo, informe
                    )
                arte = actor.get("art")
                if not isinstance(arte, str) or not arte:
                    informe.error(rel_sp, "%s.actor.art: debe ser una cadena no vacia" % campo)
                else:
                    for sufijo in ("", "_e", "_n"):
                        comprobar_fichero_existe(
                            RAIZ / "art" / "beta" / ("%s%s.svg" % (arte, sufijo)),
                            rel_sp,
                            "%s.actor.art%s" % (campo, sufijo or " (base)"),
                            informe,
                        )

            for lista in ("names", "surnames"):
                valores = datos.get(lista)
                if not isinstance(valores, list):
                    informe.error(rel_sp, "%s.%s: falta o no es una lista" % (campo, lista))
                else:
                    comprobar_duplicados(valores, rel_sp, "%s.%s" % (campo, lista), informe)

    # --- Progenitores.
    progenitores = cargar_json(DATA / "world" / "progenitors.json", informe)
    rel_pr = "data/world/progenitors.json"
    informe.cuenta(rel_pr)
    ids_progenitor = claves_unicas(progenitores, rel_pr, informe, "raices")
    conteos["progenitors"] = len(ids_progenitor)
    if isinstance(progenitores, dict):
        for nombre, datos in progenitores.items():
            campo = "progenitores.%s" % nombre
            if not isinstance(datos, dict):
                informe.error(rel_pr, "%s: no es un objeto" % campo)
                continue
            material = datos.get("material")
            if material is None:
                informe.error(rel_pr, "%s: falta 'material'" % campo)
            else:
                comprobar_referencia(material, materiales, rel_pr, "%s.material" % campo, informe)
            fija = datos.get("fixed_property")
            if fija is None:
                informe.error(rel_pr, "%s: falta 'fixed_property'" % campo)
            else:
                comprobar_referencia(fija, propiedades, rel_pr, "%s.fixed_property" % campo, informe)
            muertes_prog = datos.get("deaths")
            if isinstance(muertes_prog, list):
                comprobar_lista_de_referencias(
                    muertes_prog, set(ids_muerte), rel_pr, "%s.deaths" % campo, informe
                )

    # --- Misiones.
    misiones = cargar_json(DATA / "world" / "missions.json", informe)
    rel_mi = "data/world/missions.json"
    informe.cuenta(rel_mi)
    ids_mision = claves_unicas(misiones, rel_mi, informe, "raices")
    conteos["missions"] = len(ids_mision)

    # --- Eventos.
    eventos = cargar_json(DATA / "world" / "events.json", informe)
    rel_ev = "data/world/events.json"
    informe.cuenta(rel_ev)
    lista_eventos = eventos.get("events") if isinstance(eventos, dict) else None
    ids_evento = ids_unicos(lista_eventos, "id", rel_ev, informe, "events")
    conteos["events"] = len(ids_evento)
    if isinstance(lista_eventos, list):
        for indice, evento in enumerate(lista_eventos):
            if not isinstance(evento, dict):
                continue
            campo = "events[%d]" % indice
            especie = evento.get("species")
            if especie is not None:
                comprobar_referencia(especie, set(ids_especie), rel_ev, "%s.species" % campo, informe)
            mision = evento.get("mission")
            if mision is not None:
                comprobar_referencia(mision, set(ids_mision), rel_ev, "%s.mission" % campo, informe)
            siguiente = evento.get("next")
            if siguiente is not None:
                if not isinstance(siguiente, list):
                    informe.error(rel_ev, "%s.next: se esperaba una lista" % campo)
                else:
                    for indice_next, enlace in enumerate(siguiente):
                        if not isinstance(enlace, dict):
                            informe.error(rel_ev, "%s.next[%d]: no es un objeto" % (campo, indice_next))
                            continue
                        comprobar_referencia(
                            enlace.get("event"),
                            set(ids_evento),
                            rel_ev,
                            "%s.next[%d].event" % (campo, indice_next),
                            informe,
                        )

    # --- Festivales.
    festivales = cargar_json(DATA / "world" / "festivals.json", informe)
    rel_fe = "data/world/festivals.json"
    informe.cuenta(rel_fe)
    lista_festivales = (
        festivales.get("festivals") if isinstance(festivales, dict) else None
    )
    ids_festival = ids_unicos(lista_festivales, "id", rel_fe, informe, "festivals")
    conteos["festivals"] = len(ids_festival)
    if isinstance(lista_festivales, list):
        for indice, festival in enumerate(lista_festivales):
            if not isinstance(festival, dict):
                continue
            campo = "festivals[%d]" % indice
            comprobar_referencia(festival.get("host"), set(ids_especie), rel_fe, "%s.host" % campo, informe)
            mes = festival.get("month")
            dia = festival.get("day")
            if not isinstance(mes, int) or not isinstance(dia, int):
                informe.error(rel_fe, "%s: 'month' y 'day' deben ser enteros" % campo)
            elif not (1 <= mes <= 12) or not (1 <= dia <= 31):
                informe.error(rel_fe, "%s: fecha fuera de rango (month=%s, day=%s)" % (campo, mes, dia))
    # --- Batallas.
    batalla = cargar_json(DATA / "world" / "battles.json", informe)
    rel_ba = "data/world/battles.json"
    informe.cuenta(rel_ba)
    if isinstance(batalla, dict):
        for seccion in ("names", "orders", "witness"):
            bloque = batalla.get(seccion)
            if not isinstance(bloque, dict):
                informe.error(rel_ba, "%s: falta o no es un objeto" % seccion)
                continue
            for clave in bloque:
                comprobar_referencia(
                    clave, set(ids_especie), rel_ba, "%s.%s" % (seccion, clave), informe
                )
    else:
        informe.error(rel_ba, "raices: se esperaba un objeto")

    return conteos


def validar_zonas(informe: Informe) -> None:
    """Zonas: reparto, rutas, objetos y convertibles contra la geometria."""
    directorio = DATA / "zones"
    if not directorio.is_dir():
        informe.error("data/zones", "no existe el directorio")
        return
    for ruta in sorted(directorio.glob("*.json")):
        rel = ruta.relative_to(RAIZ).as_posix()
        zona = cargar_json(ruta, informe)
        informe.cuenta(rel)
        if not isinstance(zona, dict):
            informe.error(rel, "raices: se esperaba un objeto")
            continue
        geometria = zona.get("geometry")
        if not isinstance(geometria, dict):
            informe.error(rel, "geometry: falta o no es un objeto")
            continue
        claves_geometria = set(geometria.keys())

        especies = cargar_json(DATA / "world" / "species.json", informe)
        ids_especie = set(especies.keys()) if isinstance(especies, dict) else set()

        zona_especies = zona.get("species")
        if not isinstance(zona_especies, list):
            informe.error(rel, "species: falta o no es una lista")
        else:
            comprobar_lista_de_referencias(zona_especies, ids_especie, rel, "species", informe)

        homes = zona.get("homes")
        if isinstance(homes, dict):
            for nombre, casa in homes.items():
                if nombre not in ids_especie:
                    informe.error(rel, "homes.%s: no es una especie del catalogo" % nombre)
                if not isinstance(casa, dict):
                    informe.error(rel, "homes.%s: no es un objeto" % nombre)
                    continue
                for campo in ("area", "gate"):
                    valor = casa.get(campo)
                    if not isinstance(valor, str):
                        informe.error(rel, "homes.%s.%s: debe ser una cadena" % (nombre, campo))
                    elif valor not in claves_geometria:
                        informe.error(
                            rel,
                            "homes.%s.%s: '%s' no existe en geometry" % (nombre, campo, valor),
                        )

        conversiones = cargar_json(DATA / "conversion" / "catalog.json", informe)
        materiales = set(conversiones.get("materials", {}).keys()) if isinstance(conversiones, dict) else set()

        actores = zona.get("actors")
        if isinstance(actores, list):
            ids_unicos(actores, "id", rel, informe, "actors")
            for indice, actor in enumerate(actores):
                if not isinstance(actor, dict):
                    continue
                campo = "actors[%d]" % indice
                especie = actor.get("species")
                if especie is not None:
                    comprobar_referencia(especie, ids_especie, rel, "%s.species" % campo, informe)
                ruta_patron = actor.get("route")
                if not isinstance(ruta_patron, str):
                    informe.error(rel, "%s.route: debe ser una cadena" % campo)
                elif ruta_patron not in claves_geometria:
                    informe.error(
                        rel, "%s.route: '%s' no existe en geometry" % (campo, ruta_patron)
                    )
                progenitor = actor.get("progenitor")
                if progenitor is not None:
                    progenitores = cargar_json(DATA / "world" / "progenitors.json", informe)
                    ids_progenitor = set(progenitores.keys()) if isinstance(progenitores, dict) else set()
                    comprobar_referencia(
                        progenitor, ids_progenitor, rel, "%s.progenitor" % campo, informe
                    )
                arma = actor.get("weapon")
                if arma is not None:
                    armas = cargar_json(DATA / "combat" / "weapons.json", informe)
                    ids_arma = set(armas.get("enemy", {}).keys()) if isinstance(armas, dict) else set()
                    comprobar_referencia(arma, ids_arma, rel, "%s.weapon" % campo, informe)

        objetos = zona.get("items")
        if isinstance(objetos, list):
            ids_unicos(objetos, "id", rel, informe, "items")
            for indice, objeto in enumerate(objetos):
                if not isinstance(objeto, dict):
                    continue
                campo = "items[%d]" % indice
                posicion = objeto.get("at")
                if not isinstance(posicion, str):
                    informe.error(rel, "%s.at: debe ser una cadena" % campo)
                elif posicion not in claves_geometria:
                    informe.error(rel, "%s.at: '%s' no existe en geometry" % (campo, posicion))
                arte = objeto.get("art")
                if isinstance(arte, str) and arte:
                    if arte.startswith("res://"):
                        comprobar_fichero_existe(RAIZ / arte[len("res://"):], rel, "%s.art" % campo, informe)
                    else:
                        comprobar_fichero_existe(
                            RAIZ / "art" / "beta" / ("%s.svg" % arte), rel, "%s.art" % campo, informe
                        )

        convertibles = zona.get("convertibles")
        if isinstance(convertibles, list):
            ids_unicos(convertibles, "id", rel, informe, "convertibles")
            for indice, convertible in enumerate(convertibles):
                if not isinstance(convertible, dict):
                    continue
                campo = "convertibles[%d]" % indice
                material = convertible.get("material")
                if material is None:
                    informe.error(rel, "%s.material: falta" % campo)
                else:
                    comprobar_referencia(material, materiales, rel, "%s.material" % campo, informe)

        props = zona.get("props")
        if isinstance(props, list):
            for indice, prop in enumerate(props):
                if not isinstance(prop, dict):
                    continue
                campo = "props[%d]" % indice
                posicion = prop.get("at")
                if not isinstance(posicion, str):
                    informe.error(rel, "%s.at: debe ser una cadena" % campo)
                elif posicion not in claves_geometria:
                    informe.error(rel, "%s.at: '%s' no existe en geometry" % (campo, posicion))
                material = prop.get("material")
                if material is not None:
                    comprobar_referencia(material, materiales, rel, "%s.material" % campo, informe)

        material_mina = zona.get("mine_material")
        if material_mina is not None:
            comprobar_referencia(material_mina, materiales, rel, "mine_material", informe)


def validar_ia(informe: Informe) -> dict[str, Any]:
    """Personalidades, apodos y caras: misma lista de IAs en los tres."""
    conteos: dict[str, Any] = {}

    personalidades = cargar_json(DATA / "ai" / "personalities.json", informe)
    rel_pe = "data/ai/personalities.json"
    informe.cuenta(rel_pe)
    ids_ia: list[str] = []
    if isinstance(personalidades, dict):
        ais = personalidades.get("ais")
        ids_ia = claves_unicas(ais, rel_pe, informe, "ais")
        conteos["personalities_ais"] = len(ids_ia)
        pares = personalidades.get("pairs")
        if not isinstance(pares, list):
            informe.error(rel_pe, "pairs: falta o no es una lista")
            conteos["personalities_pairs"] = 0
        else:
            conteos["personalities_pairs"] = len(pares)
            for indice, par in enumerate(pares):
                if not isinstance(par, dict):
                    informe.error(rel_pe, "pairs[%d]: no es un objeto" % indice)
                    continue
                for lado in ("a", "b"):
                    comprobar_referencia(
                        par.get(lado), set(ids_ia), rel_pe, "pairs[%d].%s" % (indice, lado), informe
                    )
                lineas = par.get("lines")
                if not isinstance(lineas, list):
                    informe.error(rel_pe, "pairs[%d].lines: falta o no es una lista" % indice)
    else:
        informe.error(rel_pe, "raices: se esperaba un objeto")

    caras = cargar_json(DATA / "art" / "ai_faces.json", informe)
    rel_ca = "data/art/ai_faces.json"
    informe.cuenta(rel_ca)
    ids_cara = claves_unicas(caras, rel_ca, informe, "raices")
    conteos["ai_faces"] = len(ids_cara)

    apodos = cargar_json(DATA / "ai" / "nicknames.json", informe)
    rel_ni = "data/ai/nicknames.json"
    informe.cuenta(rel_ni)
    total_grupos = 0
    total_motes = 0
    if isinstance(apodos, dict):
        for seccion in ("ais", "progenitors"):
            bloque = apodos.get(seccion)
            if not isinstance(bloque, dict):
                informe.error(rel_ni, "%s: falta o no es un objeto" % seccion)
                continue
            total_grupos += len(bloque)
            for clave, motes in bloque.items():
                if not isinstance(motes, list) or not motes:
                    informe.error(rel_ni, "%s.%s: debe ser una lista no vacia" % (seccion, clave))
                    continue
                total_motes += len(motes)
                comprobar_duplicados(motes, rel_ni, "%s.%s" % (seccion, clave), informe)
                if seccion == "ais":
                    comprobar_referencia(clave, set(ids_ia), rel_ni, "%s.%s" % (seccion, clave), informe)
                else:
                    progenitores = cargar_json(DATA / "world" / "progenitors.json", informe)
                    ids_progenitor = set(progenitores.keys()) if isinstance(progenitores, dict) else set()
                    comprobar_referencia(
                        clave, ids_progenitor, rel_ni, "%s.%s" % (seccion, clave), informe
                    )
    else:
        informe.error(rel_ni, "raices: se esperaba un objeto")
    conteos["nicknames_grupos"] = total_grupos
    conteos["nicknames_motes"] = total_motes

    # Alineacion de IAs entre los tres catalogos.
    conjunto_ia = set(ids_ia)
    for etiqueta, lista in (("ai_faces", ids_cara),):
        if conjunto_ia != set(lista):
            solo_ia = sorted(conjunto_ia - set(lista))
            solo_otr = sorted(set(lista) - conjunto_ia)
            detalle = "las IAs no coinciden con data/ai/personalities.json"
            if solo_ia:
                detalle += "; solo en personalities: %s" % ", ".join(solo_ia)
            if solo_otr:
                detalle += "; solo en %s: %s" % (etiqueta, ", ".join(solo_otr))
            informe.error(rel_ca, detalle)

    return conteos


def validar_conversion(informe: Informe) -> dict[str, Any]:
    """Catalogo de conversion y banco de preguntas."""
    conteos: dict[str, Any] = {}

    catalogo = cargar_json(DATA / "conversion" / "catalog.json", informe)
    rel_ca = "data/conversion/catalog.json"
    informe.cuenta(rel_ca)
    if isinstance(catalogo, dict):
        materiales = claves_unicas(catalogo.get("materials", {}), rel_ca, informe, "materials")
        objetivos = claves_unicas(catalogo.get("objectives", {}), rel_ca, informe, "objectives")
        propiedades = claves_unicas(catalogo.get("properties", {}), rel_ca, informe, "properties")
        acciones = claves_unicas(catalogo.get("actions", {}), rel_ca, informe, "actions")
        conteos["conversion_materials"] = len(materiales)
        conteos["conversion_objectives"] = len(objetivos)
        conteos["conversion_properties"] = len(propiedades)
        conteos["conversion_actions"] = len(acciones)

        conjunto_propiedades = set(propiedades)
        for material, datos in (catalogo.get("materials") or {}).items():
            if not isinstance(datos, dict):
                informe.error(rel_ca, "materials.%s: no es un objeto" % material)
                continue
            comprobar_lista_de_referencias(
                datos.get("properties", []),
                conjunto_propiedades,
                rel_ca,
                "materials.%s.properties" % material,
                informe,
            )
        conjunto_acciones = set(acciones)
        for objetivo, datos in (catalogo.get("objectives") or {}).items():
            if not isinstance(datos, dict):
                informe.error(rel_ca, "objectives.%s: no es un objeto" % objetivo)
                continue
            comprobar_lista_de_referencias(
                datos.get("actions", []),
                conjunto_acciones,
                rel_ca,
                "objectives.%s.actions" % objetivo,
                informe,
            )
    else:
        informe.error(rel_ca, "raices: se esperaba un objeto")

    preguntas = cargar_json(DATA / "conversion" / "questions.json", informe)
    rel_qu = "data/conversion/questions.json"
    informe.cuenta(rel_qu)
    conteos["questions"] = len(preguntas) if isinstance(preguntas, list) else 0
    if isinstance(preguntas, list):
        textos: list[str] = []
        for indice, pregunta in enumerate(preguntas):
            if not isinstance(pregunta, dict):
                informe.error(rel_qu, "questions[%d]: no es un objeto" % indice)
                continue
            campo = "questions[%d]" % indice
            texto = pregunta.get("text")
            if not isinstance(texto, str) or not texto:
                informe.error(rel_qu, "%s.text: debe ser una cadena no vacia" % campo)
            else:
                textos.append(texto)
            opciones = pregunta.get("options")
            if not isinstance(opciones, list):
                informe.error(rel_qu, "%s.options: falta o no es una lista" % campo)
                continue
            if len(opciones) < 2:
                informe.error(rel_qu, "%s.options: hacen falta al menos 2 opciones" % campo)
            respuesta = pregunta.get("answer")
            if not isinstance(respuesta, int) or isinstance(respuesta, bool):
                informe.error(rel_qu, "%s.answer: debe ser un entero" % campo)
            elif not (0 <= respuesta < len(opciones)):
                informe.error(
                    rel_qu,
                    "%s.answer: %d esta fuera de las opciones (0..%d)" % (campo, respuesta, len(opciones) - 1),
                )
        comprobar_duplicados(textos, rel_qu, "questions.text", informe)
    else:
        informe.error(rel_qu, "raices: se esperaba una lista")

    return conteos


def validar_combat(informe: Informe) -> dict[str, Any]:
    """Armas y catalogo de muertes."""
    conteos: dict[str, Any] = {}
    armas = cargar_json(DATA / "combat" / "weapons.json", informe)
    rel_w = "data/combat/weapons.json"
    informe.cuenta(rel_w)
    if isinstance(armas, dict):
        for seccion in ("player", "enemy"):
            bloque = armas.get(seccion)
            if not isinstance(bloque, dict):
                informe.error(rel_w, "%s: falta o no es un objeto" % seccion)
                conteos["weapons_%s" % seccion] = 0
                continue
            conteos["weapons_%s" % seccion] = len(bloque)
            claves_unicas(bloque, rel_w, informe, seccion)
    else:
        informe.error(rel_w, "raices: se esperaba un objeto")
    return conteos


def validar_investigacion(informe: Informe) -> dict[str, Any]:
    """Casos de investigacion: npcs, pruebas, ambiente y dialogos.

    El contrato es el que comprueba investigation/investigation_director.gd:
    cada npc apunta a un nodo de dialogo, cada nodo lo pronuncia un npc y
    cada opcion apunta a otro nodo existente o a "" para cerrar.
    """
    conteos: dict[str, Any] = {}
    directorio = DATA / "investigation"
    for ruta in sorted(directorio.glob("*.json")):
        rel = ruta.relative_to(RAIZ).as_posix()
        caso = cargar_json(ruta, informe)
        informe.cuenta(rel)
        if not isinstance(caso, dict):
            informe.error(rel, "raices: se esperaba un objeto")
            continue

        npcs = caso.get("npcs")
        ids_npc: list[str] = []
        if isinstance(npcs, list):
            ids_npc = ids_unicos(npcs, "id", rel, informe, "npcs")
            for indice, npc in enumerate(npcs):
                if not isinstance(npc, dict):
                    continue
                campo = "npcs[%d]" % indice
                for clave in ("name", "race", "pos", "dialogue"):
                    if clave not in npc:
                        informe.error(rel, "%s: falta '%s'" % (campo, clave))
                # La raza puede no estar en el catalogo (p.ej. 'maquina'): el juego
                # usa un color por defecto, asi que basta con que sea una cadena.
                raza = npc.get("race")
                if not isinstance(raza, str) or not raza:
                    informe.error(rel, "%s.race: debe ser una cadena no vacia" % campo)
                posicion = npc.get("pos")
                if posicion is not None and (
                    not isinstance(posicion, list)
                    or len(posicion) != 2
                    or not all(isinstance(v, (int, float)) for v in posicion)
                ):
                    informe.error(rel, "%s.pos: se esperaba [x, y] numerico" % campo)
        else:
            informe.error(rel, "npcs: falta o no es una lista")

        pruebas = caso.get("evidence")
        if isinstance(pruebas, list):
            ids_unicos(pruebas, "id", rel, informe, "evidence")
            for indice, prueba in enumerate(pruebas):
                if not isinstance(prueba, dict):
                    continue
                campo = "evidence[%d]" % indice
                for clave in ("name", "pos", "text", "observation"):
                    if clave not in prueba:
                        informe.error(rel, "%s: falta '%s'" % (campo, clave))
        else:
            informe.error(rel, "evidence: falta o no es una lista")

        dialogos = caso.get("dialogue")
        if not isinstance(dialogos, dict):
            informe.error(rel, "dialogue: falta o no es un objeto")
            dialogos = {}
        for clave, nodo in dialogos.items():
            campo = "dialogue.%s" % clave
            if not isinstance(nodo, dict):
                informe.error(rel, "%s: no es un objeto" % campo)
                continue
            hablante = nodo.get("speaker")
            if not isinstance(hablante, str):
                informe.error(rel, "%s.speaker: debe ser una cadena" % campo)
            elif hablante not in ids_npc:
                informe.error(rel, "%s.speaker: '%s' no es un npc del caso" % (campo, hablante))
            if not isinstance(nodo.get("text"), str) or not nodo.get("text"):
                informe.error(rel, "%s.text: debe ser una cadena no vacia" % campo)
            opciones = nodo.get("options")
            if not isinstance(opciones, list):
                informe.error(rel, "%s.options: falta o no es una lista" % campo)
                continue
            for indice, opcion in enumerate(opciones):
                if not isinstance(opcion, dict):
                    informe.error(rel, "%s.options[%d]: no es un objeto" % (campo, indice))
                    continue
                sub = "%s.options[%d]" % (campo, indice)
                if not isinstance(opcion.get("text"), str) or not opcion.get("text"):
                    informe.error(rel, "%s.text: debe ser una cadena no vacia" % sub)
                destino = opcion.get("next")
                if not isinstance(destino, str):
                    informe.error(rel, "%s.next: debe ser una cadena" % sub)
                elif destino and destino not in dialogos:
                    informe.error(rel, "%s.next: '%s' no es un nodo de dialogo" % (sub, destino))
                for clave in ("requires", "forbids", "sets"):
                    if clave in opcion and not isinstance(opcion[clave], list):
                        informe.error(rel, "%s.%s: se esperaba una lista" % (sub, clave))

        for indice, npc in enumerate(npcs if isinstance(npcs, list) else []):
            if not isinstance(npc, dict):
                continue
            entrada = npc.get("dialogue")
            if isinstance(entrada, str) and entrada and entrada not in dialogos:
                informe.error(
                    rel, "npcs[%d].dialogue: '%s' no es un nodo de dialogo" % (indice, entrada)
                )

        ambiente = caso.get("ambient")
        if isinstance(ambiente, list):
            for indice, amb in enumerate(ambiente):
                if not isinstance(amb, dict):
                    informe.error(rel, "ambient[%d]: no es un objeto" % indice)
                    continue
                campo = "ambient[%d]" % indice
                comprobar_lista_de_referencias(
                    amb.get("npcs", []), set(ids_npc), rel, "%s.npcs" % campo, informe
                )
                lineas = amb.get("lines")
                if not isinstance(lineas, list):
                    informe.error(rel, "%s.lines: falta o no es una lista" % campo)
                    continue
                for indice_linea, linea in enumerate(lineas):
                    if not isinstance(linea, list) or len(linea) < 2:
                        informe.error(
                            rel,
                            "%s.lines[%d]: se esperaba [hablante, texto]" % (campo, indice_linea),
                        )
                        continue
                    hablante = linea[0]
                    if hablante not in set(ids_npc):
                        informe.error(
                            rel,
                            "%s.lines[%d]: '%s' no es un npc del caso" % (campo, indice_linea, hablante),
                        )
        else:
            informe.error(rel, "ambient: falta o no es una lista")

        conteos[ruta.stem] = {
            "npcs": len(npcs) if isinstance(npcs, list) else 0,
            "evidence": len(pruebas) if isinstance(pruebas, list) else 0,
            "ambient": len(ambiente) if isinstance(ambiente, list) else 0,
            "dialogue": len(dialogos) if isinstance(dialogos, dict) else 0,
        }
    return conteos


def validar_arte(informe: Informe) -> dict[str, Any]:
    """Atlas de piezas, animaciones enemigas y vista del protagonista."""
    conteos: dict[str, Any] = {}

    atlas = cargar_json(DATA / "art" / "atlas_piezas.json", informe)
    rel_at = "data/art/atlas_piezas.json"
    informe.cuenta(rel_at)
    claves_atlas = claves_unicas(atlas, rel_at, informe, "raices")
    conteos["atlas_piezas"] = len(claves_atlas)

    # El atlas debe cubrir las piezas de los rigs y solo las piezas de los rigs.
    directorio_rig = RAIZ / "art" / "beta" / "rig"
    piezas_rig: set[str] = set()
    if directorio_rig.is_dir():
        for sub in sorted(directorio_rig.iterdir()):
            if not sub.is_dir():
                continue
            for svg in sorted(sub.glob("*.svg")):
                piezas_rig.add("%s/%s" % (sub.name, svg.stem))
    else:
        informe.error(rel_at, "no existe el directorio de rigs 'art/beta/rig'")

    for clave in piezas_rig:
        if clave not in claves_atlas:
            informe.error(rel_at, "falta la pieza del rig '%s'" % clave)
    for clave in claves_atlas:
        if clave not in piezas_rig and "/" in clave:
            informe.error(rel_at, "la pieza '%s' no corresponde a ningún rig" % clave)

    # Fotogramas por acción (P-25): claves sin '/' para no confundirlas con piezas de rig.
    fotogramas = cargar_json(DATA / "art" / "action_frames.json", informe)
    rel_fr = "data/art/action_frames.json"
    informe.cuenta(rel_fr)
    acciones = fotogramas.get("acciones") if isinstance(fotogramas, dict) else None
    if not isinstance(acciones, dict):
        informe.error(rel_fr, "acciones: falta o no es un objeto")
    else:
        conteos["action_frames"] = len(acciones)
        for accion, bloque in acciones.items():
            if not isinstance(bloque, dict):
                informe.error(rel_fr, "%s: no es un objeto" % accion)
                continue
            claves = bloque.get("frames")
            if not isinstance(claves, list) or not claves:
                informe.error(rel_fr, "%s.frames: falta o está vacío" % accion)
                continue
            fps = bloque.get("fps")
            if not isinstance(fps, (int, float)) or fps <= 0:
                informe.error(rel_fr, "%s.fps: debe ser un número positivo" % accion)
            for clave in claves:
                if "/" in str(clave):
                    informe.error(rel_fr, "%s: '%s' no puede llevar '/'" % (accion, clave))
                elif clave not in claves_atlas:
                    informe.error(rel_fr, "%s: '%s' no está en el atlas" % (accion, clave))

    animaciones = cargar_json(DATA / "art" / "enemy_animations.json", informe)
    rel_en = "data/art/enemy_animations.json"
    informe.cuenta(rel_en)
    conteos["enemy_animations"] = len(claves_unicas(animaciones, rel_en, informe, "raices"))

    protagonista = cargar_json(DATA / "art" / "protagonista.json", informe)
    rel_pr = "data/art/protagonista.json"
    informe.cuenta(rel_pr)
    if isinstance(protagonista, dict):
        vistas = protagonista.get("views")
        variantes = protagonista.get("variants")
        if not isinstance(vistas, dict):
            informe.error(rel_pr, "views: falta o no es un objeto")
            conteos["protagonista_vistas"] = 0
        else:
            conteos["protagonista_vistas"] = len(vistas)
        if not isinstance(variantes, dict):
            informe.error(rel_pr, "variants: falta o no es un objeto")
            conteos["protagonista_variantes"] = 0
        else:
            conteos["protagonista_variantes"] = len(variantes)
            for nombre, lista in variantes.items():
                if not isinstance(lista, list):
                    informe.error(rel_pr, "variants.%s: se esperaba una lista" % nombre)
    else:
        informe.error(rel_pr, "raices: se esperaba un objeto")

    return conteos


def validar_audio(informe: Informe) -> dict[str, Any]:
    """Banco de musica y voces."""
    conteos: dict[str, Any] = {}
    biblioteca = cargar_json(DATA / "audio" / "library.json", informe)
    rel_li = "data/audio/library.json"
    informe.cuenta(rel_li)
    if isinstance(biblioteca, dict):
        pistas = biblioteca.get("tracks")
        voces = biblioteca.get("voices")
        conteos["library_pistas"] = len(pistas) if isinstance(pistas, list) else 0
        conteos["library_voces"] = len(voces) if isinstance(voces, list) else 0
        if isinstance(pistas, list):
            for indice, pista in enumerate(pistas):
                if not isinstance(pista, dict):
                    informe.error(rel_li, "tracks[%d]: no es un objeto" % indice)
                    continue
                archivo = pista.get("file")
                if not isinstance(archivo, str) or not archivo:
                    informe.error(rel_li, "tracks[%d].file: falta o vacio" % indice)
                elif archivo.startswith("res://"):
                    comprobar_fichero_existe(
                        RAIZ / archivo[len("res://"):], rel_li, "tracks[%d].file" % indice, informe
                    )
            archivos = [p.get("file") for p in pistas if isinstance(p, dict)]
            comprobar_duplicados(
                [a for a in archivos if isinstance(a, str)], rel_li, "tracks.file", informe
            )
    else:
        informe.error(rel_li, "raices: se esperaba un objeto")
    return conteos


def validar_comentarios(informe: Informe) -> dict[str, Any]:
    """Comentarios del protagonista."""
    conteos: dict[str, Any] = {}
    comentarios = cargar_json(DATA / "protagonist" / "comments.json", informe)
    rel_co = "data/protagonist/comments.json"
    informe.cuenta(rel_co)
    if isinstance(comentarios, dict):
        conteos["comments_grupos"] = len(comentarios)
        for clave, valor in comentarios.items():
            if not isinstance(valor, list):
                informe.error(rel_co, "%s: se esperaba una lista" % clave)
                continue
            comprobar_duplicados(valor, rel_co, clave, informe)
    else:
        informe.error(rel_co, "raices: se esperaba un objeto")
    return conteos


def validar_i18n(informe: Informe) -> dict[str, Any]:
    """Tabla de textos en español."""
    conteos: dict[str, Any] = {}
    ruta = DATA / "i18n" / "textos.csv"
    rel = ruta.relative_to(RAIZ).as_posix()
    informe.cuenta(rel)
    if not ruta.is_file():
        informe.error(rel, "no existe el archivo")
        return conteos
    try:
        texto = ruta.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        informe.error(rel, "no se puede leer como UTF-8: %s" % exc)
        return conteos
    lineas = [linea for linea in texto.splitlines() if linea.strip()]
    if not lineas:
        informe.error(rel, "el archivo esta vacio")
        return conteos
    if lineas[0].strip() != "keys,es":
        informe.error(rel, "la cabecera debe ser 'keys,es' (es '%s')" % lineas[0].strip())
    entradas = lineas[1:]
    conteos["textos"] = len(entradas)
    claves: list[str] = []
    for indice, linea in enumerate(entradas):
        partes = linea.split(",")
        if len(partes) < 2:
            informe.error(rel, "línea %d: faltan columnas" % (indice + 2))
            continue
        claves.append(partes[0].strip())
    comprobar_duplicados(claves, rel, "keys", informe)
    return conteos


def validar_controles(informe: Informe) -> None:
    """Controles de la interfaz."""
    ruta = DATA / "ui" / "controls.json"
    rel = ruta.relative_to(RAIZ).as_posix()
    controles = cargar_json(ruta, informe)
    informe.cuenta(rel)
    if not isinstance(controles, dict):
        informe.error(rel, "raices: se esperaba un objeto")
        return
    for seccion in ("compact", "keyboard", "mouse", "notes"):
        if not isinstance(controles.get(seccion), list):
            informe.error(rel, "%s: falta o no es una lista" % seccion)


def validar_formato(informe: Informe) -> None:
    """UTF-8 sin BOM y finales de linea LF en todos los JSON de data/."""
    for ruta in sorted(DATA.rglob("*.json")):
        rel = ruta.relative_to(RAIZ).as_posix()
        informe.cuenta(rel)
        bytes_leidos = ruta.read_bytes()
        if bytes_leidos.startswith(b"\xef\xbb\xbf"):
            informe.error(rel, "el archivo tiene BOM UTF-8")
        if b"\r\n" in bytes_leidos:
            informe.error(rel, "el archivo tiene finales de linea CRLF (deben ser LF)")
        if b"\r" in bytes_leidos.replace(b"\r\n", b""):
            informe.error(rel, "el archivo tiene finales de linea CR (deben ser LF)")
        try:
            bytes_leidos.decode("utf-8")
        except UnicodeDecodeError as exc:
            informe.error(rel, "no es UTF-8 valido: %s" % exc)


# ---------------------------------------------------------------------------
# Referencia de conteos
# ---------------------------------------------------------------------------


def construir_conteos() -> dict[str, Any]:
    """Calcula los conteos actuales de cada archivo de datos."""
    informe = Informe()
    conteos: dict[str, Any] = {}
    conteos.update(validar_mundo(informe))
    conteos.update(validar_zonas(informe) or {})
    conteos.update(validar_ia(informe))
    conteos.update(validar_conversion(informe))
    conteos.update(validar_combat(informe))
    conteos.update(validar_investigacion(informe))
    conteos.update(validar_arte(informe))
    conteos.update(validar_audio(informe))
    conteos.update(validar_comentarios(informe))
    conteos.update(validar_i18n(informe))
    conteos["zones"] = len(list((DATA / "zones").glob("*.json"))) if (DATA / "zones").is_dir() else 0
    return conteos


def comparar_conteos(
    conteos: dict[str, Any], referencia: dict[str, Any], informe: Informe, estricto: bool
) -> None:
    """Compara los conteos actuales con la referencia guardada."""
    claves = sorted(set(conteos) | set(referencia))
    for clave in claves:
        actual = conteos.get(clave)
        esperado = referencia.get(clave)
        if esperado is None:
            mensaje = "no hay en la referencia (valor actual %s)" % json.dumps(actual, ensure_ascii=False)
            if estricto:
                informe.error("tools/referencia_datos.json", "%s: %s" % (clave, mensaje))
            else:
                informe.aviso("tools/referencia_datos.json", "%s: %s" % (clave, mensaje))
            continue
        if actual != esperado:
            mensaje = "conteo %s, se esperaba %s" % (
                json.dumps(actual, ensure_ascii=False),
                json.dumps(esperado, ensure_ascii=False),
            )
            if estricto:
                informe.error("tools/referencia_datos.json", "%s: %s" % (clave, mensaje))
            else:
                informe.aviso("tools/referencia_datos.json", "%s: %s" % (clave, mensaje))


def actualizar_referencia(conteos: dict[str, Any]) -> None:
    REFERENCIA.parent.mkdir(parents=True, exist_ok=True)
    REFERENCIA.write_text(
        json.dumps(conteos, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
        newline="\n",
    )


# ---------------------------------------------------------------------------
# Principal
# ---------------------------------------------------------------------------


def main(argv: list[str]) -> int:
    analizador = argparse.ArgumentParser(
        description="Valida los datos del juego Bug de Familia (sin modificar data/)."
    )
    analizador.add_argument(
        "--actualizar",
        action="store_true",
        help="reescribe tools/referencia_datos.json con los conteos actuales",
    )
    analizador.add_argument(
        "--estricto",
        action="store_true",
        help="los conteos que no cuadran con la referencia tambien son errores",
    )
    argumentos = analizador.parse_args(argv)

    if not DATA.is_dir():
        print("ERROR data no existe el directorio 'data/'", file=sys.stderr)
        return 1

    informe = Informe()

    conteos: dict[str, Any] = {}
    conteos.update(validar_mundo(informe))
    validar_zonas(informe)
    conteos.update(validar_ia(informe))
    conteos.update(validar_conversion(informe))
    conteos.update(validar_combat(informe))
    conteos.update(validar_investigacion(informe))
    conteos.update(validar_arte(informe))
    conteos.update(validar_audio(informe))
    conteos.update(validar_comentarios(informe))
    conteos.update(validar_i18n(informe))
    validar_controles(informe)
    conteos["zones"] = len(list((DATA / "zones").glob("*.json"))) if (DATA / "zones").is_dir() else 0
    validar_formato(informe)

    if argumentos.actualizar:
        actualizar_referencia(conteos)
        print("Referencia actualizada: %s" % REFERENCIA.relative_to(RAIZ).as_posix())

    if REFERENCIA.is_file():
        try:
            referencia = json.loads(REFERENCIA.read_text(encoding="utf-8"))
        except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
            informe.error(
                REFERENCIA.relative_to(RAIZ).as_posix(), "no se puede leer la referencia: %s" % exc
            )
            referencia = {}
        if isinstance(referencia, dict):
            comparar_conteos(conteos, referencia, informe, argumentos.estricto)
        else:
            informe.error(
                REFERENCIA.relative_to(RAIZ).as_posix(), "la referencia debe ser un objeto JSON"
            )
    elif argumentos.estricto:
        informe.error(
            REFERENCIA.relative_to(RAIZ).as_posix(),
            "no existe la referencia; ejecuta el script con --actualizar",
        )

    for aviso in informe.avisos:
        print(aviso)
    for error in informe.errores:
        print(error)

    total_errores = len(informe.errores)
    if total_errores:
        print(
            "FALLO: %d errores (%d comprobaciones, %d archivos)"
            % (total_errores, informe.comprobaciones, len(informe.archivos))
        )
        return 1
    print("OK: %d comprobaciones, %d archivos" % (informe.comprobaciones, len(informe.archivos)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
