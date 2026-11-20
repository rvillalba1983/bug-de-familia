#!/usr/bin/env python3
"""Pruebas de las herramientas de validacion (stdlib, sin dependencias).

Se ejecutan con:

    python -m unittest discover -s tools/tests -q

Cubren los casos limite de `validar_rutas.py`, `validar_informes.py`,
`verificar_humo.py` y `poblar_zonas.py` con arboles y XML temporales: no tocan
el repositorio ni necesitan Godot.
"""
from __future__ import annotations

import json
import os
import sys
import tempfile
import unittest
import unittest.mock
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import poblar_zonas  # noqa: E402
import validar_conversaciones  # noqa: E402
import validar_datos  # noqa: E402
import validar_informes  # noqa: E402
import validar_rutas  # noqa: E402
import verificar_humo  # noqa: E402


def escribir(ruta: Path, texto: str) -> Path:
    ruta.parent.mkdir(parents=True, exist_ok=True)
    ruta.write_text(texto, encoding="utf-8")
    return ruta


def informe(tests: int, suites: int = 1, fallos: int = 0, omitidas: int = 0,
            errores: int = 0, casos: int | None = None,
            paquete: str = "tests/core", fallos_raiz: int | None = None,
            errores_raiz: int | None = None,
            omitidas_raiz: int | None = None) -> str:
    """Construye un results.xml de GdUnit4 con los conteos pedidos.

    Los parametros `*_raiz` permiten un XML cuyo agregado de la raiz no
    coincide con las suites (informe truncado o manipulado). El XML real de
    GdUnit4 no escribe `errors` en la raiz; aqui se escribe para poder
    probar su deteccion.
    """
    casos = tests if casos is None else casos
    por_suite = casos // suites if suites else 0
    hijos = "".join(
        f'<testsuite name="suite{i}" package="{paquete}" tests="{por_suite}" '
        f'failures="{fallos if i == 0 else 0}" '
        f'errors="{errores if i == 0 else 0}" '
        f'skipped="{omitidas if i == 0 else 0}">'
        + "".join(f'<testcase name="t{j}" classname="suite{i}" time="0.1">'
                  f'</testcase>' for j in range(por_suite))
        + "</testsuite>"
        for i in range(suites)
    )
    return (f'<?xml version="1.0" encoding="UTF-8" ?>'
            f'<testsuites name="report_1" tests="{tests}" '
            f'failures="{fallos_raiz if fallos_raiz is not None else fallos}" '
            f'errors="{errores_raiz if errores_raiz is not None else errores}" '
            f'skipped="{omitidas_raiz if omitidas_raiz is not None else omitidas}" '
            f'flaky="0" time="0.1">{hijos}</testsuites>')


class RutasTest(unittest.TestCase):
    def test_ignora_dinamicas_directorios_y_godot(self) -> None:
        texto = "\n".join([
            'const A := "res://art/shared/%s.svg"',
            'const B := "res://data/zones/"',
            'const C := "res://.godot/imported/x.ctex"',
            'const D := "res://"',
        ])
        self.assertEqual(list(validar_rutas.literales(texto)), [])

    def test_detecta_ruta_y_linea(self) -> None:
        texto = "uno\nconst P := \"res://scenes/beta/beta_zone.tscn\"\n"
        self.assertEqual(list(validar_rutas.literales(texto)),
                         [(2, "res://scenes/beta/beta_zone.tscn")])

    def test_comprobar_detecta_ruta_inexistente(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            raiz = Path(temporal)
            escribir(raiz / "core" / "a.gd", 'const P := "res://falta/x.tscn"\n')
            revisados, total, errores = validar_rutas.comprobar(raiz)
            self.assertEqual((revisados, total), (1, 1))
            self.assertEqual(len(errores), 1)
            self.assertIn("core/a.gd:1", errores[0])
            self.assertIn("res://falta/x.tscn", errores[0])

    def test_comprobar_acepta_archivo_y_directorio(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            raiz = Path(temporal)
            escribir(raiz / "data" / "zones" / "despliegue_cero.json", "{}\n")
            escribir(raiz / "core" / "a.gd",
                     'load("res://data/zones/despliegue_cero.json")\n'
                     'load("res://data/zones/")\n')
            _, _, errores = validar_rutas.comprobar(raiz)
            self.assertEqual(errores, [])

    def test_ignora_carpetas_no_operativas(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            raiz = Path(temporal)
            escribir(raiz / "docs" / "nota.gd", 'load("res://viejo/x.tscn")\n')
            escribir(raiz / "addons" / "x" / "a.gd",
                     'load("res://viejo/y.tscn")\n')
            revisados, _, errores = validar_rutas.comprobar(raiz)
            self.assertEqual(revisados, 0)
            self.assertEqual(errores, [])


class InformesTest(unittest.TestCase):
    def comprobar(self, xml: str, minimo: int = 1,
                  carpetas: list[str] | None = None) -> tuple[bool, list[str]]:
        with tempfile.TemporaryDirectory() as temporal:
            base = Path(temporal)
            escribir(base / "report_3" / "results.xml", xml)
            ruta = validar_informes.buscar_informe(base)
            self.assertIsNotNone(ruta)
            datos = validar_informes.leer_informe(ruta)
            _, errores = validar_informes.comprobar(
                datos, minimo, carpetas if carpetas is not None else [])
            return not errores, errores

    def test_informe_valido(self) -> None:
        correcto, errores = self.comprobar(informe(10), minimo=10,
                                           carpetas=["res://tests/core"])
        self.assertTrue(correcto, errores)

    def test_informe_sin_pruebas(self) -> None:
        correcto, errores = self.comprobar(informe(0, suites=0))
        self.assertFalse(correcto)
        self.assertTrue(any("no se ejecuto ninguna prueba" in e for e in errores))

    def test_informe_bajo_el_suelo(self) -> None:
        correcto, errores = self.comprobar(informe(5), minimo=10)
        self.assertFalse(correcto)
        self.assertTrue(any("suelo" in e for e in errores))

    def test_informe_con_fallos(self) -> None:
        correcto, errores = self.comprobar(informe(10, fallos=1))
        self.assertFalse(correcto)
        self.assertTrue(any("fallos" in e for e in errores))

    def test_informe_con_omitidas(self) -> None:
        correcto, errores = self.comprobar(informe(10, omitidas=2))
        self.assertFalse(correcto)
        self.assertTrue(any("omitidas" in e for e in errores))

    def test_informe_con_errores_en_raiz(self) -> None:
        # XML real de GdUnit4 no escribe errors en la raiz; si aparece, cuenta.
        correcto, errores = self.comprobar(informe(10, errores_raiz=1))
        self.assertFalse(correcto)
        self.assertTrue(any("errores" in e for e in errores))

    def test_informe_con_errores_en_suite(self) -> None:
        correcto, errores = self.comprobar(informe(10, errores=2))
        self.assertFalse(correcto)
        self.assertTrue(any("errores" in e for e in errores))

    def test_informe_fallos_ocultos_en_suites(self) -> None:
        # La raiz dice 0 fallos pero una suite declara 1: informe truncado.
        correcto, errores = self.comprobar(
            informe(10, fallos=1, fallos_raiz=0))
        self.assertFalse(correcto)
        self.assertTrue(any("no cuadran" in e for e in errores))

    def test_informe_conteos_incoherentes(self) -> None:
        # La raiz declara 10 pero el XML solo trae 4 casos.
        correcto, errores = self.comprobar(informe(10, casos=4))
        self.assertFalse(correcto)
        self.assertTrue(any("no cuadran" in e for e in errores))

    def test_informe_carpeta_ausente(self) -> None:
        correcto, errores = self.comprobar(
            informe(10, paquete="tests/core"), carpetas=["res://tests/beta"])
        self.assertFalse(correcto)
        self.assertTrue(any("tests/beta" in e for e in errores))

    def test_busca_el_informe_mas_reciente(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            base = Path(temporal)
            escribir(base / "report_2" / "results.xml", informe(2))
            escribir(base / "report_10" / "results.xml", informe(3))
            ruta = validar_informes.buscar_informe(base)
            self.assertIsNotNone(ruta)
            self.assertEqual(ruta.parent.name, "report_10")

    def test_sin_informes(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            self.assertIsNone(validar_informes.buscar_informe(Path(temporal)))

    def test_carpetas_de_argumentos_gdunit(self) -> None:
        argumentos = "-a res://tests/core -a res://tests/entities -c"
        self.assertEqual(validar_informes.carpetas_de(argumentos),
                         ["res://tests/core", "res://tests/entities"])


class RegistroTest(unittest.TestCase):
    """El registro de la corrida: errores de parseo y de carga fuera del XML."""

    def test_registro_limpio(self) -> None:
        avisos, errores = validar_informes.revisar_registro(
            "Godot Engine v4.7.2\nOverall Summary: 39 test cases\n")
        self.assertEqual((avisos, errores), ([], []))

    def test_registro_detecta_error_de_parseo(self) -> None:
        _, errores = validar_informes.revisar_registro(
            "SCRIPT ERROR: Parse Error: falta un parentesis\n")
        self.assertEqual(len(errores), 1)
        self.assertIn("Parse Error", errores[0])

    def test_registro_detecta_parse_error_suelto(self) -> None:
        _, errores = validar_informes.revisar_registro(
            "Parse Error: Unexpected end of expression\n")
        self.assertEqual(len(errores), 1)

    def test_registro_detecta_carga_rota(self) -> None:
        _, errores = validar_informes.revisar_registro(
            "ERROR: No se pudo abrir 'res://tests/beta/music_test.gd'.\n")
        self.assertEqual(len(errores), 1)
        self.assertIn("res://tests/beta", errores[0])

    def test_registro_ignora_error_sin_ruta(self) -> None:
        # Ruido del motor sin res://: no es un fallo de descubrimiento.
        avisos, errores = validar_informes.revisar_registro(
            "ERROR: Condition '!E' is true.\n")
        self.assertEqual((avisos, errores), ([], []))

    def test_registro_avisa_user_error_sin_fallar(self) -> None:
        # push_error de codigo bajo prueba: visible, pero no invalida la run.
        avisos, errores = validar_informes.revisar_registro(
            "USER ERROR: ruta de navegacion vacia\n")
        self.assertEqual(errores, [])
        self.assertEqual(len(avisos), 1)

    def test_registro_avisa_push_error_capturado_por_gdunit(self) -> None:
        # Un test negativo provoca el push_error y GdUnit4 lo captura con
        # assert_push_error: es esperado, no un fallo de descubrimiento.
        registro = (
            "ERROR: res://data/zones/taller.json: el corredor hacia paso "
            "declara walls y facades a la vez\n"
            "   at: push_error (core/variant/variant_utility.cpp:1023)\n"
            "   GDScript backtrace (most recent call first):\n"
            "       [0] corridors (res://core/data/zone_definition.gd:155)\n"
            "       [1] <anonymous lambda> (res://tests/zones/"
            "corridor_facades_test.gd:153)\n"
            "       [2] _execute (res://addons/gdUnit4/src/asserts/"
            "GdUnitGodotErrorAssertImpl.gd:23)\n"
            "       [3] is_push_error (res://addons/gdUnit4/src/asserts/"
            "GdUnitGodotErrorAssertImpl.gd:139)\n"
            "       [4] test_corridor_with_walls_and_facades_is_a_clear_error\n"
        )
        avisos, errores = validar_informes.revisar_registro(registro)
        self.assertEqual(errores, [])
        self.assertEqual(len(avisos), 1)
        self.assertIn("assert_push_error", avisos[0])

    def test_registro_no_ignora_el_mismo_error_sin_backtrace(self) -> None:
        # Sin la captura de GdUnit4, el mismo mensaje sigue siendo fatal.
        _, errores = validar_informes.revisar_registro(
            "ERROR: res://data/zones/taller.json: el corredor hacia paso "
            "declara walls y facades a la vez\n"
            "   at: push_error (core/variant/variant_utility.cpp:1023)\n")
        self.assertEqual(len(errores), 1)
        self.assertIn("taller.json", errores[0])

    def test_registro_quita_colores_ansi(self) -> None:
        _, errores = validar_informes.revisar_registro(
            "\x1b[31mSCRIPT ERROR:\x1b[0m Parse Error: x\n")
        self.assertEqual(len(errores), 1)

    def test_registro_sin_duplicados(self) -> None:
        _, errores = validar_informes.revisar_registro(
            "SCRIPT ERROR: x\nSCRIPT ERROR: x\n")
        self.assertEqual(len(errores), 1)


class HumoTest(unittest.TestCase):
    def partida(self, cuerpo: dict | None = None,
                poblacion: dict | None = None,
                zona: str = "despliegue_cero") -> dict:
        return {
            "version": 3,
            "dead": False,
            "body": {"seed": 1234} if cuerpo is None else cuerpo,
            "world_zones": {
                "current": zona,
                "records": {zona: {
                    "zone_id": zona,
                    "visited": True,
                    "level_state": {"seed": 1234},
                    "world": {"npcs": []},
                    "population": {"mohocrata": 3} if poblacion is None
                    else poblacion,
                }},
            },
        }

    def test_partida_valida(self) -> None:
        buenas, errores = verificar_humo.validar_partida(
            self.partida(), "despliegue_cero")
        self.assertEqual(errores, [])
        self.assertTrue(any("poblacion" in linea for linea in buenas))

    def test_sin_jugador(self) -> None:
        _, errores = verificar_humo.validar_partida(
            self.partida(cuerpo={}), "despliegue_cero")
        self.assertTrue(any("protagonista" in e for e in errores))

    def test_sin_poblacion(self) -> None:
        _, errores = verificar_humo.validar_partida(
            self.partida(poblacion={}), "despliegue_cero")
        self.assertTrue(any("poblacion" in e for e in errores))

    def test_zona_incorrecta(self) -> None:
        _, errores = verificar_humo.validar_partida(self.partida(), "otra")
        self.assertTrue(any("zona actual" in e for e in errores))

    def test_sin_zona_montada(self) -> None:
        datos = {"version": 3, "dead": False, "body": {"seed": 1}}
        _, errores = verificar_humo.validar_partida(datos, "despliegue_cero")
        self.assertTrue(any("world_zones" in e for e in errores))

    def test_registro_sin_errores(self) -> None:
        texto = "Godot Engine v4.7.2.stable.official\nWARNING: benigno\n"
        buenas, errores = verificar_humo.revisar_registro(texto)
        self.assertEqual(errores, [])
        self.assertTrue(buenas)

    def test_registro_con_error(self) -> None:
        texto = ("Godot Engine v4.7.2.stable\n"
                 "ERROR: No se pudo cargar res://falta.tscn\n")
        _, errores = verificar_humo.revisar_registro(texto)
        self.assertEqual(len(errores), 1)
        self.assertIn("falta.tscn", errores[0])

    def test_registro_sin_motor(self) -> None:
        # En Linux el binario puede no emitir salida capturada; el registro
        # vacio ya no es un fallo duro (la partida.json es la prueba real).
        buenas, errores = verificar_humo.revisar_registro("")
        self.assertEqual(errores, [])
        self.assertTrue(any("AVISO" in b for b in buenas))

    def test_partida_exportada_se_lee_de_json(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            ruta = escribir(Path(temporal) / "partida.json",
                            json.dumps(self.partida()))
            _, errores = verificar_humo.validar_partida(
                json.loads(ruta.read_text(encoding="utf-8")), "despliegue_cero")
            self.assertEqual(errores, [])

    def guion_falso(self, escribir_partida: bool) -> list[str]:
        """Comando que imita al juego: escribe (o no) la partida en user://."""
        cuerpo = (
            "import json,os,pathlib,time\n"
            "print('Godot Engine v4.7.2.stable.falsa', flush=True)\n"
        )
        if escribir_partida:
            cuerpo += (
                "clave = 'APPDATA' if os.name == 'nt' else 'XDG_DATA_HOME'\n"
                "destino = (pathlib.Path(os.environ[clave]) / 'godot' / "
                "'app_userdata' / 'Bug de Familia')\n"
                "destino.mkdir(parents=True, exist_ok=True)\n"
                f"(destino / 'partida.json').write_text("
                f"{json.dumps(self.partida())!r}, encoding='utf-8')\n"
            )
        cuerpo += "time.sleep(30)\n"
        return [sys.executable, "-c", cuerpo]

    def test_lanzar_espera_la_partida(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            base = Path(temporal)
            buenas, errores = verificar_humo.lanzar(
                Path(sys.executable), base / "datos", base / "humo.log", 20,
                "despliegue_cero", comando=self.guion_falso(True))
            self.assertEqual(errores, [])
            self.assertTrue(any("poblacion" in linea for linea in buenas))

    def test_lanzar_falla_sin_partida(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            base = Path(temporal)
            _, errores = verificar_humo.lanzar(
                Path(sys.executable), base / "datos", base / "humo.log", 1,
                "despliegue_cero", comando=self.guion_falso(False))
            self.assertTrue(any("no llego a montarse" in e for e in errores))

    def test_poblacion_cero_falla(self) -> None:
        _, errores = verificar_humo.validar_partida(
            self.partida(poblacion={"gato": 0}), "despliegue_cero")
        self.assertTrue(any("suma 0" in e for e in errores))

    def test_poblacion_no_numerica_falla(self) -> None:
        _, errores = verificar_humo.validar_partida(
            self.partida(poblacion={"gato": "muchos"}), "despliegue_cero")
        self.assertTrue(any("no numericos" in e for e in errores))

    def test_version_no_numerica_falla(self) -> None:
        datos = self.partida()
        datos["version"] = "tres"
        _, errores = verificar_humo.validar_partida(datos, "despliegue_cero")
        self.assertTrue(any("version" in e for e in errores))

    def test_resuelve_binario_a_absoluto(self) -> None:
        resuelto = verificar_humo.resolver_binario(Path("build/bug.exe"))
        self.assertTrue(resuelto.is_absolute())
        self.assertEqual(resuelto, Path("build/bug.exe").resolve())

    def test_base_segura_rechaza_perfiles_reales(self) -> None:
        self.assertIsNotNone(verificar_humo.base_segura(Path.home()))
        self.assertIsNotNone(
            verificar_humo.base_segura(Path(Path.home().anchor)))
        if os.environ.get("APPDATA"):
            self.assertIsNotNone(
                verificar_humo.base_segura(Path(os.environ["APPDATA"])))
        with tempfile.TemporaryDirectory() as temporal:
            self.assertIsNone(verificar_humo.base_segura(Path(temporal)))

    def test_lanzar_rechaza_base_peligrosa(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            registro = Path(temporal) / "humo_falso.log"
            buenas, errores = verificar_humo.lanzar(
                Path(sys.executable), Path.home(), registro, 5,
                "despliegue_cero", comando=self.guion_falso(True))
            self.assertEqual(buenas, [])
            self.assertTrue(any("no se puede usar" in e for e in errores))

    def test_partida_exige_registro(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            partida = escribir(Path(temporal) / "partida.json",
                               json.dumps(self.partida()))
            argv = ["verificar_humo.py", "--partida", str(partida)]
            with unittest.mock.patch("sys.argv", argv):
                codigo = verificar_humo.main()
        self.assertEqual(codigo, 1)

    def test_partida_con_registro_inexistente_falla(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            partida = escribir(Path(temporal) / "partida.json",
                               json.dumps(self.partida()))
            argv = ["verificar_humo.py", "--partida", str(partida),
                    "--registro", str(Path(temporal) / "falta.log")]
            with unittest.mock.patch("sys.argv", argv):
                codigo = verificar_humo.main()
        self.assertEqual(codigo, 1)


class ConversacionesTest(unittest.TestCase):
    """validar_conversaciones: forma de una conversación de P-42."""

    def conversacion(self) -> dict:
        return {
            "id": "eco_000",
            "nodes": {
                "root": {
                    "text": "¿Sabes qué pasa aquí?",
                    "options": [
                        {"label": "Sí", "next": "n1"},
                        {"label": "No", "next": ""},
                    ],
                },
                "n1": {
                    "text": "Pasa que todo suena.",
                    "options": [
                        {"label": "Gracias", "next": "", "action": "praise"},
                    ],
                },
            },
        }

    def validar(self, conversacion: dict) -> list[str]:
        fallos: list[str] = []
        validar_conversaciones.validar_conversacion("live_eco.json", conversacion, fallos)
        return fallos

    def test_conversacion_correcta(self) -> None:
        self.assertEqual(self.validar(self.conversacion()), [])

    def test_next_inexistente(self) -> None:
        conversacion = self.conversacion()
        conversacion["nodes"]["root"]["options"][0]["next"] = "n99"
        fallos = self.validar(conversacion)
        self.assertTrue(any("n99" in fallo for fallo in fallos), fallos)

    def test_accion_desconocida(self) -> None:
        conversacion = self.conversacion()
        conversacion["nodes"]["n1"]["options"][0]["action"] = "explotar"
        fallos = self.validar(conversacion)
        self.assertTrue(any("explotar" in fallo for fallo in fallos), fallos)

    def test_texto_vacio(self) -> None:
        conversacion = self.conversacion()
        conversacion["nodes"]["n1"]["text"] = "   "
        fallos = self.validar(conversacion)
        self.assertTrue(any("texto vacío" in fallo for fallo in fallos), fallos)

    def test_nodo_inalcanzable(self) -> None:
        conversacion = self.conversacion()
        conversacion["nodes"]["suelto"] = {
            "text": "Nadie llega aquí.",
            "options": [{"label": "Vale", "next": ""}],
        }
        fallos = self.validar(conversacion)
        self.assertTrue(any("inalcanzables" in fallo for fallo in fallos), fallos)


class PobladoJsonTest(unittest.TestCase):
    """poblar_zonas.escribir_json: UTF-8 sin mojibake, LF y salto final."""

    def test_roundtrip_acentos_con_lf(self) -> None:
        with tempfile.TemporaryDirectory() as temporal:
            ruta = Path(temporal) / "zona.json"
            datos = {"nombre": "Señor Muñeca ±e", "lista": ["cañón", "ácido"]}
            poblar_zonas.escribir_json(str(ruta), datos)
            crudo = ruta.read_bytes()
            self.assertNotIn(b"\r\n", crudo)
            self.assertIn("ñ".encode("utf-8"), crudo)
            self.assertTrue(crudo.endswith(b"\n"))
            self.assertEqual(poblar_zonas.leer_json(str(ruta)), datos)


class DelimitadoresCorredorTest(unittest.TestCase):
    """validar_datos: muros (legacy) y fachadas de corredor (P-53)."""

    def comprobar(self, corredor: dict, rect: list[float] | None = None) -> list[str]:
        informe = validar_datos.Informe()
        validar_datos._comprobar_delimitadores(
            "data/zones/zona.json",
            "geometry.corridors[0]",
            corredor,
            rect if rect is not None else [100.0, 100.0, 240.0, 64.0],
            [0.0, 0.0, 4000.0, 4000.0],
            informe,
        )
        return informe.errores

    def test_fachadas_validas(self) -> None:
        self.assertEqual(self.comprobar({"facades": [[60.0, 100.0, 40.0, 400.0]]}), [])

    def test_muros_legacy_validos(self) -> None:
        self.assertEqual(self.comprobar({"walls": [[60.0, 100.0, 40.0, 400.0]]}), [])

    def test_sin_delimitadores(self) -> None:
        self.assertEqual(self.comprobar({}), [])

    def test_muros_y_fachadas_a_la_vez_es_error(self) -> None:
        errores = self.comprobar({
            "walls": [[60.0, 100.0, 40.0, 400.0]],
            "facades": [[400.0, 100.0, 40.0, 400.0]],
        })
        self.assertEqual(len(errores), 1)
        self.assertIn("walls y facades a la vez", errores[0])

    def test_fachada_que_invade_el_pasillo_es_error(self) -> None:
        errores = self.comprobar({"facades": [[120.0, 100.0, 40.0, 400.0]]})
        self.assertEqual(len(errores), 1)
        self.assertIn("invade el rect caminable", errores[0])

    def test_fachada_que_toca_el_borde_del_pasillo_es_valida(self) -> None:
        self.assertEqual(self.comprobar({"facades": [[60.0, 100.0, 40.0, 400.0]]}), [])

    def test_fachada_fuera_del_mundo_es_error(self) -> None:
        errores = self.comprobar({"facades": [[3990.0, 3800.0, 40.0, 400.0]]})
        self.assertEqual(len(errores), 1)
        self.assertIn("se sale de world_size", errores[0])

    def test_delimitador_mal_formado_es_error(self) -> None:
        errores = self.comprobar({"facades": "no soy una lista"})
        self.assertEqual(len(errores), 1)
        self.assertIn("se esperaba una lista de rectangulos", errores[0])
        errores = self.comprobar({"facades": [[10.0, 10.0, 0.0, 40.0]]})
        self.assertEqual(len(errores), 1)
        self.assertIn("ancho y alto deben ser positivos", errores[0])


if __name__ == "__main__":
    unittest.main()
