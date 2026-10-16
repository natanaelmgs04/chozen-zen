class_name CinemaFX
extends CanvasLayer

## Camada de pós-processamento das cutscenes. Fica entre o mundo e a interface de diálogo:
## o que está abaixo dela recebe a gradação de cor, a vinheta, o desfoque etc.
## Climas (gradação) inspirados na linguagem de cor de filmes: frio na tensão, quente no afeto.

const SHADER := preload("res://assets/shaders/cinema_pos.gdshader")

const CLIMAS := {
	"neutro": {"saturacao": 1.0, "contraste": 1.0, "brilho": 0.0, "tinta": Vector3(1, 1, 1), "vinheta": 0.28},
	"tensao": {"saturacao": 0.45, "contraste": 1.2, "brilho": -0.03, "tinta": Vector3(0.92, 0.97, 1.08), "vinheta": 0.55},
	"quente": {"saturacao": 1.12, "contraste": 1.02, "brilho": 0.02, "tinta": Vector3(1.07, 1.0, 0.9), "vinheta": 0.3},
	"frio": {"saturacao": 0.6, "contraste": 1.05, "brilho": -0.02, "tinta": Vector3(0.88, 0.95, 1.1), "vinheta": 0.45},
	"memoria": {"saturacao": 0.7, "contraste": 0.95, "brilho": 0.03, "tinta": Vector3(1.08, 0.98, 0.86), "vinheta": 0.4},
	"noite": {"saturacao": 0.85, "contraste": 1.05, "brilho": -0.01, "tinta": Vector3(0.92, 0.96, 1.08), "vinheta": 0.42},
}

var _rect := ColorRect.new()
var _material := ShaderMaterial.new()
var _tween_clima: Tween

func _init(camada := 8) -> void:
	layer = camada

func _ready() -> void:
	_material.shader = SHADER
	_rect.material = _material
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.anchor_right = 1.0
	_rect.anchor_bottom = 1.0
	add_child(_rect)

## Troca o clima da cena em `segundos` (gradação de cor + vinheta).
func clima(nome: String, segundos := 1.0) -> void:
	var alvo: Dictionary = CLIMAS.get(nome, CLIMAS["neutro"])
	if _tween_clima:
		_tween_clima.kill()
	_tween_clima = _novo_tween().set_parallel()
	for chave in alvo:
		var valor = alvo[chave]
		if valor is Vector3:
			_tween_clima.tween_method(func(v: Vector3) -> void: _material.set_shader_parameter(chave, v),
				_ler(chave, Vector3.ONE), valor, segundos)
		else:
			_tween_param(_tween_clima, chave, valor, segundos)

## Profundidade de campo: desfoca o mundo atrás do diálogo.
func desfocar(raio: float, segundos := 0.4) -> void:
	_tween_param(_novo_tween(), "desfoque", raio, segundos)

func flash(cor := Color.WHITE, segundos := 0.35, forca := 1.0) -> void:
	_material.set_shader_parameter("cor_flash", Vector3(cor.r, cor.g, cor.b))
	_material.set_shader_parameter("flash", forca)
	_tween_param(_novo_tween(), "flash", 0.0, segundos)

## "Impact frame" (anime / Persona): congela por um instante, negativo, flash, linhas de
## velocidade e aberração cromática se dissipando. Para o momento de maior choque da cena.
func impacto(centro := Vector2(0.5, 0.5), congelar := 0.12) -> void:
	Audio.sfx("impact")
	_material.set_shader_parameter("centro_linhas", centro)
	_material.set_shader_parameter("negativo", 1.0)
	_material.set_shader_parameter("linhas", 1.0)
	_material.set_shader_parameter("aberracao", 14.0)
	Engine.time_scale = 0.03
	await get_tree().create_timer(congelar, true, false, true).timeout
	Engine.time_scale = 1.0
	_material.set_shader_parameter("negativo", 0.0)
	flash(Color.WHITE, 0.3, 0.85)
	var t := _novo_tween().set_parallel()
	_tween_param(t, "linhas", 0.0, 0.9)
	_tween_param(t, "aberracao", 0.0, 0.8)

## Linhas de velocidade contínuas (tensão crescente).
func linhas(forca: float, segundos := 0.4) -> void:
	_tween_param(_novo_tween(), "linhas", forca, segundos)

func pulso_aberracao(forca := 6.0, segundos := 0.5) -> void:
	_material.set_shader_parameter("aberracao", forca)
	_tween_param(_novo_tween(), "aberracao", 0.0, segundos)

func brilho_luzes(forca: float, segundos := 1.0) -> void:
	_tween_param(_novo_tween(), "faixa_luz", forca, segundos)

func _tween_param(tween: Tween, nome: String, valor: float, segundos: float) -> void:
	tween.tween_method(func(v: float) -> void: _material.set_shader_parameter(nome, v), _ler(nome, 0.0), valor, segundos) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _ler(nome: String, padrao):
	var v = _material.get_shader_parameter(nome)
	return padrao if v == null else v

## Efeitos ignoram a câmera lenta (Engine.time_scale), senão o congelamento os pararia.
func _novo_tween() -> Tween:
	return create_tween().set_ignore_time_scale(true)

func _exit_tree() -> void:
	Engine.time_scale = 1.0
