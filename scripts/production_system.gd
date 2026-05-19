extends RefCounted

var jobs: Dictionary = {}
var job_order: Array[String] = []

func setup(initial_jobs: Dictionary, initial_job_order: Array[String]) -> void:
	jobs = initial_jobs.duplicate(true)
	job_order = initial_job_order.duplicate(true)

func apply_daily_production(village_state) -> void:
	for job_id: String in job_order:
		var job: Dictionary = jobs.get(job_id, {})
		if job.is_empty():
			continue
		if not can_apply_job(job, village_state):
			apply_blocked_job_pressure(job, village_state)
			continue
		apply_job_effects(job, village_state)

func can_apply_job(job: Dictionary, village_state) -> bool:
	if job.has("requires_resource"):
		var required_resource := String(job.get("requires_resource", ""))
		var required_minimum := int(job.get("requires_minimum", 1))
		if village_state.get_resource(required_resource) < required_minimum:
			return false
	for worker_id: String in job.get("workers", []):
		if not village_state.npcs.has(worker_id):
			return false
		var worker_state: Dictionary = village_state.npcs[worker_id].get("state", {})
		if int(worker_state.get("salud", 100)) <= 15:
			return false
	return true

func apply_job_effects(job: Dictionary, village_state) -> void:
	for effect: Dictionary in job.get("daily_effects", []):
		village_state.change_resource(
			String(effect.get("resource", "")),
			int(effect.get("delta", 0)),
			String(effect.get("source", job.get("name", "Oficio")))
		)
	for effect: Dictionary in job.get("state_effects", []):
		village_state.change_state(
			String(effect.get("target", "all")),
			String(effect.get("state", "")),
			int(effect.get("delta", 0))
		)
	var stress_delta := int(job.get("stress_delta", 0))
	if stress_delta != 0:
		for worker_id: String in job.get("workers", []):
			village_state.change_state(worker_id, "estrés", stress_delta)

func apply_blocked_job_pressure(job: Dictionary, village_state) -> void:
	var job_name := String(job.get("name", "Oficio"))
	for worker_id: String in job.get("workers", []):
		if village_state.npcs.has(worker_id):
			village_state.change_state(worker_id, "estrés", 2)
	village_state.change_resource("moral", -1, "%s bloqueado" % job_name)

func get_job_summary_lines(village_state) -> Array[String]:
	var lines: Array[String] = []
	for job_id: String in job_order:
		var job: Dictionary = jobs.get(job_id, {})
		if job.is_empty():
			continue
		var worker_names: Array[String] = []
		for worker_id: String in job.get("workers", []):
			if village_state.npcs.has(worker_id):
				worker_names.append(String(village_state.npcs[worker_id].get("name", worker_id)))
			else:
				worker_names.append(worker_id)
		var status := "activo" if can_apply_job(job, village_state) else "bloqueado"
		lines.append("• %s — %s — %s" % [String(job.get("name", job_id)), ", ".join(worker_names), status])
	return lines
