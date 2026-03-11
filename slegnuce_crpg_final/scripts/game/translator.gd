extends RefCounted
class_name Translator

static func t(locale: String, key: String, fallback_locale: String, text_db: Dictionary) -> String:
	var bundle: Dictionary = text_db.get(locale, text_db.get(fallback_locale, {}))
	return str(bundle.get(key, key))
