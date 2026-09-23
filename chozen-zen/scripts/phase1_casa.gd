extends Node2D

## Fase 1 — Família: Conversando com a mãe.
## Conteúdo do evento definido pelo Game Designer (docs/specs/001-sistema-de-decisoes.md,
## "Perguntas em aberto" sobre o primeiro evento do protótipo).

const EVENTO_MAE := {
	"contexto": "Você chega em casa depois de um dia cansativo. Sua mãe percebe que você está diferente e pergunta se aconteceu alguma coisa. Você não está muito a fim de conversar. O que você faz?",
	"opcoes": [
		{
			"texto": "Contar o que aconteceu e conversar com ela.",
			"reputacao": 0,
			"feedback": "Você decidiu conversar com alguém próximo e demonstrou confiança e respeito.",
		},
		{
			"texto": "Dizer que está tudo bem, mas agradecer pela preocupação.",
			"reputacao": -2,
			"feedback": "Você não quis conversar naquele momento, mas respondeu de maneira respeitosa.",
		},
		{
			"texto": "Ignorar a pergunta e ir para o quarto.",
			"reputacao": -5,
			"feedback": "Você pode não querer conversar, mas ignorou alguém que demonstrou preocupação com você.",
		},
		{
			"texto": "Responder de forma grosseira.",
			"reputacao": -8,
			"feedback": "Você poderia não querer conversar, mas escolheu tratar mal alguém que estava tentando ajudar.",
		},
	],
}

@onready var mae: StaticBody2D = $Mae
@onready var player: CharacterBody2D = $Player
@onready var decision_ui: CanvasLayer = $DecisionUI

func _ready() -> void:
	mae.talk_requested.connect(_on_mae_talk_requested)
	decision_ui.closed.connect(_on_decision_closed)

func _on_mae_talk_requested() -> void:
	player.lock_input(true)
	decision_ui.show_event(EVENTO_MAE)

func _on_decision_closed() -> void:
	player.lock_input(false)
