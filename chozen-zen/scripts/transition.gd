extends CanvasLayer

## Autoload "Transition": troca de cena com fade, em vez de corte seco.

const COLOR := Color("1f4b3b")

var _rect := ColorRect.new()
var _busy := false

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect.color = COLOR
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.modulate.a = 0.0
	add_child(_rect)

## `color` permite emendar com o último quadro (ex.: a luz da porta de casa na cutscene).
func change_scene(path: String, color := COLOR) -> void:
	_run(func() -> void: get_tree().change_scene_to_file(path), color)

func reload() -> void:
	_run(func() -> void: get_tree().reload_current_scene())

func _run(swap: Callable, color := COLOR) -> void:
	if _busy:
		return
	_busy = true
	_rect.color = color
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	Audio.sfx("transition")
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 1.0, 0.35)
	await tween.finished
	get_tree().paused = false
	swap.call()
	await get_tree().process_frame
	tween = create_tween()
	tween.tween_property(_rect, "modulate:a", 0.0, 0.45)
	await tween.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
