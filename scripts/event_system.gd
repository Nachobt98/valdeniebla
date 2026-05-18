extends RefCounted

const REPEATED_CATEGORY_PENALTY := 0.45
const HIGH_STRESS_THRESHOLD := 50
const LOW_MOOD_THRESHOLD := 40

var events: Array[Dictionary] = []

func setup(initial_events: Array[Dictionary]) -> void:
	events = initial_events.duplicate(true)

func pick_event(village_state) -> Dictionary:
	var weighted_events: Array[Dictionary] = []
	var total_weight := 0.0
	for event_data in events:
		if is_event_eligible(event_data, village_state):
			var final_weight := get_final_weight(event_data, village_state)
			if final_weight > 0.0:
				weighted_events.append({"event": event_data, "weight": final_weight})
				total_weight += final_weight
	if weighted_events.is_empty():
		return events.pick_random()
	var roll := randf() * total_weight
	var cursor := 0.0
	for weighted_event in weighted_events:
		cursor += float(weighted_event["weight"])
		if roll <= cursor:
			return weighted_event["event"]
	return weighted_events[weighted_events.size() - 1]["event"]

func is_event_eligible(event_data: Dictionary, village_state) -> bool:
	if not are_actors_valid(event_data, village_state):
		return false
	if bool(event_data.get("unique", false)) and village_state.has_event_happened(event_data["id"]):
		return false
	var cooldown_days := int(event_data.get("cooldown_days", 0))
	if village_state.days_since_event(event_data["id"]) < cooldown_days:
		return false
	if village_state.get_last_event_id() == event_data["id"]:
		return false
	if not event_data.has("conditions"):
		return true
	return are_conditions_met(event_data["conditions"], village_state)

func are_actors_valid(event_data: Dictionary, village_state) -> bool:
	for actor_id in event_data.get("actors", []):
		if not village_state.npcs.has(actor_id):
			return false
	return true

func are_conditions_met(conditions: Dictionary, village_state) -> bool:
	if conditions.has("min_day") and village_state.day < int(conditions["min_day"]):
		return false
	if conditions.has("min_relation"):
		var condition = conditions["min_relation"]
		if village_state.get_relation(condition["from"], condition["to"]) < int(condition["value"]):
			return false
	if conditions.has("max_relation"):
		var condition = conditions["max_relation"]
		if village_state.get_relation(condition["from"], condition["to"]) > int(condition["value"]):
			return false
	if conditions.has("min_state"):
		var condition = conditions["min_state"]
		if int(village_state.npcs[condition["target"]]["state"].get(condition["state"], 0)) < int(condition["value"]):
			return false
	if conditions.has("max_state"):
		var condition = conditions["max_state"]
		if int(village_state.npcs[condition["target"]]["state"].get(condition["state"], 0)) > int(condition["value"]):
			return false
	if conditions.has("min_stat"):
		var condition = conditions["min_stat"]
		if int(village_state.npcs[condition["target"]]["stats"].get(condition["stat"], 0)) < int(condition["value"]):
			return false
	if conditions.has("max_stat"):
		var condition = conditions["max_stat"]
		if int(village_state.npcs[condition["target"]]["stats"].get(condition["stat"], 0)) > int(condition["value"]):
			return false
	return true

func get_final_weight(event_data: Dictionary, village_state) -> float:
	var final_weight := float(event_data.get("weight", 1.0))
	var category := String(event_data.get("category", "uncategorized"))
	var recent_categories := village_state.get_recent_event_categories(3)
	if category in recent_categories:
		final_weight *= REPEATED_CATEGORY_PENALTY
	final_weight *= get_dynamic_category_multiplier(category, village_state)
	final_weight *= get_dynamic_actor_multiplier(event_data, village_state)
	return max(final_weight, 0.0)

func get_dynamic_category_multiplier(category: String, village_state) -> float:
	var multiplier := 1.0
	var average_stress := village_state.get_average_state("estrés")
	var average_mood := village_state.get_average_state("ánimo")
	if average_stress >= HIGH_STRESS_THRESHOLD and category == "conflict":
		multiplier *= 1.35
	if average_stress >= HIGH_STRESS_THRESHOLD and category == "relief":
		multiplier *= 1.25
	if average_mood <= LOW_MOOD_THRESHOLD and category == "relief":
		multiplier *= 1.35
	if average_mood <= LOW_MOOD_THRESHOLD and category == "positive":
		multiplier *= 1.15
	return multiplier

func get_dynamic_actor_multiplier(event_data: Dictionary, village_state) -> float:
	var multiplier := 1.0
	for actor_id in event_data.get("actors", []):
		var actor_state: Dictionary = village_state.npcs[actor_id]["state"]
		if int(actor_state.get("estrés", 0)) >= 65 and event_data.get("tone", "neutral") == "tense":
			multiplier *= 1.15
		if int(actor_state.get("ánimo", 0)) <= 35 and event_data.get("tone", "neutral") == "relief":
			multiplier *= 1.15
	return multiplier

func apply_event(event_data: Dictionary, village_state) -> void:
	for effect in event_data["effects"]:
		if effect.has("stat"):
			village_state.change_stat(effect["target"], effect["stat"], int(effect["delta"]))
		elif effect.has("state"):
			village_state.change_state(effect["target"], effect["state"], int(effect["delta"]))
		elif effect.has("relation_delta"):
			village_state.change_relation(effect["from"], effect["to"], int(effect["relation_delta"]))
	village_state.record_event(event_data)
