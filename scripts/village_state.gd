extends RefCounted

var day: int = 1
var season: String = "Primavera"
var year: int = 1
var npc_order: Array[String] = []
var npcs: Dictionary = {}
var event_history: Array[Dictionary] = []

func setup(initial_npc_order: Array[String], initial_npcs: Dictionary) -> void:
	npc_order = initial_npc_order.duplicate(true)
	npcs = initial_npcs.duplicate(true)
	event_history.clear()

func advance_day() -> void:
	day += 1

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

func get_average_state(state_name: String) -> int:
	if npc_order.is_empty():
		return 0
	var total := 0
	for npc_id in npc_order:
		total += int(npcs[npc_id]["state"].get(state_name, 0))
	return int(total / npc_order.size())

func record_event(event_data: Dictionary) -> void:
	event_history.append({
		"id": event_data.get("id", ""),
		"category": event_data.get("category", "uncategorized"),
		"importance": event_data.get("importance", "minor"),
		"tone": event_data.get("tone", "neutral"),
		"day": day
	})

func has_event_happened(event_id: String) -> bool:
	for entry in event_history:
		if entry.get("id", "") == event_id:
			return true
	return false

func days_since_event(event_id: String) -> int:
	var latest_day := -1
	for entry in event_history:
		if entry.get("id", "") == event_id:
			latest_day = max(latest_day, int(entry.get("day", -1)))
	if latest_day == -1:
		return 100000
	return day - latest_day

func get_recent_event_categories(limit: int = 3) -> Array[String]:
	var categories: Array[String] = []
	var start_index = max(0, event_history.size() - limit)
	for index in range(start_index, event_history.size()):
		categories.append(String(event_history[index].get("category", "uncategorized")))
	return categories

func get_last_event_id() -> String:
	if event_history.is_empty():
		return ""
	return String(event_history[event_history.size() - 1].get("id", ""))
