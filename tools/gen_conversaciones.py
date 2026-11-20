# -*- coding: utf-8 -*-
"""Genera lotes de conversaciones por raza en data/conversation/live_<especie>.json.
Se ejecuta una sola vez por lote; el director revisa el contenido resultante."""
import json, os, hashlib

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(RAIZ, "data", "conversation")

SPECIES = ["jubilado", "mohocrata", "plegado", "eco", "grux", "manada"]

GREET = {
 "jubilado": "Siéntate, que tengo tiempo y tú no.",
 "mohocrata": "Bienvenido al censo. ¿Traes papeles?",
 "plegado": "No hables alto. Las paredes escuchan.",
 "eco": "Hola. ¿Oyes eso? Es tu propia voz rebotando.",
 "grux": "Grrr... ¿qué quieres, carne?",
 "manada": "El grupo nos dice que hablemos. ¿Qué traes?",
}

def conv(sid, species, idx):
    c = {
      "id": "%s_%03d" % (species[:4], idx),
      "greeting": GREET[species],
      "nodes": {}
    }
    # Tipo 1: pregunta corta
    if idx % 6 == 0:
        c["nodes"]["root"] = {"text": "¿Sabes qué hora es?", "options": [
            {"label": "No", "next": "r1"},
            {"label": "Sí", "next": "r2"}]}
        c["nodes"]["r1"] = {"text": "Pues yo tampoco. El reloj se rompió en el Apocalipsis.", "options": [{"label": "Volver", "next": ""}]}
        c["nodes"]["r2"] = {"text": "Mentira. Nadie sabe. Pero gracias por intentar.", "options": [{"label": "De nada", "next": "", "action": "praise"}]}
    # Tipo 2: 3-4 preguntas
    elif idx % 6 == 1:
        c["nodes"]["root"] = {"text": "¿Quieres que te cuente algo del Apocalipsis?", "options": [
            {"label": "Sí", "next": "a1"},
            {"label": "No", "next": "a2"}]}
        c["nodes"]["a1"] = {"text": "Había mucha luz y mucho ruido. Y luego silencio.", "options": [{"label": "¿Y después?", "next": "a3"}]}
        c["nodes"]["a2"] = {"text": "Pues bien. Tú te lo pierdes.", "options": [{"label": "Volver", "next": ""}]}
        c["nodes"]["a3"] = {"text": "Después vinimos nosotros. Y aquí seguimos.", "options": [
            {"label": "Gracias", "next": "", "action": "praise"},
            {"label": "Qué rollo", "next": "", "action": "insult"}]}
    # Tipo 3: ramificación con regalo
    elif idx % 6 == 2:
        c["nodes"]["root"] = {"text": "Tengo una pieza de repuesto. ¿La quieres?", "options": [
            {"label": "Sí", "next": "g1"},
            {"label": "No", "next": "g2"}]}
        c["nodes"]["g1"] = {"text": "Toma. No la pierdas.", "options": [{"label": "Gracias", "next": "", "action": "gift_piece"}]}
        c["nodes"]["g2"] = {"text": "Pues la guardo. Más para mí.", "options": [{"label": "Volver", "next": ""}]}
    # Tipo 4: ramificación con golpe
    elif idx % 6 == 3:
        c["nodes"]["root"] = {"text": "¿Te atreves a decirme que soy viejo?", "options": [
            {"label": "Sí", "next": "h1"},
            {"label": "No", "next": "h2"}]}
        c["nodes"]["h1"] = {"text": "Pues toma.", "options": [{"label": "Ay", "next": "", "action": "hit"}]}
        c["nodes"]["h2"] = {"text": "Sabia decisión.", "options": [{"label": "Volver", "next": "", "action": "praise"}]}
    # Tipo 5: provocar batalla
    elif idx % 6 == 4:
        c["nodes"]["root"] = {"text": "¿Qué opinas de los %s?" % SPECIES[SPECIES.index(species) - 1], "options": [
            {"label": "Son basura", "next": "b1"},
            {"label": "Son majos", "next": "b2"}]}
        c["nodes"]["b1"] = {"text": "Exacto. Y ahora que lo dices...", "options": [{"label": "Oh no", "next": "", "action": "provoke_battle"}]}
        c["nodes"]["b2"] = {"text": "Majos no, pero útiles. Vete.", "options": [{"label": "Vale", "next": ""}]}
    # Tipo 6: lore
    else:
        c["nodes"]["root"] = {"text": "¿Sabes por qué el cielo es gris?", "options": [
            {"label": "No", "next": "l1"},
            {"label": "Sí", "next": "l2"}]}
        c["nodes"]["l1"] = {"text": "Porque el Apocalipsis pintó todo de gris. Literal.", "options": [{"label": "Jaja", "next": "", "action": "praise"}]}
        c["nodes"]["l2"] = {"text": "Mentira. El cielo siempre fue gris. El Apocalipsis solo lo dejó ver.", "options": [{"label": "Volver", "next": ""}]}
    return c


def main():
    os.makedirs(OUT, exist_ok=True)
    for species in SPECIES:
        convs = [conv(i, species, i) for i in range(12)]
        data = {"species": species, "conversations": convs}
        path = os.path.join(OUT, "live_%s.json" % species)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
        print("wrote", path, len(convs))

if __name__ == "__main__":
    main()
