extends RefCounted

static func get_building_order() -> Array[String]:
	return ["forge", "tavern", "well", "farms", "chapel", "pastures", "communal_house", "healers_house", "storehouse"]

static func get_initial_buildings() -> Dictionary:
	return {
		"forge": {
			"name": "Herrería",
			"level": 1,
			"condition": 100,
			"status": "Operativa",
			"workers": ["aldric", "gareth"],
			"function": "Forja, herramientas, reparaciones y defensa básica.",
			"production": ["Seguridad +1/día si queda hierro"],
			"costs": ["Hierro -1 cada 3 días"],
			"risks": ["Falta de hierro", "accidentes de forja", "conflictos entre aprendices"],
			"future_upgrade": "Herrería reforzada"
		},
		"tavern": {
			"name": "Taberna",
			"level": 1,
			"condition": 100,
			"status": "Abierta",
			"workers": ["mara"],
			"function": "Rumores, descanso, moral y visitantes.",
			"production": ["Moral +1/día"],
			"costs": [],
			"risks": ["Discusiones", "rumores peligrosos", "escasez de comida"],
			"future_upgrade": "Sala común ampliada"
		},
		"well": {
			"name": "Pozo",
			"level": 1,
			"condition": 100,
			"status": "Limpio",
			"workers": [],
			"function": "Punto de reunión, agua cotidiana y encuentros casuales.",
			"production": ["Eventos sociales futuros"],
			"costs": [],
			"risks": ["Contaminación", "sequía", "rumores públicos"],
			"future_upgrade": "Pozo cubierto"
		},
		"farms": {
			"name": "Granjas",
			"level": 1,
			"condition": 100,
			"status": "Productivas",
			"workers": ["bran"],
			"function": "Producción principal de comida.",
			"production": ["Comida +10/día"],
			"costs": [],
			"risks": ["Tormentas", "plagas", "agotamiento", "invierno"],
			"future_upgrade": "Campos drenados"
		},
		"chapel": {
			"name": "Capilla",
			"level": 1,
			"condition": 100,
			"status": "En calma",
			"workers": ["tomas"],
			"function": "Memoria, mediación, moral y primeras tramas de misterio.",
			"production": ["Moral +1/día"],
			"costs": [],
			"risks": ["Tensiones de fe", "secretos antiguos", "duelo comunitario"],
			"future_upgrade": "Archivo parroquial"
		},
		"pastures": {
			"name": "Prados",
			"level": 1,
			"condition": 100,
			"status": "Vigilados",
			"workers": ["lysa"],
			"function": "Ganado, comida secundaria y frontera rural.",
			"production": ["Comida +3/día"],
			"costs": [],
			"risks": ["Vallas rotas", "lobos", "robos", "niebla exterior"],
			"future_upgrade": "Cercado reforzado"
		},
		"communal_house": {
			"name": "Casa comunal",
			"level": 1,
			"condition": 100,
			"status": "Activa",
			"workers": ["oren"],
			"function": "Decisiones, organización mensual y conflictos públicos.",
			"production": ["Gestión de prioridades"],
			"costs": [],
			"risks": ["Disputas", "bloqueos políticos", "falta de liderazgo"],
			"future_upgrade": "Sala de consejo"
		},
		"healers_house": {
			"name": "Casa de curas",
			"level": 1,
			"condition": 100,
			"status": "Preparada",
			"workers": ["elowen"],
			"function": "Medicina, heridas, enfermedad y cuidado de la población.",
			"production": ["Eventos de salud", "uso de medicina"],
			"costs": [],
			"risks": ["Falta de medicina", "brotes", "agotamiento de Elowen"],
			"future_upgrade": "Enfermería limpia"
		},
		"storehouse": {
			"name": "Almacén",
			"level": 1,
			"condition": 100,
			"status": "Ordenable",
			"workers": [],
			"function": "Reservas, herramientas, comida y materiales.",
			"production": ["Capacidad y eventos de hallazgo futuros"],
			"costs": [],
			"risks": ["Humedad", "pérdidas", "desorden", "roedores"],
			"future_upgrade": "Almacén seco"
		}
	}
