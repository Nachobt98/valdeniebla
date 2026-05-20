extends Control
class_name VillageMapView

signal building_selected(building_id: String, screen_position: Vector2)
signal npc_selected(npc_id: String, screen_position: Vector2)

const VillageLayoutDatabase = preload("res://data/village_layout_database.gd")
const UiAssetDatabase = preload("res://data/ui_asset_database.gd")

var buildings := VillageLayoutDatabase.get_building_layouts()
var paths := VillageLayoutDatabase.get_paths()
var npc_routines := VillageLayoutDatabase.get_npc_routines()
var building_textures: Dictionary = {}
var npc_textures: Dictionary = {}
var status_icon_textures: Dictionary = {}
var npc_names: Dictionary = {}
var selected_building_id := ""
var selected_npc_id := ""
var hovered_building_id := ""
var hovered_npc_id := ""
var map_mode := "normal"
var routine_time := 0.0
var fog_phase := 0.0
var building_statuses: Dictionary = {}

const NPC_COLORS := {
	"aldric": Color(0.66, 0.30, 0.18, 1.0),
	"gareth": Color(0.44, 0.37, 0.30, 1.0),
	"mara": Color(0.72, 0.42, 0.24, 1.0),
	"elowen": Color(0.42, 0.58, 0.42, 1.0),
	"oren": Color(0.44, 0.45, 0.56, 1.0),
	"tomas": Color(0.62, 0.59, 0.50, 1.0),
	"bran": Color(0.52, 0.36, 0.18, 1.0),
	"lysa": Color(0.35, 0.48, 0.34, 1.0)
}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	load_map_asset_textures()
	resized.connect(func(): queue_redraw())
	set_process(true)

func load_map_asset_textures() -> void:
	building_textures = load_texture_dictionary(UiAssetDatabase.get_map_building_asset_paths())
	npc_textures = load_texture_dictionary(UiAssetDatabase.get_map_npc_sprite_paths())
	status_icon_textures = load_texture_dictionary(UiAssetDatabase.get_status_icon_paths())

func load_texture_dictionary(paths_by_id: Dictionary) -> Dictionary:
	var textures := {}
	for asset_id: String in paths_by_id.keys():
		var path := String(paths_by_id[asset_id])
		var texture := UiAssetDatabase.load_texture(path)
		if texture != null:
			textures[asset_id] = texture
	return textures

func set_npcs(npcs: Dictionary) -> void:
	npc_names.clear()
	for npc_id: String in npcs.keys():
		npc_names[npc_id] = String(npcs[npc_id].get("name", npc_id))
	queue_redraw()

func set_building_statuses(statuses: Dictionary) -> void:
	building_statuses = statuses.duplicate(true)
	queue_redraw()

func set_map_mode(mode: String) -> void:
	map_mode = mode
	queue_redraw()

func select_building(building_id: String) -> void:
	selected_building_id = building_id
	selected_npc_id = ""
	queue_redraw()

func select_npc(npc_id: String) -> void:
	selected_npc_id = npc_id
	selected_building_id = ""
	queue_redraw()

func _process(delta: float) -> void:
	routine_time = fmod(routine_time + delta * 0.035, 1.0)
	fog_phase = fmod(fog_phase + delta * 0.018, 1.0)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_hover_state(Vector2(event.position))
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position := Vector2(event.position)
		var npc_id := get_npc_at_position(click_position)
		if npc_id != "":
			npc_selected.emit(npc_id, click_position)
			return
		var building_id := get_building_at_position(click_position)
		if building_id != "":
			building_selected.emit(building_id, click_position)

func update_hover_state(position: Vector2) -> void:
	var npc_id := get_npc_at_position(position)
	var building_id := ""
	if npc_id == "":
		building_id = get_building_at_position(position)
	if hovered_npc_id == npc_id and hovered_building_id == building_id:
		return
	hovered_npc_id = npc_id
	hovered_building_id = building_id
	if hovered_npc_id != "" or hovered_building_id != "":
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
	queue_redraw()

func _draw() -> void:
	var viewport := size
	if viewport.x <= 0.0 or viewport.y <= 0.0:
		return
	draw_ground(viewport)
	draw_distant_mist(viewport)
	draw_forests(viewport)
	draw_paths(viewport)
	draw_fields(viewport)
	draw_map_mode_overlay(viewport)
	draw_warm_light_patches(viewport)
	draw_buildings(viewport)
	draw_settlement_props(viewport)
	draw_npcs(viewport)
	draw_ambient_specks(viewport)
	draw_low_fog(viewport)
	draw_vignette(viewport)
	draw_hover_tooltip(viewport)

func draw_ground(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(0.13, 0.17, 0.13, 1.0))
	draw_rect(Rect2(Vector2(0.0, viewport.y * 0.12), Vector2(viewport.x, viewport.y * 0.76)), Color(0.20, 0.26, 0.17, 0.80))
	draw_rect(Rect2(Vector2(0.0, viewport.y * 0.52), Vector2(viewport.x, viewport.y * 0.48)), Color(0.18, 0.22, 0.15, 0.32))
	for i in range(20):
		var x := fmod(float(i * 157), viewport.x)
		var y := fmod(float(i * 89), viewport.y)
		draw_circle(Vector2(x, y), 52.0 + float(i % 5) * 18.0, Color(0.08, 0.14, 0.09, 0.16))
	for i in range(28):
		var x := fmod(float(i * 97 + 41), viewport.x)
		var y := fmod(float(i * 53 + 17), viewport.y)
		draw_line(Vector2(x, y), Vector2(x + 26.0, y + 5.0), Color(0.43, 0.37, 0.20, 0.12), 2.0)

func draw_distant_mist(viewport: Vector2) -> void:
	for i in range(5):
		var y := viewport.y * (0.16 + float(i) * 0.15)
		var drift := sin((fog_phase + float(i) * 0.21) * TAU) * viewport.x * 0.018
		var rect := Rect2(Vector2(-viewport.x * 0.08 + drift, y), Vector2(viewport.x * 1.16, viewport.y * 0.085))
		draw_rect(rect, Color(0.52, 0.58, 0.52, 0.035 + float(i % 2) * 0.015))

func draw_forests(viewport: Vector2) -> void:
	for forest in [
		{"position": Vector2(0.09, 0.22), "radius": 0.24},
		{"position": Vector2(0.88, 0.24), "radius": 0.20},
		{"position": Vector2(0.90, 0.82), "radius": 0.16}
	]:
		draw_circle(to_screen(forest["position"], viewport), viewport.y * float(forest["radius"]), Color(0.04, 0.09, 0.055, 0.78))
	for i in range(34):
		var px := fmod(float(i * 73), viewport.x)
		var py := fmod(float(i * 131), viewport.y)
		if px > viewport.x * 0.18 and px < viewport.x * 0.82 and py > viewport.y * 0.22 and py < viewport.y * 0.78:
			continue
		draw_tree(Vector2(px, py), 0.7 + float(i % 4) * 0.18)

func draw_tree(position: Vector2, scale: float) -> void:
	var trunk := Color(0.12, 0.075, 0.045, 0.85)
	draw_rect(Rect2(position + Vector2(-2.0, 10.0) * scale, Vector2(4.0, 14.0) * scale), trunk)
	draw_circle(position, 16.0 * scale, Color(0.035, 0.12, 0.06, 0.92))
	draw_circle(position + Vector2(8.0, 5.0) * scale, 12.0 * scale, Color(0.055, 0.15, 0.075, 0.84))

func draw_paths(viewport: Vector2) -> void:
	for path: PackedVector2Array in paths:
		var screen_path := PackedVector2Array()
		for point: Vector2 in path:
			screen_path.append(to_screen(point, viewport))
		draw_polyline(screen_path, Color(0.08, 0.055, 0.035, 0.68), 38.0, true)
		draw_polyline(screen_path, Color(0.42, 0.31, 0.18, 0.90), 25.0, true)
		draw_polyline(screen_path, Color(0.62, 0.50, 0.31, 0.24), 5.0, true)
		draw_polyline(screen_path, Color(0.25, 0.18, 0.10, 0.28), 1.4, true)

func draw_fields(viewport: Vector2) -> void:
	var field_rect := Rect2(to_screen(Vector2(0.26, 0.66), viewport), Vector2(viewport.x * 0.18, viewport.y * 0.16))
	draw_rect(field_rect, Color(0.38, 0.34, 0.15, 0.70))
	for row in range(5):
		var y := field_rect.position.y + 18.0 + row * field_rect.size.y / 6.0
		draw_line(Vector2(field_rect.position.x + 12.0, y), Vector2(field_rect.end.x - 12.0, y), Color(0.72, 0.65, 0.34, 0.36), 8.0)
	draw_fence(field_rect.grow(8.0))

func draw_warm_light_patches(viewport: Vector2) -> void:
	for building_id in ["forge", "tavern", "chapel", "communal_house", "healers_house"]:
		var layout: Dictionary = buildings[building_id]
		var center := to_screen(layout["position"], viewport)
		var radius := viewport.y * (0.10 if building_id != "tavern" else 0.13)
		draw_circle(center + Vector2(0.0, radius * 0.15), radius, Color(0.72, 0.46, 0.20, 0.055))
		draw_circle(center, radius * 0.45, Color(0.95, 0.65, 0.28, 0.045))

func draw_buildings(viewport: Vector2) -> void:
	for building_id: String in buildings.keys():
		draw_building(building_id, buildings[building_id], viewport)

func draw_building(building_id: String, layout: Dictionary, viewport: Vector2) -> void:
	var normalized_size: Vector2 = layout["size"]
	var center := to_screen(layout["position"], viewport)
	var footprint := Vector2(normalized_size.x * viewport.x, normalized_size.y * viewport.y)
	var rect := Rect2(center - footprint * 0.5, footprint)
	var selected := building_id == selected_building_id
	var hovered := building_id == hovered_building_id
	var uses_texture := building_textures.has(building_id)
	if uses_texture:
		draw_building_texture(building_id, rect)
	else:
		draw_procedural_building(layout, rect)
	var outline_alpha := 0.32
	var outline_width := 2.0
	if selected:
		outline_alpha = 0.90
		outline_width = 4.0
	elif hovered:
		outline_alpha = 0.78
		outline_width = 3.0
	draw_rect(rect, Color(0.81, 0.69, 0.42, outline_alpha), false, outline_width)
	if not uses_texture:
		draw_door(rect)
		draw_windows(rect)
		draw_building_details(building_id, rect)
	draw_building_status_marker(building_id, rect)
	if selected or hovered or not uses_texture:
		draw_label(center + Vector2(0.0, rect.size.y * 0.58), String(layout["label"]), selected)
	if hovered:
		draw_rect(rect.grow(8.0), Color(0.95, 0.78, 0.38, 0.22), false, 3.0)
	if building_id == "well":
		draw_circle(center, minf(footprint.x, footprint.y) * 0.48, Color(0.09, 0.16, 0.17, 1.0))
		draw_circle(center, minf(footprint.x, footprint.y) * 0.28, Color(0.17, 0.31, 0.33, 0.9))
	if building_id == "pastures":
		draw_fence(rect.grow(28.0))
	if building_id == "chapel":
		draw_chapel_yard(rect)

func draw_building_texture(building_id: String, rect: Rect2) -> void:
	var texture: Texture2D = building_textures[building_id]
	var draw_rect_size := rect.size * 1.85
	if building_id == "chapel":
		draw_rect_size = rect.size * 1.75
	elif building_id == "communal_house":
		draw_rect_size = rect.size * 1.70
	var draw_rect_position := rect.get_center() - draw_rect_size * 0.5 + Vector2(0.0, -rect.size.y * 0.18)
	draw_texture_rect(texture, Rect2(draw_rect_position, draw_rect_size), false)

func draw_procedural_building(layout: Dictionary, rect: Rect2) -> void:
	draw_rect(rect.grow(13.0), Color(0.02, 0.018, 0.014, 0.76))
	draw_rect(rect.grow(5.0), Color(0.46, 0.38, 0.22, 0.08))
	draw_rect(rect, layout["body"])
	draw_colored_polygon(PackedVector2Array([
		rect.position + Vector2(-8.0, rect.size.y * 0.38),
		rect.position + Vector2(rect.size.x * 0.5, -18.0),
		rect.position + Vector2(rect.size.x + 8.0, rect.size.y * 0.38),
		rect.position + Vector2(rect.size.x, rect.size.y * 0.50),
		rect.position + Vector2(0.0, rect.size.y * 0.50)
	]), layout["roof"])

func draw_building_details(building_id: String, rect: Rect2) -> void:
	if building_id == "forge":
		var chimney := Rect2(rect.position + Vector2(rect.size.x * 0.70, -9.0), Vector2(10.0, 24.0))
		draw_rect(chimney, Color(0.10, 0.08, 0.07, 1.0))
		draw_circle(chimney.position + Vector2(5.0, -8.0), 10.0, Color(0.42, 0.43, 0.39, 0.18))
		draw_circle(chimney.position + Vector2(13.0, -18.0), 14.0, Color(0.54, 0.56, 0.51, 0.11))
		draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.12, rect.size.y * 0.72), Vector2(22.0, 5.0)), Color(0.70, 0.40, 0.18, 0.75))
	elif building_id == "tavern":
		draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.80, rect.size.y * 0.45), Vector2(12.0, 18.0)), Color(0.72, 0.48, 0.22, 0.72))
		draw_circle(rect.position + Vector2(rect.size.x * 0.82, rect.size.y * 0.37), 7.0, Color(0.88, 0.70, 0.38, 0.30))
		draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.12, rect.size.y * 0.72), Vector2(28.0, 7.0)), Color(0.20, 0.10, 0.05, 0.85))
	elif building_id == "farms":
		for i in range(4):
			draw_line(
				rect.position + Vector2(rect.size.x * (0.15 + float(i) * 0.18), rect.size.y * 0.52),
				rect.position + Vector2(rect.size.x * (0.10 + float(i) * 0.18), rect.size.y * 0.92),
				Color(0.68, 0.54, 0.22, 0.35),
				3.0
			)
	elif building_id == "chapel":
		var bell := Rect2(rect.position + Vector2(rect.size.x * 0.43, -14.0), Vector2(rect.size.x * 0.14, 22.0))
		draw_rect(bell, Color(0.13, 0.12, 0.11, 1.0))
		draw_line(bell.position + Vector2(bell.size.x * 0.5, 3.0), bell.position + Vector2(bell.size.x * 0.5, 18.0), Color(0.72, 0.65, 0.48, 0.7), 2.0)
	elif building_id == "pastures":
		for i in range(3):
			var sheep := rect.position + Vector2(rect.size.x * (0.25 + float(i) * 0.22), rect.size.y * 0.54)
			draw_circle(sheep, 7.0, Color(0.76, 0.74, 0.62, 0.85))
			draw_circle(sheep + Vector2(6.0, 1.0), 3.0, Color(0.19, 0.17, 0.13, 0.88))
	elif building_id == "communal_house":
		draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.14, rect.size.y * 0.68), Vector2(rect.size.x * 0.72, 5.0)), Color(0.62, 0.42, 0.20, 0.60))
		draw_line(rect.position + Vector2(rect.size.x * 0.50, rect.size.y * 0.20), rect.position + Vector2(rect.size.x * 0.50, rect.size.y * 0.72), Color(0.80, 0.66, 0.36, 0.42), 2.0)
		draw_circle(rect.position + Vector2(rect.size.x * 0.50, rect.size.y * 0.22), 7.0, Color(0.82, 0.62, 0.26, 0.22))
	elif building_id == "healers_house":
		for i in range(4):
			var herb := rect.position + Vector2(rect.size.x * (0.18 + float(i) * 0.18), rect.size.y * 0.82)
			draw_line(herb, herb + Vector2(0.0, -12.0), Color(0.36, 0.55, 0.28, 0.75), 2.0)
			draw_circle(herb + Vector2(-3.0, -7.0), 3.0, Color(0.45, 0.68, 0.35, 0.7))
			draw_circle(herb + Vector2(4.0, -9.0), 3.0, Color(0.45, 0.68, 0.35, 0.7))
	elif building_id == "storehouse":
		for i in range(3):
			var crate := Rect2(rect.position + Vector2(rect.size.x * (0.16 + float(i) * 0.22), rect.size.y * 0.64), Vector2(17.0, 15.0))
			draw_rect(crate, Color(0.37, 0.24, 0.11, 0.86))
			draw_rect(crate, Color(0.78, 0.58, 0.27, 0.24), false, 1.0)

func draw_building_status_marker(building_id: String, rect: Rect2) -> void:
	var status := String(building_statuses.get(building_id, "activo"))
	if status_icon_textures.has(status):
		var texture: Texture2D = status_icon_textures[status]
		var marker_rect := Rect2(rect.position + Vector2(rect.size.x - 22.0, 0.0), Vector2(24.0, 24.0))
		draw_texture_rect(texture, marker_rect, false)
		return
	var color := Color(0.54, 0.68, 0.45, 1.0)
	if status == "riesgo":
		color = Color(0.82, 0.58, 0.28, 1.0)
	elif status == "bloqueado":
		color = Color(0.62, 0.23, 0.20, 1.0)
	var marker_position := rect.position + Vector2(rect.size.x - 12.0, 10.0)
	draw_circle(marker_position + Vector2(1.0, 2.0), 8.0, Color(0, 0, 0, 0.42))
	draw_circle(marker_position, 6.0, color)
	draw_circle(marker_position, 9.0, Color(color.r, color.g, color.b, 0.22), false, 2.0)
	if status == "riesgo":
		draw_colored_polygon(PackedVector2Array([
			marker_position + Vector2(0.0, -5.0),
			marker_position + Vector2(5.0, 5.0),
			marker_position + Vector2(-5.0, 5.0)
		]), Color(0.09, 0.06, 0.03, 0.72))
	elif status == "bloqueado":
		draw_line(marker_position + Vector2(-4.0, -4.0), marker_position + Vector2(4.0, 4.0), Color(0.08, 0.04, 0.04, 0.82), 2.0)
		draw_line(marker_position + Vector2(4.0, -4.0), marker_position + Vector2(-4.0, 4.0), Color(0.08, 0.04, 0.04, 0.82), 2.0)
	else:
		draw_line(marker_position + Vector2(-4.0, 0.0), marker_position + Vector2(-1.0, 4.0), Color(0.06, 0.09, 0.05, 0.80), 2.0)
		draw_line(marker_position + Vector2(-1.0, 4.0), marker_position + Vector2(5.0, -4.0), Color(0.06, 0.09, 0.05, 0.80), 2.0)

func draw_door(rect: Rect2) -> void:
	var door_size := Vector2(rect.size.x * 0.14, rect.size.y * 0.28)
	draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.43, rect.size.y * 0.62), door_size), Color(0.09, 0.055, 0.035, 1.0))

func draw_windows(rect: Rect2) -> void:
	for x in [0.22, 0.70]:
		draw_rect(Rect2(rect.position + Vector2(rect.size.x * x, rect.size.y * 0.58), Vector2(10.0, 12.0)), Color(0.90, 0.68, 0.28, 0.62))

func draw_chapel_yard(rect: Rect2) -> void:
	for i in range(5):
		var grave_position := rect.position + Vector2(rect.size.x + 18.0 + float(i % 2) * 18.0, 10.0 + float(i) * 16.0)
		draw_rect(Rect2(grave_position, Vector2(8.0, 13.0)), Color(0.40, 0.39, 0.34, 0.8))

func draw_settlement_props(viewport: Vector2) -> void:
	draw_barrels(to_screen(Vector2(0.64, 0.42), viewport))
	draw_barrels(to_screen(Vector2(0.24, 0.44), viewport))
	draw_wood_stack(to_screen(Vector2(0.20, 0.49), viewport))
	draw_wood_stack(to_screen(Vector2(0.38, 0.67), viewport))
	draw_cart(to_screen(Vector2(0.61, 0.60), viewport))
	draw_notice_board(to_screen(Vector2(0.54, 0.38), viewport))

func draw_barrels(position: Vector2) -> void:
	for i in range(3):
		var offset := Vector2(float(i) * 9.0, float(i % 2) * 5.0)
		draw_circle(position + offset, 5.0, Color(0.33, 0.20, 0.10, 0.90))
		draw_line(position + offset + Vector2(-4.0, 0.0), position + offset + Vector2(4.0, 0.0), Color(0.73, 0.56, 0.28, 0.34), 1.0)

func draw_wood_stack(position: Vector2) -> void:
	for i in range(4):
		var start := position + Vector2(0.0, float(i) * 4.0)
		draw_line(start, start + Vector2(24.0, 2.0), Color(0.40, 0.24, 0.11, 0.9), 3.0)
		draw_circle(start + Vector2(25.0, 2.0), 2.6, Color(0.62, 0.43, 0.20, 0.75))

func draw_cart(position: Vector2) -> void:
	draw_rect(Rect2(position, Vector2(34.0, 16.0)), Color(0.32, 0.20, 0.10, 0.85))
	draw_circle(position + Vector2(8.0, 18.0), 5.0, Color(0.08, 0.06, 0.04, 0.9))
	draw_circle(position + Vector2(27.0, 18.0), 5.0, Color(0.08, 0.06, 0.04, 0.9))

func draw_notice_board(position: Vector2) -> void:
	draw_rect(Rect2(position + Vector2(-14.0, -18.0), Vector2(28.0, 18.0)), Color(0.24, 0.13, 0.06, 0.86))
	draw_rect(Rect2(position + Vector2(-11.0, -15.0), Vector2(22.0, 12.0)), Color(0.62, 0.45, 0.22, 0.44))
	draw_line(position + Vector2(-10.0, 0.0), position + Vector2(-10.0, 18.0), Color(0.16, 0.09, 0.05, 0.9), 3.0)
	draw_line(position + Vector2(10.0, 0.0), position + Vector2(10.0, 18.0), Color(0.16, 0.09, 0.05, 0.9), 3.0)

func draw_ambient_specks(viewport: Vector2) -> void:
	for i in range(16):
		var x := fmod(float(i * 113 + 29), viewport.x)
		var y := fmod(float(i * 67 + 47), viewport.y)
		var shimmer := 0.35 + sin((fog_phase + float(i) * 0.17) * TAU) * 0.25
		if y < viewport.y * 0.18 or y > viewport.y * 0.86:
			continue
		draw_circle(Vector2(x, y), 1.4 + shimmer, Color(0.76, 0.70, 0.48, 0.08 + shimmer * 0.05))

func draw_fence(rect: Rect2) -> void:
	var color := Color(0.23, 0.16, 0.08, 0.76)
	draw_rect(rect, color, false, 2.0)
	for i in range(8):
		var x := lerpf(rect.position.x, rect.end.x, float(i) / 7.0)
		draw_line(Vector2(x, rect.position.y - 4.0), Vector2(x, rect.position.y + 8.0), color, 3.0)
		draw_line(Vector2(x, rect.end.y - 8.0), Vector2(x, rect.end.y + 4.0), color, 3.0)

func draw_npcs(viewport: Vector2) -> void:
	for npc_id: String in npc_routines.keys():
		var position := get_npc_position(npc_id, viewport)
		var selected := npc_id == selected_npc_id
		var hovered := npc_id == hovered_npc_id
		draw_npc_sprite(npc_id, position, selected)
		if selected or hovered:
			draw_label(position + Vector2(0.0, 17.0), String(npc_names.get(npc_id, npc_id)), selected or hovered, 13)

func draw_npc_sprite(npc_id: String, position: Vector2, selected: bool) -> void:
	if npc_textures.has(npc_id):
		draw_npc_texture(npc_id, position, selected)
		return
	var body_color: Color = NPC_COLORS.get(npc_id, Color(0.82, 0.72, 0.42, 1.0))
	var scale := 1.0
	if selected:
		scale = 1.16
	draw_circle(position + Vector2(2.0, 6.0), 12.0 * scale, Color(0, 0, 0, 0.42))
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-7.0, 4.0) * scale,
		position + Vector2(7.0, 4.0) * scale,
		position + Vector2(10.0, 15.0) * scale,
		position + Vector2(-10.0, 15.0) * scale
	]), body_color)
	draw_circle(position + Vector2(0.0, -6.0) * scale, 5.0 * scale, Color(0.80, 0.66, 0.52, 1.0))
	draw_line(position + Vector2(-6.0, 8.0) * scale, position + Vector2(6.0, 8.0) * scale, Color(0.12, 0.08, 0.05, 0.55), 2.0)
	draw_npc_role_prop(npc_id, position, scale)
	if selected:
		draw_circle(position + Vector2(0.0, 5.0), 17.0, Color(0.92, 0.76, 0.36, 0.26), false, 2.0)

func draw_npc_texture(npc_id: String, position: Vector2, selected: bool) -> void:
	var texture: Texture2D = npc_textures[npc_id]
	var draw_size := Vector2(38.0, 52.0)
	if selected:
		draw_size *= 1.14
	draw_circle(position + Vector2(1.0, 14.0), draw_size.x * 0.36, Color(0, 0, 0, 0.36))
	var draw_position := position - Vector2(draw_size.x * 0.5, draw_size.y * 0.72)
	draw_texture_rect(texture, Rect2(draw_position, draw_size), false)
	if selected:
		draw_circle(position + Vector2(0.0, 5.0), 20.0, Color(0.92, 0.76, 0.36, 0.22), false, 2.0)

func draw_npc_role_prop(npc_id: String, position: Vector2, scale: float) -> void:
	var dark := Color(0.10, 0.07, 0.045, 0.88)
	var brass := Color(0.78, 0.58, 0.28, 0.82)
	if npc_id == "aldric" or npc_id == "gareth":
		draw_line(position + Vector2(8.0, -2.0) * scale, position + Vector2(16.0, -10.0) * scale, dark, 2.0)
		draw_rect(Rect2(position + Vector2(14.0, -13.0) * scale, Vector2(8.0, 4.0) * scale), Color(0.45, 0.43, 0.38, 0.92))
	elif npc_id == "mara":
		draw_rect(Rect2(position + Vector2(-5.0, 4.0) * scale, Vector2(10.0, 10.0) * scale), Color(0.86, 0.70, 0.44, 0.52))
		draw_circle(position + Vector2(11.0, 1.0) * scale, 3.0 * scale, brass)
	elif npc_id == "elowen":
		draw_line(position + Vector2(10.0, 3.0) * scale, position + Vector2(18.0, -8.0) * scale, Color(0.38, 0.58, 0.28, 0.86), 2.0)
		draw_circle(position + Vector2(17.0, -9.0) * scale, 3.0 * scale, Color(0.52, 0.76, 0.40, 0.82))
	elif npc_id == "oren":
		draw_rect(Rect2(position + Vector2(8.0, -6.0) * scale, Vector2(8.0, 11.0) * scale), Color(0.72, 0.67, 0.50, 0.72))
		draw_line(position + Vector2(9.0, -2.0) * scale, position + Vector2(15.0, -2.0) * scale, dark, 1.0)
	elif npc_id == "tomas":
		draw_rect(Rect2(position + Vector2(8.0, -1.0) * scale, Vector2(10.0, 8.0) * scale), Color(0.72, 0.68, 0.52, 0.72))
		draw_line(position + Vector2(13.0, -8.0) * scale, position + Vector2(18.0, -13.0) * scale, Color(0.80, 0.78, 0.66, 0.82), 1.4)
	elif npc_id == "bran":
		draw_line(position + Vector2(11.0, -10.0) * scale, position + Vector2(11.0, 14.0) * scale, dark, 2.0)
		for tine in [-4.0, 0.0, 4.0]:
			draw_line(position + Vector2(11.0, -10.0) * scale, position + Vector2(11.0 + tine, -16.0) * scale, dark, 1.5)
	elif npc_id == "lysa":
		draw_line(position + Vector2(11.0, -12.0) * scale, position + Vector2(11.0, 16.0) * scale, Color(0.28, 0.20, 0.10, 0.94), 2.0)
		draw_line(position + Vector2(11.0, -12.0) * scale, position + Vector2(17.0, -6.0) * scale, Color(0.28, 0.20, 0.10, 0.94), 1.6)

func draw_label(position: Vector2, text: String, selected: bool, font_size: int = 14) -> void:
	var font := get_theme_default_font()
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size)
	var rect := Rect2(position - Vector2(text_size.x * 0.5 + 8.0, 10.0), Vector2(text_size.x + 16.0, 23.0))
	draw_rect(rect, Color(0.025, 0.031, 0.034, 0.72 if not selected else 0.92))
	draw_rect(rect, Color(0.78, 0.66, 0.38, 0.24 if not selected else 0.92), false, 1.0)
	draw_string(font, Vector2(position.x - text_size.x * 0.5, position.y + 5.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.90, 0.86, 0.72, 1.0))

func draw_vignette(viewport: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(viewport.x, 32.0)), Color(0.015, 0.018, 0.018, 0.72))
	draw_rect(Rect2(Vector2(0.0, viewport.y - 32.0), Vector2(viewport.x, 32.0)), Color(0.015, 0.018, 0.018, 0.72))
	draw_rect(Rect2(Vector2.ZERO, Vector2(32.0, viewport.y)), Color(0.015, 0.018, 0.018, 0.62))
	draw_rect(Rect2(Vector2(viewport.x - 32.0, 0.0), Vector2(32.0, viewport.y)), Color(0.015, 0.018, 0.018, 0.62))

func draw_low_fog(viewport: Vector2) -> void:
	for i in range(7):
		var y := viewport.y * (0.20 + float(i) * 0.105)
		var drift := sin((fog_phase + float(i) * 0.13) * TAU) * viewport.x * 0.035
		var x := -viewport.x * 0.20 + drift
		draw_rect(Rect2(Vector2(x, y), Vector2(viewport.x * 1.35, viewport.y * 0.055)), Color(0.58, 0.64, 0.62, 0.045))

func draw_map_mode_overlay(viewport: Vector2) -> void:
	if map_mode == "riesgo":
		for building_id: String in buildings.keys():
			var status := String(building_statuses.get(building_id, "activo"))
			if status == "activo":
				continue
			var layout: Dictionary = buildings[building_id]
			var center := to_screen(layout["position"], viewport)
			var radius := viewport.y * 0.075
			var color := Color(0.80, 0.58, 0.24, 0.16)
			if status == "bloqueado":
				color = Color(0.65, 0.18, 0.15, 0.20)
			draw_circle(center, radius, color)
	elif map_mode == "recursos":
		for point in [
			{"position": Vector2(0.26, 0.72), "text": "+ comida"},
			{"position": Vector2(0.23, 0.47), "text": "+ hierro"},
			{"position": Vector2(0.43, 0.67), "text": "+ medicina"},
			{"position": Vector2(0.64, 0.42), "text": "+ moral"}
		]:
			var label_position := to_screen(point["position"], viewport)
			draw_resource_badge(label_position, String(point["text"]))

func draw_resource_badge(position: Vector2, text: String) -> void:
	var font := get_theme_default_font()
	var font_size := 13
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size)
	var rect := Rect2(position - Vector2(text_size.x * 0.5 + 8.0, 13.0), Vector2(text_size.x + 16.0, 24.0))
	draw_rect(rect, Color(0.06, 0.045, 0.025, 0.74))
	draw_rect(rect, Color(0.82, 0.62, 0.30, 0.42), false, 1.0)
	draw_string(font, Vector2(position.x - text_size.x * 0.5, position.y + 5.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.92, 0.83, 0.58, 1.0))

func draw_hover_tooltip(viewport: Vector2) -> void:
	var title := ""
	var subtitle := ""
	var position := Vector2.ZERO
	if hovered_npc_id != "":
		title = String(npc_names.get(hovered_npc_id, hovered_npc_id))
		subtitle = "Habitante"
		position = get_npc_position(hovered_npc_id, viewport) + Vector2(20.0, -34.0)
	elif hovered_building_id != "":
		var layout: Dictionary = buildings[hovered_building_id]
		title = String(layout.get("label", hovered_building_id))
		subtitle = String(building_statuses.get(hovered_building_id, "activo")).capitalize()
		position = to_screen(layout["position"], viewport) + Vector2(24.0, -44.0)
	else:
		return
	var font := get_theme_default_font()
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15)
	var subtitle_size := font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12)
	var width := maxf(title_size.x, subtitle_size.x) + 22.0
	var rect := Rect2(position, Vector2(width, 48.0))
	if rect.end.x > viewport.x - 16.0:
		rect.position.x = viewport.x - rect.size.x - 16.0
	if rect.position.y < 16.0:
		rect.position.y = 16.0
	draw_rect(rect, Color(0.020, 0.024, 0.023, 0.92))
	draw_rect(rect, Color(0.76, 0.62, 0.34, 0.70), false, 1.0)
	draw_string(font, rect.position + Vector2(11.0, 20.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, Color(0.95, 0.86, 0.62, 1.0))
	draw_string(font, rect.position + Vector2(11.0, 38.0), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color(0.70, 0.64, 0.49, 1.0))

func get_npc_position(npc_id: String, viewport: Vector2) -> Vector2:
	var routine: Array = npc_routines.get(npc_id, [])
	if routine.is_empty():
		return viewport * 0.5
	var segment_count := routine.size()
	var scaled_time := routine_time * float(segment_count)
	var from_index := int(floor(scaled_time)) % segment_count
	var to_index := (from_index + 1) % segment_count
	var local_t := smoothstep(0.0, 1.0, scaled_time - floor(scaled_time))
	var from_layout: Dictionary = buildings[String(routine[from_index])]
	var to_layout: Dictionary = buildings[String(routine[to_index])]
	var offset := get_npc_offset(npc_id)
	var from_position := to_screen(from_layout["position"], viewport) + offset
	var to_position := to_screen(to_layout["position"], viewport) + offset
	return from_position.lerp(to_position, local_t)

func get_npc_offset(npc_id: String) -> Vector2:
	var offsets := {
		"aldric": Vector2(-42.0, -8.0),
		"gareth": Vector2(-24.0, -34.0),
		"mara": Vector2(52.0, -20.0),
		"elowen": Vector2(-32.0, 34.0),
		"bran": Vector2(-54.0, 18.0),
		"lysa": Vector2(58.0, 26.0),
		"oren": Vector2(0.0, -6.0),
		"tomas": Vector2(28.0, 36.0)
	}
	return offsets.get(npc_id, Vector2.ZERO)

func get_npc_at_position(position: Vector2) -> String:
	for npc_id: String in npc_routines.keys():
		if position.distance_to(get_npc_position(npc_id, size)) <= 18.0:
			return npc_id
	return ""

func get_building_at_position(position: Vector2) -> String:
	for building_id: String in buildings.keys():
		var layout: Dictionary = buildings[building_id]
		var normalized_size: Vector2 = layout["size"]
		var center := to_screen(layout["position"], size)
		var footprint := Vector2(normalized_size.x * size.x, normalized_size.y * size.y)
		if Rect2(center - footprint * 0.5, footprint).grow(18.0).has_point(position):
			return building_id
	return ""

func to_screen(normalized: Vector2, viewport: Vector2) -> Vector2:
	return Vector2(normalized.x * viewport.x, normalized.y * viewport.y)
