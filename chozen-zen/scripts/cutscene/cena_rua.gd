extends Node2D

## Plano 2 — Voltando para casa no fim da tarde. O céu escurece enquanto ele anda (parallax em
## três camadas) e os postes acendem um a um. O celular vibra: a turma já está comentando.

const PADRAO_LONGE := 400
const PADRAO_MEIO := 300
const DISTANCIA_POSTES := 110
const PES_Y := 162

const CEU_TOPO := [Color("7e6ba8"), Color("2a3558")]
const CEU_MEIO := [Color("d9878a"), Color("6b4e78")]
const CEU_HORIZONTE := [Color("f6c48e"), Color("c07a7a")]
const PREDIOS := [Color("a8697c"), Color("4a3a5c")]
const ARVORES := [Color("3e6e57"), Color("1f3a33")]
const CALCADA := [Color("c9ad8a"), Color("8a7a74")]
const MEIO_FIO := [Color("dcc7a5"), Color("9d8f86")]
const RUA := [Color("5a5560"), Color("33303a")]
const JANELA_ACESA := Color("f7d8a0")
const LUZ_POSTE := Color(1.0, 0.85, 0.55, 0.55)

var escurecer := 0.0:
	set(valor):
		escurecer = valor
		queue_redraw()
var andando := false
var velocidade := 80.0
var jogador := AnimatedSprite2D.new()

var _distancia := 0.0
var _predios: Array[Dictionary] = []
var _meio: Array[Dictionary] = []
var _emote := Emote.new()

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var x := 0
	while x < PADRAO_LONGE:
		var w := rng.randi_range(18, 34)
		_predios.append({"x": x, "w": w, "h": rng.randi_range(22, 58), "limiar": rng.randf_range(0.25, 0.9)})
		x += w + rng.randi_range(0, 4)
	x = 0
	while x < PADRAO_MEIO:
		if rng.randf() < 0.6:
			_meio.append({"tipo": "arvore", "x": x, "r": rng.randi_range(8, 12)})
			x += rng.randi_range(26, 40)
		else:
			_meio.append({"tipo": "casa", "x": x, "w": rng.randi_range(26, 34), "h": rng.randi_range(14, 20)})
			x += rng.randi_range(40, 52)
	jogador.sprite_frames = preload("res://assets/sprites/jogador/jogador_frames.tres")
	jogador.offset = Vector2(0, -61)
	jogador.position = Vector2(140, PES_Y) * Pixel.U
	jogador.frame_changed.connect(_on_frame_changed)
	add_child(jogador)
	add_child(_emote)
	_folhas()

func _folhas() -> void:
	var folhas := CPUParticles2D.new()
	folhas.position = Vector2(700, -20)
	folhas.amount = 18
	folhas.lifetime = 7.0
	folhas.preprocess = 7.0
	folhas.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	folhas.emission_rect_extents = Vector2(900, 10)
	folhas.direction = Vector2(-1, 0.6)
	folhas.spread = 20.0
	folhas.gravity = Vector2(-6, 18)
	folhas.initial_velocity_min = 30.0
	folhas.initial_velocity_max = 60.0
	folhas.angular_velocity_min = -90.0
	folhas.angular_velocity_max = 90.0
	folhas.scale_amount_min = 4.0
	folhas.scale_amount_max = 6.0
	var cores := Gradient.new()
	cores.set_color(0, Color("d9878a"))
	cores.set_color(1, Color("f4b183"))
	folhas.color_initial_ramp = cores
	add_child(folhas)

func tocar(d: Node) -> void:
	Audio.play_ambience(Audio.AMB_STREET, 1.0)
	Audio.play_music(Audio.MUSIC_MELANCHOLY, 1.5)
	Audio.set_music_muffled(false, 0.1)
	d.fx.clima("quente", 0.0)
	d.fx.brilho_luzes(0.4, 0.5)
	d.carimbo("17:48", "Voltando para casa")
	create_tween().tween_property(self, "escurecer", 0.6, 14.0)
	d.enquadrar_ja(Vector2(560, 470), 1.3)
	d.enquadrar(Vector2(640, 380), 1.0, 3.0)
	_andar(0.75)
	await d.espera(2.8)

	# O celular vibra. O grupo da turma já está falando dele.
	_parar()
	_emote.position = jogador.position + Vector2(0, -120)
	_emote.mostrar("celular", 1.0)
	Audio.sfx("phone")
	await d.espera(0.9)
	jogador.play("idle_down")
	d.fx.desfocar(3.5)
	d.fx.clima("frio", 1.5)
	d.enquadrar(jogador.position + Vector2(0, -60), 1.6, 1.5)
	await d.celular.abrir("9º B — Turma", "32 participantes", "17:48")
	await d.celular.mensagem("Bia", "gente, a prof pegou alguém colando??")
	await d.celular.mensagem("Rafa", "foi o da carteira do meio kkkkk")
	await d.celular.mensagem("Duda", "sério??", false, 0.4)
	await d.celular.mensagem("Gui", "sempre achei estranho ele tirar 10")
	await d.celular.mensagem("Mari", "coitado... será que foi ele mesmo?")
	await d.celular.mensagem("Rafa", "óbvio né", false, 0.4)
	await d.celular.digitando_e_some("Lucas", 1.8)
	await d.celular.mensagem("Bia", "amanhã é a recuperação dele kkkk", false, 0.5)
	await d.espera(0.9)
	await d.celular.fechar()
	d.fx.desfocar(0.0)
	await d.dizer("voce", "triste", "Ótimo. Agora a turma inteira acha que eu colei.", "esquerda", true)
	d.dialogo.fechar()
	d.fx.clima("memoria", 2.0)
	d.enquadrar(Vector2(640, 380), 1.0, 2.0)
	_andar(0.55)
	await d.espera(2.6)

func _andar(ritmo: float) -> void:
	andando = true
	velocidade = 110.0 * ritmo
	jogador.play("walk_right")
	jogador.speed_scale = ritmo

func _parar() -> void:
	andando = false
	jogador.play("idle_right")
	jogador.speed_scale = 1.0

func _process(delta: float) -> void:
	if andando:
		_distancia += velocidade * delta
		queue_redraw()

func _on_frame_changed() -> void:
	if andando and jogador.frame in [0, 2]:
		Audio.step()

func _cor(par: Array) -> Color:
	return (par[0] as Color).lerp(par[1], escurecer)

func _draw() -> void:
	var anda := _distancia / Pixel.U
	# céu em faixas e sol se pondo
	Pixel.faixas(self, -100, -60, 520, 200, [_cor(CEU_TOPO), _cor(CEU_MEIO), _cor(CEU_HORIZONTE)], 6)
	var sol_y := 92.0 + escurecer * 40.0
	Pixel.brilho(self, 232, sol_y, 24, Color(1, 0.88, 0.65, 0.5))
	Pixel.circulo(self, 232, sol_y, 12, Color("fbe3b0"))
	if escurecer > 0.35:
		var a := (escurecer - 0.35) * 2.0
		for estrela in [Vector2(30, 10), Vector2(88, 24), Vector2(150, 6), Vector2(270, 18), Vector2(310, 34), Vector2(200, 30)]:
			Pixel.rect(self, estrela.x, estrela.y, 1, 1, Color(1, 1, 1, a))
	# prédios ao longe (mais lentos)
	var off := fposmod(anda * 0.15, PADRAO_LONGE)
	for repeticao in range(-1, 3):
		for p in _predios:
			var px: float = p["x"] - off + repeticao * PADRAO_LONGE - 100
			if px > 420 or px + p["w"] < -100:
				continue
			Pixel.rect(self, px, 140 - p["h"], p["w"], p["h"], _cor(PREDIOS))
			if escurecer > p["limiar"] * 0.6:
				for jy in range(136 - p["h"] + 6, 136, 6):
					for jx in range(2, p["w"] - 2, 5):
						if (int(jx + jy + p["x"]) % 3) != 0:
							Pixel.rect(self, px + jx, jy, 2, 2, JANELA_ACESA)
	# árvores e casas (meio)
	off = fposmod(anda * 0.45, PADRAO_MEIO)
	var cor_meio := _cor(ARVORES)
	for repeticao in range(-1, 3):
		for item in _meio:
			var mx: float = item["x"] - off + repeticao * PADRAO_MEIO - 100
			if mx > 440 or mx < -140:
				continue
			if item["tipo"] == "arvore":
				var r: int = item["r"]
				Pixel.rect(self, mx - 1, 134, 3, 10, cor_meio.darkened(0.2))
				Pixel.circulo(self, mx, 132 - r, r, cor_meio)
				Pixel.circulo(self, mx - r * 0.6, 136 - r * 0.6, roundi(r * 0.7), cor_meio)
			else:
				var w: int = item["w"]
				var h: int = item["h"]
				Pixel.rect(self, mx, 144 - h, w, h, cor_meio)
				for k in 9:
					Pixel.rect(self, mx - 2 + k, 144 - h - 1 - k, w + 4 - k * 2, 1, cor_meio.darkened(0.15))
				var janela := JANELA_ACESA if escurecer > 0.3 else cor_meio.lightened(0.15)
				Pixel.rect(self, mx + 5, 144 - h + 5, 5, 5, janela)
	# calçada, meio-fio e rua (velocidade real)
	Pixel.rect(self, -100, 144, 520, 28, _cor(CALCADA))
	off = fposmod(anda, 16)
	for jx in range(-100, 436, 16):
		Pixel.rect(self, jx - off, 144, 1, 28, _cor(CALCADA).darkened(0.08))
	Pixel.rect(self, -100, 172, 520, 2, _cor(MEIO_FIO))
	Pixel.rect(self, -100, 174, 520, 70, _cor(RUA))
	off = fposmod(anda, 40)
	for jx in range(-100, 460, 40):
		Pixel.rect(self, jx - off, 182, 18, 1, Color(1, 1, 1, 0.25))
	# postes: acendem quando escurece
	off = fposmod(anda, DISTANCIA_POSTES)
	for i in range(-1, 5):
		var lx := i * DISTANCIA_POSTES - off + 30
		var acesso := escurecer > 0.22 + 0.03 * i
		if acesso:
			var cone := PackedVector2Array([Vector2(lx - 1, 106), Vector2(lx + 3, 106), Vector2(lx + 14, 160), Vector2(lx - 12, 160)])
			for k in cone.size():
				cone[k] *= Pixel.U
			draw_colored_polygon(cone, Color(LUZ_POSTE, 0.12))
			Pixel.brilho(self, lx + 1, 105, 10, LUZ_POSTE)
		Pixel.rect(self, lx, 104, 2, 42, Color("2f3a3a"))
		Pixel.rect(self, lx - 2, 102, 6, 3, Color("2f3a3a"))
		Pixel.rect(self, lx - 1, 105, 4, 1, JANELA_ACESA if acesso else Color("5d6666"))
	# sombra longa (o sol está à direita)
	var jx_u := jogador.position.x / Pixel.U
	Pixel.rect(self, jx_u - 16, PES_Y - 1, 20, 2, Color(0.15, 0.05, 0.15, 0.22))
