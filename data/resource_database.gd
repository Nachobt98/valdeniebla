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
	return [
		{"source": "Granjas", "resource": "comida", "delta": 10, "description": "Las granjas sostienen la despensa diaria."},
		{"source": "Prados", "resource": "comida", "delta": 3, "description": "Los prados aportan ganado y pequeñas reservas."},
		{"source": "Taberna", "resource": "moral", "delta": 1, "description": "La taberna mantiene viva la conversación."},
		{"source": "Capilla", "resource": "moral", "delta": 1, "description": "La capilla da consuelo y rutina compartida."},
		{"source": "Herrería", "resource": "seguridad", "delta": 1, "requires_resource": "hierro", "requires_minimum": 1, "description": "La herrería convierte mantenimiento y metal en defensa básica."}
	]

static func get_periodic_cost_rules() -> Array[Dictionary]:
	return [
		{"source": "Herrería", "resource": "hierro", "delta": -1, "every_days": 3, "description": "La herrería consume hierro cada pocos días."}
	]