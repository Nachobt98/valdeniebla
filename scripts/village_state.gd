extends RefCounted

const DAYS_PER_MONTH := 14
const JobDatabase = preload("res://data/job_database.gd")

var day: int = 1
var day_of_month: int = 1
var month: int = 1
var season: String = "Primavera"
var year: int = 1
var current_strategy_id: String = "balanced"
var pending_decision_event: Dictionary = {}
var decision_event_history: Dictionary = {}
var npc_order: Array[String] = []
var npcs: Dictionary = {}
var buildings: Dictionary = {}
var event_history: Array[Dictionary] = []
var resources: Dictionary = {}
var last_daily_resource_changes: Array[Dictionary] = []
var last_daily_job_summaries: Array[Dictionary] = []

func setup(initial_npc_order: Array[String], initial_npcs: Dictionary, initial_resources: Dictionary = {}, initial_strategy_id: String = "balanced", initial_buildings: Dictionary = {}) -> void:
	npc_order = initial_npc_order.duplicate(true)
	npcs = initial_npcs.duplicate(true)
	resources = initial_resources.duplicate(true)
	buildings = initial_buildings.duplicate(true)
	current_strategy_id = initial_strategy_id
	event_history.clear()
	decision_event_history.clear()
	pending_decision_event.clear()
	last_daily_resource_changes.clear()
	last_daily_job_summaries.clear()

func advance_day() -> void:
	day += 1
	day_of_month += 1
	if day_of_month > DAYS_PER_MONTH:
		day_of_month = 1
		month += 1
	last_daily_resource_changes.clear()
	last_daily_job_summaries.clear()

func is_start_of_month() -> bool:
	return day_of_month == 1

func set_monthly_strategy(strategy_id: String) -> void:
	current_strategy_id = strategy_id

func get_building(building_id: String) -> Dictionary:
	return buildings.get(building_id, {})

func has_building(building_id: String) -> bool:
	return buildings.has(building_id)

func change_building_condition(building_id: String, delta: int) -> void:
	if not buildings.has(building_id):
		return
	var building: Dictionary = buildings[building_id]
	building["condition"] = int(clamp(int(building.get("condition", 100)) + delta, 0, 100))
	if int(building["condition"]) <= 20:
		building["status"] = "Dañada"
	elif int(building["condition"]) <= 60:
		building["status"] = "Desgastada"

func change_stat(npc_id: String, stat_name: String, delta: int) -> void:
	var stats: Dictionary = npcs[npc_id]["stats"]
	stats[stat_name] = int(stats.get(stat_name, 0)) + delta

func change_state(npc_id: String, state_name: String, delta: int) -> void:
	if npc_id == "all":
		for target_id: String in npc_order:
			change_state(target_id, state_name, delta)
		return
	if not npcs.has(npc_id):
		return
	var state: Dictionary = npcs[npc_id]["state"]
	state[state_name] = int(clamp(int(state.get(state_name, 0)) + delta, 0, 100))

func change_relation(from_id: String, to_id: String, delta: int) -> void:
	var relationships: Dictionary = npcs[from_id]["relationships"]
	relationships[to_id] = int(clamp(int(relationships.get(to_id, 0)) + delta, -100, 100))

func change_resource(resource_name: String, delta: int, source: String = "") -> void:
	var current_value: int = int(resources.get(resource_name, 0))
	resources[resource_name] = max(0, current_value + delta)
	last_daily_resource_changes.append({"resource": resource_name, "delta": delta, "source": source})

func get_resource(resource_name: String) -> int:
	return int(resources.get(resource_name, 0))

func apply_daily_economy(resource_database, strategy_database = null) -> void:
	for rule: Dictionary in resource_database.get_daily_production_rules():
		if can_apply_resource_rule(rule):
			change_resource(String(rule["resource"]), int(rule["delta"]), String(rule["source"]))
	apply_daily_job_state_effects()
	apply_food_consumption()
	for rule: Dictionary in resource_database.get_periodic_cost_rules():
		var every_days: int = int(rule.get("every_days", 1))
		if every_days > 0 and day % every_days == 0:
			change_resource(String(rule["resource"]), int(rule["delta"]), String(rule["source"]))
	if strategy_database != null:
		apply_monthly_strategy_effects(strategy_database)
	apply_low_resource_pressure()

func apply_daily_job_state_effects() -> void:
	for job_id: String in JobDatabase.get_job_order():
		var job: Dictionary = JobDatabase.get_job(job_id)
		var status := get_job_status(job)
		last_daily_job_summaries.append({"job": job.get("name", job_id), "status": status, "workers": get_job_worker_names(job)})
		if status == "bloqueado":
			for worker_id: String in job.get("workers", []):
				change_state(worker_id, "estrés", 2)
			change_resource("moral", -1, "%s bloqueado" % String(job.get("name", "Oficio")))
			continue
		for effect: Dictionary in job.get("state_effects", []):
			change_state(String(effect.get("target", "all")), String(effect.get("state", "")), int(effect.get("delta", 0)))
		var stress_delta := int(job.get("stress_delta", 0))
		if stress_delta != 0:
			for worker_id: String in job.get("workers", []):
				change_state(worker_id, "estrés", stress_delta)

func get_job_status(job: Dictionary) -> String:
	if job.has("requires_resource") and get_resource(String(job.get("requires_resource", ""))) < int(job.get("requires_minimum", 1)):
		return "bloqueado"
	for worker_id: String in job.get("workers", []):
		if not npcs.has(worker_id):
			return "bloqueado"
		var state: Dictionary = npcs[worker_id].get("state", {})
		if int(state.get("salud", 100)) <= 15:
			return "bloqueado"
		if int(state.get("estrés", 0)) >= 70 or int(state.get("salud", 100)) <= 35:
			return "riesgo"
	return "activo"

func get_job_worker_names(job: Dictionary) -> String:
	var names: Array[String] = []
	for worker_id: String in job.get("workers", []):
		names.append(String(npcs.get(worker_id, {}).get("name", worker_id)))
	return ", ".join(names)

func get_job_summary_lines() -> Array[String]:
	var lines: Array[String] = []
	for job_id: String in JobDatabase.get_job_order():
		var job: Dictionary = JobDatabase.get_job(job_id)
		lines.append("• %s — %s — %s" % [String(job.get("name", job_id)), get_job_worker_names(job), get_job_status(job)])
	return lines

func apply_monthly_strategy_effects(strategy_database) -> void:
	var strategy: Dictionary = strategy_database.get_strategy(current_strategy_id)
	var resource_modifiers: Dictionary = strategy.get("resource_modifiers", {})
	for resource_name: String in resource_modifiers.keys():
		change_resource(resource_name, int(resource_modifiers[resource_name]), "Prioridad: %s" % strategy.get("name", "Equilibrada"))
	var state_modifiers: Dictionary = strategy.get("state_modifiers", {})
	for state_name: String in state_modifiers.keys():
		for npc_id: String in npc_order:
			change_state(npc_id, state_name, int(state_modifiers[state_name]))

func can_apply_resource_rule(rule: Dictionary) -> bool:
	if rule.has("workers"):
		for worker_id: String in rule.get("workers", []):
			if not npcs.has(worker_id):
				return false
			var state: Dictionary = npcs[worker_id].get("state", {})
			if int(state.get("salud", 100)) <= 15:
				return false
	if rule.has("requires_resource"):
		var required_resource: String = String(rule["requires_resource"])
		var required_minimum: int = int(rule.get("requires_minimum", 1))
		return get_resource(required_resource) >= required_minimum
	return true

func apply_food_consumption() -> void:
	change_resource("comida", -npc_order.size(), "Habitantes")

func apply_low_resource_pressure() -> void:
	if get_resource("comida") <= 5:
		for npc_id: String in npc_order:
			change_state(npc_id, "ánimo", -1)
			change_state(npc_id, "estrés", 1)
		change_resource("moral", -2, "Escasez de comida")
	if get_resource("moral") <= 20:
		for npc_id: String in npc_order:
			change_state(npc_id, "estrés", 1)
	if get_resource("seguridad") <= 20:
		change_resource("moral", -1, "Inseguridad")

func has_pending_decision() -> bool:
	return not pending_decision_event.is_empty()

func set_pending_decision(event_data: Dictionary) -> void:
	pending_decision_event = event_data.duplicate(true)

func clear_pending_decision() -> void:
	pending_decision_event.clear()

func can_pay_requirements(requirements: Dictionary) -> bool:
	for resource_name: String in requirements.keys():
		if get_resource(resource_name) < int(requirements[resource_name]):
			return false
	return true

func apply_decision_option(option_data: Dictionary) -> void:
	for effect: Dictionary in option_data.get("effects", []):
		if effect.has("resource"):
			change_resource(effect["resource"], int(effect["delta"]), pending_decision_event.get("title", "Decisión"))
		elif effect.has("state"):
			change_state(effect.get("target", "all"), effect["state"], int(effect["delta"]))
		elif effect.has("relation_delta"):
			change_relation(effect["from"], effect["to"], int(effect["relation_delta"]))
		elif effect.has("building"):
			change_building_condition(effect["building"], int(effect["delta"]))
	var event_id: String = String(pending_decision_event.get("id", ""))
	if event_id != "":
		decision_event_history[event_id] = day
	clear_pending_decision()

func days_since_decision_event(event_id: String) -> int:
	if not decision_event_history.has(event_id):
		return 100000
	return day - int(decision_event_history[event_id])

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