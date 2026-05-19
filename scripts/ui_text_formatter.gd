extends RefCounted

const BAR_SEGMENTS := 12

static func section(title: String) -> String:
	return "\n[color=#d8c28a][b]%s[/b][/color]\n[color=#6f6040]━━━━━━━━━━━━━━━━━━━━[/color]\n" % title

static func portrait(path: String) -> String:
	if path == "":
		return ""
	return "[center][img=190x190]%s[/img][/center]\n" % path

static func header(name: String, age: int, profession: String, location: String) -> String:
	return "[center][font_size=25][color=#f0dfb2][b]%s[/b][/color][/font_size]\n[color=#cdbf9c]%d años · %s[/color]\n[i][color=#b59d70]%s[/color][/i][/center]\n" % [name, age, profession, location]

static func trait_chips(traits: Array) -> String:
	var chips := PackedStringArray()
	for trait in traits:
		chips.append("[color=#e5d09d]‹ %s ›[/color]" % String(trait))
	return "  ".join(chips)

static func stats_block(stats: Dictionary) -> String:
	var chunks := PackedStringArray()
	for key in stats.keys():
		chunks.append("[color=#b7a77e]%s[/color] [color=#f0dfb2]%d[/color]" % [String(key).capitalize(), int(stats[key])])
	return "  ·  ".join(chunks)

static func state_block(state: Dictionary) -> String:
	var text := ""
	text += state_line("Salud", int(state.get("salud", 0)), false)
	text += state_line("Ánimo", int(state.get("ánimo", 0)), false)
	text += state_line("Estrés", int(state.get("estrés", 0)), true)
	return text

static func state_line(label: String, value: int, inverted: bool) -> String:
	var color := get_state_color(value, inverted)
	return "%s  [color=%s]%s[/color]  [color=#f0dfb2]%d[/color]/100\n" % [label, color, make_bar(value), value]

static func make_bar(value: int) -> String:
	var filled := int(round(clamp(value, 0, 100) / 100.0 * BAR_SEGMENTS))
	var empty := BAR_SEGMENTS - filled
	return "█".repeat(filled) + "░".repeat(empty)

static func get_state_color(value: int, inverted: bool) -> String:
	if inverted:
		if value >= 70:
			return "#a33b35"
		if value >= 45:
			return "#d09347"
		return "#8aac73"
	if value <= 30:
		return "#a33b35"
	if value <= 55:
		return "#d09347"
	return "#8aac73"

static func relationship_line(name: String, value: int) -> String:
	var color := "#cdbf9c"
	if value >= 15:
		color = "#8aac73"
	elif value <= -10:
		color = "#d09347"
	var sign := "+" if value > 0 else ""
	return "[color=#b7a77e]%s[/color] [color=%s]%s%d[/color]" % [name, color, sign, value]
