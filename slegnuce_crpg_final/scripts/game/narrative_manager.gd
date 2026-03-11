extends RefCounted
class_name NarrativeManager

var current_node: String = NarrativeData.ROOT

func start() -> void:
	current_node = NarrativeData.ROOT

func get_text(locale: String) -> String:
	var node: Dictionary = NarrativeData.NODES.get(current_node, {})
	return str(node.get(locale, node.get("en", "")))

func get_choices(locale: String) -> Array[String]:
	var node: Dictionary = NarrativeData.NODES.get(current_node, {})
	var choices: Array = node.get("choices", [])
	var labels: Array[String] = []
	for choice in choices:
		labels.append(str(choice.get(locale, choice.get("en", "..."))))
	return labels

func choose(index: int, locale: String, state: GameState, resonance: ResonanceSystem, notebook: ThoughtNotebook, evidence: EvidenceTracker) -> String:
	var node: Dictionary = NarrativeData.NODES.get(current_node, {})
	var choices: Array = node.get("choices", [])
	if index < 0 or index >= choices.size():
		return ""
	var choice: Dictionary = choices[index]

	if choice.has("voice"):
		resonance.apply_delta(str(choice.get("voice", "")), int(choice.get("delta", 0)))
	if choice.has("thought"):
		notebook.unlock(str(choice.get("thought", "")))
	if choice.has("evidence"):
		evidence.add_evidence(str(choice.get("evidence", "")))

	current_node = str(choice.get("next", current_node))
	state.advance_time_slot()

	var new_node: Dictionary = NarrativeData.NODES.get(current_node, {})
	return str(new_node.get(locale, new_node.get("en", "")))

func to_dict() -> Dictionary:
	return {"current_node": current_node}

func load_from_dict(data: Dictionary) -> void:
	current_node = str(data.get("current_node", NarrativeData.ROOT))
