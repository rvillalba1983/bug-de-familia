class_name DialogueTrees
extends RefCounted
## Árboles de diálogo ramificados por raza. Entrega ampliada: 8-10 nodos por raza.

static func tree_for(species: String) -> Dictionary:
	match species:
		"jubilado":
			return {
				"root": {"text": "¿Qué quieres, mozo?", "options": [
					{"label": "¿Qué haces aquí?", "next": "job"},
					{"label": "¿Algo interesante?", "next": "rumor"},
					{"label": "¿Cómo va la petanca?", "next": "petanca"},
					{"label": "Adiós", "next": ""},
				]},
				"job": {"text": "Juego a la petanca con minas. Es lo que hay.", "options": [
					{"label": "¿Petanca con minas?", "next": "job2"},
					{"label": "¿No es peligroso?", "next": "job3"},
					
				]},
				"job2": {"text": "Sí, es peligroso pero divertido. ¿Quieres una pieza de repuesto?", "options": [
					{"label": "Sí, gracias", "next": "", "action": "gift_piece"},
					{"label": "No, gracias", "next": "root"},
				]},
				"job3": {"text": "Peligroso sí, pero los jubilados somos duros. ¿Te atreves?", "options": [
					{"label": "Sí", "next": "job4"},
					{"label": "No", "next": "root"},
				]},
				"job4": {"text": "Entonces toma esta pieza. Y cuidado con las minas.", "options": [
					{"label": "Gracias", "next": "", "action": "gift_piece"},
				]},
				"petanca": {"text": "La petanca va bien. Pero los grux flotan y no respetan las reglas.", "options": [
					{"label": "¿Los grux?", "next": "petanca2"},
					
				]},
				"petanca2": {"text": "Sí, flotan sobre el campo y dicen que el aire es suyo. ¡Ridículo!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"rumor": {"text": "Los mohócratas han votado algo raro otra vez.", "options": [
					{"label": "¿Qué votaron?", "next": "rumor2"},
					{"label": "¿Siempre votan?", "next": "rumor3"},
					
				]},
				"rumor2": {"text": "No sé, pero huele a moho. ¡Ja!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué asco", "next": "", "action": "insult"},
				]},
				"rumor3": {"text": "Siempre. Votan hasta para respirar. ¡Los grux se quejan!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
			}
		"mohocrata":
			return {
				"root": {"text": "La asamblea ha decidido que hables conmigo.", "options": [
					{"label": "¿Qué ha decidido?", "next": "vote"},
					{"label": "¿Alguna queja?", "next": "complaint"},
					{"label": "¿Votáis mucho?", "next": "vote3"},
					{"label": "Adiós", "next": ""},
				]},
				"vote": {"text": "Hemos votado por unanimidad que el aire es nuestro.", "options": [
					{"label": "¿El aire?", "next": "vote2"},
					
				]},
				"vote2": {"text": "Sí, el aire. Los grux no pagan tributo. ¡Es un escándalo!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"vote3": {"text": "Votamos para todo. Incluso para votar. Es democracia.", "options": [
					{"label": "¿Para todo?", "next": "vote4"},
					
				]},
				"vote4": {"text": "Sí. La última votación fue sobre si votar es divertido. Ganó el sí.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"complaint": {"text": "Los plegados clasifican nuestras esporas. ¡Es una ofensa!", "options": [
					{"label": "¿Esporas?", "next": "complaint2"},
					
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
					{"label": "¿Qué clasificas?", "next": "classify"},
					{"label": "Adiós", "next": ""},
				]},
				"cat": {"text": "Todo debe tener una categoría. Tú eres... 'individuo sin pliegue'.", "options": [
					{"label": "¿Sin pliegue?", "next": "cat2"},
					
				]},
				"cat2": {"text": "Sí, no te puedes doblar. Es una limitación. ¿Quieres una pieza?", "options": [
					{"label": "Sí", "next": "", "action": "gift_piece"},
					{"label": "No", "next": "root"},
				]},
				"classify": {"text": "Clasificamos todo. Incluso las quejas. Las esporas de los mohócratas están en 'hongos molestos'.", "options": [
					{"label": "¿Hongos molestos?", "next": "classify2"},
					
				]},
				"classify2": {"text": "Sí. Y los grux están en 'seres que flotan sin permiso'.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué ofensa", "next": "", "action": "insult"},
				]},
				"news": {"text": "Los ecos han grabado un acta sobre nosotros. De nuevo.", "options": [
					{"label": "¿Qué dice?", "next": "news2"},
					
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
					{"label": "¿Qué repites?", "next": "repeat"},
					{"label": "Adiós", "next": ""},
				]},
				"what": {"text": "Soy un eco. Repito lo que otros dicen. Pero con estilo.", "options": [
					{"label": "¿Con estilo?", "next": "what2"},
					
				]},
				"what2": {"text": "Sí, añado resonancia. ¿Quieres que repita algo?", "options": [
					{"label": "Sí", "next": "root", "action": "praise"},
					{"label": "No", "next": "", "action": "insult"},
				]},
				"repeat": {"text": "Repito todo. La última cosa que repetí fue 'el aire es nuestro'.", "options": [
					{"label": "¿De quién?", "next": "repeat2"},
					
				]},
				"repeat2": {"text": "De los grux. Lo repiten mucho. Y yo lo amplifico.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"news": {"text": "Los grux han dicho algo sobre el aire. Lo repito: 'el aire es nuestro'.", "options": [
					{"label": "¿Los grux?", "next": "news2"},
					
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
					{"label": "¿Por qué flotáis?", "next": "float"},
					{"label": "Adiós", "next": ""},
				]},
				"below": {"text": "Sí, tú caminas por el suelo. Nosotros flotamos. Es mejor.", "options": [
					{"label": "¿Mejor?", "next": "below2"},
					
				]},
				"below2": {"text": "Sí, el aire es nuestro. ¿Quieres una pieza voladora?", "options": [
					{"label": "Sí", "next": "", "action": "gift_piece"},
					{"label": "No", "next": "root"},
				]},
				"float": {"text": "Flotamos porque el aire nos sostiene. Es nuestro derecho.", "options": [
					{"label": "¿Derecho?", "next": "float2"},
					
				]},
				"float2": {"text": "Sí. Los mohócratas quieren cobrar por respirar. ¡Ridículo!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"news": {"text": "Los mohócratas quieren cobrar tributo por el aire. ¡Ridículo!", "options": [
					{"label": "¿Tributo?", "next": "news2"},
					
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
					{"label": "¿Por qué solo a la derecha?", "next": "why"},
					{"label": "Adiós", "next": ""},
				]},
				"right": {"text": "Sí, no hay marcha atrás. Siempre adelante.", "options": [
					{"label": "¿Por qué?", "next": "right2"},
					
				]},
				"right2": {"text": "Porque así lo manda la ruta eterna. ¿Quieres una pieza?", "options": [
					{"label": "Sí", "next": "", "action": "gift_piece"},
					{"label": "No", "next": "root"},
				]},
				"why": {"text": "Porque la ruta eterna va hacia adelante. No hay vuelta atrás.", "options": [
					{"label": "¿Y si hay peligro?", "next": "why2"},
					
				]},
				"why2": {"text": "Entonces vamos más rápido. ¿Quieres venir?", "options": [
					{"label": "Sí", "next": "root", "action": "praise"},
					{"label": "No", "next": "", "action": "insult"},
				]},
				"news": {"text": "Los jubilados juegan con minas. Es peligroso.", "options": [
					{"label": "¿Minas?", "next": "news2"},
					
				]},
				"news2": {"text": "Sí, petanca con minas. Solo a la derecha, lejos de ellos.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué peligro", "next": "", "action": "insult"},
				]},
			}
		_:
			return {}
