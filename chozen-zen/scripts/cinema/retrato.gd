class_name Retrato
extends TextureRect

## Busto em pixel art (tools/make_retratos.py) que respira, pisca sozinho e mexe a boca
## enquanto o personagem fala, como em Celeste e Night in the Woods.

const PASTA := "res://assets/retratos/%s/%s_%s.png"
const QUADRO_BOCA := 0.09

var personagem := ""
var expressao := ""
var falando := false:
	set(valor):
		falando = valor
		if not falando:
			_boca_aberta = false
			_atualizar()

var _tempo := 0.0
var _proxima_piscada := 2.0
var _piscando := 0.0
var _boca_aberta := false
var _tempo_boca := 0.0
var _base_y := 0.0

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stretch_mode = TextureRect.STRETCH_KEEP
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func definir(novo_personagem: String, nova_expressao: String) -> void:
	var mudou := novo_personagem != personagem or nova_expressao != expressao
	personagem = novo_personagem
	expressao = nova_expressao
	_atualizar()
	if mudou and is_inside_tree():
		# "pulinho" ao trocar de expressão: a emoção chega com movimento
		pivot_offset = size * Vector2(0.5, 1.0)
		scale = Vector2(1.06, 0.94)
		create_tween().tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _ready() -> void:
	_base_y = position.y

func _process(delta: float) -> void:
	if personagem == "":
		return
	_tempo += delta
	# respiração: 1 pixel de arte para cima e para baixo
	position.y = _base_y + roundf(sin(_tempo * 2.2) * 2.5)
	_proxima_piscada -= delta
	if _piscando > 0.0:
		_piscando -= delta
		if _piscando <= 0.0:
			_atualizar()
	elif _proxima_piscada <= 0.0:
		_piscando = 0.12
		_proxima_piscada = randf_range(2.2, 4.5)
		_atualizar()
	if falando:
		_tempo_boca += delta
		if _tempo_boca >= QUADRO_BOCA:
			_tempo_boca = 0.0
			_boca_aberta = not _boca_aberta
			_atualizar()

func fixar_base() -> void:
	_base_y = position.y

func _atualizar() -> void:
	if personagem == "":
		texture = null
		return
	var quadro := "base"
	if _piscando > 0.0:
		quadro = "pisca"
	elif _boca_aberta:
		quadro = "fala"
	var caminho := PASTA % [personagem, expressao, quadro]
	if ResourceLoader.exists(caminho):
		texture = load(caminho)
