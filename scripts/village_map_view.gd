extends Control
class_name VillageMapView

signal building_selected(building_id: String)
signal npc_selected(npc_id: String)

const VillageLayoutDatabase = preload("res://data/village_layout_database.gd")

var buildings := VillageLayoutDatabase.get_building_layouts()
var paths := VillageLayoutDatabase.get_paths()
var npc_routines := VillageLayoutDatabase.get_npc_routines()
var npc_names: Dictionary = {}
var selected_building_id := ""
var selected_npc_id := ""
var routine_time := 0.0
var fog_phase := 0.0

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
	resized.connect(func(): queue_redraw())
	set_process(true)

func set_npcs(npcs: Dictionary) -> void:
	npc_names.clear()
	for npc_id: String in npcs.keys():
		npc_names[npc_id] = String(npcs[npc_id].get("name", npc_id))
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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position := Vector2(event.position)
		var npc_id := get_npc_at_position(click_position)
		if npc_id != "":
			npc_selected.emit(npc_id)
			return
		var building_id := get_building_at_position(click_position)
		if building_id != "":
			building_selected.emit(building_id)

func _draw() -> void:
	var viewport := size
	if viewport.x <= 0.0 or viewport.y <= 0.0:
		return
	draw_ground(viewport)
	draw_distant_mist(viewport)
	draw_forests(viewport)
	draw_paths(viewport)
	draw_fields(viewport)
	draw_warm_light_patches(viewport)
	draw_buildings(viewport)
	draw_settlement_props(viewport)
	draw_npcs(viewport)
	draw_low_fog(viewport)
	draw_vignette(viewport)

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
	for building_id in ["forge", "tavern", "chapel"]:
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
	draw_rect(rect, Color(0.81, 0.69, 0.42, 0.32 if not selected else 0.90), false, 2.0 if not selected else 4.0)
	draw_door(rect)
	draw_windows(rect)
	draw_building_details(building_id, rect)
	draw_label(center + Vector2(0.0, rect.size.y * 0.58), String(layout["label"]), selected)
	if building_id == "well":
		draw_circle(center, minf(footprint.x, footprint.y) * 0.48, Color(0.09, 0.16, 0.17, 1.0))
		draw_circle(center, minf(footprint.x, footprint.y) * 0.28, Color(0.17, 0.31, 0.33, 0.9))
	if building_id == "pastures":
		draw_fence(rect.grow(28.0))
	if building_id == "chapel":
		draw_chapel_yard(rect)

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
		var body_color: Color = NPC_COLORS.get(npc_id, Color(0.82, 0.72, 0.42, 1.0))
		draw_circle(position + Vector2(2.0, 5.0), 12.0, Color(0, 0, 0, 0.42))
		draw_circle(position, 8.0 if not selected else 11.0, body_color)
		draw_circle(position + Vector2(0.0, -10.0), 5.0, Color(0.80, 0.66, 0.52, 1.0))
		draw_line(position + Vector2(-5.0, 5.0), position + Vector2(5.0, 5.0), Color(0.12, 0.08, 0.05, 0.55), 2.0)
		if selected:
			draw_circle(position, 15.0, Color(0.92, 0.76, 0.36, 0.24), false, 2.0)
		draw_label(position + Vector2(0.0, 17.0), String(npc_names.get(npc_id, npc_id)), selected, 13)

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
	var index := npc_routines.keys().find(npc_id)
	return Vector2(float((index % 3) - 1) * 16.0, float(index / 3) * 12.0)

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
