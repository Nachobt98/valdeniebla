extends RefCounted

var events: Array[Dictionary] = []

func setup(initial_events: Array[Dictionary]) -> void:
	events = initial_events.duplicate(true)

func pick_event(village_state) -> Dictionary:
	var eligible_events: Array[Dictionary] = []
	for event_data in events:
		if is_event_eligible(event_data, village_state):
			eligible_events.append(event_data)
	if eligible_events.is_empty():
		return events.pick_random()
	return eligible_events.pick_random()

func is_event_eligible(event_data: Dictionary, village_state) -> bool:
	if not event_data.has("conditions"):
		return true
	var conditions: Dictionary = event_data["conditions"]
	if conditions.has("min_day") and village_state.day < int(conditions["min_day"]):
		return false
	if conditions.has("min_relation"):
		var condition = conditions["min_relation"]
		if village_state.get_relation(condition["from"], condition["to"]) < int(condition["value"]):
			return false
	if conditions.has("min_state"):
		var condition = conditions["min_state"]
		if int(village_state.npcs[condition["target"]]["state"].get(condition["state"], 0)) < int(condition["value"]):
			return false
	return true

func apply_event(event_data: Dictionary, village_state) -> void:
	for effect in event_data["effects"]:
		if effect.has("stat"):
			village_state.change_stat(effect["target"], effect["stat"], int(effect["delta"]))
		elif effect.has("state"):
			village_state.change_state(effect["target"], effect["state"], int(effect["delta"]))
		elif effect.has("relation_delta"):
			village_state.change_relation(effect["from"], effect["to"], int(effect["relation_delta"]))
