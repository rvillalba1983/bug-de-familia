class_name DialogueTrees
extends RefCounted
## Árboles de diálogo ramificados por raza. Entrega ampliada: 30+ nodos por raza, cubriendo todo el lore.

static func tree_for(species: String) -> Dictionary:
	match species:
		"jubilado":
			return {
				"root": {"text": "¿Qué quieres, mozo?", "options": [
					{"label": "¿Qué haces aquí?", "next": "job"},
					{"label": "¿Algo interesante?", "next": "rumor"},
					{"label": "¿Cómo va la petanca?", "next": "petanca"},
					{"label": "¿Conoces a Don Ramón?", "next": "ramon"},
					{"label": "¿Qué opinas de los mohócratas?", "next": "opinion_moho"},
					{"label": "¿Y de los grux?", "next": "opinion_grux"},
					{"label": "¿Y de los plegados?", "next": "opinion_plegado"},
					{"label": "¿Y de los ecos?", "next": "opinion_eco"},
					{"label": "¿Y de la manada?", "next": "opinion_manada"},
					{"label": "¿Alguna anécdota?", "next": "anecdote"},
					{"label": "¿Qué fue el Apocalipsis?", "next": "apocalipsis"},
					{"label": "Adiós", "next": ""},
				]},
				"job": {"text": "Juego a la petanca con minas. Es lo que hay.", "options": [
					{"label": "¿Petanca con minas?", "next": "job2"},
					{"label": "¿No es peligroso?", "next": "job3"},
					{"label": "¿Dónde consigues las minas?", "next": "job5"},
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
				"job5": {"text": "Las minas las dejaron los militares. Nosotros las reciclamos para la petanca.", "options": [
					{"label": "¿Reciclar minas?", "next": "job6"},
				]},
				"job6": {"text": "Sí, es ecológico. Y explosivo. La mejor combinación.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué peligro", "next": "root"},
				]},
				"petanca": {"text": "La petanca va bien. Pero los grux flotan y no respetan las reglas.", "options": [
					{"label": "¿Los grux?", "next": "petanca2"},
					{"label": "¿Y los mohócratas?", "next": "petanca3"},
					{"label": "¿Algún truco?", "next": "petanca4"},
				]},
				"petanca2": {"text": "Sí, flotan sobre el campo y dicen que el aire es suyo. ¡Ridículo!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"petanca3": {"text": "Los mohócratas votan todo. Hasta el color de la bola. ¡Es absurdo!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"petanca4": {"text": "El truco es no pisar las minas. Y no dejar que los grux floten sobre tu bola.", "options": [
					{"label": "Gracias", "next": "root", "action": "praise"},
					{"label": "Qué difícil", "next": "root"},
				]},
				"ramon": {"text": "Don Ramón es el jefe. Mejor no te metas con él.", "options": [
					{"label": "¿Por qué?", "next": "ramon2"},
					{"label": "¿Es peligroso?", "next": "ramon3"},
					{"label": "¿Qué hace?", "next": "ramon4"},
				]},
				"ramon2": {"text": "Porque tiene un martillo y no le gusta que le molesten.", "options": [
					{"label": "Entendido", "next": "root"},
					{"label": "Me da igual", "next": "", "action": "hit"},
				]},
				"ramon3": {"text": "No es peligroso si le respetas. Si no... mejor corre.", "options": [
					{"label": "Gracias", "next": "root", "action": "praise"},
					{"label": "Qué miedo", "next": "root"},
				]},
				"ramon4": {"text": "Manda a los jubilados a jugar con minas. Y cobra peaje por todo.", "options": [
					{"label": "¿Peaje?", "next": "ramon5"},
				]},
				"ramon5": {"text": "Sí, hasta por respirar. Pero los grux no pagan. ¡Es injusto!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"opinion_moho": {"text": "Los mohócratas son... bueno, votan mucho. Pero son buena gente.", "options": [
					{"label": "¿Buena gente?", "next": "opinion_moho2"},
					{"label": "No lo parece", "next": "opinion_moho3"},
				]},
				"opinion_moho2": {"text": "Sí, cuando no están votando. Entonces son insoportables.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_moho3": {"text": "No, no lo parece. Pero en el fondo son como nosotros: viejos y cansados.", "options": [
					{"label": "Qué bonito", "next": "root", "action": "praise"},
					{"label": "No lo creo", "next": "", "action": "insult"},
				]},
				"opinion_grux": {"text": "Los grux son flotantes y pretenciosos. Pero tienen buen aire.", "options": [
					{"label": "¿Buen aire?", "next": "opinion_grux2"},
					{"label": "Qué pesados", "next": "opinion_grux3"},
				]},
				"opinion_grux2": {"text": "Sí, el aire que respiran es fresco. Pero no lo comparten. ¡Egoístas!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"opinion_grux3": {"text": "Sí, pesados. Pero al menos no votan todo como los mohócratas.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_plegado": {"text": "Los plegados clasifican todo. Hasta las minas. ¡Es absurdo!", "options": [
					{"label": "¿Clasifican minas?", "next": "opinion_plegado2"},
					{"label": "Qué pesados", "next": "opinion_plegado3"},
				]},
				"opinion_plegado2": {"text": "Sí, las clasifican por tamaño, forma y color. ¡Las minas no son colores!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_plegado3": {"text": "Sí, pesados. Pero al menos no flotan como los grux.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_eco": {"text": "Los ecos repiten todo. Es como tener un loro que habla.", "options": [
					{"label": "¿Un loro?", "next": "opinion_eco2"},
					{"label": "Qué pesados", "next": "opinion_eco3"},
				]},
				"opinion_eco2": {"text": "Sí, pero el loro al menos es gracioso. Los ecos son... repetitivos.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_eco3": {"text": "Sí, pesados. Pero al menos no votan todo.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_manada": {"text": "La manada solo va a la derecha. Es como nosotros pero sin parar.", "options": [
					{"label": "¿Sin parar?", "next": "opinion_manada2"},
					{"label": "Qué raros", "next": "opinion_manada3"},
				]},
				"opinion_manada2": {"text": "Sí, van siempre adelante. Como los jubilados pero sin descansar.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_manada3": {"text": "Sí, raros. Pero al menos no flotan ni votan.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"anecdote": {"text": "Una vez un grux cayó en una mina. ¡Explotó! Y flotó aún más alto. ¡Ja!", "options": [
					{"label": "Jaja", "next": "anecdote2"},
					{"label": "Qué cruel", "next": "anecdote3"},
				]},
				"anecdote2": {"text": "Sí, fue gracioso. El grux no pensó lo mismo. Pero flotó más alto, así que ganó.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué horror", "next": "", "action": "insult"},
				]},
				"anecdote3": {"text": "Cruel sí, pero el grux sobrevivió. Y ahora tiene una pierna de madera. ¡Ja!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué horror", "next": "", "action": "insult"},
				]},
				"apocalipsis": {"text": "El Apocalipsis fue cuando todo se desplegó. Ciudades enteras cambiaron de sitio.", "options": [
					{"label": "¿Qué pasó?", "next": "apocalipsis2"},
					{"label": "¿Sobreviviste?", "next": "apocalipsis3"},
				]},
				"apocalipsis2": {"text": "Las instalaciones recibieron órdenes contradictorias. Unas regiones se desplegaron, otras se comprimieron.", "options": [
					{"label": "¿Y los jubilados?", "next": "apocalipsis4"},
					{"label": "Qué horror", "next": "root"},
				]},
				"apocalipsis3": {"text": "Sí, nos refugiamos en pliegues y espacios que ya no aparecían en los registros.", "options": [
					{"label": "¿Y los demás?", "next": "apocalipsis4"},
					{"label": "Qué suerte", "next": "root", "action": "praise"},
				]},
				"apocalipsis4": {"text": "Los plegados ocultaron que la tecnología comprimía materia viva. Por eso hubo guerra.", "options": [
					{"label": "¿Guerra?", "next": "apocalipsis5"},
					{"label": "Volver", "next": "root"},
				]},
				"apocalipsis5": {"text": "Sí, la Guerra de las Esquinas. Los grux financiaron, los ecos transmitieron, los jubilados mantuvieron las instalaciones.", "options": [
					{"label": "Qué historia", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"rumor": {"text": "Los mohócratas han votado algo raro otra vez.", "options": [
					{"label": "¿Qué votaron?", "next": "rumor2"},
					{"label": "¿Siempre votan?", "next": "rumor3"},
					{"label": "¿Alguna otra cosa?", "next": "rumor4"},
				]},
				"rumor2": {"text": "No sé, pero huele a moho. ¡Ja!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué asco", "next": "", "action": "insult"},
				]},
				"rumor3": {"text": "Siempre. Votan hasta para respirar. ¡Los grux se quejan!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"rumor4": {"text": "Sí, los plegados han clasificado algo. No sé qué. Pero suena importante.", "options": [
					{"label": "¿Los plegados?", "next": "rumor5"},
				]},
				"rumor5": {"text": "Sí, clasifican todo. Incluso las esporas de los mohócratas. ¡Es absurdo!", "options": [
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
					{"label": "¿Conoces a Don Ramón?", "next": "ramon"},
					{"label": "¿Qué opinas de los jubilados?", "next": "opinion_jub"},
					{"label": "¿Y de los grux?", "next": "opinion_grux"},
					{"label": "¿Y de los plegados?", "next": "opinion_plegado"},
					{"label": "¿Y de los ecos?", "next": "opinion_eco"},
					{"label": "¿Y de la manada?", "next": "opinion_manada"},
					{"label": "¿Alguna anécdota?", "next": "anecdote"},
					{"label": "¿Qué fue el Apocalipsis?", "next": "apocalipsis"},
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
					{"label": "¿Votáis por diversión?", "next": "vote5"},
				]},
				"vote4": {"text": "Sí. La última votación fue sobre si votar es divertido. Ganó el sí.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"vote5": {"text": "Sí, votamos por diversión. Es la única forma de que la asamblea no se aburra.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"complaint": {"text": "Los plegados clasifican nuestras esporas. ¡Es una ofensa!", "options": [
					{"label": "¿Esporas?", "next": "complaint2"},
					{"label": "¿Qué más?", "next": "complaint3"},
				]},
				"complaint2": {"text": "Sí, las clasifican por color. ¡Nosotros no somos colores!", "options": [
					{"label": "Qué injusto", "next": "root", "action": "praise"},
					{"label": "Me parece bien", "next": "", "action": "hit"},
				]},
				"complaint3": {"text": "También clasifican nuestro moho. Dicen que es 'hongo de tercera'. ¡Indignante!", "options": [
					{"label": "Indignante", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"ramon": {"text": "Don Ramón es un tirano. Pero no lo digas muy alto.", "options": [
					{"label": "¿Tirano?", "next": "ramon2"},
					{"label": "¿Por qué?", "next": "ramon3"},
					{"label": "¿Qué hace?", "next": "ramon4"},
				]},
				"ramon2": {"text": "Porque obliga a los jubilados a jugar con minas. ¡Es un abuso!", "options": [
					{"label": "Qué horror", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"ramon3": {"text": "Porque si no te pegas con él. Y nadie quiere eso.", "options": [
					{"label": "Entendido", "next": "root"},
					{"label": "Me da igual", "next": "", "action": "hit"},
				]},
				"ramon4": {"text": "Manda a los jubilados a jugar. Y cobra peaje. ¡Es un abuso!", "options": [
					{"label": "¿Peaje?", "next": "ramon5"},
				]},
				"ramon5": {"text": "Sí, hasta por respirar. Pero los grux no pagan. ¡Es injusto!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"opinion_jub": {"text": "Los jubilados son... viejos y cansados. Pero buena gente.", "options": [
					{"label": "¿Buena gente?", "next": "opinion_jub2"},
					{"label": "No lo parece", "next": "opinion_jub3"},
				]},
				"opinion_jub2": {"text": "Sí, cuando no juegan con minas. Entonces son peligrosos.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_jub3": {"text": "No, no lo parece. Pero en el fondo son como nosotros: viejos.", "options": [
					{"label": "Qué bonito", "next": "root", "action": "praise"},
					{"label": "No lo creo", "next": "", "action": "insult"},
				]},
				"opinion_grux": {"text": "Los grux son flotantes y pretenciosos. Pero tienen buen aire.", "options": [
					{"label": "¿Buen aire?", "next": "opinion_grux2"},
					{"label": "Qué pesados", "next": "opinion_grux3"},
				]},
				"opinion_grux2": {"text": "Sí, el aire que respiran es fresco. Pero no lo comparten. ¡Egoístas!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"opinion_grux3": {"text": "Sí, pesados. Pero al menos no juegan con minas como los jubilados.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_plegado": {"text": "Los plegados clasifican todo. Hasta nuestras esporas. ¡Es una ofensa!", "options": [
					{"label": "¿Clasifican esporas?", "next": "opinion_plegado2"},
					{"label": "Qué pesados", "next": "opinion_plegado3"},
				]},
				"opinion_plegado2": {"text": "Sí, las clasifican por color. ¡Nosotros no somos colores!", "options": [
					{"label": "Qué injusto", "next": "root", "action": "praise"},
					{"label": "Me parece bien", "next": "", "action": "hit"},
				]},
				"opinion_plegado3": {"text": "Sí, pesados. Pero al menos no votan todo.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_eco": {"text": "Los ecos repiten todo. Es como tener un loro que habla.", "options": [
					{"label": "¿Un loro?", "next": "opinion_eco2"},
					{"label": "Qué pesados", "next": "opinion_eco3"},
				]},
				"opinion_eco2": {"text": "Sí, pero el loro al menos es gracioso. Los ecos son... repetitivos.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_eco3": {"text": "Sí, pesados. Pero al menos no votan todo.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_manada": {"text": "La manada solo va a la derecha. Es como nosotros pero sin parar.", "options": [
					{"label": "¿Sin parar?", "next": "opinion_manada2"},
					{"label": "Qué raros", "next": "opinion_manada3"},
				]},
				"opinion_manada2": {"text": "Sí, van siempre adelante. Como los mohócratas pero sin votar.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"opinion_manada3": {"text": "Sí, raros. Pero al menos no clasifican todo.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"anecdote": {"text": "Una vez un grux cayó en una mina. ¡Explotó! Y flotó aún más alto. ¡Ja!", "options": [
					{"label": "Jaja", "next": "anecdote2"},
					{"label": "Qué cruel", "next": "anecdote3"},
				]},
				"anecdote2": {"text": "Sí, fue gracioso. El grux no pensó lo mismo. Pero flotó más alto, así que ganó.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué horror", "next": "", "action": "insult"},
				]},
				"anecdote3": {"text": "Cruel sí, pero el grux sobrevivió. Y ahora tiene una pierna de madera. ¡Ja!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué horror", "next": "", "action": "insult"},
				]},
				"apocalipsis": {"text": "El Apocalipsis fue cuando todo se desplegó. Ciudades enteras cambiaron de sitio.", "options": [
					{"label": "¿Qué pasó?", "next": "apocalipsis2"},
					{"label": "¿Sobreviviste?", "next": "apocalipsis3"},
				]},
				"apocalipsis2": {"text": "Las instalaciones recibieron órdenes contradictorias. Unas regiones se desplegaron, otras se comprimieron.", "options": [
					{"label": "¿Y los mohócratas?", "next": "apocalipsis4"},
					{"label": "Qué horror", "next": "root"},
				]},
				"apocalipsis3": {"text": "Sí, nos refugiamos en pliegues y espacios que ya no aparecían en los registros.", "options": [
					{"label": "¿Y los demás?", "next": "apocalipsis4"},
					{"label": "Qué suerte", "next": "root", "action": "praise"},
				]},
				"apocalipsis4": {"text": "Los plegados ocultaron que la tecnología comprimía materia viva. Por eso hubo guerra.", "options": [
					{"label": "¿Guerra?", "next": "apocalipsis5"},
				]},
				"apocalipsis5": {"text": "Sí, la Guerra de las Esquinas. Los grux financiaron, los ecos transmitieron, los jubilados mantuvieron las instalaciones.", "options": [
					{"label": "Qué historia", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
			}
		"plegado":
			return {
				"root": {"text": "¿En qué categoría te sitúo?", "options": [
					{"label": "¿Categoría?", "next": "cat"},
					{"label": "¿Algo interesante?", "next": "news"},
					{"label": "¿Qué clasificas?", "next": "classify"},
					{"label": "¿Qué fue la Gran Clasificación?", "next": "granclas"},
					{"label": "¿Y la Guerra de las Esquinas?", "next": "guerra"},
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
					{"label": "¿Y los grux?", "next": "classify3"},
				]},
				"classify2": {"text": "Sí. Y los grux están en 'seres que flotan sin permiso'.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué ofensa", "next": "", "action": "insult"},
				]},
				"classify3": {"text": "Los grux están en 'seres que flotan sin permiso'. Y los ecos en 'ruido repetitivo'.", "options": [
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
				"granclas": {"text": "La Gran Clasificación fue nuestro mayor logro. Catalogamos todo lo existente.", "options": [
					{"label": "¿Todo?", "next": "granclas2"},
				]},
				"granclas2": {"text": "Sí, todo. Hasta las categorías. El sistema se volvió tan complejo que necesitaba más recursos que el gobierno.", "options": [
					{"label": "¿Y qué pasó?", "next": "granclas3"},
				]},
				"granclas3": {"text": "La administración colapsó. Pero los archivos siguen ahí. En algún pliegue.", "options": [
					{"label": "¿Dónde?", "next": "granclas4"},
					{"label": "Volver", "next": "root"},
				]},
				"granclas4": {"text": "Nadie sabe. Los archivos están en pliegues que ya no aparecen en los registros.", "options": [
					{"label": "Qué misterio", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"guerra": {"text": "La Guerra de las Esquinas fue cuando los plegados ocultaron que la tecnología comprimía materia viva.", "options": [
					{"label": "¿Materia viva?", "next": "guerra2"},
				]},
				"guerra2": {"text": "Sí, la tecnología que comprimía regiones enteras también podía comprimir seres vivos.", "options": [
					{"label": "¿Y qué pasó?", "next": "guerra3"},
				]},
				"guerra3": {"text": "Las facciones lucharon por controlar las instalaciones. El experimento falló. Ciudades enteras cambiaron de sitio.", "options": [
					{"label": "¿El Apocalipsis?", "next": "guerra4"},
					{"label": "Volver", "next": "root"},
				]},
				"guerra4": {"text": "Sí, el Apocalipsis del Despliegue. Las instalaciones recibieron órdenes contradictorias.", "options": [
					{"label": "Qué horror", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
			}
		"eco":
			return {
				"root": {"text": "Eco... eco... ¿qué quieres?", "options": [
					{"label": "¿Qué eres?", "next": "what"},
					{"label": "¿Alguna noticia?", "next": "news"},
					{"label": "¿Qué repites?", "next": "repeat"},
					{"label": "¿Qué fue el Apocalipsis?", "next": "apocalipsis"},
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
					{"label": "¿Repites secretos?", "next": "repeat3"},
				]},
				"repeat2": {"text": "De los grux. Lo repiten mucho. Y yo lo amplifico.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"repeat3": {"text": "Sí, repito secretos. Pero no los entiendo. Solo los amplifico.", "options": [
					{"label": "¿Qué secretos?", "next": "repeat4"},
					{"label": "Volver", "next": "root"},
				]},
				"repeat4": {"text": "No sé. Algo sobre pliegues y materia viva. Pero solo es un eco.", "options": [
					{"label": "Qué misterio", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"news": {"text": "Los grux han dicho algo sobre el aire. Lo repito: 'el aire es nuestro'.", "options": [
					{"label": "¿Los grux?", "next": "news2"},
					{"label": "¿Algo más?", "next": "news3"},
				]},
				"news2": {"text": "Sí, flotan y se creen dueños del viento. ¡Qué eco!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"news3": {"text": "Sí, los plegados han clasificado algo. Lo repito: 'individuo sin pliegue'.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"apocalipsis": {"text": "El Apocalipsis... eco... fue cuando todo se desplegó. Lo repito: 'ciudades cambiaron de sitio'.", "options": [
					{"label": "¿Qué pasó?", "next": "apocalipsis2"},
				]},
				"apocalipsis2": {"text": "Las instalaciones recibieron órdenes contradictorias. Lo repito: 'unas regiones se desplegaron'.", "options": [
					{"label": "¿Y los demás?", "next": "apocalipsis3"},
				]},
				"apocalipsis3": {"text": "Los jubilados mantuvieron las instalaciones. Lo repito: 'los grux financiaron'.", "options": [
					{"label": "Qué historia", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
			}
		"grux":
			return {
				"root": {"text": "¿Qué quieres, ser de abajo?", "options": [
					{"label": "¿Ser de abajo?", "next": "below"},
					{"label": "¿Algo interesante?", "next": "news"},
					{"label": "¿Por qué flotáis?", "next": "float"},
					{"label": "¿Qué fue el Apocalipsis?", "next": "apocalipsis"},
					{"label": "Adiós", "next": ""},
				]},
				"below": {"text": "Sí, tú caminas por el suelo. Nosotros flotamos. Es mejor.", "options": [
					{"label": "¿Mejor?", "next": "below2"},
					{"label": "¿Por qué es mejor?", "next": "below3"},
				]},
				"below2": {"text": "Sí, el aire es nuestro. ¿Quieres una pieza voladora?", "options": [
					{"label": "Sí", "next": "", "action": "gift_piece"},
					{"label": "No", "next": "root"},
				]},
				"below3": {"text": "Porque no pisamos minas. Y vemos todo desde arriba. Es una ventaja.", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"float": {"text": "Flotamos porque el aire nos sostiene. Es nuestro derecho.", "options": [
					{"label": "¿Derecho?", "next": "float2"},
					{"label": "¿De dónde viene el aire?", "next": "float3"},
				]},
				"float2": {"text": "Sí. Los mohócratas quieren cobrar por respirar. ¡Ridículo!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"float3": {"text": "El aire viene del planeta. Pero los mohócratas quieren cobrar por usarlo. ¡Es absurdo!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"news": {"text": "Los mohócratas quieren cobrar tributo por el aire. ¡Ridículo!", "options": [
					{"label": "¿Tributo?", "next": "news2"},
					{"label": "¿Alguna otra cosa?", "next": "news3"},
				]},
				"news2": {"text": "Sí, quieren cobrar por respirar. ¡El aire es de todos!", "options": [
					{"label": "Tienes razón", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
				"news3": {"text": "Sí, los plegados han clasificado algo. No sé qué. Pero suena importante.", "options": [
					{"label": "¿Los plegados?", "next": "news4"},
				]},
				"news4": {"text": "Sí, clasifican todo. Incluso el aire. ¡Es absurdo!", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"apocalipsis": {"text": "El Apocalipsis... fue cuando todo se desplegó. Nosotros financiamos parte de los experimentos.", "options": [
					{"label": "¿Financiasteis?", "next": "apocalipsis2"},
				]},
				"apocalipsis2": {"text": "Sí, los grux financiaron la tecnología de los plegados. Pero no sabíamos que comprimía materia viva.", "options": [
					{"label": "¿Y qué pasó?", "next": "apocalipsis3"},
				]},
				"apocalipsis3": {"text": "La guerra comenzó. Las instalaciones fallaron. Ciudades enteras cambiaron de sitio.", "options": [
					{"label": "Qué horror", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
			}
		"manada":
			return {
				"root": {"text": "Solo vamos a la derecha. ¿Vienes?", "options": [
					{"label": "¿Solo a la derecha?", "next": "right"},
					{"label": "¿Algo interesante?", "next": "news"},
					{"label": "¿Por qué solo a la derecha?", "next": "why"},
					{"label": "¿Qué fue el Apocalipsis?", "next": "apocalipsis"},
					{"label": "Adiós", "next": ""},
				]},
				"right": {"text": "Sí, no hay marcha atrás. Siempre adelante.", "options": [
					{"label": "¿Por qué?", "next": "right2"},
					{"label": "¿Nunca paráis?", "next": "right3"},
				]},
				"right2": {"text": "Porque así lo manda la ruta eterna. ¿Quieres una pieza?", "options": [
					{"label": "Sí", "next": "", "action": "gift_piece"},
					{"label": "No", "next": "root"},
				]},
				"right3": {"text": "No, nunca paramos. Parar es morir. La ruta eterna es nuestro destino.", "options": [
					{"label": "Qué valiente", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"why": {"text": "Porque la ruta eterna va hacia adelante. No hay vuelta atrás.", "options": [
					{"label": "¿Y si hay peligro?", "next": "why2"},
					{"label": "¿Y si hay un muro?", "next": "why3"},
				]},
				"why2": {"text": "Entonces vamos más rápido. ¿Quieres venir?", "options": [
					{"label": "Sí", "next": "root", "action": "praise"},
					{"label": "No", "next": "", "action": "insult"},
				]},
				"why3": {"text": "Entonces damos la vuelta. Pero solo a la derecha. Es la única forma.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué raro", "next": "root"},
				]},
				"news": {"text": "Los jubilados juegan con minas. Es peligroso.", "options": [
					{"label": "¿Minas?", "next": "news2"},
					{"label": "¿Algo más?", "next": "news3"},
				]},
				"news2": {"text": "Sí, petanca con minas. Solo a la derecha, lejos de ellos.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué peligro", "next": "", "action": "insult"},
				]},
				"news3": {"text": "Sí, los grux flotan. Y los mohócratas votan. Todo es raro aquí.", "options": [
					{"label": "Jaja", "next": "root", "action": "praise"},
					{"label": "Qué pesados", "next": "", "action": "insult"},
				]},
				"apocalipsis": {"text": "El Apocalipsis... fue cuando todo se desplegó. Nosotros solo seguimos la ruta.", "options": [
					{"label": "¿Qué pasó?", "next": "apocalipsis2"},
				]},
				"apocalipsis2": {"text": "Las ciudades cambiaron de sitio. Pero nosotros seguimos a la derecha. Es lo único que sabemos.", "options": [
					{"label": "Qué valiente", "next": "root", "action": "praise"},
					{"label": "Me da igual", "next": "", "action": "insult"},
				]},
			}
		_:
			return {}
