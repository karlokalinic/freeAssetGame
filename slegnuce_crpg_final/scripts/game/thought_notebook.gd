extends RefCounted
class_name ThoughtNotebook

var thoughts: Array[String] = []

func unlock(thought: String) -> void:
	if thought.is_empty():
		return
	if thoughts.has(thought):
		return
	thoughts.append(thought)

func summary() -> String:
	if thoughts.is_empty():
		return "No active thoughts"
	return "Thoughts: %s" % ", ".join(thoughts)

func to_array() -> Array[String]:
	return thoughts.duplicate()

func load_from_array(data: Array) -> void:
	thoughts.clear()
	for entry in data:
		thoughts.append(str(entry))
