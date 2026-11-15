class_name DialogueTrees
extends RefCounted
## Árboles de diálogo ramificados por raza. Entrega pequeña: 3-5 nodos por raza.

static func tree_for(species: String) -> Dictionary:
	match species:
		"jubilado":
			return {
				"root": {"text": "¿Qué quieres, mozo?", "options": [
					{"label": "¿Qué haces aquí?", "next": "job"},
					{"label": "¿Algo interesante?", "next": "rumor"},
					{"label": "Adiós", "next": ""},
				]},
				"job": {"text": "Juego a la petanca con minas. Es lo que hay.", "options": [
					{"label": "¿Petanca con minas?", "next": "job2"},
					{"label": "Volver", "next": "root"},
				]},
				"job2": {"text": "Sí, es peligroso pero divertido. ¿Quieres una pieza de repuesto?", "options": [
					{"label": "Sí, gracias", "next": "", "action": "gift_piece"},
					{"label": "No, gracias", "next": "root"},
				]},
				"rumor": {"text": "Los mohócratas han votado algo raro otra vez.", "options": [
					{"label": "¿Qué votaron?", "next": "rumor2"},
					{"label": "Volver", "next": "root"},
				]},
				"rumor2": {"text": "No sé, pero huele a moho. ¡Ja!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué asco", "next": "", "action": "insult"},
				]},
			}
		"mohocrata":
			return {
				"root": {"text": "La asamblea ha decidido que hables conmigo.", "options": [
					{"label": "¿Qué ha decidido?", "next": "vote"},
					{"label": "¿Alguna queja?", "next": "complaint"},
					{"label": "Adiós", "next": ""},
				]},
				"vote": {"text": "Hemos votado por unanimidad que el aire es nuestro.", "options": [
					{"label": "¿El aire?", "next": "vote2"},
					{"label": "Volver", "next": "root"},
				]},
				"vote2": {"text": "Sí, el aire. Los grux no pagan tributo. ¡Es un escándalo!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"complaint": {"text": "Los plegados clasifican nuestras esporas. ¡Es una ofensa!", "options": [
					{"label": "¿Esporas?", "next": "complaint2"},
					{"label": "Volver", "next": "root"},
				]},
				"complaint2": {"text": "Sí, las clasifican por color. ¡Nosotros no somos colores!", "options": [
					{"label": "Qué injusto", "next": "root", "action": "praise"},
					{"label": "Me parece bien", "next": "", "action": "hit"},
				]},
			}
		"plegado":
			return {
				"root": {"text": "¿En qué categoría te sitúo?", "options": [
					{"label": "¿Categoría?", "next": "cat"},
					{"label": "¿Algo interesante?", "next": "news"},
					{"label": "Adiós", "next": ""},
				]},
				"cat": {"text": "Todo debe tener una categoría. Tú eres... 'individuo sin pliegue'.", "options": [
					{"label": "¿Sin pliegue?", "next": "cat2"},
					{"label": "Volver", "next": "root"},
				]},
				"cat2": {"text": "Sí, no te puedes doblar. Es una limitación. ¿Quieres una pieza?", "options": [
					{"label": "Sí", "next": "", "action": "gift_piece"},
					{"label": "No", "next": "root"},
				]},
				"news": {"text": "Los ecos han grabado un acta sobre nosotros. De nuevo.", "options": [
					{"label": "¿Qué dice?", "next": "news2"},
					{"label": "Volver", "next": "root"},
				]},
				"news2": {"text": "Que somos 'plegados de tercera categoría'. ¡Indignante!", "options": [
					{"label": "Indignante", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
			}
		"eco":
			return {
				"root": {"text": "Eco... eco... ¿qué quieres?", "options": [
					{"label": "¿Qué eres?", "next": "what"},
					{"label": "¿Alguna noticia?", "next": "news"},
					{"label": "Adiós", "next": ""},
				]},
				"what": {"text": "Soy un eco. Repito lo que otros dicen. Pero con estilo.", "options": [
					{"label": "¿Con estilo?", "next": "what2"},
					{"label": "Volver", "next": "root"},
				]},
				"what2": {"text": "Sí, añado resonancia. ¿Quieres que repita algo?", "options": [
					{"label": "Sí", "next": "root", "action": "praise"},
					{"label": "No", "next": "", "action": "insult"},
				]},
				"news": {"text": "Los grux han dicho algo sobre el aire. Lo repito: 'el aire es nuestro'.", "options": [
					{"label": "¿Los grux?", "next": "news2"},
					{"label": "Volver", "next": "root"},
				]},
				"news2": {"text": "Sí, flotan y se creen dueños del viento. ¡Qué eco!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
			}
		"grux":
			return {
				"root": {"text": "¿Qué quieres, ser de abajo?", "options": [
					{"label": "¿Ser de abajo?", "next": "below"},
					{"label": "¿Algo interesante?", "next": "news"},
					{"label": "Adiós", "next": ""},
				]},
				"below": {"text": "Sí, tú caminas por el suelo. Nosotros flotamos. Es mejor.", "options": [
					{"label": "¿Mejor?", "next": "below2"},
					{"label": "Volver", "next": "root"},
				]},
				"below2": {"text": "Sí, el aire es nuestro. ¿Quieres una pieza voladora?", "options": [
					{"label": "Sí", "next": "", "action": "gift_piece"},
					{"label": "No", "next": "root"},
				]},
				"news": {"text": "Los mohócratas quieren cobrar tributo por el aire. ¡Ridículo!", "options": [
					{"label": "¿Tributo?", "next": "news2"},
					{"label": "Volver", "next": "root"},
				]},
				"news2": {"text": "Sí, quieren cobrar por respirar. ¡El aire es de todos!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
			}
		"manada":
			return {
				"root": {"text": "Solo vamos a la derecha. ¿Vienes?", "options": [
					{"label": "¿Solo a la derecha?", "next": "right"},
					{"label": "¿Algo interesante?", "next": "news"},
					{"label": "Adiós", "next": ""},
				]},
				"right": {"text": "Sí, no hay marcha atrás. Siempre adelante.", "options": [
					{"label": "¿Por qué?", "next": "right2"},
					{"label": "Volver", "next": "root"},
				]},
				"right2": {"text": "Porque así lo manda la ruta eterna. ¿Quieres una pieza?", "options": [
					{"label": "Sí", "next": "", "action": "gift_piece"},
					{"label": "No", "next": "root"},
				]},
				"news": {"text": "Los jubilados juegan con minas. Es peligroso.", "options": [
					{"label": "¿Minas?", "next": "news2"},
					{"label": "Volver", "next": "root"},
				]},
				"news2": {"text": "Sí, petanca con minas. Solo a la derecha, lejos de ellos.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué peligro", "next": "", "action": "insult"},
				]},
			}
		_:
			return {}
