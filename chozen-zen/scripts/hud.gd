extends CanvasLayer

## HUD de Reputação (RF-AGE-003): barra 0-100 com o número e cor por faixa.

const COLOR_LOW := Color("c8412d")
const COLOR_MID := Color("e6b422")
const COLOR_HIGH := Color("5fae3e")

@onready var bar: ProgressBar = %Bar
@onready var value_label: Label = %Value

var _fill := StyleBoxFlat.new()
var _tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bar.add_theme_stylebox_override("fill", _fill)
	GameState.reputation_changed.connect(_show.bind(true))
	_show(GameState.reputation, false)

static func color_for(value: int) -> Color:
	if value <= 20:
		return COLOR_LOW
	if value <= 80:
		return COLOR_MID
	return COLOR_HIGH

func _show(value: int, animate: bool) -> void:
	value_label.text = "%d%%" % value
	_fill.bg_color = color_for(value)
	if _tween:
		_tween.kill()
	if animate:
		_tween = create_tween()
		_tween.tween_property(bar, "value", float(value), 0.4)
	else:
		bar.value = value
