extends Control

const FIRST_PHASE := "res://scenes/phase1_casa.tscn"

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(get_tree().quit)
	play_button.grab_focus()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.6)

func _on_play_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file(FIRST_PHASE)
