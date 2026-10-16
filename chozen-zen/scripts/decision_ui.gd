extends CanvasLayer

## Painel de decisão (RF-AGE-001/002, RF-ENE-002): o custo de Energia aparece antes da
## escolha e bloqueia a opção se faltar Energia; o efeito na Reputação só aparece depois.
## Game feel: entrada animada, texto em máquina de escrever (pulável) e opções em sequência.
## Se `before_result` estiver definido, o painel some depois da escolha, a fase encena o que o
## jogador escolheu e só então o resultado (Reputação, Energia, retorno) aparece.

signal chosen(option: Dictionary)
signal closed(option: Dictionary)

const OPTION_LETTERS := ["A", "B", "C", "D"]
const BLIP_EVERY_CHARS := 3

@onready var backdrop: ColorRect = $Backdrop
@onready var panel: Control = $Backdrop/Panel
@onready var title_label: Label = %TitleLabel
@onready var context_label: Label = %ContextLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var feedback_box: VBoxContainer = %FeedbackBox
@onready var feedback_label: Label = %FeedbackLabel
@onready var effects_label: Label = %EffectsLabel
@onready var continue_button: Button = %ContinueButton

var _chosen := {}
var _typing := false
var _type_tween: Tween
var _last_blip := 0
var _closing := false
## Cena tocada entre a escolha e o resultado; recebe a opção escolhida.
var before_result: Callable

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	panel.resized.connect(func() -> void: panel.pivot_offset = panel.size / 2)

func show_event(event_data: Dictionary) -> void:
	title_label.text = event_data.get("titulo", "")
	context_label.text = event_data.get("contexto", "")
	feedback_box.visible = false
	for child in options_container.get_children():
		child.queue_free()
	var opcoes: Array = event_data.get("opcoes", [])
	for i in opcoes.size():
		var opcao: Dictionary = opcoes[i]
		var button := Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = not GameState.can_afford(opcao)
		button.text = "%s)  %s%s" % [OPTION_LETTERS[i], opcao["texto"], _energy_tag(opcao, button.disabled)]
		button.pressed.connect(_on_option_pressed.bind(opcao))
		button.modulate.a = 0.0
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.focus_mode = Control.FOCUS_NONE
		options_container.add_child(button)
	options_container.visible = true
	_closing = false
	visible = true
	get_tree().paused = true
	Audio.sfx("open")
	_pop_in()
	_start_typing()

func hide_panel() -> void:
	_typing = false
	visible = false

func _pop_in() -> void:
	backdrop.modulate.a = 0.0
	panel.scale = Vector2.ONE * 0.94
	panel.modulate.a = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property(backdrop, "modulate:a", 1.0, 0.25)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)

func _start_typing() -> void:
	var cps := Settings.chars_per_second()
	if cps <= 0.0:
		context_label.visible_ratio = 1.0
		_reveal_options()
		return
	_typing = true
	_last_blip = 0
	context_label.visible_ratio = 0.0
	if _type_tween:
		_type_tween.kill()
	_type_tween = create_tween()
	_type_tween.tween_interval(0.2)
	_type_tween.tween_property(context_label, "visible_ratio", 1.0, context_label.text.length() / cps)
	_type_tween.tween_callback(_finish_typing)

func _process(_delta: float) -> void:
	if not _typing:
		return
	var shown := context_label.visible_characters
	if shown - _last_blip >= BLIP_EVERY_CHARS:
		_last_blip = shown
		Audio.sfx("blip", -2.0, 0.12)

func _input(event: InputEvent) -> void:
	if not (visible and _typing):
		return
	var skip := event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")
	skip = skip or (event is InputEventMouseButton and event.pressed)
	if skip:
		get_viewport().set_input_as_handled()
		_finish_typing()

func _finish_typing() -> void:
	if not _typing:
		return
	_typing = false
	if _type_tween:
		_type_tween.kill()
	context_label.visible_ratio = 1.0
	_reveal_options()

func _reveal_options() -> void:
	var tween := create_tween().set_parallel()
	var first_enabled: Button
	var i := 0
	for button: Button in options_container.get_children():
		if button.is_queued_for_deletion():
			continue
		tween.tween_property(button, "modulate:a", 1.0, 0.18).set_delay(i * 0.07)
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.focus_mode = Control.FOCUS_ALL
		if not button.disabled and first_enabled == null:
			first_enabled = button
		i += 1
	if first_enabled:
		first_enabled.grab_focus.call_deferred()

func _energy_tag(opcao: Dictionary, blocked: bool) -> String:
	var energia: int = opcao.get("energia", 0)
	if energia == 0:
		return ""
	var tag := "   [Energia %+d]" % energia
	return tag.replace("]", " · sem energia]") if blocked else tag

func _on_option_pressed(opcao: Dictionary) -> void:
	if not options_container.visible:
		return
	_chosen = opcao
	options_container.visible = false
	Audio.sfx("choice")
	if before_result.is_valid():
		await _fade_out()
		get_tree().paused = false
		await before_result.call(opcao)
		get_tree().paused = true
		visible = true
		_pop_in()
	GameState.apply_option(opcao)
	if not visible:
		return
	chosen.emit(opcao)
	feedback_label.text = opcao.get("feedback", "")
	effects_label.text = "%s   ·   %s" % [_effect("Reputação", opcao.get("reputacao", 0), "%"), _effect("Energia", opcao.get("energia", 0), "")]
	feedback_box.visible = true
	feedback_box.modulate.a = 0.0
	create_tween().tween_property(feedback_box, "modulate:a", 1.0, 0.3)
	continue_button.grab_focus()

func _effect(label: String, value: int, unit: String) -> String:
	return "%s sem mudança" % label if value == 0 else "%s %+d%s" % [label, value, unit]

func _on_continue_pressed() -> void:
	if _closing:
		return
	_closing = true
	await _fade_out()
	get_tree().paused = false
	closed.emit(_chosen)

func _fade_out() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	tween.tween_property(backdrop, "modulate:a", 0.0, 0.2)
	await tween.finished
	visible = false
