class_name DiretorCasa
extends Node

## Linguagem de cinema das cenas dentro da casa (antes e depois de cada enquete):
## faixas de cinema, diálogos com retratos, celular em tela cheia, gradação de cor por clima,
## "impact frame", câmera que inclina, emotes e o cartão de título do capítulo.
## As falas avançam no ritmo do jogador (E / Espaço / clique).

const ALTURA_FAIXA := 56.0
const CABECA_JOGADOR := Vector2(0, -128)
const CABECA_MAE := Vector2(0, -136)

var fase: Node2D
var player: CharacterBody2D
var mae: CharacterBody2D
var camera: Camera2D

var fx := CinemaFX.new(8)
var dialogo := Dialogo.new(12)
var celular := Celular.new(13)
var letreiros := Letreiros.new(60)

var _camada := CanvasLayer.new()
var _faixa_topo := ColorRect.new()
var _faixa_base := ColorRect.new()
var _baloes := Baloes.new()
var _emotes := {}

func _init(p_fase: Node2D, p_player: CharacterBody2D, p_mae: CharacterBody2D) -> void:
	fase = p_fase
	player = p_player
	mae = p_mae
	camera = player.get_node("Camera2D")

func _ready() -> void:
	# Faixas abaixo do painel de decisão (10) e do HUD (11); efeitos (8) só no mundo.
	_camada.layer = 9
	add_child(_camada)
	for camada in [fx, dialogo, celular, letreiros]:
		add_child(camada)
	for faixa in [_faixa_topo, _faixa_base]:
		faixa.color = Color("1f4b3b")
		faixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_camada.add_child(faixa)
	_faixa_topo.anchor_right = 1.0
	_faixa_base.anchor_right = 1.0
	_faixa_base.anchor_top = 1.0
	_faixa_base.anchor_bottom = 1.0
	for faixa in [_faixa_topo, _faixa_base]:
		faixa.offset_left = 0.0
		faixa.offset_right = 0.0
		faixa.offset_top = 0.0
		faixa.offset_bottom = 0.0
	_baloes.converter = func(ponto: Vector2) -> Vector2: return fase.get_viewport().get_canvas_transform() * ponto
	_camada.add_child(_baloes)
	camera.ignore_rotation = false

## Liga o modo cinema: faixas entram, jogador e mãe passam a obedecer a cena.
func comecar() -> void:
	player.lock_input(true)
	mae.scripted = true
	mae.can_talk = false
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_faixa_topo, "offset_bottom", ALTURA_FAIXA, 0.35)
	tween.tween_property(_faixa_base, "offset_top", -ALTURA_FAIXA, 0.35)
	await tween.finished

func terminar() -> void:
	_baloes.limpar()
	dialogo.fechar()
	celular.fechar()
	fx.clima("neutro", 0.8)
	inclinar(0.0, 0.4)
	mae.scripted = false
	player.pode_levantar = true
	if player.sentado:
		player.levantar()
	else:
		player.lock_input(false)
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_faixa_topo, "offset_bottom", 0.0, 0.3)
	tween.tween_property(_faixa_base, "offset_top", 0.0, 0.3)

## Toca uma cena e deixa a tela limpa (sem diálogo nem celular) para a enquete ou o resultado.
func tocar(cena: Callable) -> void:
	await cena.call()
	await dialogo.fechar()
	await celular.fechar()

# --- Linguagem das cenas ------------------------------------------------------------

func espera(segundos: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(segundos)
	await timer.timeout
	timer.queue_free()

## Fala com retrato (o jogador à esquerda, a mãe à direita, como num palco).
func dizer(quem: String, expressao: String, texto: String, pensamento := false) -> void:
	var lado := "esquerda" if quem == "voce" else "direita"
	await dialogo.dizer(quem, expressao, texto, lado, pensamento)

func fechar_dialogo() -> void:
	await dialogo.fechar()

func clima(nome: String, segundos := 0.8) -> void:
	fx.clima(nome, segundos)

## Impact frame centrado num personagem.
func impacto(alvo: Node2D) -> void:
	var tela: Vector2 = fase.get_viewport().get_canvas_transform() * (alvo.global_position + Vector2(0, -70))
	fx.impacto(tela / fase.get_viewport().get_visible_rect().size)
	tremer(8.0)

## Dutch angle: a câmera sai do eixo nos momentos de conflito.
func inclinar(graus: float, segundos := 0.5) -> void:
	create_tween().tween_property(camera, "rotation_degrees", graus, segundos).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func emote(alvo: Node2D, tipo: String, duracao := 1.4) -> void:
	if not _emotes.has(alvo):
		var novo := Emote.new()
		novo.z_index = 50
		alvo.add_child(novo)
		_emotes[alvo] = novo
	var e: Emote = _emotes[alvo]
	e.position = _cabeca(alvo)
	e.mostrar(tipo, duracao)

func falar(alvo: Node2D, texto: String, duracao := 1.8) -> void:
	_baloes.falar(_cabeca(alvo) + Vector2(0, -56), texto, duracao, alvo)

func notificar(alvo: Node2D, titulo: String, texto: String, duracao := 2.4) -> void:
	_baloes.notificar(_cabeca(alvo) + Vector2(0, -56), titulo, texto, duracao, alvo)

## Caminho em linha reta, ponto a ponto (desviando dos móveis à mão).
func andar(quem: Node2D, pontos: Array[Vector2], velocidade := 150.0) -> void:
	for ponto in pontos:
		await quem.walk_to(ponto, velocidade)

func tremer(forca := 5.0) -> void:
	var tween := create_tween().set_ignore_time_scale(true)
	for i in 6:
		tween.tween_property(fase, "tremor", Vector2(randf_range(-forca, forca), randf_range(-forca, forca)), 0.035)
	tween.tween_property(fase, "tremor", Vector2.ZERO, 0.05)

func _cabeca(alvo: Node2D) -> Vector2:
	return CABECA_MAE if alvo == mae else CABECA_JOGADOR
