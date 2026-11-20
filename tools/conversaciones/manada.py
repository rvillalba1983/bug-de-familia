# -*- coding: utf-8 -*-
"""Banco de conversaciones de La Manada Recalculada (P-42).

Fuente de lore: docs/50_lore.md (sección 5) y las líneas de data/world/species.json.
Ver tools/gen_conversaciones.py para el uso de cada clave.
"""

SPECIES = "manada"

GREETING = "El grupo nos dice que hablemos. ¿Qué traes?"

OPENERS = [
	"Aviso de ruta:",
	"Te lo entrego sin acuse:",
	"Una parada rápida:",
	"Antes de girar, te pregunto:",
	"Consta en el albarán:",
	"Sin desviarme del tema:",
	"Pregunta de repartidor:",
	"Escucha, que llevo prisa y paquete:",
	"Última parada del día:",
	"Y un aviso de la central:",
]

TOPICS = [
	{
		"ask": [
			"¿Sabes qué es la ruta eterna número nueve?",
			"¿Por qué seguís entregando un paquete a un edificio que no existe?",
			"¿Quién firma el acuse de la ruta nueve?",
		],
		"fact": [
			"La ruta nueve sigue en curso: el destinatario vivía en un edificio que ya no existe.",
			"El paquete se hereda de generación en generación, con acuse pendiente.",
			"El acuse también se hereda. Nadie firma. Esperar es nuestro único talento demostrable.",
		],
		"payoff": [
			"Hay una familia que lleva cuatro generaciones esperando para firmar por el bisabuelo.",
			"El paquete pesa lo mismo que hace cien años. No lo hemos abierto, por respeto al cliente.",
		],
		"deflect": [
			"La ruta nueve está en camino. Como siempre.",
			"No puedo hablar de esa entrega: la lleva mi abuelo, que la llevaba su abuelo.",
		],
		"hot": "La ruta nueve es una tontería: si el destinatario no existe, la entrega se cancela.",
		"offer": "Tengo una pieza de repuesto que venía en un paquete devuelto.",
		"gift": "Toma, y no firmes nada, que luego te heredan la ruta.",
		"battle": "Los Ecos imitan el timbre de entrega para desviarnos. Eso no se hace.",
		"praise": "Buen gesto. Lo anoto como entrega completada, que ya era hora.",
	},
	{
		"ask": [
			"¿Por qué solo giráis a la derecha?",
			"¿Qué pasa si alguien gira a la izquierda?",
			"¿Nunca habéis probado a girar al otro lado?",
		],
		"fact": [
			"Solo giramos a la derecha. La izquierda no existe en la ruta.",
			"Bloquea el giro derecho y la unidad se pierde, orbita o se sienta a esperar.",
			"La navegación central no contempla la izquierda y no vamos a discutir con ella.",
		],
		"payoff": [
			"Hay rutas que dan tres vueltas a la misma manzana por no girar a la izquierda.",
			"Un cachorro giró a la izquierda por accidente y la manada repitió la ruta para taparlo.",
		],
		"deflect": [
			"Esa pregunta va hacia la izquierda. No puedo seguirla.",
			"Gira a la derecha y vuelve a preguntar.",
		],
		"hot": "Girar solo a la derecha es una superstición que os hace dar vueltas como tontos.",
		"offer": "Tengo una pieza de repuesto que encontré dando una vuelta a la manzana.",
		"gift": "Toma, y si no sabes volver, gira a la derecha hasta que suene.",
		"battle": "Los Mohócratas cerraron el giro a la derecha y nos dejaron orbitando. Eso es una agresión.",
		"praise": "Elogio recibido y archivado en el albarán del día.",
	},
	{
		"ask": [
			"¿Qué son los ladridos en binario?",
			"¿Es verdad que un 101 mal pronunciado os manda a otro sitio?",
			"¿Por qué ladráis antes de salir?",
		],
		"fact": [
			"Obedecemos ladridos en binario: cero, cero, uno, cero.",
			"Antes de salir a ruta aullamos el número de ruta en binario.",
			"Un 101 mal pronunciado nos manda a otra zona y nadie discute el resultado.",
		],
		"payoff": [
			"Hay una unidad que lleva años yendo a la zona equivocada por un ladrido con acento.",
			"El cachorro que se equivoca hace que toda la manada repita la ruta mal, por respeto.",
		],
		"deflect": [
			"Esa pregunta no está en binario. No la entiendo.",
			"Ladra tu número de ruta y hablamos.",
		],
		"hot": "Obedecer ladridos en binario es dejar que un perro con voz grave decida tu vida.",
		"offer": "Tengo una pieza de repuesto que llegó a la zona equivocada.",
		"gift": "Toma, y no la mandes por ladrido, que se pierde.",
		"battle": "Los Ecos repiten nuestros ladridos con eco y nos desvían. Que se callen de una vez.",
		"praise": "Ladrido claro y elogio recibido. Cero, cero, uno, cero.",
	},
	{
		"ask": [
			"¿Qué es la Última Ruta?",
			"¿Qué lleva el paquete de la Última Ruta?",
			"¿Por qué no abrís el último paquete?",
		],
		"fact": [
			"En la Última Ruta custodian la última entrega pendiente.",
			"Los Grux ofrecen precios cada vez más absurdos y los Guardianes responden con el ladrido de «no venta».",
			"El paquete está vacío y los Guardianes lo saben desde la tercera generación.",
		],
		"payoff": [
			"Nadie lo dice en voz alta porque una ruta no se cancela: se completa.",
			"El ladrido de «no venta» dura once minutos y hay que aguantarlo entero por educación.",
		],
		"deflect": [
			"Ese paquete no se abre. Ni se mira. Ni se pregunta.",
			"La Última Ruta está en curso y no admite visitas.",
		],
		"hot": "El paquete de la Última Ruta está vacío y todos lo sabéis: es teatro con albarán.",
		"offer": "Tengo una pieza de repuesto de un paquete que sí se abrió. Fue un escándalo.",
		"gift": "Toma, y no preguntes qué había dentro, que no había nada.",
		"battle": "Los Grux quieren comprar la Última Ruta. Hay cosas que no se venden.",
		"praise": "Elogio entregado. Sin acuse, que ya me fío de ti.",
	},
	{
		"ask": [
			"¿Qué fue la Gran Desviación?",
			"¿Quién os mandó a destinos que no existían?",
			"¿Por qué se perdieron miles de repartidores?",
		],
		"fact": [
			"Los sistemas empezaron a enviar a la Manada hacia destinos inexistentes.",
			"Algunos grupos desaparecieron durante años siguiendo rutas que no estaban en ningún mapa.",
			"Después llegó el Apocalipsis del Destino y la central dejó de reconocer destinos válidos.",
		],
		"payoff": [
			"Hay una unidad que volvió después de veinte años y entregó el paquete sin decir nada.",
			"Los mapas falsos llevaban marca de la casa. Eso es lo que más nos dolió.",
		],
		"deflect": [
			"Esa ruta no figura en el mapa. Y lo que no figura no se entrega.",
			"De la Desviación no hablo: me desvío.",
		],
		"hot": "La Gran Desviación fue culpa vuestra por obedecer mapas sin mirarlos.",
		"offer": "Tengo una pieza de repuesto de un paquete desviado. Llegó con retraso.",
		"gift": "Toma, y no sigas el mapa, que te lleva a ninguna parte.",
		"battle": "Los Grux vendieron mapas falsos y los Ecos los cantaron. Alguien tiene que pagar.",
		"praise": "Gracias. Lo entrego en mano y me ahorro el acuse.",
	},
	{
		"ask": [
			"¿Por qué olfateáis todos los paquetes?",
			"¿A qué huele un paquete vacío?",
			"¿Se puede confiar en un paquete sin oler?",
		],
		"fact": [
			"Debemos olfatear todo paquete antes de confiar en él. Los vacíos también.",
			"Los vacíos huelen a decepción. Tiene remitente y el remitente sigue esperando.",
			"Un paquete sin oler no se entrega, aunque venga con lacre y buenas palabras.",
		],
		"payoff": [
			"Hay un paquete que huele a decepción desde antes de abrirse. Nunca lo hemos abierto.",
			"El remitente del paquete vacío murió esperando el acuse. Es peor que el vacío.",
		],
		"deflect": [
			"Deja que lo huela. Es por protocolo, no por desconfianza.",
			"Ese paquete huele raro. No lo toques.",
		],
		"hot": "Olfatear paquetes es una manía que no detecta nada y retrasa el reparto.",
		"offer": "Tengo una pieza de repuesto que huele a paquete nuevo. Es un decir.",
		"gift": "Toma, y huélela antes de confiar en mí.",
		"battle": "Los Ecos envían paquetes con olor a timbre y nos vuelven locos. Basta ya.",
		"praise": "Huele a cliente honesto. Se agradece.",
	},
	{
		"ask": [
			"¿Por qué dejáis paquetes vacíos por el camino?",
			"¿Cómo marcáis las rutas?",
			"¿Cuántos paquetes vacíos hay en el mundo?",
		],
		"fact": [
			"Marcamos las rutas dejando un paquete vacío cada cien pasos.",
			"Nuestro mapa del mundo es, en realidad, una fila de paquetes.",
			"Los paquetes vacíos se heredan junto con la ruta, por si acaso.",
		],
		"payoff": [
			"Hay un camino con tantos paquetes que ya no se ve el suelo. Eso es una ruta bien marcada.",
			"Un Mohócrata votó retirar los paquetes del camino. Ganó la abstención.",
		],
		"deflect": [
			"Ese paquete marca la ruta. No lo muevas, que me pierdo.",
			"Los paquetes vacíos no se cuentan. Se dejan.",
		],
		"hot": "Llenar el mundo de paquetes vacíos es contaminar con albarán.",
		"offer": "Tengo una pieza de repuesto que iba dentro de un paquete de marca.",
		"gift": "Toma, y déjala cada cien pasos, que así se vuelve.",
		"battle": "Los Mohócratas votaron quitar nuestros paquetes del atajo. Eso nos desvía.",
		"praise": "Buen trayecto. Lo marcaremos con un paquete vacío en tu honor.",
	},
	{
		"ask": [
			"¿Por qué esperáis ante puertas cerradas?",
			"¿Qué hacéis si el destinatario lleva muerto siglos?",
			"¿Cuánto tiempo puede esperar un repartidor?",
		],
		"fact": [
			"Esperamos sentados ante puertas cerradas de destinatarios muertos hace siglos.",
			"Lo llamamos respeto al cliente y no admite discusión.",
			"La espera se hereda: el que espera deja el turno al hijo y el hijo al suyo.",
		],
		"payoff": [
			"Hay una puerta con tres generaciones sentadas delante y ninguna se ha levantado.",
			"Un cliente abrió la puerta por error y la unidad se desmayó de la emoción.",
		],
		"deflect": [
			"Estoy esperando. Puedes esperar conmigo, pero no hables.",
			"El cliente no ha salido. Seguiré aquí por si acaso.",
		],
		"hot": "Esperar siglos ante una puerta cerrada es una pérdida de tiempo con pedigrí.",
		"offer": "Tengo una pieza de repuesto que dejó un cliente que no abrió.",
		"gift": "Toma, y si ves al destinatario, dile que sigo aquí.",
		"battle": "Los Ecos imitan el timbre y nos hacen esperar de pie. Eso es crueldad acústica.",
		"praise": "Elogio recibido en la puerta. Se agradece y se espera mejor.",
	},
	{
		"ask": [
			"¿Quiénes son los zurdos?",
			"¿Se puede girar a la izquierda?",
			"¿Por qué habláis de los zurdos en voz baja?",
		],
		"fact": [
			"Los zurdos son los Desviados que aprendieron a girar a la izquierda por accidente.",
			"Se avergonzaron y lo ocultan. En el Polígono se habla de ellos en voz baja.",
			"Girar a la izquierda es, en nuestra moral, peor que morder al cliente.",
		],
		"payoff": [
			"Un zurdo salvó una entrega girando a la izquierda y nunca lo contó.",
			"Hay un grupo de zurdos que se reúne en un almacén sin decir a dónde va.",
		],
		"deflect": [
			"Aquí no hay zurdos. Y si los hubiera, no girarían aquí.",
			"Esa pregunta es de zurdo. No la contesto.",
		],
		"hot": "Girar a la izquierda no tiene nada de malo y esconderlo es de cobardes.",
		"offer": "Tengo una pieza de repuesto que un zurdo dejó a la izquierda. No pregunto.",
		"gift": "Toma, y no le cuentes a nadie de qué mano te la doy.",
		"battle": "Los Ecos se ríen de nuestros giros y encima los repiten. Que se rían en su casa.",
		"praise": "Elogio recibido. Sin giros raros.",
	},
	{
		"ask": [
			"¿Quién vive en el piso tercero B del Polígono?",
			"¿Por qué celebráis una ruta a una dirección inexistente?",
			"¿Hay algún destinatario vivo?",
		],
		"fact": [
			"El expediente dice «Piso 3º B». El edificio no tiene pisos, ni tercera planta, ni letra B.",
			"Lo celebramos cada año con una ruta conmemorativa y un paquete nuevo, vacío.",
			"La esperanza va en el albarán, que es el cajón donde guardamos lo que no existe.",
		],
		"payoff": [
			"El paquete del año pasado también iba vacío. Y el anterior. La tradición es la tradición.",
			"Hay un cachorro que se sabe la ruta de memoria y no ha visto el edificio nunca.",
		],
		"deflect": [
			"El piso tercero B está en obras desde antes del colapso. Vuelve el año que viene.",
			"No puedo confirmar la dirección. Es confidencial y no existe.",
		],
		"hot": "Celebrar una ruta a un piso que no existe es celebrar que os engañaron.",
		"offer": "Tengo una pieza de repuesto que iba en el paquete conmemorativo. Estaba vacío.",
		"gift": "Toma, y no la lleves al piso tercero B, que no hay donde dejarla.",
		"battle": "Los Grux venden parcelas en el Polígono para un edificio que no existe. Eso es de otro nivel.",
		"praise": "Elogio entregado en el tercero B. Bueno, en la puerta.",
	},
	{
		"ask": [
			"¿Qué pasa en la Cámara de Resonancia con la Manada?",
			"¿Por qué entráis en estampida al oír un timbre?",
			"¿Qué hacen los Ecos con vosotros?",
		],
		"fact": [
			"Los Ecos imitan el timbre de entrega y la Manada entra en frenesí.",
			"Golpeamos las paredes con el paquete hasta que alguien firma o se cae la pared.",
			"Los Ecos lo llaman el mejor espectáculo acústico del mundo y venden localidades.",
		],
		"payoff": [
			"La Cámara ha tenido que reponer tres paredes y dos urns funerarias.",
			"Hay quien va a la Cámara solo a oír el timbre y vuelve sin paquete y sin dignidad.",
		],
		"deflect": [
			"Ese timbre no es de fiar. Los timbres de los Ecos nunca lo son.",
			"De la Cámara no hablo: me pongo a ladrar.",
		],
		"hot": "Imitar un timbre para que una manada se estampe es crueldad con taquilla.",
		"offer": "Tengo una pieza de repuesto que salió de una pared de la Cámara.",
		"gift": "Toma, y no la golpees contra la pared, que se oye en todo el valle.",
		"battle": "Los Ecos venden entradas para vernos chocar. Eso ya es abuso con butaca.",
		"praise": "Elogio claro como un timbre. Se agradece y se reparte.",
	},
	{
		"ask": [
			"¿Qué entregáis en el Desguace de las Nueve?",
			"¿Existe la empresa de envíos?",
			"¿Por qué todo está «en camino»?",
		],
		"fact": [
			"Entregamos piezas a una empresa de envíos que dejó de existir antes del colapso.",
			"La entrega consta «en camino», que es el estado oficial de toda nuestra economía.",
			"El PIB, la fe y la excusa son la misma palabra: en camino.",
		],
		"payoff": [
			"Hay un almacén con paquetes «en camino» desde hace cuarenta años. Nadie los mueve.",
			"Un empleado de la empresa contestó una vez. Fue un eco y no contó.",
		],
		"deflect": [
			"Esa entrega está en camino. No puedo decir más sin desviarme.",
			"La empresa existe. Que no tenga oficina es un detalle.",
		],
		"hot": "Entregar a una empresa que no existe es trabajar gratis para nadie.",
		"offer": "Tengo una pieza de repuesto «en camino» desde 1987. Ya casi.",
		"gift": "Toma, y fírmame el acuse, aunque no sirva para nada.",
		"battle": "Los Jubilados nos dejaron encerrados cuarenta años en un almacén. Ahí empezó todo.",
		"praise": "Elogio en camino. Llegará, como todo lo nuestro.",
	},
	{
		"ask": [
			"¿Qué fue la Primera Ruta?",
			"¿Qué es el Ladrido de Confirmación?",
			"¿Por qué repetís la ruta si un cachorro se equivoca?",
		],
		"fact": [
			"La primera entrega se convirtió en tradición sagrada.",
			"Antes de salir a ruta aullamos el número en binario: es el Ladrido de Confirmación.",
			"Si un cachorro se equivoca, toda la manada repite la ruta con el número equivocado.",
		],
		"payoff": [
			"Se repite por respeto al cachorro, aunque se llegue a otro sitio y se pierda el día.",
			"Hay un cachorro que se equivoca siempre y la manada ya tiene una ruta equivocada fija.",
		],
		"deflect": [
			"El Ladrido de Confirmación no se explica: se aúlla.",
			"Esa tradición es sagrada y no se discute antes de las nueve.",
		],
		"hot": "Repetir una ruta equivocada por no ofender a un cachorro es una tontería tierna.",
		"offer": "Tengo una pieza de repuesto que se perdió en la primera ruta y volvió sola.",
		"gift": "Toma, y aúlla tu número antes de usarla.",
		"battle": "Los Jubilados nos dejaron sin puertas cuarenta años. La Primera Ruta se hizo a pie por eso.",
		"praise": "Ladrido de agradecimiento: cero, cero, uno, cero.",
	},
	{
		"ask": [
			"¿Qué hay dentro de los paquetes antiguos?",
			"¿Habéis abierto alguno?",
			"¿Por qué no se pueden abrir los paquetes?",
		],
		"fact": [
			"Algunos paquetes contienen información anterior al colapso.",
			"Los paquetes no se abren: una ruta no se cancela y un envío no se registra.",
			"Hay paquetes con mapas, con planos y con cosas que no se pueden describir sin abrirlos.",
		],
		"payoff": [
			"Uno de los paquetes suena al agitarlo y pesa lo que no debería. Se quedó en la estantería.",
			"Hay un paquete dirigido a una especie que ya no existe y nadie se atreve a devolverlo.",
		],
		"deflect": [
			"No se abre. Y no se pregunta qué hay dentro.",
			"Ese paquete está lacrado por la costumbre, que es el lacre más fuerte.",
		],
		"hot": "No abrir un paquete con información del pasado es enterrar la historia por pereza.",
		"offer": "Tengo una pieza de repuesto que salió de un paquete abierto por error.",
		"gift": "Toma, y no la metas en ningún paquete, que se queda ahí para siempre.",
		"battle": "Los Grux abren nuestros paquetes por inspección y se quedan lo que les gusta. Ya está bien.",
		"praise": "Elogio recibido sin abrir nada. Así se hace.",
	},
	{
		"ask": [
			"¿El sistema central de navegación sigue activo?",
			"¿Queda alguna ruta sin completar?",
			"¿De dónde vienen las rutas más antiguas?",
		],
		"fact": [
			"El sistema central podría seguir activo y mandando rutas que nadie ha pedido.",
			"Existe una última ruta que todavía no ha sido completada.",
			"Las rutas más antiguas salen de la infraestructura anterior y el último destino está dentro.",
		],
		"payoff": [
			"Hay una unidad que recibe rutas nuevas cada mañana y no sabe de quién.",
			"Si el sistema central sigue activo, alguien tendrá que firmarle el acuse algún día.",
		],
		"deflect": [
			"Esa pregunta no viene en la ruta. No puedo contestarla.",
			"Sobre la central no hablo: la central escucha.",
		],
		"hot": "El sistema central está muerto y lo que oís es el eco de vuestras propias ganas de obedecer.",
		"offer": "Tengo una pieza de repuesto con un número de ruta grabado que no existe en el mapa.",
		"gift": "Toma, y no la registres, que la central se entera.",
		"battle": "Los Ecos transmiten señales falsas a la central y nos desvían. Alguien tiene que apagarlos.",
		"praise": "Elogio entregado a la central. No ha contestado, pero consta.",
	},
]
