extends StaticBody2D

## NPC estático desta cena: dispara o evento de decisão quando o jogador
## se aproxima e confirma a interação (Fase 1 — Família, RF-AGE-001).

signal talk_requested

@onready var prompt: Label = $Prompt
@onready var interaction_area: Area2D = $InteractionArea

var _player_in_range := false
var _talked := false

func _ready() -> void:
	prompt.visible = false
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _talked:
		_player_in_range = true
		prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and not _talked and event.is_action_pressed("interact"):
		_talked = true
		prompt.visible = false
		talk_requested.emit()
