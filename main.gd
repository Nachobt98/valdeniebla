extends Control

const NPCDatabase = preload("res://data/npc_database.gd")
const EventDatabase = preload("res://data/event_database.gd")
const VillageState = preload("res://scripts/village_state.gd")
const EventSystem = preload("res://scripts/event_system.gd")
const DiarySystem = preload("res://scripts/diary_system.gd")

const DAY_TIMES := ["Mañana", "Tarde"]

var selected_npc_id: String = "aldric"
var village_state := VillageState.new()
var event_system := EventSystem.new()
var diary_system := DiarySystem.new()

@onready var title_label: Label = $RootMargin/RootLayout/TopBar/TopBarMargin/TitleLabel
@onready var npc_list: ItemList = $RootMargin/RootLayout/MainContent/LeftPanel/NPCMargin/NPCInfo/NPCList
@onready var npc_info_label: RichTextLabel = $RootMargin/RootLayout/MainContent/LeftPanel/NPCMargin/NPCInfo/NPCInfoLabel
@onready var village_overview_label: RichTextLabel = $RootMargin/RootLayout/MainContent/VillagePanel/VillageMargin/VillageOverviewLabel
@onready var diary_title_label: Label = $RootMargin/RootLayout/MainContent/RightPanel/NPCMargin/DiaryPanel/DiaryTitleLabel
@onready var diary_entries_label: RichTextLabel = $RootMargin/RootLayout/MainContent/RightPanel/NPCMargin/DiaryPanel/DiaryEntriesLabel
@onready var advance_day_button: Button = $RootMargin/RootLayout/MainContent/RightPanel/NPCMargin/DiaryPanel/AdvanceDayButton

func _ready() -> void:
	village_state.setup(NPCDatabase.get_npc_order(), NPCDatabase.get_initial_npcs())
	event_system.setup(EventDatabase.get_events())
	diary_system.setup_initial_entry()
	populate_npc_list()
	update_all_ui()
	advance_day_button.pressed.connect(_on_advance_day_pressed)
	npc_list.item_selected.connect(_on_npc_selected)

func populate_npc_list() -> void:
	npc_list.clear()
	for npc_id in village_state.npc_order:
		npc_list.add_item(village_state.npcs[npc_id]["name"])
	npc_list.select(0)

func _on_npc_selected(index: int) -> void:
	if index >= 0 and index < village_state.npc_order.size():
		selected_npc_id = village_state.npc_order[index]
		update_npc_panel()

func _on_advance_day_pressed() -> void:
	village_state.advance_day()
	for time_name in DAY_TIMES:
		var event_data = event_system.pick_event(village_state)
		event_system.apply_event(event_data, village_state)
		diary_system.add_entry(time_name, event_data, village_state)
	update_all_ui()

func update_all_ui() -> void:
	update_title()
	update_npc_panel()
	update_village_overview()
	update_diary()

func update_title() -> void:
	title_label.text = "Valdeniebla — %s, Año %d — Día %d" % [
		village_state.season,
		village_state.year,
		village_state.day
	]

func update_npc_panel() -> void:
	var npc: Dictionary = village_state.npcs[selected_npc_id]
	var text := "[b]%s[/b]\n%d años — %s\n[i]%s[/i]\n\n" % [
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

func update_village_overview() -> void:
	var average_mood := village_state.get_average_state("ánimo")
	var average_stress := village_state.get_average_state("estrés")
	village_overview_label.text = "[center][font_size=26][b]Valdeniebla[/b][/font_size][/center]\n\n" + \
		"[b]Pulso de la aldea[/b]\nÁnimo medio: %d/100\nEstrés medio: %d/100\nHabitantes registrados: %d\n\n" % [average_mood, average_stress, village_state.npc_order.size()] + \
		"[b]Lugares[/b]\nHerrería · Taberna · Pozo · Granjas · Prados · Capilla · Casa comunal\n\n" + \
		"[b]Rumor del día[/b]\nLa niebla baja aún se agarra a los tejados. En la plaza se oyen pasos, cubos de agua y conversaciones que nadie termina de decir en voz alta."

func update_diary() -> void:
	diary_title_label.text = "Crónica de la aldea"
	diary_entries_label.text = "\n\n".join(diary_system.get_recent_entries())

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
