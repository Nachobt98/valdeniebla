extends Control

var day: int = 1
var season: String = "Primavera"
var year: int = 1

var aldric := {
	"name": "Aldric",
	"age": 19,
	"profession": "Aprendiz de herrero",
	"traits": ["Trabajador", "Orgulloso", "Impaciente"],
	"smithing": 6,
	"strength": 5,
	"charisma": 2,
	"gareth_relation": 45,
	"mara_relation": 10,
	"elowen_relation": -5
}

var diary_history: Array[String] = []

var possible_events := [
	{
		"text": "Aldric trabajó en la herrería durante toda la mañana.",
		"smithing": 1,
		"gareth": 1,
		"mara": 0,
		"elowen": 0
	},
	{
		"text": "Gareth corrigió la técnica de Aldric en la forja.",
		"smithing": 1,
		"gareth": 2,
		"mara": 0,
		"elowen": 0
	},
	{
		"text": "Mara saludó a Aldric cerca del pozo.",
		"smithing": 0,
		"gareth": 0,
		"mara": 2,
		"elowen": 0
	},
	{
		"text": "Elowen evitó hablar con Aldric en la plaza.",
		"smithing": 0,
		"gareth": 0,
		"mara": 0,
		"elowen": -2
	},
	{
		"text": "Aldric terminó una pequeña herramienta y ganó confianza.",
		"smithing": 1,
		"gareth": 1,
		"mara": 0,
		"elowen": 0
	},
	{
		"text": "Un viajero llegó a la taberna contando rumores del norte.",
		"smithing": 0,
		"gareth": 0,
		"mara": 1,
		"elowen": 0
	},
	{
		"text": "La lluvia dificultó el trabajo en las granjas.",
		"smithing": 0,
		"gareth": 0,
		"mara": 0,
		"elowen": 0
	},
	{
		"text": "El herrero recibió un encargo urgente del alcalde.",
		"smithing": 1,
		"gareth": 2,
		"mara": 0,
		"elowen": 0
	},
	{
		"text": "Aldric se quemó levemente la mano, pero siguió trabajando.",
		"smithing": 1,
		"gareth": 1,
		"mara": 0,
		"elowen": 0
	},
	{
		"text": "Mara defendió a Aldric durante una conversación incómoda.",
		"smithing": 0,
		"gareth": 0,
		"mara": 3,
		"elowen": 0
	}
]

@onready var title_label: Label = $RootLayout/TopBar/TitleLabel
@onready var npc_info_label: Label = $RootLayout/MainContent/LeftPanel/NPCMargin/NPCInfo/NPCNameLabel
@onready var diary_entries_label: RichTextLabel = $RootLayout/MainContent/RightPanel/NPCMargin/DiaryPanel/DiaryEntriesLabel
@onready var advance_day_button: Button = $RootLayout/MainContent/RightPanel/NPCMargin/DiaryPanel/AdvanceDayButton

func _ready() -> void:
	diary_history.append("[b]Día 1 — Mañana[/b]\nAldric trabajó en la herrería.")
	diary_history.append("[b]Día 1 — Tarde[/b]\nMara saludó a Aldric cerca del pozo.")
	
	update_title()
	update_npc_panel()
	update_diary()
	
	advance_day_button.pressed.connect(_on_advance_day_pressed)

func _on_advance_day_pressed() -> void:
	day += 1
	
	var morning_event = possible_events.pick_random()
	var afternoon_event = possible_events.pick_random()
	
	apply_event(morning_event)
	apply_event(afternoon_event)
	
	diary_history.append("[b]Día %d — Mañana[/b]\n%s" % [day, morning_event["text"]])
	diary_history.append("[b]Día %d — Tarde[/b]\n%s" % [day, afternoon_event["text"]])
	
	update_title()
	update_npc_panel()
	update_diary()

func apply_event(event_data: Dictionary) -> void:
	aldric["smithing"] += event_data["smithing"]
	aldric["gareth_relation"] += event_data["gareth"]
	aldric["mara_relation"] += event_data["mara"]
	aldric["elowen_relation"] += event_data["elowen"]

func update_title() -> void:
	title_label.text = "Valdeniebla — %s, Año %d — Día %d" % [season, year, day]

func update_npc_panel() -> void:
	npc_info_label.text = "%s\n%d años — %s\n\nRasgos: %s\n\nForja: %d | Fuerza: %d | Carisma: %d\n\nRelaciones:\nGareth %+d\nMara %+d\nElowen %+d" % [
		aldric["name"],
		aldric["age"],
		aldric["profession"],
		", ".join(aldric["traits"]),
		aldric["smithing"],
		aldric["strength"],
		aldric["charisma"],
		aldric["gareth_relation"],
		aldric["mara_relation"],
		aldric["elowen_relation"]
	]

func update_diary() -> void:
	var recent_entries = diary_history.slice(max(0, diary_history.size() - 8), diary_history.size())
	diary_entries_label.text = "\n\n".join(recent_entries)
