# -*- coding: utf-8 -*-
"""Banco de conversaciones de los Tasadores Grux (P-42).

Fuente de lore: docs/50_lore.md (sección 4) y las líneas de data/world/species.json.
Ver tools/gen_conversaciones.py para el uso de cada clave.
"""

SPECIES = "grux"

GREETING = "Grrr... ¿qué quieres, carne?"

OPENERS = [
	"Escucha, que el tiempo se cobra:",
	"Te lo digo al contado:",
	"Una tasación rápida:",
	"Sin letra pequeña, que la cobro aparte:",
	"Pregunta con recibo:",
	"Que conste en el libro:",
	"Cuatro brazos, una pregunta:",
	"Te informo del precio de saberlo:",
	"Última oferta del día:",
	"Y un extra, sin recargo:",
]

TOPICS = [
	{
		"ask": [
			"¿Sabes qué es el Diente de Oro?",
			"¿Cómo va la lonja hoy?",
			"¿Por qué suspiráis tanto en la Lonja de los Dientes?",
		],
		"fact": [
			"En la Lonja de los Dientes cotizamos los dientes en bolsa.",
			"El Diente de Oro sube cada vez que alguien suspira. Un gemido rinde más que una jornada.",
			"En la lonja se gime a propósito y a eso lo llamamos oficio.",
		],
		"payoff": [
			"Hay un tasador que se pasa el día suspirando y cobra por el suspiro y por la tasación.",
			"El índice subió tanto un martes que hubo que abrir la lonja de noche para gemir.",
		],
		"deflect": [
			"El Diente de Oro está cerrado al público. Y al improductivo.",
			"Eso vale una consulta y la consulta vale dos dientes.",
		],
		"hot": "El Diente de Oro es una fantasía que se sostiene con suspiros de gente sin dientes.",
		"offer": "Tengo una pieza de repuesto. Está cotizada y no pienso rebajarla.",
		"gift": "Toma, y no la empeñes en la lonja, que te la tasan a la baja.",
		"battle": "Los Plegados archivan nuestras tasaciones como ofensas. Eso cuesta y se cobra.",
		"praise": "Buen cumplido. Lo taso en un diente y me lo quedo.",
	},
	{
		"ask": [
			"¿Sabes para qué sirve el estómago-bolsillo?",
			"¿Dónde guardas lo que cobras?",
			"¿Es verdad que tragais lo que robáis?",
		],
		"fact": [
			"El estómago-bolsillo es una caja fuerte con digestión.",
			"Tragamos lo que cobramos y lo sacamos cuando hace falta dar cambio.",
			"Ahí dentro cabe un archivo portátil entero y algún cliente pequeño.",
		],
		"payoff": [
			"Una vez se me quedó un recibo dentro tres años y salió con intereses.",
			"Hay quien dice que nuestro estómago es un buzón. Los Ecos nos dejan cartas.",
		],
		"deflect": [
			"Ahí dentro no hay nada. Y lo que hay no es tuyo.",
			"El inventario del bolsillo es confidencial y huele a beneficio.",
		],
		"hot": "El estómago-bolsillo es un truco de feria para no pagar almacén.",
		"offer": "Tengo una pieza de repuesto en el bolsillo. Salió caliente.",
		"gift": "Toma, y no la tragues, que luego la cobro por recuperación.",
		"battle": "Los Plegados dicen que nuestro estómago es un archivo robado. Eso es difamación con ficha.",
		"praise": "Elogio registrado. Se agradece en especie o en dientes.",
	},
	{
		"ask": [
			"¿Qué es el Tributo del Aire?",
			"¿Cobráis por respirar?",
			"¿Por qué hay una lista de precios por litro de aire?",
		],
		"fact": [
			"En cualquier estancia cerrada, el primero que respira tasa el aire y lo reparte por tramos.",
			"En el Gran Mercado hay lista de precios por litro respirado.",
			"Quien no paga, aguanta. Es su huelga y la pierde por asfixia.",
		],
		"payoff": [
			"Hay un cliente que lleva tres años pagando el tramo alto por no discutir.",
			"El aire de las escaleras se cobra aparte por ser cuesta arriba.",
		],
		"deflect": [
			"Respira bajito, que el tramo barato se acaba.",
			"El aire está en oferta hoy. La oferta también se cobra.",
		],
		"hot": "Cobrar el aire es una estafa con tabla de precios.",
		"offer": "Tengo una pieza de repuesto que ventila. Se cobra el uso.",
		"gift": "Toma, y respira por la nariz, que sale más barato.",
		"battle": "Los Jubilados no pagan el aire y encima se apagan. así no hay negocio.",
		"praise": "Buena respiración. Se le aplica la tarifa de cliente educado.",
	},
	{
		"ask": [
			"¿Qué es el Bautizo del Diente?",
			"¿Por qué le ponéis nombre al primer diente?",
			"¿Un diente puede tener apellidos?",
		],
		"fact": [
			"El primer diente cobrado se nombra, se asegura y se presenta en sociedad.",
			"Los dientes heredados heredan también el nombre.",
			"Hay dientes con genealogía más larga que las familias.",
		],
		"payoff": [
			"Hay un diente que ya va por la decimocuarta generación y sigue cobrando intereses.",
			"Al bautizo se invita a los deudores para que vean lo que se pierde.",
		],
		"deflect": [
			"Los nombres de los dientes no se dan gratis. El mío tampoco.",
			"Ese diente está en sociedad y no concede entrevistas.",
		],
		"hot": "Poner nombre a un diente es una cursilería que no aumenta su valor.",
		"offer": "Tengo una pieza de repuesto de un diente con nombre. Está de luto.",
		"gift": "Toma, y ponle nombre, que sin nombre no cotiza.",
		"battle": "Los Plegados archivan nuestros dientes como «objetos sin ficha». Pues que paguen la ficha.",
		"praise": "Elogio con nombre y apellidos. Se agradece y se asegura.",
	},
	{
		"ask": [
			"¿Cuánto cuesta una frase retórica?",
			"¿Cobráis por hablar?",
			"¿Cuánto vale tu silencio?",
		],
		"fact": [
			"Cobramos por las frases retóricas: una pregunta de ese tipo son un diente.",
			"La respuesta son dos y el silencio son tres.",
			"El silencio es el producto estrella y lo pagas tú sin abrir la boca.",
		],
		"payoff": [
			"Hay clientes que pagan el silencio por adelantado y se van sin hablar. Los mejores.",
			"Un cliente pidió descuento por callarse dos veces. Se le cobró el descuento.",
		],
		"deflect": [
			"Esa pregunta es retórica. Un diente. Gracias.",
			"Si sigues hablando, sube el recibo. Tú mismo.",
		],
		"hot": "Cobrar por el silencio es el negocio más limpio que existe: no das nada y cobras.",
		"offer": "Tengo una pieza de repuesto. Callarme sobre su origen cuesta dos dientes.",
		"gift": "Toma, y el silencio sobre el regalo va incluido.",
		"battle": "Los Ecos repiten nuestras frases sin pagar derechos. Eso es copia y se cobra.",
		"praise": "Ese elogio es gratis. El siguiente ya lleva recargo.",
	},
	{
		"ask": [
			"¿Qué fue la Gran Burbuja de los Dientes?",
			"¿Se pueden hipotecar dientes futuros?",
			"¿Por qué quebró el mercado de dientes?",
		],
		"fact": [
			"Los dientes se convirtieron en activo financiero y se prestó contra dientes futuros.",
			"También se prestó contra dientes heredados y dientes aún no desarrollados.",
			"La burbuja estalló y provocó una crisis económica generalizada.",
		],
		"payoff": [
			"Hay un contrato que grava el diente de un niño que todavía no ha nacido. Ni familia tiene.",
			"El Estado rescató la burbuja comprando dientes con dientes. Funcionó, no preguntes.",
		],
		"deflect": [
			"De la burbuja no hablo: me quedé con tres dientes y una hipoteca.",
			"Esa deuda está en reestructuración. Como todo lo que respiro.",
		],
		"hot": "La burbuja de los dientes fue un fraude y los que la hicieron siguen cobrando.",
		"offer": "Tengo una pieza de repuesto. Estaba hipotecada y la rescaté.",
		"gift": "Toma, y no la pongas de garantía, que ya tiene dueño.",
		"battle": "Los Plegados nos culparon de la burbuja y luego pidieron un préstamo. Cinismo con ficha.",
		"praise": "Elogio sin burbuja. Se agradece y se guarda en efectivo.",
	},
	{
		"ask": [
			"¿Qué fue el Apocalipsis de la Deuda?",
			"¿Puede uno deber dinero a alguien que no existe?",
			"¿Por qué hay deudas anteriores a los deudores?",
		],
		"fact": [
			"El sistema dejó de distinguir deudas reales, heredadas y errores administrativos.",
			"Muchos descubrieron que debían cantidades imposibles a entidades que ya no existían.",
			"Existen deudas anteriores a la existencia de sus deudores.",
		],
		"payoff": [
			"La deuda más antigua nos la debemos a nosotros mismos por servicios futuros ya prestados.",
			"Hay un deudor que paga religiosamente a una oficina cerrada desde antes del colapso.",
		],
		"deflect": [
			"Su deuda está en el libro. No le digo la página porque la página se cobra.",
			"Todo el mundo debe algo. Usted también, y no lo sabe.",
		],
		"hot": "Las deudas anteriores al deudor son una estafa y el libro es una novela.",
		"offer": "Tengo una pieza de repuesto libre de cargas. Es casi un milagro.",
		"gift": "Toma, y firme aquí: es un regalo con hipoteca afectiva.",
		"battle": "Los Plegados dicen que las deudas no existen si no están archivadas. Pues que las paguen.",
		"praise": "Elogio sin intereses. No se preocupe, ya los cobraré en otra cosa.",
	},
	{
		"ask": [
			"¿Quién es el Gran Tasador?",
			"¿Es verdad que tasó un planeta en tres dientes?",
			"¿Cuánto vale un planeta?",
		],
		"fact": [
			"El Gran Tasador valoró un planeta entero en tres dientes y nadie se atrevió a replicar.",
			"Estaba de mal humor, y aun así la tasación es oficial.",
			"Ese planeta es el más barato del universo y nunca se ha vendido.",
		],
		"payoff": [
			"A ese precio parece trampa. Lo es. Nadie regatea con quien tasa mundos.",
			"Hay una copia de la tasación enmarcada en la lonja y otra en la cárcel.",
		],
		"deflect": [
			"La tasación del planeta es vinculante y no admite preguntas.",
			"Tres dientes. Ni uno más. Y el porte, aparte.",
		],
		"hot": "Tasar un planeta en tres dientes es el mayor chiste de la historia del comercio.",
		"offer": "Tengo una pieza de repuesto de aquel planeta. Pesa como un mundo.",
		"gift": "Toma, y no la tasen, que la devalúan.",
		"battle": "Los Plegados tasaron nuestro catálogo en cero y luego se ofenden. Empecemos por el cero.",
		"praise": "Buen ojo. Le taso el elogio en dos dientes y se lo devuelvo.",
	},
	{
		"ask": [
			"¿Qué se paga en el Camino de los Dientes?",
			"¿Por qué hay tres peajes en el mismo camino?",
			"¿Se cobra también el arcén?",
		],
		"fact": [
			"En el Camino de los Dientes cobramos peaje por el camino, por el arcén y por la idea de camino.",
			"El peaje se paga al entrar, al salir y al pensarlo dos veces.",
			"El recibo del peaje incluye una tasa por el recibo.",
		],
		"payoff": [
			"Hay quien ha pagado el peaje y se ha quedado a vivir en la caseta por no pagar la vuelta.",
			"El camino es de tierra. La tierra también se cobra, pero barato.",
		],
		"deflect": [
			"El peaje es obligatorio. El camino, opcional.",
			"Si no quiere pagar, hay una ruta alternativa de pago.",
		],
		"hot": "Cobrar por la idea de camino es de ladrones con caseta.",
		"offer": "Tengo una pieza de repuesto del peaje. Va sin tasa.",
		"gift": "Toma, y no la saque del camino, que se cobra la salida.",
		"battle": "Los Plegados cobran el uso de esquinas ajenas en nuestro camino. Eso es competencia desleal.",
		"praise": "Cliente educado. Se le perdona la tasa de sonrisa.",
	},
	{
		"ask": [
			"¿Cuánto vale mi cabeza?",
			"¿Me has tasado ya?",
			"¿Por qué el perito cobra por mirarme?",
		],
		"fact": [
			"Su cabeza está tasada en cero dientes y el perito cobra plus por haberla mirado.",
			"El pelo está sin peritar y es mejor así.",
			"El futuro está a la baja y sin pujas. Lote sin valor: ni de broma se lo queda nadie.",
		],
		"payoff": [
			"Su tasación ya está en el libro con una nota: «cliente reincidente en valer poco».",
			"Un cliente se ofendió por la tasación y pagó dos dientes por la queja. Salió ganando el libro.",
		],
		"deflect": [
			"Su tasación es confidencial. Y mala.",
			"Le tasaría otra vez, pero me cuesta mirar y eso se cobra.",
		],
		"hot": "Tasar a un cliente sin avisar es una falta de respeto con plus.",
		"offer": "Tengo una pieza de repuesto que vale más que usted. Sin ánimo de ofender.",
		"gift": "Toma, y no se la cobre a sí mismo, que se devalúa.",
		"battle": "Los Plegados nos tasaron en cero y ahora se quejan de la tasación. Que se miren.",
		"praise": "Su elogio vale más que su cabeza. Tampoco es difícil.",
	},
	{
		"ask": [
			"¿Por qué no oléis a azufre?",
			"¿Qué pasa si te ofendo?",
			"¿Dónde está lo que robaste?",
		],
		"fact": [
			"Si huelo azufre, vomito lo robado. Por eso no olemos azufre.",
			"El estómago devuelve lo ajeno en cuanto el aire se pone feo.",
			"Hay quien lleva un huevo podrido en el bolsillo para negociar con nosotros.",
		],
		"payoff": [
			"Un cliente listo nos hizo devolver un cargamento entero con una cerilla y un calcetín.",
			"Desde entonces el azufre está prohibido en la lonja por motivos de inventario.",
		],
		"deflect": [
			"Aquí no huele a nada. Y lo que huele es de otro.",
			"Esa pregunta huele mal. No siga.",
		],
		"hot": "Vomitar lo robado con el azufre demuestra que el negocio es un robo.",
		"offer": "Tengo una pieza de repuesto. La devolví y la volví a cobrar.",
		"gift": "Toma, y no la acerque al azufre, que la devuelvo y se la cobro otra vez.",
		"battle": "Los Ecos repiten nuestro recibo hasta que vomitamos. Eso es sabotaje con eco.",
		"praise": "Elogio sincero. No huele a azufre y se agradece.",
	},
	{
		"ask": [
			"¿Qué es la Familia del Mordisco?",
			"¿Quién lleva el registro de las deudas imposibles?",
			"¿Qué es el interés histórico?",
		],
		"fact": [
			"La Familia del Mordisco lleva el registro y cobra interés histórico.",
			"Hay deudas de antes del colapso que siguen generando intereses cada mañana.",
			"El interés histórico sube cuando nadie discute, que es casi siempre.",
		],
		"payoff": [
			"Hay un cliente que paga el interés histórico con el interés de otra deuda.",
			"El libro de la Familia tiene una página dedicada a los que dicen no deber nada.",
		],
		"deflect": [
			"De la Familia no hablo. Ni de la Familia de al lado.",
			"Ese registro está cerrado. El cierre se cobra.",
		],
		"hot": "La Familia del Mordisco es una banda de cobradores con árbol genealógico.",
		"offer": "Tengo una pieza de repuesto sin cargas familiares. Raro.",
		"gift": "Toma, y no firme nada de la Familia, que luego hereda.",
		"battle": "Los Sin Dientes dicen que la deuda es un invento. Pues que devuelvan el invento.",
		"praise": "Se agradece. Le anoto un descuento que no pienso aplicar.",
	},
	{
		"ask": [
			"¿Quiénes son los Sin Dientes?",
			"¿Se puede vivir sin deudas?",
			"¿Qué quiere el movimiento Sin Dientes?",
		],
		"fact": [
			"Los Sin Dientes son un movimiento de resistencia económica.",
			"Rechazan el sistema financiero y pagan en especie, en favores y en silencio.",
			"Viven peor, pero duermen sin deber nada a nadie que no exista.",
		],
		"payoff": [
			"Hay un Sin Dientes que debe un favor a otro y lo lleva apuntado en la mano.",
			"Nos han ofrecido comprar el movimiento. No aceptaron, pero pidieron precio.",
		],
		"deflect": [
			"De los Sin Dientes no sé nada. Y si lo supiera, lo cobraría.",
			"Ese movimiento no paga impuestos ni entrevistas.",
		],
		"hot": "Los Sin Dientes son unos románticos que vivirán de favores hasta que les cobren el aire.",
		"offer": "Tengo una pieza de repuesto que les iba a vender. No la quisieron.",
		"gift": "Toma, y si te preguntan de quién es, di que no lo sabes.",
		"battle": "Los Sin Dientes nos llaman ladrones y luego piden cambio. Eso no se sostiene.",
		"praise": "Buen cliente: elogia y no debe nada. Casi no existe.",
	},
	{
		"ask": [
			"¿Qué fue la Guerra de Intereses?",
			"¿Financiasteis la Guerra de las Esquinas?",
			"¿Por qué todos os deben dinero?",
		],
		"fact": [
			"Las grandes casas se enfrentaron por rutas, deudas y territorios.",
			"La guerra afectó a otras especies mediante préstamos y financiación militar.",
			"Financiamos la Guerra de las Esquinas con un préstamo solidario.",
		],
		"payoff": [
			"El préstamo sigue sin devolverse y de ahí viene la deuda universal, que es un malentendido cariñoso.",
			"Hay un libro con la lista de los que dicen que el préstamo ya se pagó. Página 1 de 400.",
		],
		"deflect": [
			"Esa guerra se pagó a plazos y los plazos siguen vivos.",
			"De la guerra no hablo: me deben dinero y se me nota.",
		],
		"hot": "Financiar una guerra y llamarlo préstamo solidario es de una cara muy dura.",
		"offer": "Tengo una pieza de repuesto que era garantía de un préstamo impagado.",
		"gift": "Toma, y firme el pagaré de la gratitud.",
		"battle": "Los Plegados no han devuelto el préstamo y encima nos tasan en cero. Ya está.",
		"praise": "Elogio con intereses. Se agradece y se acumula.",
	},
	{
		"ask": [
			"¿Compráis robots muertos?",
			"¿Qué es el suplemento nocturno?",
			"¿Por qué los Jubilados entierran de noche?",
		],
		"fact": [
			"Compramos los difuntos antes de que los entierren los Jubilados.",
			"Los Jubilados empezaron a enterrar de noche y eso creó el suplemento nocturno.",
			"El suplemento nocturno se cobra al comprador y al difunto, por si acaso.",
		],
		"payoff": [
			"Hay un cementerio donde la mitad de las tumbas están vacías y la otra mitad, tasadas.",
			"Un Jubilado vendió a su compañero dos veces: una por error y otra por costumbre.",
		],
		"deflect": [
			"Ese difunto ya tiene comprador. Y comprador tiene el comprador.",
			"De entierros no hablo. Se me hace tarde y la noche se cobra.",
		],
		"hot": "Comprar difuntos antes del entierro es profanar con factura.",
		"offer": "Tengo una pieza de repuesto que salió de un difunto. Está fría.",
		"gift": "Toma, y no pregunte de quién era. Era de alguien que ya no discute.",
		"battle": "Los Jubilados entierran de noche para no vendernos y luego nos llaman ladrones.",
		"praise": "Elogio de cliente. Se agradece y se le hace precio de mañana.",
	},
]
