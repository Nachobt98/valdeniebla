extends RefCounted

static func load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if path.ends_with(".png"):
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null:
			return null
		return ImageTexture.create_from_image(image)
	if ResourceLoader.exists(path):
		return load(path)
	return null

static func get_resource_icon_paths() -> Dictionary:
	return {
		"comida": "res://assets/ui/icons/resources/icon_food.svg",
		"madera": "res://assets/ui/icons/resources/icon_wood.svg",
		"hierro": "res://assets/ui/icons/resources/icon_iron.svg",
		"medicina": "res://assets/ui/icons/resources/icon_medicine.svg",
		"moral": "res://assets/ui/icons/resources/icon_morale.svg",
		"seguridad": "res://assets/ui/icons/resources/icon_security.svg"
	}

static func get_generated_resource_icon_paths() -> Dictionary:
	return {
		"comida": "res://assets/ui/generated/icons/resources/icon_food.png",
		"madera": "res://assets/ui/generated/icons/resources/icon_wood.png",
		"hierro": "res://assets/ui/generated/icons/resources/icon_iron.png",
		"medicina": "res://assets/ui/generated/icons/resources/icon_medicine.png",
		"moral": "res://assets/ui/generated/icons/resources/icon_morale.png",
		"seguridad": "res://assets/ui/generated/icons/resources/icon_security.png"
	}

static func get_map_npc_sprite_paths() -> Dictionary:
	return {
		"aldric": "res://assets/characters/sprites/aldric.png",
		"gareth": "res://assets/characters/sprites/gareth.png",
		"mara": "res://assets/characters/sprites/mara.png",
		"elowen": "res://assets/characters/sprites/elowen.png",
		"oren": "res://assets/characters/sprites/oren.png",
		"tomas": "res://assets/characters/sprites/tomas.png",
		"bran": "res://assets/characters/sprites/bran.png",
		"lysa": "res://assets/characters/sprites/lysa.png"
	}

static func get_map_building_asset_paths() -> Dictionary:
	return {
		"forge": "res://assets/map/buildings/forge.png",
		"tavern": "res://assets/map/buildings/tavern.png",
		"communal_house": "res://assets/map/buildings/communal_house.png",
		"chapel": "res://assets/map/buildings/chapel.png"
	}

static func get_portrait_paths() -> Dictionary:
	return {
		"aldric": "res://assets/characters/portraits/main/portrait_aldric.svg",
		"gareth": "res://assets/characters/portraits/main/portrait_gareth.svg",
		"mara": "res://assets/characters/portraits/main/portrait_mara.svg",
		"elowen": "res://assets/characters/portraits/main/portrait_elowen.svg",
		"oren": "res://assets/characters/portraits/main/portrait_oren.svg",
		"tomas": "res://assets/characters/portraits/main/portrait_tomas.svg",
		"bran": "res://assets/characters/portraits/main/portrait_bran.svg",
		"lysa": "res://assets/characters/portraits/main/portrait_lysa.svg"
	}

static func get_panel_asset_paths() -> Dictionary:
	return {
		"dark_parchment": "res://assets/ui/generated/panels/popup_dark_parchment.png"
	}

static func get_button_asset_paths() -> Dictionary:
	return {
		"resource_chip": "res://assets/ui/generated/buttons/resource_chip.png",
		"default": "res://assets/ui/generated/buttons/button_default.png",
		"important": "res://assets/ui/generated/buttons/button_important.png"
	}

static func get_status_icon_paths() -> Dictionary:
	return {
		"activo": "res://assets/ui/generated/status/status_active.png",
		"riesgo": "res://assets/ui/generated/status/status_risk.png"
	}

static func get_status_colors() -> Dictionary:
	return {
		"activo": Color(0.54, 0.68, 0.45),
		"riesgo": Color(0.82, 0.58, 0.28),
		"bloqueado": Color(0.62, 0.23, 0.20),
		"neutral": Color(0.64, 0.58, 0.48)
	}
