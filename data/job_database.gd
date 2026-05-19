extends RefCounted

static func get_job_order() -> Array[String]:
	return ["farmer", "pastor", "smith", "tavern_keeper", "healer", "scribe", "mayor"]

static func get_jobs() -> Dictionary:
	return {
		"farmer": {
			"name": "Granjero",
			"building": "farms",
			"workers": ["bran"],
			"daily_effects": [
				{"resource": "comida", "delta": 8, "source": "Bran en las granjas"}
			],
			"stress_delta": 1,
			"description": "Sostiene la comida base de Valdeniebla. Si Bran cae, la despensa lo nota."
		},
		"pastor": {
			"name": "Pastora",
			"building": "pastures",
			"workers": ["lysa"],
			"daily_effects": [
				{"resource": "comida", "delta": 3, "source": "Lysa en los prados"},
				{"resource": "seguridad", "delta": 1, "source": "Vigilancia de Lysa"}
			],
			"stress_delta": 1,
			"description": "Aporta comida secundaria y vigilancia rural en la frontera de la aldea."
		},
		"smith": {
			"name": "Herreros",
			"building": "forge",
			"workers": ["aldric", "gareth"],
			"requires_resource": "hierro",
			"requires_minimum": 1,
			"daily_effects": [
				{"resource": "seguridad", "delta": 2, "source": "Aldric y Gareth en la herrería"}
			],
			"stress_delta": 1,
			"description": "Convierte hierro y oficio en herramientas, reparaciones y defensa básica."
		},
		"tavern_keeper": {
			"name": "Tabernera",
			"building": "tavern",
			"workers": ["mara"],
			"daily_effects": [
				{"resource": "moral", "delta": 1, "source": "Mara en la taberna"}
			],
			"stress_delta": 0,
			"description": "Mantiene conversación, rumores y cohesión social."
		},
		"healer": {
			"name": "Curandera",
			"building": "healers_house",
			"workers": ["elowen"],
			"daily_effects": [
				{"resource": "medicina", "delta": 1, "source": "Elowen preparando remedios"}
			],
			"state_effects": [
				{"target": "all", "state": "salud", "delta": 1}
			],
			"stress_delta": 1,
			"description": "Reduce el deterioro sanitario y prepara reservas médicas."
		},
		"scribe": {
			"name": "Escriba",
			"building": "chapel",
			"workers": ["tomas"],
			"daily_effects": [
				{"resource": "moral", "delta": 1, "source": "Tomas en la capilla"}
			],
			"stress_delta": 0,
			"description": "Sostiene memoria, mediación y calma espiritual de la aldea."
		},
		"mayor": {
			"name": "Alcalde",
			"building": "communal_house",
			"workers": ["oren"],
			"daily_effects": [],
			"state_effects": [
				{"target": "oren", "state": "estrés", "delta": 1}
			],
			"stress_delta": 0,
			"description": "Coordina prioridades, quejas y legitimidad. Su efecto principal será desbloquear decisiones futuras."
		}
	}

static func get_job(job_id: String) -> Dictionary:
	return get_jobs().get(job_id, {})
