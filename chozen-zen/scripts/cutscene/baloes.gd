class_name Baloes
extends Control

## Balões de fala e notificações de celular para cutscenes (abertura e cenas da fase).
## `converter` transforma um ponto do mundo em ponto da tela. Se o balão tiver um alvo,
## ele acompanha o personagem enquanto a câmera ou o personagem se movem.

const FONTE_FALA := preload("res://ui/font_bold.tres")
const CREME := Color(0.984, 0.961, 0.925)
const BORDA := Color(0.91, 0.706, 0.682)

var converter: Callable = func(ponto: Vector2) -> Vector2: return ponto

var _seguindo: Array[Dictionary] = []

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

## Fala com digitação (mesma velocidade de texto das Configurações) e bipes curtos.
func falar(ponto: Vector2, texto: String, duracao := 1.8, alvo: Node2D = null) -> void:
	var label := Label.new()
	label.text = texto
	label.add_theme_font_override("font", FONTE_FALA)
	label.add_theme_font_size_override("font_size", 22)
	var balao := _balao(label, ponto, alvo, true)
	var cps := Settings.chars_per_second()
	label.visible_ratio = 0.0 if cps > 0.0 else 1.0
	if cps > 0.0:
		var digitar := label.create_tween()
		digitar.tween_property(label, "visible_ratio", 1.0, texto.length() / cps)
		for i in range(0, texto.length(), 3):
			digitar.parallel().tween_callback(Audio.sfx.bind("blip", 0.0, 0.1)).set_delay(i / cps)
	_sumir_depois(balao, duracao)

## Notificação de celular (título em destaque + mensagem), sem rabinho.
func notificar(ponto: Vector2, titulo: String, texto: String, duracao := 2.4, alvo: Node2D = null) -> void:
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 0)
	var topo := Label.new()
	topo.text = titulo
	topo.theme_type_variation = &"AccentLabel"
	var corpo := Label.new()
	corpo.text = texto
	caixa.add_child(topo)
	caixa.add_child(corpo)
	var balao := _balao(caixa, ponto, alvo, false)
	_sumir_depois(balao, duracao)

func limpar() -> void:
	_seguindo.clear()
	for filho in get_children():
		filho.queue_free()

func _process(_delta: float) -> void:
	for item in _seguindo.duplicate():
		# Checar antes de tipar: o balão some sozinho quando o tempo dele acaba.
		if not is_instance_valid(item["balao"]) or not is_instance_valid(item["alvo"]):
			_seguindo.erase(item)
			continue
		var alvo: Node2D = item["alvo"]
		_posicionar(item["balao"], alvo.global_position + item["ponto"])

func _balao(conteudo: Control, ponto: Vector2, alvo: Node2D, com_rabinho: bool) -> Control:
	var balao := Control.new()
	balao.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var painel := PanelContainer.new()
	painel.theme_type_variation = &"PillPanel"
	painel.add_child(conteudo)
	balao.add_child(painel)
	add_child(balao)
	painel.size = painel.get_combined_minimum_size()
	balao.size = painel.size
	if com_rabinho:
		var rabinho := Control.new()
		rabinho.name = "Rabinho"
		rabinho.draw.connect(func() -> void:
			rabinho.draw_colored_polygon(PackedVector2Array([Vector2(-9, 0), Vector2(9, 0), Vector2(0, 13)]), CREME)
			rabinho.draw_line(Vector2(-9, 1), Vector2(0, 13), BORDA, 2.0)
			rabinho.draw_line(Vector2(9, 1), Vector2(0, 13), BORDA, 2.0))
		balao.add_child(rabinho)
	if alvo:
		_seguindo.append({"balao": balao, "alvo": alvo, "ponto": ponto})
		_posicionar(balao, alvo.global_position + ponto)
	else:
		_posicionar(balao, ponto)
	balao.pivot_offset = Vector2(balao.size.x / 2, balao.size.y)
	balao.scale = Vector2.ONE * 0.6
	balao.modulate.a = 0.0
	var tween := balao.create_tween().set_parallel()
	tween.tween_property(balao, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(balao, "modulate:a", 1.0, 0.12)
	return balao

func _posicionar(balao: Control, ponto_mundo: Vector2) -> void:
	var tela: Vector2 = converter.call(ponto_mundo)
	var limite := get_viewport().get_visible_rect().size
	balao.position = Vector2(
		clampf(tela.x - balao.size.x / 2, 16, limite.x - balao.size.x - 16),
		clampf(tela.y - balao.size.y - 18, 16, limite.y - balao.size.y - 16))
	var rabinho := balao.get_node_or_null("Rabinho") as Control
	if rabinho:
		rabinho.position = Vector2(clampf(tela.x - balao.position.x, 22, balao.size.x - 22), balao.size.y - 3)

func _sumir_depois(balao: Control, segundos: float) -> void:
	var tween := balao.create_tween()
	tween.tween_interval(segundos)
	tween.tween_property(balao, "modulate:a", 0.0, 0.25)
	tween.tween_callback(balao.queue_free)
