class_name OverlayPanel
extends Control

## Base dos painéis sobrepostos (Configurações, Controles, Créditos):
## abre com animação e som, fecha com "Voltar" ou Esc.

signal closed

@onready var _panel: Control = $Panel
@onready var _back: Button = %BackButton

func _ready() -> void:
	visible = false
	_back.pressed.connect(close)
	_panel.resized.connect(func() -> void: _panel.pivot_offset = _panel.size / 2)

func open() -> void:
	visible = true
	Audio.sfx("open")
	_panel.scale = Vector2.ONE * 0.95
	_panel.modulate.a = 0.0
	var tween := create_tween().set_parallel().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.18)
	_first_focus().grab_focus.call_deferred()

func close() -> void:
	visible = false
	closed.emit()

func _first_focus() -> Control:
	return _back

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
