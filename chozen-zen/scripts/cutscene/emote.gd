class_name Emote
extends Node2D

## Balão de emoção em pixel art sobre a cabeça ("!", "?", "?!", "...", celular, coração,
## raiva, zzz, nota, choro, livro, triste) ou gota de suor, como em Stardew Valley.
## Conta a reação sem precisar de texto.

const FUNDO := Color("fbf5ec")
const BORDA := Color("1f4b3b")
const DESTAQUE := Color("b9616a")
const AGUA := Color("8ec5e8")
const TELA := Color("f4b183")
const RAIVA := Color("c8412d")
const VERDE := Color("2f6b52")
const NUVEM := Color("8a8f99")

var tipo := ""
var _pontos := 3
var _tempo := 0.0
var _tween: Tween

func _ready() -> void:
	visible = false

func mostrar(novo_tipo: String, duracao := 1.6) -> void:
	tipo = novo_tipo
	_pontos = 1
	queue_redraw()
	visible = true
	scale = Vector2.ZERO
	Audio.sfx("pop", 0.0, 0.08)
	# Um emote novo substitui o anterior (sem isso, o "sumir" do antigo esconde o novo).
	if _tween:
		_tween.kill()
	_tween = create_tween()
	var tween := _tween
	tween.tween_property(self, "scale", Vector2.ONE * 1.2, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)
	if duracao > 0.0:
		tween.tween_interval(duracao)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.12)
		tween.tween_callback(hide)

func _process(delta: float) -> void:
	if not visible or tipo != "...":
		return
	_tempo += delta
	if _tempo >= 0.28:
		_tempo = 0.0
		_pontos = _pontos % 3 + 1
		queue_redraw()

func _draw() -> void:
	if tipo == "suor":
		Pixel.rect(self, 0, -4, 1, 1, AGUA)
		Pixel.rect(self, -1, -3, 3, 3, AGUA)
		Pixel.rect(self, -1, -3, 1, 1, FUNDO)
		return
	# balão com rabinho (origem na ponta do rabinho)
	Pixel.rect_arredondado(self, -6, -13, 13, 11, BORDA)
	Pixel.rect_arredondado(self, -5, -12, 11, 9, FUNDO)
	Pixel.rect(self, -1, -2, 3, 1, BORDA)
	Pixel.rect(self, 0, -1, 1, 1, BORDA)
	Pixel.rect(self, 0, -3, 1, 1, FUNDO)
	Pixel.rect(self, 0, -2, 1, 1, FUNDO)
	match tipo:
		"!":
			_exclamacao(0)
		"?":
			_interrogacao(-1)
		"?!":
			_interrogacao(-3)
			_exclamacao(2)
		"...":
			for i in _pontos:
				Pixel.rect(self, -3 + i * 3, -7, 1, 1, BORDA)
		"celular":
			Pixel.rect(self, -2, -11, 5, 8, BORDA)
			Pixel.rect(self, -1, -10, 3, 5, TELA)
			Pixel.rect(self, 2, -12, 2, 2, DESTAQUE)
		"coracao":
			Pixel.rect(self, -3, -10, 3, 1, DESTAQUE)
			Pixel.rect(self, 1, -10, 3, 1, DESTAQUE)
			Pixel.rect(self, -3, -9, 7, 2, DESTAQUE)
			Pixel.rect(self, -2, -7, 5, 1, DESTAQUE)
			Pixel.rect(self, -1, -6, 3, 1, DESTAQUE)
			Pixel.rect(self, 0, -5, 1, 1, DESTAQUE)
			Pixel.rect(self, -2, -9, 1, 1, FUNDO)
		"raiva":
			for canto in [Vector2(-3, -10), Vector2(2, -10), Vector2(-3, -5), Vector2(2, -5)]:
				var dentro := 1 if canto.x < 0 else 0
				var vertical := 1 if canto.y < -7 else -1
				Pixel.rect(self, canto.x, canto.y, 2, 1, RAIVA)
				Pixel.rect(self, canto.x + dentro, canto.y + vertical, 1, 1, RAIVA)
		"zzz":
			Pixel.rect(self, -4, -7, 3, 1, BORDA)
			Pixel.rect(self, -3, -6, 1, 1, BORDA)
			Pixel.rect(self, -4, -5, 3, 1, BORDA)
			Pixel.rect(self, 0, -11, 4, 1, BORDA)
			Pixel.rect(self, 2, -10, 1, 1, BORDA)
			Pixel.rect(self, 1, -9, 1, 1, BORDA)
			Pixel.rect(self, 0, -8, 4, 1, BORDA)
		"nota":
			Pixel.rect(self, 1, -11, 1, 5, VERDE)
			Pixel.rect(self, 2, -11, 2, 1, VERDE)
			Pixel.rect(self, 3, -10, 1, 1, VERDE)
			Pixel.rect(self, -1, -7, 2, 2, VERDE)
		"choro":
			Pixel.rect(self, -3, -10, 2, 1, BORDA)
			Pixel.rect(self, 2, -10, 2, 1, BORDA)
			Pixel.rect(self, -3, -9, 1, 3, AGUA)
			Pixel.rect(self, 3, -9, 1, 3, AGUA)
			Pixel.rect(self, -1, -7, 3, 2, DESTAQUE)
		"livro":
			Pixel.rect(self, -4, -9, 9, 5, VERDE)
			Pixel.rect(self, -3, -10, 3, 5, FUNDO.darkened(0.08))
			Pixel.rect(self, 1, -10, 3, 5, FUNDO.darkened(0.08))
			Pixel.rect(self, 0, -10, 1, 6, BORDA)
			Pixel.rect(self, -2, -9, 2, 1, NUVEM)
			Pixel.rect(self, 2, -9, 1, 1, NUVEM)
		"triste":
			Pixel.rect(self, -2, -11, 4, 1, NUVEM)
			Pixel.rect(self, -4, -10, 8, 2, NUVEM)
			Pixel.rect(self, -3, -7, 1, 1, AGUA)
			Pixel.rect(self, 0, -6, 1, 1, AGUA)
			Pixel.rect(self, 2, -7, 1, 1, AGUA)

func _exclamacao(x: int) -> void:
	Pixel.rect(self, x, -11, 1, 5, DESTAQUE)
	Pixel.rect(self, x, -5, 1, 1, DESTAQUE)

func _interrogacao(x: int) -> void:
	Pixel.rect(self, x, -11, 3, 1, DESTAQUE)
	Pixel.rect(self, x + 2, -10, 1, 2, DESTAQUE)
	Pixel.rect(self, x + 1, -8, 1, 2, DESTAQUE)
	Pixel.rect(self, x + 1, -5, 1, 1, DESTAQUE)
