extends OverlayPanel

## Créditos e licenças de terceiros (a licença MIT do Godot exige o aviso no jogo distribuído).

## Preencha com os nomes do grupo; vazio mostra só o nome do estúdio.
const EQUIPE: Array[String] = []

@onready var _body: RichTextLabel = %CreditsBody

func _ready() -> void:
	super()
	var equipe := "Equipe Estúdio Vívido" if EQUIPE.is_empty() else "\n".join(EQUIPE)
	_body.text = """[center][b]ChosenZen[/b]
Um jogo do [b]Estúdio Vívido[/b] — "Ideias que ganham vida."

[b]Equipe[/b]
%s

[b]Música e efeitos sonoros[/b]
Originais, compostos e sintetizados para o jogo.

[b]Fonte[/b]
Quicksand — The Quicksand Project Authors
SIL Open Font License 1.1

[b]Agradecimentos[/b]
Prof. Caio Oliveira — FIAP Games
Todos que jogaram os protótipos e deram feedback.

[b]Feito com Godot Engine[/b][/center]

[font_size=13]%s[/font_size]""" % [equipe, Engine.get_license_text()]
