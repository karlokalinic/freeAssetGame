extends RefCounted
class_name EvidenceTracker

var evidence: Array[String] = []

func add_evidence(item: String) -> void:
	if item.is_empty():
		return
	if evidence.has(item):
		return
	evidence.append(item)

func summary() -> String:
	if evidence.is_empty():
		return "Evidence: none"
	return "Evidence: %s" % ", ".join(evidence)

func to_array() -> Array[String]:
	return evidence.duplicate()

func load_from_array(data: Array) -> void:
	evidence.clear()
	for entry in data:
		evidence.append(str(entry))
