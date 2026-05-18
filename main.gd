extends Control

const NPCDatabase = preload("res://data/npc_database.gd")
const EventDatabase = preload("res://data/event_database.gd")
const VillageState = preload("res://scripts/village_state.gd")
const EventSystem = preload("res://scripts/event_system.gd")
const DiarySystem = preload("res://scripts/diary_system.gd")

const DAY_TIMES := ["Mañana", "Tarde"]

var selected_npc_id: String = "aldric"
var village_state := VillageState.new()
var event_system := EventSystem.new()
var diary_system := DiarySystem.new()

@onready var title_label: Label = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent/TitleLabel
@onready var top_stats_label: Label = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent/TopStatsLabel
@onready var map_status_label: RichTextLabel = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/MapStatusLabel

@onready var context_panel: PanelContainer = $RootMargin/RootLayout/GameArea/ContextPanel
@onready var context_title_label: Label = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/ContextHeader/ContextTitleLabel
@onready var context_text_label: RichTextLabel = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/ContextTextLabel
@onready var npc_list: ItemList = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/NPCList
@onready var npc_info_label: RichTextLabel = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/NPCInfoLabel
@onready var close_context_button: Button = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/ContextHeader/CloseContextButton

@onready var people_button: Button = $RootMargin/RootLayout/BottomBar/BottomBarMargin/ActionBar/PeopleButton
@onready var chronicle_button: Button = $RootMargin/RootLayout/BottomBar/BottomBarMargin/ActionBar/ChronicleButton
@onready var management_button: Button = $RootMargin/RootLayout/BottomBar/BottomBarMargin/ActionBar/ManagementButton
@onready var quests_button: Button = $RootMargin/RootLayout/BottomBar/BottomBarMargin/ActionBar/QuestsButton
@onready var build_button: Button = $RootMargin/RootLayout/BottomBar/BottomBarMargin/ActionBar/BuildButton
@onready var advance_day_button: Button = $RootMargin/RootLayout/BottomBar/BottomBarMargin/ActionBar/AdvanceDayButton

@onready var forge_button: Button = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/ForgeButton
@onready var tavern_button: Button = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/TavernButton
@onready var well_button: Button = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/WellButton
@onready var farms_button: Button = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/FarmsButton
@onready var chapel_button: Button = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/ChapelButton
@onready var pastures_button: Button = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/PasturesButton

func _ready() -> void:
	village_state.setup(NPCDatabase.get_npc_order(), NPCDatabase.get_initial_npcs())
	event_system.setup(EventDatabase.get_events())
	diary_system.setup_initial_entry()
	populate_npc_list()
	connect_signals()
	update_all_ui()
	show_people_panel()

func connect_signals() -> void:
	advance_day_button.pressed.connect(_on_advance_day_pressed)
	close_context_button.pressed.connect(_on_close_context_pressed)
	npc_list.item_selected.connect(_on_npc_selected)
	people_button.pressed.connect(show_people_panel)
	chronicle_button.pressed.connect(show_chronicle_panel)
	management_button.pressed.connect(show_management_panel)
	quests_button.pressed.connect(show_quests_panel)
	build_button.pressed.connect(show_build_panel)
	forge_button.pressed.connect(func(): show_building_panel("Herrería", "Aldric · Gareth", "Forja, herramientas, reparaciones y futuras armas.", "El yunque marca el pulso material de Valdeniebla."))
	tavern_button.pressed.connect(func(): show_building_panel("Taberna", "Mara", "Rumores, moral, viajeros y futuras decisiones sociales.", "Aquí la aldea habla antes de saber qué piensa."))
	well_button.pressed.connect(func(): show_building_panel("Pozo", "Vecinos de paso", "Encuentros casuales, conversaciones breves y rumores pequeños.", "Todo el mundo acaba pasando por el pozo."))
	farms_button.pressed.connect(func(): show_building_panel("Granjas", "Bran", "Comida, cosechas, fatiga, clima y preparación del invierno.", "Si los campos fallan, toda la aldea lo nota."))
	chapel_button.pressed.connect(func(): show_building_panel("Capilla", "Tomas", "Crónica, memoria, mediación y primeras pistas de la trama principal.", "Las velas recuerdan más de lo que dicen."))
	pastures_button.pressed.connect(func(): show_building_panel("Prados", "Lysa", "Ganado, lindes, vigilancia rural y frontera exterior.", "Más allá de los prados empieza lo incierto."))

func populate_npc_list() -> void:
	npc_list.clear()
	for npc_id in village_state.npc_order:
		npc_list.add_item(village_state.npcs[npc_id]["name"])
	npc_list.select(0)

func _on_npc_selected(index: int) -> void:
	if index >= 0 and index < village_state.npc_order.size():
		selected_npc_id = village_state.npc_order[index]
		update_npc_panel()

func _on_close_context_pressed() -> void:
	context_panel.visible = false

func _on_advance_day_pressed() -> void:
	village_state.advance_day()
	for time_name in DAY_TIMES:
		var event_data = event_system.pick_event(village_state)
		event_system.apply_event(event_data, village_state)
		diary_system.add_entry(time_name, event_data, village_state)
	update_all_ui()

func update_all_ui() -> void:
	update_title()
	update_map_status()
	if context_panel.visible:
		update_npc_panel()

func update_title() -> void:
	var average_mood := village_state.get_average_state("ánimo")
	var average_stress := village_state.get_average_state("estrés")
	title_label.text = "Valdeniebla — %s, Año %d — Día %d" % [
		village_state.season,
		village_state.year,
		village_state.day
	]
	top_stats_label.text = "Ánimo %d/100   ·   Estrés %d/100   ·   Habitantes %d   ·   Crónica %d eventos" % [
		average_mood,
		average_stress,
		village_state.npc_order.size(),
		diary_system.diary_history.size()
	]

func update_map_status() -> void:
	var average_mood := village_state.get_average_state("ánimo")
	var average_stress := village_state.get_average_state("estrés")
	map_status_label.text = "[center][b]Pulso de la aldea[/b]\nÁnimo medio: %d/100 · Estrés medio: %d/100 · Habitantes: %d\nLa niebla baja aún se agarra a los tejados. Cada edificio es una futura puerta a tareas, recursos, quests y conflictos.[/center]" % [
		average_mood,
		average_stress,
		village_state.npc_order.size()
	]

func show_context(title: String, body: String, show_npcs: bool = false) -> void:
	context_panel.visible = true
	context_title_label.text = title
	context_text_label.text = body
	context_text_label.visible = body.strip_edges() != ""
	npc_list.visible = show_npcs
	npc_info_label.visible = show_npcs
	if show_npcs:
		update_npc_panel()

func show_people_panel() -> void:
	show_context(
		"Habitantes",
		"[b]Protagonistas[/b]\nLos habitantes principales tienen ficha, relaciones y futuras tramas personales.\n\nSelecciona un nombre para ver su estado.",
		true
	)

func show_chronicle_panel() -> void:
	show_context("Crónica", "\n\n".join(diary_system.get_recent_entries()), false)

func show_management_panel() -> void:
	show_context(
		"Gestión",
		"[b]Próximo sistema[/b]\nAquí irán recursos, prioridades, producción diaria, moral, seguridad y decisiones de aldea.\n\n[b]Objetivo[/b]\nQue el jugador piense antes de avanzar el día, no solo pulse un botón.",
		false
	)

func show_quests_panel() -> void:
	show_context(
		"Quests",
		"[b]Tramas futuras[/b]\n• Quest personal de Aldric y Gareth.\n• Primer misterio de la niebla.\n• Quests cruzadas entre protagonistas.\n• Eventos donde secundarios puedan ganar importancia.\n\nTodavía es placeholder: estructura primero, brillo después.",
		false
	)

func show_build_panel() -> void:
	show_context(
		"Construcción",
		"[b]Edificios futuros[/b]\nHerrería mejorada, almacén, viviendas, empalizada, puesto de mercado y mejoras de producción.\n\nEl mapa debe acabar mostrando el crecimiento visual de la aldea.",
		false
	)

func show_building_panel(building_name: String, people: String, role: String, flavor: String) -> void:
	show_context(
		building_name,
		"[b]Habitantes asociados[/b]\n%s\n\n[b]Función[/b]\n%s\n\n[i]%s[/i]" % [people, role, flavor],
		false
	)

func update_npc_panel() -> void:
	if not npc_info_label.visible:
		return
	var npc: Dictionary = village_state.npcs[selected_npc_id]
	var text := "[font_size=23][b]%s[/b][/font_size]\n%d años — %s\n[i]%s[/i]\n\n" % [
		npc["name"],
		int(npc["age"]),
		npc["profession"],
		npc["location"]
	]
	text += "[b]Rasgos[/b]\n%s\n\n" % ", ".join(npc["traits"])
	text += "[b]Habilidades[/b]\n%s\n\n" % format_dictionary(npc["stats"])
	text += "[b]Estado[/b]\n%s\n\n" % format_dictionary(npc["state"])
	text += "[b]Relaciones[/b]\n%s" % format_relationships(selected_npc_id)
	npc_info_label.text = text

func format_dictionary(values: Dictionary) -> String:
	var chunks: Array[String] = []
	for key in values.keys():
		chunks.append("%s: %d" % [String(key).capitalize(), int(values[key])])
	return " | ".join(chunks)

func format_relationships(npc_id: String) -> String:
	var chunks: Array[String] = []
	var relationships: Dictionary = village_state.npcs[npc_id]["relationships"]
	for other_id in village_state.npc_order:
		if other_id == npc_id:
			continue
		chunks.append("%s %+d" % [village_state.npcs[other_id]["name"], int(relationships.get(other_id, 0))])
	return "\n".join(chunks)
