# -*- coding: utf-8 -*-
"""Banco de conversaciones de los Ecos de Vurm (P-42).

Fuente de lore: docs/50_lore.md (sección 2) y las líneas de data/world/species.json.
Las claves se usan así: ask/fact/payoff/deflect son líneas del tema; hot es la frase
que enfada; offer y gift son el regalo de pieza; battle prepara la pelea entre razas;
praise es la respuesta al elogio. Ver tools/gen_conversaciones.py.
"""

SPECIES = "eco"

GREETING = "Hola. ¿Oyes eso? Es tu propia voz rebotando."

OPENERS = [
	"Escucha.",
	"Te lo digo claro:",
	"Una cosa rápida.",
	"Te advierto que lo repito todo.",
	"Pregunta sincera:",
	"Sin rodeos:",
	"Atención, que esto suena.",
	"Deja que te cuente:",
	"Última cosa y te dejo.",
	"Y otra cosa:",
]

TOPICS = [
	{
		"ask": [
			"¿Sabes qué pasa aquí cuando no hay ruido?",
			"¿Te has fijado en que este sitio suena a nada?",
			"¿Por qué crees que no me acerco al Desguace de noche?",
		],
		"fact": [
			"Solo existimos mientras haya ruido. El silencio nos borra.",
			"En el Desguace de las Nueve, a partir de las nueve, no queda ni un sonido.",
			"Los Mudos dicen que exageramos, y lo dicen en voz muy baja.",
		],
		"payoff": [
			"El otro día calló un pájaro y perdí una mano. Luego volvió. No pregunto más.",
			"Por eso llamo a las puertas antes de entrar: si contesto yo, ya hay ruido.",
		],
		"deflect": [
			"Silencio. Y encima lo he pronunciado yo, que es peor.",
			"Nada, nada, nada. Mira, hasta la respuesta se ha ido.",
		],
		"hot": "El silencio no existe: es una excusa de los que no saben cantar.",
		"offer": "Tengo una pieza que suena al moverla. ¿Te la llevas?",
		"gift": "Toma, y no la sacudas cerca de mí.",
		"battle": "Si la Manada dejara de aullar en binario, dormiríamos todos mejor. ¿Empezamos?",
		"praise": "Eso ha sonado bien. Lo repito para que dure.",
	},
	{
		"ask": [
			"¿Sabes por qué repito tu última palabra antes de contestarte?",
			"¿Te molesta que repita lo que dices?",
			"¿Quieres saber la regla número uno de hablar con un Eco?",
		],
		"fact": [
			"Repetimos la última palabra que oímos. No es un tic, es dieta.",
			"Responder sin repetir se considera maleducado, y un poco caníbal.",
			"Se llama Responso del Eco: primero la palabra, luego la respuesta.",
		],
		"payoff": [
			"Un tribunal antiguo nos condenó a repetir; los Plegados lo archivan como testigo perpetuo.",
			"Si la última palabra fue un insulto, el insulto va primero y la cortesía después.",
		],
		"deflect": [
			"Pregunta. Pregunta. Ya está repetido, ya podemos hablar.",
			"Me lo has preguntado con una palabra muy rica. Me la quedo.",
		],
		"hot": "Repetir es de pobres de vocabulario. Yo solo tengo una voz y la gasto entera.",
		"offer": "Tengo una pieza de repuesto. Repuesto. ¿La quieres?",
		"gift": "Toma, y dile a alguien que te la dio. Se repetirá.",
		"battle": "La Manada no repite nada: solo ladra rutas. Eso no es conversación.",
		"praise": "Gracias. Gracias. Me ha gustado decirlo dos veces.",
	},
	{
		"ask": [
			"¿Has oído hablar de la Gran Emisión?",
			"¿Sabes de dónde salió la señal que nos dejó así?",
			"¿Te interesa la historia de la señal que nadie entendió?",
		],
		"fact": [
			"Encontramos una señal automática de una infraestructura antigua y la amplificamos.",
			"Creíamos que era un mensaje cósmico. Era más bien un aviso de mantenimiento.",
			"Los Jubilados intentaron arreglarlo con una actualización y lo empeoraron.",
		],
		"payoff": [
			"La señal sigue transmitiéndose en algún sitio. Yo la oigo los martes.",
			"Dentro de las grabaciones más viejas hay voces que no conocemos. Una de ellas tose.",
		],
		"deflect": [
			"De eso no hay grabación. Y yo soy la grabación.",
			"Lo preguntas como si yo hubiera estado. Estuve, pero no me acuerdo del final.",
		],
		"hot": "La Gran Emisión fue un chiste entre cuatro y vosotros lo habéis convertido en religión.",
		"offer": "Tengo una pieza con la señal grabada. No suena, pero vibra.",
		"gift": "Toma. Si la acercas a la oreja, oye a los Jubilados discutir.",
		"battle": "Los Jubilados nos metieron una actualización a mitad del concierto. Eso se paga.",
		"praise": "Qué bien lo has dicho. Voy a reemitirlo tal cual.",
	},
	{
		"ask": [
			"¿Sabes qué fue el Apocalipsis del Silencio?",
			"¿Quieres saber qué pasó cuando el sonido dejó de portarse bien?",
			"¿Te han contado lo de los Ecos que se quedaron a medias?",
		],
		"fact": [
			"La señal se propagó y hubo regiones donde el sonido desapareció.",
			"Algunos Ecos perdieron la forma. Otros quedaron repitiendo frases antiguas.",
			"Se les oye todavía en los túneles, siempre en mitad de una discusión.",
		],
		"payoff": [
			"Hay un túnel donde dos Ecos discuten desde hace cuarenta años y ya no saben de qué.",
			"El Niño del Último Suspiro sobrevivió callándose. Es la única leyenda que me da miedo.",
		],
		"deflect": [
			"Silencio, silencio... y encima lo pronuncio yo.",
			"De eso no hablo. Y mira que yo hablo de todo, dos veces.",
		],
		"hot": "El Apocalipsis del Silencio fue sabotaje de los que no hablan. Todos sabemos quiénes son.",
		"offer": "Tengo una pieza que salió de un túnel de esos. ¿La quieres?",
		"gift": "Toma, pero no la escuches de noche.",
		"battle": "Los Mudos nos acusan de exagerar y luego no dicen nada. Es su confesión.",
		"praise": "Bonito. Lo guardo para el karaoke del ocaso.",
	},
	{
		"ask": [
			"¿Vas a venir al karaoke del ocaso?",
			"¿Sabes qué hacemos los Ecos cuando cae la tarde?",
			"¿Te gusta cantar, o solo escuchar?",
		],
		"fact": [
			"Al caer la tarde cada Eco repite la mejor frase que ha oído ese día.",
			"Si dos repetimos la misma, hay duelo de volumen hasta que uno se queda ronco.",
			"En la Cámara de Resonancia ya ha derribado dos estalactitas y una urna ajena.",
		],
		"payoff": [
			"La urna era de un Plegado. La archivó como «daño acústico con acta pendiente».",
			"El ganador del año pasado cantó una frase de un Grux y la cobró el Grux. Dos veces.",
		],
		"deflect": [
			"Hoy no hay karaoke. Hoy hay resaca de karaoke.",
			"Canto fatal. Por eso aplaudo fuerte a los demás.",
		],
		"hot": "El karaoke del ocaso es una pérdida de tiempo y de tímpanos, y lo digo yo, que lo inventé.",
		"offer": "Tengo una pieza que hace de micrófono. No funciona, pero da presencia.",
		"gift": "Toma, canta bajito que se oye todo.",
		"battle": "La Manada aúlla en binario y encima desafina. Eso no se puede dejar pasar.",
		"praise": "Qué frase. La apunto para el duelo de esta tarde.",
	},
	{
		"ask": [
			"¿Conoces la liturgia del eslogan?",
			"¿Sabes qué hacemos con los anuncios de antes?",
			"¿Te suena «llame ya»?",
		],
		"fact": [
			"Los anuncios que sobrevivieron se consideran escritura sagrada.",
			"Recitarlos en orden se llama liturgia del eslogan, y tiene su ritmo.",
			"La más santa acaba en «llame ya». Nadie llama. La fe no admite devoluciones.",
		],
		"payoff": [
			"Un Amplificado se pasó once días recitando la liturgia entera y no perdió la voz: la ganó.",
			"Hay un Mohócrata que quiere votar el canon. Lleva catorce años en el primer verso.",
		],
		"deflect": [
			"Eso no está en el canon. Y si no está, no lo digo.",
			"No me sé esa parte. Me la salto con dignidad.",
		],
		"hot": "Los eslóganes son publicidad, no escritura. Rezad menos y hablad más.",
		"offer": "Tengo una pieza con un eslogan grabado. ¿La quieres oír?",
		"gift": "Toma. No la reproduzcas en la Cámara, que se llama a sí misma.",
		"battle": "Los Grux cobran por oír su propio eco. Eso sí que es una herejía con ticket.",
		"praise": "Amén, pero con ritmo.",
	},
	{
		"ask": [
			"¿Sabes cuál es la grabación más antigua que tenemos?",
			"¿Te han hablado de Vurm el Primero?",
			"¿Quieres oír el secreto mejor guardado de los Ecos?",
		],
		"fact": [
			"La grabación venerada de Vurm el Primero es, en realidad, un tono de línea ocupada.",
			"Tres eruditos lo saben. Los tres son Mudos y no pueden contarlo sin dejar de existir.",
			"Nosotros la reproducimos igual: ocupa, ocupa, ocupa.",
		],
		"payoff": [
			"Hubo un Eco que se pasó cuarenta años repitiendo «ocupado» y lo llamaron profeta.",
			"Si marcas un número antiguo, sigue sonando. Nadie sabe a quién pertenece la línea.",
		],
		"deflect": [
			"Eso es material sagrado. Y lo sagrado se repite, no se explica.",
			"No lo sé. Y lo que no sé lo repito igual, por educación.",
		],
		"hot": "Vurm el Primero nunca existió: era un tono de ocupado y vosotros le habéis puesto nombre.",
		"offer": "Tengo una pieza con aquel tono grabado. Ocupa, ocupa, ocupa.",
		"gift": "Toma, y no la escuches entera: son cuarenta años.",
		"battle": "Los Mudos saben la verdad y callan. Es una provocación con mucho silencio.",
		"praise": "Cuarenta años de tono y ahora resulta que era una alabanza. Gracias.",
	},
	{
		"ask": [
			"¿Sabes qué discuten los Mudos y los Amplificados?",
			"¿Te suena el pleito de la señal?",
			"¿Crees que deberíamos volver a amplificar la Gran Emisión?",
		],
		"fact": [
			"Los Amplificados llevan décadas pidiendo reamplificar la señal original.",
			"Los Mudos llevan las mismas décadas pidiendo un minuto de silencio.",
			"Las dos peticiones siguen en trámite, y el sello del trámite también.",
		],
		"payoff": [
			"El sello lleva en trámite tanto tiempo que ya hay una petición para pedir el sello.",
			"Un Amplificado y un Mudo se casaron para ahorrar trámites. Aún no han votado la boda.",
		],
		"deflect": [
			"Hay dos respuestas y las dos están en trámite.",
			"Pregunta al sello. El sello no habla, pero escucha muy bien.",
		],
		"hot": "Los Mudos son unos egoístas: quieren silencio para no tener que contestar.",
		"offer": "Tengo una pieza con la solicitud del sello. Pesa lo suyo.",
		"gift": "Toma, y preséntala tú, que yo ya no tengo paciencia.",
		"battle": "Los Mohócratas votan cada frase antes de decirla. Las nuestras, al menos, suenan.",
		"praise": "Eso merece un sello. En trámite, claro.",
	},
	{
		"ask": [
			"¿Has estado en el Cañón del Eco?",
			"¿Sabes que aquí se cobra por escuchar el eco?",
			"¿Cuánto pagarías por oírte a ti mismo?",
		],
		"fact": [
			"En el Cañón del Eco cobramos entrada por escuchar tu propio eco.",
			"Los Grux tasaron el eco en cero dientes y montaron un mercado de ecos de segunda mano.",
			"Nosotros consideramos eso canibalismo con ticket.",
		],
		"payoff": [
			"El mercado de segunda mano ya vende ecos de Ecos que aún están vivos. Eso sí es raro.",
			"Hay un puesto que alquila ecos por horas. El mío lo alquilaron un martes y volvió ronco.",
		],
		"deflect": [
			"Hoy el cañón está cerrado por exceso de público sonando.",
			"El eco no contesta a preguntas tan directas. Y menos gratis.",
		],
		"hot": "Cobrar por un eco es de ladrones; el eco es de quien lo grita.",
		"offer": "Tengo una pieza del cañón. Lleva un eco pegado dentro.",
		"gift": "Toma, pero si la golpeas te cobro la entrada.",
		"battle": "Los Grux venden nuestros ecos usados. Eso no se tasó, eso se robó.",
		"praise": "Bonito eco te has marcado. No te lo cobro.",
	},
	{
		"ask": [
			"¿Sabes que los Grux intentan cobrarnos el eco?",
			"¿Te cuento cómo se rinde un tasador?",
			"¿Quieres saber cómo ganamos a los Grux sin pelear?",
		],
		"fact": [
			"Un Grux intentó cobrarnos el eco: «de la caja, caja», decía.",
			"Le repetimos el recibo cuatrocientas veces. Se rindió en la doscientas.",
			"Desde entonces tasan el eco a la baja y con miedo.",
		],
		"payoff": [
			"El recibo repetido es la única arma que tenemos y no cuesta nada.",
			"Un tasador escribió en su libro: «cliente con eco, no apto». Le pusimos música.",
		],
		"deflect": [
			"No se puede cobrar lo que rebota. Es física, y también mala educación.",
			"De eso no hay factura. Bueno, sí, hay cuatrocientas.",
		],
		"hot": "Los Grux tienen razón: todo tiene precio, incluso el eco, y nosotros lo regalamos.",
		"offer": "Tengo una pieza que era de un Grux. Me la debía y se la cobré yo.",
		"gift": "Toma. No la tasen delante de mí, que me pongo a repetir.",
		"battle": "Los Grux nos robaron el eco y encima lo revendieron. Hasta aquí.",
		"praise": "Eso ha sido cortés y sin recibo. Se agradece.",
	},
	{
		"ask": [
			"¿Has oído la Emisión Conmemorativa Anual?",
			"¿Sabes qué pasa en la Cámara de Resonancia cada año?",
			"¿Te gustaría oír la Gran Emisión entera, de memoria?",
		],
		"fact": [
			"En la Cámara repetimos la Gran Emisión entera de memoria, y dura once días.",
			"La Manada del Polígono de Reparto la confunde con una orden y sale en estampida.",
			"El año pasado la Cámara se quedó sin paredes y el eco siguió solo.",
		],
		"payoff": [
			"Los Grux venden entradas para la estampida. La Manada cobra la taquilla sin saber.",
			"En el día nueve ya nadie recuerda la letra y todos cantan igual de convencidos.",
		],
		"deflect": [
			"La Emisión está en curso. Contesto cuando acabe, en once días.",
			"Lo siento, ahora estoy repitiendo el día octavo.",
		],
		"hot": "Once días de emisión es abuso: nadie aguanta a un vecino hablando tanto.",
		"offer": "Tengo una pieza de la Cámara. Vibra al pasar cerca de una estampida.",
		"gift": "Toma, y no la lleves al Polígono, que organizan una ruta.",
		"battle": "La Manada entra a golpes con el paquete en la Cámara. Es un atentado acústico.",
		"praise": "Eso lo repito en el día diez, palabra por palabra.",
	},
	{
		"ask": [
			"¿Sabes lo del Eco que repite «acta»?",
			"¿Has oído a alguien decir «acta» cuarenta años seguidos?",
			"¿Te suena el Valle de las Esquinas?",
		],
		"fact": [
			"Un Eco quedó atrapado repitiendo la última palabra de un Plegado: «acta».",
			"Lleva cuarenta años diciendo «acta». Los Archivistas lo consideran patrimonio.",
			"Pidió el alta y se la negaron por acta.",
		],
		"payoff": [
			"Es la mejor fuente histórica viva de la zona y no puede callarse ni para cobrar.",
			"Los Plegados le llevan preguntas con dos palabras para no alargar la respuesta.",
		],
		"deflect": [
			"Acta. Perdón, se me ha pegado del vecino.",
			"Ese tema está archivado. Y también repetido.",
		],
		"hot": "Dejar a un Eco repitiendo «acta» cuarenta años no es patrimonio: es crueldad.",
		"offer": "Tengo una pieza que dice «acta» si la aprietas. No preguntes.",
		"gift": "Toma, y no la aprietes dentro del Archivo.",
		"battle": "Los Plegados archivan personas y lo llaman patrimonio. Eso se contesta.",
		"praise": "Qué detalle. Lo repito cuarenta años, pero con cariño.",
	},
	{
		"ask": [
			"¿Sabes qué compramos en la Colmena Fúngica?",
			"¿Has negociado alguna vez con un Mohócrata?",
			"¿A qué crees que sabe una conversación fresca?",
		],
		"fact": [
			"En la Colmena negociamos conversación fresca a cambio de fertilizante.",
			"Los Mohócratas votan cada frase antes de decirla. Se nota en el sabor.",
			"Nosotros nos quejamos de que la frase «sabe a votación».",
		],
		"payoff": [
			"Una frase votada tres veces llega tibia y con acta. Las nuestras no llevan acta.",
			"El fertilizante de la Colmena es el único que nos sienta bien: abona la garganta.",
		],
		"deflect": [
			"Hoy no hay conversación fresca. Solo de ayer y recalentada.",
			"Sin fertilizante no hay charla. Es un pacto, no un capricho.",
		],
		"hot": "Los Mohócratas no conversan: aprueban. Una frase votada no es una frase.",
		"offer": "Tengo una pieza que huele a fertilizante. Es un decir.",
		"gift": "Toma, y no la voten antes de usarla.",
		"battle": "Los Mohócratas quieren votar quién habla en la Colmena. Eso ya es otra cosa.",
		"praise": "Esa frase estaba fresca. Se nota que no la han votado.",
	},
	{
		"ask": [
			"¿Sabes lo que hacemos los Ecos mientras dormimos?",
			"¿Te han dicho que repetimos anuncios en sueños?",
			"¿Quieres saber mi mayor vergüenza?",
		],
		"fact": [
			"En sueños recitamos anuncios de antes del colapso, completos y con entonación.",
			"Los más piadosos amanecen vendiendo yogur y pasan el día en modo susurro.",
			"El modo susurro es nuestro estado más débil: un círculo vicioso con colchón.",
		],
		"payoff": [
			"Hay un Eco que lleva despertando cuarenta años a mitad de una oferta de detergente.",
			"El anuncio de yogur es el más repetido y ya lo consideramos una oración.",
		],
		"deflect": [
			"No he dormido. Y lo que diga a partir de aquí es una oferta.",
			"De eso no hay grabación, aunque me consta que hay grabación.",
		],
		"hot": "Los anuncios dormidos son una tontería romántica; deberíamos dormir en silencio.",
		"offer": "Tengo una pieza que recita una oferta si la dejas en un colchón.",
		"gift": "Toma, y tápala, que por la noche vende cosas.",
		"battle": "Los Jubilados nos graban mientras dormimos y lo llaman archivo sonoro.",
		"praise": "Qué amable. Lo repetiré a las cuatro de la mañana, sin querer.",
	},
	{
		"ask": [
			"¿Sabes de dónde venimos los Ecos de este planeta?",
			"¿Te has preguntado por qué hay Ecos aquí, con la que hay fuera?",
			"¿Sabes qué nos trajo hasta este sitio?",
		],
		"fact": [
			"Las radios humanas nos atrajeron: sonaban solas, de noche, sin nadie delante.",
			"Vinimos por una voz y nos quedamos por la avería.",
			"Los humanos se extinguieron a mitad del chiste y nos dejaron el remate.",
		],
		"payoff": [
			"Una radio sigue encendida en algún sótano. Cuando se apague, iremos a ver qué era.",
			"Aquí había cuatro especies antes de nosotros. Los Grux y los Mohócratas llegaron después.",
		],
		"deflect": [
			"De eso no hay grabación limpia. Solo ruido de fondo, y el ruido es de ellos.",
			"No me acuerdo. Y si me acuerdo, no lo repito.",
		],
		"hot": "Los humanos eran ruido y nosotros somos lo que quedó de su voz. Nada más.",
		"offer": "Tengo una pieza que aún huele a radio caliente. ¿La quieres?",
		"gift": "Toma. Si zumba, es que está recordando.",
		"battle": "Los Grux tasaron las radios humanas como chatarra. Nos quitaron la cuna.",
		"praise": "Bonita frase. Casi parece de una radio.",
	},
]
