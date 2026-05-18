extends Control

const NPCDatabase = preload("res://data/npc_database.gd")
const EventDatabase = preload("res://data/event_database.gd")
const VillageState = preload("res://scripts/village_state.gd")
const EventSystem = preload("res://scripts/event_system.gd")
const DiarySystem = preload("res://scripts/diary_system.gd")

const DAY_TIMES := ["Mañana", "Tarde"]
const EVENT_FEED_LIFETIME := 5.0
const EVENT_FEED_FADE_TIME := 1.25
const MAX_VISIBLE_EVENT_FEED_MESSAGES := 4

var selected_npc_id: String = "aldric"
var village_state := VillageState.new()
var event_system := EventSystem.new()
var diary_system := DiarySystem.new()
var event_feed_container: VBoxContainer
var event_feed_empty_label: RichTextLabel

@onready var title_label: Label = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent/TitleLabel
@onready var top_stats_label: Label = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent/TopStatsLabel
@onready var map_content: Control = $RootMargin/RootLayout/GameArea/MapPanel/MapContent
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
	apply_translucent_context_style()
	create_event_feed_overlay()
	connect_signals()
	update_all_ui()

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

func apply_translucent_context_style() -> void:
	context_panel.custom_minimum_size = Vector2(350, 0)
	context_panel.offset_right = 366.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.05, 0.035, 0.78)
	style.border_color = Color(0.64, 0.45, 0.18, 0.38)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	context_panel.add_theme_stylebox_override("panel", style)

func create_event_feed_overlay() -> void:
	var feed_panel := PanelContainer.new()
	feed_panel.name = "EventFeedPanel"
	feed_panel.clip_contents = true
	feed_panel.custom_minimum_size = Vector2(420, 210)
	feed_panel.anchor_left = 1.0
	feed_panel.anchor_top = 1.0
	feed_panel.anchor_right = 1.0
	feed_panel.anchor_bottom = 1.0
	feed_panel.offset_left = -455.0
	feed_panel.offset_top = -255.0
	feed_panel.offset_right = -32.0
	feed_panel.offset_bottom = -45.0
	feed_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.03, 0.02, 0.30)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	feed_panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.clip_contents = true
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	feed_panel.add_child(margin)

	event_feed_container = VBoxContainer.new()
	event_feed_container.clip_contents = true
	event_feed_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	event_feed_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	event_feed_container.alignment = BoxContainer.ALIGNMENT_END
	event_feed_container.add_theme_constant_override("separation", 5)
	margin.add_child(event_feed_container)

	event_feed_empty_label = RichTextLabel.new()
	event_feed_empty_label.bbcode_enabled = true
	event_feed_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_feed_empty_label.scroll_active = false
	event_feed_empty_label.fit_content = true
	event_feed_empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	event_feed_empty_label.text = "[b]Eventos recientes[/b]\n[color=#b8a890]Avanza el día para ver qué ocurre.[/color]"
	event_feed_container.add_child(event_feed_empty_label)
	map_content.add_child(feed_panel)

func populate_npc_list() -> void:
	npc_list.clear()
	for npc_id in village_state.npc_order:
		npc_list.add_item(village_state.npcs[npc_id]["name"])
	npc_list.select(0)
	npc_list.ensure_current_is_visible()

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
		add_event_feed_entry(time_name, event_data)
	update_all_ui()

func add_event_feed_entry(time_name: String, event_data: Dictionary) -> void:
	if event_feed_empty_label != null:
		event_feed_empty_label.visible = false
	var entry_label := RichTextLabel.new()
	entry_label.bbcode_enabled = true
	entry_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry_label.scroll_active = false
	entry_label.fit_content = true
	entry_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry_label.modulate.a = 0.0
	entry_label.set_meta("event_feed_message", true)
	entry_label.text = "[b]Día %d · %s[/b] — %s\n[color=#d9c9a8]%s[/color]" % [
		village_state.day,
		time_name,
		event_data.get("location", "Aldea"),
		event_data.get("title", "Suceso")
	]
	event_feed_container.add_child(entry_label)
	trim_event_feed_messages()
	var fade_in := create_tween()
	fade_in.tween_property(entry_label, "modulate:a", 1.0, 0.25)
	fade_event_feed_entry(entry_label)

func trim_event_feed_messages() -> void:
	var message_labels: Array[Node] = []
	for child in event_feed_container.get_children():
		if child.has_meta("event_feed_message"):
			message_labels.append(child)
	while message_labels.size() > MAX_VISIBLE_EVENT_FEED_MESSAGES:
		var oldest: Node = message_labels.pop_front() as Node
		if is_instance_valid(oldest):
			oldest.queue_free()

func fade_event_feed_entry(entry_label: RichTextLabel) -> void:
	await get_tree().create_timer(EVENT_FEED_LIFETIME).timeout
	if not is_instance_valid(entry_label):
		return
	var fade_out := create_tween()
	fade_out.tween_property(entry_label, "modulate:a", 0.0, EVENT_FEED_FADE_TIME)
	await fade_out.finished
	if is_instance_valid(entry_label):
		entry_label.queue_free()

func update_all_ui() -> void:
	update_title()
	update_map_status()
	if context_panel.visible and npc_info_label.visible:
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
	map_status_label.text = "[center][b]Pulso de la aldea[/b]\nÁnimo medio: %d/100 · Estrés medio: %d/100 · Habitantes: %d\nCada edificio será una puerta a tareas, recursos, quests y conflictos.[/center]" % [
		average_mood,
		average_stress,
		village_state.npc_order.size()
	]

func reset_context_text_layout() -> void:
	context_text_label.scroll_active = false
	context_text_label.fit_content = true
	context_text_label.custom_minimum_size = Vector2(320, 118)
	context_text_label.size_flags_vertical = Control.SIZE_FILL

func show_context(title: String, body: String, show_npcs: bool = false) -> void:
	reset_context_text_layout()
	context_panel.visible = true
	context_title_label.text = title
	context_text_label.text = body
	context_text_label.visible = body.strip_edges() != ""
	npc_list.visible = show_npcs
	npc_info_label.visible = show_npcs
	if show_npcs:
		npc_list.select(0)
		npc_list.ensure_current_is_visible()
		update_npc_panel()

func show_people_panel() -> void:
	show_context(
		"Habitantes",
		"[b]Protagonistas[/b]\nSelecciona un nombre para ver ficha, relaciones y futuras tramas.",
		true
	)

func show_chronicle_panel() -> void:
	context_panel.visible = true
	context_title_label.text = "Crónica"
	context_text_label.visible = true
	context_text_label.text = "\n\n".join(diary_system.diary_history)
	context_text_label.scroll_active = true
	context_text_label.fit_content = false
	context_text_label.custom_minimum_size = Vector2(320, 620)
	context_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	npc_list.visible = false
	npc_info_label.visible = false

func show_management_panel() -> void:
	show_context(
		"Gestión",
		"[b]Próximo sistema[/b]\nAquí irán recursos, prioridades, producción diaria, moral, seguridad y decisiones de aldea.\n\n[b]Objetivo[/b]\nQue el jugador piense antes de avanzar el día, no solo pulse un botón.",
		false
	)

func show_quests_panel() -> void:
	show_context(
		"Quests",
		"[b]Tramas futuras[/b]\n• Quest personal de Aldric y Gareth.\n• Primer misterio de la niebla.\n• Quests cruzadas entre protagonistas.\n• Eventos donde secundarios puedan ganar importancia.",
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
