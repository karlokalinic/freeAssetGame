extends Control
class_name HudController

@onready var _mini_hint: Label = $MiniHint
@onready var _expand_button: Button = $ExpandButton
@onready var _tutorial_panel: PanelContainer = $TutorialPanel
@onready var _collapse_button: Button = $TutorialPanel/TutorialVBox/TopActions/CollapseButton
@onready var _clear_button: Button = $TutorialPanel/TutorialVBox/TopActions/ClearMsgButton
@onready var _drag_hint: Label = $TutorialPanel/TutorialVBox/TopActions/DragHint
@onready var _dialogue_label: Label = $TutorialPanel/TutorialVBox/Dialogue
@onready var _controls_label: Label = $TutorialPanel/TutorialVBox/Instructions
@onready var _player_hp_label: Label = $TutorialPanel/TutorialVBox/PlayerHP
@onready var _npc_hp_label: Label = $TutorialPanel/TutorialVBox/NpcHP
@onready var _inventory_label: Label = $TutorialPanel/TutorialVBox/Inventory
@onready var _quest_label: Label = $TutorialPanel/TutorialVBox/Quest
@onready var _story_label: Label = $TutorialPanel/TutorialVBox/Story

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	_tutorial_panel.gui_input.connect(_on_tutorial_gui_input)

func setup_callbacks(show_tutorial: Callable, hide_tutorial: Callable, clear_message: Callable) -> void:
	_expand_button.pressed.connect(show_tutorial)
	_collapse_button.pressed.connect(hide_tutorial)
	_clear_button.pressed.connect(clear_message)

func _on_tutorial_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = event.global_position - _tutorial_panel.global_position
		else:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		_tutorial_panel.global_position = event.global_position - _drag_offset

func set_tutorial_visible(value: bool) -> void:
	_expand_button.visible = not value
	if value:
		_tutorial_panel.visible = true
		_tutorial_panel.modulate.a = 0.0
		create_tween().tween_property(_tutorial_panel, "modulate:a", 1.0, 0.15)
	else:
		if _tutorial_panel.visible:
			var tween := create_tween()
			tween.tween_property(_tutorial_panel, "modulate:a", 0.0, 0.12)
			tween.finished.connect(func(): _tutorial_panel.visible = false)

func is_tutorial_visible() -> bool:
	return _tutorial_panel.visible

func set_dialogue(message: String) -> void:
	_dialogue_label.text = message

func refresh(locale: String, state: GameState) -> void:
	_mini_hint.text = Translator.t(locale, "mini_hint", GameConstants.LOCALE_HR, GameConstants.TEXT)
	_expand_button.text = "Show Tutorial" if locale == GameConstants.LOCALE_EN else "Prikaži tutorial"
	_collapse_button.text = "Hide Tutorial" if locale == GameConstants.LOCALE_EN else "Sakrij tutorial"
	_clear_button.text = "Clear Msg" if locale == GameConstants.LOCALE_EN else "Očisti poruku"
	_drag_hint.text = "Drag panel" if locale == GameConstants.LOCALE_EN else "Povuci panel"
	_controls_label.text = Translator.t(locale, "controls", GameConstants.LOCALE_HR, GameConstants.TEXT)
	_player_hp_label.text = Translator.t(locale, "hud_player", GameConstants.LOCALE_HR, GameConstants.TEXT) % [state.player_hp, GameConstants.PLAYER_MAX_HP]
	_npc_hp_label.text = Translator.t(locale, "hud_npc", GameConstants.LOCALE_HR, GameConstants.TEXT) % [state.npc_hp, GameConstants.NPC_MAX_HP]

	if state.inventory.is_empty():
		_inventory_label.text = Translator.t(locale, "hud_inventory_empty", GameConstants.LOCALE_HR, GameConstants.TEXT)
	else:
		_inventory_label.text = Translator.t(locale, "hud_inventory", GameConstants.LOCALE_HR, GameConstants.TEXT) % ", ".join(state.inventory)

	_quest_label.text = Translator.t(locale, state.quest_key(), GameConstants.LOCALE_HR, GameConstants.TEXT)
	_story_label.text = Translator.t(locale, state.story_key(), GameConstants.LOCALE_HR, GameConstants.TEXT)
