extends RefCounted

static func get_building_layouts() -> Dictionary:
	return {
		"forge": {
			"label": "HERRERIA",
			"position": Vector2(0.23, 0.36),
			"size": Vector2(0.13, 0.11),
			"roof": Color(0.27, 0.12, 0.08, 1.0),
			"body": Color(0.19, 0.15, 0.12, 1.0)
		},
		"well": {
			"label": "POZO",
			"position": Vector2(0.50, 0.47),
			"size": Vector2(0.07, 0.07),
			"roof": Color(0.16, 0.24, 0.25, 1.0),
			"body": Color(0.18, 0.18, 0.16, 1.0)
		},
		"communal_house": {
			"label": "CASA COMUNAL",
			"position": Vector2(0.50, 0.32),
			"size": Vector2(0.12, 0.10),
			"roof": Color(0.27, 0.18, 0.10, 1.0),
			"body": Color(0.23, 0.19, 0.14, 1.0)
		},
		"tavern": {
			"label": "TABERNA",
			"position": Vector2(0.68, 0.36),
			"size": Vector2(0.15, 0.12),
			"roof": Color(0.31, 0.12, 0.08, 1.0),
			"body": Color(0.20, 0.16, 0.13, 1.0)
		},
		"farms": {
			"label": "GRANJAS",
			"position": Vector2(0.30, 0.68),
			"size": Vector2(0.14, 0.10),
			"roof": Color(0.42, 0.32, 0.12, 1.0),
			"body": Color(0.25, 0.19, 0.11, 1.0)
		},
		"chapel": {
			"label": "CAPILLA",
			"position": Vector2(0.58, 0.67),
			"size": Vector2(0.12, 0.14),
			"roof": Color(0.16, 0.16, 0.15, 1.0),
			"body": Color(0.25, 0.24, 0.20, 1.0)
		},
		"healers_house": {
			"label": "CURAS",
			"position": Vector2(0.43, 0.69),
			"size": Vector2(0.10, 0.10),
			"roof": Color(0.18, 0.27, 0.20, 1.0),
			"body": Color(0.21, 0.22, 0.17, 1.0)
		},
		"storehouse": {
			"label": "ALMACEN",
			"position": Vector2(0.36, 0.50),
			"size": Vector2(0.10, 0.09),
			"roof": Color(0.24, 0.17, 0.09, 1.0),
			"body": Color(0.20, 0.15, 0.10, 1.0)
		},
		"pastures": {
			"label": "PRADOS",
			"position": Vector2(0.78, 0.58),
			"size": Vector2(0.17, 0.12),
			"roof": Color(0.20, 0.27, 0.13, 1.0),
			"body": Color(0.14, 0.22, 0.12, 1.0)
		}
	}

static func get_paths() -> Array[PackedVector2Array]:
	return [
		PackedVector2Array([
			Vector2(0.06, 0.58),
			Vector2(0.33, 0.57),
			Vector2(0.50, 0.47),
			Vector2(0.74, 0.42),
			Vector2(0.94, 0.37)
		]),
		PackedVector2Array([
			Vector2(0.50, 0.47),
			Vector2(0.50, 0.39),
			Vector2(0.50, 0.32)
		]),
		PackedVector2Array([
			Vector2(0.50, 0.47),
			Vector2(0.47, 0.58),
			Vector2(0.43, 0.76)
		]),
		PackedVector2Array([
			Vector2(0.50, 0.47),
			Vector2(0.58, 0.59),
			Vector2(0.70, 0.70)
		]),
		PackedVector2Array([
			Vector2(0.33, 0.57),
			Vector2(0.36, 0.50),
			Vector2(0.40, 0.58),
			Vector2(0.29, 0.67),
			Vector2(0.24, 0.77)
		])
	]

static func get_npc_routines() -> Dictionary:
	return {
		"aldric": ["forge", "well", "forge"],
		"gareth": ["forge", "tavern", "forge"],
		"mara": ["tavern", "well", "tavern"],
		"bran": ["farms", "well", "farms"],
		"lysa": ["pastures", "well", "pastures"],
		"tomas": ["chapel", "well", "chapel"],
		"elowen": ["healers_house", "well", "chapel"],
		"oren": ["communal_house", "well", "tavern"]
	}
