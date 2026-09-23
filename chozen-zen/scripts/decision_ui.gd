extends CanvasLayer

## Painel de decisão (RF-AGE-001/002): mostra contexto + 2-4 opções,
## aplica o efeito de Reputação da opção escolhida e mostra o feedback.

signal closed

@onready var context_label: Label = $Backdrop/Panel/Margin/VBox/ContextLabel
@onready var options_container: VBoxContainer = $Backdrop/Panel/Margin/VBox/OptionsContainer
@onready var feedback_label: Label = $Backdrop/Panel/Margin/VBox/FeedbackLabel
@onready var continue_button: Button = $Backdrop/Panel/Margin/VBox/ContinueButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	feedback_label.visible = false
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue_pressed)

func show_event(event_data: Dictionary) -> void:
	context_label.text = event_data.get("contexto", "")
	feedback_label.visible = false
	continue_button.visible = false
	for child in options_container.get_children():
		child.queue_free()
	for opcao in event_data.get("opcoes", []):
		var button := Button.new()
		button.text = opcao["texto"]
		button.pressed.connect(_on_option_pressed.bind(opcao))
		options_container.add_child(button)
	visible = true
	get_tree().paused = true

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

func _on_continue_pressed() -> void:
	visible = false
	get_tree().paused = false
	closed.emit()
