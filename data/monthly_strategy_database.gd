extends RefCounted

static func get_default_strategy_id() -> String:
	return "balanced"

static func get_strategy_order() -> Array[String]:
	return ["balanced", "food", "defense", "wellbeing", "medicine", "construction"]

static func get_strategies() -> Dictionary:
	return {
		"balanced": {
			"name": "Equilibrada",
			"description": "La aldea reparte esfuerzos sin especializarse este mes.",
			"resource_modifiers": {}
		},
		"food": {
			"name": "Alimentos",
			"description": "La aldea prioriza campos, prados y reservas de comida.",
			"resource_modifiers": {"comida": 4},
			"state_modifiers": {"estrés": 1}
		},
		"defense": {
			"name": "Defensa",
			"description": "La aldea refuerza vigilancia, herramientas y preparación ante amenazas.",
			"resource_modifiers": {"seguridad": 2, "hierro": -1},
			"state_modifiers": {"estrés": 1}
		},
		"wellbeing": {
			"name": "Bienestar",
			"description": "La aldea protege moral, descanso y cohesión social.",
			"resource_modifiers": {"moral": 2, "comida": -2},
			"state_modifiers": {"estrés": -1, "ánimo": 1}
		},
		"medicine": {
			"name": "Medicina",
			"description": "La aldea recolecta hierbas, prepara remedios y vigila la salud.",
			"resource_modifiers": {"medicina": 2, "comida": -1},
			"state_modifiers": {"salud": 1}
		},
		"construction": {
			"name": "Construcción",
			"description": "La aldea reserva manos para talar, reparar y preparar futuras obras.",
			"resource_modifiers": {"madera": 3},
			"state_modifiers": {"estrés": 1}
		}
	}

static func get_strategy(strategy_id: String) -> Dictionary:
	return get_strategies().get(strategy_id, get_strategies()[get_default_strategy_id()])

static func get_strategy_name(strategy_id: String) -> String:
	return String(get_strategy(strategy_id).get("name", "Equilibrada"))
