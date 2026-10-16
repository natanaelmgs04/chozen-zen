extends Control

## Abertura com o logo do Estúdio Vívido. Qualquer tecla ou clique pula.

const NEXT_SCENE := "res://scenes/main_menu.tscn"

@onready var logo: TextureRect = $Logo

var _leaving := false

func _ready() -> void:
	logo.modulate.a = 0.0
	Audio.sfx("memory", -4.0)
	var tween := create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, 0.7)
	tween.tween_interval(1.4)
	tween.tween_property(logo, "modulate:a", 0.0, 0.6)
	tween.tween_callback(_go_next)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton):
		_go_next()

func _go_next() -> void:
	if _leaving:
		return
	_leaving = true
	Transition.change_scene(NEXT_SCENE)
