extends Control

const OPENING := "res://scenes/cutscene_intro.tscn"

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var controls_button: Button = %ControlsButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_button: Button = %QuitButton
@onready var logo: Control = %Logo
@onready var _panels := {
	settings_button: $SettingsPanel as OverlayPanel,
	controls_button: $ControlsPanel as OverlayPanel,
	credits_button: $CreditsPanel as OverlayPanel,
}

var _time := 0.0
var _logo_y := 0.0

func _ready() -> void:
	Audio.play_music()
	Audio.stop_ambience()
	Audio.set_music_muffled(false)
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(get_tree().quit)
	# No navegador "Sair" não fecha a aba; esconder evita um botão que não faz nada.
	quit_button.visible = not OS.has_feature("web")
	for button: Button in _panels:
		var panel: OverlayPanel = _panels[button]
		button.pressed.connect(panel.open)
		panel.closed.connect(button.grab_focus)
	play_button.grab_focus()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.6)
	_logo_y = logo.position.y

func _process(delta: float) -> void:
	_time += delta
	logo.position.y = _logo_y + sin(_time * 1.3) * 3.0

func _on_play_pressed() -> void:
	GameState.reset()
	Transition.change_scene(OPENING)
