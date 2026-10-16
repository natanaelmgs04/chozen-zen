extends Node2D

## Plano 3 — A porta de casa. A sombra da mãe passa pela janela (ela está esperando),
## ele para, respira fundo e entra. A luz quente da porta emenda com o começo da fase.

const SILHUETA := preload("res://assets/shaders/silhueta.gdshader")
const PAREDE := Color("efd9bf")
const PAREDE_LINHA := Color("e2c7a8")
const TELHADO := Color("5a3a2a")
const MADEIRA := Color("7a4e2f")
const MADEIRA_ESCURA := Color("6b4429")
const VIDRO := [Color("f4b183"), Color("f9d29a")]
const CORTINA := Color("d9878a")
const LUZ_DE_DENTRO := Color("ffe2b0")
const CALCADA := Color("b8a08a")
const GRAMA := Color("4f7f63")
const PORTA := Rect2(189, 87, 30, 63)
const PES_Y := 172

var abertura := 0.0:
	set(valor):
		abertura = valor
		_moldura.queue_redraw()
		_luz.queue_redraw()
var jogador := AnimatedSprite2D.new()

var _vidro := Node2D.new()
var _mae := Sprite2D.new()
var _moldura := Node2D.new()
var _luz := Node2D.new()
var _emote := Emote.new()

func _ready() -> void:
	# A sombra da mãe só aparece dentro do vidro da janela.
	_vidro.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	_vidro.draw.connect(func() -> void: Pixel.faixas(_vidro, 62, 60, 56, 46, VIDRO, 6))
	add_child(_vidro)
	var material := ShaderMaterial.new()
	material.shader = SILHUETA
	material.set_shader_parameter("cor", Color(0.45, 0.24, 0.22, 0.72))
	material.set_shader_parameter("forma", 0.0)
	_mae.material = material
	_mae.texture = preload("res://assets/sprites/mae/idle_right_0.png")
	_mae.position = Vector2(40, 80) * Pixel.U
	_vidro.add_child(_mae)
	_moldura.draw.connect(_desenhar_frente)
	add_child(_moldura)
	_luz.draw.connect(_desenhar_luz)
	add_child(_luz)
	jogador.sprite_frames = preload("res://assets/sprites/jogador/jogador_frames.tres")
	jogador.offset = Vector2(0, -61)
	jogador.position = Vector2(-20, PES_Y) * Pixel.U
	jogador.frame_changed.connect(func() -> void:
		if jogador.animation.begins_with("walk") and jogador.frame in [0, 2]:
			Audio.step())
	add_child(jogador)
	add_child(_emote)

func tocar(d: Node) -> void:
	d.fx.clima("noite", 0.0)
	d.fx.brilho_luzes(0.0, 0.0)
	d.carimbo("18:10", "Em casa")
	Audio.set_music_muffled(true, 1.5)
	# A sombra da mãe atravessa a janela: ela está esperando.
	var sombra := create_tween()
	sombra.tween_property(_mae, "position:x", 128.0 * Pixel.U, 3.2).set_delay(0.4)
	sombra.tween_callback(func() -> void: _mae.texture = preload("res://assets/sprites/mae/idle_left_0.png"))
	sombra.tween_property(_mae, "position:x", 92.0 * Pixel.U, 1.6).set_delay(0.8)

	d.enquadrar_ja(Vector2(420, 420), 1.15)
	d.enquadrar(Vector2(700, 420), 1.15, 4.4)
	jogador.play("walk_right")
	jogador.speed_scale = 0.75
	var chegada := create_tween()
	chegada.tween_property(jogador, "position:x", 204.0 * Pixel.U, 4.4)
	await chegada.finished
	jogador.speed_scale = 1.0
	jogador.play("idle_up")
	await d.espera(0.4)
	await d.dizer("voce", "triste", "Só quero ir pro meu quarto e esquecer esse dia.", "esquerda", true)
	d.dialogo.fechar()

	# Respira fundo... e abre a porta. A luz quente de dentro toma a tela.
	d.enquadrar(Vector2(816, 520), 1.7, 1.6)
	_emote.position = jogador.position + Vector2(0, -120)
	_emote.mostrar("...", 1.1)
	await d.espera(1.3)
	jogador.play("walk_up")
	var subir := create_tween()
	subir.tween_property(jogador, "position:y", 158.0 * Pixel.U, 0.6)
	await subir.finished
	jogador.play("idle_up")
	Audio.sfx("door")
	Audio.play_music(Audio.MUSIC_THEME, 2.0)
	Audio.set_music_muffled(false, 2.0)
	d.fx.clima("quente", 1.2)
	d.fx.brilho_luzes(1.2, 1.2)
	create_tween().tween_property(self, "abertura", 1.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await d.espera(0.8)
	jogador.play("walk_up")
	var entrar := create_tween().set_parallel()
	entrar.tween_property(jogador, "position:y", 150.0 * Pixel.U, 0.8)
	entrar.tween_property(jogador, "modulate:a", 0.0, 0.8).set_delay(0.2)
	d.enquadrar(Vector2(816, 480), 2.6, 1.4)
	await d.espera(0.6)

func _draw() -> void:
	Pixel.faixas(self, -100, -60, 520, 84, [Color("2a3558"), Color("5d4a78"), Color("b0727a")], 6)
	for estrela in [Vector2(20, 6), Vector2(70, 14), Vector2(140, 4), Vector2(250, 10), Vector2(300, 2)]:
		Pixel.rect(self, estrela.x, estrela.y, 1, 1, Color(1, 1, 1, 0.8))
	# telhado e parede
	Pixel.rect(self, -100, 22, 520, 12, TELHADO)
	for x in range(-100, 420, 8):
		Pixel.rect(self, x, 28, 1, 6, TELHADO.darkened(0.25))
	Pixel.rect(self, -100, 34, 520, 2, Color(0, 0, 0, 0.25))
	Pixel.rect(self, -100, 36, 520, 114, PAREDE)
	for y in range(42, 150, 6):
		Pixel.rect(self, -100, y, 520, 1, PAREDE_LINHA)
	# luz da janela batendo na parede
	Pixel.brilho(self, 90, 84, 44, Color(1, 0.8, 0.5, 0.18))
	# moldura da porta
	Pixel.rect(self, PORTA.position.x - 3, PORTA.position.y - 3, PORTA.size.x + 6, PORTA.size.y + 3, TELHADO)
	# chão: degrau, grama e calçada
	Pixel.rect(self, -100, 150, 520, 6, GRAMA)
	Pixel.rect(self, 180, 150, 48, 6, Color("cdb89a"))
	Pixel.rect(self, 180, 150, 48, 1, Color("e2d0b4"))
	Pixel.rect(self, -100, 156, 520, 90, CALCADA)
	for x in range(-100, 420, 16):
		Pixel.rect(self, x, 156, 1, 30, CALCADA.darkened(0.06))
	Pixel.rect(self, -100, 186, 520, 1, CALCADA.darkened(0.1))

## Janela (cortinas e caixilho por cima da sombra da mãe), porta, luminária, vaso e caixa de correio.
func _desenhar_frente() -> void:
	var c := _moldura
	Pixel.rect(c, 58, 56, 64, 2, MADEIRA_ESCURA)
	Pixel.rect(c, 58, 106, 64, 2, MADEIRA_ESCURA)
	Pixel.rect(c, 58, 56, 4, 52, MADEIRA_ESCURA)
	Pixel.rect(c, 118, 56, 4, 52, MADEIRA_ESCURA)
	Pixel.rect(c, 88, 58, 4, 48, MADEIRA_ESCURA)
	Pixel.rect(c, 62, 80, 56, 2, MADEIRA_ESCURA)
	Pixel.rect(c, 62, 58, 8, 48, CORTINA)
	Pixel.rect(c, 110, 58, 8, 48, CORTINA)
	Pixel.rect(c, 62, 58, 56, 3, CORTINA.darkened(0.1))
	Pixel.rect(c, 56, 108, 68, 3, MADEIRA)
	Pixel.rect(c, 58, 111, 64, 5, MADEIRA_ESCURA)
	for x in range(61, 120, 6):
		Pixel.rect(c, x, 109, 3, 2, Color("e07a7e"))
		Pixel.rect(c, x + 1, 110, 1, 1, Color("2f6b52"))
	# porta: o interior iluminado aparece conforme ela abre (dobradiça à esquerda)
	Pixel.rect(c, PORTA.position.x, PORTA.position.y, PORTA.size.x, PORTA.size.y, LUZ_DE_DENTRO)
	var largura := roundi(PORTA.size.x * (1.0 - abertura * 0.8))
	Pixel.rect(c, PORTA.position.x, PORTA.position.y, largura, PORTA.size.y, MADEIRA if abertura < 0.05 else MADEIRA.darkened(0.25))
	if abertura < 0.05:
		for painel in [Rect2(192, 91, 10, 24), Rect2(206, 91, 10, 24), Rect2(192, 120, 10, 26), Rect2(206, 120, 10, 26)]:
			Pixel.rect(c, painel.position.x, painel.position.y, painel.size.x, 1, MADEIRA_ESCURA)
			Pixel.rect(c, painel.position.x, painel.position.y, 1, painel.size.y, MADEIRA_ESCURA)
			Pixel.rect(c, painel.position.x, painel.end.y - 1, painel.size.x, 1, MADEIRA.lightened(0.12))
			Pixel.rect(c, painel.end.x - 1, painel.position.y, 1, painel.size.y, MADEIRA.lightened(0.12))
		Pixel.rect(c, 215, 120, 2, 2, Color("e6b422"))
	# capacho
	Pixel.rect(c, 192, 150, 24, 2, Color("b9616a"))
	# número da casa e luminária acesa
	Pixel.rect(c, 226, 92, 10, 7, Color("fbf5ec"))
	Pixel.texto(c, 227, 93, "12", Color("1f4b3b"))
	Pixel.brilho(c, 231, 108, 16, Color(1, 0.85, 0.55, 0.5))
	Pixel.rect(c, 230, 102, 2, 3, TELHADO)
	Pixel.rect(c, 228, 105, 6, 7, TELHADO)
	Pixel.rect(c, 229, 106, 4, 5, Color("ffe2b0"))
	# vaso de planta
	Pixel.circulo(c, 239, 130, 6, Color("2f6b52"))
	Pixel.circulo(c, 236, 127, 4, Color("5f9a72"))
	Pixel.rect(c, 234, 138, 11, 12, Color("b9616a"))
	Pixel.rect(c, 233, 138, 13, 2, Color("d9878a"))
	# caixa de correio na calçada
	Pixel.rect(c, 34, 136, 2, 22, TELHADO)
	Pixel.rect_arredondado(c, 29, 128, 12, 9, Color("d9878a"))
	Pixel.rect(c, 41, 129, 1, 4, Color("c8412d"))

func _desenhar_luz() -> void:
	if abertura <= 0.0:
		return
	var feixe := PackedVector2Array([Vector2(189, 150), Vector2(219, 150), Vector2(238, 190), Vector2(172, 190)])
	for i in feixe.size():
		feixe[i] *= Pixel.U
	_luz.draw_colored_polygon(feixe, Color(1, 0.88, 0.62, 0.3 * abertura))
