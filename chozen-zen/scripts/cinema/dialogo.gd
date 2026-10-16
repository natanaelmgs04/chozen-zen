class_name Dialogo
extends CanvasLayer

## Caixa de diálogo com retratos (Persona / Celeste / Night in the Woods):
## - o retrato de quem fala entra deslizando; quem escuta fica apagado ao fundo;
## - cada personagem tem uma "voz" (bipes com tom próprio) e uma cor na plaquinha do nome;
## - BBCode no texto: [shake] para gritos, [wave] para carinho, [color] para ênfase;
## - pausas naturais na pontuação; E / Espaço / clique completa o texto ou avança.

signal avancou

const PERSONAGENS := {
	"voce": {"nome": "Você", "retrato": "jogador", "voz": 1.0, "cor": Color("2f6b52")},
	"mae": {"nome": "Mãe", "retrato": "mae", "voz": 0.82, "cor": Color("b9616a")},
	"professora": {"nome": "Profª Helena", "retrato": "professora", "voz": 0.68, "cor": Color("b9802a")},
	"lucas": {"nome": "Lucas", "retrato": "lucas", "voz": 1.25, "cor": Color("4a6fa5")},
}
const LADO_RETRATO := 280.0
const CAIXA_ALTURA := 170.0
const FONTE := preload("res://ui/font_regular.tres")
const FONTE_NEGRITO := preload("res://ui/font_bold.tres")

## Para testes automáticos (screenshot_runner): avança sozinho depois de ler.
static var avanco_automatico := false

var _raiz := Control.new()
var _caixa := PanelContainer.new()
var _texto := RichTextLabel.new()
var _placa := PanelContainer.new()
var _nome := Label.new()
var _seta := Control.new()
var _suportes := {}
var _retratos := {}
var _ativo_lado := ""
var _digitando := false
var _esperando := false
var _acumulado := 0.0
var _voz := 1.0
var _aberto := false
var _pensamento := false
var _murmurios := Control.new()

func _init(camada := 12) -> void:
	layer = camada

func _ready() -> void:
	_raiz.anchor_right = 1.0
	_raiz.anchor_bottom = 1.0
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)
	_murmurios.anchor_right = 1.0
	_murmurios.anchor_bottom = 1.0
	_murmurios.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_murmurios)
	for lado in ["esquerda", "direita"]:
		var suporte := Control.new()
		suporte.mouse_filter = Control.MOUSE_FILTER_IGNORE
		suporte.size = Vector2(LADO_RETRATO, LADO_RETRATO)
		var retrato := Retrato.new()
		retrato.size = suporte.size
		if lado == "direita":
			retrato.flip_h = true
		suporte.add_child(retrato)
		_raiz.add_child(suporte)
		suporte.visible = false
		_suportes[lado] = suporte
		_retratos[lado] = retrato
	_montar_caixa()
	_raiz.visible = false

func _montar_caixa() -> void:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.984, 0.961, 0.925, 0.97)
	estilo.border_color = Color("e8b4ae")
	estilo.set_border_width_all(3)
	estilo.border_width_left = 10
	estilo.set_corner_radius_all(18)
	estilo.shadow_color = Color(0.07, 0.16, 0.13, 0.45)
	estilo.shadow_size = 14
	estilo.shadow_offset = Vector2(0, 6)
	estilo.content_margin_top = 34
	estilo.content_margin_bottom = 18
	estilo.content_margin_left = 30
	estilo.content_margin_right = 30
	_caixa.add_theme_stylebox_override("panel", estilo)
	_caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(_caixa)
	_texto.bbcode_enabled = true
	_texto.fit_content = true
	_texto.scroll_active = false
	_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texto.add_theme_font_override("normal_font", FONTE)
	_texto.add_theme_font_override("bold_font", FONTE_NEGRITO)
	_texto.add_theme_font_size_override("normal_font_size", 25)
	_texto.add_theme_font_size_override("bold_font_size", 25)
	_texto.add_theme_color_override("default_color", Color("1f4b3b"))
	_caixa.add_child(_texto)
	# plaquinha do nome, levemente inclinada (energia de Persona sem perder a delicadeza)
	var estilo_placa := StyleBoxFlat.new()
	estilo_placa.set_corner_radius_all(10)
	estilo_placa.content_margin_left = 18
	estilo_placa.content_margin_right = 18
	estilo_placa.content_margin_top = 4
	estilo_placa.content_margin_bottom = 6
	estilo_placa.shadow_color = Color(0, 0, 0, 0.25)
	estilo_placa.shadow_size = 4
	estilo_placa.shadow_offset = Vector2(2, 3)
	_placa.add_theme_stylebox_override("panel", estilo_placa)
	_placa.rotation_degrees = -3.0
	_placa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_placa.z_index = 2
	_nome.add_theme_font_override("font", FONTE_NEGRITO)
	_nome.add_theme_font_size_override("font_size", 24)
	_nome.add_theme_color_override("font_color", Color("fbf5ec"))
	_placa.add_child(_nome)
	_raiz.add_child(_placa)
	_seta.custom_minimum_size = Vector2(22, 14)
	_seta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_seta.z_index = 2
	_seta.draw.connect(func() -> void:
		_seta.draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(22, 0), Vector2(11, 13)]), Color("b9616a")))
	_raiz.add_child(_seta)
	_seta.visible = false

## Uma fala. `lado`: onde fica o retrato. `pensamento`: monólogo interno (sem boca mexendo).
func dizer(quem: String, expressao: String, texto: String, lado := "esquerda", pensamento := false) -> void:
	var dados: Dictionary = PERSONAGENS[quem]
	_pensamento = pensamento
	_voz = dados["voz"]
	await _abrir()
	_mostrar_retrato(lado, dados["retrato"], expressao)
	_nome.text = dados["nome"] + (" (pensando)" if pensamento else "")
	_posicionar(lado)
	(_placa.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = dados["cor"]
	_texto.add_theme_color_override("default_color", Color("4f6f63") if pensamento else Color("1f4b3b"))
	_texto.text = ("[i]%s[/i]" % texto) if pensamento else texto
	_texto.visible_characters = 0
	_seta.visible = false
	_acumulado = 0.0
	_digitando = true
	_retratos[lado].falando = not pensamento
	if Settings.chars_per_second() <= 0.0:
		_terminar_digitacao()
	await avancou

func fechar() -> void:
	if not _aberto:
		return
	_aberto = false
	_seta.visible = false
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_raiz, "modulate:a", 0.0, 0.22)
	for lado in _suportes:
		var suporte: Control = _suportes[lado]
		tween.tween_property(suporte, "position:x", _fora(lado), 0.25)
	await tween.finished
	_raiz.visible = false
	for lado in _suportes:
		_suportes[lado].visible = false
		_retratos[lado].definir("", "")
	_ativo_lado = ""

## Cochichos da turma espalhados pela tela (Persona): frases curtas que surgem e somem.
func murmurios(frases: Array, duracao := 2.6) -> void:
	var tela := _raiz.get_viewport_rect().size
	var posicoes := [Vector2(0.12, 0.22), Vector2(0.7, 0.16), Vector2(0.22, 0.52), Vector2(0.78, 0.46),
		Vector2(0.42, 0.12), Vector2(0.6, 0.62), Vector2(0.08, 0.38), Vector2(0.86, 0.3)]
	posicoes.shuffle()
	for i in frases.size():
		var label := Label.new()
		label.text = frases[i]
		label.theme_type_variation = &"WorldLabel"
		label.add_theme_font_size_override("font_size", 20 + (i % 3) * 3)
		label.add_theme_color_override("font_color", Color("e9dfd2"))
		label.add_theme_color_override("font_outline_color", Color("1f2a27"))
		label.modulate.a = 0.0
		label.rotation_degrees = randf_range(-6, 6)
		label.position = posicoes[i % posicoes.size()] * tela
		_murmurios.add_child(label)
		var tween := label.create_tween()
		tween.tween_interval(i * 0.32)
		tween.tween_property(label, "modulate:a", 0.9, 0.25)
		tween.parallel().tween_property(label, "position:y", label.position.y - 18, duracao).set_trans(Tween.TRANS_SINE)
		tween.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(maxf(0.2, duracao - 0.9))
		tween.tween_callback(label.queue_free)
	Audio.sfx("whispers", -6.0, 0.1)

# --- interno ------------------------------------------------------------------------

func _abrir() -> void:
	if _aberto:
		return
	_aberto = true
	_raiz.visible = true
	_raiz.modulate.a = 0.0
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_raiz, "modulate:a", 1.0, 0.18)
	await tween.finished

func _mostrar_retrato(lado: String, personagem: String, expressao: String) -> void:
	var suporte: Control = _suportes[lado]
	var retrato: Retrato = _retratos[lado]
	var tela := _raiz.get_viewport_rect().size
	var y := tela.y - CAIXA_ALTURA - LADO_RETRATO + 74
	var x := 24.0 if lado == "esquerda" else tela.x - LADO_RETRATO - 24
	if not suporte.visible or retrato.personagem != personagem:
		suporte.visible = true
		suporte.position = Vector2(_fora(lado), y)
		retrato.definir(personagem, expressao)
		Audio.sfx("swoosh", -6.0, 0.05)
		create_tween().tween_property(suporte, "position:x", x, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		retrato.definir(personagem, expressao)
	# quem fala acende; quem escuta fica atrás, apagado
	for outro in _suportes:
		var ativo: bool = outro == lado
		var alvo := Color(1, 1, 1, 1) if ativo else Color(0.55, 0.58, 0.6, 1)
		create_tween().tween_property(_suportes[outro], "modulate", alvo, 0.2)
		_suportes[outro].z_index = 1 if ativo else 0
		if not ativo:
			_retratos[outro].falando = false
	_ativo_lado = lado

func _posicionar(lado: String) -> void:
	var tela := _raiz.get_viewport_rect().size
	var margem := 40.0
	_caixa.position = Vector2(margem, tela.y - CAIXA_ALTURA - 22)
	_caixa.size = Vector2(tela.x - margem * 2, CAIXA_ALTURA)
	var recuo := LADO_RETRATO - 40
	var estilo := _caixa.get_theme_stylebox("panel") as StyleBoxFlat
	# abre espaço para todo retrato visível (quem fala e quem escuta)
	estilo.content_margin_left = recuo if _suportes["esquerda"].visible else 30.0
	estilo.content_margin_right = recuo if _suportes["direita"].visible else 30.0
	_caixa.move_to_front()
	for suporte in _suportes.values():
		suporte.move_to_front()
	_placa.move_to_front()
	_seta.move_to_front()
	# a plaquinha fica do lado de quem fala
	_placa.size = _placa.get_combined_minimum_size()
	var placa_x := _caixa.position.x + recuo - 6
	if lado == "direita":
		placa_x = _caixa.position.x + _caixa.size.x - recuo - _placa.size.x + 6
	_placa.position = Vector2(placa_x, _caixa.position.y - 20)
	_seta.position = Vector2(_caixa.position.x + _caixa.size.x - (recuo + 10 if lado == "direita" else 52), _caixa.position.y + CAIXA_ALTURA - 34)

func _fora(lado: String) -> float:
	return -LADO_RETRATO - 40 if lado == "esquerda" else _raiz.get_viewport_rect().size.x + 40

func _process(delta: float) -> void:
	if _seta.visible:
		_seta.position.y += sin(Time.get_ticks_msec() / 140.0) * 0.4
	if not _digitando:
		return
	var cps := Settings.chars_per_second()
	_acumulado += delta * cps
	var total := _texto.get_total_character_count()
	while _acumulado >= 1.0 and _texto.visible_characters < total:
		_acumulado -= 1.0
		_texto.visible_characters += 1
		var i := _texto.visible_characters
		var letra := _texto.get_parsed_text().substr(i - 1, 1)
		if letra in [".", "!", "?"]:
			_acumulado -= cps * 0.22
		elif letra == ",":
			_acumulado -= cps * 0.08
		elif i % 2 == 0 and letra != " ":
			Audio.sfx_pitch("blip", _voz * (0.92 if _pensamento else 1.0), -3.0, 0.06)
	if _texto.visible_characters >= total:
		_terminar_digitacao()

func _terminar_digitacao() -> void:
	_digitando = false
	_texto.visible_characters = -1
	if _ativo_lado != "":
		_retratos[_ativo_lado].falando = false
	_seta.visible = true
	_esperando = true
	if avanco_automatico:
		await get_tree().create_timer(1.0).timeout
		_avancar()

func _avancar() -> void:
	if not _esperando:
		return
	_esperando = false
	_seta.visible = false
	Audio.sfx("click", -8.0)
	avancou.emit()

func _input(event: InputEvent) -> void:
	if not _aberto or not _raiz.visible:
		return
	var apertou := event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")
	apertou = apertou or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not apertou:
		return
	get_viewport().set_input_as_handled()
	if _digitando:
		_terminar_digitacao()
	else:
		_avancar()
