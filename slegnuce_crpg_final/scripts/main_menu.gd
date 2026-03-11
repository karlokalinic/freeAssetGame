extends Control

const GAME_SCENE := "res://scenes/Game.tscn"

@onready var _new_game_button: Button = $CenterContainer/PanelContainer/VBoxContainer/NewGameButton
@onready var _settings_button: Button = $CenterContainer/PanelContainer/VBoxContainer/SettingsButton
@onready var _quit_button: Button = $CenterContainer/PanelContainer/VBoxContainer/QuitButton
@onready var _settings_panel: PanelContainer = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel
@onready var _fullscreen_check: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/FullscreenCheck
@onready var _borderless_check: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/BorderlessCheck
@onready var _vsync_check: CheckBox = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/VsyncCheck
@onready var _render_scale_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/RenderScaleSlider
@onready var _camera_fov_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/CameraFovSlider
@onready var _ui_scale_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/UiScaleSlider
@onready var _language_option: OptionButton = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/LanguageOption
@onready var _master_volume_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/MasterVolumeSlider
@onready var _environment_volume_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/EnvironmentVolumeSlider
@onready var _sfx_volume_slider: HSlider = $CenterContainer/PanelContainer/VBoxContainer/SettingsPanel/SettingsVBox/SfxVolumeSlider
@onready var _status: Label = $CenterContainer/PanelContainer/VBoxContainer/Status

var _settings: Dictionary = {}

func _ready() -> void:
	_language_option.add_item("Hrvatski", 0)
	_language_option.add_item("English", 1)

	_new_game_button.pressed.connect(_on_new_game_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_fullscreen_check.toggled.connect(_on_setting_changed)
	_borderless_check.toggled.connect(_on_setting_changed)
	_vsync_check.toggled.connect(_on_setting_changed)
	_render_scale_slider.value_changed.connect(_on_setting_changed)
	_camera_fov_slider.value_changed.connect(_on_setting_changed)
	_ui_scale_slider.value_changed.connect(_on_setting_changed)
	_language_option.item_selected.connect(_on_setting_changed)
	_master_volume_slider.value_changed.connect(_on_setting_changed)
	_environment_volume_slider.value_changed.connect(_on_setting_changed)
	_sfx_volume_slider.value_changed.connect(_on_setting_changed)

	_settings = SettingsManager.load_settings()
	_apply_settings_to_ui()
	_apply_and_save_settings(false)

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_settings_pressed() -> void:
	_settings_panel.visible = not _settings_panel.visible
	_status.text = "Settings opened." if _settings_panel.visible else "Settings closed."

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_setting_changed(_value: Variant = null) -> void:
	_apply_and_save_settings(true)

func _apply_settings_to_ui() -> void:
	_fullscreen_check.button_pressed = bool(_settings.get("fullscreen", false))
	_borderless_check.button_pressed = bool(_settings.get("borderless", false))
	_vsync_check.button_pressed = bool(_settings.get("vsync", true))
	_render_scale_slider.value = float(_settings.get("render_scale", 1.0))
	_camera_fov_slider.value = float(_settings.get("camera_fov", 70.0))
	_ui_scale_slider.value = float(_settings.get("ui_scale", 1.0))
	_master_volume_slider.value = float(_settings.get("master_volume_db", -6.0))
	_environment_volume_slider.value = float(_settings.get("environment_volume_db", -8.0))
	_sfx_volume_slider.value = float(_settings.get("sfx_volume_db", -6.0))

	var language := str(_settings.get("language", GameConstants.LOCALE_HR))
	_language_option.select(1 if language == GameConstants.LOCALE_EN else 0)

func _collect_ui_settings() -> Dictionary:
	return {
		"fullscreen": _fullscreen_check.button_pressed,
		"borderless": _borderless_check.button_pressed,
		"vsync": _vsync_check.button_pressed,
		"render_scale": _render_scale_slider.value,
		"camera_fov": _camera_fov_slider.value,
		"ui_scale": _ui_scale_slider.value,
		"language": GameConstants.LOCALE_EN if _language_option.selected == 1 else GameConstants.LOCALE_HR,
		"master_volume_db": _master_volume_slider.value,
		"environment_volume_db": _environment_volume_slider.value,
		"sfx_volume_db": _sfx_volume_slider.value
	}

func _apply_and_save_settings(show_status: bool) -> void:
	_settings = _collect_ui_settings()
	SettingsManager.apply_settings(_settings, get_viewport())
	SettingsManager.save_settings(_settings)
	if show_status:
		_status.text = "Settings saved (%s)." % OS.get_name()
