extends RefCounted
class_name ResonanceSystem

const VOICES := ["Empathy", "Logic", "Defiance", "Institution", "Memory", "Instinct"]

var levels: Dictionary = {
	"Empathy": 1,
	"Logic": 1,
	"Defiance": 1,
	"Institution": 1,
	"Memory": 1,
	"Instinct": 1
}

func apply_delta(voice: String, amount: int) -> void:
	if not levels.has(voice):
		return
	levels[voice] = clampi(int(levels[voice]) + amount, 1, 6)

func summary() -> String:
	var parts: Array[String] = []
	for voice in VOICES:
		parts.append("%s:%d" % [voice.substr(0, 3), int(levels[voice])])
	return " | ".join(parts)

func to_dict() -> Dictionary:
	return levels.duplicate(true)

func load_from_dict(data: Dictionary) -> void:
	for voice in VOICES:
		levels[voice] = clampi(int(data.get(voice, 1)), 1, 6)
