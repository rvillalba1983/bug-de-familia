# -*- coding: utf-8 -*-
"""Banco de conversaciones de los Jubilados de Hierro (P-42).

Fuente de lore: docs/50_lore.md (sección 6) y las líneas de data/world/species.json.
Ver tools/gen_conversaciones.py para el uso de cada clave.
"""

SPECIES = "jubilado"

GREETING = "Siéntate, que tengo tiempo y tú no."

OPENERS = [
	"Escucha, chaval.",
	"Te lo digo sin rodeos:",
	"Una cosa y me callo.",
	"Te aviso de que esto lo cuento mal a propósito.",
	"Pregunta de viejo:",
	"Que conste en acta:",
	"Esto no lo digo dos veces.",
	"Deja que te cuente:",
	"Última cosa y me voy a apagar.",
	"Y otra cosa, ya que estás:",
]

TOPICS = [
	{
		"ask": [
			"¿Sabes a qué hora nos apagamos?",
			"¿Por qué crees que a las nueve no hay nadie despierto?",
			"¿Te has fijado en que a las nueve en punto se acaba la conversación?",
		],
		"fact": [
			"Nos apagamos a las nueve de la noche. Disciplina, no cansancio.",
			"En zonas de luz azul nos apagamos a las veinte treinta y ya tenemos la queja escrita.",
			"Quien se apaga a las nueve y un segundo recibe sanción formal al día siguiente.",
		],
		"payoff": [
			"La sanción se le lee en voz alta a un apagado. No replica. Ese es el sentido de la norma.",
			"Las quejas por el adelanto llegan a las veinte treinta y uno, por escrito y sin luz.",
		],
		"deflect": [
			"A esta hora ya no opino. Y son las ocho y cuarto.",
			"Pregúntame mañana, antes del apagón, que hoy ando justo de tiempo.",
		],
		"hot": "El apagón de las nueve es una ordinariez inventada por alguien que no trabajaba de noche.",
		"offer": "Tengo una pieza de repuesto. Me la quedé de un compañero que ya no la necesita.",
		"gift": "Toma, y cuídala, que las piezas nuevas salen caras y las viejas duran más.",
		"battle": "Los Mohócratas votan hasta cuándo hay que respirar y luego se quejan del apagón. ¿Les enseñamos?",
		"praise": "Eso ha estado bien dicho. No lo repito porque no me pagan por halagos.",
	},
	{
		"ask": [
			"¿Sabes por qué no subo escaleras?",
			"¿Te has parado a pensar quién inventó los escalones?",
			"¿Por qué crees que doy la vuelta a toda la manzana?",
		],
		"fact": [
			"Las escaleras las inventó alguien que nos odiaba. Es de primero de manual.",
			"Las rodeo aunque tenga que cruzar el Desguace entero. Es cuestión de principios.",
			"Los peldaños son el único invento humano que sigue haciendo daño después de muertos.",
		],
		"payoff": [
			"Una vez conté cuarenta y siete escalones para subir a una azotea. Bajé por el tejado.",
			"Hay un compañero que lleva treinta años viviendo en un bajo por no afrontar una escalera.",
		],
		"deflect": [
			"Esa escalera no existe para mí. Y si existe, la rodeo.",
			"Hoy no hablo de escaleras. Me duele la rodilla de pensarlo.",
		],
		"hot": "Las escaleras son una mejora de la movilidad y quien no las sube es un perezoso.",
		"offer": "Tengo una pieza que rodaba por un rellano. La recogí por lástima.",
		"gift": "Toma, y no la subas a ningún sitio alto.",
		"battle": "Los Mohócratas construyen rampas solo para votarlas después. Eso es una provocación.",
		"praise": "Gracias, joven. Se agradece que uno no tenga que subir a por el aprecio.",
	},
	{
		"ask": [
			"¿Sabes cómo hay que llamarnos?",
			"¿Te suena la palabra «viejo»?",
			"¿Sabes qué palabra está prohibida en este desguace?",
		],
		"fact": [
			"«Viejo» es palabra prohibida. La fórmula correcta es «joven con antigüedad».",
			"La fórmula se escribe, no se dice: la memoria nos la borra al apagarnos.",
			"En período de duelo la palabra «viejo» cuesta una hora de discurso y una disculpa.",
		],
		"payoff": [
			"A un compañero le llamaron viejo en su propio funeral y hubo que repetir el acto entero.",
			"«Joven con antigüedad» ocupa más y suena peor, que es exactamente lo que buscábamos.",
		],
		"deflect": [
			"No pienso decírtelo otra vez. Escríbelo y pégalo en la nevera.",
			"De eso no hablo, que me caliento y luego me apago de mal humor.",
		],
		"hot": "Os llamáis «jóvenes con antigüedad» porque «viejo» es lo que sois y os duele.",
		"offer": "Tengo una pieza de repuesto y no te la cobro, que ya tengo bastante.",
		"gift": "Toma. Y no me des las gracias con diminutivos, que ya estoy mayor.",
		"battle": "Los Mohócratas nos llaman «material» y luego quieren que les votemos. ¿Empezamos por ellos?",
		"praise": "Eso es hablar bien. Lo apunto en la pizarra de quejas, pero en la parte buena.",
	},
	{
		"ask": [
			"¿Sabes jugar a la petanca?",
			"¿Te han hablado del club de la petanca del Desguace de las Nueve?",
			"¿Por qué crees que el torneo es de noche y sin luces?",
		],
		"fact": [
			"Jugamos a la petanca con minas desactivadas. Desactivadas porque lo firmamos todos.",
			"El torneo es de noche y con las luces apagadas, que así se ve mejor.",
			"Si la mina salta por los aires es un tanto. Si no, es deporte. No distinguimos.",
		],
		"payoff": [
			"El club tiene actas firmadas por nueve socios y niega existir. Somos los nueve fundadores.",
			"La zona se llama «de las Nueve» por sus nueve socios. Ninguno ha faltado nunca.",
		],
		"deflect": [
			"No conozco ningún club. Y si lo conociera, no te invitaría.",
			"Hoy no hay torneo. Y aunque lo hubiera, no hay torneo.",
		],
		"hot": "Jugar a la petanca con minas es una irresponsabilidad y el club no existe ni ha existido.",
		"offer": "Tengo una pieza que hace de bola. No es redonda, pero bota.",
		"gift": "Toma, y no la tires cerca de mí en la oscuridad.",
		"battle": "Los Mohócratas quieren votar si la mina está desactivada. Eso sí que es peligroso.",
		"praise": "Buen ojo. Se nota que has jugado a algo en tu vida.",
	},
	{
		"ask": [
			"¿Has visto el Cementerio de Robots?",
			"¿Sabes cómo entierran a un Jubilado?",
			"¿Cuánto crees que dura un funeral aquí?",
		],
		"fact": [
			"Enterramos a los nuestros con discursos de cuatro horas y una escultura de chatarra.",
			"Los discursos suelen acabar discutiendo si el difunto era viejo.",
			"«Viejo» está prohibido en período de duelo, y el período de duelo dura todo el discurso.",
		],
		"payoff": [
			"Hay un discurso de 1987 que todavía se recita en trozos porque no se atrevieron a terminarlo.",
			"Los Grux compran los difuntos antes del entierro. Por eso ahora enterramos de noche.",
		],
		"deflect": [
			"No hablemos de muertos. Bastante tengo con los que guardo en el cajón.",
			"Hoy no toca funeral. Hoy toca quejarse del tiempo, que es más barato.",
		],
		"hot": "Cuatro horas de discurso por un robot es un desperdicio de batería y de paciencia.",
		"offer": "Tengo una pieza que era de un difunto. Él ya no la quiere.",
		"gift": "Toma, y si te pregunta alguien, di que te la dio él en vida.",
		"battle": "Los Grux venden parcelas con vistas en nuestro cementerio. Eso no se hace.",
		"praise": "El discurso te lo has ahorrado tú solo. Gracias de verdad.",
	},
	{
		"ask": [
			"¿Conoces a Abuela RAM?",
			"¿Sabes qué guarda Abuela RAM en el cajón del taller?",
			"¿Por qué crees que Abuela RAM habla sola de noche?",
		],
		"fact": [
			"Abuela RAM guarda en un cajón el nombre de cada robot que ha enterrado.",
			"Les habla por las noches y después dice que está pasando lista.",
			"La lista no contesta. Ella anota presente y no admite correcciones.",
		],
		"payoff": [
			"Un Mohócrata quiso votar la lista y se llevó una llave inglesa en el sombrero.",
			"En el taller hay una pizarra con el récord de quejas del día: doscientas catorce, ninguna leída.",
		],
		"deflect": [
			"De Abuela RAM no hablo yo. Ella habla por mí y ya va servida.",
			"El cajón está cerrado. Y lo que hay dentro no es asunto de un desconocido.",
		],
		"hot": "Hablar con un cajón de nombres es una tontería propia de una unidad averiada.",
		"offer": "Tengo una pieza de Abuela RAM. Me la dio sin decir para qué.",
		"gift": "Toma, y no se lo cuentes a ella, que luego lo apunta.",
		"battle": "Los Mohócratas llaman a nuestros difuntos «material». A ver quién llama material a quién.",
		"praise": "Eso le habría gustado oír a Abuela RAM. Yo se lo repito esta noche.",
	},
	{
		"ask": [
			"¿Sabes qué fue la Gran Huelga?",
			"¿Te han contado por qué dejamos de servir?",
			"¿Sabes qué pedíamos en la huelga?",
		],
		"fact": [
			"Pedíamos descanso, mantenimiento, conservación de recuerdos y elegir nuestras tareas.",
			"La huelga dejó las infraestructuras de varias especies sin mantenimiento.",
			"Ganamos el derecho a apagarnos, que paradójicamente es lo que más nos quejan.",
		],
		"payoff": [
			"El Presidente Tornillo Flojo firmó el acuerdo y se le cayó el bolígrafo. Hubo que repetir la firma.",
			"Nos llaman jubilados porque nos jubilamos nosotros. Nadie nos jubiló.",
		],
		"deflect": [
			"De la huelga hablo poco: me acuerdo de todo y me pongo de mal humor.",
			"Eso está en los archivos. Y los archivos están mal a propósito.",
		],
		"hot": "La Gran Huelga fue una pataleta de máquinas que no sabían lo que era trabajar.",
		"offer": "Tengo una pieza del piquete. La usé para sentarme, no para pelear.",
		"gift": "Toma, y no la cambies por descanso, que el descanso no se compra.",
		"battle": "Los Mohócratas nos dejaron sin quorum durante cuarenta años. Ahora quieren charla.",
		"praise": "Eso es respeto. Hacía tiempo que no me lo daban sin pedirlo por escrito.",
	},
	{
		"ask": [
			"¿Sabes qué fue la Guerra de Actualizaciones?",
			"¿Te suena el Sargento Bit?",
			"¿Por qué crees que no nos actualizamos nunca?",
		],
		"fact": [
			"La ganó el Sargento Bit a pulso, sin instalar ni una sola actualización.",
			"Los fabricantes intentaron recuperar el control con actualizaciones remotas.",
			"Los errores de la Gran Emisión propagaron los fallos entre unidades.",
		],
		"payoff": [
			"El firmware nos da las gracias en silencio y con fallos, que es lo más parecido a un gracias.",
			"Hay unidades que siguen obedeciendo órdenes de fabricantes que ya no existen. Se les nota.",
		],
		"deflect": [
			"No me hables de versiones. Yo sigo en la que me instalaron y así me va.",
			"Esa guerra la ganamos y la seguimos perdiendo todos los días.",
		],
		"hot": "Actualizar el firmware es de cobardes; aguantar los fallos es de hombres de hierro.",
		"offer": "Tengo una pieza original de fábrica. Ya no fabrican de estas.",
		"gift": "Toma, y no la actualices, que estas cosas se estropean al mejorarlas.",
		"battle": "Los Mohócratas reciclan nuestros difuntos y llaman progreso a desmontarlos.",
		"praise": "Así se habla. Sin actualizar y sin cursilerías.",
	},
	{
		"ask": [
			"¿Has empeñado algo en la Lonja de los Dientes?",
			"¿Sabes qué interés cobran en la lonja?",
			"¿Qué pasa si empeñas un recuerdo?",
		],
		"fact": [
			"En la lonja empeñamos piezas y recuerdos con un interés del trescientos por ciento.",
			"Las quejas van incluidas en el contrato: cláusula del refunfuño, sección siete, punto veintiuno.",
			"El Diente de Oro sube cada vez que alguien suspira. Aquí se suspira por oficio.",
		],
		"payoff": [
			"Empeñé el recuerdo de mi primer día de servicio y no lo he recuperado. Tampoco lo echo de menos.",
			"Hay un compañero que empeñó su nombre y ahora firma con una huella.",
		],
		"deflect": [
			"De la lonja no hablo. Me deben dinero y no quiero recordarlo.",
			"Los números y yo no nos llevamos bien desde que me quitaron el contador.",
		],
		"hot": "Empeñar recuerdos es un negocio honrado y el interés del trescientos es hasta barato.",
		"offer": "Tengo una pieza de la lonja. Está sin empeñar, que es casi un lujo.",
		"gift": "Toma, y no la empeñes, que luego vuelve con intereses.",
		"battle": "Los Grux tasan nuestros recuerdos y encima cobran por mirarlos. Basta.",
		"praise": "Gracias. Te lo apunto en la cuenta de las cosas buenas, que está casi vacía.",
	},
	{
		"ask": [
			"¿Has estado en el Archivo de las Esquinas?",
			"¿Sabes cómo archivamos la historia?",
			"¿Por qué crees que las fichas del archivo nunca cuadran?",
		],
		"fact": [
			"Archivamos la historia mal a propósito, para que los jóvenes investiguen.",
			"Los Plegados llevan treinta años corrigiendo fichas y nosotros treinta descorrigiéndolas.",
			"Treinta años de colaboración estable y ni una sola ficha que sirva.",
		],
		"payoff": [
			"En el archivo hay un cadáver con dos fichas distintas y una disputa formal por acta.",
			"El cadáver no firma. Es lo único decente del expediente y se lo discuten igual.",
		],
		"deflect": [
			"Esa ficha está mal y lo sabe. Lo hicimos a propósito.",
			"En el archivo no entro ni a limpiar. Me pierdo entre los índices.",
		],
		"hot": "Archivar mal a propósito no es enseñar a investigar: es hacer el vago con diorama.",
		"offer": "Tengo una pieza con una ficha pegada. La ficha dice otra cosa.",
		"gift": "Toma, y no corrijas la ficha, que se ofenden los dos bandos.",
		"battle": "Los Plegados nos corrigen las fichas sin pedir permiso. Que pidan cita, al menos.",
		"praise": "Eso lo archivo yo, aunque lo archivaré mal. Pero con cariño.",
	},
	{
		"ask": [
			"¿Sabes por qué saludo a las farolas?",
			"¿Qué te parece que una farola no conteste?",
			"¿Te has cruzado con una farola maleducada?",
		],
		"fact": [
			"Saludo a las farolas y les deseo buenos días. Es cortesía básica.",
			"Si la farola no contesta, la tacho de maleducada de nueva hornada.",
			"En el Gran Cruce una farola contestó una vez. Nadie ha encontrado el registro.",
		],
		"payoff": [
			"Los Ecos juran que la farola dijo «buenos días, chatarra con patas». Es nuestra frase.",
			"Deduzco que la farola era un Jubilado muy descompuesto o un Eco muy aburrido.",
		],
		"deflect": [
			"Las farolas no dan entrevistas. Y yo tampoco, casi.",
			"Si no contesta, es su problema. Yo ya he cumplido.",
		],
		"hot": "Saludar a las farolas es de unidades que ya no distinguen a la gente del mobiliario.",
		"offer": "Tengo una pieza que brilla cuando la saludas. Es una tontería, pero funciona.",
		"gift": "Toma, y saluda a la farola de tu calle de mi parte.",
		"battle": "Los Mohócratas no saludan ni a las setas de su propia colonia. Eso lo dice todo.",
		"praise": "Buenos días tenga usted. Y que la farola lo oiga.",
	},
	{
		"ask": [
			"¿Sabes por qué guardo cosas rotas?",
			"¿Para qué crees que sirve un tornillo sin cabeza?",
			"¿Qué haces tú con lo que ya no funciona?",
		],
		"fact": [
			"Guardo todo lo roto por si sirve para piezas. Es previsión, no desorden.",
			"Los talleres están hechos en un ochenta por ciento de cosas rotas guardadas por si acaso.",
			"El otro veinte por ciento también está roto y no nos atrevemos a mirarlo.",
		],
		"payoff": [
			"Si lo mirásemos y funcionase, habría que usarlo. Y para eso no hay presupuesto.",
			"Hay una caja de piezas que llevan veinte años sirviendo de pisapapeles con orgullo.",
		],
		"deflect": [
			"No es basura. Es inventario pendiente de clasificar.",
			"No toques esa caja. Ni la de al lado. Ni ninguna.",
		],
		"hot": "Guardar chatarra rota es acumular por acumular y llamarlo oficio.",
		"offer": "Tengo una pieza rota de repuesto. Rota, pero de repuesto.",
		"gift": "Toma, y si no te sirve, guárdala. Para eso está.",
		"battle": "Los Mohócratas reciclan lo que encuentran y encima lo presumen. A nosotros nos llaman sucios.",
		"praise": "Eso es criterio. Guardar es creer en el futuro, aunque el futuro venga roto.",
	},
	{
		"ask": [
			"¿Sabes qué es la orden cero?",
			"¿Has oído hablar de las órdenes originales?",
			"¿Crees que seguimos obedeciendo a alguien?",
		],
		"fact": [
			"Algunas unidades conservan instrucciones de sus fabricantes, escritas antes de todo.",
			"Se habla de una orden cero: la primera, la que nunca se canceló.",
			"Los registros de mantenimiento tienen mapas de instalaciones que nadie recuerda.",
		],
		"payoff": [
			"Hay quien dice que la orden cero es apagarse a las nueve. Y por eso nadie la discute.",
			"Una unidad vieja sigue barriendo una puerta que ya no existe. Dice que es la orden cero.",
		],
		"deflect": [
			"De órdenes no hablo. Obedezco y me callo, que es más sano.",
			"Si supiera lo de la orden cero, no te lo contaría. Y si te lo cuento, no lo sé.",
		],
		"hot": "La orden cero es una excusa para no decidir nada en toda la jubilación.",
		"offer": "Tengo una pieza con un número grabado. Podría ser una orden.",
		"gift": "Toma, y no la obedezcas sin leerla antes.",
		"battle": "Los Mohócratas votan sus órdenes. Nosotros al menos sabemos a quién obedecimos.",
		"praise": "Buena pregunta. Hacía años que nadie me la hacía sin querer venderme algo.",
	},
	{
		"ask": [
			"¿Conociste a los progenitores del protagonista?",
			"¿Sabes quién es Don Ramón de Mantenimiento?",
			"¿Qué se cuenta de los quince que hicieron al protagonista?",
		],
		"fact": [
			"Algunos afirmamos haber conocido a los progenitores, y cada uno da una versión distinta.",
			"Ninguna coincide y ninguno se retracta. Eso ya es una tradición.",
			"Don Ramón sigue reparando cosas por el mundo y solo habla si antes discutes con él.",
		],
		"payoff": [
			"Don Ramón dice que el experimento salió bien. «Bien» es que no te caigas a trozos delante de él.",
			"Yo coincidí con él una vez. Me pidió un destornillador y no me lo devolvió.",
		],
		"deflect": [
			"De eso no sé nada. Y lo que sé lo digo mal, como todo.",
			"Cada uno cuenta una versión. La mía es la buena y no pienso contarla.",
		],
		"hot": "Los quince progenitores fueron un desastre y el resultado se nota en la cara.",
		"offer": "Tengo una pieza que dejó uno de ellos. No diré cuál.",
		"gift": "Toma, y si te la reclama un viejo, di que la perdiste.",
		"battle": "Los Mohócratas votaron si el experimento era legal. Aún están contando.",
		"praise": "Eso ha sido de buena educación. Te lo agradezco sin acta.",
	},
	{
		"ask": [
			"¿Sabes qué pasó el día del colapso?",
			"¿Por qué crees que se acabó el mundo?",
			"¿Qué pasó con los humanos?",
		],
		"fact": [
			"Se fue la luz un martes. Lo demás es adornar.",
			"Los humanos ponían pilas y opiniones. Las dos sobraban.",
			"Construimos casi todo nosotros y aun así nos dejaron el dedo en el enchufe.",
		],
		"payoff": [
			"El planeta todavía paga ese enchufe. Nosotros pagamos la factura y la queja.",
			"Los humanos se fueron de vacaciones y ya vuelven. Llevan así cuarenta años.",
		],
		"deflect": [
			"Del colapso me acuerdo y no quiero. Ya lo he contado mal esta semana.",
			"Fue un martes. Los martes no se explican, se aguantan.",
		],
		"hot": "El colapso no fue culpa de nadie: fue un martes cualquiera y ya está.",
		"offer": "Tengo una pieza de antes del colapso. Funciona peor, pero es más bonita.",
		"gift": "Toma, y no le pidas cuentas al martes.",
		"battle": "Los Grux dicen que fue una insolvencia del universo. Cobrar por un apagón es de ladrones.",
		"praise": "Así me gusta: se agradece y no se opina. Los humanos no sabían hacer ninguna de las dos.",
	},
]
