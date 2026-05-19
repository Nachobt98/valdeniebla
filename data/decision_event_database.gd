extends RefCounted

static func get_decision_events() -> Array[Dictionary]:
	return [
		{
			"id": "fever_in_farms",
			"title": "Fiebre en las granjas",
			"location": "Granjas",
			"weight": 7,
			"cooldown_days": 8,
			"description": "La humedad ha traído fiebre a varias casas cercanas a los campos. Elowen cree que puede contenerla, pero necesita reservas.",
			"options": [
				{
					"label": "Usar medicina",
					"requirements": {"medicina": 3},
					"effects": [
						{"resource": "medicina", "delta": -3},
						{"resource": "moral", "delta": 1},
						{"state": "salud", "delta": 3, "target": "all"}
					],
					"result_text": "Elowen reparte remedios y la fiebre remite antes de extenderse."
				},
				{
					"label": "Reservar medicina",
					"effects": [
						{"resource": "moral", "delta": -2},
						{"state": "salud", "delta": -4, "target": "all"},
						{"state": "estrés", "delta": 2, "target": "elowen"}
					],
					"result_text": "La aldea conserva sus reservas, pero la enfermedad deja cansancio y miedo."
				}
			]
		},
		{
			"id": "damaged_fence",
			"title": "Valla rota tras la tormenta",
			"location": "Prados",
			"weight": 6,
			"cooldown_days": 6,
			"description": "Una tormenta ha tirado parte de una valla en los prados. Lysa advierte que dejarla así hará la zona más vulnerable.",
			"options": [
				{
					"label": "Reparar con madera",
					"requirements": {"madera": 5},
					"effects": [
						{"resource": "madera", "delta": -5},
						{"resource": "seguridad", "delta": 2},
						{"relation_delta": 2, "from": "lysa", "to": "oren"}
					],
					"result_text": "La valla queda reforzada antes del anochecer. Lysa respira algo más tranquila."
				},
				{
					"label": "Dejarlo para más adelante",
					"effects": [
						{"resource": "seguridad", "delta": -4},
						{"resource": "moral", "delta": -1},
						{"state": "estrés", "delta": 2, "target": "lysa"}
					],
					"result_text": "La reparación queda pendiente. Los prados se sienten más expuestos."
				}
			]
		},
		{
			"id": "hungry_travelers",
			"title": "Viajeros hambrientos",
			"location": "Camino norte",
			"weight": 5,
			"cooldown_days": 10,
			"description": "Un pequeño grupo de viajeros pide comida y refugio. No parecen peligrosos, pero las reservas no son infinitas.",
			"options": [
				{
					"label": "Acogerlos",
					"requirements": {"comida": 8},
					"effects": [
						{"resource": "comida", "delta": -8},
						{"resource": "moral", "delta": 3}
					],
					"result_text": "Los viajeros comen junto al fuego. La aldea se siente más humana, aunque la despensa baja."
				},
				{
					"label": "Rechazarlos",
					"effects": [
						{"resource": "moral", "delta": -3},
						{"state": "ánimo", "delta": -1, "target": "all"}
					],
					"result_text": "Los viajeros siguen su camino. Nadie lo discute, pero el silencio pesa."
				}
			]
		},
		{
			"id": "old_tools_cache",
			"title": "Herramientas olvidadas",
			"location": "Almacén viejo",
			"weight": 4,
			"cooldown_days": 12,
			"description": "Aparece un pequeño lote de herramientas viejas bajo unas lonas podridas. No son nuevas, pero algo se puede aprovechar.",
			"options": [
				{
					"label": "Llevarlas a la herrería",
					"effects": [
						{"resource": "hierro", "delta": 3},
						{"resource": "seguridad", "delta": 1},
						{"state": "ánimo", "delta": 1, "target": "aldric"}
					],
					"result_text": "Aldric separa piezas útiles. No es un tesoro, pero sí una ayuda."
				},
				{
					"label": "Repartirlas entre vecinos",
					"effects": [
						{"resource": "moral", "delta": 2},
						{"resource": "madera", "delta": 1}
					],
					"result_text": "Varias casas aprovechan mangos, clavos y útiles. La noticia cae bien."
				}
			]
		}
	]
