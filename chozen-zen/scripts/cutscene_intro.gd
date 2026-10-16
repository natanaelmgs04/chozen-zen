extends Node

## Cutscene de abertura do Capítulo 1: o que aconteceu na escola antes de ele chegar em casa.
## Três planos em pixel art com linguagem de cinema: carimbo de hora/lugar, gradação de cor por
## clima, câmera com zoom e inclinação (rig), câmera lenta, "impact frame", diálogos com
## retratos, celular em tela cheia e cortinas diagonais entre os planos.
## Toque em E avança as falas; segurar E pula tudo.

const FASE := "res://scenes/phase1_casa.tscn"
const PLANOS: Array[Script] = [
	preload("res://scripts/cutscene/cena_sala.gd"),
	preload("res://scripts/cutscene/cena_rua.gd"),
	preload("res://scripts/cutscene/cena_porta.gd"),
]
const TELA := Vector2(1280, 720)
const SEGURAR_PARA_PULAR := 1.2
const NOITE := Color("0d1513")
const VERDE := Color("1f4b3b")
const CREME := Color("fbf5ec")
const LUZ_DA_PORTA := Color("ffe2b0")

@onready var palco: Node2D = $Palco
@onready var falas: Control = %Falas
@onready var legenda_painel: PanelContainer = %Legenda
@onready var legenda_texto: Label = %LegendaTexto
@onready var pular_painel: Control = %Pular
@onready var pular_barra: ProgressBar = %PularBarra
@onready var veu: ColorRect = %Veu

var _segurando := 0.0
var _saindo := false
var _base := Vector2.ZERO
var _baloes := Baloes.new()
## Rig de câmera: gira e aproxima em torno do centro da tela (o palco é filho dele).
var _rig := Node2D.new()
var fx := CinemaFX.new(4)
var dialogo := Dialogo.new(12)
var celular := Celular.new(13)
var letreiros := Letreiros.new(60)

func _ready() -> void:
	_base = ((get_viewport().get_visible_rect().size - TELA) / 2).round()
	add_child(_rig)
	move_child(_rig, 0)
	palco.reparent(_rig, false)
	_rig.position = _base + TELA / 2
	palco.position = -TELA / 2
	for camada in [fx, dialogo, celular, letreiros]:
		add_child(camada)
	veu.color = NOITE
	_baloes.converter = func(ponto: Vector2) -> Vector2: return palco.get_global_transform_with_canvas() * ponto
	falas.add_child(_baloes)
	legenda_painel.modulate.a = 0.0
	pular_painel.modulate.a = 0.0
	create_tween().tween_property(pular_painel, "modulate:a", 0.6, 0.6).set_delay(1.0)
	_tocar()

func _tocar() -> void:
	for i in PLANOS.size():
		var cena: Node2D = PLANOS[i].new()
		palco.add_child(cena)
		if i == 0:
			await _clarear(1.4)
		else:
			await letreiros.revelar()
		await cena.tocar(self)
		_limpar_falas()
		dialogo.fechar()
		if i == PLANOS.size() - 1:
			await _escurecer(LUZ_DA_PORTA, 0.9)
		else:
			await letreiros.cobrir()
		cena.queue_free()
		_rig.scale = Vector2.ONE
		_rig.rotation = 0.0
		palco.position = -TELA / 2
		Engine.time_scale = 1.0
	_terminar(LUZ_DA_PORTA)

func _process(delta: float) -> void:
	var segurando := Input.is_action_pressed("interact") or Input.is_action_pressed("ui_accept")
	_segurando = clampf(_segurando + (delta if segurando else -delta * 2.0), 0.0, SEGURAR_PARA_PULAR)
	pular_barra.value = _segurando / SEGURAR_PARA_PULAR * 100.0
	if segurando:
		pular_painel.modulate.a = 1.0
	if _segurando >= SEGURAR_PARA_PULAR:
		_terminar(VERDE)

func _terminar(cor: Color) -> void:
	if _saindo:
		return
	_saindo = true
	Engine.time_scale = 1.0
	Transition.change_scene(FASE, cor)

func _exit_tree() -> void:
	Engine.time_scale = 1.0

# --- Ferramentas usadas pelos planos -------------------------------------------------

## Espera presa a esta cena: se o jogador pular, a cena some e a linha do tempo para junto.
func espera(segundos: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(segundos)
	await timer.timeout
	timer.queue_free()

func legenda(texto: String) -> void:
	legenda_texto.text = texto
	var tween := create_tween()
	tween.tween_property(legenda_painel, "modulate:a", 1.0, 0.5).set_delay(0.3)
	tween.tween_interval(2.6)
	tween.tween_property(legenda_painel, "modulate:a", 0.0, 0.6)

## Carimbo de hora e lugar (linguagem de cinema).
func carimbo(hora: String, lugar: String) -> void:
	letreiros.carimbo(hora, lugar)

## Fala com retrato; espera o jogador avançar.
func dizer(quem: String, expressao: String, texto: String, lado := "esquerda", pensamento := false) -> void:
	await dialogo.dizer(quem, expressao, texto, lado, pensamento)

## "Impact frame" centrado num ponto do palco.
func impacto(ponto: Vector2) -> void:
	var tela := palco.get_global_transform_with_canvas() * ponto
	fx.impacto(tela / get_viewport().get_visible_rect().size)
	tremer(10.0)

## Inclina a câmera (dutch angle): o mundo "sai do eixo" junto com o personagem.
func inclinar(graus: float, segundos := 0.5) -> void:
	create_tween().tween_property(_rig, "rotation_degrees", graus, segundos).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Câmera lenta (afeta personagens e esperas; os efeitos de tela continuam em tempo real).
func camera_lenta(fator: float) -> void:
	Engine.time_scale = fator

func enquadrar_ja(ponto: Vector2, zoom: float) -> void:
	_rig.scale = Vector2.ONE * zoom
	palco.position = -ponto

## Balão de fala sobre um ponto do palco (texto em máquina de escrever, como no resto do jogo).
func falar(ponto: Vector2, texto: String, duracao := 1.8) -> void:
	_baloes.falar(ponto, texto, duracao)

## Notificação de celular (título em negrito + mensagem).
func notificar(ponto: Vector2, titulo: String, texto: String, duracao := 2.4) -> void:
	_baloes.notificar(ponto, titulo, texto, duracao)

## Aproxima a câmera num ponto do palco (como um corte de cinema para o close).
func enquadrar(ponto: Vector2, zoom: float, segundos: float) -> void:
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_rig, "scale", Vector2.ONE * zoom, segundos)
	tween.tween_property(palco, "position", -ponto, segundos)

func tremer(forca := 6.0) -> void:
	var origem := _base + TELA / 2
	var tween := create_tween().set_ignore_time_scale(true)
	for i in 7:
		tween.tween_property(_rig, "position", origem + Vector2(randf_range(-forca, forca), randf_range(-forca, forca)), 0.035)
	tween.tween_property(_rig, "position", origem, 0.06)

# --- Internos -------------------------------------------------------------------------

func _limpar_falas() -> void:
	_baloes.limpar()

func _clarear(segundos: float) -> void:
	var tween := create_tween()
	tween.tween_property(veu, "modulate:a", 0.0, segundos)
	await tween.finished

func _escurecer(cor: Color, segundos: float) -> void:
	veu.color = cor
	var tween := create_tween()
	tween.tween_property(veu, "modulate:a", 1.0, segundos)
	await tween.finished
