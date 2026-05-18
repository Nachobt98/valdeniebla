extends Control

const MAX_DIARY_ENTRIES := 12
const DAY_TIMES := ["Mañana", "Tarde"]

var day: int = 1
var season: String = "Primavera"
var year: int = 1
var selected_npc_id: String = "aldric"

var diary_history: Array[String] = []

var npc_order := [
	"aldric",
	"gareth",
	"mara",
	"elowen",
	"bran",
	"lysa",
	"oren",
	"tomas"
]

var npcs := {
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

var events := [
	{
		"id": "aldric_forge_practice",
		"title": "Práctica en la herrería",
		"location": "Herrería",
		"actors": ["aldric", "gareth"],
		"text": "Gareth corrigió la técnica de Aldric mientras forjaban bisagras para las granjas. Aldric aprendió algo útil, aunque tragó orgullo más de una vez.",
		"effects": [
			{"target": "aldric", "stat": "forja", "delta": 1},
			{"from": "aldric", "to": "gareth", "relation_delta": -2},
			{"from": "gareth", "to": "aldric", "relation_delta": 1},
			{"target": "aldric", "state": "estrés", "delta": 4}
		]
	},
	{
		"id": "mara_well_conversation",
		"title": "Conversación junto al pozo",
		"location": "Pozo",
		"actors": ["aldric", "mara"],
		"text": "Mara encontró a Aldric junto al pozo y le sacó conversación sobre la herrería. Aldric intentó parecer tranquilo; no lo consiguió del todo.",
		"effects": [
			{"from": "aldric", "to": "mara", "relation_delta": 2},
			{"from": "mara", "to": "aldric", "relation_delta": 1},
			{"target": "aldric", "state": "ánimo", "delta": 4}
		]
	},
	{
		"id": "elowen_treats_bran",
		"title": "Fiebre en las granjas",
		"location": "Casa de curas",
		"actors": ["elowen", "bran"],
		"text": "Bran acudió a Elowen con fiebre leve tras una mañana de humedad en los campos. Elowen lo atendió sin hacer preguntas de más.",
		"effects": [
			{"target": "bran", "state": "salud", "delta": 5},
			{"target": "elowen", "state": "estrés", "delta": 3},
			{"from": "bran", "to": "elowen", "relation_delta": 3}
		]
	},
	{
		"id": "oren_public_request",
		"title": "Encargo del alcalde",
		"location": "Casa comunal",
		"actors": ["oren", "gareth", "aldric"],
		"text": "Oren pidió a la herrería que reparase herramientas comunales antes del mercado. Gareth aceptó el encargo, pero dejó claro que faltaban manos y hierro.",
		"effects": [
			{"target": "gareth", "state": "estrés", "delta": 5},
			{"target": "aldric", "stat": "forja", "delta": 1},
			{"from": "gareth", "to": "oren", "relation_delta": -1},
			{"from": "oren", "to": "gareth", "relation_delta": 1}
		]
	},
	{
		"id": "tavern_rumor",
		"title": "Rumores del camino norte",
		"location": "Taberna",
		"actors": ["mara", "tomas", "oren"],
		"text": "Un viajero dejó caer en la taberna que el camino norte está menos seguro. Mara escuchó con atención; Tomas lo anotó para la crónica local.",
		"effects": [
			{"target": "oren", "state": "estrés", "delta": 4},
			{"from": "tomas", "to": "mara", "relation_delta": 1},
			{"from": "mara", "to": "tomas", "relation_delta": 1}
		]
	},
	{
		"id": "lysa_bran_fence",
		"title": "Valla caída en los prados",
		"location": "Prados",
		"actors": ["lysa", "bran", "aldric"],
		"text": "Lysa y Bran discutieron por una valla caída. Aldric prometió preparar clavos nuevos antes del anochecer.",
		"effects": [
			{"target": "aldric", "stat": "forja", "delta": 1},
			{"target": "lysa", "state": "estrés", "delta": 3},
			{"from": "lysa", "to": "bran", "relation_delta": -2},
			{"from": "bran", "to": "lysa", "relation_delta": -1},
			{"from": "lysa", "to": "aldric", "relation_delta": 2}
		]
	},
	{
		"id": "elowen_avoids_aldric",
		"title": "Silencio incómodo",
		"location": "Plaza",
		"actors": ["elowen", "aldric"],
		"text": "Elowen evitó hablar con Aldric en la plaza. Aldric fingió no darse cuenta, pero el gesto no pasó desapercibido.",
		"effects": [
			{"from": "aldric", "to": "elowen", "relation_delta": -2},
			{"target": "aldric", "state": "ánimo", "delta": -3},
			{"target": "elowen", "state": "estrés", "delta": 1}
		]
	},
	{
		"id": "tomas_mediates",
		"title": "Mediación discreta",
		"location": "Capilla",
		"actors": ["tomas", "oren", "elowen"],
		"text": "Tomas habló con Oren y Elowen tras las tensiones de la semana. No resolvió gran cosa, pero al menos consiguió que se escucharan sin levantar la voz.",
		"effects": [
			{"target": "oren", "state": "estrés", "delta": -4},
			{"target": "elowen", "state": "estrés", "delta": -3},
			{"from": "oren", "to": "tomas", "relation_delta": 2},
			{"from": "elowen", "to": "tomas", "relation_delta": 1}
		]
	},
	{
		"id": "mara_defends_aldric",
		"title": "Defensa en la taberna",
		"location": "Taberna",
		"actors": ["mara", "aldric", "gareth"],
		"conditions": {"min_day": 3, "min_relation": {"from": "mara", "to": "aldric", "value": 12}},
		"text": "Cuando alguien se burló de los errores de Aldric, Mara salió en su defensa con una sonrisa afilada. Gareth observó la escena en silencio.",
		"effects": [
			{"from": "aldric", "to": "mara", "relation_delta": 4},
			{"from": "mara", "to": "aldric", "relation_delta": 2},
			{"target": "aldric", "state": "ánimo", "delta": 6},
			{"from": "gareth", "to": "mara", "relation_delta": 1}
		]
	},
	{
		"id": "aldric_overworks",
		"title": "Trabajo hasta tarde",
		"location": "Herrería",
		"actors": ["aldric", "gareth"],
		"conditions": {"min_day": 4, "min_state": {"target": "aldric", "state": "estrés", "value": 25}},
		"text": "Aldric se quedó en la herrería después de la puesta de sol para demostrar que podía con más de lo que Gareth esperaba. La pieza salió bien; él, no tanto.",
		"effects": [
			{"target": "aldric", "stat": "forja", "delta": 2},
			{"target": "aldric", "state": "salud", "delta": -4},
			{"target": "aldric", "state": "estrés", "delta": 7},
			{"from": "gareth", "to": "aldric", "relation_delta": 2}
		]
	}
]

@onready var title_label: Label = $RootLayout/TopBar/TitleLabel
@onready var npc_list: ItemList = $RootLayout/MainContent/LeftPanel/NPCMargin/NPCInfo/NPCList
@onready var npc_info_label: RichTextLabel = $RootLayout/MainContent/LeftPanel/NPCMargin/NPCInfo/NPCInfoLabel
@onready var village_overview_label: RichTextLabel = $RootLayout/MainContent/VillagePanel/VillageMargin/VillageOverviewLabel
@onready var diary_title_label: Label = $RootLayout/MainContent/RightPanel/NPCMargin/DiaryPanel/DiaryTitleLabel
@onready var diary_entries_label: RichTextLabel = $RootLayout/MainContent/RightPanel/NPCMargin/DiaryPanel/DiaryEntriesLabel
@onready var advance_day_button: Button = $RootLayout/MainContent/RightPanel/NPCMargin/DiaryPanel/AdvanceDayButton

func _ready() -> void:
	diary_history.append("[b]Día 1 — Amanecer[/b]\nValdeniebla despierta entre humo de chimeneas, barro reciente y rumores pequeños.")
	populate_npc_list()
	update_all_ui()
	advance_day_button.pressed.connect(_on_advance_day_pressed)
	npc_list.item_selected.connect(_on_npc_selected)

func populate_npc_list() -> void:
	npc_list.clear()
	for npc_id in npc_order:
		npc_list.add_item(npcs[npc_id]["name"])
	npc_list.select(0)

func _on_npc_selected(index: int) -> void:
	if index >= 0 and index < npc_order.size():
		selected_npc_id = npc_order[index]
		update_npc_panel()

func _on_advance_day_pressed() -> void:
	day += 1
	for time_name in DAY_TIMES:
		var event_data = pick_event()
		apply_event(event_data)
		add_diary_entry(time_name, event_data)
	update_all_ui()

func pick_event() -> Dictionary:
	var eligible_events: Array = []
	for event_data in events:
		if is_event_eligible(event_data):
			eligible_events.append(event_data)
	if eligible_events.is_empty():
		return events.pick_random()
	return eligible_events.pick_random()

func is_event_eligible(event_data: Dictionary) -> bool:
	if not event_data.has("conditions"):
		return true
	var conditions: Dictionary = event_data["conditions"]
	if conditions.has("min_day") and day < int(conditions["min_day"]):
		return false
	if conditions.has("min_relation"):
		var condition = conditions["min_relation"]
		if get_relation(condition["from"], condition["to"]) < int(condition["value"]):
			return false
	if conditions.has("min_state"):
		var condition = conditions["min_state"]
		if int(npcs[condition["target"]]["state"].get(condition["state"], 0)) < int(condition["value"]):
			return false
	return true

func apply_event(event_data: Dictionary) -> void:
	for effect in event_data["effects"]:
		if effect.has("stat"):
			change_stat(effect["target"], effect["stat"], int(effect["delta"]))
		elif effect.has("state"):
			change_state(effect["target"], effect["state"], int(effect["delta"]))
		elif effect.has("relation_delta"):
			change_relation(effect["from"], effect["to"], int(effect["relation_delta"]))

func change_stat(npc_id: String, stat_name: String, delta: int) -> void:
	var stats: Dictionary = npcs[npc_id]["stats"]
	stats[stat_name] = int(stats.get(stat_name, 0)) + delta

func change_state(npc_id: String, state_name: String, delta: int) -> void:
	var state: Dictionary = npcs[npc_id]["state"]
	state[state_name] = int(clamp(int(state.get(state_name, 0)) + delta, 0, 100))

func change_relation(from_id: String, to_id: String, delta: int) -> void:
	var relationships: Dictionary = npcs[from_id]["relationships"]
	relationships[to_id] = int(clamp(int(relationships.get(to_id, 0)) + delta, -100, 100))

func get_relation(from_id: String, to_id: String) -> int:
	return int(npcs[from_id]["relationships"].get(to_id, 0))

func add_diary_entry(time_name: String, event_data: Dictionary) -> void:
	var actors_text := get_actor_names(event_data["actors"])
	var consequences := format_effects(event_data["effects"])
	var entry := "[b]Día %d — %s, %s[/b]\n[i]%s[/i]\n%s\n\n[color=gray]Consecuencias: %s[/color]" % [
		day,
		time_name,
		event_data["location"],
		actors_text,
		event_data["text"],
		consequences
	]
	diary_history.append(entry)

func get_actor_names(actor_ids: Array) -> String:
	var names: Array[String] = []
	for actor_id in actor_ids:
		names.append(npcs[actor_id]["name"])
	return ", ".join(names)

func format_effects(effects: Array) -> String:
	var chunks: Array[String] = []
	for effect in effects:
		if effect.has("stat"):
			chunks.append("%s %s %+d" % [npcs[effect["target"]]["name"], effect["stat"].capitalize(), int(effect["delta"])])
		elif effect.has("state"):
			chunks.append("%s %s %+d" % [npcs[effect["target"]]["name"], effect["state"].capitalize(), int(effect["delta"])])
		elif effect.has("relation_delta"):
			chunks.append("%s → %s %+d" % [npcs[effect["from"]]["name"], npcs[effect["to"]]["name"], int(effect["relation_delta"])])
	return "; ".join(chunks)

func update_all_ui() -> void:
	update_title()
	update_npc_panel()
	update_village_overview()
	update_diary()

func update_title() -> void:
	title_label.text = "Valdeniebla — %s, Año %d — Día %d" % [season, year, day]

func update_npc_panel() -> void:
	var npc: Dictionary = npcs[selected_npc_id]
	var text := "[b]%s[/b]\n%d años — %s\n[i]%s[/i]\n\n" % [npc["name"], int(npc["age"]), npc["profession"], npc["location"]]
	text += "[b]Rasgos[/b]\n%s\n\n" % ", ".join(npc["traits"])
	text += "[b]Habilidades[/b]\n%s\n\n" % format_dictionary(npc["stats"])
	text += "[b]Estado[/b]\n%s\n\n" % format_dictionary(npc["state"])
	text += "[b]Relaciones[/b]\n%s" % format_relationships(selected_npc_id)
	npc_info_label.text = text

func update_village_overview() -> void:
	var average_mood := 0
	var average_stress := 0
	for npc_id in npc_order:
		average_mood += int(npcs[npc_id]["state"]["ánimo"])
		average_stress += int(npcs[npc_id]["state"]["estrés"])
	average_mood = int(average_mood / npc_order.size())
	average_stress = int(average_stress / npc_order.size())
	village_overview_label.text = "[center][b]Valdeniebla[/b][/center]\n\n" + \
		"[b]Estado de la aldea[/b]\nÁnimo medio: %d/100\nEstrés medio: %d/100\nHabitantes registrados: %d\n\n" % [average_mood, average_stress, npc_order.size()] + \
		"[b]Lugares actuales[/b]\nHerrería · Taberna · Pozo · Granjas · Prados · Capilla · Casa comunal\n\n" + \
		"[b]Lectura de diseño[/b]\nEl prototipo ya no gira solo alrededor de Aldric: cada día selecciona eventos con varios actores y modifica relaciones, estados y habilidades."

func update_diary() -> void:
	diary_title_label.text = "Crónica de la aldea"
	var recent_entries = diary_history.slice(max(0, diary_history.size() - MAX_DIARY_ENTRIES), diary_history.size())
	diary_entries_label.text = "\n\n".join(recent_entries)

func format_dictionary(values: Dictionary) -> String:
	var chunks: Array[String] = []
	for key in values.keys():
		chunks.append("%s: %d" % [String(key).capitalize(), int(values[key])])
	return " | ".join(chunks)

func format_relationships(npc_id: String) -> String:
	var chunks: Array[String] = []
	var relationships: Dictionary = npcs[npc_id]["relationships"]
	for other_id in npc_order:
		if other_id == npc_id:
			continue
		chunks.append("%s %+d" % [npcs[other_id]["name"], int(relationships.get(other_id, 0))])
	return "\n".join(chunks)
