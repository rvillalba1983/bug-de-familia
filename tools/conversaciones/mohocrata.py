# -*- coding: utf-8 -*-
"""Banco de conversaciones de los Mohócratas (P-42).

Fuente de lore: docs/50_lore.md (sección 3) y las líneas de data/world/species.json.
Ver tools/gen_conversaciones.py para el uso de cada clave.
"""

SPECIES = "mohocrata"

GREETING = "Bienvenido al censo. ¿Traes papeles?"

OPENERS = [
	"Antes de nada, una aclaración:",
	"Te informo con arreglo al reglamento:",
	"Una cuestión de orden.",
	"Pregunto y luego se vota:",
	"Con permiso de la Asamblea:",
	"Que quede constancia:",
	"Esto lo someto a tu consideración:",
	"Escucha, que hay quorum:",
	"Última cuestión del día:",
	"Y un asunto menor:",
]

TOPICS = [
	{
		"ask": [
			"¿Sabes qué se votó en la Asamblea de las Esporas?",
			"¿Has oído lo del banco?",
			"¿Cuánto crees que puede durar una votación?",
		],
		"fact": [
			"Llevamos catorce años votando la cuarta votación sobre las tres primeras.",
			"La propuesta original era poner un banco. El banco ya no existe, la votación sí.",
			"La cuarta votación se convocó para decidir si las tres anteriores eran válidas.",
		],
		"payoff": [
			"Hay una facción que propone poner otro banco para que la votación tenga sentido.",
			"El acta de la votación del banco ocupa más que el banco. El banco era de madera.",
		],
		"deflect": [
			"Ese asunto está en la cuarta votación. No puedo hablar de él hasta la quinta.",
			"Se votó no informar. Ganó por dos votos y un recuento.",
		],
		"hot": "Catorce años para decidir un banco es una incompetencia que debería votarse y anularse.",
		"offer": "Tengo una pieza de repuesto del banco. Del banco original, que ya no está.",
		"gift": "Toma, y no la instales sin votarlo antes.",
		"battle": "Los Jubilados se apagan a las nueve sin votarlo siquiera. Eso es un abuso de poder.",
		"praise": "Tu intervención queda aprobada por aclamación. Sin recuento, que hoy hay prisa.",
	},
	{
		"ask": [
			"¿Sabes cuántas veces votamos antes de atacar?",
			"¿Cuántas votaciones crees que hacen falta para respirar?",
			"¿Te parece normal votar si votar?",
		],
		"fact": [
			"Votamos tres veces antes de atacar: la propuesta, la confirmación y la validez.",
			"Nos hemos votado hasta si respirar. Salió a favor por poco.",
			"El sistema produce una estabilidad institucional enorme y una lentitud legendaria.",
		],
		"payoff": [
			"Un año votamos respirar y salió en contra. Fue un invierno muy corto.",
			"La tercera votación existe porque la segunda siempre parecía sospechosa.",
		],
		"deflect": [
			"Eso requiere tres votaciones y hoy solo tengo tiempo para dos.",
			"Se votó no responder a preguntas sobre votaciones. Irónico, pero válido.",
		],
		"hot": "Tres votaciones para todo es una tontería que solo sirve para no decidir nunca.",
		"offer": "Tengo una pieza de repuesto. La segunda votación sobre ella sigue abierta.",
		"gift": "Toma, y la entrega queda aprobada por unanimidad de los presentes.",
		"battle": "Los Jubilados deciden solos y encima se quejan. Votemos enseñarles modales.",
		"praise": "Queda aprobado tu elogio. Se votará si se agradece mañana.",
	},
	{
		"ask": [
			"¿Sabes qué es el acta fundacional?",
			"¿Te han contado de dónde salió nuestra constitución?",
			"¿Qué crees que dice la Primera Asamblea?",
		],
		"fact": [
			"El acta de la Primera Asamblea es, en realidad, una receta de sopa leída en voz alta.",
			"Se leyó por error y gustó tanto que se archivó como constitución.",
			"Los Cocina-Comités la siguen interpretando cada invierno con rigor jurídico.",
		],
		"payoff": [
			"Nadie ha catado la sopa. La ley, sí, y sabe a caldo frío.",
			"Una enmienda reciente cambió «sofreír» por «legislar». Se nota en el sabor.",
		],
		"deflect": [
			"El acta es secreta. Y la receta, también, por motivos de seguridad alimentaria.",
			"No puedo leerte el acta sin tres votaciones y una cuchara.",
		],
		"hot": "La constitución es una receta de sopa y el país entero huele a caldo frío.",
		"offer": "Tengo una pieza que sirve de cazo. Tiene más rango que yo.",
		"gift": "Toma, y no la llenes: es el cazo fundacional.",
		"battle": "Los Jubilados nos llaman sopistas. Su colapso fue una luz que se fue, y aun así opinan.",
		"praise": "Ese elogio se incorpora al preámbulo. Con tu permiso y dos votos.",
	},
	{
		"ask": [
			"¿Sabes quién es el más hongo?",
			"¿Has votado alguna vez al más hongo?",
			"¿Qué premio tiene el concurso del más hongo?",
		],
		"fact": [
			"Votamos en secreto quién es el más hongo. Sin premio, sin criterios y sin sentido.",
			"El ganador lleva doscientos años siendo el mismo sombrero de chatarra.",
			"El sombrero está más oxidado que orgulloso, y aun así gana por mayoría.",
		],
		"payoff": [
			"Se presentó un hongo joven con un programa electoral y quedó tercero.",
			"El sombrero no ha pronunciado un discurso en doscientos años. Su silencio se vota como programa.",
		],
		"deflect": [
			"La votación es secreta. Y el resultado también, aunque se sabe.",
			"No te puedo decir el ganador sin consultar al sombrero.",
		],
		"hot": "El concurso del más hongo es un chiste que lleva doscientos años sin gracia.",
		"offer": "Tengo una pieza que votó al sombrero. Por lealtad, no por criterio.",
		"gift": "Toma, y vota lo que quieras, que el sombrero gana igual.",
		"battle": "Los Grux quieren apostar por el más hongo. Convertir un concurso en negocio es de otra especie.",
		"praise": "Quedas nombrado hongo honorario. No tiene premio, pero se vota.",
	},
	{
		"ask": [
			"¿Sabes qué es la Enmienda del Plato?",
			"¿Qué coméis en los años malos?",
			"¿Por qué votáis qué comer tres veces?",
		],
		"fact": [
			"Antes de comer votamos qué comer, tres veces, como todo.",
			"En años malos comemos abstención. No sabe mal, sabe a nada.",
			"La Enmienda del Plato reparte los recursos por votación y por hambre.",
		],
		"payoff": [
			"Hubo un año en que la abstención se sirvió caliente y hubo que votar el menú otra vez.",
			"Un Cocina-Comité dimitió por servir sopa del acta fundacional sin enfriarla.",
		],
		"deflect": [
			"Hoy se vota el postre. Cuando acabe, hablamos.",
			"El menú está pendiente de confirmación. Como el año pasado.",
		],
		"hot": "Votar la comida es absurdo: el hambre no admite segunda vuelta.",
		"offer": "Tengo una pieza de repuesto que también sirve de tenedor.",
		"gift": "Toma, y no la uses con abstención, que se pega.",
		"battle": "Los Jubilados comen chispas y nos miran mal. Pues que voten su menú.",
		"praise": "Se agradece el elogio y se vota si se repite.",
	},
	{
		"ask": [
			"¿Sabes qué opinamos de la luz?",
			"¿Por qué crees que vivimos bajo tierra?",
			"¿Qué fue el Apocalipsis de la Luz?",
		],
		"fact": [
			"La luz es un abuso de poder con lumbre. Es doctrina, no manía.",
			"El Apocalipsis de la Luz colapsó las zonas de cultivo y la comunicación.",
			"Muchas colonias sobrevivimos bajo tierra y en estructuras abandonadas.",
		],
		"payoff": [
			"Hay una comisión para votar si la luz del sol cuenta como abuso o como exceso.",
			"El comité antiluz se reúne de noche. Asisten pocos y todos con sombrero.",
		],
		"deflect": [
			"Apaga eso, por favor. Estamos hablando.",
			"No puedo votar nada con esta claridad. Me desconcentra.",
		],
		"hot": "La luz del sol no es un abuso: es gratis, y lo gratis no se vota.",
		"offer": "Tengo una pieza de repuesto que brilla. La guardo por si acaso.",
		"gift": "Toma, y no la enciendas en la Asamblea, que la votan apagada.",
		"battle": "Los Jubilados se iluminan a todas horas y nos llaman oscurantistas. Ya está bien.",
		"praise": "Tu elogio brilla. Y eso, viniendo de mí, es mucho.",
	},
	{
		"ask": [
			"¿Con qué se compran los votos aquí?",
			"¿Sabes qué pasa con los sobornos?",
			"¿Es legal sobornar en la Asamblea?",
		],
		"fact": [
			"Los votos se compran con fertilizante y los sobornos se declaran por transparencia.",
			"Al declararse, el soborno es legal, masivo y muy rentable para el vendedor.",
			"Un buen saco de fertilizante cambia cualquier votación y consta en acta.",
		],
		"payoff": [
			"El vendedor de fertilizante es el único ciudadano con mayoría absoluta permanente.",
			"El registro de sobornos es público y se consulta más que el censo.",
		],
		"deflect": [
			"Ese soborno está declarado. Por tanto, no ha existido.",
			"No hablemos de fertilizante delante de la comisión de fertilizante.",
		],
		"hot": "Sobornar con fertilizante y llamarlo transparencia es corrupción con abono.",
		"offer": "Tengo una pieza de repuesto. La cambio por fertilizante o por un voto.",
		"gift": "Toma, y decláralo, que lo no declarado huele mal.",
		"battle": "Los Grux nos venden fertilizante a crédito y luego votan nuestras deudas. Eso sí es trampa.",
		"praise": "Gracias. Lo declaro como regalo y lo votamos bonito.",
	},
	{
		"ask": [
			"¿Sabes qué votan nuestros pies?",
			"¿Por qué crees que nos movemos tan poco?",
			"¿Quién decide si damos un paso?",
		],
		"fact": [
			"Sometemos a votación partes del cuerpo antes de moverlas. Los pies suelen perder.",
			"La propuesta de caminar se debate y se archiva con frecuencia.",
			"Hay ciudadanos que llevan años sin moverse por respeto al resultado.",
		],
		"payoff": [
			"Un pie presentó un recurso y se le votó como «extremidad con iniciativa». Perdió.",
			"El comité de movilidad se reúne en una silla. Nunca ha hecho falta levantarla.",
		],
		"deflect": [
			"El movimiento está en estudio. No me pidas que me levante a comprobarlo.",
			"Mis pies han votado no. Y yo acato.",
		],
		"hot": "Votar si moverse es la excusa perfecta para no hacer absolutamente nada.",
		"offer": "Tengo una pieza de repuesto que no necesita votación para funcionar.",
		"gift": "Toma, y llévala tú, que mis pies están en contra.",
		"battle": "La Manada no para de girar a la derecha y nosotros no damos un paso. Empecemos por alguien.",
		"praise": "Se agradece el elogio. No requiere votación, por suerte.",
	},
	{
		"ask": [
			"¿Sabes qué fue la Revolución de los Sombreros?",
			"¿Por qué lleváis chatarra en la cabeza?",
			"¿Te gusta mi sombrero?",
		],
		"fact": [
			"Una parte de la población rechazó los sombreros de chatarra como símbolo de estatus.",
			"El conflicto dividió a la sociedad entre tradicionalistas y renovadores.",
			"Los Mohócratas usamos sombreros de chatarra como identidad física y social.",
		],
		"payoff": [
			"Se votó el asunto tres veces y ganó llevar sombrero, pero del revés.",
			"Hay un renovador que lleva el sombrero dentro. Dice que es una postura política.",
		],
		"deflect": [
			"El sombrero no se discute. Se lleva y se vota.",
			"Mi sombrero es de antes del conflicto. No opina y por eso dura.",
		],
		"hot": "Los sombreros de chatarra son un pliego de descargo con óxido encima.",
		"offer": "Tengo una pieza de repuesto que era parte de un sombrero.",
		"gift": "Toma, y póntela donde puedas, que no juzgamos.",
		"battle": "Los Plegados dicen que nuestros sombreros son pliegues fallidos. Eso se contesta con votos o con palos.",
		"praise": "Buen gusto. Se nota que no te has dejado influir por la moda del revés.",
	},
	{
		"ask": [
			"¿Sabes qué fue la Crisis de las Esporas?",
			"¿Quién robó la red biológica?",
			"¿Por qué está rota la memoria colectiva?",
		],
		"fact": [
			"Los Grux comerciaron con información de nuestra red biológica.",
			"Algunas sustancias alteraron la comunicación entre colonias y la red se fragmentó.",
			"Parte de la memoria colectiva quedó aislada. Hay recuerdos que nadie reclama.",
		],
		"payoff": [
			"En la red fragmentada quedaron recuerdos de otras especies que ahora no sabemos devolver.",
			"Hay una colonia que responde a estímulos de instalaciones que nadie recuerda.",
		],
		"deflect": [
			"Ese asunto está en la comisión de la red. Lleva en la comisión desde la crisis.",
			"Se votó no recordar. Salió casi unánime y luego se olvidó.",
		],
		"hot": "Los Grux no robaron nada: compraron lo que nadie estaba usando.",
		"offer": "Tengo una pieza que guarda un recuerdo suelto. No sé de quién es.",
		"gift": "Toma, y si el recuerdo te suena, avísame. Sería un buen día para la red.",
		"battle": "Los Grux nos vendieron nuestra propia memoria por fertilizante. Empecemos por ahí.",
		"praise": "Eso merece constar en la red. Y en acta, si se puede.",
	},
	{
		"ask": [
			"¿Cuánto cuesta un tomate en el Gran Mercado?",
			"¿Por qué tardáis tanto en poner los precios?",
			"¿Sabes cómo se fija un precio aquí?",
		],
		"fact": [
			"En el Gran Mercado sometemos a votación los precios de todo.",
			"Un tomate necesita tres votos y un anexo regulatorio.",
			"Los Grux venden en la puerta «precios tasados al contado, sin acta».",
		],
		"payoff": [
			"El público agradece la prisa de los Grux y luego vota arrepentirse.",
			"Hay un tomate que lleva cuatro años en la Asamblea como «producto pendiente de precio».",
		],
		"deflect": [
			"El precio del tomate está en la segunda votación. Vuelve el jueves.",
			"Te lo diría, pero costaría tres votos y no tengo quorum.",
		],
		"hot": "Votar los precios es encarecer la vida con papeleo. El tomate ya lo dice el mercado.",
		"offer": "Tengo una pieza de repuesto. El precio lo pongo yo, que para eso la tengo.",
		"gift": "Toma, y no me pidas factura, que necesitaría dos votos.",
		"battle": "Los Grux abren un puesto fuera y se llevan el género. Eso no se vota, se impide.",
		"praise": "Buen ojo para el precio. Se agradece y se tasa.",
	},
	{
		"ask": [
			"¿Sabes qué votamos en el Atajo de las Esporas?",
			"¿Por qué hay una caravana dando vueltas?",
			"¿Es verdad que cerrasteis el giro a la derecha?",
		],
		"fact": [
			"Votamos cerrar el giro a la derecha para frenar el tráfico.",
			"La Manada solo gira a la derecha: lleva semanas orbitando el paso.",
			"Hemos convocado una votación de emergencia sobre si es un problema. Tres veces.",
		],
		"payoff": [
			"Los Rastreadores Libres proponen girar a la izquierda. La Manada Central se indispone.",
			"La caravana ya sabe el camino de memoria y sigue sin poder usarlo.",
		],
		"deflect": [
			"El giro está cerrado por votación. Reabrirlo exige cuatro y un estudio.",
			"Si vienes por el atajo, da la vuelta. Nosotros ya la hemos votado.",
		],
		"hot": "Cerrar el giro a la derecha fue una ocurrencia y ahora hay una caravana dando vueltas.",
		"offer": "Tengo una pieza de repuesto del puesto de peaje del atajo.",
		"gift": "Toma, y si vas al atajo, gira a la derecha antes de que lo reabramos.",
		"battle": "La Manada no respeta el giro cerrado y encima se queja de la vuelta. ¿Votamos defendernos?",
		"praise": "Se agradece el elogio. Y no hay que votarlo, que ya es tarde.",
	},
	{
		"ask": [
			"¿Sabes qué discuten Mohócratas y Jubilados en Abuela RAM?",
			"¿Por qué llamáis «material» a los robots muertos?",
			"¿Qué es un difunto para ti?",
		],
		"fact": [
			"Nosotros llamamos «material» a los robots muertos. Los Jubilados los llaman «difuntos».",
			"Ha habido insultos formales por acta y una reprimenda conjunta.",
			"La reprimenda se votó, hubo empate y se votó el empate. Sigue empatado.",
		],
		"payoff": [
			"Así ganamos los dos y no arreglamos nada, que es nuestra obra maestra.",
			"Hay un taller donde el mismo cuerpo tiene dos fichas y ninguna se mueve.",
		],
		"deflect": [
			"El asunto está empatado. No puedo hablar de él sin desempatar.",
			"Llámalo como quieras, pero no lo toques.",
		],
		"hot": "Llamar «difunto» a un robot es un sentimentalismo que retrasa el reciclaje.",
		"offer": "Tengo una pieza de repuesto. Venía de un «material» que ya no discutía.",
		"gift": "Toma, y no le pongas nombre, que luego reclama.",
		"battle": "Los Jubilados nos miran reciclar en silencio y lo llaman abstención hostil. Pues hablemos.",
		"praise": "Buen detalle. Lo apunto en la ficha buena, la que no tiene gemela.",
	},
	{
		"ask": [
			"¿Conoces a algún abstencionista?",
			"¿Sabes cuánto puede aguantar uno sin votar?",
			"¿Qué pasa si no votas nada?",
		],
		"fact": [
			"La abstención es una forma de vida: hay quien lleva nueve años sin confirmar su nombre.",
			"Abstenerse no es no decidir, es decidir que decida otro con tu silencio.",
			"El abstencionista más veterano no vota ni cuando le votan a él.",
		],
		"payoff": [
			"Se le preguntó su nombre y contestó «pendiente». Consta así en el censo.",
			"Hay un premio al mérito abstencionista, pero nadie lo ha aceptado.",
		],
		"deflect": [
			"Yo me abstengo de responder a esa pregunta. Y a la siguiente.",
			"Podría votar una respuesta, pero no veo quorum en mí mismo.",
		],
		"hot": "Abstenerse es cobardía con papeleta: no decide nada y luego se queja de todo.",
		"offer": "Tengo una pieza de repuesto. No te la doy ni te la niego: me abstengo.",
		"gift": "Toma, y si te preguntan, di que no te la di.",
		"battle": "Los Jubilados no votan nada y aun así tienen normas. Nosotros al menos las aprobamos.",
		"praise": "Tu elogio se agradece. Me abstengo de repetirlo para no gastarlo.",
	},
	{
		"ask": [
			"¿Llegasteis antes o después del colapso?",
			"¿Qué opinas de la Gran Emisión?",
			"¿Por qué no votasteis la señal?",
		],
		"fact": [
			"Llegamos antes que nadie. Consta en acta. Nadie ha encontrado el acta.",
			"La Gran Emisión la oímos primero y decidimos no votarla.",
			"Fue la decisión más responsable de la historia y también la menos votada.",
		],
		"payoff": [
			"El acta de búsqueda del acta también está en trámite.",
			"Los Grux y nosotros llegamos después del colapso, pero eso no lo votamos.",
		],
		"deflect": [
			"Esa pregunta la respondió una votación que no consta.",
			"De la Emisión no hablamos: se votó no oírla.",
		],
		"hot": "Decidir no votar la Gran Emisión y llamarlo responsabilidad es de una cara muy dura.",
		"offer": "Tengo una pieza de repuesto con la Emisión grabada. No la hemos votado.",
		"gift": "Toma, y escúchala bajito, que hay vecinos.",
		"battle": "Los Grux dicen que llegaron antes que nosotros. Eso se resuelve con papeleo o con palos.",
		"praise": "Se agradece. Y no hace falta votarlo, que ya lo has dicho tú.",
	},
]
