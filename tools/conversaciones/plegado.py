# -*- coding: utf-8 -*-
"""Banco de conversaciones de los Plegados (P-42).

Fuente de lore: docs/50_lore.md (sección 1) y las líneas de data/world/species.json.
Ver tools/gen_conversaciones.py para el uso de cada clave.
"""

SPECIES = "plegado"

GREETING = "No hables alto. Las paredes escuchan."

OPENERS = [
	"Antes de nada, una ficha:",
	"Consta que preguntas:",
	"Con el permiso del índice:",
	"Una aclaración administrativa:",
	"Doblo el asunto y te lo explico:",
	"Queda anotado:",
	"Fuera de formulario, te pregunto:",
	"Escucha, que esto se archiva:",
	"Última anotación del día:",
	"Y un anexo, si me permites:",
]

TOPICS = [
	{
		"ask": [
			"¿Sabes qué fue la Gran Clasificación?",
			"¿Por qué lo clasificáis absolutamente todo?",
			"¿Cuántas categorías tiene vuestro sistema?",
		],
		"fact": [
			"La Gran Clasificación pretendía catalogar todo lo existente, hasta las categorías.",
			"El sistema se volvió tan complejo que generaba categorías para las categorías.",
			"La administración gastaba más recursos en mantenerlo que en gobernar.",
		],
		"payoff": [
			"Hay una categoría dedicada a las cosas que no caben en ninguna categoría. Tiene dos tomos.",
			"El índice del índice ocupa una sala y la sala no está indexada.",
		],
		"deflect": [
			"Eso depende de la categoría. Y la categoría está en revisión.",
			"No consta. Y si no consta, no existe, aunque lo estés viendo.",
		],
		"hot": "Clasificar todo es una enfermedad administrativa que os ha dejado sin país.",
		"offer": "Tengo una pieza de repuesto. Está clasificada como «pieza suelta, uso indeterminado».",
		"gift": "Toma, y fírmame el recibimiento en la ficha que te doy.",
		"battle": "Los Grux tasaron nuestra clasificación en cero dientes. Eso, en nuestro idioma, es una guerra.",
		"praise": "Lo anoto en la ficha de elogios. Es la tercera del año y la primera que vale la pena.",
	},
	{
		"ask": [
			"¿Sabes qué fue la Guerra de las Esquinas?",
			"¿Por qué hubo una guerra por unas instalaciones?",
			"¿Ocultasteis que la tecnología comprimía materia viva?",
		],
		"fact": [
			"Desarrollamos tecnología para comprimir regiones enteras del espacio.",
			"Ocultamos que también podía comprimir materia viva. Era un detalle técnico pendiente.",
			"La guerra empezó cuando las facciones quisieron controlar las instalaciones y los mapas.",
		],
		"payoff": [
			"Las bajas de la guerra constan como erratas de archivo. La errata más grande de la historia.",
			"Los Grux financiaron los experimentos y aún reclaman el préstamo solidario.",
		],
		"deflect": [
			"Ese expediente está cerrado. Y el cierre está pendiente de clasificar.",
			"Fue un traslado administrativo de gran calado. Nada más que declarar.",
		],
		"hot": "La Guerra de las Esquinas fue un crimen y lo archivasteis como error de copia.",
		"offer": "Tengo una pieza de repuesto de la guerra. Está sin clasificar y así se queda.",
		"gift": "Toma, y no preguntes de qué instalación salió.",
		"battle": "Los Grux financiaron la guerra y luego nos la cobraron. Empecemos por esa deuda.",
		"praise": "Se agradece. Lo archivo como「gesto amable, categoría provisional」.",
	},
	{
		"ask": [
			"¿Sabes qué fue el Apocalipsis del Despliegue?",
			"¿Por qué hay ciudades que ya no están en el mapa?",
			"¿Qué pasó cuando llegaron las órdenes contradictorias?",
		],
		"fact": [
			"Las instalaciones recibieron órdenes contradictorias y unas regiones se desplegaron.",
			"Otras quedaron comprimidas. Ciudades enteras cambiaron de posición.",
			"La versión oficial dice que fue un despliegue exitoso de documentación.",
		],
		"payoff": [
			"Las ciudades perdidas constan como «archivadas en otra carpeta». Esa carpeta no tiene código.",
			"Hay un mapa que se dobla solo y nadie se atreve a desplegarlo del todo.",
		],
		"deflect": [
			"Ese mapa está mal doblado. Perdona, ¿me dejas corregírtelo?",
			"No hubo apocalipsis: hubo una reorganización de inventario a escala planetaria.",
		],
		"hot": "El Apocalipsis del Despliegue fue un fracaso vuestro y lo llamáis inventario.",
		"offer": "Tengo una pieza de repuesto de una ciudad comprimida. Pesa más de lo que debería.",
		"gift": "Toma, y no la despliegues en interiores.",
		"battle": "Los Grux siguen cobrando el préstamo de una guerra que perdimos todos. Basta.",
		"praise": "Queda archivado tu elogio, con código y todo.",
	},
	{
		"ask": [
			"¿Sabes qué es el octavo pliegue?",
			"¿Existe un pliegue secreto?",
			"¿Qué pasa si doblas ocho veces?",
		],
		"fact": [
			"El octavo pliegue existe. Solo lo dominan los archivistas veteranos y todos lo niegan.",
			"Doblarlo ocho veces vuelve invisible una tarde exacta.",
			"Deja una arruga que no se quita, y por vergüenza nadie admite saberlo.",
		],
		"payoff": [
			"Hay un archivista al que se le perdió una tarde de 1998 y no la ha reclamado.",
			"El octavo pliegue no está en el manual. El manual está doblado siete veces.",
		],
		"deflect": [
			"No sé de qué me hablas, y lo digo con la espalda recta.",
			"Ese pliegue no existe. Y si existiera, no se habla de él en pasillo.",
		],
		"hot": "El octavo pliegue es un cuento para presumir de arrugas.",
		"offer": "Tengo una pieza de repuesto con una arruga. No pregunto de dónde viene.",
		"gift": "Toma, y no la dobles más, que ya está bien doblada.",
		"battle": "Los Grux pagan por ver pliegues y se quedan la taquilla. Eso sí que es un robo.",
		"praise": "Lo agradezco. No lo archivo, que luego se pierde.",
	},
	{
		"ask": [
			"¿Qué es el cajón X?",
			"¿Por qué vigiláis un cajón vacío?",
			"¿Qué guardáis en la categoría X?",
		],
		"fact": [
			"El cajón X está clasificado como «categoría X: cosas que no queremos clasificar».",
			"Está vacío y lo vigilamos tres turnos al día para que siga vacío.",
			"Si alguien mete algo, habría que clasificarlo, y eso no está previsto.",
		],
		"payoff": [
			"Hay una solicitud para meter una nota en el cajón X. La solicitud está en el cajón X.",
			"El cajón tiene tres cerraduras y ninguna llave clasificada.",
		],
		"deflect": [
			"El cajón X no se comenta. Se vigila.",
			"No puedo confirmar ni negar el cajón. Está en la categoría X.",
		],
		"hot": "El cajón X es un cajón vacío y tres turnos de vigilancia pagados por todos.",
		"offer": "Tengo una pieza de repuesto. No va al cajón X, que conste.",
		"gift": "Toma, y no la metas en ningún cajón sin ficha.",
		"battle": "Los Jubilados meten fichas en nuestro cajón por diversión. Eso se paga.",
		"praise": "Bien dicho. Lo dejo fuera del cajón X, que es un honor.",
	},
	{
		"ask": [
			"¿Sabes saludar como un Plegado?",
			"¿Qué es el Saludo del Acordeón?",
			"¿Por qué os desplegáis tres veces al saludar?",
		],
		"fact": [
			"El Saludo del Acordeón se hace desplegándose y replegándose tres veces con ruido de fuelle.",
			"Un cuarto despliegue es un insulto formal.",
			"Medio despliegue se considera coqueteo administrativo.",
		],
		"payoff": [
			"Hubo un incidente diplomático por un saludo de cuatro pliegues con resaca.",
			"El ruido de fuelle se considera cortesía. El silencio, desprecio.",
		],
		"deflect": [
			"Saluda tú primero y te digo si lo has hecho bien.",
			"Mi fuelle está en mantenimiento. Saludo con la cabeza, que es menos vistoso.",
		],
		"hot": "El saludo del acordeón es un ruido innecesario que asusta a las otras especies.",
		"offer": "Tengo una pieza de repuesto que hace ruido de fuelle al abrirla.",
		"gift": "Toma, y despliégala tres veces por educación.",
		"battle": "Los Grux imitan nuestro saludo para burlarse y cobran entrada. Eso no se hace.",
		"praise": "Saludo correcto. Lo anoto con dos pliegues de cortesía.",
	},
	{
		"ask": [
			"¿Qué es el Juramento de la Esquina?",
			"¿Por qué miráis una esquina un minuto al entrar?",
			"¿Alguien ha necesitado alguna vez la esquina?",
		],
		"fact": [
			"Al entrar en casa giramos noventa grados y miramos la esquina un minuto.",
			"Es por si alguien la necesita. Nadie la ha necesitado nunca.",
			"El minuto se cumple con rencor, pero se cumple.",
		],
		"payoff": [
			"Hubo una vez alguien que necesitó la esquina, y no estaba mirando. No se repitió.",
			"El juramento dura un minuto oficial y dos reales, según el cronómetro del acta.",
		],
		"deflect": [
			"Estoy en el minuto de la esquina. Vuelve en un minuto.",
			"La esquina está bien. Gracias por preguntar, que nadie lo hace.",
		],
		"hot": "Mirar una esquina un minuto al día es una tontería que nadie se atreve a votar en contra.",
		"offer": "Tengo una pieza de repuesto que estaba apoyada en la esquina.",
		"gift": "Toma, y no la muevas de esquina sin avisar.",
		"battle": "Los Mohócratas votan sus rituales y se ríen de los nuestros. Pues hablemos de los suyos.",
		"praise": "Cumplido el minuto y agradecido el gesto. Dos pliegues.",
	},
	{
		"ask": [
			"¿Qué es el Acta Plegada?",
			"¿Dónde guardáis la historia?",
			"¿Por qué hay grietas llenas de papel?",
		],
		"fact": [
			"Cada día doblamos un acta con lo ocurrido y la metemos en una grieta.",
			"Las grietas del Valle de las Esquinas son el archivo histórico más completo del mundo.",
			"Nadie lo sabe porque nadie sabe leer el orden de los pliegues.",
		],
		"payoff": [
			"Hay una grieta que ya no admite más actas y hemos empezado a doblar más fuerte.",
			"Un Jubilado intentó leer el archivo y se quedó dormido en la letra Q.",
		],
		"deflect": [
			"Esa grieta está llena. Prueba en la de al lado, que tiene menos historia.",
			"El acta de hoy ya está metida. Lo de ahora va en la de mañana.",
		],
		"hot": "Meter actas en grietas no es un archivo: es esconder el papel bajo la alfombra.",
		"offer": "Tengo una pieza de repuesto envuelta en un acta antigua.",
		"gift": "Toma, y no la desdobles, que se pierde el orden.",
		"battle": "Los Jubilados archivan mal a propósito para que investiguemos. Qué humor.",
		"praise": "Queda plegado tu elogio y metido en la grieta buena.",
	},
	{
		"ask": [
			"¿Cuántos pliegues mide esta habitación?",
			"¿Por qué medís las estancias antes de entrar?",
			"¿Qué es un pliegue y medio?",
		],
		"fact": [
			"Antes de entrar medimos la estancia en pliegues. Es lo primero de cualquier visita.",
			"Catorce pliegues y medio se considera indecente y se dice en voz alta.",
			"La medida se anota en la ficha de la puerta, aunque la puerta no la lea.",
		],
		"payoff": [
			"Hay una casa que mide quince pliegues y nadie ha querido entrar por decencia.",
			"El patrón del pliegue está guardado en una caja que mide un pliegue justo.",
		],
		"deflect": [
			"Esta estancia mide lo que mide. No pienso repetirlo delante de ella.",
			"La medición está pendiente de confirmación por el comité de pliegues.",
		],
		"hot": "Medir las habitaciones en pliegues es una manía que no sirve absolutamente para nada.",
		"offer": "Tengo una pieza de repuesto que mide exactamente un pliegue.",
		"gift": "Toma, y úsala para medir antes de sentarte.",
		"battle": "Los Grux nos cobran el metro cuadrado y luego dicen que el pliegue no existe. Ya está.",
		"praise": "Medida correcta y saludo correcto. Se agradece la formalidad.",
	},
	{
		"ask": [
			"¿Por qué os molestan las esquinas redondeadas?",
			"¿Cuál es la única postura decente?",
			"¿Qué hacéis en una habitación curva?",
		],
		"fact": [
			"El ángulo recto es la única postura decente. Lo demás es dejadez.",
			"Las esquinas redondeadas se esquivan por pudor, no por higiene.",
			"En una habitación curva entramos mirando al suelo y salimos rápido.",
		],
		"payoff": [
			"Hay un edificio redondo en el que nadie ha trabajado desde hace cuarenta años.",
			"Un arquitecto plegado propuso redondear una esquina y se le abrió expediente.",
		],
		"deflect": [
			"No mires esa esquina. Está redondeada y es una indecencia.",
			"Prefiero no opinar sobre curvas. Me pongo nervioso.",
		],
		"hot": "Las esquinas redondeadas son más seguras y vuestro pudor es puro teatro.",
		"offer": "Tengo una pieza de repuesto con esquinas rectas. Como debe ser.",
		"gift": "Toma, y no la lima, que se redondea y pierde el decoro.",
		"battle": "Los Mohócratas construyen setas redondas y encima las votan. Eso es provocar.",
		"praise": "Opinas con ángulos rectos. Se agradece la decencia.",
	},
	{
		"ask": [
			"¿Qué pasa en el Archivo de las Esquinas?",
			"¿Por qué cada cadáver tiene dos fichas?",
			"¿Cómo os lleváis con los Jubilados en el archivo?",
		],
		"fact": [
			"Compartimos estanterías con Jubilados: ellos archivan por sentimiento y nosotros por código.",
			"Cada cadáver termina con dos fichas distintas y una disputa formal por acta.",
			"El cadáver no firma. Es lo único decente del expediente.",
		],
		"payoff": [
			"Hay un expediente con dos fichas que llevan treinta años sin coincidir en la fecha de muerte.",
			"Los Jubilados archivan mal a propósito. Nosotros lo corregimos por principio.",
		],
		"deflect": [
			"En el archivo no se habla. Se susurra y se firma.",
			"Esa ficha está en disputa. Como todas, por otra parte.",
		],
		"hot": "Archivar por sentimiento es una falta de respeto al difunto y al código.",
		"offer": "Tengo una pieza de repuesto con dos fichas. Una de ellas miente.",
		"gift": "Toma, y firma la ficha buena, no la del Jubilado.",
		"battle": "Los Jubilados nos descorrijan las fichas a propósito. Treinta años ya son bastantes.",
		"praise": "Ficha correcta. Se agradece y se archiva sin disputa.",
	},
	{
		"ask": [
			"¿Qué es el peaje de las esquinas?",
			"¿Cobráis por usar esquinas ajenas?",
			"¿Por qué hay un puesto de peaje en el Camino de los Dientes?",
		],
		"fact": [
			"En el Camino de los Dientes cobramos «uso de esquinas ajenas».",
			"Los Grux tasaron el puesto en cero dientes.",
			"Archivamos la tasación como «ofensa histórica, categoría provisional».",
		],
		"payoff": [
			"«Provisional» es nuestra forma de decir eterno. Lleva un siglo en provisional.",
			"El puesto tiene un libro de reclamaciones que ocupa más que el puesto.",
		],
		"deflect": [
			"El peaje se paga o se rodea. Y rodear cuesta más.",
			"Esa esquina es de pago. La de enfrente, también.",
		],
		"hot": "Cobrar por doblar una esquina es un abuso con sello y ventanilla.",
		"offer": "Tengo una pieza de repuesto del peaje. Está libre de tasación.",
		"gift": "Toma, y no la pases por la ventanilla, que te la tasan.",
		"battle": "Los Grux nos tasaron en cero y luego cobran peaje en nuestro camino. Empecemos.",
		"praise": "Gestión correcta. Se le exime del peaje simbólico.",
	},
	{
		"ask": [
			"¿Qué es la Antecámara?",
			"¿Habéis encontrado una esquina que no está en el mapa?",
			"¿Por qué vigiláis una esquina las veinticuatro horas?",
		],
		"fact": [
			"En la Antecámara unos exploradores encontraron una esquina que no figura en ningún mapa.",
			"Se turnan para vigilarla las veinticuatro horas. Nadie ha visto nada.",
			"Nadie se atreve a irse: abandonar el turno exigiría archivar el abandono.",
		],
		"payoff": [
			"Ya hay una lista de espera para vigilar una esquina que quizá no exista.",
			"El turno se hereda como una finca. Hay familias que llevan tres generaciones.",
		],
		"deflect": [
			"No puedo hablar, estoy en el turno de vigilancia. Bueno, lo estoy dejando.",
			"La esquina no figura. Y lo que no figura no se comenta.",
		],
		"hot": "Vigilar una esquina invisible es el trabajo más inútil del planeta.",
		"offer": "Tengo una pieza de repuesto que quedó en la Antecámara. No pregunto cómo.",
		"gift": "Toma, y no la lleves a la esquina sin ficha, que la lían.",
		"battle": "Los Grux quieren cobrar entrada por ver la esquina invisible. Eso es el colmo.",
		"praise": "Bien hablado. Se le concede un turno de vigilancia honorífico.",
	},
	{
		"ask": [
			"¿Quién fue el Capitán Origami?",
			"¿Te sabes alguna leyenda plegada?",
			"¿Existe la Niña Acordeón?",
		],
		"fact": [
			"El Capitán Origami del Apocalipsis fue un héroe de la Guerra de las Esquinas.",
			"La Niña Acordeón era una leyenda popular capaz de atravesar espacios imposibles.",
			"Santa Esquinia de los Siete Pliegues protegía a los refugiados.",
		],
		"payoff": [
			"Hay quien dice que la Niña Acordeón era un mapa mal doblado que se movía solo.",
			"El Capitán Origami murió de una arruga. Es lo más honroso que puede pasar aquí.",
		],
		"deflect": [
			"Las leyendas no se archivan. Se cuentan y se doblan.",
			"Esa te la cuento cuando no haya testigos. Las leyendas son tímidas.",
		],
		"hot": "Las leyendas plegadas son cuentos para niños con exceso de geometría.",
		"offer": "Tengo una pieza de repuesto que, según la leyenda, fue del Capitán.",
		"gift": "Toma, y no la dobles siete veces, que igual desaparece.",
		"battle": "Los Grux venden entradas para ver a la Niña Acordeón. Eso no se puede tolerar.",
		"praise": "Historia bien contada. Se agradece y se archiva como leyenda viva.",
	},
	{
		"ask": [
			"¿Es verdad que los Grux os tasaron en cero dientes?",
			"¿Qué opinas de los Grux?",
			"¿Por qué hay una ofensa histórica en vuestro archivo?",
		],
		"fact": [
			"Los Grux nos tasaron en cero dientes y lo archivamos como ofensa histórica.",
			"La categoría sigue siendo provisional, que en nuestro idioma significa eterna.",
			"Ellos dicen que fue una tasación de mercado. Nosotros, un insulto con recibo.",
		],
		"payoff": [
			"Hay un archivero que repite la tasación cada mañana en voz alta, por si acaso.",
			"Los Grux ofrecieron subirla a un diente. Se votó no aceptar y luego se olvidó.",
		],
		"deflect": [
			"De los Grux hablo poco. Se me dobla el expediente.",
			"Esa ofensa está en revisión. Lleva un siglo en revisión.",
		],
		"hot": "Los Grux son comerciantes honrados y la tasación fue correcta.",
		"offer": "Tengo una pieza de repuesto. Los Grux no la quisieron ni gratis.",
		"gift": "Toma, y no la tasen, que se ofende ella sola.",
		"battle": "Un cero dientes pesa más que un ejército. Y ya está bien de paciencia.",
		"praise": "Compartes nuestra indignación y eso ya es parentesco administrativo.",
	},
]
