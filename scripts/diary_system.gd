extends RefCounted

const MAX_DIARY_ENTRIES := 12

var diary_history: Array[String] = []

func setup_initial_entry() -> void:
	diary_history.clear()
	diary_history.append("[font_size=20][b]Día 1 — Amanecer[/b][/font_size]\n[i]Valdeniebla[/i]\nValdeniebla despierta entre humo de chimeneas, barro reciente y rumores pequeños.")

func add_entry(time_name: String, event_data: Dictionary, village_state) -> void:
	var actors_text := get_actor_names(event_data["actors"], village_state)
	var consequences := format_effects(event_data["effects"], village_state)
	var entry := "[font_size=20][b]Día %d — %s, %s[/b][/font_size]\n[i]%s[/i]\n%s\n\n[b]Consecuencias[/b]\n[color=#b8a890]%s[/color]" % [
		village_state.day,
		time_name,
		event_data["location"],
		actors_text,
		event_data["text"],
		consequences
	]
	diary_history.append(entry)

func add_daily_economy_entry(village_state) -> void:
	if village_state.last_daily_resource_changes.is_empty():
		return
	var chunks: Array[String] = []
	for change: Dictionary in village_state.last_daily_resource_changes:
		chunks.append("• %s %+d (%s)" % [String(change["resource"]).capitalize(), int(change["delta"]), String(change.get("source", "aldea"))])
	var entry := "[font_size=20][b]Día %d — Balance de recursos[/b][/font_size]\n[i]Aldea[/i]\nLa aldea produce, consume y ajusta sus reservas.\n\n[b]Balance[/b]\n[color=#b8a890]%s[/color]" % [
		village_state.day,
		"\n".join(chunks)
	]
	diary_history.append(entry)

func get_recent_entries(max_entries: int = MAX_DIARY_ENTRIES) -> Array[String]:
	return diary_history.slice(max(0, diary_history.size() - max_entries), diary_history.size())

func get_actor_names(actor_ids: Array, village_state) -> String:
	var names: Array[String] = []
	for actor_id in actor_ids:
		names.append(village_state.npcs[actor_id]["name"])
	return ", ".join(names)

func format_effects(effects: Array, village_state) -> String:
	var chunks: Array[String] = []
	for effect in effects:
		if effect.has("stat"):
			chunks.append("• %s %s %+d" % [village_state.npcs[effect["target"]]["name"], effect["stat"].capitalize(), int(effect["delta"])])
		elif effect.has("state"):
			chunks.append("• %s %s %+d" % [village_state.npcs[effect["target"]]["name"], effect["state"].capitalize(), int(effect["delta"])])
		elif effect.has("relation_delta"):
			chunks.append("• %s → %s %+d" % [village_state.npcs[effect["from"]]["name"], village_state.npcs[effect["to"]]["name"], int(effect["relation_delta"])])
		elif effect.has("resource"):
			chunks.append("• %s %+d" % [String(effect["resource"]).capitalize(), int(effect["delta"])])
	if chunks.is_empty():
		return "Sin consecuencias registradas."
	return "\n".join(chunks)
