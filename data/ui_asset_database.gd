extends RefCounted

static func get_resource_icon_paths() -> Dictionary:
	return {
		"comida": "res://assets/ui/icons/resources/icon_food.svg",
		"madera": "res://assets/ui/icons/resources/icon_wood.svg",
		"hierro": "res://assets/ui/icons/resources/icon_iron.svg",
		"medicina": "res://assets/ui/icons/resources/icon_medicine.svg",
		"moral": "res://assets/ui/icons/resources/icon_morale.svg",
		"seguridad": "res://assets/ui/icons/resources/icon_security.svg"
	}

static func get_panel_asset_paths() -> Dictionary:
	return {
		"dark_parchment": "res://assets/ui/panels/panel_dark_parchment.svg"
	}

static func get_button_asset_paths() -> Dictionary:
	return {
		"default": "res://assets/ui/buttons/button_default.svg",
		"important": "res://assets/ui/buttons/button_important.svg"
	}

static func get_status_colors() -> Dictionary:
	return {
		"activo": Color(0.54, 0.68, 0.45),
		"riesgo": Color(0.82, 0.58, 0.28),
		"bloqueado": Color(0.62, 0.23, 0.20),
		"neutral": Color(0.64, 0.58, 0.48)
	}
