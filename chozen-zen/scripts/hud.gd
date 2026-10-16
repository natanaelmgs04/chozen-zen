extends CanvasLayer

## HUD: Reputação (RF-AGE-003, cor por faixa), Energia (RF-ENE-001), objetivo atual, avisos
## e "memórias" (aviso de que uma escolha terá consequência, como em Telltale/Life is Strange).

const COLOR_LOW := Color("c8412d")
const COLOR_MID := Color("e6b422")
const COLOR_HIGH := Color("5fae3e")
const COLOR_ENERGY := Color("f4a672")
const COLOR_LOSS := Color("b9616a")
const COLOR_GAIN := Color("2f6b52")

@onready var stats: PanelContainer = $Stats
@onready var reputation_bar: ProgressBar = %ReputationBar
@onready var reputation_value: Label = %ReputationValue
@onready var energy_bar: ProgressBar = %EnergyBar
@onready var energy_value: Label = %EnergyValue
@onready var objective_panel: PanelContainer = %ObjectivePanel
@onready var objective_label: Label = %ObjectiveLabel
@onready var toast_panel: PanelContainer = %ToastPanel
@onready var toast_label: Label = %ToastLabel
@onready var memory_panel: PanelContainer = %MemoryPanel
@onready var memory_label: Label = %MemoryLabel

var _reputation_fill := StyleBoxFlat.new()
var _energy_fill := StyleBoxFlat.new()
var _tweens := {}
var _shown_reputation := 0
var _shown_energy := 0
var _stats_origin := Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for fill in [_reputation_fill, _energy_fill]:
		fill.set_corner_radius_all(8)
	_energy_fill.bg_color = COLOR_ENERGY
	reputation_bar.add_theme_stylebox_override("fill", _reputation_fill)
	energy_bar.add_theme_stylebox_override("fill", _energy_fill)
	GameState.reputation_changed.connect(_show_reputation.bind(true))
	GameState.energy_changed.connect(_show_energy.bind(true))
	_show_reputation(GameState.reputation, false)
	_show_energy(GameState.energy, false)
	objective_panel.visible = false
	toast_panel.modulate.a = 0.0
	memory_panel.modulate.a = 0.0
	_stats_origin = stats.position
	for panel: Control in [objective_panel, memory_panel]:
		panel.resized.connect(func() -> void: panel.pivot_offset = panel.size / 2)

static func reputation_color(value: int) -> Color:
	if value <= 20:
		return COLOR_LOW
	if value <= 80:
		return COLOR_MID
	return COLOR_HIGH

func set_objective(text: String) -> void:
	var changed := objective_label.text != "Objetivo: " + text
	objective_panel.visible = text != ""
	objective_label.text = "Objetivo: " + text
	if text != "" and changed:
		Audio.sfx("objective")
		objective_panel.scale = Vector2.ONE * 1.08
		_restart_tween(objective_panel).tween_property(objective_panel, "scale", Vector2.ONE, 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Título do capítulo sobre a cena, como abertura de episódio (Life is Strange); some sozinho.
func chapter_title(title: String, subtitle: String) -> void:
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.set_anchors_preset(Control.PRESET_TOP_WIDE)
	box.offset_top = 170
	box.add_theme_constant_override("separation", 2)
	for line: Array in [[title, 46, 12], [subtitle, 24, 8]]:
		var label := Label.new()
		label.text = line[0]
		label.theme_type_variation = &"WorldLabel"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", line[1])
		label.add_theme_constant_override("outline_size", line[2])
		box.add_child(label)
	add_child(box)
	box.modulate.a = 0.0
	box.position.y += 12
	var tween := box.create_tween()
	tween.set_parallel()
	tween.tween_property(box, "modulate:a", 1.0, 0.7)
	tween.tween_property(box, "position:y", box.position.y - 12, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_interval(2.0)
	tween.chain().tween_property(box, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(box.queue_free)

func toast(text: String) -> void:
	toast_label.text = text
	var tween := _restart_tween(toast_panel)
	tween.tween_property(toast_panel, "modulate:a", 1.0, 0.25)
	tween.tween_interval(2.2)
	tween.tween_property(toast_panel, "modulate:a", 0.0, 0.5)

func memory(text: String) -> void:
	memory_label.text = text
	Audio.sfx("memory")
	memory_panel.scale = Vector2.ONE * 0.9
	var tween := _restart_tween(memory_panel)
	tween.set_parallel()
	tween.tween_property(memory_panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(memory_panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_interval(2.8)
	tween.chain().tween_property(memory_panel, "modulate:a", 0.0, 0.6)

func _show_reputation(value: int, animate: bool) -> void:
	var delta := value - _shown_reputation
	_shown_reputation = value
	reputation_value.text = "%d%%" % value
	_reputation_fill.bg_color = reputation_color(value)
	_set_bar(reputation_bar, value, animate)
	if animate and delta != 0:
		_float_text(reputation_bar, "%+d%%" % delta, delta)
		Audio.sfx("rep_down" if delta < 0 else "rep_up")
		if delta < 0:
			_shake_stats()

func _show_energy(value: int, animate: bool) -> void:
	var delta := value - _shown_energy
	_shown_energy = value
	energy_value.text = "%d" % value
	_set_bar(energy_bar, value, animate)
	if animate and delta != 0:
		_float_text(energy_bar, "%+d" % delta, delta)
		if delta > 0:
			Audio.sfx("energy_up")

func _set_bar(bar: ProgressBar, value: int, animate: bool) -> void:
	if not animate:
		bar.value = value
		return
	_restart_tween(bar).tween_property(bar, "value", float(value), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Número que sobe e some ao lado da barra (feedback imediato da mudança).
func _float_text(bar: Control, text: String, delta: int) -> void:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = &"WorldLabel"
	label.add_theme_color_override("font_color", COLOR_GAIN if delta > 0 else COLOR_LOSS)
	label.add_theme_color_override("font_outline_color", Color("fbf5ec"))
	label.add_theme_font_size_override("font_size", 20)
	add_child(label)
	label.position = bar.global_position + Vector2(bar.size.x + 82, -6)
	var tween := label.create_tween().set_parallel()
	tween.tween_property(label, "position:y", label.position.y - 26, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 1.1).set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)

func _shake_stats() -> void:
	var tween := _restart_tween(stats)
	for offset in [Vector2(6, 0), Vector2(-5, 0), Vector2(3, 0), Vector2(-2, 0), Vector2.ZERO]:
		tween.tween_property(stats, "position", _stats_origin + offset, 0.045)

func _restart_tween(target: Node) -> Tween:
	if _tweens.has(target):
		_tweens[target].kill()
	var tween := create_tween()
	_tweens[target] = tween
	return tween
