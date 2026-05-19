extends Control

const NPCDatabase = preload("res://data/npc_database.gd")
const EventDatabase = preload("res://data/event_database.gd")
const ResourceDatabase = preload("res://data/resource_database.gd")
const BuildingDatabase = preload("res://data/building_database.gd")
const MonthlyStrategyDatabase = preload("res://data/monthly_strategy_database.gd")
const DecisionEventDatabase = preload("res://data/decision_event_database.gd")
const UiAssetDatabase = preload("res://data/ui_asset_database.gd")
const VillageState = preload("res://scripts/village_state.gd")
const EventSystem = preload("res://scripts/event_system.gd")
const DiarySystem = preload("res://scripts/diary_system.gd")

const DAY_TIMES := ["Mañana", "Tarde"]
const EVENT_FEED_LIFETIME := 5.0
const EVENT_FEED_FADE_TIME := 1.25
const MAX_VISIBLE_EVENT_FEED_MESSAGES := 4
const DECISION_EVENT_CHANCE := 0.35

var selected_npc_id: String = "aldric"
var village_state := VillageState.new()
var event_system := EventSystem.new()
var diary_system := DiarySystem.new()
var event_feed_panel: PanelContainer
var event_feed_container: VBoxContainer
var event_feed_empty_label: RichTextLabel
var resource_strip: HBoxContainer
var resource_value_labels: Dictionary = {}
var dynamic_context_buttons: Array[Button] = []

@onready var title_label: Label = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent/TitleLabel
@onready var top_stats_label: Label = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent/TopStatsLabel
@onready var map_content: Control = $RootMargin/RootLayout/GameArea/MapPanel/MapContent
@onready var village_map_view: VillageMapView = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/VillageMapView
@onready var map_status_label: RichTextLabel = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/MapStatusLabel

@onready var context_panel: PanelContainer = $RootMargin/RootLayout/GameArea/ContextPanel
@onready var context_title_label: Label = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/ContextHeader/ContextTitleLabel
@onready var context_content: VBoxContainer = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent
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

func _ready() -> void:
	village_state.setup(
		NPCDatabase.get_npc_order(),
		NPCDatabase.get_initial_npcs(),
		ResourceDatabase.get_initial_resources(),
		MonthlyStrategyDatabase.get_default_strategy_id(),
		BuildingDatabase.get_initial_buildings()
	)
	event_system.setup(EventDatabase.get_events())
	diary_system.setup_initial_entry()
	populate_npc_list()
	village_map_view.set_npcs(village_state.npcs)
	apply_visual_map_style()
	apply_translucent_context_style()
	create_resource_strip()
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
	village_map_view.building_selected.connect(show_building_panel)
	village_map_view.npc_selected.connect(show_npc_from_map)

func apply_visual_map_style() -> void:
	var map_panel: PanelContainer = $RootMargin/RootLayout/GameArea/MapPanel
	var map_style := StyleBoxFlat.new()
	map_style.bg_color = Color(0.055, 0.067, 0.055, 1.0)
	map_style.border_color = Color(0.52, 0.47, 0.31, 0.36)
	map_style.border_width_left = 1
	map_style.border_width_top = 1
	map_style.border_width_right = 1
	map_style.border_width_bottom = 1
	map_style.corner_radius_top_left = 0
	map_style.corner_radius_top_right = 0
	map_style.corner_radius_bottom_left = 0
	map_style.corner_radius_bottom_right = 0
	map_panel.add_theme_stylebox_override("panel", map_style)

	var top_bar: PanelContainer = $RootMargin/RootLayout/TopBar
	top_bar.add_theme_stylebox_override("panel", make_hud_panel_style(Color(0.035, 0.04, 0.044, 0.90), Color(0.72, 0.62, 0.38, 0.32), 0))

	var bottom_bar: PanelContainer = $RootMargin/RootLayout/BottomBar
	bottom_bar.add_theme_stylebox_override("panel", make_hud_panel_style(Color(0.04, 0.048, 0.052, 0.92), Color(0.72, 0.62, 0.38, 0.34), 0))

	for button: Button in [people_button, chronicle_button, management_button, quests_button, build_button]:
		button.add_theme_font_size_override("font_size", 17)

	advance_day_button.add_theme_font_size_override("font_size", 18)

func make_hud_panel_style(bg_color: Color, border_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 10
	style.content_margin_top = 8
	style.content_margin_right = 10
	style.content_margin_bottom = 8
	return style

func apply_translucent_context_style() -> void:
	context_panel.custom_minimum_size = Vector2(410, 0)
	context_panel.offset_right = 436.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.031, 0.034, 0.92)
	style.border_color = Color(0.72, 0.62, 0.38, 0.38)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	style.content_margin_left = 2
	style.content_margin_top = 2
	style.content_margin_right = 2
	style.content_margin_bottom = 2
	context_panel.add_theme_stylebox_override("panel", style)

func create_resource_strip() -> void:
	if resource_strip != null:
		return
	top_stats_label.visible = false
	var top_bar_content: BoxContainer = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent
	resource_strip = HBoxContainer.new()
	resource_strip.name = "ResourceIconStrip"
	resource_strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resource_strip.alignment = BoxContainer.ALIGNMENT_END
	resource_strip.add_theme_constant_override("separation", 8)
	top_bar_content.add_child(resource_strip)
	for resource_name: String in ResourceDatabase.get_resource_order():
		var chip := make_resource_chip(resource_name)
		resource_strip.add_child(chip)

func make_resource_chip(resource_name: String) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.name = "%sChip" % resource_name.capitalize()
	chip.tooltip_text = String(ResourceDatabase.get_resource_labels().get(resource_name, resource_name))
	chip.add_theme_stylebox_override("panel", make_resource_chip_style())
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_bottom", 3)
	chip.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	margin.add_child(row)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(22, 22)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_path := String(UiAssetDatabase.get_resource_icon_paths().get(resource_name, ""))
	if icon_path != "":
		icon.texture = load(icon_path)
	row.add_child(icon)
	var value_label := Label.new()
	value_label.add_theme_font_size_override("font_size", 16)
	value_label.add_theme_color_override("font_color", Color(0.88, 0.80, 0.64))
	value_label.text = "0"
	row.add_child(value_label)
	resource_value_labels[resource_name] = value_label
	return chip

func make_resource_chip_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.095, 0.07, 0.82)
	style.border_color = Color(0.65, 0.52, 0.30, 0.42)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style

func update_resource_strip() -> void:
	for resource_name: String in ResourceDatabase.get_resource_order():
		if resource_value_labels.has(resource_name):
			var label: Label = resource_value_labels[resource_name]
			label.text = str(village_state.get_resource(resource_name))

func create_event_feed_overlay() -> void:
	event_feed_panel = PanelContainer.new()
	event_feed_panel.name = "EventFeedPanel"
	event_feed_panel.visible = false
	event_feed_panel.clip_contents = true
	event_feed_panel.custom_minimum_size = Vector2(430, 230)
	event_feed_panel.anchor_left = 1.0
	event_feed_panel.anchor_top = 1.0
	event_feed_panel.anchor_right = 1.0
	event_feed_panel.anchor_bottom = 1.0
	event_feed_panel.offset_left = -466.0
	event_feed_panel.offset_top = -314.0
	event_feed_panel.offset_right = -28.0
	event_feed_panel.offset_bottom = -84.0
	event_feed_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.031, 0.034, 0.70)
	style.border_color = Color(0.72, 0.62, 0.38, 0.18)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	event_feed_panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.clip_contents = true
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	event_feed_panel.add_child(margin)

	event_feed_container = VBoxContainer.new()
	event_feed_container.clip_contents = true
	event_feed_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	event_feed_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	event_feed_container.alignment = BoxContainer.ALIGNMENT_END
	event_feed_container.add_theme_constant_override("separation", 5)
	margin.add_child(event_feed_container)

	event_feed_empty_label = RichTextLabel.new()
	event_feed_empty_label.visible = false
	event_feed_empty_label.bbcode_enabled = true
	event_feed_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_feed_empty_label.scroll_active = false
	event_feed_empty_label.fit_content = true
	event_feed_empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	event_feed_empty_label.text = ""
	event_feed_container.add_child(event_feed_empty_label)
	map_content.add_child(event_feed_panel)

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
	if village_state.has_pending_decision():
		show_decision_panel()
		add_event_feed_entry("Decisión pendiente", {"location": "Aldea", "title": "Resuelve la decisión antes de avanzar"})
		return
	village_state.advance_day()
	village_state.apply_daily_economy(ResourceDatabase, MonthlyStrategyDatabase)
	diary_system.add_daily_economy_entry(village_state)
	add_event_feed_entry("Balance", {"location": "Aldea", "title": get_daily_resource_feed_summary()})
	for time_name in DAY_TIMES:
		var event_data = event_system.pick_event(village_state)
		event_system.apply_event(event_data, village_state)
		diary_system.add_entry(time_name, event_data, village_state)
		add_event_feed_entry(time_name, event_data)
	try_spawn_decision_event()
	update_all_ui()
	refresh_open_context_panel()

func try_spawn_decision_event() -> void:
	if village_state.has_pending_decision():
		return
	if randf() > DECISION_EVENT_CHANCE:
		return
	var event_data := pick_decision_event()
	if event_data.is_empty():
		return
	village_state.set_pending_decision(event_data)
	add_event_feed_entry("Decisión", {"location": event_data.get("location", "Aldea"), "title": event_data.get("title", "Nueva decisión")})
	show_decision_panel()

func pick_decision_event() -> Dictionary:
	var candidates: Array[Dictionary] = []
	var total_weight := 0.0
	for event_data: Dictionary in DecisionEventDatabase.get_decision_events():
		var cooldown_days: int = int(event_data.get("cooldown_days", 0))
		if village_state.days_since_decision_event(event_data.get("id", "")) < cooldown_days:
			continue
		var weight := float(event_data.get("weight", 1.0))
		candidates.append({"event": event_data, "weight": weight})
		total_weight += weight
	if candidates.is_empty():
		return {}
	var roll := randf() * total_weight
	var cursor := 0.0
	for candidate: Dictionary in candidates:
		cursor += float(candidate["weight"])
		if roll <= cursor:
			return candidate["event"]
	return candidates[candidates.size() - 1]["event"]

func refresh_open_context_panel() -> void:
	if not context_panel.visible:
		return
	if context_title_label.text == "Gestión":
		show_management_panel()
	elif context_title_label.text == "Crónica":
		show_chronicle_panel()
	elif context_title_label.text == "Decisión":
		show_decision_panel()

func get_daily_resource_feed_summary() -> String:
	var chunks: Array[String] = []
	for change: Dictionary in village_state.last_daily_resource_changes:
		chunks.append("%s %+d" % [String(change["resource"]).capitalize(), int(change["delta"])])
	if chunks.is_empty():
		return "Sin cambios de recursos"
	return " · ".join(chunks)

func add_event_feed_entry(time_name: String, event_data: Dictionary) -> void:
	event_feed_panel.visible = true
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
	call_deferred("update_event_feed_panel_visibility")

func fade_event_feed_entry(entry_label: RichTextLabel) -> void:
	await get_tree().create_timer(EVENT_FEED_LIFETIME).timeout
	if not is_instance_valid(entry_label):
		return
	var fade_out := create_tween()
	fade_out.tween_property(entry_label, "modulate:a", 0.0, EVENT_FEED_FADE_TIME)
	await fade_out.finished
	if is_instance_valid(entry_label):
		entry_label.queue_free()
	call_deferred("update_event_feed_panel_visibility")

func update_event_feed_panel_visibility() -> void:
	if event_feed_panel == null or event_feed_container == null:
		return
	var has_active_messages := false
	for child in event_feed_container.get_children():
		if child.has_meta("event_feed_message") and not child.is_queued_for_deletion():
			has_active_messages = true
			break
	event_feed_panel.visible = has_active_messages

func update_all_ui() -> void:
	update_title()
	update_resource_strip()
	update_map_status()
	if context_panel.visible and npc_info_label.visible:
		update_npc_panel()

func update_title() -> void:
	title_label.text = "Valdeniebla — %s, Año %d — Mes %d, Día %d/%d" % [
		village_state.season,
		village_state.year,
		village_state.month,
		village_state.day_of_month,
		village_state.DAYS_PER_MONTH
	]

func update_map_status() -> void:
	var average_mood := village_state.get_average_state("ánimo")
	var average_stress := village_state.get_average_state("estrés")
	map_status_label.text = "[center][b]Pulso de la aldea[/b]\nÁnimo medio: %d/100 · Estrés medio: %d/100 · Habitantes: %d\nPrioridad mensual: %s · Comida: %d · Seguridad: %d[/center]" % [
		average_mood,
		average_stress,
		village_state.npc_order.size(),
		MonthlyStrategyDatabase.get_strategy_name(village_state.current_strategy_id),
		village_state.get_resource("comida"),
		village_state.get_resource("seguridad")
	]

func clear_dynamic_context_buttons() -> void:
	for button: Button in dynamic_context_buttons:
		if is_instance_valid(button):
			button.queue_free()
	dynamic_context_buttons.clear()

func reset_context_text_layout() -> void:
	clear_dynamic_context_buttons()
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
		var npc_index := village_state.npc_order.find(selected_npc_id)
		npc_list.select(maxi(0, npc_index))
		npc_list.ensure_current_is_visible()
		update_npc_panel()

func show_npc_from_map(npc_id: String) -> void:
	if not village_state.npcs.has(npc_id):
		return
	selected_npc_id = npc_id
	var npc_index := village_state.npc_order.find(npc_id)
	if npc_index >= 0:
		npc_list.select(npc_index)
	village_map_view.select_npc(npc_id)
	show_context("Habitantes", "", true)

func add_context_button(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.custom_minimum_size = Vector2(0, 38)
	button.pressed.connect(callback)
	context_content.add_child(button)
	dynamic_context_buttons.append(button)
	return button

func show_people_panel() -> void:
	show_context(
		"Habitantes",
		"[b]Protagonistas[/b]\nSelecciona un nombre para ver ficha, relaciones y futuras tramas.",
		true
	)

func show_chronicle_panel() -> void:
	clear_dynamic_context_buttons()
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
	show_context("Gestión", get_management_panel_text(), false)
	if village_state.is_start_of_month():
		for strategy_id: String in MonthlyStrategyDatabase.get_strategy_order():
			var strategy_name := MonthlyStrategyDatabase.get_strategy_name(strategy_id)
			var is_current := strategy_id == village_state.current_strategy_id
			add_context_button(strategy_name if not is_current else "✓ %s" % strategy_name, func(id := strategy_id): set_monthly_strategy(id), is_current)

func set_monthly_strategy(strategy_id: String) -> void:
	if not village_state.is_start_of_month():
		return
	village_state.set_monthly_strategy(strategy_id)
	add_event_feed_entry("Estrategia", {"location": "Casa comunal", "title": "Prioridad mensual: %s" % MonthlyStrategyDatabase.get_strategy_name(strategy_id)})
	show_management_panel()
	update_all_ui()

func get_management_panel_text() -> String:
	var strategy := MonthlyStrategyDatabase.get_strategy(village_state.current_strategy_id)
	var text := "[b]Calendario[/b]\nMes %d · Día %d/%d\n\n" % [village_state.month, village_state.day_of_month, village_state.DAYS_PER_MONTH]
	text += "[b]Prioridad mensual[/b]\n%s\n[i]%s[/i]\n" % [strategy.get("name", "Equilibrada"), strategy.get("description", "")]
	if village_state.is_start_of_month():
		text += "\nPuedes cambiar la prioridad al inicio del mes.\n"
	else:
		text += "\nLa prioridad se podrá cambiar al comenzar el próximo mes.\n"
	text += "\n[b]Oficios activos[/b]\n"
	for line: String in village_state.get_job_summary_lines():
		text += "%s\n" % colorize_job_status_line(line)
	text += "\n[b]Recursos[/b]\n"
	for resource_name: String in ResourceDatabase.get_resource_order():
		var label := String(ResourceDatabase.get_resource_labels().get(resource_name, resource_name))
		var icon_path := String(UiAssetDatabase.get_resource_icon_paths().get(resource_name, ""))
		if icon_path != "":
			text += "[img=18x18]%s[/img] %s: %d\n" % [icon_path, label, village_state.get_resource(resource_name)]
		else:
			text += "%s: %d\n" % [label, village_state.get_resource(resource_name)]
	text += "\n[b]Último balance[/b]\n"
	if village_state.last_daily_resource_changes.is_empty():
		text += "Aún no hay balance diario."
	else:
		for change: Dictionary in village_state.last_daily_resource_changes:
			text += "• %s %+d (%s)\n" % [String(change["resource"]).capitalize(), int(change["delta"]), String(change.get("source", "aldea"))]
	return text

func colorize_job_status_line(line: String) -> String:
	if line.ends_with("activo"):
		return "[color=#8aac73]%s[/color]" % line
	if line.ends_with("riesgo"):
		return "[color=#d09347]%s[/color]" % line
	if line.ends_with("bloqueado"):
		return "[color=#a33b35]%s[/color]" % line
	return line

func show_decision_panel() -> void:
	if not village_state.has_pending_decision():
		return
	var event_data: Dictionary = village_state.pending_decision_event
	show_context("Decisión", "[b]%s[/b]\n[i]%s[/i]\n\n%s\n\nElige una respuesta:" % [event_data.get("title", "Decisión"), event_data.get("location", "Aldea"), event_data.get("description", "")], false)
	for option_index in range(event_data.get("options", []).size()):
		var option_data: Dictionary = event_data["options"][option_index]
		var requirements: Dictionary = option_data.get("requirements", {})
		var can_pay := village_state.can_pay_requirements(requirements)
		var label := String(option_data.get("label", "Opción"))
		if not requirements.is_empty():
			label += " (%s)" % format_requirements(requirements)
		add_context_button(label, func(index := option_index): resolve_decision_option(index), not can_pay)

func resolve_decision_option(option_index: int) -> void:
	if not village_state.has_pending_decision():
		return
	var event_data: Dictionary = village_state.pending_decision_event
	var options: Array = event_data.get("options", [])
	if option_index < 0 or option_index >= options.size():
		return
	var option_data: Dictionary = options[option_index]
	if not village_state.can_pay_requirements(option_data.get("requirements", {})):
		return
	village_state.apply_decision_option(option_data)
	diary_system.add_decision_entry(event_data, option_data, village_state)
	add_event_feed_entry("Decisión", {"location": event_data.get("location", "Aldea"), "title": option_data.get("result_text", "Decisión resuelta")})
	update_all_ui()
	show_chronicle_panel()

func format_requirements(requirements: Dictionary) -> String:
	var chunks: Array[String] = []
	for resource_name: String in requirements.keys():
		chunks.append("%s %d" % [String(resource_name).capitalize(), int(requirements[resource_name])])
	return ", ".join(chunks)

func show_quests_panel() -> void:
	show_context(
		"Quests",
		"[b]Tramas futuras[/b]\n• Quest personal de Aldric y Gareth.\n• Primer misterio de la niebla.\n• Quests cruzadas entre protagonistas.\n• Eventos donde secundarios puedan ganar importancia.",
		false
	)

func show_build_panel() -> void:
	var text := "[b]Edificios registrados[/b]\n"
	for building_id: String in BuildingDatabase.get_building_order():
		var building: Dictionary = village_state.get_building(building_id)
		text += "• %s · Nivel %d · %s\n" % [building.get("name", building_id), int(building.get("level", 1)), building.get("status", "Sin estado")]
	text += "\n[b]Construcción real[/b]\nLas mejoras, costes y obras llegan en la siguiente capa. Esta PR solo crea la base de estado de edificios."
	show_context("Construcción", text, false)

func show_building_panel(building_id: String) -> void:
	if not village_state.has_building(building_id):
		show_context("Edificio", "No hay datos registrados para este edificio.", false)
		return
	village_map_view.select_building(building_id)
	var building: Dictionary = village_state.get_building(building_id)
	show_context(String(building.get("name", "Edificio")), get_building_panel_text(building), false)

func get_building_panel_text(building: Dictionary) -> String:
	var text := "[b]Nivel[/b]\n%d\n\n" % int(building.get("level", 1))
	text += "[b]Estado[/b]\n%s · %d/100\n\n" % [building.get("status", "Sin estado"), int(building.get("condition", 100))]
	text += "[b]Habitantes asociados[/b]\n%s\n\n" % format_worker_names(building.get("workers", []))
	text += "[b]Función[/b]\n%s\n\n" % building.get("function", "Sin función registrada.")
	text += "[b]Producción[/b]\n%s\n\n" % format_string_list(building.get("production", []), "Sin producción directa.")
	text += "[b]Costes[/b]\n%s\n\n" % format_string_list(building.get("costs", []), "Sin costes actuales.")
	text += "[b]Riesgos[/b]\n%s\n\n" % format_string_list(building.get("risks", []), "Sin riesgos registrados.")
	text += "[b]Mejora futura[/b]\n%s" % building.get("future_upgrade", "Sin mejora registrada.")
	return text

func format_worker_names(worker_ids: Array) -> String:
	if worker_ids.is_empty():
		return "Sin habitantes asignados."
	var names: Array[String] = []
	for worker_id: String in worker_ids:
		if village_state.npcs.has(worker_id):
			names.append(String(village_state.npcs[worker_id]["name"]))
		else:
			names.append(worker_id)
	return ", ".join(names)

func format_string_list(items: Array, empty_text: String) -> String:
	if items.is_empty():
		return empty_text
	var chunks: Array[String] = []
	for item: String in items:
		chunks.append("• %s" % item)
	return "\n".join(chunks)

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