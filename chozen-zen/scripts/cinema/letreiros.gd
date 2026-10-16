class_name Letreiros
extends CanvasLayer

## Tipografia em movimento das cutscenes:
## - cartão de capítulo (faixas diagonais + letras caindo, abertura de episódio estilo Persona/LiS);
## - carimbo de hora e lugar no canto (linguagem de cinema);
## - cortina diagonal em três cores para cortes entre planos.

const FONTE := preload("res://ui/font_regular.tres")
const FONTE_NEGRITO := preload("res://ui/font_bold.tres")
const VERDE := Color("1f4b3b")
const ROSA := Color("d9878a")
const PESSEGO := Color("f4b183")
const CREME := Color("fbf5ec")
const INCLINACAO := -7.0

var _raiz := Control.new()

func _init(camada := 60) -> void:
	layer = camada

func _ready() -> void:
	_raiz.anchor_right = 1.0
	_raiz.anchor_bottom = 1.0
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)

func _tela() -> Vector2:
	return _raiz.get_viewport_rect().size

func _faixa(cor: Color, altura: float, y: float) -> ColorRect:
	var faixa := ColorRect.new()
	faixa.color = cor
	faixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	faixa.size = Vector2(_tela().x * 2.2, altura)
	faixa.pivot_offset = faixa.size / 2
	faixa.rotation_degrees = INCLINACAO
	faixa.position = Vector2(-faixa.size.x - 200, y - altura / 2)
	_raiz.add_child(faixa)
	return faixa

func _label(texto: String, tamanho: int, cor: Color, negrito := true) -> Label:
	var label := Label.new()
	label.text = texto
	label.add_theme_font_override("font", FONTE_NEGRITO if negrito else FONTE)
	label.add_theme_font_size_override("font_size", tamanho)
	label.add_theme_color_override("font_color", cor)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

## Cartão de capítulo. Bloqueia até sair da tela.
func capitulo(rotulo: String, titulo: String, subtitulo: String, segurar := 2.0) -> void:
	var tela := _tela()
	var meio := tela.y * 0.5
	var centro_x := (tela.x - tela.x * 2.2) / 2
	var faixas := [_faixa(ROSA, 26, meio - 112), _faixa(VERDE, 190, meio), _faixa(PESSEGO, 26, meio + 112)]
	Audio.sfx("swoosh")
	var entrada := create_tween().set_parallel()
	for i in faixas.size():
		entrada.tween_property(faixas[i], "position:x", centro_x, 0.45).set_delay(i * 0.07) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await entrada.finished
	# rótulo pequeno, título letra a letra, subtítulo
	var bloco := VBoxContainer.new()
	bloco.alignment = BoxContainer.ALIGNMENT_CENTER
	bloco.add_theme_constant_override("separation", 2)
	bloco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bloco.rotation_degrees = INCLINACAO * 0.5
	var topo := _label(rotulo.to_upper(), 24, PESSEGO)
	topo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bloco.add_child(topo)
	var letras := HBoxContainer.new()
	letras.alignment = BoxContainer.ALIGNMENT_CENTER
	letras.add_theme_constant_override("separation", 0)
	bloco.add_child(letras)
	var lista: Array[Label] = []
	for letra in titulo:
		var l := _label(letra, 84, CREME)
		l.modulate.a = 0.0
		letras.add_child(l)
		lista.append(l)
	var sub := _label(subtitulo, 26, CREME, false)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.modulate.a = 0.0
	bloco.add_child(sub)
	_raiz.add_child(bloco)
	bloco.size = Vector2(tela.x, 220)
	bloco.position = Vector2(0, meio - 110)
	bloco.pivot_offset = bloco.size / 2
	await get_tree().process_frame
	Audio.sfx("memory", -4.0)
	for i in lista.size():
		var l := lista[i]
		l.pivot_offset = l.size / 2
		l.scale = Vector2(1.8, 1.8)
		var t := l.create_tween().set_parallel()
		t.tween_property(l, "modulate:a", 1.0, 0.15).set_delay(i * 0.045)
		t.tween_property(l, "scale", Vector2.ONE, 0.35).set_delay(i * 0.045).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	sub.create_tween().tween_property(sub, "modulate:a", 1.0, 0.5).set_delay(0.25 + lista.size() * 0.045)
	await get_tree().create_timer(segurar + lista.size() * 0.045).timeout
	# saída: texto some, faixas atravessam para a direita
	Audio.sfx("swoosh", -3.0)
	var saida := create_tween().set_parallel()
	saida.tween_property(bloco, "modulate:a", 0.0, 0.25)
	for i in faixas.size():
		saida.tween_property(faixas[i], "position:x", tela.x + 200, 0.5).set_delay(0.08 + (2 - i) * 0.06) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await saida.finished
	bloco.queue_free()
	for faixa in faixas:
		faixa.queue_free()

## Carimbo de hora/lugar no canto superior esquerdo (não bloqueia).
func carimbo(grande: String, pequeno: String, segurar := 2.8) -> void:
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", -4)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hora := _label(grande, 44, CREME)
	hora.add_theme_color_override("font_outline_color", VERDE)
	hora.add_theme_constant_override("outline_size", 10)
	caixa.add_child(hora)
	var lugar := _label(pequeno, 20, CREME)
	lugar.add_theme_color_override("font_outline_color", VERDE)
	lugar.add_theme_constant_override("outline_size", 8)
	caixa.add_child(lugar)
	var barra := ColorRect.new()
	barra.color = ROSA
	barra.custom_minimum_size = Vector2(0, 5)
	barra.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	caixa.add_child(barra)
	caixa.position = Vector2(48, 70)
	caixa.modulate.a = 0.0
	_raiz.add_child(caixa)
	var tween := caixa.create_tween()
	tween.tween_property(caixa, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(caixa, "position:x", 64.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(barra, "custom_minimum_size:x", 220.0, 0.6).set_delay(0.15).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_interval(segurar)
	tween.tween_property(caixa, "modulate:a", 0.0, 0.5)
	tween.tween_callback(caixa.queue_free)

## Cortina diagonal: três faixas cobrem a tela (aguardar) e depois `revelar()` abre.
var _cortina: Array[ColorRect] = []

func cobrir(segundos := 0.4) -> void:
	var tela := _tela()
	_limpar_cortina()
	var cores := [ROSA, PESSEGO, VERDE]
	var altura := tela.y * 1.6
	var tween := create_tween().set_parallel()
	Audio.sfx("swoosh", -2.0)
	for i in 3:
		var faixa := ColorRect.new()
		faixa.color = cores[i]
		faixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
		faixa.size = Vector2(tela.x * 1.5, altura)
		faixa.pivot_offset = faixa.size / 2
		faixa.rotation_degrees = 18.0
		faixa.position = Vector2(-faixa.size.x - 300, (tela.y - altura) / 2)
		_raiz.add_child(faixa)
		_cortina.append(faixa)
		tween.tween_property(faixa, "position:x", (tela.x - faixa.size.x) / 2, segundos).set_delay(i * 0.07) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await tween.finished

func revelar(segundos := 0.45) -> void:
	var tela := _tela()
	var tween := create_tween().set_parallel()
	for i in _cortina.size():
		tween.tween_property(_cortina[i], "position:x", tela.x + 300, segundos).set_delay((2 - i) * 0.07) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await tween.finished
	_limpar_cortina()

func _limpar_cortina() -> void:
	for faixa in _cortina:
		faixa.queue_free()
	_cortina.clear()
