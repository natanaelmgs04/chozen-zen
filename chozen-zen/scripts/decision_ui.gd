extends CanvasLayer

## Painel de decisão (RF-AGE-001/002): mostra contexto + 2-4 opções,
## aplica o efeito de Reputação da opção escolhida e mostra o feedback.

signal closed

const OPTION_LETTERS := ["A", "B", "C", "D"]

@onready var title_label: Label = %TitleLabel
@onready var context_label: Label = %ContextLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var feedback_label: Label = %FeedbackLabel
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	feedback_label.visible = false
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue_pressed)

func show_event(event_data: Dictionary) -> void:
	title_label.text = event_data.get("titulo", "")
	context_label.text = event_data.get("contexto", "")
	feedback_label.visible = false
	continue_button.visible = false
	for child in options_container.get_children():
		child.queue_free()
	var opcoes: Array = event_data.get("opcoes", [])
	for i in opcoes.size():
		var button := Button.new()
		button.text = "%s) %s" % [OPTION_LETTERS[i], opcoes[i]["texto"]]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(_on_option_pressed.bind(opcoes[i]))
		options_container.add_child(button)
	visible = true
	get_tree().paused = true
	options_container.get_child(0).grab_focus.call_deferred()

func _on_option_pressed(opcao: Dictionary) -> void:
	for child in options_container.get_children():
		child.queue_free()
	var delta: int = opcao.get("reputacao", 0)
	GameState.apply_reputation_delta(delta)
	feedback_label.text = "%s\n\nReputação: %+d%%  (atual: %d%%)" % [
		opcao.get("feedback", ""), delta, GameState.reputation
	]
	feedback_label.visible = true
	continue_button.visible = true
	continue_button.grab_focus()

func _on_continue_pressed() -> void:
	visible = false
	get_tree().paused = false
	closed.emit()
