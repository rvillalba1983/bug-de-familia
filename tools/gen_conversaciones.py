# -*- coding: utf-8 -*-
"""Genera las conversaciones de P-42 en data/conversation/live_<especie>.json.

Cada especie tiene un banco en tools/conversaciones/<especie>.py con 15 temas y
10 aperturas. De cada tema salen 10 conversaciones de estructuras distintas (pregunta
suelta, cadenas de 3 y 4 pasos, bifurcación, regalo de pieza, enfado con pelea contra
el protagonista y enfado con pelea entre razas), así que cada especie queda con 150.

Uso:
	python tools/gen_conversaciones.py              # escribe los seis JSON
	python tools/gen_conversaciones.py --validar    # solo comprueba los bancos
	python tools/gen_conversaciones.py --especie eco
"""
import importlib.util
import json
import os
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANCOS = os.path.join(RAIZ, "tools", "conversaciones")
OUT = os.path.join(RAIZ, "data", "conversation")

SPECIES = ["jubilado", "mohocrata", "plegado", "eco", "grux", "manada"]
VARIANTES = 10
TEMAS = 15
LARGO_MAXIMO = 160


def cargar_banco(especie):
	ruta = os.path.join(BANCOS, "%s.py" % especie)
	if not os.path.isfile(ruta):
		raise SystemExit("falta el banco %s" % ruta)
	spec = importlib.util.spec_from_file_location("banco_%s" % especie, ruta)
	modulo = importlib.util.module_from_spec(spec)
	spec.loader.exec_module(modulo)
	return modulo


def validar_banco(especie, banco):
	"""Devuelve la lista de problemas del banco. Vacía si todo está bien."""
	fallos = []
	if banco.SPECIES != especie:
		fallos.append("SPECIES es %r y debería ser %r" % (banco.SPECIES, especie))
	if not isinstance(banco.GREETING, str) or not banco.GREETING.strip():
		fallos.append("GREETING vacío")
	aberturas = getattr(banco, "OPENERS", [])
	if not isinstance(aberturas, list) or len(aberturas) != VARIANTES:
		fallos.append("OPENERS debe tener %d líneas" % VARIANTES)
	temas = getattr(banco, "TOPICS", [])
	if not isinstance(temas, list) or len(temas) != TEMAS:
		fallos.append("TOPICS debe tener %d temas" % TEMAS)
	claves_lista = {"ask": 3, "fact": 3, "payoff": 2, "deflect": 2}
	claves_texto = ["hot", "offer", "gift", "battle", "praise"]
	vistos = set()
	for indice, tema in enumerate(temas):
		if not isinstance(tema, dict):
			fallos.append("el tema %d no es un diccionario" % indice)
			continue
		for clave, cuantas in claves_lista.items():
			lineas = tema.get(clave)
			if not isinstance(lineas, list) or len(lineas) != cuantas:
				fallos.append("el tema %d necesita %s con %d líneas" % (indice, clave, cuantas))
				continue
			for linea in lineas:
				fallos.append(_revisar_texto(indice, clave, linea, vistos))
		for clave in claves_texto:
			fallos.append(_revisar_texto(indice, clave, tema.get(clave), vistos))
	for linea in aberturas:
		fallos.append(_revisar_texto(-1, "OPENERS", linea, vistos))
	if len(set(aberturas)) != len(aberturas):
		fallos.append("OPENERS tiene líneas repetidas")
	return [fallo for fallo in fallos if fallo]


def _revisar_texto(indice, clave, linea, vistos):
	donde = "tema %d, %s" % (indice, clave) if indice >= 0 else clave
	if not isinstance(linea, str):
		return "%s: no es texto (%r)" % (donde, linea)
	if not linea.strip():
		return "%s: línea vacía" % donde
	if len(linea) > LARGO_MAXIMO:
		return "%s: %d caracteres (máximo %d): %s" % (donde, len(linea), LARGO_MAXIMO, linea)
	if linea != linea.strip():
		return "%s: espacios al principio o al final: %r" % (donde, linea)
	if "  " in linea:
		return "%s: espacios dobles: %r" % (donde, linea)
	if "\n" in linea or "\t" in linea:
		return "%s: salto de línea o tabulador" % donde
	if clave != "OPENERS":
		if linea in vistos:
			return "%s: repetida: %s" % (donde, linea)
		vistos.add(linea)
	return ""


def opcion(etiqueta, siguiente="", accion=""):
	opt = {"label": etiqueta, "next": siguiente}
	if accion:
		opt["action"] = accion
	return opt


def nodo(texto, *opciones):
	return {"text": texto, "options": list(opciones)}


def construir(tema, variante, abertura):
	"""Devuelve los nodos de la conversación del tema y la variante dados."""
	pedir = tema["ask"]
	dato = tema["fact"]
	provecho = tema["payoff"]
	esquiva = tema["deflect"]
	asunto = "%s %s" % (abertura, pedir[variante % len(pedir)])
	nodos = {}
	if variante == 0:
		# Pregunta suelta con una respuesta que lleva a información interesante.
		nodos["root"] = nodo(asunto, opcion("Sí", "n1"), opcion("No", "n2"))
		nodos["n1"] = nodo(dato[0], opcion("¿Y luego?", "n3"))
		nodos["n3"] = nodo(provecho[0], opcion("Gracias", "", "praise"))
		nodos["n2"] = nodo(esquiva[0], opcion("Vale"))
	elif variante == 1:
		# Tres preguntas con final que se puede agradecer o despreciar.
		nodos["root"] = nodo(asunto, opcion("Cuéntame", "n1"), opcion("No me interesa", "n3"))
		nodos["n1"] = nodo(dato[1], opcion("Sigue", "n2"))
		nodos["n2"] = nodo(provecho[1],
			opcion("Gracias", "", "praise"), opcion("Qué aburrido", "", "insult"))
		nodos["n3"] = nodo(esquiva[1], opcion("Vale"))
	elif variante == 2:
		# Cadena de cuatro pasos que acaba en el dato bueno.
		nodos["root"] = nodo(asunto, opcion("Vamos allá", "n1"), opcion("Ahora no", "n4"))
		nodos["n1"] = nodo(dato[2], opcion("¿Y eso?", "n2"))
		nodos["n2"] = nodo(dato[0], opcion("¿Siempre?", "n3"))
		nodos["n3"] = nodo(provecho[0], opcion("Gracias", "", "praise"))
		nodos["n4"] = nodo(esquiva[0], opcion("Vale"))
	elif variante == 3:
		# Regalo de pieza: la pieza se entrega con la acción gift_piece.
		nodos["root"] = nodo(tema["offer"], opcion("Sí", "n1"), opcion("No", "n2"))
		nodos["n1"] = nodo(tema["gift"], opcion("Gracias", "", "gift_piece"))
		nodos["n2"] = nodo(esquiva[1], opcion("Vale"))
	elif variante == 4:
		# Enfado que termina en pelea con el protagonista.
		nodos["root"] = nodo(tema["hot"],
			opcion("Sí, y lo repito", "n1"), opcion("No, era broma", "n2"))
		nodos["n1"] = nodo(dato[1], opcion("Pues ya está", "", "hit"))
		nodos["n2"] = nodo(tema["praise"], opcion("Vale"))
	elif variante == 5:
		# Enfado que termina en pelea entre razas.
		nodos["root"] = nodo("%s %s" % (abertura, tema["battle"]),
			opcion("Tienes razón", "n1"), opcion("Déjalos en paz", "n2"))
		nodos["n1"] = nodo(dato[0], opcion("Que empiece", "", "provoke_battle"))
		nodos["n2"] = nodo(esquiva[0], opcion("Vale"))
	elif variante == 6:
		# Pregunta suelta con una tercera opción impertinente.
		nodos["root"] = nodo(asunto,
			opcion("Sí", "n1"), opcion("No", "n2"), opcion("Vaya pregunta", "n3"))
		nodos["n1"] = nodo(provecho[1], opcion("Gracias", "", "praise"))
		nodos["n2"] = nodo(esquiva[1], opcion("Vale"))
		nodos["n3"] = nodo(tema["hot"], opcion("Y lo mantengo", "", "insult"))
	elif variante == 7:
		# Bifurcación: dos caminos con reacción distinta.
		nodos["root"] = nodo(asunto,
			opcion("Por el principio", "n1"), opcion("Por el final", "n2"))
		nodos["n1"] = nodo(dato[0], opcion("Interesante", "", "praise"))
		nodos["n2"] = nodo(provecho[0], opcion("Qué tontería", "", "insult"))
	elif variante == 8:
		# Cadena de cuatro pasos que termina regalando una pieza.
		nodos["root"] = nodo(asunto, opcion("Cuenta", "n1"), opcion("Otro día", "n4"))
		nodos["n1"] = nodo(dato[1], opcion("Sigue", "n2"))
		nodos["n2"] = nodo(provecho[0], opcion("¿Y qué gano?", "n3"))
		nodos["n3"] = nodo(tema["offer"], opcion("Gracias", "", "gift_piece"))
		nodos["n4"] = nodo(esquiva[0], opcion("Vale"))
	else:
		# Cadena que termina en pelea entre razas.
		nodos["root"] = nodo("%s %s" % (abertura, tema["battle"]),
			opcion("Claro que sí", "n1"), opcion("Ni hablar", "n2"))
		nodos["n1"] = nodo(dato[2], opcion("¿Y los demás?", "n3"))
		nodos["n3"] = nodo(provecho[1], opcion("Que empiece", "", "provoke_battle"))
		nodos["n2"] = nodo(esquiva[1], opcion("Vale"))
	return nodos


def generar(especie, banco):
	conversaciones = []
	prefijo = especie[:4]
	for indice_tema, tema in enumerate(banco.TOPICS):
		for variante in range(VARIANTES):
			numero = indice_tema * VARIANTES + variante
			conversaciones.append({
				"id": "%s_%03d" % (prefijo, numero),
				"greeting": banco.GREETING,
				"nodes": construir(tema, variante, banco.OPENERS[variante]),
			})
	return {"species": especie, "conversations": conversaciones}


def main() -> int:
	solo_validar = "--validar" in sys.argv
	especies = SPECIES
	if "--especie" in sys.argv:
		especies = [sys.argv[sys.argv.index("--especie") + 1]]
		os.makedirs(OUT, exist_ok=True)
	fallos = {}
	bancos = {}
	for especie in especies:
		banco = cargar_banco(especie)
		bancos[especie] = banco
		problemas = validar_banco(especie, banco)
		if problemas:
			fallos[especie] = problemas
	if fallos:
		for especie, problemas in fallos.items():
			for problema in problemas:
				print("ERROR %s: %s" % (especie, problema))
		print("Bancos con errores: %s" % ", ".join(sorted(fallos)))
		return 1
	print("Bancos válidos: %s" % ", ".join(especies))
	if solo_validar:
		return 0
	for especie in especies:
		datos = generar(especie, bancos[especie])
		ruta = os.path.join(OUT, "live_%s.json" % especie)
		with open(ruta, "w", encoding="utf-8", newline="\n") as mano:
			json.dump(datos, mano, ensure_ascii=False, indent=2)
			mano.write("\n")
		print("escrito %s (%d conversaciones)" % (ruta, len(datos["conversations"])))
	return 0


if __name__ == "__main__":
	sys.exit(main())
