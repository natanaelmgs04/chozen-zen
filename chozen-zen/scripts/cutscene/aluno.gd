class_name Aluno
extends Node2D

## Aluno sentado na carteira, visto de costas (usa os sprites do jogador recortados na cintura;
## o encosto da cadeira, desenhado na frente, esconde as pernas).
## Os colegas são silhuetas: a turma é uma multidão sem rosto que julga. Em cor ficam só
## os personagens da cena (o protagonista e a professora).

const SILHUETA := preload("res://assets/shaders/silhueta.gdshader")
const COR := Color("2e4a43")
const RECORTE := Rect2(0, 0, 80, 94)
const TEXTURAS := {
	"up": preload("res://assets/sprites/jogador/idle_up_0.png"),
	"down": preload("res://assets/sprites/jogador/idle_down_0.png"),
	"left": preload("res://assets/sprites/jogador/idle_left_0.png"),
	"right": preload("res://assets/sprites/jogador/idle_right_0.png"),
}

var colorido := false
## Muda o contorno para os colegas não parecerem clones: "coque", "rabo", "laco", "espetado", "longo".
var acessorio := ""
var tom := 0.0
var direcao := "up"

var _sprite := Sprite2D.new()
var _extra := Node2D.new()

## Topo da cabeça, em coordenadas do pai (para balões e emotes).
var cabeca: Vector2:
	get:
		return position + Vector2(40, 10)

func _init(p_colorido := false, p_acessorio := "", p_tom := 0.0) -> void:
	colorido = p_colorido
	acessorio = p_acessorio
	tom = p_tom

func _ready() -> void:
	_sprite.centered = false
	_sprite.region_enabled = true
	_sprite.region_rect = RECORTE
	if not colorido:
		var material := ShaderMaterial.new()
		material.shader = SILHUETA
		material.set_shader_parameter("cor", _cor())
		_sprite.material = material
	add_child(_sprite)
	_extra.draw.connect(_desenhar_acessorio)
	add_child(_extra)
	virar("up")

func virar(nova: String) -> void:
	direcao = nova
	_sprite.texture = TEXTURAS[nova]
	_extra.queue_redraw()

## Pequeno susto/negação: balança de um lado para o outro.
func balancar(intensidade := 4.0) -> void:
	var origem := position
	var tween := create_tween()
	for dx in [intensidade, -intensidade, intensidade * 0.6, -intensidade * 0.6, 0.0]:
		tween.tween_property(self, "position:x", origem.x + dx, 0.05)

func _cor() -> Color:
	return COR.lightened(tom)

func _desenhar_acessorio() -> void:
	if colorido:
		return
	var c := _cor().darkened(0.03)
	var r := func(x: float, y: float, w: float, h: float) -> void: _extra.draw_rect(Rect2(x, y, w, h), c)
	match acessorio:
		"coque":
			r.call(28, 0, 24, 12)
			r.call(32, -4, 16, 4)
		"rabo":
			if direcao != "right":
				r.call(68, 24, 12, 8)
				r.call(72, 32, 8, 16)
		"laco":
			r.call(4, 2, 12, 10)
			r.call(16, 6, 4, 4)
			r.call(20, 2, 12, 10)
		"espetado":
			for x in [16, 30, 44, 56]:
				r.call(x, 2 if x in [30, 44] else 6, 8, 8)
		"longo":
			if direcao in ["up", "down"]:
				r.call(4, 36, 10, 32)
				r.call(66, 36, 10, 32)
