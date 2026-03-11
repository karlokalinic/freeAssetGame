extends RefCounted
class_name AbilitySystem

var unlocked: Dictionary = {
	"cross_reference": false,
	"interview_pressure": false,
	"toxicology_sense": false,
	"public_statement": false
}

func evaluate(resonance: ResonanceSystem, notebook: ThoughtNotebook, evidence: EvidenceTracker) -> Array[String]:
	var newly_unlocked: Array[String] = []

	if not unlocked.cross_reference and evidence.evidence.size() >= 2:
		unlocked.cross_reference = true
		newly_unlocked.append("cross_reference")

	if not unlocked.interview_pressure and int(resonance.levels.get("Defiance", 1)) >= 3:
		unlocked.interview_pressure = true
		newly_unlocked.append("interview_pressure")

	if not unlocked.toxicology_sense and notebook.thoughts.size() >= 2:
		unlocked.toxicology_sense = true
		newly_unlocked.append("toxicology_sense")

	if not unlocked.public_statement and unlocked.cross_reference and unlocked.interview_pressure and unlocked.toxicology_sense:
		unlocked.public_statement = true
		newly_unlocked.append("public_statement")

	return newly_unlocked

func is_unlocked(key: String) -> bool:
	return bool(unlocked.get(key, false))

func summary() -> String:
	var active: Array[String] = []
	for key in unlocked.keys():
		if bool(unlocked[key]):
			active.append(key)
	if active.is_empty():
		return "none"
	return ", ".join(active)

func to_dict() -> Dictionary:
	return unlocked.duplicate(true)

func load_from_dict(data: Dictionary) -> void:
	for key in unlocked.keys():
		unlocked[key] = bool(data.get(key, false))

func reset() -> void:
	for key in unlocked.keys():
		unlocked[key] = false
