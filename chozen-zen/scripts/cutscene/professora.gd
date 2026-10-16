class_name Professora
extends Node2D

## Professora da cutscene (origem = pés). Sprites em pixel art feitos por
## `tools/make_professora.py`, na mesma grade de 4 px do jogador e da mãe.

const POSES := {
	"frente": preload("res://assets/sprites/professora/frente.png"),
	"frente_passo_1": preload("res://assets/sprites/professora/frente_passo_1.png"),
	"frente_passo_2": preload("res://assets/sprites/professora/frente_passo_2.png"),
	"frente_papel": preload("res://assets/sprites/professora/frente_papel.png"),
	"costas": preload("res://assets/sprites/professora/costas.png"),
	"costas_escrevendo": preload("res://assets/sprites/professora/costas_escrevendo.png"),
	"direita_aponta": preload("res://assets/sprites/professora/direita_aponta.png"),
}
## Os pés ficam a 144 px do topo da imagem (148 px com a margem do contorno).
const PES := Vector2(52, 144)
const INTERVALO_PASSO := 0.2

var de_frente := false:
	set(valor):
		de_frente = valor
		_atualizar()
## 0 = parada; 1 e 2 alternam a perna levantada.
var passo := 0:
	set(valor):
		passo = valor
		_atualizar()
var curvada := 0.0:
	set(valor):
		curvada = valor
		_atualizar()
## "", "aponta", "ergue" (segurando o papel no alto ou escrevendo no quadro) ou "abaixa".
var braco := "":
	set(valor):
		braco = valor
		_atualizar()
var com_papel := false:
	set(valor):
		com_papel = valor
		_atualizar()

var _corpo := Node2D.new()
var _sprite := Sprite2D.new()
var _andando := false
var _tempo_passo := 0.0

var cabeca: Vector2:
	get:
		return position + Vector2(0, -140)

func _init() -> void:
	_sprite.centered = false
	_sprite.position = -PES
	_corpo.add_child(_sprite)
	add_child(_corpo)
	_atualizar()

func andar_ate(alvo: Vector2, segundos: float) -> void:
	_andando = true
	var tween := create_tween()
	tween.tween_property(self, "position", alvo, segundos).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	_andando = false
	passo = 0

func _process(delta: float) -> void:
	if not _andando:
		return
	_tempo_passo += delta
	if _tempo_passo >= INTERVALO_PASSO:
		_tempo_passo = 0.0
		passo = 2 if passo == 1 else 1
		Audio.step()

func _atualizar() -> void:
	var pose := "frente"
	if not de_frente:
		pose = "costas_escrevendo" if braco == "ergue" else "costas"
	elif braco == "aponta":
		pose = "direita_aponta"
	elif braco == "ergue" and com_papel:
		pose = "frente_papel"
	elif passo != 0:
		pose = "frente_passo_%d" % passo
	_sprite.texture = POSES[pose]
	# Abaixar para pegar o papel: um squash pelos pés (princípio de antecipação).
	_corpo.scale = Vector2(1.0 + curvada * 0.06, 1.0 - curvada * 0.12)
