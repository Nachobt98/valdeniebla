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
const NPC_STATE_BAR_SEGMENTS := 12
const MAP_POPUP_SIZE := Vector2(410.0, 280.0)

var selected_npc_id: String = "aldric"
var village_state := VillageState.new()
var event_system := EventSystem.new()
var diary_system := DiarySystem.new()
var event_feed_panel: PanelContainer
var event_feed_container: VBoxContainer
var event_feed_empty_label: RichTextLabel
var village_overview_panel: PanelContainer
var village_overview_content: VBoxContainer
var village_overview_expanded := false
var map_mode_panel: PanelContainer
var map_mode_buttons: Dictionary = {}
var map_popup_panel: PanelContainer
var map_popup_title: Label
var map_popup_content: VBoxContainer
var map_popup_dragging := false
var map_popup_drag_offset := Vector2.ZERO
var resource_strip: HBoxContainer
var resource_value_labels: Dictionary = {}
var dynamic_context_buttons: Array[Button] = []
var active_context_id := "map"

@onready var title_label: Label = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent/TitleLabel
@onready var top_stats_label: Label = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent/TopStatsLabel
@onready var top_bar_panel: PanelContainer = $RootMargin/RootLayout/TopBar
@onready var top_bar_content: BoxContainer = $RootMargin/RootLayout/TopBar/TopBarMargin/TopBarContent
@onready var map_content: Control = $RootMargin/RootLayout/GameArea/MapPanel/MapContent
@onready var village_map_view: VillageMapView = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/VillageMapView
@onready var map_title_label: Label = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/MapTitleLabel
@onready var map_hint_label: RichTextLabel = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/MapHintLabel
@onready var map_status_label: RichTextLabel = $RootMargin/RootLayout/GameArea/MapPanel/MapContent/MapStatusLabel

@onready var context_panel: PanelContainer = $RootMargin/RootLayout/GameArea/ContextPanel
@onready var context_title_label: Label = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/ContextHeader/ContextTitleLabel
@onready var context_content: VBoxContainer = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent
@onready var context_text_label: RichTextLabel = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/ContextTextLabel
@onready var npc_list: ItemList = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/NPCList
@onready var npc_info_label: RichTextLabel = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/NPCInfoLabel
@onready var close_context_button: Button = $RootMargin/RootLayout/GameArea/ContextPanel/ContextMargin/ContextContent/ContextHeader/CloseContextButton

@onready var bottom_bar_panel: PanelContainer = $RootMargin/RootLayout/BottomBar
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
	apply_map_first_hud_layout()
	apply_visual_map_style()
	apply_translucent_context_style()
	create_resource_strip()
	create_village_overview_panel()
	create_map_mode_panel()
	create_map_context_popup()
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

func _input(event: InputEvent) -> void:
	if not map_popup_dragging:
		return
	if event is InputEventMouseMotion:
		var mouse_event := event as InputEventMouseMotion
		var local_mouse: Vector2 = mouse_event.global_position - map_content.global_position
		place_map_popup(clamp_map_popup_position(local_mouse - map_popup_drag_offset))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		map_popup_dragging = false

func apply_map_first_hud_layout() -> void:
	var root_layout: VBoxContainer = $RootMargin/RootLayout
	var game_area: Control = $RootMargin/RootLayout/GameArea
	root_layout.move_child(game_area, 0)
	top_bar_panel.reparent(map_content)
	bottom_bar_panel.reparent(map_content)
	top_bar_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar_panel.offset_left = 24.0
	top_bar_panel.offset_top = 26.0
	top_bar_panel.offset_right = -24.0
	top_bar_panel.offset_bottom = 94.0
	top_bar_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	bottom_bar_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_bar_panel.offset_left = 24.0
	bottom_bar_panel.offset_top = -104.0
	bottom_bar_panel.offset_right = -24.0
	bottom_bar_panel.offset_bottom = -18.0
	bottom_bar_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	title_label.visible = false
	map_title_label.offset_top = 104.0
	map_title_label.offset_bottom = 142.0
	map_hint_label.offset_top = 144.0
	map_hint_label.offset_bottom = 196.0

func apply_visual_map_style() -> void:
	var map_panel: PanelContainer = $RootMargin/RootLayout/GameArea/MapPanel
	var map_style := StyleBoxFlat.new()
	map_style.bg_color = Color(0.035, 0.045, 0.037, 1.0)
	map_style.border_color = Color(0.50, 0.43, 0.27, 0.44)
	map_style.border_width_left = 1
	map_style.border_width_top = 1
	map_style.border_width_right = 1
	map_style.border_width_bottom = 1
	map_style.corner_radius_top_left = 0
	map_style.corner_radius_top_right = 0
	map_style.corner_radius_bottom_left = 0
	map_style.corner_radius_bottom_right = 0
	map_panel.add_theme_stylebox_override("panel", map_style)

	top_bar_panel.custom_minimum_size = Vector2(0, 0)
	top_bar_panel.add_theme_stylebox_override("panel", make_hud_panel_style(Color(0.020, 0.023, 0.024, 0.0), Color(0.66, 0.54, 0.32, 0.0), 0))
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color(0.93, 0.86, 0.66))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.72))

	bottom_bar_panel.custom_minimum_size = Vector2(0, 0)
	bottom_bar_panel.add_theme_stylebox_override("panel", make_hud_panel_style(Color(0.022, 0.026, 0.027, 0.0), Color(0.66, 0.54, 0.32, 0.0), 0))

	for button: Button in [people_button, chronicle_button, management_button, quests_button, build_button]:
		button.add_theme_font_size_override("font_size", 16)
		button.custom_minimum_size = Vector2(196, 70)
		apply_action_button_style(button, false)
		button.add_theme_color_override("font_color", Color(0.84, 0.79, 0.66))

	advance_day_button.custom_minimum_size = Vector2(232, 70)
	advance_day_button.add_theme_font_size_override("font_size", 18)
	apply_important_button_style(advance_day_button)
	advance_day_button.add_theme_color_override("font_color", Color(0.98, 0.88, 0.62))

	map_title_label.add_theme_color_override("font_color", Color(0.94, 0.86, 0.66))
	map_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.72))
	map_title_label.add_theme_constant_override("shadow_offset_x", 2)
	map_title_label.add_theme_constant_override("shadow_offset_y", 2)
	map_hint_label.add_theme_color_override("default_color", Color(0.86, 0.80, 0.66))
	map_status_label.visible = false

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

func make_button_style(bg_color: Color, border_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 14
	style.content_margin_top = 9
	style.content_margin_right = 14
	style.content_margin_bottom = 9
	return style

func make_textured_style(asset_path: String, fallback: StyleBox, margin: int = 24, content_margins: Vector4 = Vector4(14, 9, 14, 9), tint: Color = Color.WHITE) -> StyleBox:
	var texture := UiAssetDatabase.load_texture(asset_path)
	if texture == null:
		return fallback
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = margin
	style.texture_margin_top = margin
	style.texture_margin_right = margin
	style.texture_margin_bottom = margin
	style.content_margin_left = content_margins.x
	style.content_margin_top = content_margins.y
	style.content_margin_right = content_margins.z
	style.content_margin_bottom = content_margins.w
	style.modulate_color = tint
	return style

func apply_action_button_style(button: Button, selected: bool) -> void:
	var asset_path := String(UiAssetDatabase.get_button_asset_paths().get("default", ""))
	var normal_tint := Color(0.90, 0.84, 0.70, 1.0)
	var hover_tint := Color(1.08, 0.96, 0.72, 1.0)
	var pressed_tint := Color(0.78, 0.64, 0.42, 1.0)
	if selected:
		normal_tint = Color(1.18, 0.96, 0.58, 1.0)
		hover_tint = Color(1.28, 1.04, 0.66, 1.0)
		pressed_tint = Color(1.0, 0.78, 0.44, 1.0)
		button.add_theme_stylebox_override("normal", make_textured_style(
			asset_path,
			make_button_style(Color(0.115, 0.080, 0.045, 1.0), Color(0.92, 0.69, 0.34, 0.95), 7),
			38,
			Vector4(34, 19, 34, 19),
			normal_tint
		))
	else:
		button.add_theme_stylebox_override("normal", make_textured_style(
			asset_path,
			make_button_style(Color(0.045, 0.050, 0.047, 0.92), Color(0.50, 0.43, 0.28, 0.44), 7),
			38,
			Vector4(34, 19, 34, 19),
			normal_tint
		))
	button.add_theme_stylebox_override("hover", make_textured_style(
		asset_path,
		make_button_style(Color(0.075, 0.068, 0.052, 1.0), Color(0.78, 0.62, 0.34, 0.82), 7),
		38,
		Vector4(34, 19, 34, 19),
		hover_tint
	))
	button.add_theme_stylebox_override("pressed", make_textured_style(
		asset_path,
		make_button_style(Color(0.10, 0.075, 0.045, 1.0), Color(0.90, 0.68, 0.34, 0.95), 7),
		38,
		Vector4(34, 19, 34, 19),
		pressed_tint
	))

func apply_important_button_style(button: Button) -> void:
	var asset_path := String(UiAssetDatabase.get_button_asset_paths().get("important", ""))
	button.add_theme_stylebox_override("normal", make_textured_style(
		asset_path,
		make_button_style(Color(0.18, 0.105, 0.045, 0.98), Color(0.88, 0.62, 0.30, 0.72), 7),
		38,
		Vector4(34, 19, 34, 19),
		Color(1.05, 0.86, 0.54, 1.0)
	))
	button.add_theme_stylebox_override("hover", make_textured_style(
		asset_path,
		make_button_style(Color(0.24, 0.135, 0.055, 1.0), Color(1.0, 0.74, 0.38, 0.95), 7),
		38,
		Vector4(34, 19, 34, 19),
		Color(1.24, 0.98, 0.62, 1.0)
	))
	button.add_theme_stylebox_override("pressed", make_textured_style(
		asset_path,
		make_button_style(Color(0.11, 0.065, 0.035, 1.0), Color(1.0, 0.80, 0.42, 1.0), 7),
		38,
		Vector4(34, 19, 34, 19),
		Color(0.92, 0.64, 0.34, 1.0)
	))

func make_panel_style(bg_color: Color = Color(0.020, 0.025, 0.026, 0.94), border_color: Color = Color(0.75, 0.61, 0.34, 0.46), radius: int = 8) -> StyleBoxFlat:
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
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	return style

func make_map_popup_style() -> StyleBoxFlat:
	var style := make_panel_style(Color(0.018, 0.022, 0.021, 0.92), Color(0.86, 0.66, 0.34, 0.72), 8)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.content_margin_left = 18
	style.content_margin_top = 16
	style.content_margin_right = 18
	style.content_margin_bottom = 16
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 5)
	return style

func apply_translucent_context_style() -> void:
	context_panel.anchor_left = 0.0
	context_panel.anchor_top = 0.0
	context_panel.anchor_right = 0.0
	context_panel.anchor_bottom = 1.0
	context_panel.offset_left = 20.0
	context_panel.offset_top = 24.0
	context_panel.offset_right = 440.0
	context_panel.offset_bottom = -126.0
	context_panel.custom_minimum_size = Vector2(420, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.020, 0.025, 0.026, 0.95)
	style.border_color = Color(0.75, 0.61, 0.34, 0.52)
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
	context_title_label.add_theme_color_override("font_color", Color(0.96, 0.87, 0.64))
	close_context_button.text = "×"
	close_context_button.tooltip_text = "Cerrar panel"
	close_context_button.add_theme_stylebox_override("normal", make_button_style(Color(0.05, 0.055, 0.052, 0.95), Color(0.65, 0.56, 0.36, 0.55), 7))
	close_context_button.add_theme_stylebox_override("hover", make_button_style(Color(0.10, 0.08, 0.06, 1.0), Color(0.90, 0.70, 0.40, 0.9), 7))

func create_resource_strip() -> void:
	if resource_strip != null:
		return
	top_stats_label.visible = false
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
	chip.custom_minimum_size = Vector2(94, 42)
	chip.tooltip_text = String(ResourceDatabase.get_resource_labels().get(resource_name, resource_name))
	chip.add_theme_stylebox_override("panel", make_resource_chip_style())
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	chip.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	margin.add_child(row)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(24, 24)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_path := String(UiAssetDatabase.get_generated_resource_icon_paths().get(resource_name, ""))
	if icon_path != "":
		icon.texture = UiAssetDatabase.load_texture(icon_path)
	row.add_child(icon)
	var text_stack := VBoxContainer.new()
	text_stack.custom_minimum_size = Vector2(48, 0)
	text_stack.add_theme_constant_override("separation", -3)
	row.add_child(text_stack)
	var caption := Label.new()
	caption.text = String(ResourceDatabase.get_resource_labels().get(resource_name, resource_name)).to_upper()
	caption.add_theme_font_size_override("font_size", 9)
	caption.add_theme_color_override("font_color", Color(0.58, 0.52, 0.40))
	text_stack.add_child(caption)
	var value_label := Label.new()
	value_label.add_theme_font_size_override("font_size", 16)
	value_label.add_theme_color_override("font_color", Color(0.93, 0.82, 0.58))
	value_label.text = "0"
	text_stack.add_child(value_label)
	resource_value_labels[resource_name] = value_label
	return chip

func make_resource_chip_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.075, 0.050, 0.88)
	style.border_color = Color(0.72, 0.55, 0.30, 0.52)
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

func create_map_mode_panel() -> void:
	map_mode_panel = PanelContainer.new()
	map_mode_panel.name = "MapModePanel"
	map_mode_panel.anchor_left = 0.0
	map_mode_panel.anchor_top = 0.0
	map_mode_panel.anchor_right = 0.0
	map_mode_panel.anchor_bottom = 0.0
	map_mode_panel.offset_left = 24.0
	map_mode_panel.offset_top = 24.0
	map_mode_panel.offset_right = 262.0
	map_mode_panel.offset_bottom = 70.0
	map_mode_panel.add_theme_stylebox_override("panel", make_panel_style(Color(0.018, 0.022, 0.020, 0.38), Color(0.64, 0.52, 0.30, 0.18), 7))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	map_mode_panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	margin.add_child(row)
	row.add_child(make_map_mode_button("normal", "Mapa", "Mapa normal", Vector2(62, 32)))
	row.add_child(make_map_mode_button("recursos", "Rec.", "Recursos", Vector2(58, 32)))
	row.add_child(make_map_mode_button("riesgo", "Riesgo", "Riesgo y seguridad", Vector2(78, 32)))
	map_content.add_child(map_mode_panel)
	set_map_mode("normal")

func make_map_mode_button(mode: String, label_text: String, tooltip: String, minimum_size: Vector2) -> Button:
	var button := Button.new()
	button.text = label_text
	button.tooltip_text = tooltip
	button.custom_minimum_size = minimum_size
	button.add_theme_font_size_override("font_size", 13)
	button.pressed.connect(func(): set_map_mode(mode))
	map_mode_buttons[mode] = button
	return button

func set_map_mode(mode: String) -> void:
	if map_popup_panel != null:
		map_popup_panel.visible = false
	village_map_view.set_map_mode(mode)
	for mode_id: String in map_mode_buttons.keys():
		var button: Button = map_mode_buttons[mode_id]
		if mode_id == mode:
			button.add_theme_stylebox_override("normal", make_button_style(Color(0.12, 0.08, 0.04, 0.96), Color(0.92, 0.68, 0.34, 0.90), 6))
			button.add_theme_color_override("font_color", Color(0.98, 0.88, 0.62))
		else:
			button.add_theme_stylebox_override("normal", make_button_style(Color(0.035, 0.040, 0.037, 0.82), Color(0.50, 0.43, 0.28, 0.32), 6))
			button.add_theme_color_override("font_color", Color(0.80, 0.74, 0.62))
		button.add_theme_stylebox_override("hover", make_button_style(Color(0.075, 0.063, 0.042, 0.96), Color(0.78, 0.61, 0.32, 0.72), 6))
		button.add_theme_stylebox_override("pressed", make_button_style(Color(0.11, 0.075, 0.040, 1.0), Color(0.90, 0.68, 0.34, 0.90), 6))

func create_map_context_popup() -> void:
	map_popup_panel = PanelContainer.new()
	map_popup_panel.name = "MapContextPopup"
	map_popup_panel.visible = false
	map_popup_panel.anchor_left = 0.0
	map_popup_panel.anchor_top = 0.0
	map_popup_panel.anchor_right = 0.0
	map_popup_panel.anchor_bottom = 0.0
	map_popup_panel.custom_minimum_size = MAP_POPUP_SIZE
	map_popup_panel.size = MAP_POPUP_SIZE
	map_popup_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	map_popup_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	map_popup_panel.add_theme_stylebox_override("panel", make_map_popup_style())
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	map_popup_panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	margin.add_child(content)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	header.mouse_filter = Control.MOUSE_FILTER_STOP
	header.mouse_default_cursor_shape = Control.CURSOR_MOVE
	header.tooltip_text = "Arrastrar tarjeta"
	header.gui_input.connect(_on_map_popup_header_input)
	content.add_child(header)
	map_popup_title = Label.new()
	map_popup_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_popup_title.add_theme_font_size_override("font_size", 20)
	map_popup_title.add_theme_color_override("font_color", Color(0.96, 0.86, 0.60))
	header.add_child(map_popup_title)
	var close_button := Button.new()
	close_button.text = "×"
	close_button.custom_minimum_size = Vector2(34, 30)
	close_button.add_theme_stylebox_override("normal", make_button_style(Color(0.035, 0.038, 0.034, 0.55), Color(0.50, 0.42, 0.26, 0.30), 6))
	close_button.add_theme_stylebox_override("hover", make_button_style(Color(0.11, 0.06, 0.04, 0.86), Color(0.86, 0.60, 0.34, 0.80), 6))
	close_button.pressed.connect(func(): map_popup_panel.visible = false)
	header.add_child(close_button)
	map_popup_content = VBoxContainer.new()
	map_popup_content.add_theme_constant_override("separation", 8)
	map_popup_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(map_popup_content)
	map_content.add_child(map_popup_panel)

func _on_map_popup_header_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_event := event as InputEventMouseButton
		map_popup_dragging = event.pressed
		if event.pressed:
			enforce_map_popup_size()
			map_popup_drag_offset = mouse_event.global_position - map_popup_panel.global_position
			map_popup_panel.move_to_front()

func show_map_popup_at(title: String, screen_position: Vector2) -> void:
	context_panel.visible = false
	map_popup_title.text = title
	map_popup_panel.visible = true
	place_map_popup(get_clamped_map_popup_position(screen_position))
	map_popup_panel.move_to_front()
	map_popup_panel.call_deferred("set_size", MAP_POPUP_SIZE)
	call_deferred("place_map_popup", map_popup_panel.position)

func place_map_popup(position: Vector2) -> void:
	map_popup_panel.position = position
	map_popup_panel.size = MAP_POPUP_SIZE
	map_popup_panel.offset_left = position.x
	map_popup_panel.offset_top = position.y
	map_popup_panel.offset_right = position.x + MAP_POPUP_SIZE.x
	map_popup_panel.offset_bottom = position.y + MAP_POPUP_SIZE.y

func enforce_map_popup_size() -> void:
	place_map_popup(map_popup_panel.position)

func get_clamped_map_popup_position(screen_position: Vector2) -> Vector2:
	var popup_size := MAP_POPUP_SIZE
	var position := screen_position + Vector2(26.0, -18.0)
	if position.x + popup_size.x > map_content.size.x - 18.0:
		position.x = screen_position.x - popup_size.x - 26.0
	if position.y + popup_size.y > map_content.size.y - 126.0:
		position.y = map_content.size.y - popup_size.y - 126.0
	position.x = clamp(position.x, 18.0, maxf(18.0, map_content.size.x - popup_size.x - 18.0))
	position.y = clamp(position.y, 88.0, maxf(88.0, map_content.size.y - popup_size.y - 126.0))
	return position

func clamp_map_popup_position(position: Vector2) -> Vector2:
	var popup_size := MAP_POPUP_SIZE
	var max_x := maxf(18.0, map_content.size.x - popup_size.x - 18.0)
	var max_y := maxf(88.0, map_content.size.y - popup_size.y - 126.0)
	return Vector2(
		clamp(position.x, 18.0, max_x),
		clamp(position.y, 88.0, max_y)
	)

func create_village_overview_panel() -> void:
	village_overview_panel = PanelContainer.new()
	village_overview_panel.name = "VillageOverviewPanel"
	village_overview_panel.custom_minimum_size = Vector2(222, 0)
	village_overview_panel.anchor_left = 1.0
	village_overview_panel.anchor_top = 0.0
	village_overview_panel.anchor_right = 1.0
	village_overview_panel.anchor_bottom = 0.0
	village_overview_panel.offset_left = -246.0
	village_overview_panel.offset_top = 104.0
	village_overview_panel.offset_right = -24.0
	village_overview_panel.offset_bottom = 220.0
	village_overview_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	village_overview_panel.add_theme_stylebox_override("panel", make_panel_style(Color(0.018, 0.022, 0.022, 0.66), Color(0.70, 0.58, 0.34, 0.26), 8))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	village_overview_panel.add_child(margin)
	village_overview_content = VBoxContainer.new()
	village_overview_content.add_theme_constant_override("separation", 4)
	margin.add_child(village_overview_content)
	map_content.add_child(village_overview_panel)

func update_village_overview_panel() -> void:
	if village_overview_content == null:
		return
	for child in village_overview_content.get_children():
		child.queue_free()
	add_overview_title()
	if village_overview_expanded:
		add_overview_mood_row()
		add_overview_warning_row()
	else:
		add_overview_compact_summary()
	village_map_view.set_building_statuses(get_building_visual_statuses())

func add_overview_title() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	village_overview_content.add_child(row)
	var title := Label.new()
	title.text = "Consejo"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.96, 0.86, 0.60))
	row.add_child(title)
	var toggle := Button.new()
	toggle.text = "-" if village_overview_expanded else "+"
	toggle.tooltip_text = "Mostrar detalle" if not village_overview_expanded else "Ocultar detalle"
	toggle.custom_minimum_size = Vector2(28, 26)
	toggle.add_theme_font_size_override("font_size", 15)
	toggle.add_theme_stylebox_override("normal", make_button_style(Color(0.035, 0.040, 0.036, 0.60), Color(0.55, 0.46, 0.28, 0.28), 5))
	toggle.add_theme_stylebox_override("hover", make_button_style(Color(0.09, 0.07, 0.045, 0.92), Color(0.86, 0.66, 0.34, 0.70), 5))
	toggle.pressed.connect(toggle_village_overview)
	row.add_child(toggle)
	var subtitle := Label.new()
	subtitle.text = "Prioridad: %s" % MonthlyStrategyDatabase.get_strategy_name(village_state.current_strategy_id)
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", Color(0.65, 0.58, 0.44))
	village_overview_content.add_child(subtitle)

func toggle_village_overview() -> void:
	village_overview_expanded = not village_overview_expanded
	village_overview_panel.offset_bottom = 312.0 if village_overview_expanded else 220.0
	update_village_overview_panel()

func add_overview_compact_summary() -> void:
	var summary := Label.new()
	summary.text = "Ánimo %d  ·  Estrés %d" % [
		village_state.get_average_state("ánimo"),
		village_state.get_average_state("estrés")
	]
	summary.add_theme_font_size_override("font_size", 13)
	summary.add_theme_color_override("font_color", Color(0.86, 0.80, 0.64))
	village_overview_content.add_child(summary)

func add_overview_mood_row() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	village_overview_content.add_child(row)
	row.add_child(make_metric_card("Ánimo", village_state.get_average_state("ánimo"), false))
	row.add_child(make_metric_card("Estrés", village_state.get_average_state("estrés"), true))

func make_metric_card(label_text: String, value: int, inverted: bool) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", make_panel_style(Color(0.035, 0.041, 0.038, 0.68), Color(0.50, 0.42, 0.26, 0.22), 7))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 3)
	card.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 3)
	margin.add_child(content)
	var name_label := Label.new()
	name_label.text = label_text.to_upper()
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color(0.62, 0.55, 0.42))
	content.add_child(name_label)
	var value_label := Label.new()
	value_label.text = "%d/100" % value
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.add_theme_color_override("font_color", Color.html(get_state_color(value, inverted)))
	content.add_child(value_label)
	return card

func clear_map_popup_content() -> void:
	for child in map_popup_content.get_children():
		child.queue_free()

func add_map_popup_label(text: String, font_size: int, color: Color, bold := false) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if bold:
		label.add_theme_font_override("font", get_theme_font("bold", "Label"))
	map_popup_content.add_child(label)
	return label

func add_map_popup_section(text: String) -> void:
	var label := add_map_popup_label(text, 17, Color(0.96, 0.87, 0.64), true)
	label.custom_minimum_size = Vector2(0, 20)

func add_map_popup_action(text: String) -> void:
	var label := add_map_popup_label(text, 15, Color(0.86, 0.75, 0.50), false)
	label.custom_minimum_size = Vector2(0, 24)

func add_map_popup_stat_row(label_text: String, value: int, inverted: bool) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_popup_content.add_child(row)
	var name_label := Label.new()
	name_label.text = label_text
	name_label.custom_minimum_size = Vector2(58, 0)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(0.90, 0.84, 0.70))
	row.add_child(name_label)
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(150, 12)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_theme_stylebox_override("background", make_button_style(Color(0.035, 0.038, 0.034, 0.90), Color(0.42, 0.34, 0.20, 0.40), 3))
	bar.add_theme_stylebox_override("fill", make_button_style(Color.html(get_state_color(value, inverted)), Color(0, 0, 0, 0), 3))
	row.add_child(bar)
	var value_label := Label.new()
	value_label.text = "%d/100" % value
	value_label.custom_minimum_size = Vector2(56, 0)
	value_label.add_theme_font_size_override("font_size", 15)
	value_label.add_theme_color_override("font_color", Color(0.96, 0.87, 0.64))
	row.add_child(value_label)

func add_overview_warning_row() -> void:
	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.fit_content = true
	text.scroll_active = false
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.text = get_village_warning_text()
	text.add_theme_font_size_override("normal_font_size", 13)
	village_overview_content.add_child(text)

func get_village_warning_text() -> String:
	var food := village_state.get_resource("comida")
	var medicine := village_state.get_resource("medicina")
	var security := village_state.get_resource("seguridad")
	if food <= 35:
		return "[color=#d09347][b]Alerta[/b][/color]\nLas reservas de comida empiezan a tensar la rutina."
	if medicine <= 5:
		return "[color=#d09347][b]Alerta[/b][/color]\nLa casa de curas necesita hierbas antes de que llegue una crisis."
	if security <= 20:
		return "[color=#a33b35][b]Riesgo[/b][/color]\nLas rondas son escasas y la frontera se siente abierta."
	return "[color=#8aac73][b]Estable[/b][/color]\nLa aldea aguanta el día, aunque la niebla no retrocede."

func add_overview_building_watch() -> void:
	var header := Label.new()
	header.text = "Edificios clave"
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", Color(0.88, 0.78, 0.55))
	village_overview_content.add_child(header)
	for building_id in ["communal_house", "forge", "farms", "healers_house", "pastures"]:
		village_overview_content.add_child(make_building_watch_row(building_id))

func make_building_watch_row(building_id: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	var marker := ColorRect.new()
	marker.custom_minimum_size = Vector2(7, 18)
	marker.color = get_visual_status_color(String(get_building_visual_statuses().get(building_id, "activo")))
	row.add_child(marker)
	var building := village_state.get_building(building_id)
	var label := Label.new()
	label.text = "%s · %s" % [building.get("name", building_id), building.get("status", "")]
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.82, 0.77, 0.64))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	return row

func get_building_visual_statuses() -> Dictionary:
	var statuses := {}
	for building_id: String in BuildingDatabase.get_building_order():
		if not village_state.has_building(building_id):
			continue
		var building := village_state.get_building(building_id)
		var condition := int(building.get("condition", 100))
		var status := "activo"
		if condition <= 35:
			status = "bloqueado"
		elif condition <= 65:
			status = "riesgo"
		statuses[building_id] = status
	if village_state.get_resource("hierro") <= 2:
		statuses["forge"] = "riesgo"
	if village_state.get_resource("medicina") <= 5:
		statuses["healers_house"] = "riesgo"
	if village_state.get_resource("seguridad") <= 20:
		statuses["pastures"] = "riesgo"
	return statuses

func get_visual_status_color(status: String) -> Color:
	if status == "bloqueado":
		return Color(0.62, 0.23, 0.20)
	if status == "riesgo":
		return Color(0.82, 0.58, 0.28)
	return Color(0.54, 0.68, 0.45)

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
	active_context_id = "map"
	update_action_bar_selection()

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
	update_village_overview_panel()
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
	map_status_label.text = ""

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
	context_text_label.call_deferred("scroll_to_line", 0)

func apply_scrollable_context_text(min_height: float = 260.0) -> void:
	context_text_label.scroll_active = true
	context_text_label.fit_content = false
	context_text_label.custom_minimum_size = Vector2(380, min_height)
	context_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	context_text_label.call_deferred("scroll_to_line", 0)

func show_context(title: String, body: String, show_npcs: bool = false) -> void:
	if map_popup_panel != null:
		map_popup_panel.visible = false
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

func show_npc_from_map(npc_id: String, screen_position: Vector2 = Vector2(-1.0, -1.0)) -> void:
	if not village_state.npcs.has(npc_id):
		return
	if screen_position.x < 0.0:
		active_context_id = "people"
		update_action_bar_selection()
	selected_npc_id = npc_id
	var npc_index := village_state.npc_order.find(npc_id)
	if npc_index >= 0:
		npc_list.select(npc_index)
	village_map_view.select_npc(npc_id)
	if screen_position.x >= 0.0:
		show_npc_map_popup(npc_id, screen_position)
	else:
		show_context("Habitantes", "", true)

func add_context_button(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.custom_minimum_size = Vector2(0, 38)
	button.add_theme_stylebox_override("normal", make_button_style(Color(0.040, 0.044, 0.040, 0.96), Color(0.52, 0.44, 0.28, 0.52), 7))
	button.add_theme_stylebox_override("hover", make_button_style(Color(0.075, 0.063, 0.042, 1.0), Color(0.78, 0.61, 0.32, 0.86), 7))
	button.add_theme_stylebox_override("pressed", make_button_style(Color(0.11, 0.075, 0.040, 1.0), Color(0.90, 0.68, 0.34, 1.0), 7))
	button.add_theme_color_override("font_color", Color(0.90, 0.83, 0.64))
	button.pressed.connect(callback)
	context_content.add_child(button)
	dynamic_context_buttons.append(button)
	return button

func format_context_header(title: String, subtitle: String) -> String:
	return "[center][font_size=23][color=#f0dfb2][b]%s[/b][/color][/font_size]\n[color=#b59d70][i]%s[/i][/color][/center]\n[color=#6f6040]━━━━━━━━━━━━━━━━━━━━[/color]\n" % [title, subtitle]

func format_context_section(title: String) -> String:
	return "\n[color=#d8c28a][b]%s[/b][/color]\n[color=#6f6040]━━━━━━━━━━━━━━━━━━━━[/color]\n" % title

func format_context_notice(text: String) -> String:
	return "[color=#cdbf9c]%s[/color]\n" % text

func format_status_dot(status: String) -> String:
	if status == "bloqueado":
		return "[color=#a33b35]■[/color]"
	if status == "riesgo":
		return "[color=#d09347]▲[/color]"
	return "[color=#8aac73]●[/color]"

func get_status_color(status: String) -> String:
	if status == "bloqueado":
		return "#a33b35"
	if status == "riesgo":
		return "#d09347"
	return "#8aac73"

func update_action_bar_selection() -> void:
	var styles := {
		"people": people_button,
		"chronicle": chronicle_button,
		"management": management_button,
		"quests": quests_button,
		"build": build_button
	}
	for context_id: String in styles.keys():
		var button: Button = styles[context_id]
		if context_id == active_context_id:
			apply_action_button_style(button, true)
			button.add_theme_color_override("font_color", Color(0.98, 0.88, 0.62))
		else:
			apply_action_button_style(button, false)
			button.add_theme_color_override("font_color", Color(0.84, 0.79, 0.66))

func show_people_panel() -> void:
	active_context_id = "people"
	update_action_bar_selection()
	show_context(
		"Habitantes",
		format_context_header("Habitantes de Valdeniebla", "Rostros, oficio y tensiones personales") +
		format_context_notice("Selecciona un nombre para abrir su ficha. En el mapa cada protagonista usa una silueta ligada a su oficio."),
		true
	)

func show_chronicle_panel() -> void:
	active_context_id = "chronicle"
	update_action_bar_selection()
	if map_popup_panel != null:
		map_popup_panel.visible = false
	clear_dynamic_context_buttons()
	context_panel.visible = true
	context_title_label.text = "Crónica"
	context_text_label.visible = true
	context_text_label.text = get_chronicle_panel_text()
	apply_scrollable_context_text()
	npc_list.visible = false
	npc_info_label.visible = false

func show_management_panel() -> void:
	active_context_id = "management"
	update_action_bar_selection()
	show_context("Gestión", get_management_panel_text(), false)
	apply_scrollable_context_text()
	if village_state.is_start_of_month():
		for strategy_id: String in MonthlyStrategyDatabase.get_strategy_order():
			var strategy_name := MonthlyStrategyDatabase.get_strategy_name(strategy_id)
			var is_current := strategy_id == village_state.current_strategy_id
			var button := add_context_button(strategy_name if not is_current else "✓ %s" % strategy_name, func(id := strategy_id): set_monthly_strategy(id), is_current)
			button.custom_minimum_size = Vector2(0, 34)

func set_monthly_strategy(strategy_id: String) -> void:
	if not village_state.is_start_of_month():
		return
	village_state.set_monthly_strategy(strategy_id)
	add_event_feed_entry("Estrategia", {"location": "Casa comunal", "title": "Prioridad mensual: %s" % MonthlyStrategyDatabase.get_strategy_name(strategy_id)})
	show_management_panel()
	update_all_ui()

func get_management_panel_text() -> String:
	var strategy := MonthlyStrategyDatabase.get_strategy(village_state.current_strategy_id)
	var text := format_context_header("Registro del consejo", "Mes %d · Día %d/%d" % [village_state.month, village_state.day_of_month, village_state.DAYS_PER_MONTH])
	text += format_context_section("Prioridad mensual")
	text += "[color=#f0dfb2][font_size=18][b]%s[/b][/font_size][/color]\n[i]%s[/i]\n" % [strategy.get("name", "Equilibrada"), strategy.get("description", "")]
	if village_state.is_start_of_month():
		text += "\n[color=#d8c28a]Puedes cambiar la prioridad al inicio del mes.[/color]\n"
	else:
		text += "\n[color=#8d8062]La prioridad se podrá cambiar al comenzar el próximo mes.[/color]\n"
	text += format_context_section("Oficios activos")
	for line: String in village_state.get_job_summary_lines():
		text += "%s\n" % format_job_status_badge(line)
	text += format_context_section("Recursos")
	for resource_name: String in ResourceDatabase.get_resource_order():
		var label := String(ResourceDatabase.get_resource_labels().get(resource_name, resource_name))
		var icon_path := String(UiAssetDatabase.get_resource_icon_paths().get(resource_name, ""))
		var value := village_state.get_resource(resource_name)
		var value_color := "#f0dfb2"
		if value <= get_resource_warning_threshold(resource_name):
			value_color = "#d09347"
		if icon_path != "":
			text += "[img=18x18]%s[/img] %s: [color=%s]%d[/color]\n" % [icon_path, label, value_color, value]
		else:
			text += "%s: [color=%s]%d[/color]\n" % [label, value_color, value]
	text += format_context_section("Último balance")
	if village_state.last_daily_resource_changes.is_empty():
		text += "[color=#8d8062]Aún no hay balance diario.[/color]"
	else:
		for change: Dictionary in village_state.last_daily_resource_changes:
			var delta := int(change["delta"])
			var color := "#d09347"
			if delta >= 0:
				color = "#8aac73"
			text += "[color=%s]• %s %+d[/color] [color=#8d8062](%s)[/color]\n" % [color, String(change["resource"]).capitalize(), delta, String(change.get("source", "aldea"))]
	return text

func format_job_status_badge(line: String) -> String:
	if line.ends_with("activo"):
		return "[color=#8aac73]● ACTIVO[/color]  %s" % line.replace(" — activo", "")
	if line.ends_with("riesgo"):
		return "[color=#d09347]● RIESGO[/color]  %s" % line.replace(" — riesgo", "")
	if line.ends_with("bloqueado"):
		return "[color=#a33b35]● BLOQUEADO[/color]  %s" % line.replace(" — bloqueado", "")
	return line

func get_resource_warning_threshold(resource_name: String) -> int:
	if resource_name == "comida":
		return 35
	if resource_name == "madera":
		return 12
	if resource_name == "hierro":
		return 3
	if resource_name == "medicina":
		return 5
	if resource_name == "seguridad":
		return 20
	return -1

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
	active_context_id = "decision"
	update_action_bar_selection()
	var event_data: Dictionary = village_state.pending_decision_event
	var body := format_context_header(String(event_data.get("title", "Decisión")), String(event_data.get("location", "Aldea")))
	body += format_context_notice(String(event_data.get("description", "")))
	body += "\n[color=#d8c28a][b]Elige una respuesta[/b][/color]\n"
	show_context("Decisión", body, false)
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
		var icon_path := String(UiAssetDatabase.get_resource_icon_paths().get(resource_name, ""))
		if icon_path != "":
			chunks.append("[img=16x16]%s[/img] %d" % [icon_path, int(requirements[resource_name])])
		else:
			chunks.append("%s %d" % [String(resource_name).capitalize(), int(requirements[resource_name])])
	return ", ".join(chunks)

func show_quests_panel() -> void:
	active_context_id = "quests"
	update_action_bar_selection()
	show_context("Tramas", get_quests_panel_text(), false)
	apply_scrollable_context_text()

func show_build_panel() -> void:
	active_context_id = "build"
	update_action_bar_selection()
	var text := format_context_header("Construcción", "Estado material de la aldea")
	text += format_context_section("Edificios registrados")
	for building_id: String in BuildingDatabase.get_building_order():
		var building: Dictionary = village_state.get_building(building_id)
		var visual_status := String(get_building_visual_statuses().get(building_id, "activo"))
		text += "%s [b]%s[/b] · Nivel %d · [color=#cdbf9c]%s[/color]\n" % [format_status_dot(visual_status), building.get("name", building_id), int(building.get("level", 1)), building.get("status", "Sin estado")]
	text += format_context_section("Obras futuras")
	text += "Las mejoras, costes y obras llegan en la siguiente capa. Esta vista ya reserva lenguaje visual para estado, nivel y función."
	show_context("Construcción", text, false)
	apply_scrollable_context_text()

func show_building_panel(building_id: String, screen_position: Vector2 = Vector2(-1.0, -1.0)) -> void:
	if not village_state.has_building(building_id):
		show_context("Edificio", "No hay datos registrados para este edificio.", false)
		return
	if screen_position.x < 0.0:
		active_context_id = "build"
		update_action_bar_selection()
	village_map_view.select_building(building_id)
	var building: Dictionary = village_state.get_building(building_id)
	if screen_position.x >= 0.0:
		show_building_map_popup(building_id, building, screen_position)
	else:
		show_context(String(building.get("name", "Edificio")), get_building_panel_text(building), false)

func show_npc_map_popup(npc_id: String, screen_position: Vector2) -> void:
	var npc: Dictionary = village_state.npcs[npc_id]
	clear_map_popup_content()
	add_map_popup_label("%d años · %s" % [int(npc["age"]), npc["profession"]], 15, Color(0.80, 0.73, 0.58))
	add_map_popup_label(String(npc["location"]), 14, Color(0.58, 0.52, 0.40))
	add_map_popup_section("Estado")
	add_map_popup_stat_row("Salud", int(npc["state"].get("salud", 0)), false)
	add_map_popup_stat_row("Ánimo", int(npc["state"].get("ánimo", 0)), false)
	add_map_popup_stat_row("Estrés", int(npc["state"].get("estrés", 0)), true)
	add_map_popup_action("Habitantes: ficha completa")
	show_map_popup_at(String(npc["name"]), screen_position)

func show_building_map_popup(building_id: String, building: Dictionary, screen_position: Vector2) -> void:
	var visual_status := String(get_building_visual_statuses().get(building_id, "activo"))
	clear_map_popup_content()
	add_map_popup_label("%s · Nivel %d · %d/100" % [
		building.get("status", "Sin estado"),
		int(building.get("level", 1)),
		int(building.get("condition", 100))
	], 15, Color.html(get_status_color(visual_status)))
	add_map_popup_section("Función")
	add_map_popup_label(String(building.get("function", "Sin función registrada.")), 16, Color(0.90, 0.84, 0.70))
	var place_note := get_place_context_note(building_id)
	if place_note != "":
		add_map_popup_section("Situación")
		add_map_popup_label(place_note, 15, Color(0.78, 0.72, 0.58))
	add_map_popup_action("Construir: registro completo")
	show_map_popup_at(String(building.get("name", "Edificio")), screen_position)

func get_place_context_note(building_id: String) -> String:
	if building_id == "forge":
		return "Aldric y Gareth sostienen herramientas y defensa; la falta de hierro se notará aquí primero."
	if building_id == "tavern":
		return "Mara escucha más de lo que dice. La moral de la aldea suele cambiar en esta sala."
	if building_id == "chapel":
		return "Tomas conserva la crónica. Algunas entradas ya no encajan del todo."
	if building_id == "well":
		return "El pozo reúne conversaciones breves, rumores y primeros avisos de tensión."
	if building_id == "communal_house":
		return "Oren convierte quejas en prioridades mensuales, cuando logra que todos escuchen."
	return ""

func get_building_panel_text(building: Dictionary) -> String:
	var text := "[font_size=18][color=#f0dfb2][b]Nivel %d[/b][/color][/font_size]  [color=#cdbf9c]%s · %d/100[/color]\n" % [int(building.get("level", 1)), building.get("status", "Sin estado"), int(building.get("condition", 100))]
	text += format_context_section("Habitantes asociados")
	text += "%s\n" % format_worker_names(building.get("workers", []))
	text += format_context_section("Función")
	text += "%s\n" % building.get("function", "Sin función registrada.")
	text += format_context_section("Producción")
	text += "%s\n" % format_string_list(building.get("production", []), "Sin producción directa.")
	text += format_context_section("Costes")
	text += "%s\n" % format_string_list(building.get("costs", []), "Sin costes actuales.")
	text += format_context_section("Riesgos")
	text += "%s\n" % format_string_list(building.get("risks", []), "Sin riesgos registrados.")
	text += format_context_section("Mejora futura")
	text += "%s" % building.get("future_upgrade", "Sin mejora registrada.")
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

func get_chronicle_panel_text() -> String:
	var text := format_context_header("Crónica de Valdeniebla", "Registro de sucesos, balances y decisiones")
	if diary_system.diary_history.is_empty():
		return text + format_context_notice("Todavía no hay entradas registradas.")
	var entries: Array = diary_system.diary_history.duplicate()
	entries.reverse()
	for i in range(entries.size()):
		var entry_text := String(entries[i])
		text += "[color=#d8c28a][b]Entrada %d[/b][/color]\n" % (entries.size() - i)
		text += "[color=#cdbf9c]%s[/color]\n" % entry_text
		if i < entries.size() - 1:
			text += "[color=#51472f]────────────────────[/color]\n"
	return text

func get_quests_panel_text() -> String:
	var text := format_context_header("Tablón de tramas", "Historias personales y misterio de la niebla")
	text += "[color=#8d8062]Estas líneas preparan la presentación visual de quests antes de activar el sistema completo.[/color]\n"
	text += format_context_section("Tramas personales")
	text += format_quest_teaser("Aldric y Gareth", "Forja, orgullo y relevo generacional.", "Casa de la herrería")
	text += format_quest_teaser("Mara", "Rumores de taberna y favores cruzados.", "Taberna")
	text += format_quest_teaser("Elowen", "Curas, culpa y la primera enfermedad seria.", "Casa de curas")
	text += format_context_section("Misterio de la niebla")
	text += format_quest_teaser("Linde del bosque", "La niebla no se mueve como clima normal.", "Prados")
	text += format_quest_teaser("Memoria rota", "Tomas empieza a detectar contradicciones en la crónica.", "Capilla")
	return text

func format_quest_teaser(title: String, description: String, place: String) -> String:
	return "[color=#d09347]◆[/color] [b]%s[/b]\n[color=#cdbf9c]%s[/color]\n[color=#8d8062]%s[/color]\n\n" % [title, description, place]

func format_npc_section(title: String) -> String:
	return "\n[color=#d8c28a][b]%s[/b][/color]\n[color=#6f6040]━━━━━━━━━━━━━━━━━━━━[/color]\n" % title

func format_npc_portrait(path: String) -> String:
	if path == "":
		return ""
	return "[center][img=190x190]%s[/img][/center]\n" % path

func format_npc_header(name: String, age: int, profession: String, location: String) -> String:
	return "[center][font_size=25][color=#f0dfb2][b]%s[/b][/color][/font_size]\n[color=#cdbf9c]%d años · %s[/color]\n[i][color=#b59d70]%s[/color][/i][/center]\n" % [name, age, profession, location]

func format_trait_chips(traits: Array) -> String:
	var chips: Array[String] = []
	for trait_name in traits:
		chips.append("[color=#e5d09d]‹ %s ›[/color]" % String(trait_name))
	return "  ".join(chips)

func format_stats_block(stats: Dictionary) -> String:
	var chunks: Array[String] = []
	for key in stats.keys():
		chunks.append("[color=#b7a77e]%s[/color] [color=#f0dfb2]%d[/color]" % [String(key).capitalize(), int(stats[key])])
	return "\n".join(chunks)

func format_state_block(state: Dictionary) -> String:
	var text := ""
	text += format_state_line("Salud", int(state.get("salud", 0)), false)
	text += format_state_line("Ánimo", int(state.get("ánimo", 0)), false)
	text += format_state_line("Estrés", int(state.get("estrés", 0)), true)
	return text

func format_state_line(label: String, value: int, inverted: bool) -> String:
	var color := get_state_color(value, inverted)
	return "%s  [color=%s]%s[/color]  [color=#f0dfb2]%d[/color]/100\n" % [label, color, make_state_bar(value), value]

func make_state_bar(value: int) -> String:
	var filled := int(round(clamp(value, 0, 100) / 100.0 * NPC_STATE_BAR_SEGMENTS))
	var empty := NPC_STATE_BAR_SEGMENTS - filled
	return "█".repeat(filled) + "░".repeat(empty)

func get_state_color(value: int, inverted: bool) -> String:
	if inverted:
		if value >= 70:
			return "#a33b35"
		if value >= 45:
			return "#d09347"
		return "#8aac73"
	if value <= 30:
		return "#a33b35"
	if value <= 55:
		return "#d09347"
	return "#8aac73"

func format_relationship_line(name: String, value: int) -> String:
	var color := "#cdbf9c"
	if value >= 15:
		color = "#8aac73"
	elif value <= -10:
		color = "#d09347"
	var sign := "+" if value > 0 else ""
	return "[color=#b7a77e]%s[/color] [color=%s]%s%d[/color]" % [name, color, sign, value]

func update_npc_panel() -> void:
	if not npc_info_label.visible:
		return
	var npc: Dictionary = village_state.npcs[selected_npc_id]
	var portrait_path := String(UiAssetDatabase.get_portrait_paths().get(selected_npc_id, ""))
	var text := format_npc_portrait(portrait_path)
	text += format_npc_header(npc["name"], int(npc["age"]), npc["profession"], npc["location"])
	text += format_npc_section("Rasgos")
	text += format_trait_chips(npc["traits"]) + "\n"
	text += format_npc_section("Habilidades")
	text += format_stats_block(npc["stats"]) + "\n"
	text += format_npc_section("Estado")
	text += format_state_block(npc["state"])
	text += format_npc_section("Relaciones")
	text += format_relationships(selected_npc_id)
	npc_info_label.text = text

func get_npc_portrait_bbcode(npc_id: String) -> String:
	var portrait_path := String(UiAssetDatabase.get_portrait_paths().get(npc_id, ""))
	if portrait_path == "":
		return ""
	return format_npc_portrait(portrait_path)

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
		chunks.append(format_relationship_line(village_state.npcs[other_id]["name"], int(relationships.get(other_id, 0))))
	return "\n".join(chunks)
