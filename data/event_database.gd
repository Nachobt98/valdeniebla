extends RefCounted

static func get_events() -> Array[Dictionary]:
	return [
		{
			"id": "aldric_forge_practice",
			"title": "Práctica en la herrería",
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
			"location": "Casa de curas",
			"actors": ["elowen", "bran"],
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
			"location": "Plaza",
			"actors": ["elowen", "aldric"],
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
			"location": "Capilla",
			"actors": ["tomas", "oren", "elowen"],
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
		}
	]
