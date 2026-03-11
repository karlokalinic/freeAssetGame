extends RefCounted
class_name SettingsManager

const SETTINGS_PATH := "user://settings.cfg"

static func load_settings() -> Dictionary:
	var defaults := {
		"fullscreen": false,
		"borderless": false,
		"vsync": true,
		"render_scale": 1.0,
		"camera_fov": 70.0,
		"ui_scale": 1.0,
		"language": GameConstants.LOCALE_HR,
		"master_volume_db": -6.0,
		"environment_volume_db": -8.0,
		"sfx_volume_db": -6.0
	}

	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return defaults

	defaults["fullscreen"] = bool(cfg.get_value("video", "fullscreen", defaults["fullscreen"]))
	defaults["borderless"] = bool(cfg.get_value("video", "borderless", defaults["borderless"]))
	defaults["vsync"] = bool(cfg.get_value("video", "vsync", defaults["vsync"]))
	defaults["render_scale"] = float(cfg.get_value("video", "render_scale", defaults["render_scale"]))
	defaults["camera_fov"] = float(cfg.get_value("video", "camera_fov", defaults["camera_fov"]))
	defaults["ui_scale"] = float(cfg.get_value("video", "ui_scale", defaults["ui_scale"]))
	defaults["language"] = str(cfg.get_value("gameplay", "language", defaults["language"]))
	defaults["master_volume_db"] = float(cfg.get_value("audio", "master_volume_db", defaults["master_volume_db"]))
	defaults["environment_volume_db"] = float(cfg.get_value("audio", "environment_volume_db", defaults["environment_volume_db"]))
	defaults["sfx_volume_db"] = float(cfg.get_value("audio", "sfx_volume_db", defaults["sfx_volume_db"]))
	return defaults

static func save_settings(settings: Dictionary) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", settings.get("fullscreen", false))
	cfg.set_value("video", "borderless", settings.get("borderless", false))
	cfg.set_value("video", "vsync", settings.get("vsync", true))
	cfg.set_value("video", "render_scale", settings.get("render_scale", 1.0))
	cfg.set_value("video", "camera_fov", settings.get("camera_fov", 70.0))
	cfg.set_value("video", "ui_scale", settings.get("ui_scale", 1.0))
	cfg.set_value("gameplay", "language", settings.get("language", GameConstants.LOCALE_HR))
	cfg.set_value("audio", "master_volume_db", settings.get("master_volume_db", -6.0))
	cfg.set_value("audio", "environment_volume_db", settings.get("environment_volume_db", -8.0))
	cfg.set_value("audio", "sfx_volume_db", settings.get("sfx_volume_db", -6.0))
	cfg.save(SETTINGS_PATH)

static func apply_settings(settings: Dictionary, viewport: Viewport) -> void:
	var fullscreen: bool = bool(settings.get("fullscreen", false))
	var borderless: bool = bool(settings.get("borderless", false))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if bool(settings.get("vsync", true)) else DisplayServer.VSYNC_DISABLED)
	viewport.scaling_3d_scale = clampf(float(settings.get("render_scale", 1.0)), 0.5, 1.5)
	viewport.content_scale_factor = clampf(float(settings.get("ui_scale", 1.0)), 0.8, 1.35)

	_set_bus_volume("Master", float(settings.get("master_volume_db", -6.0)), 0)
	_set_bus_volume("Environment", float(settings.get("environment_volume_db", -8.0)), 0)
	_set_bus_volume("SFX", float(settings.get("sfx_volume_db", -6.0)), 0)

static func _set_bus_volume(bus_name: String, volume_db: float, fallback_index: int) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		index = fallback_index
	AudioServer.set_bus_volume_db(index, volume_db)
