extends Area2D

## Zona do cenário: avisa quando o jogador entra e, se tiver prompt, quando ele aperta E.

signal entered_by_player
signal interacted

@export var prompt_text := ""
@export var enabled := true:
	set(value):
		enabled = value
		_update_prompt()

var player_inside := false

@onready var prompt: Label = get_node_or_null("Prompt")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_prompt()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player_inside = true
	_update_prompt()
	if enabled:
		entered_by_player.emit()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		_update_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if enabled and player_inside and prompt_text != "" and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		interacted.emit()

func _update_prompt() -> void:
	if prompt:
		prompt.text = prompt_text
		prompt.visible = enabled and player_inside and prompt_text != ""
