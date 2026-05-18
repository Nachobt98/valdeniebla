extends RefCounted

static func get_events() -> Array[Dictionary]:
	return [
		{
			"id": "aldric_forge_practice",
			"title": "Práctica en la herrería",
			"category": "work",
			"tone": "neutral",
			"weight": 10,
			"cooldown_days": 2,
			"unique": false,
			"importance": "minor",
			"location": "Herrería",
			"actors": ["aldric", "gareth"],
			"text": "Gareth corrigió la técnica de Aldric mientras forjaban bisagras para las granjas. Aldric aprendió algo útil, aunque tragó orgullo más de una vez.",
			"effects": [
				{"target": "aldric", "stat": "forja", "delta": 1},
				{"from": "aldric", "to": "gareth", "relation_delta": -2},
				{"from": "gareth", "to": "aldric", "relation_delta": 1},
				{"target": "aldric", "state": "estrés", "delta": 4}
			]
		},
		{
			"id": "mara_well_conversation",
			"title": "Conversación junto al pozo",
			"category": "social",
			"tone": "positive",
			"weight": 8,
			"cooldown_days": 3,
			"unique": false,
			"importance": "minor",
			"location": "Pozo",
			"actors": ["aldric", "mara"],
			"text": "Mara encontró a Aldric junto al pozo y le sacó conversación sobre la herrería. Aldric intentó parecer tranquilo; no lo consiguió del todo.",
			"effects": [
				{"from": "aldric", "to": "mara", "relation_delta": 2},
				{"from": "mara", "to": "aldric", "relation_delta": 1},
				{"target": "aldric", "state": "ánimo", "delta": 4}
			]
		},
		{
			"id": "elowen_treats_bran",
			"title": "Fiebre en las granjas",
			"category": "health",
			"tone": "neutral",
			"weight": 5,
			"cooldown_days": 5,
			"unique": false,
			"importance": "medium",
			"location": "Casa de curas",
			"actors": ["elowen", "bran"],
			"conditions": {"max_state": {"target": "bran", "state": "salud", "value": 85}},
			"text": "Bran acudió a Elowen con fiebre leve tras una mañana de humedad en los campos. Elowen lo atendió sin hacer preguntas de más.",
			"effects": [
				{"target": "bran", "state": "salud", "delta": 5},
				{"target": "elowen", "state": "estrés", "delta": 3},
				{"from": "bran", "to": "elowen", "relation_delta": 3}
			]
		},
		{
			"id": "oren_public_request",
			"title": "Encargo del alcalde",
			"category": "work",
			"tone": "tense",
			"weight": 6,
			"cooldown_days": 4,
			"unique": false,
			"importance": "medium",
			"location": "Casa comunal",
			"actors": ["oren", "gareth", "aldric"],
			"text": "Oren pidió a la herrería que reparase herramientas comunales antes del mercado. Gareth aceptó el encargo, pero dejó claro que faltaban manos y hierro.",
			"effects": [
				{"target": "gareth", "state": "estrés", "delta": 5},
				{"target": "aldric", "stat": "forja", "delta": 1},
				{"from": "gareth", "to": "oren", "relation_delta": -1},
				{"from": "oren", "to": "gareth", "relation_delta": 1}
			]
		},
		{
			"id": "tavern_rumor",
			"title": "Rumores del camino norte",
			"category": "rumor",
			"tone": "tense",
			"weight": 5,
			"cooldown_days": 3,
			"unique": false,
			"importance": "medium",
			"location": "Taberna",
			"actors": ["mara", "tomas", "oren"],
			"text": "Un viajero dejó caer en la taberna que el camino norte está menos seguro. Mara escuchó con atención; Tomas lo anotó para la crónica local.",
			"effects": [
				{"target": "oren", "state": "estrés", "delta": 4},
				{"from": "tomas", "to": "mara", "relation_delta": 1},
				{"from": "mara", "to": "tomas", "relation_delta": 1}
			]
		},
		{
			"id": "lysa_bran_fence",
			"title": "Valla caída en los prados",
			"category": "conflict",
			"tone": "tense",
			"weight": 6,
			"cooldown_days": 4,
			"unique": false,
			"importance": "medium",
			"location": "Prados",
			"actors": ["lysa", "bran", "aldric"],
			"text": "Lysa y Bran discutieron por una valla caída. Aldric prometió preparar clavos nuevos antes del anochecer.",
			"effects": [
				{"target": "aldric", "stat": "forja", "delta": 1},
				{"target": "lysa", "state": "estrés", "delta": 3},
				{"from": "lysa", "to": "bran", "relation_delta": -2},
				{"from": "bran", "to": "lysa", "relation_delta": -1},
				{"from": "lysa", "to": "aldric", "relation_delta": 2}
			]
		},
		{
			"id": "elowen_avoids_aldric",
			"title": "Silencio incómodo",
			"category": "social",
			"tone": "negative",
			"weight": 5,
			"cooldown_days": 4,
			"unique": false,
			"importance": "minor",
			"location": "Plaza",
			"actors": ["elowen", "aldric"],
			"conditions": {"max_relation": {"from": "aldric", "to": "elowen", "value": 0}},
			"text": "Elowen evitó hablar con Aldric en la plaza. Aldric fingió no darse cuenta, pero el gesto no pasó desapercibido.",
			"effects": [
				{"from": "aldric", "to": "elowen", "relation_delta": -2},
				{"target": "aldric", "state": "ánimo", "delta": -3},
				{"target": "elowen", "state": "estrés", "delta": 1}
			]
		},
		{
			"id": "tomas_mediates",
			"title": "Mediación discreta",
			"category": "relief",
			"tone": "relief",
			"weight": 4,
			"cooldown_days": 5,
			"unique": false,
			"importance": "medium",
			"location": "Capilla",
			"actors": ["tomas", "oren", "elowen"],
			"conditions": {"min_state": {"target": "oren", "state": "estrés", "value": 30}},
			"text": "Tomas habló con Oren y Elowen tras las tensiones de la semana. No resolvió gran cosa, pero al menos consiguió que se escucharan sin levantar la voz.",
			"effects": [
				{"target": "oren", "state": "estrés", "delta": -4},
				{"target": "elowen", "state": "estrés", "delta": -3},
				{"from": "oren", "to": "tomas", "relation_delta": 2},
				{"from": "elowen", "to": "tomas", "relation_delta": 1}
			]
		},
		{
			"id": "mara_defends_aldric",
			"title": "Defensa en la taberna",
			"category": "social",
			"tone": "positive",
			"weight": 3,
			"cooldown_days": 8,
			"unique": false,
			"importance": "medium",
			"location": "Taberna",
			"actors": ["mara", "aldric", "gareth"],
			"conditions": {"min_day": 3, "min_relation": {"from": "mara", "to": "aldric", "value": 12}},
			"text": "Cuando alguien se burló de los errores de Aldric, Mara salió en su defensa con una sonrisa afilada. Gareth observó la escena en silencio.",
			"effects": [
				{"from": "aldric", "to": "mara", "relation_delta": 4},
				{"from": "mara", "to": "aldric", "relation_delta": 2},
				{"target": "aldric", "state": "ánimo", "delta": 6},
				{"from": "gareth", "to": "mara", "relation_delta": 1}
			]
		},
		{
			"id": "aldric_overworks",
			"title": "Trabajo hasta tarde",
			"category": "work",
			"tone": "negative",
			"weight": 4,
			"cooldown_days": 5,
			"unique": false,
			"importance": "medium",
			"location": "Herrería",
			"actors": ["aldric", "gareth"],
			"conditions": {"min_day": 4, "min_state": {"target": "aldric", "state": "estrés", "value": 25}},
			"text": "Aldric se quedó en la herrería después de la puesta de sol para demostrar que podía con más de lo que Gareth esperaba. La pieza salió bien; él, no tanto.",
			"effects": [
				{"target": "aldric", "stat": "forja", "delta": 2},
				{"target": "aldric", "state": "salud", "delta": -4},
				{"target": "aldric", "state": "estrés", "delta": 7},
				{"from": "gareth", "to": "aldric", "relation_delta": 2}
			]
		},
		{
			"id": "bran_good_harvest_morning",
			"title": "Buenos surcos al amanecer",
			"category": "work",
			"tone": "positive",
			"weight": 7,
			"cooldown_days": 4,
			"unique": false,
			"importance": "minor",
			"location": "Granjas",
			"actors": ["bran", "lysa"],
			"conditions": {"min_state": {"target": "bran", "state": "salud", "value": 60}, "max_state": {"target": "bran", "state": "estrés", "value": 70}},
			"text": "Bran encontró la tierra más blanda de lo esperado tras la humedad de la noche. Lysa le ayudó a reforzar los lindes mientras los primeros vecinos cruzaban hacia el pozo.",
			"effects": [
				{"target": "bran", "state": "ánimo", "delta": 4},
				{"target": "bran", "state": "estrés", "delta": -2},
				{"from": "lysa", "to": "bran", "relation_delta": 1},
				{"from": "bran", "to": "lysa", "relation_delta": 1}
			]
		},
		{
			"id": "mara_hears_private_confession",
			"title": "Una confesión entre jarras",
			"category": "social",
			"tone": "neutral",
			"weight": 5,
			"cooldown_days": 5,
			"unique": false,
			"importance": "medium",
			"location": "Taberna",
			"actors": ["mara", "tomas"],
			"conditions": {"min_stat": {"target": "mara", "stat": "carisma", "value": 7}},
			"text": "Entre el ruido bajo de la taberna, Tomas dejó escapar una preocupación que llevaba días guardándose. Mara no insistió, pero supo escuchar justo lo suficiente.",
			"effects": [
				{"target": "tomas", "state": "estrés", "delta": -3},
				{"from": "tomas", "to": "mara", "relation_delta": 2},
				{"from": "mara", "to": "tomas", "relation_delta": 1},
				{"target": "mara", "stat": "sabiduría", "delta": 1}
			]
		},
		{
			"id": "oren_avoids_decision",
			"title": "El alcalde pospone una decisión",
			"category": "conflict",
			"tone": "tense",
			"weight": 5,
			"cooldown_days": 4,
			"unique": false,
			"importance": "medium",
			"location": "Casa comunal",
			"actors": ["oren", "bran", "gareth"],
			"conditions": {"min_state": {"target": "oren", "state": "estrés", "value": 35}},
			"text": "Bran y Gareth pidieron a Oren que decidiera qué reparación era prioritaria. Oren prometió pensarlo hasta el día siguiente. Ninguno de los dos pareció satisfecho.",
			"effects": [
				{"target": "oren", "state": "estrés", "delta": 5},
				{"from": "bran", "to": "oren", "relation_delta": -2},
				{"from": "gareth", "to": "oren", "relation_delta": -2},
				{"target": "oren", "state": "ánimo", "delta": -2}
			]
		},
		{
			"id": "elowen_late_night_herbs",
			"title": "Hierbas bajo la lluvia",
			"category": "health",
			"tone": "neutral",
			"weight": 4,
			"cooldown_days": 5,
			"unique": false,
			"importance": "minor",
			"location": "Casa de curas",
			"actors": ["elowen", "lysa"],
			"conditions": {"max_state": {"target": "elowen", "state": "estrés", "value": 70}},
			"text": "Elowen salió a revisar las hierbas secas antes de que la humedad las echara a perder. Lysa la encontró trabajando sola y la ayudó sin hacer demasiadas preguntas.",
			"effects": [
				{"target": "elowen", "state": "estrés", "delta": -2},
				{"target": "elowen", "state": "ánimo", "delta": 2},
				{"from": "lysa", "to": "elowen", "relation_delta": 2},
				{"from": "elowen", "to": "lysa", "relation_delta": 1}
			]
		},
		{
			"id": "aldric_public_boast",
			"title": "Una fanfarronada mal medida",
			"category": "social",
			"tone": "tense",
			"weight": 4,
			"cooldown_days": 5,
			"unique": false,
			"importance": "medium",
			"location": "Plaza",
			"actors": ["aldric", "gareth", "mara"],
			"conditions": {"min_stat": {"target": "aldric", "stat": "forja", "value": 8}, "min_state": {"target": "aldric", "state": "estrés", "value": 25}},
			"text": "Aldric presumió en la plaza de que pronto no necesitaría que nadie corrigiera su trabajo. Gareth no respondió, pero Mara notó el silencio que dejó la frase.",
			"effects": [
				{"target": "aldric", "state": "ánimo", "delta": 2},
				{"target": "aldric", "state": "estrés", "delta": 3},
				{"from": "gareth", "to": "aldric", "relation_delta": -3},
				{"from": "mara", "to": "aldric", "relation_delta": -1}
			]
		},
		{
			"id": "tomas_records_old_story",
			"title": "Una historia antigua vuelve al papel",
			"category": "rumor",
			"tone": "neutral",
			"weight": 4,
			"cooldown_days": 6,
			"unique": false,
			"importance": "minor",
			"location": "Capilla",
			"actors": ["tomas", "gareth"],
			"conditions": {"min_day": 3},
			"text": "Gareth contó a Tomas una vieja historia sobre la fundación de Valdeniebla. Tomas la copió con cuidado, aunque sospechó que el herrero había adornado la mitad.",
			"effects": [
				{"target": "tomas", "stat": "sabiduría", "delta": 1},
				{"from": "tomas", "to": "gareth", "relation_delta": 1},
				{"target": "gareth", "state": "ánimo", "delta": 2}
			]
		},
		{
			"id": "mara_and_elowen_notice_tension",
			"title": "Miradas sobre la plaza",
			"category": "social",
			"tone": "tense",
			"weight": 4,
			"cooldown_days": 5,
			"unique": false,
			"importance": "medium",
			"location": "Plaza",
			"actors": ["mara", "elowen", "aldric"],
			"conditions": {"min_state": {"target": "aldric", "state": "estrés", "value": 30}},
			"text": "Mara y Elowen vieron a Aldric cruzar la plaza con los hombros tensos. Mara quiso acercarse; Elowen le aconsejó esperar.",
			"effects": [
				{"from": "mara", "to": "aldric", "relation_delta": 1},
				{"from": "elowen", "to": "aldric", "relation_delta": 1},
				{"target": "aldric", "state": "estrés", "delta": 1},
				{"from": "mara", "to": "elowen", "relation_delta": 1}
			]
		},
		{
			"id": "first_market_preparations",
			"title": "Preparativos para el pequeño mercado",
			"category": "special",
			"tone": "positive",
			"weight": 2,
			"cooldown_days": 999,
			"unique": true,
			"importance": "major",
			"location": "Plaza",
			"actors": ["oren", "mara", "bran", "gareth"],
			"conditions": {"min_day": 5},
			"text": "Oren anunció que Valdeniebla celebraría un pequeño mercado al final de la semana. Mara empezó a organizar la taberna, Bran revisó sus cestas y Gareth calculó cuántas herramientas podía terminar a tiempo.",
			"effects": [
				{"target": "oren", "state": "ánimo", "delta": 4},
				{"target": "mara", "state": "ánimo", "delta": 3},
				{"target": "bran", "state": "estrés", "delta": 2},
				{"target": "gareth", "state": "estrés", "delta": 2},
				{"from": "oren", "to": "mara", "relation_delta": 1},
				{"from": "oren", "to": "gareth", "relation_delta": 1}
			]
		}
	]
