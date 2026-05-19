extends RefCounted

static func get_initial_resources() -> Dictionary:
	return {
		"comida": 60,
		"madera": 30,
		"hierro": 10,
		"medicina": 8,
		"moral": 50,
		"seguridad": 25
	}

static func get_resource_order() -> Array[String]:
	return ["comida", "madera", "hierro", "medicina", "moral", "seguridad"]

static func get_resource_labels() -> Dictionary:
	return {
		"comida": "Comida",
		"madera": "Madera",
		"hierro": "Hierro",
		"medicina": "Medicina",
		"moral": "Moral",
		"seguridad": "Seguridad"
	}

static func get_daily_production_rules() -> Array[Dictionary]:
	return []

static func get_periodic_cost_rules() -> Array[Dictionary]:
	return [
		{"source": "Herrería", "resource": "hierro", "delta": -1, "every_days": 3, "description": "La herrería consume hierro cada pocos días."}
	]