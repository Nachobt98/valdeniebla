extends RefCounted

static func get_npc_order() -> Array[String]:
	return [
		"aldric",
		"gareth",
		"mara",
		"elowen",
		"bran",
		"lysa",
		"oren",
		"tomas"
	]

static func get_initial_npcs() -> Dictionary:
	return {
		"aldric": {
			"name": "Aldric",
			"age": 19,
			"profession": "Aprendiz de herrero",
			"location": "Herrería",
			"traits": ["Trabajador", "Orgulloso", "Impaciente"],
			"stats": {"forja": 6, "fuerza": 5, "carisma": 2, "sabiduría": 1},
			"state": {"salud": 90, "ánimo": 55, "estrés": 20},
			"relationships": {"gareth": 45, "mara": 10, "elowen": -5, "bran": 0, "lysa": 0, "oren": 5, "tomas": 0}
		},
		"gareth": {
			"name": "Gareth",
			"age": 48,
			"profession": "Herrero veterano",
			"location": "Herrería",
			"traits": ["Exigente", "Protector", "Tradicional"],
			"stats": {"forja": 9, "fuerza": 7, "carisma": 3, "sabiduría": 5},
			"state": {"salud": 78, "ánimo": 50, "estrés": 30},
			"relationships": {"aldric": 38, "mara": 5, "elowen": 15, "bran": 20, "lysa": 5, "oren": 10, "tomas": 5}
		},
		"mara": {
			"name": "Mara",
			"age": 23,
			"profession": "Tabernera",
			"location": "Taberna",
			"traits": ["Sociable", "Perspicaz", "Curiosa"],
			"stats": {"forja": 0, "fuerza": 2, "carisma": 8, "sabiduría": 4},
			"state": {"salud": 88, "ánimo": 65, "estrés": 18},
			"relationships": {"aldric": 12, "gareth": 5, "elowen": 25, "bran": 10, "lysa": 8, "oren": 0, "tomas": 5}
		},
		"elowen": {
			"name": "Elowen",
			"age": 31,
			"profession": "Curandera",
			"location": "Casa de curas",
			"traits": ["Reservada", "Empática", "Observadora"],
			"stats": {"forja": 0, "fuerza": 1, "carisma": 5, "sabiduría": 8},
			"state": {"salud": 82, "ánimo": 48, "estrés": 25},
			"relationships": {"aldric": -5, "gareth": 20, "mara": 30, "bran": 12, "lysa": 15, "oren": -5, "tomas": 18}
		},
		"bran": {
			"name": "Bran",
			"age": 42,
			"profession": "Granjero",
			"location": "Granjas",
			"traits": ["Constante", "Prudente", "Cansado"],
			"stats": {"forja": 1, "fuerza": 6, "carisma": 3, "sabiduría": 4},
			"state": {"salud": 74, "ánimo": 44, "estrés": 35},
			"relationships": {"aldric": 0, "gareth": 15, "mara": 10, "elowen": 14, "lysa": 22, "oren": -2, "tomas": 8}
		},
		"lysa": {
			"name": "Lysa",
			"age": 27,
			"profession": "Pastora",
			"location": "Prados",
			"traits": ["Pragmática", "Directa", "Leal"],
			"stats": {"forja": 0, "fuerza": 5, "carisma": 4, "sabiduría": 5},
			"state": {"salud": 86, "ánimo": 58, "estrés": 22},
			"relationships": {"aldric": 0, "gareth": 5, "mara": 8, "elowen": 15, "bran": 25, "oren": 0, "tomas": 0}
		},
		"oren": {
			"name": "Oren",
			"age": 53,
			"profession": "Alcalde",
			"location": "Casa comunal",
			"traits": ["Diplomático", "Inseguro", "Calculador"],
			"stats": {"forja": 0, "fuerza": 2, "carisma": 7, "sabiduría": 6},
			"state": {"salud": 76, "ánimo": 46, "estrés": 40},
			"relationships": {"aldric": 5, "gareth": 10, "mara": 0, "elowen": -5, "bran": -2, "lysa": 0, "tomas": 20}
		},
		"tomas": {
			"name": "Tomas",
			"age": 36,
			"profession": "Monje escriba",
			"location": "Capilla",
			"traits": ["Paciente", "Culto", "Melancólico"],
			"stats": {"forja": 0, "fuerza": 1, "carisma": 5, "sabiduría": 9},
			"state": {"salud": 80, "ánimo": 42, "estrés": 28},
			"relationships": {"aldric": 0, "gareth": 5, "mara": 5, "elowen": 18, "bran": 8, "lysa": 0, "oren": 20}
		}
	}
