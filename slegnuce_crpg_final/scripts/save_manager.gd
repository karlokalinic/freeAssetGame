extends RefCounted
class_name SaveManager

const SAVE_PATH := "user://savegame.dat"
const SAVE_VERSION := 1

static func save_state(state: Dictionary) -> Dictionary:
	var wrapped_state := {
		"version": SAVE_VERSION,
		"timestamp_unix": Time.get_unix_time_from_system(),
		"payload": state
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": "Failed to open save file for writing."}

	var bytes: PackedByteArray = var_to_bytes(wrapped_state)
	file.store_buffer(bytes)
	return {"ok": true, "error": ""}

static func load_state() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"ok": false, "error": "missing", "payload": {}}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "Failed to open save file for reading.", "payload": {}}

	var bytes: PackedByteArray = file.get_buffer(file.get_length())
	if bytes.is_empty():
		return {"ok": false, "error": "Save file is empty.", "payload": {}}

	var parsed: Variant = bytes_to_var(bytes)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Invalid save format.", "payload": {}}

	var wrapped_state: Dictionary = parsed
	if wrapped_state.get("version", -1) != SAVE_VERSION:
		return {"ok": false, "error": "Unsupported save version.", "payload": {}}

	var payload: Variant = wrapped_state.get("payload", {})
	if typeof(payload) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Missing save payload.", "payload": {}}

	return {"ok": true, "error": "", "payload": payload}
